#!/bin/bash

# Script để test kết nối Redis
echo "🔴 Testing Redis connection..."

# Kiểm tra Redis container có đang chạy không
if ! docker-compose ps redis | grep -q "Up"; then
    echo "❌ Redis container không đang chạy. Khởi động Redis..."
    docker-compose up -d redis
    sleep 2
fi

# Test kết nối Redis
echo "📡 Testing Redis connection..."
REDIS_RESPONSE=$(docker-compose exec -T redis redis-cli ping 2>/dev/null)

if [ "$REDIS_RESPONSE" = "PONG" ]; then
    echo "✅ Redis hoạt động bình thường!"
    
    # Test thêm một số lệnh cơ bản
    echo "🧪 Testing Redis operations..."
    
    # Set và get một key
    docker-compose exec -T redis redis-cli set test_key "Hello Redis" > /dev/null
    VALUE=$(docker-compose exec -T redis redis-cli get test_key 2>/dev/null)
    
    if [ "$VALUE" = "Hello Redis" ]; then
        echo "✅ Redis read/write operations hoạt động!"
    else
        echo "❌ Redis read/write operations có vấn đề"
    fi
    
    # Cleanup
    docker-compose exec -T redis redis-cli del test_key > /dev/null
    
    # Hiển thị thông tin Redis
    echo ""
    echo "📊 Redis Information:"
    echo "   - Host: localhost"
    echo "   - Port: 6378"
    echo "   - Container: redis"
    echo "   - Data volume: ./docker/volumes/redis"
    
    # Hiển thị một số stats
    echo ""
    echo "📈 Redis Stats:"
    docker-compose exec -T redis redis-cli info memory | grep used_memory_human
    docker-compose exec -T redis redis-cli info keyspace
    
else
    echo "❌ Redis không phản hồi. Kiểm tra logs:"
    docker-compose logs redis
fi
