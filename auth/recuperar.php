<?php
/**
 * RECUPERAR CONTRASEÑA - CONPRE V.1.0
 */

header("X-Content-Type-Options: nosniff");
header("X-Frame-Options: SAMEORIGIN");
header("X-XSS-Protection: 1; mode=block");
header("Referrer-Policy: strict-origin-when-cross-origin");

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

require_once('src/prepare_auth.php');

$w_error = "";
$w_success = "";
$w_nueva_pass = "";

// ===== TOKEN CSRF (igual que en index.php) =====
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// ===== RATE LIMITING =====
$max_intentos = 3;
$tiempo_bloqueo = 10; // minutos

if (!isset($_SESSION['recuperar_intentos'])) {
    $_SESSION['recuperar_intentos'] = 0;
    $_SESSION['primer_intento_rec'] = 0;
}

if ($_SESSION['recuperar_intentos'] >= $max_intentos) {
    $tiempo_transcurrido = time() - $_SESSION['primer_intento_rec'];
    $tiempo_bloqueo_seg = $tiempo_bloqueo * 60;
    
    if ($tiempo_transcurrido < $tiempo_bloqueo_seg) {
        $minutos_restantes = ceil(($tiempo_bloqueo_seg - $tiempo_transcurrido) / 60);
        $w_error = "Demasiados intentos. Espere $minutos_restantes minutos.";
    } else {
        $_SESSION['recuperar_intentos'] = 0;
    }
}

// ===== FUNCIÓN GENERAR CONTRASEÑA =====
function generarPasswordSegura($longitud = 12) {
    $mayusculas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $minusculas = 'abcdefghijklmnopqrstuvwxyz';
    $numeros = '0123456789';
    $especiales = '!@#$%^&()_-+=[]{}<>?';
    $especiales = str_replace(['*','"',"'"], '', $especiales);
    $todos = $mayusculas . $minusculas . $numeros . $especiales;

    $password = '';
    $password .= $mayusculas[random_int(0, strlen($mayusculas)-1)];
    $password .= $minusculas[random_int(0, strlen($minusculas)-1)];
    $password .= $numeros[random_int(0, strlen($numeros)-1)];
    $password .= $especiales[random_int(0, strlen($especiales)-1)];

    for ($i = 4; $i < $longitud; $i++) {
        $password .= $todos[random_int(0, strlen($todos)-1)];
    }

    return str_shuffle($password);
}

// ===== PROCESAR FORMULARIO =====
if ($_SERVER['REQUEST_METHOD'] === 'POST' && empty($w_error)) {
    
    // Validar token CSRF
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        $w_error = "Error de seguridad. Intente nuevamente.";
    } else {
        
        // ===== SANITIZACIÓN =====
        $w_user   = trim($_POST['txt_usuario'] ?? '');
        $w_user   = filter_var($w_user, FILTER_SANITIZE_STRING);
        $w_user   = substr($w_user, 0, 50);
        
        $w_correo = trim($_POST['txt_correo'] ?? '');
        $w_correo = filter_var($w_correo, FILTER_SANITIZE_EMAIL);
        
        $w_metodo = $_POST['rdo_metodo'] ?? 'correo';
        
        // ===== VALIDACIONES =====
        if (empty($w_user)) {
            $w_error = "El usuario es obligatorio";
        } elseif ($w_metodo === 'correo') {
            if (empty($w_correo)) {
                $w_error = "El correo es obligatorio para este método";
            } elseif (!filter_var($w_correo, FILTER_VALIDATE_EMAIL)) {
                $w_error = "El formato del correo no es válido";
            }
        }
        
        // ===== PROCESAR SI NO HAY ERROR =====
        if (empty($w_error)) {
            try {
                // Verificar que el usuario existe y está activo
                $stmt_fun_valida_usr->execute([$w_user]);
                $w_reg = $stmt_fun_valida_usr->fetch();

                if (!$w_reg) {
                    $w_error = "No se encontró un usuario activo con ese ID.";
                    
                    // Rate limiting: aumentar intentos
                    $_SESSION['recuperar_intentos']++;
                    if ($_SESSION['recuperar_intentos'] == 1) {
                        $_SESSION['primer_intento_rec'] = time();
                    }
                    
                } else {
                    // Si eligió correo, validar que coincida
                    if ($w_metodo === 'correo') {
                        $stmt_valida_mail->execute([$w_user, $w_correo]);
                        $w_mail_reg = $stmt_valida_mail->fetch();
                        
                        if (!$w_mail_reg) {
                            $w_error = "El correo no coincide con el registrado.";
                            
                            // Rate limiting
                            $_SESSION['recuperar_intentos']++;
                            if ($_SESSION['recuperar_intentos'] == 1) {
                                $_SESSION['primer_intento_rec'] = time();
                            }
                        }
                    }
                    
                    // Si aún no hay error (correo válido o método pantalla)
                    if (empty($w_error)) {
                        
                        // Generar nueva contraseña
                        $w_nueva_pass = generarPasswordSegura(12);
                        $hash_pass = password_hash($w_nueva_pass, PASSWORD_BCRYPT);
                        
                        // Actualizar en BD
                        $stmt_upd_pass->execute([$hash_pass, $w_user]);
                        
                        // Resetear contador de intentos
                        $_SESSION['recuperar_intentos'] = 0;
                        
                        // Mensaje según método
                        if ($w_metodo === 'correo') {
                            // AQUÍ IRÍA LÓGICA DE ENVÍO DE EMAIL
                            $w_success = "Se ha enviado una nueva contraseña a su correo.";
                        } else {
                            // Método pantalla: mostrar contraseña
                            $w_success = "Contraseña generada correctamente.";
                        }
                    }
                }
                
            } catch (Exception $e) {
                $w_error = "Error técnico. Intente más tarde.";
                error_log("Recuperar error: " . $e->getMessage());
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONPRE | Recuperar Contraseña</title>
    
    <!-- ANTI-FLASH - MISMO MÉTODO QUE INDEX.PHP (data-theme) -->
    <script>
    (function() {
        var theme = localStorage.getItem('erp_adso_theme');
        var user = localStorage.getItem('erp_adso_theme_user') === '1';
        var dark = user ? theme === 'dark' : window.matchMedia('(prefers-color-scheme: dark)').matches;
        if (!user) localStorage.setItem('erp_adso_theme', dark ? 'dark' : 'light');
        if (dark) {
            document.documentElement.setAttribute('data-theme', 'dark');
            document.documentElement.style.colorScheme = 'dark';
        }
    })();
    </script>
    
    <!-- Estilos -->
    <link rel="stylesheet" href="css/recuperar.css">
    
    <!-- Fuentes -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="img/logo-erp.webp">
</head>
<body>

    <!-- Botón volver al login -->
    <a href="index.php" class="back-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 18 9 12 15 6"/>
        </svg>
        Volver
    </a>

    <!-- Botón de tema (usa ThemeSync si existe) -->
    <div class="dark-toggle-fixed">
        <button class="icon-btn" onclick="if(typeof ThemeSync !== 'undefined' && ThemeSync.toggle) ThemeSync.toggle(); else toggleThemeFallback()" aria-label="Cambiar tema">
            <svg id="theme-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="5"/>
                <line x1="12" y1="1" x2="12" y2="3"/>
                <line x1="12" y1="21" x2="12" y2="23"/>
                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                <line x1="1" y1="12" x2="3" y2="12"/>
                <line x1="21" y1="12" x2="23" y2="12"/>
                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
            </svg>
        </button>
    </div>

    <div class="login-wrapper">
        <div class="auth-card">
            <div class="auth-blob t"></div>
            <div class="auth-blob b"></div>

            <!-- Header -->
            <div class="auth-header">
                <div class="auth-logo-wrap">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </div>
                <h2 class="auth-title">Recuperar Contraseña</h2>
                <div class="auth-subtitle">
                    <span class="auth-badge">Control de Acceso</span>
                </div>
            </div>

            <!-- Alertas -->
            <?php if ($w_error): ?>
                <div class="alert alert-danger">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <?= htmlspecialchars($w_error) ?>
                </div>
            <?php endif; ?>

            <?php if ($w_success): ?>
                <div class="alert alert-success">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <?= htmlspecialchars($w_success) ?>
                </div>
            <?php endif; ?>

            <?php if ($w_nueva_pass): ?>
                <!-- Mostrar nueva contraseña -->
                <div class="pass-result-box">
                    <span class="pass-result-label">Su nueva clave temporal</span>
                    <div class="pass-result-wrap">
                        <input type="password" id="nueva-pass-display" class="pass-result-input" value="<?= htmlspecialchars($w_nueva_pass) ?>" readonly>
                        <button type="button" class="pass-eye" onclick="toggleNuevaPass()" aria-label="Ver clave">
                            <svg id="pass-eye-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                    <div class="aviso-copia">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                        </svg>
                        Copie su clave antes de salir
                    </div>
                </div>
                <a href="index.php" class="btn-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
                        <polyline points="10 17 15 12 10 7"/>
                        <line x1="15" y1="12" x2="3" y2="12"/>
                    </svg>
                    Ir al Login
                </a>

            <?php else: ?>
                <!-- Formulario de recuperación -->
                <form method="POST" autocomplete="off" novalidate>
                    
                    <!-- Token CSRF -->
                    <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
                    
                    <div class="form-group">
                        <label class="form-label" for="txt_usuario">
                            ID de Usuario <span style="color:#ef4444;margin-left:3px">*</span>
                        </label>
                        <div class="input-wrap">
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                            <input class="form-input" type="text" id="txt_usuario" name="txt_usuario"
                                   placeholder="Ingresa tu usuario"
                                   value="<?= htmlspecialchars($_POST['txt_usuario'] ?? '') ?>">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Método de entrega</label>
                        <div class="metodo-row">
                            <label class="radio-label">
                                <input type="radio" name="rdo_metodo" value="correo"
                                       <?= (($_POST['rdo_metodo'] ?? 'correo') === 'correo') ? 'checked' : '' ?>
                                       onchange="toggleCorreo(true)">
                                Correo
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="rdo_metodo" value="pantalla"
                                       <?= (($_POST['rdo_metodo'] ?? '') === 'pantalla') ? 'checked' : '' ?>
                                       onchange="toggleCorreo(false)">
                                Pantalla
                            </label>
                        </div>
                    </div>

                    <div id="div-correo" class="form-group">
                        <label class="form-label" for="txt_correo">
                            Confirme su correo <span style="color:#ef4444;margin-left:3px">*</span>
                        </label>
                        <div class="input-wrap">
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                <polyline points="22,6 12,13 2,6"/>
                            </svg>
                            <input class="form-input" type="email" id="txt_correo" name="txt_correo"
                                   placeholder="correo@ejemplo.com"
                                   value="<?= htmlspecialchars($_POST['txt_correo'] ?? '') ?>">
                        </div>
                    </div>

                    <button type="submit" class="btn-primary">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="9 11 12 14 22 4"/>
                            <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                        </svg>
                        Procesar Solicitud
                    </button>

                    <div class="center-row">
                        <a href="index.php" class="forgot-link">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M19 12H5M12 19l-7-7 7-7"/>
                            </svg>
                            Cancelar
                        </a>
                    </div>
                </form>
            <?php endif; ?>
        </div>
        <p class="copyright">© 2026 ADSO – </p>
    </div>

    <!-- Scripts -->
    <script src="/js/theme-sync.js"></script>
    
    <!-- Fallback para toggle de tema si theme-sync.js no carga -->
    <script>
    function toggleThemeFallback() {
        var html = document.documentElement;
        var isDark = html.hasAttribute('data-theme');
        
        if (isDark) {
            html.removeAttribute('data-theme');
            html.style.colorScheme = 'light';
            localStorage.setItem('erp_adso_theme', 'light');
            localStorage.setItem('erp_adso_theme_user', '1');
            
            var icon = document.getElementById('theme-icon');
            if (icon) {
                icon.innerHTML = '<circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>';
            }
        } else {
            html.setAttribute('data-theme', 'dark');
            html.style.colorScheme = 'dark';
            localStorage.setItem('erp_adso_theme', 'dark');
            localStorage.setItem('erp_adso_theme_user', '1');
            
            var icon = document.getElementById('theme-icon');
            if (icon) {
                icon.innerHTML = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>';
            }
        }
    }
    
    // Funciones para el formulario
    function toggleCorreo(mostrar) {
        const div = document.getElementById('div-correo');
        const input = document.getElementById('txt_correo');
        if (!div || !input) return;
        div.style.display = mostrar ? 'block' : 'none';
        input.required = mostrar;
    }

    document.addEventListener('DOMContentLoaded', () => {
        const metodo = document.querySelector('input[name="rdo_metodo"]:checked')?.value ?? 'correo';
        toggleCorreo(metodo === 'correo');
    });

    function toggleNuevaPass() {
        const input = document.getElementById('nueva-pass-display');
        const icon = document.getElementById('pass-eye-icon');
        if (!input) return;
        
        if (input.type === 'password') {
            input.type = 'text';
            icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>';
        } else {
            input.type = 'password';
            icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
        }
    }
    </script>
</body>
</html>