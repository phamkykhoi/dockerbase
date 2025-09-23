#!/bin/bash

# Script để chuyển đổi cấu hình Nginx cho các phiên bản PHP
# Usage: ./nginx-switch.sh [php73|php74|php81|php82|php83|php84]

PHP_VERSION=${1:-php82}

echo "🔧 Đang chuyển đổi Nginx sang $PHP_VERSION..."

# Kiểm tra phiên bản PHP hợp lệ
case $PHP_VERSION in
    php73|php74|php81|php82|php83|php84)
        echo "✅ Phiên bản PHP hợp lệ: $PHP_VERSION"
        ;;
    *)
        echo "❌ Phiên bản PHP không hợp lệ: $PHP_VERSION"
        echo "Các phiên bản có sẵn: php73, php74, php81, php82, php83, php84"
        exit 1
        ;;
esac

# Kiểm tra nginx container có đang chạy không
if ! docker-compose ps nginx | grep -q "Up"; then
    echo "❌ Nginx container không đang chạy. Khởi động nginx..."
    docker-compose up -d nginx
    sleep 3
fi

# Tạo cấu hình Nginx mới
NGINX_CONFIG="/tmp/nginx-${PHP_VERSION}.conf"

cat > $NGINX_CONFIG << EOF
server {
    listen 80;
    server_name localhost;
    root /var/www/;
    index index.php index.html index.htm;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Main location
    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    # PHP processing - Updated for $PHP_VERSION
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
        fastcgi_param HTTP_PROXY "";
        fastcgi_param HTTPS \$https if_not_empty;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Security - deny hidden files
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
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # File upload settings
    client_max_body_size 100M;
    client_body_timeout 60s;
    client_header_timeout 60s;

    # PHP info endpoint
    location /phpinfo {
        fastcgi_pass $PHP_VERSION:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/phpinfo.php;
        include fastcgi_params;
    }
}
EOF

# Copy cấu hình vào nginx container
echo "📝 Đang cập nhật cấu hình Nginx..."
NGINX_CONTAINER=$(docker-compose ps -q nginx)

if [ -n "$NGINX_CONTAINER" ]; then
    # Copy cấu hình mới
    docker cp $NGINX_CONFIG $NGINX_CONTAINER:/etc/nginx/conf.d/default.conf
    
    # Test cấu hình
    if docker exec $NGINX_CONTAINER nginx -t; then
        echo "✅ Cấu hình Nginx hợp lệ"
        
        # Reload nginx
        docker exec $NGINX_CONTAINER nginx -s reload
        echo "🔄 Nginx đã được reload"
        
        # Kiểm tra trạng thái
        sleep 2
        if curl -s -o /dev/null -w "%{http_code}" http://localhost/phpinfo | grep -q "200"; then
            echo "✅ Nginx đang hoạt động với $PHP_VERSION"
        else
            echo "⚠️  Nginx có thể chưa sẵn sàng, vui lòng kiểm tra logs"
        fi
    else
        echo "❌ Cấu hình Nginx không hợp lệ"
        exit 1
    fi
else
    echo "❌ Không tìm thấy nginx container"
    exit 1
fi

# Cleanup
rm -f $NGINX_CONFIG

echo ""
echo "✅ Nginx đã được chuyển đổi sang $PHP_VERSION"
echo "🌐 Test: http://localhost/phpinfo"
echo "📊 Xem logs: docker-compose logs -f nginx"
