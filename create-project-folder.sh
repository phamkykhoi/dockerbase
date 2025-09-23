#!/bin/bash

# Script để tạo thư mục project trong APP_CODE_PATH_HOST
# Usage: ./create-project-folder.sh <project_name>

if [ $# -ne 1 ]; then
    echo "❌ Sử dụng: ./create-project-folder.sh <project_name>"
    echo "📝 Ví dụ: ./create-project-folder.sh EnglishTemplate"
    exit 1
fi

PROJECT_NAME=$1

# Đọc APP_CODE_PATH_HOST từ .env file
if [ -f ".env" ]; then
    APP_CODE_PATH_HOST=$(grep "^APP_CODE_PATH_HOST=" .env | cut -d'=' -f2 | tr -d "'\"")
else
    echo "❌ Không tìm thấy file .env"
    exit 1
fi

if [ -z "$APP_CODE_PATH_HOST" ]; then
    echo "❌ Không tìm thấy APP_CODE_PATH_HOST trong file .env"
    exit 1
fi

PROJECT_PATH="$APP_CODE_PATH_HOST/$PROJECT_NAME"

echo "🚀 Tạo thư mục project: $PROJECT_NAME"
echo "📁 Đường dẫn: $PROJECT_PATH"
echo ""

# Kiểm tra thư mục đã tồn tại chưa
if [ -d "$PROJECT_PATH" ]; then
    echo "⚠️  Thư mục project đã tồn tại: $PROJECT_PATH"
    read -p "Bạn có muốn tiếp tục không? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Hủy tạo thư mục project."
        exit 1
    fi
fi

# Tạo thư mục project
echo "📁 Tạo thư mục project..."
mkdir -p "$PROJECT_PATH"
echo "✅ Đã tạo thư mục: $PROJECT_PATH"

# Tạo file index.php mẫu
echo "📄 Tạo file index.php mẫu..."
cat > "$PROJECT_PATH/index.php" << EOF
<?php
echo "<h1>Welcome to $PROJECT_NAME</h1>";
echo "<p>Project: $PROJECT_NAME</p>";
echo "<p>PHP Version: " . PHP_VERSION . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Project Path: $PROJECT_PATH</p>";
echo "<hr>";
echo "<h2>PHP Info</h2>";
echo "<a href='/phpinfo.php'>View PHP Info</a>";
?>
EOF
echo "✅ Đã tạo file index.php"

# Tạo file .gitignore mẫu
echo "📄 Tạo file .gitignore mẫu..."
cat > "$PROJECT_PATH/.gitignore" << EOF
# Dependencies
/vendor/
/node_modules/

# Environment
.env
.env.local
.env.production

# Logs
*.log
storage/logs/*

# Cache
storage/framework/cache/*
storage/framework/sessions/*
storage/framework/views/*

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
echo "✅ Đã tạo file .gitignore"

echo ""
echo "✅ Hoàn tất tạo thư mục project!"
echo ""
echo "📋 Thông tin project:"
echo "   - Tên project: $PROJECT_NAME"
echo "   - Đường dẫn: $PROJECT_PATH"
echo "   - Trong container: /var/www/$PROJECT_NAME"
echo ""
echo "🔧 Bước tiếp theo:"
echo "   ./setup-project.sh $PROJECT_NAME your-domain.dev.com php82"
