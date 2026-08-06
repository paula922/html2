<!-- 
  LOGIN PRINCIPAL -  CONPRE V.1.0
  Esto es el archivo principal de login. Le puse validaciones de seguridad porque me explicaron que era importante.
  Validación de ind_estado, Estética Corporativa y Seguridad
-->
<?php
  // Estos headers los agregué por seguridad, evitan que el navegador haga cosas raras
  header("X-Content-Type-Options: nosniff"); // Evita que se interpreten archivos como otro tipo
  header("X-Frame-Options: SAMEORIGIN"); // Evita que carguen mi página en un iframe (clickjacking)
  header("X-XSS-Protection: 1; mode=block"); // Activa protección contra XSS en navegadores viejos
  header("Referrer-Policy: strict-origin-when-cross-origin"); // Controla qué información se envía al salir del sitio

  if (session_status() === PHP_SESSION_NONE) {

  session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => false,
    'httponly' => true,
    'samesite' => 'Lax'
  ]);

session_start(); // Inicio la sesión para poder guardar datos del usuario
}

  require_once('src/prepare_auth.php'); // Aquí están las consultas preparadas a la base de datos

  $w_error = ""; // Esta variable guarda los mensajes de error que se muestran al usuario

  // TOKEN CSRF - Me explicaron que es para evitar que envién formularios desde otros sitios
  if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); // Genera un token aleatorio de 32 bytes
  }
  // ===== RATE LIMITING =====
  // Esto lo agregué para evitar que intenten muchas contraseñas seguidas (fuerza bruta)
  $max_intentos = 5; // Número máximo de intentos permitidos
  $tiempo_bloqueo = 10; // Minutos que dura el bloqueo

  // Inicializo las variables de sesión para controlar los intentos si no existen
  if (!isset($_SESSION['login_intentos'])) {
    $_SESSION['login_intentos'] = 0; // Contador de intentos fallidos
    $_SESSION['primer_intento'] = 0; // Guarda la hora del primer intento fallido
  }

  // Verificar si ya superó los intentos permitidos
  if ($_SESSION['login_intentos'] >= $max_intentos) {
    // Calcula cuánto tiempo pasó desde el primer intento
    $tiempo_transcurrido = time() - $_SESSION['primer_intento'];
    $tiempo_bloqueo_seg = $tiempo_bloqueo * 60; // Convierte minutos a segundos
    
    // Si aún no ha pasado el tiempo de bloqueo
    if ($tiempo_transcurrido < $tiempo_bloqueo_seg) {
        // Calcula los minutos restantes y los muestra al usuario
        $minutos_restantes = ceil(($tiempo_bloqueo_seg - $tiempo_transcurrido) / 60);
        $w_error = "Demasiados intentos. Espere $minutos_restantes minutos.";
    } else {
        // Si ya pasó el tiempo, reinicia el contador
        $_SESSION['login_intentos'] = 0;
    }
  }

  // ===== PROCESAR LOGIN =====
  // Solo proceso si es método POST y no hay error de bloqueo
  if ($_SERVER['REQUEST_METHOD'] == 'POST' && empty($w_error)) {
    
      // Validar token CSRF - esto evita que hackers envien formularios falsos
      if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        $w_error = "Error de seguridad. Intente nuevamente.";
      } else {
        // ===== SANITIZACIÓN =====
        // Limpio los datos que llegan del formulario para evitar inyecciones
        $w_user = trim($_POST['txt_usuario'] ?? ''); // Quita espacios al inicio y final
        $w_user = filter_var($w_user, FILTER_SANITIZE_STRING); // Elimina etiquetas HTML y caracteres raros
        $w_user = substr($w_user, 0, 50); // Limito a 50 caracteres máximo por seguridad
        
        $w_pass = $_POST['txt_clave'] ?? ''; // La contraseña no se limpia porque puede tener caracteres válidos
        
        // ===== VALIDACIONES =====
        // Verifico que los campos no estén vacíos
        if (empty($w_user) || empty($w_pass)) {
            $w_error = "Por favor complete todos los campos";
        } elseif (strlen($w_user) < 3) { // El usuario debe tener mínimo 3 caracteres
            $w_error = "Usuario debe tener al menos 3 caracteres";
        } elseif (strlen($w_pass) < 6) { // La contraseña debe tener mínimo 6 (aunque en el html pide 8)
            $w_error = "Contraseña debe tener al menos 6 caracteres";
        } else {
            
            try {
                // Buscar usuario en la base de datos con la consulta preparada
                $stmt_login->execute([$w_user]);
                $w_reg = $stmt_login->fetch(); // Obtengo los datos del usuario si existe
                
                if ($w_reg) {
                    // Validar estado del usuario (activo/inactivo)
                    // Me explicaron que ind_estado e ind_usuario false significa usuario bloqueado
                    if ($w_reg['ind_estado'] == false && $w_reg['ind_usuario'] == false) {
                        $w_error = "ACCESO DENEGADO"; // Mensaje genérico, no digo que está bloqueado
                        
                        // Registrar intento fallido para el rate limiting
                        $_SESSION['login_intentos']++;
                        if ($_SESSION['login_intentos'] == 1) {
                            $_SESSION['primer_intento'] = time(); // Guardo la hora del primer fallo
                        }
                        
                    } else {
                        // Validar contraseña usando password_verify (me dijeron que es más seguro)
                        if (password_verify($w_pass, $w_reg['pass_usuario'])) {
                            
                            // LOGIN EXITOSO - Reiniciar contador de intentos
                            $_SESSION['login_intentos'] = 0;
                            
                            // Crear variables de sesión con los datos del usuario
                            $_SESSION['id_usuario'] = $w_reg['id_usuario'];
                            $_SESSION['nom_usuario'] = $w_reg['nom_usuario'];
                            $_SESSION['ind_usuario'] = $w_reg['ind_usuario']; // true = admin, false = usuario normal
                            
                          // ESTO SE DEBE COMENTAR SI EL TUNNEL NO FUNCIONA, SOLO SI SE VA A INGRESAR CON PROTOCOLO HTTP, ESTO EXIGE HTTPS:
                           header("Location: https://" . $_SERVER['HTTP_HOST'] . "/erpadso/src/menu_principal.php");
                           exit(); // Importante: después de header hay que poner exit
                           

                           // Opción B: Mantener el protocolo que use el usuario (recomendado)
                           $protocolo = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
                           header("Location: " . $protocolo . "://" . $_SERVER['HTTP_HOST'] . "/erpadso/src/menu_principal.php");

                        } else {
                            $w_error = "ID de usuario o contraseña incorrectos."; // Mensaje genérico
                            
                            // Registrar intento fallido
                            $_SESSION['login_intentos']++;
                            if ($_SESSION['login_intentos'] == 1) {
                                $_SESSION['primer_intento'] = time();
                            }
                        }
                    }
                } else {
                    $w_error = "ID de usuario o contraseña incorrectos."; // Mismo mensaje por seguridad
                    
                    // Registrar intento fallido
                    $_SESSION['login_intentos']++;
                    if ($_SESSION['login_intentos'] == 1) {
                        $_SESSION['primer_intento'] = time();
                    }
                }
                
            } catch (Exception $e) {
                // Si hay error en la base de datos, muestro mensaje genérico
                $w_error = "Error técnico";
                // Pero guardo el error real en el log para poder revisarlo después
                error_log("Login error: " . $e->getMessage());
            }
        }
      } // Cierra el else del CSRF
  } // Cierra el if de POST
  
?>
<link rel="stylesheet" href="/erpadso/auth/css/index_auth2.css">
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="img/logo_erp.webp" type="image/webp" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADSO ERP | Ingreso</title>
    
    
   <!-- ANTI-FLASH - Esto evita que se vea el tema claro antes de cargar el oscuro -->
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
</head>
<body>
<div id="view-login" class="active">
  <!-- Botón volver a la página principal (landing) -->
  <a href="/loading.html?redirect=inicio.html" class="back-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
    Volver
  </a>
  <!-- Botón para cambiar tema oscuro/claro -->
  <div class="dark-toggle-fixed">
    <button class="icon-btn" onclick="toggleTheme()" aria-label="Cambiar tema">
      <svg id="dark-icon-login" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
    </button>
  </div>
  <div class="login-wrapper">
    <div class="auth-card">
      <!-- Efectos decorativos de fondo -->
      <div class="auth-blob t"></div>
      <div class="auth-blob b"></div>
      <!-- Logo y título -->
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
      <!-- Formulario de login - onsubmit="doLogin(event)" es para validar en frontend -->
      <form method="POST" onsubmit="return doLogin(event)" novalidate>
        <!-- Campo de usuario -->
        <div class="form-group">
          <label class="form-label">Usuario<span style="color:#ef4444;margin-left:3px">*</span></label>
          <div class="input-wrap">
            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            <input class="form-input" type="text" id="user-input" name="txt_usuario" autocomplete="username" placeholder="usuario" />
          </div>
          <span id="user-msg" class="field-msg"></span> <!-- Aquí se muestran los mensajes de validación en tiempo real -->
        </div>
        <!-- Campo de contraseña - le puse pattern para validar en el navegador -->
        <div class="form-group">
          <label class="form-label">Contraseña<span style="color:#ef4444;margin-left:3px">*</span></label>
          <div class="input-wrap">
            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input  id="pw-input" name="txt_clave" class="form-input has-eye" type="password" 
                    placeholder="••••••••"
                    pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
                    title="Mínimo 8 caracteres: al menos 1 mayúscula, 1 minúscula y 1 número"
                    required>
            <!-- Botón para mostrar/ocultar contraseña -->
            <button type="button" class="pw-toggle" onclick="togglePw()" aria-label="Ver contraseña">
              <svg id="pw-eye" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            </button>
          </div>
          <span id="pw-msg" class="field-msg"></span> <!-- Mensaje de validación de contraseña -->
        </div>
        <!-- Enlace para recuperar contraseña -->
        <div class="remember-row">
          <a href="recuperar.php" class="forgot-link">¿Olvidó su contraseña?</a>
        </div>
        <!-- Campo oculto con el token CSRF - protección contra falsificación -->
        <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
        <!-- Botón de envío -->
        <button type="submit" class="btn-primary" style="margin-bottom:20px">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
          Iniciar Sesión
        </button>
      </form>
    </div>
    <p class="copyright">© 2026 ADSO – </p>
  </div>
</div>
<!-- Archivos JavaScript -->
<script src="js/auth.js"></script> <!-- Validaciones del login en tiempo real -->
 <!-- Protección contra DevTools -->
<script src="/js/theme-sync.js"></script> <!-- Sincroniza el tema oscuro/claro -->
<!-- Script para el ojo de la contraseña (mostrar/ocultar) -->
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
