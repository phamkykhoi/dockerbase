# Docker PHP Development Environment

Môi trường phát triển Docker hỗ trợ nhiều phiên bản PHP cho các dự án khác nhau.

## 🚀 Các phiên bản PHP được hỗ trợ

- **PHP 7.3** - `php73`
- **PHP 7.4** - `php74` 
- **PHP 8.1** - `php81`
- **PHP 8.2** - `php82`
- **PHP 8.3** - `php83`
- **PHP 8.4** - `php84`

## 📦 Các services có sẵn

- **Nginx** - Web server (port 80)
- **MySQL 5.7** - Database (port 3307)
- **MySQL 8.0** - Database (port 3308)
- **PostgreSQL** - Database PostgreSQL
- **Redis** - Cache (port 6378)
- **MinIO** - Object storage (port 9000, console 9001)
- **PhpMyAdmin** - Database management (port 8888)
- **Adminer** - Database management (port 8081)

## 🛠️ Cách sử dụng

### 1. Cấu hình môi trường

```bash
# Copy file cấu hình mẫu
cp .env.example .env

# Chỉnh sửa các biến môi trường theo nhu cầu
nano .env
```

### 2. Chạy với phiên bản PHP và MySQL cụ thể

```bash
# Sử dụng script tự động (khuyến nghị)
./php-switch.sh php82 mysql57    # PHP 8.2 + MySQL 5.7
./php-switch.sh php74 mysql8     # PHP 7.4 + MySQL 8.0

# Chỉ chuyển đổi MySQL
./mysql-switch.sh mysql8

# Chỉ chuyển đổi Nginx (khi PHP container đã chạy)
./nginx-switch.sh php82

# Hoặc chạy thủ công
docker-compose up -d nginx php82 mysql57 redis minio phpmyadmin
```

### 3. Chạy tất cả services

```bash
# Khởi động tất cả services
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng tất cả
docker-compose down
```

## 🔧 Các lệnh hữu ích

```bash
# Xem containers đang chạy
docker-compose ps

# Vào container PHP
docker-compose exec php82 bash

# Vào container database
docker-compose exec database mysql -u root -p

# Test Redis connection
./test-redis.sh

# Vào Redis CLI
docker-compose exec redis redis-cli

# Chuyển đổi MySQL version
./mysql-switch.sh mysql8

# Chuyển đổi Nginx sang PHP version khác
./nginx-switch.sh php74

# Test PHP version hiện tại
curl http://localhost/phpinfo

# Dọn dẹp Docker cache
./docker-cleanup.sh

# Dọn dẹp Docker cache + volumes (cẩn thận!)
./docker-cleanup.sh --force

# Rebuild containers
docker-compose build --no-cache

# Xem logs của service cụ thể
docker-compose logs -f php82
docker-compose logs -f nginx
```

## 🔴 Redis - Cache dùng chung

Redis được cấu hình để **dùng chung cho tất cả các phiên bản PHP**:

- **Port**: 6378 (mapped từ 6379)
- **Host**: localhost hoặc redis (trong container)
- **Data**: Persistent trong `./docker/volumes/redis/`
- **Access**: Tất cả PHP containers đều có thể kết nối

### Kết nối Redis từ PHP:

```php
// Laravel
'redis' => [
    'client' => 'predis',
    'default' => [
        'host' => 'redis',
        'password' => null,
        'port' => 6379,
        'database' => 0,
    ],
],

// Native PHP
$redis = new Redis();
$redis->connect('redis', 6379);
```

### Test Redis:

```bash
# Test kết nối
./test-redis.sh

# Vào Redis CLI
docker-compose exec redis redis-cli

# Xem Redis info
docker-compose exec redis redis-cli info
```

## 🗄️ MySQL - Database Management

Hệ thống hỗ trợ **2 phiên bản MySQL chính**:

- **MySQL 5.7** - Port 3307 (tương thích với các ứng dụng cũ)
- **MySQL 8.0** - Port 3308 (phiên bản mới nhất với nhiều tính năng)

### Chuyển đổi MySQL:

```bash
# Chuyển sang MySQL 5.7
./mysql-switch.sh mysql57

# Chuyển sang MySQL 8.0
./mysql-switch.sh mysql8

# Kết hợp PHP + MySQL
./php-switch.sh php82 mysql8
```

### Kết nối từ PHP:

```php
// MySQL 5.7
$pdo = new PDO('mysql:host=mysql57;port=3306;dbname=myapp', 'root', 'secret');

// MySQL 8.0
$pdo = new PDO('mysql:host=mysql8;port=3306;dbname=myapp', 'root', 'secret');

// Laravel (.env)
DB_CONNECTION=mysql
DB_HOST=mysql57  # hoặc mysql8
DB_PORT=3306
DB_DATABASE=myapp
DB_USERNAME=root
DB_PASSWORD=secret
```

### PhpMyAdmin:

- **URL**: http://localhost:8888
- **Auto-switching**: Tự động kết nối với MySQL version được chọn
- **Multiple servers**: Có thể chuyển đổi giữa MySQL 5.7 và 8.0 trong giao diện

## 🌐 Nginx - Web Server

Nginx được cấu hình để **tự động chuyển đổi giữa các phiên bản PHP**:

- **Port**: 80
- **Auto-switching**: Tự động chuyển đổi fastcgi_pass theo PHP version
- **Security**: Có security headers và gzip compression
- **Static files**: Cache tối ưu cho CSS, JS, images
- **PHP Info**: Endpoint `/phpinfo` để test PHP version

### Cấu hình Nginx:

```nginx
# Tự động chuyển đổi theo PHP version
location ~ \.php$ {
    fastcgi_pass php82:9000;  # Sẽ được thay đổi bởi script
    # ... other fastcgi settings
}
```

### Chuyển đổi Nginx:

```bash
# Chuyển đổi sang PHP 7.4
./nginx-switch.sh php74

# Chuyển đổi sang PHP 8.3
./nginx-switch.sh php83

# Test cấu hình hiện tại
curl http://localhost/phpinfo
```

### Nginx Features:

- ✅ **Auto PHP switching** - Tự động chuyển đổi PHP version
- ✅ **Security headers** - X-Frame-Options, XSS-Protection, etc.
- ✅ **Gzip compression** - Tối ưu bandwidth
- ✅ **Static file caching** - Cache CSS, JS, images
- ✅ **File upload** - Hỗ trợ upload 100MB
- ✅ **Health check** - Tự động kiểm tra sức khỏe

## 📁 Cấu trúc thư mục

```
docker-base/
├── docker/
│   ├── services/
│   │   ├── php7.3/          # PHP 7.3 container
│   │   ├── php7.4/          # PHP 7.4 container
│   │   ├── php8.1/          # PHP 8.1 container
│   │   ├── php8.2/          # PHP 8.2 container
│   │   ├── php8.3/          # PHP 8.3 container
│   │   ├── php8.4/          # PHP 8.4 container
│   │   ├── nginx/           # Nginx configuration
│   │   └── phpmyadmin/      # PhpMyAdmin container
│   └── volumes/             # Persistent data
├── www/                     # Your PHP projects (mapped to /var/www)
├── docker-compose.yml       # Main configuration
├── php-switch.sh           # PHP version switcher script
└── .env                    # Environment variables
```

## 🎯 Truy cập các services

- **Website**: http://localhost
- **PhpMyAdmin**: http://localhost:8888
- **Adminer**: http://localhost:8081
- **MinIO Console**: http://localhost:9001
- **MinIO API**: http://localhost:9000

## 🔍 Troubleshooting

### Container không khởi động
```bash
# Kiểm tra logs
docker-compose logs [service_name]

# Rebuild container
docker-compose build --no-cache [service_name]
```

### Permission issues
```bash
# Fix permissions
sudo chown -R $USER:$USER www/
chmod -R 755 www/
```

### Port conflicts
```bash
# Kiểm tra port đang sử dụng
netstat -tulpn | grep :80
netstat -tulpn | grep :3307

# Thay đổi port trong docker-compose.yml nếu cần
```

## 📝 Ghi chú

- Tất cả PHP containers đều có cùng extensions và cấu hình
- Code được mount từ thư mục `www/` vào `/var/www` trong containers
- Database data được lưu trữ persistent trong `docker/volumes/`
- Sử dụng script `php-switch.sh` để dễ dàng chuyển đổi giữa các phiên bản PHP
