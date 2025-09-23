<?php
// PhpMyAdmin configuration for multiple MySQL versions
$cfg['Servers'][1]['host'] = 'mysql57';
$cfg['Servers'][1]['port'] = '3306';
$cfg['Servers'][1]['user'] = 'root';
$cfg['Servers'][1]['password'] = '123@123a';
$cfg['Servers'][1]['auth_type'] = 'config';
$cfg['Servers'][1]['connect_timeout'] = 60;
$cfg['Servers'][1]['compress'] = false;
$cfg['Servers'][1]['AllowNoPassword'] = false;

$cfg['Servers'][2]['host'] = 'mysql8';
$cfg['Servers'][2]['port'] = '3306';
$cfg['Servers'][2]['user'] = 'phpmyadmin';
$cfg['Servers'][2]['password'] = '123@123a';
$cfg['Servers'][2]['auth_type'] = 'config';
$cfg['Servers'][2]['connect_timeout'] = 60;
$cfg['Servers'][2]['compress'] = false;
$cfg['Servers'][2]['AllowNoPassword'] = false;
$cfg['Servers'][2]['ssl'] = false;
$cfg['Servers'][2]['ssl_verify'] = false;

// General settings
$cfg['DefaultLang'] = 'vi';
$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
$cfg['TempDir'] = '/tmp';
$cfg['MaxRows'] = 50;
$cfg['MaxCharactersInDisplayedSQL'] = 1000;
$cfg['ExecTimeLimit'] = 300;
$cfg['MemoryLimit'] = '512M';
$cfg['CheckConfigurationPermissions'] = false;
$cfg['DisableShortcutKeys'] = false;
$cfg['SendErrorReports'] = 'never';
$cfg['DefaultCharset'] = 'utf8mb4';
$cfg['DefaultConnectionCollation'] = 'utf8mb4_unicode_ci';
?>
