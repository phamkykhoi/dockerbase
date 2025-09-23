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

echo "🚀 Đang setup project: $ROOT_FOLDER"
echo "🌐 Domain: $SERVER_NAME"
echo "🐘 PHP Version: $PHP_VERSION"
echo ""

# 1. Tạo thư mục project
echo "📁 Tạo thư mục project..."
mkdir -p "$ROOT_FOLDER"
echo "✅ Đã tạo thư mục: $ROOT_FOLDER"

# 2. Tạo file index.php mẫu
echo "📄 Tạo file index.php mẫu..."
cat > "$ROOT_FOLDER/index.php" << EOF
<?php
echo "<h1>Welcome to $SERVER_NAME</h1>";
echo "<p>Project: $ROOT_FOLDER</p>";
echo "<p>PHP Version: " . PHP_VERSION . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<hr>";
echo "<h2>PHP Info</h2>";
echo "<a href='/phpinfo.php'>View PHP Info</a>";
?>
EOF
echo "✅ Đã tạo file index.php"

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
echo "   - Thư mục: $ROOT_FOLDER"
echo "   - Domain: $SERVER_NAME"
echo "   - PHP Version: $PHP_VERSION"
echo "   - URL: http://$SERVER_NAME"
echo ""
echo "🔧 Các bước tiếp theo:"
echo "   1. Thêm vào /etc/hosts: 127.0.0.1 $SERVER_NAME"
echo "   2. Truy cập: http://$SERVER_NAME"
echo "   3. Bắt đầu phát triển trong thư mục: $ROOT_FOLDER"
echo ""
echo "💡 Lệnh hữu ích:"
echo "   - Vào container PHP: docker-compose exec $PHP_VERSION bash"
echo "   - Xem logs nginx: docker-compose logs -f nginx"
echo "   - Reload nginx: ./nginx-manager.sh reload"
