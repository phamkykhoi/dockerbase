#!/bin/bash

# Script quản lý cấu hình Nginx
# Usage: ./nginx-manager.sh [list|create|delete|reload]

NGINX_SITES_DIR="docker/services/nginx/sites"

show_help() {
    echo "🔧 Nginx Configuration Manager"
    echo ""
    echo "Usage: ./nginx-manager.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  list                    - Hiển thị danh sách các file cấu hình"
    echo "  create <folder> <domain> <php> - Tạo file cấu hình mới"
    echo "  delete <domain>         - Xóa file cấu hình"
    echo "  reload                  - Reload nginx configuration"
    echo "  rebuild                 - Rebuild và restart nginx container"
    echo ""
    echo "Examples:"
    echo "  ./nginx-manager.sh list"
    echo "  ./nginx-manager.sh create myapp myapp.dev.com php82"
    echo "  ./nginx-manager.sh delete myapp.dev.com"
    echo "  ./nginx-manager.sh reload"
    echo ""
    echo "Available PHP versions: php73, php74, php81, php82, php83, php84"
}

list_configs() {
    echo "📋 Danh sách file cấu hình Nginx:"
    echo ""
    
    if [ ! -d "$NGINX_SITES_DIR" ]; then
        echo "❌ Thư mục $NGINX_SITES_DIR không tồn tại"
        return 1
    fi
    
    local count=0
    for config_file in "$NGINX_SITES_DIR"/*.conf; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file")
            local server_name=$(grep "server_name" "$config_file" | head -1 | awk '{print $2}' | sed 's/;//')
            local root_path=$(grep "root /var/www/" "$config_file" | head -1 | awk '{print $2}' | sed 's/;//')
            local php_version=$(grep "fastcgi_pass" "$config_file" | head -1 | awk '{print $2}' | sed 's/:9000;//')
            
            echo "  📄 $filename"
            echo "     🌐 Domain: $server_name"
            echo "     📁 Root: $root_path"
            echo "     🐘 PHP: $php_version"
            echo ""
            ((count++))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo "  📭 Không có file cấu hình nào"
    else
        echo "  📊 Tổng cộng: $count file cấu hình"
    fi
}

create_config() {
    if [ $# -ne 3 ]; then
        echo "❌ Sử dụng: ./nginx-manager.sh create <folder> <domain> <php_version>"
        echo "📝 Ví dụ: ./nginx-manager.sh create myapp myapp.dev.com php82"
        return 1
    fi
    
    local folder=$1
    local domain=$2
    local php_version=$3
    
    # Gọi script create-nginx-config.sh
    ./create-nginx-config.sh "$folder" "$domain" "$php_version"
}

delete_config() {
    if [ $# -ne 1 ]; then
        echo "❌ Sử dụng: ./nginx-manager.sh delete <domain>"
        echo "📝 Ví dụ: ./nginx-manager.sh delete myapp.dev.com"
        return 1
    fi
    
    local domain=$1
    local config_file="$NGINX_SITES_DIR/${domain}.conf"
    
    if [ ! -f "$config_file" ]; then
        echo "❌ File cấu hình không tồn tại: $config_file"
        return 1
    fi
    
    echo "⚠️  Bạn có chắc muốn xóa file cấu hình: $config_file"
    read -p "Nhập 'yes' để xác nhận: " -r
    if [[ $REPLY == "yes" ]]; then
        rm "$config_file"
        echo "✅ Đã xóa file cấu hình: $config_file"
    else
        echo "❌ Hủy xóa file cấu hình"
    fi
}

reload_nginx() {
    echo "🔄 Đang reload cấu hình Nginx..."
    
    # Kiểm tra cú pháp cấu hình
    echo "🔍 Kiểm tra cú pháp cấu hình..."
    docker-compose exec nginx nginx -t
    
    if [ $? -eq 0 ]; then
        echo "✅ Cú pháp cấu hình hợp lệ"
        echo "🔄 Reloading Nginx..."
        docker-compose exec nginx nginx -s reload
        echo "✅ Nginx đã được reload thành công"
    else
        echo "❌ Cú pháp cấu hình không hợp lệ. Vui lòng kiểm tra lại."
        return 1
    fi
}

rebuild_nginx() {
    echo "🔨 Đang rebuild Nginx container..."
    docker-compose build nginx
    echo "🔄 Đang restart Nginx container..."
    docker-compose up -d nginx
    echo "✅ Nginx đã được rebuild và restart thành công"
}

# Main script logic
case "${1:-help}" in
    "list")
        list_configs
        ;;
    "create")
        shift
        create_config "$@"
        ;;
    "delete")
        shift
        delete_config "$@"
        ;;
    "reload")
        reload_nginx
        ;;
    "rebuild")
        rebuild_nginx
        ;;
    "help"|*)
        show_help
        ;;
esac
