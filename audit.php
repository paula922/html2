<?php
// ================================================================
// audit.php - VERSIÓN CORREGIDA CON LOGS (usa myapp.* y obtiene IP real)
// ================================================================

/**
 * Función para obtener la IP real del cliente (soporta proxies/CDNs)
 */
function obtener_ip_real_audit(): string {
    $ip = '0.0.0.0';

    $cabeceras = [
        'HTTP_CF_CONNECTING_IP',    // Cloudflare
        'HTTP_X_FORWARDED_FOR',     // Proxy/Load Balancer
        'HTTP_X_REAL_IP',           // Nginx/Apache
        'HTTP_CLIENT_IP',           // Algunos proxies
    ];

    foreach ($cabeceras as $cabecera) {
        if (!empty($_SERVER[$cabecera])) {
            $lista_ips = $_SERVER[$cabecera];
            if (strpos($lista_ips, ',') !== false) {
                $ips = explode(',', $lista_ips);
                $ip_candidata = trim($ips[0]);
            } else {
                $ip_candidata = trim($lista_ips);
            }

            if (filter_var($ip_candidata, FILTER_VALIDATE_IP)) {
                $ip = $ip_candidata;
                break;
            }
        }
    }

    if ($ip === '0.0.0.0' && !empty($_SERVER['REMOTE_ADDR'])) {
        $ip_candidata = $_SERVER['REMOTE_ADDR'];
        if (filter_var($ip_candidata, FILTER_VALIDATE_IP)) {
            $ip = $ip_candidata;
        }
    }

    return $ip;
}

/**
 * Fija las variables GUC que espera el trigger fun_audit_trail()
 * Usa myapp.user_id (texto) y myapp.user_ip (texto)
 * Incluye logs para depuración.
 */
function fijar_usuario_audit(PDO $pdo): void {
    error_log('[AUDIT] === INICIO fijar_usuario_audit ===');

    // 1. Verificar sesión activa
    if (session_status() !== PHP_SESSION_ACTIVE) {
        error_log('[AUDIT] ERROR: sesión PHP no activa.');
        return;
    }

    // 2. Obtener ID de usuario
    $id_usuario = $_SESSION['id_usuario'] ?? null;
    error_log('[AUDIT] id_usuario en sesión: ' . ($id_usuario ?? 'NULL'));

    if ($id_usuario === null) {
        error_log('[AUDIT] id_usuario ausente, se asigna 0');
        $id_usuario = '0';
    }

    // 3. Obtener IP real
    $ip_conexion = obtener_ip_real_audit();
    error_log('[AUDIT] IP real capturada: ' . $ip_conexion);

    try {
        // 4. Inyectar variables CORRECTAS (myapp.*)
        $sql_user = "SELECT set_config('myapp.user_id', " . $pdo->quote((string)$id_usuario) . ", false)";
        $sql_ip = "SELECT set_config('myapp.user_ip', " . $pdo->quote((string)$ip_conexion) . ", false)";

        error_log('[AUDIT] SQL USER: ' . $sql_user);
        error_log('[AUDIT] SQL IP: ' . $sql_ip);

        $pdo->exec($sql_user);
        $pdo->exec($sql_ip);

        error_log('[AUDIT] ✅ Variables inyectadas correctamente');
    } catch (Throwable $e) {
        error_log('[AUDIT] ❌ Error al inyectar GUC: ' . $e->getMessage());
    }
}