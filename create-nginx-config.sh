#!/bin/bash

# Script để tạo file cấu hình Nginx
# Usage: ./create-nginx-config.sh <root_folder> <server_name> <php_version>
# Example: ./create-nginx-config.sh myproject myproject.dev.com php82

# Kiểm tra số lượng tham số
if [ $# -ne 3 ]; then
    echo "❌ Sử dụng: ./create-nginx-config.sh <root_folder> <server_name> <php_version>"
    echo "📝 Ví dụ: ./create-nginx-config.sh myproject myproject.dev.com php82"
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
    echo "📁 Project: $PROJECT_NAME"
    echo "📁 Subfolder: $SUBFOLDER"
else
    PROJECT_NAME="$ROOT_FOLDER"
    SUBFOLDER=""
    echo "📁 Project: $PROJECT_NAME"
fi

# Kiểm tra phiên bản PHP hợp lệ
case $PHP_VERSION in
    php73|php74|php81|php82|php83|php84)
        echo "✅ Phiên bản PHP hợp lệ: $PHP_VERSION"
        ;;
    *)
        echo "❌ Phiên bản PHP không hợp lệ: $PHP_VERSION"
        echo "📋 Các phiên bản có sẵn: php73, php74, php81, php82, php83, php84"
        exit 1
        ;;
esac

# Tạo tên file config
CONFIG_FILE="docker/services/nginx/sites/${SERVER_NAME}.conf"

# Kiểm tra file đã tồn tại chưa
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  File cấu hình đã tồn tại: $CONFIG_FILE"
    read -p "Bạn có muốn ghi đè không? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Hủy tạo file cấu hình."
        exit 1
    fi
fi

# Tạo nội dung file cấu hình
cat > "$CONFIG_FILE" << EOF
server {
    listen 80;
    server_name $SERVER_NAME;
    root /var/www/$ROOT_FOLDER;
    index index.php index.html index.htm;

    # Logging
    access_log /var/log/nginx/${SERVER_NAME}_access.log;
    error_log /var/log/nginx/${SERVER_NAME}_error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Main location block
    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    # PHP processing
    location ~ \.php\$ {
        try_files \$uri /index.php =404;
        fastcgi_pass $PHP_VERSION:9000;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_read_timeout 600;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        include fastcgi_params;
        
        # Additional FastCGI parameters
        fastcgi_param HTTP_PROXY "";
        fastcgi_param HTTPS \$https if_not_empty;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Deny access to hidden files
    location ~ /\.ht {
        deny all;
    }

    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # File upload size
    client_max_body_size 100M;
    client_body_timeout 60s;
    client_header_timeout 60s;
}
EOF

echo "✅ Đã tạo file cấu hình Nginx: $CONFIG_FILE"
echo ""
echo "📋 Thông tin cấu hình:"
echo "   - Root folder: /var/www/$ROOT_FOLDER"
echo "   - Server name: $SERVER_NAME"
echo "   - PHP version: $PHP_VERSION"
echo "   - FastCGI pass: $PHP_VERSION:9000"
echo ""
echo "🔧 Để áp dụng cấu hình:"
echo "   1. Đảm bảo thư mục project tồn tại trong APP_CODE_PATH_HOST"
echo "   2. Rebuild nginx: docker-compose build nginx"
echo "   3. Restart nginx: docker-compose up -d nginx"
echo ""
echo "🌐 Truy cập: http://$SERVER_NAME"
echo "💡 Thêm vào /etc/hosts: 127.0.0.1 $SERVER_NAME"
