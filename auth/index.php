<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

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
    session_start();
}

require_once(__DIR__ . '/src/prepare_auth.php');

$w_error = "";

// ============================================================
// PROCESAR LOGIN (POST tradicional)
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validar CSRF
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        $w_error = "Error de seguridad. Intente nuevamente.";
    } else {
        $w_user = trim($_POST['txt_usuario'] ?? '');
        $w_user = filter_var($w_user, FILTER_SANITIZE_STRING);
        $w_user = substr($w_user, 0, 50);
        $w_pass = $_POST['txt_clave'] ?? '';

        if (empty($w_user) || empty($w_pass)) {
            $w_error = "Por favor complete todos los campos.";
        } elseif (strlen($w_user) < 3) {
            $w_error = "El usuario debe tener al menos 3 caracteres.";
        } elseif (strlen($w_pass) < 6) {
            $w_error = "La contraseña debe tener al menos 6 caracteres.";
        } else {
            try {
                $stmt_login->execute([$w_user]);
                $w_reg = $stmt_login->fetch();

                if ($w_reg) {
                    if ($w_reg['ind_estado'] == false && $w_reg['ind_usuario'] == false) {
                        $w_error = "ACCESO DENEGADO";
                    } elseif (password_verify($w_pass, $w_reg['pass_usuario'])) {
                        // Login exitoso
                        $_SESSION['login_intentos'] = 0;
                        $_SESSION['id_usuario'] = $w_reg['id_usuario'];
                        $_SESSION['nom_usuario'] = $w_reg['nom_usuario'];
                        $_SESSION['ind_usuario'] = $w_reg['ind_usuario'];
                        $_SESSION['ip_conexion'] = $_SERVER['REMOTE_ADDR'] ?? null;

                        header("Location: /erpadso/src/menu_principal.php");
                        exit();
                    } else {
                        $w_error = "ID de usuario o contraseña incorrectos.";
                    }
                } else {
                    $w_error = "ID de usuario o contraseña incorrectos.";
                }
            } catch (Exception $e) {
                $w_error = "Error técnico. Intente más tarde.";
                error_log("Login error: " . $e->getMessage());
            }
        }
    }
}

// CSRF token para el formulario
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADSO ERP | Ingreso</title>
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
    <link rel="icon" type="image/x-icon" href="img/logo-erp.webp">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/erpadso/auth/css/index_auth2.css">
</head>
<body>
<div id="view-login" class="active">
    <a href="/loading.html?redirect=inicio.html" class="back-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        Volver
    </a>
    <div class="dark-toggle-fixed">
        <button class="icon-btn" onclick="toggleTheme()" aria-label="Cambiar tema">
            <svg id="dark-icon-login" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
        </button>
    </div>
    <div class="login-wrapper">
        <div class="auth-card">
            <div class="auth-blob t"></div>
            <div class="auth-blob b"></div>
            <div class="auth-header">
                <div class="auth-logo-wrap">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="10" y1="14" x2="10" y2="10"/><line x1="13" y1="14" x2="13" y2="8"/><line x1="16" y1="14" x2="16" y2="6"/>
                    </svg>
                </div>
                <h2 class="auth-title">ADSO ERP</h2>
                <div class="auth-subtitle"><span class="auth-badge">GESTIÓN ADMINISTRATIVA</span></div>
            </div>
            <?php if (!empty($w_error)): ?>
                <div class="alert alert-danger" style="background: rgba(239,68,68,0.1); color: #ef4444; padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; text-align: center; border: 1px solid rgba(239,68,68,0.2);">
                    <?= htmlspecialchars($w_error) ?>
                </div>
            <?php endif; ?>
            <form method="POST" novalidate>
                <div class="form-group">
                    <label class="form-label">Usuario<span style="color:#ef4444;margin-left:3px">*</span></label>
                    <div class="input-wrap">
                        <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input class="form-input" type="text" id="user-input" name="txt_usuario" autocomplete="username" placeholder="usuario" />
                    </div>
                    <span id="user-msg" class="field-msg"></span>
                </div>
                <div class="form-group">
                    <label class="form-label">Contraseña<span style="color:#ef4444;margin-left:3px">*</span></label>
                    <div class="input-wrap">
                        <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input id="pw-input" name="txt_clave" class="form-input has-eye" type="password" placeholder="••••••••" required>
                        <button type="button" class="pw-toggle" onclick="togglePw()" aria-label="Ver contraseña">
                            <svg id="pw-eye" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <span id="pw-msg" class="field-msg"></span>
                </div>
                <div class="remember-row">
                    <a href="recuperar.php" class="forgot-link">¿Olvidó su contraseña?</a>
                </div>
                <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
                <button type="submit" class="btn-primary" style="margin-bottom:20px">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                    Iniciar Sesión
                </button>
            </form>
        </div>
        <p class="copyright">© 2026 ADSO – </p>
    </div>
</div>
<script>
function togglePw() {
    var pw = document.getElementById('pw-input');
    var eye = document.getElementById('pw-eye');
    if (pw.type === 'password') {
        pw.type = 'text';
        eye.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>';
    } else {
        pw.type = 'password';
        eye.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
    }
}
</script>
</body>
</html>