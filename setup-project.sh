#!/bin/bash

# Script để setup project hoàn chỉnh
# Usage: ./setup-project.sh <root_folder> <server_name> <php_version>

if [ $# -ne 3 ]; then
    echo "❌ Sử dụng: ./setup-project.sh <root_folder> <server_name> <php_version>"
    echo "📝 Ví dụ: ./setup-project.sh myproject myproject.dev.com php82"
    echo ""
    echo "📋 Các phiên bản PHP có sẵn:"
    echo "   - php73, php74, php81, php82, php83, php84"
    exit 1
fi

ROOT_FOLDER=$1
SERVER_NAME=$2
PHP_VERSION=$3

# Tách project name và subfolder nếu có
if [[ "$ROOT_FOLDER" == *"/"* ]]; then
    PROJECT_NAME=$(echo "$ROOT_FOLDER" | cut -d'/' -f1)
    SUBFOLDER=$(echo "$ROOT_FOLDER" | cut -d'/' -f2-)
    echo "🚀 Đang setup project: $PROJECT_NAME"
    echo "📁 Subfolder: $SUBFOLDER"
else
    PROJECT_NAME="$ROOT_FOLDER"
    SUBFOLDER=""
    echo "🚀 Đang setup project: $PROJECT_NAME"
fi

echo "🌐 Domain: $SERVER_NAME"
echo "🐘 PHP Version: $PHP_VERSION"
echo ""

# 1. Bỏ qua việc kiểm tra thư mục - chỉ tạo cấu hình
echo "📁 Bỏ qua việc kiểm tra thư mục - chỉ tạo cấu hình Nginx"

# 3. Tạo file cấu hình Nginx
echo "⚙️  Tạo file cấu hình Nginx..."
./create-nginx-config.sh "$ROOT_FOLDER" "$SERVER_NAME" "$PHP_VERSION"

# 4. Rebuild nginx container
echo "🔨 Rebuild Nginx container..."
docker-compose build nginx

# 5. Restart nginx
echo "🔄 Restart Nginx..."
docker-compose up -d nginx

# 6. Kiểm tra trạng thái
echo "⏳ Kiểm tra trạng thái..."
sleep 3

echo ""
echo "✅ Project setup hoàn tất!"
echo ""
echo "📋 Thông tin project:"
echo "   - Project: $PROJECT_NAME"
if [ -n "$SUBFOLDER" ]; then
    echo "   - Subfolder: $SUBFOLDER"
fi
echo "   - Domain: $SERVER_NAME"
echo "   - PHP Version: $PHP_VERSION"
echo "   - URL: http://$SERVER_NAME"
echo ""
echo "🔧 Các bước tiếp theo:"
echo "   1. Thêm vào /etc/hosts: 127.0.0.1 $SERVER_NAME"
echo "   2. Truy cập: http://$SERVER_NAME"
echo "   3. Đảm bảo thư mục tồn tại: \${APP_CODE_PATH_HOST}/$ROOT_FOLDER"
echo ""
echo "💡 Lệnh hữu ích:"
echo "   - Vào container PHP: docker-compose exec $PHP_VERSION bash"
echo "   - Xem logs nginx: docker-compose logs -f nginx"
echo "   - Reload nginx: ./nginx-manager.sh reload"
