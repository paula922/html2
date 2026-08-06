<?php
/**
 * MIDDLEWARE DE SEGURIDAD - SistNomina V.1.2
 * 
 * Esta clase la pongo al inicio de las páginas para aplicar medidas de seguridad
 * de forma automática: headers HTTP, validación de HTTPS, protección contra ataques
 * comunes y configuración segura de sesiones.
 * 
 * La idea es que con solo llamar SecurityMiddleware::initialize() ya tengo
 * toda la seguridad básica cubierta.
 */

class SecurityMiddleware {
    
    /**
     * Método principal que inicia todas las protecciones
     * Lo llamo una sola vez al empezar cada página
     */
    public static function initialize() {
        self::setSecurityHeaders();           // Headers HTTP de seguridad
        // self::enforceHTTPS();              // Comentado porque estoy en desarrollo
        self::preventCommonAttacks();         // Validaciones básicas
        self::configureSessionSecurity();     // Configuración segura de sesión
    }

    /**
     * Establece los headers HTTP de seguridad
     * Estos le dicen al navegador cómo comportarse
     */
    private static function setSecurityHeaders() {
        // Evita que el navegador interprete archivos como otro tipo MIME
        header("X-Content-Type-Options: nosniff");
        
        // Evita que carguen mi página en un iframe (protección contra clickjacking)
        header("X-Frame-Options: SAMEORIGIN");
        
        // Activa protección contra XSS en navegadores viejos
        header("X-XSS-Protection: 1; mode=block");
        
        // Controla qué información se envía cuando el usuario hace clic en un enlace
        header("Referrer-Policy: strict-origin-when-cross-origin");
        
        // Política de permisos: desactivo cosas que no uso (geolocalización, cámara, micrófono)
        header("Permissions-Policy: geolocation=(), microphone=(), camera=()");
        
        // Content Security Policy - Controla de dónde se pueden cargar recursos
        // Esto es más estricto, lo fui ajustando con prueba y error
        header("Content-Security-Policy: default-src 'self'; script-src 'self' https://cdn.jsdelivr.net; style-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; font-src 'self' https://cdn.jsdelivr.net; img-src 'self' data:;");
    }

    /**
     * Fuerza el uso de HTTPS en producción
     * Por ahora lo tengo comentado porque trabajo en local sin HTTPS
     */
    private static function enforceHTTPS() {
        if (defined('APP_ENV') && APP_ENV === 'production') {
            if (empty($_SERVER['HTTPS']) || $_SERVER['HTTPS'] === 'off') {
                $url = "https://" . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
                header("Location: $url", true, 301);
                exit();
            }
        }
    }

    /**
     * Previene ataques comunes validando las peticiones
     */
    private static function preventCommonAttacks() {
        // Solo permito ciertos métodos HTTP
        $allowed_methods = ['GET', 'POST', 'HEAD', 'OPTIONS'];
        if (!in_array($_SERVER['REQUEST_METHOD'], $allowed_methods)) {
            http_response_code(405); // Method Not Allowed
            die("Método no permitido");
        }

        // Prevengo Directory Traversal en los parámetros GET
        // Busco secuencias como .. que intentan salir de directorios
        if (isset($_GET) && !empty($_GET)) {
            foreach ($_GET as $key => $value) {
                if (is_string($value) && strpos($value, '..') !== false) {
                    http_response_code(400); // Bad Request
                    die("Solicitud inválida");
                }
            }
        }
    }

    /**
     * Configura la sesión de PHP con opciones seguras
     */
    private static function configureSessionSecurity() {
        if (session_status() === PHP_SESSION_NONE) {
            // httponly: la cookie no es accesible desde JavaScript
            ini_set('session.cookie_httponly', '1');
            
            // secure: la cookie solo se envía por HTTPS
            // Lo comento en desarrollo, pero en producción debería estar en 1
            // ini_set('session.cookie_secure', '1');
            
            // samesite: evita que la cookie se envíe en peticiones de otros sitios
            ini_set('session.cookie_samesite', 'Strict');
            
            // use_strict_mode: rechaza session IDs no generadas por PHP
            ini_set('session.use_strict_mode', '1');
            
            // Finalmente, inicio la sesión
  if (session_status() === PHP_SESSION_NONE) {

  session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => true,
    'httponly' => true,
    'samesite' => 'Lax'
  ]);

session_start(); // Inicio la sesión para poder guardar datos del usuario
}

        }
    }

    /**
     * Valida el token CSRF en peticiones POST
     * Lo llamo antes de procesar formularios importantes
     */
    public static function validateCSRFToken() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
                http_response_code(403); // Forbidden
                die("Token CSRF inválido");
            }
        }
    }

    /**
     * Genera un token CSRF y lo guarda en sesión
     * Lo llamo en los formularios para ponerlo como campo oculto
     * 
     * @return string Token generado
     */
    public static function generateCSRFToken() {
        if (!isset($_SESSION['csrf_token'])) {
            // 32 bytes en hexadecimal = 64 caracteres
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }
}

// Inicializo el middleware automáticamente al incluir el archivo
SecurityMiddleware::initialize();
?>