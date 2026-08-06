<?php
// config.php - VERSIÓN UNIFICADA CON AUDITORÍA INTEGRADA

// ============================================
// CARGADOR DE .env (integrado)
// ============================================

class EnvLoader {
    private static $loaded = false;
    
    public static function load($path = '') {
        if (self::$loaded) return;
        
        if (empty($path)) {
            $path = dirname(__DIR__) . '/.env';
        }
        
        if (!file_exists($path)) {
            die('Error: Archivo .env no encontrado');
        }
        
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        
        foreach ($lines as $line) {
            if (strpos(trim($line), '#') === 0) continue;
            
            $pos = strpos($line, '=');
            if ($pos === false) continue;
            
            $key = trim(substr($line, 0, $pos));
            $value = trim(substr($line, $pos + 1));
            
            if (preg_match('/^"(.*)"$/', $value, $matches)) {
                $value = $matches[1];
            } elseif (preg_match("/^'(.*)'$/", $value, $matches)) {
                $value = $matches[1];
            }
            
            putenv("$key=$value");
            $_ENV[$key] = $value;
        }
        
        self::$loaded = true;
    }
    
    public static function get($key, $default = null) {
        return $_ENV[$key] ?? getenv($key) ?: $default;
    }
}

// ============================================
// CARGAR .env
// ============================================

EnvLoader::load();

// ============================================
// CONSTANTES
// ============================================

define('DB_HOST', EnvLoader::get('DB_HOST'));
define('DB_PORT', EnvLoader::get('DB_PORT'));
define('DB_NAME', EnvLoader::get('DB_NAME'));
define('DB_USER', EnvLoader::get('DB_USER'));
define('DB_PASS', EnvLoader::get('DB_PASS'));
define('APP_ENV', EnvLoader::get('APP_ENV', 'production'));
define('MAX_LOGIN_ATTEMPTS', 5);
define('LOGIN_BLOCK_MINUTES', 10);

// ============================================
// FUNCIÓN PARA OBTENER IP REAL
// ============================================

function obtener_ip_real(): string {
    $ip = '0.0.0.0';
    $cabeceras = [
        'HTTP_CF_CONNECTING_IP',
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_REAL_IP',
        'HTTP_CLIENT_IP',
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

// ============================================
// FUNCIÓN DE CONEXIÓN CON AUDITORÍA INTEGRADA
// ============================================

function getDBConnection() {
    static $pdo = null;
    
    if ($pdo === null) {
        try {
            $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
            $pdo = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);

            // ============================================================
            // 🔥 INYECCIÓN DE AUDITORÍA (se ejecuta al crear la conexión)
            // ============================================================
            $id_usuario = $_SESSION['id_usuario'] ?? '0';
            $ip_conexion = obtener_ip_real();

            try {
                $pdo->exec("SELECT set_config('myapp.user_id', " . $pdo->quote((string)$id_usuario) . ", false)");
                $pdo->exec("SELECT set_config('myapp.user_ip', " . $pdo->quote((string)$ip_conexion) . ", false)");
                error_log('[AUDIT] Variables inyectadas: user=' . $id_usuario . ', ip=' . $ip_conexion);
            } catch (PDOException $e) {
                error_log('[AUDIT] Error al inyectar GUC: ' . $e->getMessage());
            }
            // ============================================================

        } catch (PDOException $e) {
            die("Error de conexión: " . $e->getMessage());
        }
    }
    
    return $pdo;
}
?>