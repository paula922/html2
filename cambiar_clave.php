<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title = "ADSOERP | Cambiar Contraseña";
$page_description = "Actualización de contraseña del usuario";
$page_icon = "bi-key-fill";
$page_extra_css = [];
$page_extra_js = [];
$show_welcome = false;
// ==========================================

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

if (!isset($_SESSION['id_usuario'])) { 
    header("Location: index.php"); 
    exit(); 
}

$id_usuario = $_SESSION['id_usuario'];
$nom_usuario = $_SESSION['nom_usuario'];

$mensaje = ""; 
$alerta = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $wpass_antigua = $_POST['wpass_antigua'] ?? '';
    $wpass_nueva   = $_POST['wpass_nueva'] ?? '';
    $wpass_confirm  = $_POST['wpass_confirm'] ?? '';

    try {
        if ($wpass_nueva !== $wpass_confirm) {
            $mensaje = "Las contraseñas nuevas no coinciden";
            $alerta = "danger";
        } else {
            $stmt = $pdo->prepare("SELECT pass_usuario FROM tab_usuarios WHERE id_usuario = ?");
            $stmt->execute([$id_usuario]);
            $whash_actual = $stmt->fetchColumn();

            if ($whash_actual && password_verify($wpass_antigua, $whash_actual)) {
                
                $uppercase = preg_match('~[A-Z]~', $wpass_nueva);
                $lowercase = preg_match('~[a-z]~', $wpass_nueva);
                $number    = preg_match('~[0-9]~', $wpass_nueva);
                $special   = preg_match('~[!@#$%^&*()_+\-=\[\]{};":\\|,.<>\/?]~', $wpass_nueva);
                
                if (!$uppercase || !$lowercase || !$number || !$special || strlen($wpass_nueva) < 8) {
                    $mensaje = "La nueva contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial";
                    $alerta = "danger";
                } else {
                    $wnuevo_hash = password_hash($wpass_nueva, PASSWORD_BCRYPT);
                    
                    $stmt = $pdo->prepare("SELECT fun_actualizar_password(CAST(? AS TEXT), CAST(? AS TEXT))");
                    $stmt->execute([$id_usuario, $wnuevo_hash]);
                    $res = $stmt->fetchColumn();
                    
                    if ($res === 'OK') {
                        $mensaje = "¡Contraseña actualizada correctamente!";
                        $alerta = "success";
                    } else {
                        $mensaje = "Error al actualizar: " . $res;
                        $alerta = "danger";
                    }
                }
            } else {
                $mensaje = "La contraseña actual es incorrecta";
                $alerta = "danger";
            }
        }
    } catch (Exception $e) {
        $mensaje = "Error de sistema. Intente más tarde.";
        $alerta = "danger";
        error_log("Error cambiar_clave: " . $e->getMessage());
    }
}
?>

<style>
/* ============================================
   ESTILOS - Cambiar Contraseña
   ============================================ */
.cambiar-clave-container {
    max-width: 500px;
    margin: 0 auto;
    padding: 20px 0;
}

.clave-card {
    background: white;
    border-radius: 24px;
    padding: 32px;
    box-shadow: 0 20px 35px -12px rgba(0,0,0,0.1);
    position: relative;
    overflow: hidden;
}

[data-theme="dark"] .clave-card {
    background: #0f172a;
    box-shadow: 0 20px 35px -12px rgba(0,0,0,0.3);
}

.clave-blob {
    position: absolute;
    border-radius: 50%;
    background: rgba(37,99,235,.05);
    filter: blur(40px);
    pointer-events: none;
}

.clave-blob.t {
    width: 192px;
    height: 192px;
    top: -96px;
    right: -96px;
}

.clave-blob.b {
    width: 192px;
    height: 192px;
    bottom: -96px;
    left: -96px;
}

.clave-logo-wrap {
    width: 70px;
    height: 70px;
    background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
    border-radius: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
    box-shadow: 0 15px 30px rgba(37,99,235,.25);
}

.clave-logo-wrap svg {
    color: white;
    width: 32px;
    height: 32px;
}

.clave-title {
    font-size: 24px;
    font-weight: 800;
    text-align: center;
    color: #1e293b;
    margin-bottom: 8px;
}

[data-theme="dark"] .clave-title {
    color: #f8fafc;
}

.clave-subtitle {
    text-align: center;
    margin-bottom: 28px;
    color: #64748b;
    font-size: 14px;
}

.form-group-clave {
    margin-bottom: 20px;
}

.form-label-clave {
    display: block;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    color: #64748b;
    margin-bottom: 8px;
}

.input-wrap-clave {
    position: relative;
    display: flex;
    align-items: center;
}

.input-icon-clave {
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    width: 18px;
    height: 18px;
    pointer-events: none;
    z-index: 1;
}

.form-input-clave {
    width: 100%;
    padding: 12px 16px 12px 48px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    font-size: 14px;
    color: #1e293b;
    outline: none;
    transition: all .15s;
}

[data-theme="dark"] .form-input-clave {
    background: #1e293b;
    border-color: #334155;
    color: #f8fafc;
}

.form-input-clave:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,.1);
}

.form-input-clave.has-eye {
    padding-right: 48px;
}

.pw-toggle-clave {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    cursor: pointer;
    color: #94a3b8;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    transition: color .15s;
    z-index: 2;
}

.pw-toggle-clave:hover {
    color: #2563eb;
}

.pw-toggle-clave svg {
    width: 18px;
    height: 18px;
}

.field-msg-clave {
    display: block;
    font-size: 11px;
    font-weight: 600;
    margin-top: 6px;
    min-height: 16px;
}

.field-msg-clave.msg-ok {
    color: #10b981;
}

.field-msg-clave.msg-ok::before {
    content: '✓ ';
}

.field-msg-clave.msg-err {
    color: #ef4444;
}

.field-msg-clave.msg-err::before {
    content: '✕ ';
}

.password-requirements-clave {
    background: #f8fafc;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 24px;
    font-size: 12px;
}

[data-theme="dark"] .password-requirements-clave {
    background: #1e293b;
}

.requirement-item-clave {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
    color: #64748b;
}

.requirement-item-clave i {
    width: 16px;
    font-size: 12px;
}

.requirement-item-clave.met {
    color: #10b981;
}

.requirement-item-clave.met i {
    color: #10b981;
}

.requirement-item-clave:last-child {
    margin-bottom: 0;
}

.btn-primary-clave {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
    color: white;
    border: none;
    border-radius: 14px;
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    cursor: pointer;
    transition: all .15s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    box-shadow: 0 10px 20px rgba(37,99,235,.2);
}

.btn-primary-clave:hover {
    transform: translateY(-2px);
    box-shadow: 0 15px 25px rgba(37,99,235,.3);
}

.btn-primary-clave:active {
    transform: scale(.97);
}

.alert-clave {
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 20px;
    font-size: 13px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
}

.alert-clave.alert-success {
    background: #dcfce7;
    color: #15803d;
    border: 1px solid #bbf7d0;
}

[data-theme="dark"] .alert-clave.alert-success {
    background: rgba(16,185,129,.15);
    color: #34d399;
    border-color: rgba(16,185,129,.3);
}

.alert-clave.alert-danger {
    background: #fee2e2;
    color: #b91c1c;
    border: 1px solid #fecaca;
}

[data-theme="dark"] .alert-clave.alert-danger {
    background: rgba(239,68,68,.15);
    color: #f87171;
    border-color: rgba(239,68,68,.3);
}

.copyright-clave {
    text-align: center;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .2em;
    color: #94a3b8;
    margin-top: 20px;
}

@media (max-width: 640px) {
    .cambiar-clave-container {
        padding: 10px;
    }
    .clave-card {
        padding: 24px 20px;
    }
    .clave-title {
        font-size: 20px;
    }
}
</style>

<div class="cambiar-clave-container">
    <div class="clave-card">
        <div class="clave-blob t"></div>
        <div class="clave-blob b"></div>
        
        <div class="clave-logo-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
        </div>
        
        <h2 class="clave-title">Cambiar Contraseña</h2>
        <p class="clave-subtitle"><?= htmlspecialchars($nom_usuario) ?></p>
        
        <?php if ($mensaje): ?>
        <div class="alert-clave alert-<?= $alerta ?>">
            <i class="fas <?= $alerta == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle' ?>"></i>
            <?= htmlspecialchars($mensaje) ?>
        </div>
        <?php endif; ?>
        
        <form method="POST" id="formCambiarClave">
            
            <div class="form-group-clave">
                <label class="form-label-clave">Contraseña actual</label>
                <div class="input-wrap-clave">
                    <svg class="input-icon-clave" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    <input type="password" class="form-input-clave has-eye" id="pass_actual" name="wpass_antigua" placeholder="••••••••" required>
                    <button type="button" class="pw-toggle-clave" onclick="togglePw('pass_actual', 'eye-actual')">
                        <svg id="eye-actual" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
            </div>
            
            <div class="form-group-clave">
                <label class="form-label-clave">Nueva contraseña</label>
                <div class="input-wrap-clave">
                    <svg class="input-icon-clave" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    <input type="password" class="form-input-clave has-eye" id="pass_nueva" name="wpass_nueva" placeholder="••••••••" required>
                    <button type="button" class="pw-toggle-clave" onclick="togglePw('pass_nueva', 'eye-nueva')">
                        <svg id="eye-nueva" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
                <span id="pw-msg" class="field-msg-clave"></span>
            </div>
            
            <div class="form-group-clave">
                <label class="form-label-clave">Confirmar nueva contraseña</label>
                <div class="input-wrap-clave">
                    <svg class="input-icon-clave" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    <input type="password" class="form-input-clave has-eye" id="pass_confirm" name="wpass_confirm" placeholder="••••••••" required>
                    <button type="button" class="pw-toggle-clave" onclick="togglePw('pass_confirm', 'eye-confirm')">
                        <svg id="eye-confirm" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
                <span id="confirm-msg" class="field-msg-clave"></span>
            </div>
            
            <div class="password-requirements-clave" id="passwordRequirements">
                <div class="requirement-item-clave" id="req-length">
                    <i class="fas fa-circle"></i> Mínimo 8 caracteres
                </div>
                <div class="requirement-item-clave" id="req-uppercase">
                    <i class="fas fa-circle"></i> Al menos una mayúscula
                </div>
                <div class="requirement-item-clave" id="req-lowercase">
                    <i class="fas fa-circle"></i> Al menos una minúscula
                </div>
                <div class="requirement-item-clave" id="req-number">
                    <i class="fas fa-circle"></i> Al menos un número
                </div>
                <div class="requirement-item-clave" id="req-special">
                    <i class="fas fa-circle"></i> Al menos un carácter especial (!@#$%^&*)
                </div>
            </div>
            
            <button type="submit" class="btn-primary-clave" id="btnSubmit">
                <i class="fas fa-key"></i>
                Cambiar contraseña
            </button>
        </form>
        
        <p class="copyright-clave">© 2026 ADSOERP</p>
    </div>
</div>

<script>
// ============================================
// JAVASCRIPT - Cambiar Contraseña
// ============================================

function togglePw(inputId, eyeId) {
    const input = document.getElementById(inputId);
    const eye = document.getElementById(eyeId);
    
    if (!input || !eye) return;
    
    if (input.type === 'password') {
        input.type = 'text';
        eye.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>';
    } else {
        input.type = 'password';
        eye.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
    }
}

const passNueva = document.getElementById('pass_nueva');
const passConfirm = document.getElementById('pass_confirm');
const pwMsg = document.getElementById('pw-msg');
const confirmMsg = document.getElementById('confirm-msg');

const reqLength = document.getElementById('req-length');
const reqUppercase = document.getElementById('req-uppercase');
const reqLowercase = document.getElementById('req-lowercase');
const reqNumber = document.getElementById('req-number');
const reqSpecial = document.getElementById('req-special');

function validatePassword(password) {
    const length = password.length >= 8;
    const uppercase = /[A-Z]/.test(password);
    const lowercase = /[a-z]/.test(password);
    const number = /[0-9]/.test(password);
    const special = /[!@#$%^&*()_+\-=\[\]{};":\\|,.<>\/?]/.test(password);
    return { length, uppercase, lowercase, number, special };
}

function updateRequirements(validation) {
    reqLength.classList.toggle('met', validation.length);
    reqLength.querySelector('i').className = validation.length ? 'fas fa-check-circle' : 'fas fa-circle';
    reqUppercase.classList.toggle('met', validation.uppercase);
    reqUppercase.querySelector('i').className = validation.uppercase ? 'fas fa-check-circle' : 'fas fa-circle';
    reqLowercase.classList.toggle('met', validation.lowercase);
    reqLowercase.querySelector('i').className = validation.lowercase ? 'fas fa-check-circle' : 'fas fa-circle';
    reqNumber.classList.toggle('met', validation.number);
    reqNumber.querySelector('i').className = validation.number ? 'fas fa-check-circle' : 'fas fa-circle';
    reqSpecial.classList.toggle('met', validation.special);
    reqSpecial.querySelector('i').className = validation.special ? 'fas fa-check-circle' : 'fas fa-circle';
}

if (passNueva) {
    passNueva.addEventListener('input', function() {
        const validation = validatePassword(this.value);
        updateRequirements(validation);
        
        if (this.value === '') {
            pwMsg.textContent = '';
            pwMsg.className = 'field-msg-clave';
        } else if (validation.length && validation.uppercase && validation.lowercase && validation.number && validation.special) {
            pwMsg.textContent = 'Contraseña válida';
            pwMsg.className = 'field-msg-clave msg-ok';
        } else {
            pwMsg.textContent = 'No cumple los requisitos';
            pwMsg.className = 'field-msg-clave msg-err';
        }
        
        if (passConfirm && passConfirm.value) {
            validateMatch();
        }
    });
}

function validateMatch() {
    if (!passNueva || !passConfirm) return false;
    
    if (passConfirm.value === '') {
        confirmMsg.textContent = '';
        confirmMsg.className = 'field-msg-clave';
        return false;
    } else if (passNueva.value === passConfirm.value) {
        confirmMsg.textContent = 'Las contraseñas coinciden';
        confirmMsg.className = 'field-msg-clave msg-ok';
        return true;
    } else {
        confirmMsg.textContent = 'Las contraseñas no coinciden';
        confirmMsg.className = 'field-msg-clave msg-err';
        return false;
    }
}

if (passConfirm) {
    passConfirm.addEventListener('input', validateMatch);
}

document.getElementById('formCambiarClave').addEventListener('submit', function(e) {
    const validation = validatePassword(passNueva.value);
    const match = passNueva.value === passConfirm.value;
    
    if (!validation.length || !validation.uppercase || !validation.lowercase || !validation.number || !validation.special) {
        e.preventDefault();
        pwMsg.textContent = 'La contraseña no cumple los requisitos';
        pwMsg.className = 'field-msg-clave msg-err';
        passNueva.focus();
    } else if (!match) {
        e.preventDefault();
        confirmMsg.textContent = 'Las contraseñas no coinciden';
        confirmMsg.className = 'field-msg-clave msg-err';
        passConfirm.focus();
    }
});
</script>