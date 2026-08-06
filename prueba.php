<?php
// ============================================================
// PRUEBA DE CONEXIÓN A POSTGRESQL (script independiente)
// ============================================================

// 1. Definir los datos de conexión (cámbialos si es necesario)
$host = 'localhost';
$port = '5432';
$dbname = 'erp_prueba';
$user = 'postgres';
$password = '12345';

// 2. Intentar conectar
try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    
    echo "<h1 style='color:green;'>✅ CONEXIÓN EXITOSA</h1>";
    echo "<p>Conectado a la base de datos <strong>$dbname</strong> con el usuario <strong>$user</strong>.</p>";
    
    // (Opcional) Mostrar la versión de PostgreSQL
    $version = $pdo->query('SELECT version()')->fetchColumn();
    echo "<p>Versión de PostgreSQL: $version</p>";
    
} catch (PDOException $e) {
    echo "<h1 style='color:red;'>❌ ERROR DE CONEXIÓN</h1>";
    echo "<p><strong>Mensaje:</strong> " . $e->getMessage() . "</p>";
}
?>