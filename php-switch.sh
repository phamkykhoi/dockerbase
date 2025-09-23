#!/bin/bash

# Script để chuyển đổi giữa các phiên bản PHP và MySQL
# Usage: ./php-switch.sh [php73|php74|php81|php82|php83|php84] [mysql57|mysql8] [--minimal]

PHP_VERSION=${1:-php82}
MYSQL_VERSION=${2:-mysql57}
MINIMAL_MODE=${3:-false}

echo "🚀 Đang khởi động môi trường PHP $PHP_VERSION..."

# Dừng tất cả containers
docker-compose down

# Kiểm tra phiên bản MySQL hợp lệ
case $MYSQL_VERSION in
    mysql57|mysql8)
        echo "✅ Phiên bản MySQL hợp lệ: $MYSQL_VERSION"
        ;;
    *)
        echo "❌ Phiên bản MySQL không hợp lệ: $MYSQL_VERSION"
        echo "Các phiên bản có sẵn: mysql57, mysql8"
        exit 1
        ;;
esac

# Xác định services cần khởi động
if [ "$MINIMAL_MODE" = "--minimal" ]; then
    SERVICES="nginx $PHP_VERSION redis"
    echo "📦 Chế độ tối giản: chỉ khởi động nginx, $PHP_VERSION và redis"
else
    SERVICES="nginx $PHP_VERSION $MYSQL_VERSION redis minio phpmyadmin"
    echo "📦 Khởi động đầy đủ: nginx, $PHP_VERSION, $MYSQL_VERSION, redis, minio, phpmyadmin"
fi

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

# Cập nhật cấu hình Nginx cho phiên bản PHP được chọn
echo "🔧 Đang cập nhật cấu hình Nginx cho $PHP_VERSION..."
updateNginxConfig() {
    local php_service=$1
    local nginx_config="/tmp/nginx-php-switch.conf"
    
    # Tạo cấu hình Nginx tạm thời
    cat > $nginx_config << EOF
server {
    listen 80;
    server_name localhost;
    root /var/www/;
    index index.php index.html index.htm;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php\$ {
        try_files \$uri /index.php =404;
        fastcgi_pass $php_service:9000;
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

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    client_max_body_size 100M;
    client_body_timeout 60s;
    client_header_timeout 60s;

    location /phpinfo {
        fastcgi_pass $php_service:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/phpinfo.php;
        include fastcgi_params;
    }
}
EOF

    # Copy cấu hình vào container nginx
    docker cp $nginx_config docker-base-nginx-1:/etc/nginx/conf.d/default.conf 2>/dev/null || \
    docker cp $nginx_config $(docker-compose ps -q nginx):/etc/nginx/conf.d/default.conf 2>/dev/null || \
    echo "⚠️  Không thể cập nhật cấu hình Nginx tự động. Vui lòng restart nginx container."
    
    # Reload nginx configuration
    docker-compose exec nginx nginx -s reload 2>/dev/null || \
    echo "⚠️  Không thể reload Nginx. Vui lòng restart nginx container."
    
    # Cleanup
    rm -f $nginx_config
}

# Khởi động services
echo "🔄 Đang khởi động services..."
docker-compose up -d $SERVICES

# Cập nhật cấu hình Nginx
updateNginxConfig $PHP_VERSION

# Kiểm tra trạng thái
echo "⏳ Đang kiểm tra trạng thái services..."
sleep 3

# Hiển thị trạng thái
echo ""
echo "📊 Trạng thái containers:"
docker-compose ps

echo ""
echo "✅ Môi trường PHP $PHP_VERSION + MySQL $MYSQL_VERSION đã sẵn sàng!"
echo "🌐 Website: http://localhost"
echo "🔴 Redis: localhost:6378 (dùng chung cho tất cả PHP versions)"

if [ "$MINIMAL_MODE" != "--minimal" ]; then
    echo "🗄️  PhpMyAdmin: http://localhost:8888"
    echo "📁 MinIO Console: http://localhost:9001"
    
    case $MYSQL_VERSION in
        mysql57)
            echo "🗃️  MySQL 5.7: localhost:3307"
            ;;
        mysql8)
            echo "🗃️  MySQL 8.0: localhost:3308"
            ;;
    esac
fi

echo ""
echo "💡 Lệnh hữu ích:"
echo "   - Vào container PHP: docker-compose exec $PHP_VERSION bash"
echo "   - Xem logs: docker-compose logs -f $PHP_VERSION"
echo "   - Test Redis: docker-compose exec redis redis-cli ping"
