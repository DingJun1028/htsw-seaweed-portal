-- ★★★★★ 5T Protocol - Supabase Schema for High Tech Seaweed ★★★★★
-- Traceable: source_origin="supabase-schema-migration"
-- Trackable: lifecycle hooks via created_at/updated_at
-- Tangible: clear table structures
-- Transparent: documented columns
-- Trustworthy: RLS policies enabled

-- 1. 建立 inquiries 表 (諮詢表單)
CREATE TABLE IF NOT EXISTS inquiries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    service_type TEXT NOT NULL CHECK (service_type IN ('consultation', 'quote', 'investment', 'support')),
    message TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'resolved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 建立 products 表 (產品列表)
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('equipment', 'frozen', 'food')),
    description TEXT NOT NULL,
    price DECIMAL(10,2),
    unit TEXT,
    image_url TEXT,
    featured BOOLEAN DEFAULT FALSE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'discontinued')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 建立 orders 表 (訂單系統)
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

-- 4. 建立 users 表 (使用者管理)
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'manager')),
    phone TEXT,
    company TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 建立 analytics 表 (分析追蹤)
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
    properties JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== 6. 建立觸發器函數 =====
-- 自動更新 updated_at 時間戳記
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 為每個表添加 updated_at 觸發器
DROP TRIGGER IF EXISTS update_inquiries_timestamp ON inquiries;
CREATE TRIGGER update_inquiries_timestamp 
    BEFORE UPDATE ON inquiries 
    FOR EACH ROW 
    EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS update_products_timestamp ON products;
CREATE TRIGGER update_products_timestamp 
    BEFORE UPDATE ON products 
    FOR EACH ROW 
    EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS update_orders_timestamp ON orders;
CREATE TRIGGER update_orders_timestamp 
    BEFORE UPDATE ON orders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS update_users_timestamp ON users;
CREATE TRIGGER update_users_timestamp 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_timestamp();

-- ===== 7. 啟用 Row Level Security =====
-- 這些 RLS 策略確保 Trustworthy 數據安全

ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

-- Inquiries RLS 策略
CREATE POLICY "inquiries_select_policy" ON inquiries
    FOR SELECT USING (auth.role() = 'admin' OR auth.role() = 'manager');

CREATE POLICY "inquiries_insert_policy" ON inquiries
    FOR INSERT WITH CHECK (true); -- 允許公開提交

CREATE POLICY "inquiries_update_delete_policy" ON inquiries
    FOR UPDATE USING (auth.role() = 'admin') WITH CHECK (true);
CREATE POLICY "inquiries_delete_policy" ON inquiries
    FOR DELETE USING (auth.role() = 'admin');

-- Products RLS 策略
CREATE POLICY "products_select_policy" ON products
    FOR SELECT USING (true); -- 公開查詢

CREATE POLICY "products_crud_policy" ON products
    FOR ALL USING (auth.role() = 'admin');

-- Orders RLS 策略
CREATE POLICY "orders_select_policy" ON orders
    FOR SELECT USING (auth.role() = 'admin' OR auth.role() = 'manager');

CREATE POLICY "orders_insert_policy" ON orders
    FOR INSERT WITH CHECK (true); -- 允許公開下單

CREATE POLICY "orders_update_delete_policy" ON orders
    FOR UPDATE USING (auth.role() = 'admin');

-- Users RLS 策略
CREATE POLICY "users_select_policy" ON users
    FOR SELECT USING (auth.role() = 'admin');

CREATE POLICY "users_self_access" ON users
    FOR SELECT USING (auth.uid() = id OR auth.role() = 'admin');

CREATE POLICY "users_insert_policy" ON users
    FOR INSERT WITH CHECK (auth.role() = 'admin');

CREATE POLICY "users_update_delete_policy" ON users
    FOR UPDATE USING (auth.role() = 'admin');

-- Analytics RLS 策略
CREATE POLICY "analytics_select_policy" ON analytics
    FOR SELECT USING (auth.role() = 'admin');

CREATE POLICY "analytics_insert_policy" ON analytics
    FOR INSERT WITH CHECK (true); -- 允許記錄分析

-- ===== 8. 建立索引提升查詢性能 =====
CREATE INDEX IF NOT EXISTS idx_inquiries_created_at ON inquiries(created_at);
CREATE INDEX IF NOT EXISTS idx_inquiries_status ON inquiries(status);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_analytics_event ON analytics(event);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics(created_at);

-- ===== 9. 預設資料 (可選) =====
-- 插入初始產品類別
INSERT INTO products (name, category, description, price, unit, featured, status) VALUES
    ('海藻養殖場系統', 'equipment', '高效陸基型海藻養殖設備', 85000.00, '套組', TRUE, 'active'),
    ('IoT監控系統', 'equipment', '海藻養殖環境監控裝置', 12000.00, '單個', TRUE, 'active'),
    ('藻到愛凍飲', 'frozen', '天然海藻營養凍飲品', 280.00, '瓶', TRUE, 'active'),
    ('級級海木耳', 'food', '有機海木耳級級食品', 350.00, '袋', TRUE, 'active')
ON CONFLICT DO NOTHING;

-- ===== 10. 建立監控視圖 (5T 透明度) =====
CREATE OR REPLACE VIEW inquiry_stats AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE status = 'pending') as pending,
    COUNT(*) FILTER (WHERE status = 'contacted') as contacted,
    COUNT(*) FILTER (WHERE status = 'resolved') as resolved
FROM inquiries
GROUP BY DATE(created_at)
ORDER BY date DESC;

CREATE OR REPLACE VIEW product_stats AS
SELECT 
    category,
    COUNT(*) as total_products,
    COUNT(*) FILTER (WHERE status = 'active') as active_products,
    AVG(price) as avg_price
FROM products
GROUP BY category;

-- ===== 完成 =====
COMMENT ON TABLE inquiries IS '5T Protocol: 客戶諮詢表單';
COMMENT ON TABLE products IS '5T Protocol: 產品目錄';
COMMENT ON TABLE orders IS '5T Protocol: 訂單系統';
COMMENT ON TABLE users IS '5T Protocol: 使用者管理';
COMMENT ON TABLE analytics IS '5T Protocol: 分析追蹤';

SELECT '5T Protocol Schema deployment completed successfully' as status;