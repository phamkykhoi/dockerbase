# 🔧 Nginx Configuration Management

Bộ công cụ quản lý cấu hình Nginx cho Docker environment với nhiều phiên bản PHP.

## 📋 Các Scripts Có Sẵn

### 1. `create-nginx-config.sh` - Tạo file cấu hình Nginx

Tạo file cấu hình Nginx cho project mới.

```bash
./create-nginx-config.sh <root_folder> <server_name> <php_version>
```

**Ví dụ:**
```bash
./create-nginx-config.sh myproject myproject.dev.com php82
```

**Tham số:**
- `root_folder`: Tên thư mục project (sẽ tạo trong `/var/www/`)
- `server_name`: Domain name cho project
- `php_version`: Phiên bản PHP (php73, php74, php81, php82, php83, php84)

### 2. `setup-project.sh` - Setup project hoàn chỉnh

Tạo project hoàn chỉnh bao gồm thư mục, file cấu hình Nginx và rebuild container.

```bash
./setup-project.sh <root_folder> <server_name> <php_version>
```

**Ví dụ:**
```bash
./setup-project.sh myapp myapp.dev.com php83
```

**Tính năng:**
- ✅ Tạo thư mục project
- ✅ Tạo file `index.php` mẫu
- ✅ Tạo file cấu hình Nginx
- ✅ Rebuild và restart Nginx container
- ✅ Hiển thị hướng dẫn tiếp theo

### 3. `nginx-manager.sh` - Quản lý cấu hình Nginx

Script quản lý tổng thể cho các file cấu hình Nginx.

```bash
./nginx-manager.sh [command] [options]
```

**Commands:**

#### `list` - Hiển thị danh sách cấu hình
```bash
./nginx-manager.sh list
```
Hiển thị tất cả file cấu hình với thông tin chi tiết.

#### `create` - Tạo cấu hình mới
```bash
./nginx-manager.sh create <folder> <domain> <php_version>
```
Tương tự như `create-nginx-config.sh`.

#### `delete` - Xóa cấu hình
```bash
./nginx-manager.sh delete <domain>
```
Xóa file cấu hình theo domain name.

#### `reload` - Reload Nginx
```bash
./nginx-manager.sh reload
```
Kiểm tra cú pháp và reload cấu hình Nginx.

#### `rebuild` - Rebuild Nginx container
```bash
./nginx-manager.sh rebuild
```
Rebuild và restart Nginx container.

## 🚀 Workflow Tạo Project Mới

### Cách 1: Setup hoàn chỉnh (Khuyến nghị)
```bash
# Tạo project hoàn chỉnh
./setup-project.sh myapp myapp.dev.com php82

# Thêm vào /etc/hosts
echo "127.0.0.1 myapp.dev.com" | sudo tee -a /etc/hosts

# Truy cập project
open http://myapp.dev.com
```

### Cách 2: Tạo từng bước
```bash
# 1. Tạo thư mục project
mkdir myapp

# 2. Tạo file cấu hình Nginx
./create-nginx-config.sh myapp myapp.dev.com php82

# 3. Rebuild Nginx
./nginx-manager.sh rebuild

# 4. Thêm vào /etc/hosts
echo "127.0.0.1 myapp.dev.com" | sudo tee -a /etc/hosts
```

## 📁 Cấu Trúc File Cấu Hình

Mỗi file cấu hình Nginx được tạo sẽ có cấu trúc:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/your-project;
    index index.php index.html index.htm;

    # Logging
    access_log /var/log/nginx/your-domain.com_access.log;
    error_log /var/log/nginx/your-domain.com_error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Main location block
    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    # PHP processing
    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_pass php82:9000;  # Tự động thay đổi theo PHP version
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_read_timeout 600;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        include fastcgi_params;
        fastcgi_param HTTP_PROXY "";
        fastcgi_param HTTPS $https if_not_empty;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
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
```

## 🔧 Tính Năng Cấu Hình

### ✅ Security Headers
- X-Frame-Options: SAMEORIGIN
- X-XSS-Protection: 1; mode=block
- X-Content-Type-Options: nosniff

### ✅ Performance
- Gzip compression
- Static file caching (1 year)
- FastCGI buffering
- Connection timeouts

### ✅ File Upload
- Max body size: 100M
- Client timeouts: 60s

### ✅ Logging
- Separate access/error logs per domain
- Log rotation ready

## 🐘 PHP Version Support

| PHP Version | Container Name | Port |
|-------------|----------------|------|
| PHP 7.3     | php73          | 9000 |
| PHP 7.4     | php74          | 9000 |
| PHP 8.1     | php81          | 9000 |
| PHP 8.2     | php82          | 9000 |
| PHP 8.3     | php83          | 9000 |
| PHP 8.4     | php84          | 9000 |

## 🚨 Troubleshooting

### Lỗi "502 Bad Gateway"
```bash
# Kiểm tra PHP container có chạy không
docker-compose ps php82

# Khởi động PHP container
docker-compose up -d php82

# Kiểm tra logs
docker-compose logs php82
```

### Lỗi "404 Not Found"
```bash
# Kiểm tra file cấu hình
./nginx-manager.sh list

# Reload nginx
./nginx-manager.sh reload

# Kiểm tra logs nginx
docker-compose logs nginx
```

### Lỗi "Permission Denied"
```bash
# Kiểm tra quyền thư mục
ls -la myproject/

# Sửa quyền nếu cần
chmod -R 755 myproject/
```

## 💡 Tips & Best Practices

1. **Luôn sử dụng `setup-project.sh`** để tạo project mới
2. **Thêm domain vào `/etc/hosts`** trước khi test
3. **Sử dụng `nginx-manager.sh list`** để kiểm tra cấu hình
4. **Reload nginx** sau khi sửa cấu hình: `./nginx-manager.sh reload`
5. **Kiểm tra logs** khi có lỗi: `docker-compose logs nginx`

## 🔗 Liên Kết Hữu Ích

- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
