<?php
require_once(__DIR__ . '/../../src/config.php');

try {
    $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);

    $stmt_login = $pdo->prepare(
        "SELECT id_usuario, nom_usuario, pass_usuario, mail_usuario, ind_usuario, ind_estado
           FROM tab_usuarios
          WHERE id_usuario = ?::TEXT"
    );

    $stmt_fun_valida_usr = $pdo->prepare(
        "SELECT id_usuario, nom_usuario
           FROM tab_usuarios
          WHERE id_usuario = ?::TEXT
            AND ind_estado = TRUE"
    );

    $stmt_pmtros = $pdo->prepare(
        "SELECT val_parametro AS time_sesion_activa
           FROM tab_pmtros
          WHERE id_parametro = 'time_sesion_activa'
          LIMIT 1"
    );

    $stmt_valida_sesion = $pdo->prepare(
        "SELECT token_sesion
           FROM tab_sesiones
          WHERE id_usuario = ?"
    );

    $stmt_ins_sesion = $pdo->prepare(
        "INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio)
         VALUES (?, ?, CURRENT_TIMESTAMP)"
    );

    $stmt_del_sesion = $pdo->prepare(
        "DELETE FROM tab_sesiones WHERE id_usuario = ?"
    );

} catch (PDOException $e) {
    error_log('[DB] Error en prepare_auth.php: ' . $e->getMessage());
    http_response_code(503);
    exit('Error de conexión. Intente más tarde.');
}

function fijar_usuario_audit(PDO $pdo): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) {
        error_log('[AUDIT] fijar_usuario_audit: sesión PHP no activa.');
        return;
    }
    $id_usuario  = $_SESSION['id_usuario']  ?? null;
    $ip_conexion = $_SESSION['ip_conexion'] ?? ($_SERVER['REMOTE_ADDR'] ?? null);
    if ($id_usuario === null) {
        error_log('[AUDIT] fijar_usuario_audit: id_usuario ausente en sesión.');
        return;
    }
    try {
        $pdo->exec("SELECT set_config('app.audit_user', " . $pdo->quote((string) $id_usuario) . ", false)");
        if ($ip_conexion !== null) {
            $pdo->exec("SELECT set_config('app.audit_ip', " . $pdo->quote((string) $ip_conexion) . ", false)");
        }
    } catch (Throwable $e) {
        error_log('[AUDIT] No se pudo fijar GUC: ' . $e->getMessage());
    }
}

if (session_status() === PHP_SESSION_ACTIVE && isset($_SESSION['id_usuario'])) {
    fijar_usuario_audit($pdo);
}