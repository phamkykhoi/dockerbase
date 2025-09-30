#!/bin/bash

# Script để dọn dẹp Docker cache và containers
# Usage: ./docker-cleanup.sh [--force]

FORCE_MODE=${1:-""}

echo "🧹 Docker Cleanup Script"
echo "========================"

# Kiểm tra trạng thái hiện tại
echo "📊 Trạng thái Docker hiện tại:"
docker system df

echo ""
echo "🔄 Bắt đầu dọn dẹp..."

# Dừng tất cả containers đang chạy
echo "⏹️  Dừng tất cả containers..."
docker-compose down 2>/dev/null || true

# Xóa containers đã dừng
echo "🗑️  Xóa containers đã dừng..."
docker container prune -f

# Xóa images không sử dụng
echo "🖼️  Xóa images không sử dụng..."
docker image prune -f

# Xóa networks không sử dụng
echo "🌐 Xóa networks không sử dụng..."
docker network prune -f

# Xóa build cache
echo "🔨 Xóa build cache..."
docker builder prune -f

# Dọn dẹp toàn bộ hệ thống
echo "🧽 Dọn dẹp toàn bộ hệ thống..."
if [ "$FORCE_MODE" = "--force" ]; then
    docker system prune -a --volumes -f
else
    docker system prune -a -f
fi

echo ""
echo "✅ Hoàn thành dọn dẹp!"
echo ""
echo "📊 Trạng thái Docker sau khi dọn dẹp:"
docker system df

echo ""
echo "💡 Lệnh hữu ích:"
echo "   - Xem trạng thái: docker system df"
echo "   - Xem containers: docker ps -a"
echo "   - Xem images: docker images"
echo "   - Xem volumes: docker volume ls"
echo "   - Xem networks: docker network ls"
