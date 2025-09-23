#!/bin/bash

# Script để chuyển đổi giữa MySQL 5.7 và MySQL 8
# Usage: ./mysql-switch.sh [mysql57|mysql8]

MYSQL_VERSION=${1:-mysql57}

echo "🗄️  Đang chuyển đổi MySQL sang $MYSQL_VERSION..."

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

# Dừng tất cả MySQL containers
echo "⏹️  Dừng tất cả MySQL containers..."
docker-compose stop mysql57 mysql8 database 2>/dev/null || true

# Khởi động MySQL version được chọn
echo "🚀 Khởi động MySQL $MYSQL_VERSION..."
docker-compose up -d $MYSQL_VERSION

# Khởi động PhpMyAdmin với MySQL version tương ứng
echo "🔧 Cập nhật PhpMyAdmin cho $MYSQL_VERSION..."

# Tạo cấu hình PhpMyAdmin tạm thời
PMA_CONFIG="/tmp/phpmyadmin-config.php"

cat > $PMA_CONFIG << EOF
<?php
// PhpMyAdmin configuration for $MYSQL_VERSION
\$cfg['Servers'][1]['host'] = '$MYSQL_VERSION';
\$cfg['Servers'][1]['port'] = '3306';
\$cfg['Servers'][1]['user'] = 'root';
\$cfg['Servers'][1]['password'] = 'secret';
\$cfg['Servers'][1]['auth_type'] = 'config';

// Additional servers for easy switching
\$cfg['Servers'][2]['host'] = 'mysql57';
\$cfg['Servers'][2]['port'] = '3306';
\$cfg['Servers'][2]['user'] = 'root';
\$cfg['Servers'][2]['password'] = 'secret';
\$cfg['Servers'][2]['auth_type'] = 'config';

\$cfg['Servers'][3]['host'] = 'mysql8';
\$cfg['Servers'][3]['port'] = '3306';
\$cfg['Servers'][3]['user'] = 'root';
\$cfg['Servers'][3]['password'] = 'secret';
\$cfg['Servers'][3]['auth_type'] = 'config';

// General settings
\$cfg['DefaultLang'] = 'vi';
\$cfg['ServerDefault'] = 1;
\$cfg['UploadDir'] = '';
\$cfg['SaveDir'] = '';
\$cfg['TempDir'] = '/tmp';
\$cfg['MaxRows'] = 50;
\$cfg['MaxCharactersInDisplayedSQL'] = 1000;
\$cfg['ExecTimeLimit'] = 300;
\$cfg['MemoryLimit'] = '512M';
\$cfg['CheckConfigurationPermissions'] = false;
\$cfg['DisableShortcutKeys'] = false;
\$cfg['SendErrorReports'] = 'never';
\$cfg['DefaultCharset'] = 'utf8mb4';
\$cfg['DefaultConnectionCollation'] = 'utf8mb4_unicode_ci';
?>
EOF

# Khởi động PhpMyAdmin
echo "🌐 Khởi động PhpMyAdmin..."
docker-compose up -d phpmyadmin

# Copy cấu hình vào PhpMyAdmin container
PMA_CONTAINER=$(docker-compose ps -q phpmyadmin)
if [ -n "$PMA_CONTAINER" ]; then
    docker cp $PMA_CONFIG $PMA_CONTAINER:/etc/phpmyadmin/config.inc.php
    echo "✅ Cấu hình PhpMyAdmin đã được cập nhật"
else
    echo "⚠️  Không tìm thấy PhpMyAdmin container"
fi

# Cleanup
rm -f $PMA_CONFIG

# Kiểm tra trạng thái
echo "⏳ Đang kiểm tra trạng thái..."
sleep 5

# Test kết nối MySQL
echo "🧪 Testing MySQL connection..."
if docker-compose exec -T $MYSQL_VERSION mysql -u root -psecret -e "SELECT VERSION();" 2>/dev/null; then
    echo "✅ MySQL $MYSQL_VERSION hoạt động bình thường"
else
    echo "❌ MySQL $MYSQL_VERSION có vấn đề kết nối"
fi

# Hiển thị trạng thái
echo ""
echo "📊 Trạng thái containers:"
docker-compose ps | grep -E "(mysql|phpmyadmin)"

echo ""
echo "✅ MySQL đã được chuyển đổi sang $MYSQL_VERSION"
echo "🗄️  PhpMyAdmin: http://localhost:8888"
echo "🔗 MySQL Host: $MYSQL_VERSION"
echo "🔌 MySQL Port: 3306 (trong container)"

# Hiển thị thông tin kết nối
case $MYSQL_VERSION in
    mysql57)
        echo "🌐 External Port: 3307"
        ;;
    mysql8)
        echo "🌐 External Port: 3308"
        ;;
esac

echo ""
echo "💡 Lệnh hữu ích:"
echo "   - Vào MySQL CLI: docker-compose exec $MYSQL_VERSION mysql -u root -p"
echo "   - Xem logs: docker-compose logs -f $MYSQL_VERSION"
echo "   - Backup database: docker-compose exec $MYSQL_VERSION mysqldump -u root -p database_name > backup.sql"
