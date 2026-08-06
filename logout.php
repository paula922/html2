<?php
session_start();

// Conectar directamente a la BD
require_once('config.php');

try {
    $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    
    $id_usuario = $_SESSION['id_usuario'] ?? null;
    
    if ($id_usuario) {
        $stmt = $pdo->prepare("DELETE FROM tab_sesiones WHERE id_usuario = CAST(? AS TEXT)");
        $stmt->execute([$id_usuario]);
    }
} catch (Exception $e) {
    error_log("LOGOUT ERROR: " . $e->getMessage());
}

// Destruir sesión
$_SESSION = [];
session_unset();
session_destroy();

// Headers para no cachear
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Pragma: no-cache");
header("Expires: 0");

// Redirigir al login
header("Location: ../auth/index.php");
exit();
?>