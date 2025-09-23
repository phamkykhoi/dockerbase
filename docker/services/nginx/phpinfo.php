<?php
// PHP Info file for testing PHP version
// Access via: http://localhost/phpinfo

echo "<h1>PHP Version: " . PHP_VERSION . "</h1>";
echo "<h2>Server: " . $_SERVER['SERVER_SOFTWARE'] . "</h2>";
echo "<h3>Current Time: " . date('Y-m-d H:i:s') . "</h3>";

// Show Redis connection test
if (extension_loaded('redis')) {
    echo "<h3>Redis Extension: ✅ Available</h3>";
    try {
        $redis = new Redis();
        $redis->connect('redis', 6379);
        $redis->set('test_key', 'Hello from PHP ' . PHP_VERSION);
        $value = $redis->get('test_key');
        echo "<p>Redis Test: ✅ Connected - " . $value . "</p>";
        $redis->del('test_key');
        $redis->close();
    } catch (Exception $e) {
        echo "<p>Redis Test: ❌ Failed - " . $e->getMessage() . "</p>";
    }
} else {
    echo "<h3>Redis Extension: ❌ Not Available</h3>";
}

// Show loaded extensions
echo "<h3>Loaded Extensions:</h3>";
echo "<ul>";
foreach (get_loaded_extensions() as $ext) {
    echo "<li>" . $ext . "</li>";
}
echo "</ul>";

// Show PHP configuration
echo "<h3>PHP Configuration:</h3>";
echo "<ul>";
echo "<li>Memory Limit: " . ini_get('memory_limit') . "</li>";
echo "<li>Upload Max Filesize: " . ini_get('upload_max_filesize') . "</li>";
echo "<li>Post Max Size: " . ini_get('post_max_size') . "</li>";
echo "<li>Max Execution Time: " . ini_get('max_execution_time') . "</li>";
echo "</ul>";

// Show phpinfo if requested
if (isset($_GET['full']) && $_GET['full'] === '1') {
    phpinfo();
}
?>
