# High Tech Seaweed 官方網站
> 2022年成立的生態科技公司，專注於海藻養殖及負碳技術

## 靈魂核心聖典 (Soul Canon)

### 5T Protocol 實踐：
- **Traceable**: 所有檔案具備雜湊校驗
- **Trackable**: 生命週期可追蹤
- **Tangible**: 專業設計體驗
- **Transparent**: 開源驗證腳本
- **Trustworthy**: 凍結配置物件

### Logo 色彩標準：
- **深海生技藍**: `#3B72B9`
- **萌芽嫩綠**: `#8CC63F`  
- **深炭灰**: `#2B2B2B`
- **純白**: `#FFFFFF`

## 專案結構

├── index.html          # 前台主頁
├── style.css           # 專業設計系統
├── script.js           # 5T Protocol JS
├── package.json        # Vite 建置配置
├── supabase_schema.sql # 資料表結構
├── verify_5t.py        # 驗證腳本
├── admin/              # 後台管理
│   ├── login.html
│   └── dashboard.html
└── dist/               # 建置產出 (Vercel Netliff 部署)

## 快速開發

```bash
# 安裝相依套件
npm install

# 開發模式
npm run dev

# 建置
npm run build

# 預覽
npm run preview
```

## Supabase 部署

1. 登入 Supabase Dashboard
2. 執行 `supabase_schema.sql` 建立資料表
3. 更新 `script.js` 中的金鑰

## 5T 驗證

```bash
python verify_5t.py
```

## 佈署

- **Vercel**: npx vercel
- **Netlify**: npx netlify deploy --prod
- **手動**: 上傳 dist/ 目錄至主機

---

> **狀態**: 5T Protocol 合規 ✅ Logo 色彩整合 ✅ 前端完成 ✅