#!/bin/bash
# ★ Nuber 平台自動化佈署腳本 ★
# 5T Protocol 完整自動化
# 目標：Nuber.esggo.co

set -e

echo "=================================================="
echo "★ Nuber 平台佈署啟動 ★"
echo "=================================================="

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/dist"

# 1. 預檢
echo ""
echo "--- 預檢步驟 ---"
echo "🔍 執行部署前檢查..."

for file in index.html style.css script.js package.json; do
    if [ ! -f "$PROJECT_ROOT/$file" ]; then
        echo "❌ 缺少必要檔案: $file"
        exit 1
    fi
done
echo "✅ 部署前檢查完成"

# 2. 建置
echo ""
echo "--- 建置步驟 ---"
echo "🔨 建置生產環境..."

cd "$PROJECT_ROOT"
npm install --silent 2>/dev/null || true
npm run build

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ 建置失敗 - dist 目錄不存在"
    exit 1
fi

echo "✅ 建置成功"
ls -la "$BUILD_DIR"

# 3. 設置資訊
echo ""
echo "=================================================="
echo "✅ 佈署準備完成"
echo "=================================================="
echo ""
echo "🎯 目標網址: https://Nuber.esggo.co"
echo ""
echo "📋 下一步操作指引："
echo ""
echo "1. DNS 設定 (Cloudflare Dashboard):"
echo "   類型: CNAME"
echo "   名稱: Nuber.esggo.co"
echo "   值: esggo.co"
echo "   TTL: 300"
echo ""
echo "2. SSL 證書 (Let's Encrypt):"
echo "   certbot --nginx -d Nuber.esggo.co -d www.Nuber.esggo.co"
echo ""
echo "3. Nginx 配置:"
echo "   sudo cp $PROJECT_ROOT/nginx.conf /etc/nginx/sites-available/Nuber.esggo.co"
echo "   sudo ln -sf /etc/nginx/sites-available/Nuber.esggo.co /etc/nginx/sites-enabled/"
echo "   sudo nginx -t && sudo systemctl reload nginx"
echo ""
echo "4. PM2 部署 (選擇性):"
echo "   pm2 start \$PROJECT_ROOT/dist/index.html --name nuber-web"
echo "   pm2 save"
echo ""
echo "5. 測試:"
echo "   curl -I https://Nuber.esggo.co"
echo ""
echo "=================================================="