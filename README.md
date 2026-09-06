# Nuber 平台 - 畜牧碳資產市場

> 台灣首創「海門冬 × 減碳飼養」牧業永續解決方案

## 🎯 平台概述

**Nuber.esggo.co** - 亞洲首個畜牧碳資產市場平台

- **PUSH 科技推力**：海門冬耐熱種 + IoT智慧監測 + dMRV驗證系統
- **PULL 經濟拉力**：酪農戶提升5%收益 + 終端消費永續溢價 + 碳權分潤
- **碳減排**：每頭牛年減1-3tCO2e

## 🎨 設計理念

### Logo 色彩標準
- **深海生技藍**: `#3B72B9` (Nuber主色)
- **萌芽嫩綠**: `#8CC63F` (永續點綴)  
- **深炭灰**: `#2B2B2B` (標準字)
- **純白**: `#FFFFFF` (乾淨背景)

### 5T Protocol 實踐
- **Traceable**: 所有檔案具備雜湊校驗
- **Trackable**: 生命週期可追蹤
- **Tangible**: 專業設計體驗 (emoji 完全移除)
- **Transparent**: 開源驗證腳本
- **Trustworthy**: 凍結配置物件

## 📁 專案結構

```
Nuber Platform
├── index.html              # 前台主頁 (Nuber設計)
├── style.css               # Logo色彩專業設計
├── script.js               # 5T Protocol JS + Supabase
├── package.json            # Vite建置配置
├── vite.config.js          # 生產建置設定
├── supabase_schema_nuber.sql # Nuber專用資料表
├── deploy.sh               # 部署腳本
├── nginx.conf              # 子域名nginx設定
├── verify_5t.py            # 5T驗證腳本
└── dist/                   # 建置產出
```

## 🔧 開發流程

```bash
# 安裝套件
npm install

# 開發模式
npm run dev

# 建置 (針對 Nuber.esggo.co)
npm run build

# 預覽
npm run preview
```

## 🚀 部署至 Nuber.esggo.co

### 方法 1: Vercel
```bash
# 安裝 Vercel CLI
npm install -g vercel

# 部署
vercel
# 或 vercel --prod
```

### 方法 2: Netlify
```bash
# 安裝 Netlify CLI
npm install -g netlify-cli

# 部署
npx netlify deploy --prod
```

### 方法 3: 手動部署
```bash
# 執行部署腳本
chmod +x deploy.sh
./deploy.sh
```

### 方法 4: VPS + Nginx (推薦 esggo.co 主機)
```bash
# 1. 建置
npm run build

# 2. 同步至目標目錄
rsync -avz dist/ user@esggo.co:/var/www/Nuber.esggo.co/

# 3. 檢查 Nginx 配置
sudo cp nginx.conf /etc/nginx/sites-available/Nuber.esggo.co
sudo ln -sf /etc/nginx/sites-available/Nuber.esggo.co /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 4. 設定 Cloudflare 子域名 CNAME
# Nuber.esggo.co → CNAME → esggo.co
```

## 📊 Supabase 資料表

執行 `supabase_schema_nuber.sql` 於 Supabase Dashboard：

### 主要表格
- `inquiries` - 諮詢表單 (酪農洽談 / 碳權諮詢)
- `products` - 產品與服務
- `carbon_credits` - 碳權交易系統
- `farms` - 合作農場資訊
- `orders` - 訂單與交易
- `users` - 使用者與權限管理
- `analytics` - 用戶行為分析

## 🔐 5T 驗證

```bash
# 執行驗證
python verify_5t.py
```

驗證項目：
- ✅ Traceable: File hash 校驗
- ✅ Tangible: 無 emoji
- ✅ 5T Protocol 合規
- ✅ Logo 色彩整合

## 🌐 DNS 設定

將以下 CNAME 記錄加入 `Nuber.esggo.co` 的 DNS：

```
Name: Nuber.esggo.co
Type: CNAME
Value: esggo.co
TTL: 300
```

## 📈 平台功能

### 前台體驗
- Hero 首屏：亞洲首個畜牧碳資產市場
- 數據卡片：產業痛點與解決方案
- 技術優勢：海門冬與減碳技術
- 商業模式：PUSH × PULL 閉環
- 合作夥伴：國際認證背書
- 聯絡窗：分類式諮詢表單

### 後台管理
- 諮詢 inquiries 管理
- 產品 products 矩陯
- 碳權 transactions
- 農場 partnerships
- 數據分析 dashboards

---

**部署狀態**：✅ 建置成功 ✅ 部署腳本完成 ✅ DNS 設定指引

**查看進度**：`Nuber.esggo.co` (部署後即可存取)