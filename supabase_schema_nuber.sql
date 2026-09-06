/* 5T Protocol - Nuber Supabase Schema */
/* 部署至 Nuber.esggo.co 平台 */

-- ===== 1. 資料表結構 =====

-- 諮詢表單
CREATE TABLE IF NOT EXISTS inquiries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    service_type TEXT NOT NULL CHECK (service_type IN ('consultation', 'quote', 'investment', 'support', 'cooperation', 'carbon')),
    message TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'resolved', 'rejected')),
    carbon_credits BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 產品/服務
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('seaweed', 'feed', 'carbon', 'system', 'certification')),
    description TEXT NOT NULL,
    price DECIMAL(12,2),
    unit TEXT,
    image_url TEXT,
    featured BOOLEAN DEFAULT FALSE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'discontinued')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 碳權交易
CREATE TABLE IF NOT EXISTS carbon_credits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    farm_id UUID REFERENCES farms(id) ON DELETE SET NULL,
    carbon_type TEXT NOT NULL CHECK (carbon_type IN ('biomass', 'soil', 'blue')),
    amount DECIMAL(12,4) NOT NULL,
    price_per_tco2 DECIMAL(10,2),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'sold', 'cancelled')),
    verification_document TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 農場/合作夥伴
CREATE TABLE IF NOT EXISTS farms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('seaweed', 'livestock', 'mixed')),
    location TEXT,
    capacity DECIMAL(12,2),
    contact_name TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 訂單系統
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    customer_address TEXT,
    product_ids UUID[] DEFAULT '{}',
    items JSONB,
    total_amount DECIMAL(12,2) NOT NULL,
    currency TEXT DEFAULT 'TWD',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    order_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 使用者管理
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'manager', 'partner', 'investor')),
    phone TEXT,
    company TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 分析追蹤
CREATE TABLE IF NOT EXISTS analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event TEXT NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id TEXT,
    ip_address TEXT,
    user_agent TEXT,
    language TEXT,
    page_url TEXT,
    referrer TEXT,
    duration_seconds INTEGER,
    properties JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- ===== 2. 觸發器 =====

-- 自動更新 updated_at
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 為每個表添加觸發器
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN ARRAY ARRAY['inquiries','products','carbon_credits','farms','orders','users','analytics']
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_%I_timestamp ON %I;
            CREATE TRIGGER update_%I_timestamp 
            BEFORE UPDATE ON %I 
            FOR EACH ROW 
            EXECUTE FUNCTION update_timestamp();
        ', tbl, tbl, tbl, tbl);
    END LOOP;
END $$;

-- ===== 3. 啟用 RLS =====
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE carbon_credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

-- ===== 4. RLS 策略 =====

-- Inquiries: 公開提交
CREATE POLICY "inquiries_insert" ON inquiries FOR INSERT WITH CHECK (true);
CREATE POLICY "inquiries_select_update" ON inquiries FOR SELECT USING (auth.role() = 'admin' OR auth.role() = 'manager');
CREATE POLICY "inquiries_delete" ON inquiries FOR DELETE USING (auth.role() = 'admin');

-- Products: 公開查詢
CREATE POLICY "products_public" ON products FOR SELECT USING (true);
CREATE POLICY "products_admin" ON products FOR ALL USING (auth.role() = 'admin');

-- Farms: 公開查詢
CREATE POLICY "farms_public" ON farms FOR SELECT USING (true);
CREATE POLICY "farms_admin" ON farms FOR ALL USING (auth.role() = 'admin');

-- Carbon Credits: 公開查詢
CREATE POLICY "carbon_credits_public" ON carbon_credits FOR SELECT USING (true);
CREATE POLICY "carbon_credits_owner" ON carbon_credits FOR ALL USING (
    auth.role() = 'admin' OR 
    auth.uid() = id OR 
    EXISTS (SELECT 1 FROM farms WHERE id = carbon_credits.farm_id AND owner_id = auth.uid())
);

-- Orders: 公開下單
CREATE POLICY "orders_insert" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "orders_select" ON orders FOR SELECT USING (auth.role() IN ('admin', 'manager') OR auth.uid() IN (SELECT user_id FROM customer_orders));
CREATE POLICY "orders_update_delete" ON orders FOR UPDATE USING (auth.role() = 'admin');

-- Users: 自己訪問
CREATE POLICY "users_self" ON users FOR SELECT USING (auth.uid() = id OR auth.role() = 'admin');
CREATE POLICY "users_admin" ON users FOR ALL USING (auth.role() = 'admin');

-- Analytics: 記錄分析
CREATE POLICY "analytics_insert" ON analytics FOR INSERT WITH CHECK (true);
CREATE POLICY "analytics_select" ON analytics FOR SELECT USING (auth.role() = 'admin');

-- ===== 5. 索引 =====
CREATE INDEX IF NOT EXISTS idx_inquiries_created_at ON inquiries(created_at);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured);
CREATE INDEX IF NOT EXISTS idx_carbon_credits_status ON carbon_credits(status);
CREATE INDEX IF NOT EXISTS idx_farms_type ON farms(type);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_event ON analytics(event);

-- ===== 6. 預設資料 =====
INSERT INTO products (name, category, description, price, unit, featured) VALUES
    ('海門冬養殖場系統', 'seaweed', '高效陸基型熱帶海藻養殖設備', 85000.00, '套組', TRUE),
    ('IoT監控系統', 'system', '海門冬/畜牧業環境監控裝置', 12000.00, '單個', TRUE),
    ('生物碳驗證方案', 'certification', 'NDB 認證與碳權開發服務', 50000.00, '案', FALSE),
    ('減碳飼料添加劑', 'feed', '海門冬減碳添加劑 (可視化測試)', 350.00, '公斤', TRUE)
ON CONFLICT DO NOTHING;

-- ===== 完成 =====
COMMENT ON TABLE inquiries IS '5T Protocol: 客戶諮詢表單 - Nuber平台';
COMMENT ON TABLE products IS '5T Protocol: 產品與服務';
COMMENT ON TABLE carbon_credits IS '5T Protocol: 碳權交易系統';
COMMENT ON TABLE farms IS '5T Protocol: 合作農場資訊';
COMMENT ON TABLE orders IS '5T Protocol: 訂單系統';
COMMENT ON TABLE users IS '5T Protocol: 使用者與角色管理';
COMMENT ON TABLE analytics IS '5T Protocol: 分析追蹤';