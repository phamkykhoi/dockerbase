#!/bin/bash

# Script để dọn dẹp git và loại bỏ các file đã được track trong volumes và minio data

echo "🧹 Đang dọn dẹp git repository..."

# Loại bỏ các file trong docker/volumes khỏi git tracking
echo "📁 Loại bỏ docker/volumes khỏi git tracking..."
git rm -r --cached docker/volumes/* 2>/dev/null || echo "Không có file nào trong docker/volumes để loại bỏ"

# Loại bỏ các file trong docker/minio/data khỏi git tracking
echo "📁 Loại bỏ docker/minio/data khỏi git tracking..."
git rm -r --cached docker/minio/data/* 2>/dev/null || echo "Không có file nào trong docker/minio/data để loại bỏ"

# Thêm lại các file .gitkeep
echo "📄 Thêm lại các file .gitkeep..."
git add docker/volumes/.gitkeep
find docker/volumes -name ".gitkeep" -exec git add {} \; 2>/dev/null
git add docker/minio/data/.gitkeep

echo "✅ Hoàn tất dọn dẹp git repository!"
echo ""
echo "📋 Các thay đổi:"
echo "   - Đã loại bỏ tất cả file trong docker/volumes/* khỏi git tracking"
echo "   - Đã loại bỏ tất cả file trong docker/minio/data/* khỏi git tracking"
echo "   - Đã giữ lại các file .gitkeep để duy trì cấu trúc thư mục"
echo ""
echo "💡 Để commit các thay đổi:"
echo "   git commit -m 'Update .gitignore to exclude volumes and minio data'"
