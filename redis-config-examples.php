<?php
/**
 * Redis Configuration Examples
 * Các ví dụ cấu hình Redis cho các framework PHP khác nhau
 */

// ========================================
// 1. LARAVEL (.env)
// ========================================
/*
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=0
*/

// Laravel config/database.php
$laravelRedisConfig = [
    'redis' => [
        'client' => 'predis',
        'default' => [
            'host' => env('REDIS_HOST', 'redis'),
            'password' => env('REDIS_PASSWORD', null),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_DB', 0),
        ],
        'cache' => [
            'host' => env('REDIS_HOST', 'redis'),
            'password' => env('REDIS_PASSWORD', null),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_CACHE_DB', 1),
        ],
        'session' => [
            'host' => env('REDIS_HOST', 'redis'),
            'password' => env('REDIS_PASSWORD', null),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_SESSION_DB', 2),
        ],
    ],
];

// ========================================
// 2. SYMFONY
// ========================================
$symfonyRedisConfig = [
    'framework' => [
        'cache' => [
            'app' => 'cache.adapter.redis',
            'system' => 'cache.adapter.redis',
        ],
    ],
    'services' => [
        'cache.adapter.redis' => [
            'class' => 'Symfony\Component\Cache\Adapter\RedisAdapter',
            'arguments' => [
                '@redis_client',
            ],
        ],
        'redis_client' => [
            'class' => 'Redis',
            'calls' => [
                ['connect', ['redis', 6379]],
            ],
        ],
    ],
];

// ========================================
// 3. NATIVE PHP
// ========================================
class RedisConnection {
    private $redis;
    
    public function __construct() {
        $this->redis = new Redis();
        $this->redis->connect('redis', 6379);
    }
    
    public function set($key, $value, $ttl = 3600) {
        return $this->redis->setex($key, $ttl, $value);
    }
    
    public function get($key) {
        return $this->redis->get($key);
    }
    
    public function delete($key) {
        return $this->redis->del($key);
    }
    
    public function exists($key) {
        return $this->redis->exists($key);
    }
}

// ========================================
// 4. CODEIGNITER
// ========================================
$codeigniterRedisConfig = [
    'redis' => [
        'host' => 'redis',
        'port' => 6379,
        'password' => null,
        'database' => 0,
        'timeout' => 0,
    ],
];

// ========================================
// 5. CAKEPHP
// ========================================
$cakephpRedisConfig = [
    'Cache' => [
        'default' => [
            'className' => 'Cake\Cache\Engine\RedisEngine',
            'host' => 'redis',
            'port' => 6379,
            'database' => 0,
            'password' => null,
            'timeout' => 0,
            'persistent' => true,
        ],
    ],
];

// ========================================
// 6. TEST CONNECTION
// ========================================
function testRedisConnection() {
    try {
        $redis = new Redis();
        $redis->connect('redis', 6379);
        
        // Test basic operations
        $redis->set('test_key', 'Hello Redis!');
        $value = $redis->get('test_key');
        
        if ($value === 'Hello Redis!') {
            echo "✅ Redis connection successful!\n";
            echo "📊 Redis Info:\n";
            echo "   - Version: " . $redis->info()['redis_version'] . "\n";
            echo "   - Memory: " . $redis->info()['used_memory_human'] . "\n";
            echo "   - Connected clients: " . $redis->info()['connected_clients'] . "\n";
        } else {
            echo "❌ Redis test failed\n";
        }
        
        // Cleanup
        $redis->del('test_key');
        $redis->close();
        
    } catch (Exception $e) {
        echo "❌ Redis connection failed: " . $e->getMessage() . "\n";
    }
}

// Uncomment để test
// testRedisConnection();

// ========================================
// 7. USAGE EXAMPLES
// ========================================

// Basic usage
$redis = new Redis();
$redis->connect('redis', 6379);

// Set with expiration
$redis->setex('user:123', 3600, json_encode(['name' => 'John', 'email' => 'john@example.com']));

// Get and decode
$userData = json_decode($redis->get('user:123'), true);

// List operations
$redis->lpush('recent_visitors', 'user:123');
$redis->ltrim('recent_visitors', 0, 99); // Keep only last 100

// Hash operations
$redis->hset('user:123:profile', 'name', 'John');
$redis->hset('user:123:profile', 'email', 'john@example.com');
$profile = $redis->hgetall('user:123:profile');

// Set operations
$redis->sadd('online_users', 'user:123');
$redis->sadd('online_users', 'user:456');
$onlineCount = $redis->scard('online_users');

// Sorted set operations
$redis->zadd('leaderboard', 100, 'user:123');
$redis->zadd('leaderboard', 95, 'user:456');
$topUsers = $redis->zrevrange('leaderboard', 0, 9, true);

$redis->close();
?>
