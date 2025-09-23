#!/bin/bash

# Script để khởi động cả 2 MySQL containers cho PhpMyAdmin
echo "🚀 Đang khởi động cả 2 MySQL containers..."

# Khởi động MySQL 5.7
echo "📦 Khởi động MySQL 5.7..."
docker-compose up -d mysql57

# Khởi động MySQL 8.0
echo "📦 Khởi động MySQL 8.0..."
docker-compose up -d mysql8

# Khởi động PhpMyAdmin
echo "📦 Khởi động PhpMyAdmin..."
docker-compose up -d phpmyadmin

# Kiểm tra trạng thái
echo "⏳ Đang kiểm tra trạng thái..."
sleep 3

echo "📊 Trạng thái MySQL containers:"
docker-compose ps | grep mysql

echo ""
echo "✅ Cả 2 MySQL containers đã sẵn sàng!"
echo "🗄️  PhpMyAdmin: http://localhost:8888"
echo "🗃️  MySQL 5.7: localhost:3307"
echo "🗃️  MySQL 8.0: localhost:3308"
echo ""
echo "💡 Bây giờ bạn có thể chuyển đổi giữa MySQL 5.7 và 8.0 trong PhpMyAdmin!"
