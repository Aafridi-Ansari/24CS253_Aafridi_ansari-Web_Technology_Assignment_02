<?php
/**
 * Database Connection Configuration
 * KPR StudentHub — Web Technology Assignment 2 (CO4)
 * Author: Aafridi Ansari (24CS253)
 */

$host = 'localhost';
$db_name = 'kpr_studenthub';
$username = 'root';
$password = '';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db_name;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $username, $password, $options);
} catch (\PDOException $e) {
    // In demo / client-fallback mode, return simulated error response or connection object
    $db_connected = false;
    $db_error = $e->getMessage();
}
?>
