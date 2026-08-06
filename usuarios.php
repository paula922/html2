<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title = "ADSOERP | Gestión de Usuarios";
$page_description = "Administración de cuentas y accesos al sistema";
$page_icon = "bi-people-fill";
$page_extra_css = [];
$page_extra_js = [];
$show_welcome = false;
// ==========================================

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

/* ── Variables de estado ── */
$w_mensaje     = "";
$w_tipo_alerta = "success";

/* ── Variables para repoblar el formulario ── */
$f_id          = "";
$f_nom         = "";
$f_mail        = "";
$f_admin       = false;
$f_est         = true;
$f_id_readonly = false;

// ================================================================
// FUNCIONES DE VALIDACIÓN
// ================================================================

function validar_id_usuario(string $id): ?string
{
    if (empty($id)) return "El ID de usuario es obligatorio.";
    if (strlen($id) < 5) return "El ID debe tener mínimo 5 caracteres.";
    if (strlen($id) > 50) return "El ID no puede exceder 50 caracteres.";
    if (!preg_match('/^[a-zA-Z0-9_\-]+$/', $id)) return "El ID solo puede contener letras, números, guiones y guiones bajos.";
    return null;
}

function validar_nombre_usuario(string $nom): ?string
{
    if (empty($nom)) return "El nombre no puede estar vacío.";
    if (strlen($nom) > 100) return "El nombre no puede exceder 100 caracteres.";
    if (!preg_match('/^[\p{L}\p{M}\p{N}\p{Z}\.,\'\-]+$/u', $nom)) return 'El nombre contiene caracteres no permitidos.';
    return null;
}

function validar_correo(string $mail): ?string
{
    if (empty($mail)) return "El correo no puede estar vacío.";
    if (strlen($mail) > 150) return "El correo no puede exceder 150 caracteres.";
    if (!preg_match('/^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/', $mail)) return "El correo no tiene un formato válido.";
    return null;
}

function validar_password(string $pass): ?string
{
    if (empty($pass)) return "La contraseña no puede estar vacía.";
    if (strlen($pass) < 12) return "La contraseña debe tener mínimo 12 caracteres.";
    if (preg_match('/\s/', $pass)) return "La contraseña no puede contener espacios.";
    if (!preg_match('/[A-Z]/', $pass)) return "Debe contener al menos una mayúscula.";
    if (!preg_match('/[a-z]/', $pass)) return "Debe contener al menos una minúscula.";
    if (!preg_match('/[0-9]/', $pass)) return "Debe contener al menos un número.";
    if (!preg_match('/[!@#$%^&*()\-_=+\[\]{}|;:,.<>?\/\\\\~`\'"]/', $pass)) return "Debe contener al menos un símbolo especial.";
    return null;
}

// ================================================================
// PROCESAMIENTO POST
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Obtener parámetros de navegación
    $padre = preg_replace('/[^0-9]/', '', $_POST['_padre'] ?? '');
    $hijo = preg_replace('/[^0-9]/', '', $_POST['_hijo'] ?? '');
    $nieto = preg_replace('/[^0-9]/', '', $_POST['_nieto'] ?? '');
    
    $redirect_url = 'menu_principal.php';
    $params = [];
    if (!empty($padre)) $params[] = 'padre=' . (int)$padre;
    if (!empty($hijo))  $params[] = 'hijo='  . (int)$hijo;
    if (!empty($nieto)) $params[] = 'nieto=' . (int)$nieto;
    if ($params) $redirect_url .= '?' . implode('&', $params);

    try {

        if (isset($_POST['btn_guardar'])) {
            $w_id    = trim($_POST['txt_id_usuario']);
            $w_nom   = trim($_POST['txt_nom_usuario']);
            $w_mail  = trim($_POST['txt_mail_usuario']);
            $w_pass  = $_POST['txt_pass_usuario'];
            $w_admin = isset($_POST['chk_admin'])  ? 1 : 0;
            $w_est   = isset($_POST['chk_estado']) ? 1 : 0;

            $f_id = $w_id; $f_nom = $w_nom; $f_mail = $w_mail;
            $f_admin = (bool)$w_admin; $f_est = (bool)$w_est;

            $err = validar_id_usuario($w_id); if ($err) throw new Exception($err);
            $err = validar_nombre_usuario($w_nom); if ($err) throw new Exception($err);
            $err = validar_correo($w_mail); if ($err) throw new Exception($err);

            // Usar la variable preparada $stmt_check_usuario
            $stmt_check_usuario->execute([$w_id]);
            $existe = $stmt_check_usuario->fetchColumn();

            if ($existe) {
                $f_id_readonly = true;
                if (!empty($w_pass)) {
                    $err = validar_password($w_pass); if ($err) throw new Exception($err);
                    $w_pass_hash = password_hash($w_pass, PASSWORD_BCRYPT);
                    // Usar $stmt_update_usuario_con_pass
                    $stmt_update_usuario_con_pass->execute([$w_nom, $w_pass_hash, $w_mail, $w_admin, $w_est, $w_id]);
                } else {
                    // Usar $stmt_update_usuario_sin_pass
                    $stmt_update_usuario_sin_pass->execute([$w_nom, $w_mail, $w_admin, $w_est, $w_id]);
                }
                $w_mensaje = "✅ Usuario actualizado correctamente.";
                $w_tipo_alerta = "success";
            } else {
                if (empty($w_pass)) throw new Exception("La contraseña es obligatoria.");
                $err = validar_password($w_pass); if ($err) throw new Exception($err);
                $w_pass_hash = password_hash($w_pass, PASSWORD_BCRYPT);
                // Usar $stmt_insert_usuario
                $stmt_insert_usuario->execute([$w_id, $w_nom, $w_pass_hash, $w_mail, $w_admin, $w_est]);
                $w_mensaje = "✅ Usuario registrado correctamente.";
                $w_tipo_alerta = "success";
            }

            // Limpiar formulario
            $f_id = $f_nom = $f_mail = "";
            $f_admin = false; $f_est = true; $f_id_readonly = false;
            
            // Redirigir
            echo "<script>setTimeout(function() { window.location.href = '" . $redirect_url . "'; }, 1500);</script>";
        }

        if (isset($_POST['btn_toggle_estado'])) {
            $w_id_t  = $_POST['hid_id_usuario'];
            $w_est_t = $_POST['hid_nuevo_estado'] === 'true' ? 1 : 0;
            // Usar $stmt_toggle_estado
            $stmt_toggle_estado->execute([$w_est_t, $w_id_t]);
            $w_mensaje = "✅ Estado actualizado correctamente.";
            $w_tipo_alerta = "success";
            echo "<script>setTimeout(function() { window.location.href = '" . $redirect_url . "'; }, 1500);</script>";
        }

    } catch (PDOException $e) {
        $w_mensaje = strpos($e->getMessage(), 'duplicate key') !== false ? "El ID de usuario ya existe." : "Error en BD: " . $e->getMessage();
        $w_tipo_alerta = "danger";
    } catch (Exception $e) {
        $w_mensaje = $e->getMessage();
        $w_tipo_alerta = "danger";
    }
}

// Usar $stmt_list_users del prepare.php
$stmt_list_users->execute();
$usuarios_lista = $stmt_list_users->fetchAll();
?>

<link rel="stylesheet" href="css/usuarios.css">
<div class="crud-usuarios-container">
    <div class="crud-header">
        <div class="crud-title">
            <h2><i class="bi bi-people-fill"></i> Gestión de Usuarios</h2>
            <p>Administración de cuentas y accesos al sistema</p>
        </div>
        <button class="btn-add-usuario" onclick="abrirModal()">
            <i class="bi bi-person-plus-fill"></i> Añadir Usuario
        </button>
    </div>

    <?php if ($w_mensaje): ?>
        <div class="alert alert-<?= $w_tipo_alerta ?> alert-dismissible fade show mb-3">
            <i class="bi <?= $w_tipo_alerta === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill' ?> me-2"></i>
            <?= nl2br(htmlspecialchars($w_mensaje)) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert">&times;</button>
        </div>
    <?php endif; ?>

    <div class="filtros-bar">
        <div class="filtro-search">
            <i class="bi bi-search"></i>
            <input type="text" id="filtro_texto" placeholder="Buscar por usuario, nombre o correo…" oninput="filtrarTabla()">
        </div>
        <div class="filtro-select">
            <select id="filtro_rol" onchange="filtrarTabla()">
                <option value="">Todos los roles</option>
                <option value="admin">Administrador</option>
                <option value="usuario">Usuario</option>
            </select>
        </div>
        <div class="filtro-select">
            <select id="filtro_estado" onchange="filtrarTabla()">
                <option value="">Todos los estados</option>
                <option value="activo">Activo</option>
                <option value="inactivo">Inactivo</option>
            </select>
        </div>
        <span class="filtro-count" id="filtro_count"></span>
    </div>

    <div class="table-container">
        <div class="scroll-lista-custom">
            <table class="table-custom" id="tablaUsuarios">
                <thead>
                    <tr><th>USUARIO</th><th>NOMBRE</th><th>ROL</th><th>ACCIONES</th></tr>
                </thead>
                <tbody>
                    <?php if (count($usuarios_lista) > 0): ?>
                        <?php foreach ($usuarios_lista as $u): ?>
                            <tr class="<?= !$u['ind_estado'] ? 'inactivo' : '' ?>"
                                data-usuario="<?= strtolower(htmlspecialchars($u['id_usuario'])) ?>"
                                data-nombre="<?= strtolower(htmlspecialchars($u['nom_usuario'])) ?>"
                                data-mail="<?= strtolower(htmlspecialchars($u['mail_usuario'])) ?>"
                                data-rol="<?= $u['ind_usuario'] ? 'admin' : 'usuario' ?>"
                                data-estado="<?= $u['ind_estado'] ? 'activo' : 'inactivo' ?>">
                                <td data-label="Usuario">
                                    <strong><?= htmlspecialchars($u['id_usuario']) ?></strong><br>
                                    <small class="text-muted"><?= htmlspecialchars($u['mail_usuario']) ?></small>
                                </td>
                                <td data-label="Nombre"><?= htmlspecialchars($u['nom_usuario']) ?></td>
                                <td data-label="Rol">
                                    <?php if ($u['ind_usuario']): ?>
                                        <span class="badge-admin"><i class="bi bi-shield-lock-fill"></i> Admin</span>
                                    <?php else: ?>
                                        <span class="badge-admin" style="background:#f1f5f9;color:#475569;"><i class="bi bi-person"></i> Usuario</span>
                                    <?php endif; ?>
                                    <div class="mt-1"><span class="badge-estado <?= $u['ind_estado'] ? 'activo' : 'inactivo' ?>"><?= $u['ind_estado'] ? 'ACTIVO' : 'INACTIVO' ?></span></div>
                                </td>
                                <td data-label="Acciones">
                                    <button class="btn-icon edit" onclick="abrirModalEdicion('<?= htmlspecialchars($u['id_usuario']) ?>','<?= addslashes($u['nom_usuario']) ?>','<?= htmlspecialchars($u['mail_usuario']) ?>',<?= $u['ind_usuario'] ? 'true' : 'false' ?>,<?= $u['ind_estado'] ? 'true' : 'false' ?>)" title="Editar"><i class="bi bi-pencil-square"></i></button>
                                    <form method="POST" style="display:inline;">
                                        <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                                        <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                                        <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">
                                        <input type="hidden" name="hid_id_usuario" value="<?= htmlspecialchars($u['id_usuario']) ?>">
                                        <input type="hidden" name="hid_nuevo_estado" value="<?= $u['ind_estado'] ? 'false' : 'true' ?>">
                                        <button type="submit" name="btn_toggle_estado" class="btn-icon <?= $u['ind_estado'] ? 'toggle-inactive' : 'toggle-active' ?>" title="<?= $u['ind_estado'] ? 'Desactivar' : 'Activar' ?>"><i class="bi <?= $u['ind_estado'] ? 'bi-lock-fill' : 'bi-check-circle-fill' ?>"></i></button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <tr><td colspan="4" class="text-center py-4 text-muted"><i class="bi bi-inbox" style="font-size:2rem;"></i><p class="mt-2">No hay usuarios registrados</p></td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <div class="paginacion-bar">
            <span class="paginacion-info" id="pag_info"></span>
            <div class="paginacion-btns" id="pag_btns"></div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="bi bi-person-plus-fill"></i> Nuevo Usuario</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-card-body">
            <form method="POST" id="formUsuarios">
                <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">

                <div class="mb-3">
                    <label class="form-label-custom">ID USUARIO</label>
                    <input type="text" name="txt_id_usuario" id="f_id" class="form-control-sm" placeholder="Ej: jperez" required style="font-family:monospace;" value="<?= htmlspecialchars($f_id) ?>" <?= $f_id_readonly ? 'readonly' : '' ?>>
                    <div id="val_id" class="val-feedback"></div>
                    <small class="text-muted">Identificador único de inicio de sesión</small>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">NOMBRE COMPLETO</label>
                    <input type="text" name="txt_nom_usuario" id="f_nom" class="form-control-sm" placeholder="Nombre del usuario" required value="<?= htmlspecialchars($f_nom) ?>">
                    <div id="val_nom" class="val-feedback"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">CORREO ELECTRÓNICO</label>
                    <input type="email" name="txt_mail_usuario" id="f_mail" class="form-control-sm" placeholder="usuario@empresa.com" required value="<?= htmlspecialchars($f_mail) ?>">
                    <div id="val_mail" class="val-feedback"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">CONTRASEÑA</label>
                    <div class="pass-wrapper">
                        <input type="password" name="txt_pass_usuario" id="f_pass" class="form-control-sm" placeholder="••••••••">
                        <button type="button" class="btn-toggle-pass" onclick="togglePass()"><i class="bi bi-eye" id="icon_pass"></i></button>
                    </div>
                    <div id="val_pass" class="val-feedback"></div>
                    <small class="text-muted">Dejar vacío para mantener la actual (en edición)</small>
                </div>

                <div class="mb-3">
                    <div class="form-check-custom">
                        <input type="checkbox" name="chk_admin" id="f_adm" class="form-check-input" <?= $f_admin ? 'checked' : '' ?>>
                        <label class="form-check-label">Administrador del sistema</label>
                    </div>
                    <div class="form-check-custom">
                        <input type="checkbox" name="chk_estado" id="f_est" class="form-check-input" <?= $f_est ? 'checked' : '' ?>>
                        <label class="form-check-label">Usuario habilitado</label>
                    </div>
                </div>

                <button type="submit" name="btn_guardar" class="btn-guardar"><i class="bi bi-save me-1"></i> GUARDAR</button>
                <button type="button" onclick="limpiarFormulario()" class="btn-nuevo"><i class="bi bi-arrow-counterclockwise me-1"></i> LIMPIAR</button>
            </form>
        </div>
    </div>
</div>

<script>
// ================================================================
// JAVASCRIPT - Gestión de Usuarios (IGUAL que antes)
// ================================================================

const USUARIOS_POR_PAGINA = 6;
let hasChanges = false;
let paginaActual = 1;
let filasFiltradas = [];

function abrirModal() {
    limpiarFormulario();
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-person-plus-fill"></i> Nuevo Usuario';
    document.getElementById('modalOverlay').classList.add('show');
    document.body.style.overflow = 'hidden';
}

function abrirModalEdicion(id, nom, mail, adm, est) {
    qbe(id, nom, mail, adm, est);
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-pencil-square"></i> Editar Usuario';
    document.getElementById('modalOverlay').classList.add('show');
    document.body.style.overflow = 'hidden';
}

function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('show');
    document.body.style.overflow = '';
}

function cerrarModalSiOverlay(event) {
    if (event.target === document.getElementById('modalOverlay')) cerrarModal();
}

function togglePass() {
    const input = document.getElementById('f_pass');
    const icon = document.getElementById('icon_pass');
    if (input.type === 'password') { input.type = 'text'; icon.className = 'bi bi-eye-slash'; }
    else { input.type = 'password'; icon.className = 'bi bi-eye'; }
}

function filtrarTabla() {
    const texto = document.getElementById('filtro_texto').value.toLowerCase().trim();
    const rol = document.getElementById('filtro_rol').value;
    const estado = document.getElementById('filtro_estado').value;
    const todasLasFilas = Array.from(document.querySelectorAll('#tablaUsuarios tbody tr:not(.no-results-row)'));
    
    filasFiltradas = todasLasFilas.filter(fila => {
        const fUsuario = fila.dataset.usuario || '';
        const fNombre = fila.dataset.nombre || '';
        const fMail = fila.dataset.mail || '';
        const fRol = fila.dataset.rol || '';
        const fEstado = fila.dataset.estado || '';
        const ok = (!texto || fUsuario.includes(texto) || fNombre.includes(texto) || fMail.includes(texto)) && (!rol || fRol === rol) && (!estado || fEstado === estado);
        fila.style.display = ok ? '' : 'none';
        return ok;
    });
    
    const totalVisibles = filasFiltradas.length;
    const countEl = document.getElementById('filtro_count');
    const total = document.querySelectorAll('#tablaUsuarios tbody tr[data-usuario]').length;
    if (countEl) countEl.textContent = totalVisibles + ' de ' + total + ' usuarios';
    
    document.querySelectorAll('.no-results-row').forEach(r => r.remove());
    if (totalVisibles === 0) {
        const tbody = document.querySelector('#tablaUsuarios tbody');
        const tr = document.createElement('tr');
        tr.className = 'no-results-row';
        tr.innerHTML = '<td colspan="4"><i class="bi bi-search" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;"></i>No se encontraron usuarios con esos filtros</td>';
        tbody.appendChild(tr);
    }
    paginaActual = 1;
    aplicarPaginacion();
}

function aplicarPaginacion() {
    const totalFiltradas = filasFiltradas.length;
    const totalPaginas = Math.max(1, Math.ceil(totalFiltradas / USUARIOS_POR_PAGINA));
    if (paginaActual > totalPaginas) paginaActual = totalPaginas;
    const inicio = (paginaActual - 1) * USUARIOS_POR_PAGINA;
    const fin = inicio + USUARIOS_POR_PAGINA;
    
    filasFiltradas.forEach((fila, idx) => { fila.style.display = (idx >= inicio && idx < fin) ? '' : 'none'; });
    
    const infoEl = document.getElementById('pag_info');
    if (infoEl && totalFiltradas > 0) infoEl.textContent = `Mostrando ${inicio + 1}–${Math.min(fin, totalFiltradas)} de ${totalFiltradas} usuario${totalFiltradas !== 1 ? 's' : ''}`;
    else if (infoEl) infoEl.textContent = '';
    
    renderBotonesPaginacion(totalPaginas);
}

function renderBotonesPaginacion(totalPaginas) {
    const contenedor = document.getElementById('pag_btns');
    if (!contenedor) return;
    contenedor.innerHTML = '';
    
    const btnPrev = crearBtnPag('‹', paginaActual === 1, () => { if (paginaActual > 1) { paginaActual--; aplicarPaginacion(); } });
    contenedor.appendChild(btnPrev);
    
    const rango = calcularRango(paginaActual, totalPaginas, 5);
    rango.forEach(num => {
        if (num === '...') {
            const span = document.createElement('span');
            span.textContent = '...';
            span.style.cssText = 'color:#94a3b8;padding:0 4px;';
            contenedor.appendChild(span);
        } else {
            const btn = crearBtnPag(num, false, () => { paginaActual = num; aplicarPaginacion(); });
            if (num === paginaActual) btn.classList.add('activa');
            contenedor.appendChild(btn);
        }
    });
    
    const btnNext = crearBtnPag('›', paginaActual === totalPaginas, () => { if (paginaActual < totalPaginas) { paginaActual++; aplicarPaginacion(); } });
    contenedor.appendChild(btnNext);
}

function crearBtnPag(label, disabled, onClick) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn-pag';
    btn.textContent = label;
    btn.disabled = disabled;
    if (!disabled) btn.addEventListener('click', onClick);
    return btn;
}

function calcularRango(actual, total, maxVisible) {
    if (total <= maxVisible) return Array.from({ length: total }, (_, i) => i + 1);
    const mitad = Math.floor(maxVisible / 2);
    let inicio = Math.max(1, actual - mitad);
    let fin = inicio + maxVisible - 1;
    if (fin > total) { fin = total; inicio = Math.max(1, fin - maxVisible + 1); }
    const rango = [];
    if (inicio > 1) { rango.push(1); if (inicio > 2) rango.push('...'); }
    for (let i = inicio; i <= fin; i++) rango.push(i);
    if (fin < total) { if (fin < total - 1) rango.push('...'); rango.push(total); }
    return rango;
}

function qbe(id, nom, mail, adm, est) {
    document.querySelectorAll('.alert').forEach(a => a.remove());
    document.getElementById('f_id').value = id;
    document.getElementById('f_id').readOnly = true;
    document.getElementById('f_nom').value = nom;
    document.getElementById('f_mail').value = mail;
    document.getElementById('f_adm').checked = adm;
    document.getElementById('f_est').checked = est;
    document.getElementById('f_pass').value = '';
    document.getElementById('f_pass').type = 'password';
    document.getElementById('icon_pass').className = 'bi bi-eye';
    limpiarValidaciones();
    hasChanges = false;
}

function limpiarFormulario() {
    document.querySelectorAll('.alert').forEach(a => a.remove());
    document.getElementById('f_id').value = '';
    document.getElementById('f_id').readOnly = false;
    document.getElementById('f_nom').value = '';
    document.getElementById('f_mail').value = '';
    document.getElementById('f_adm').checked = false;
    document.getElementById('f_est').checked = true;
    document.getElementById('f_pass').value = '';
    document.getElementById('f_pass').type = 'password';
    document.getElementById('icon_pass').className = 'bi bi-eye';
    limpiarValidaciones();
    hasChanges = false;
}

function limpiarValidaciones() {
    ['f_id', 'f_nom', 'f_mail', 'f_pass'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.remove('input-ok', 'input-err');
    });
    ['val_id', 'val_nom', 'val_mail', 'val_pass'].forEach(id => {
        const box = document.getElementById(id);
        if (box) { box.classList.remove('visible'); box.innerHTML = ''; }
    });
}

function setInputState(input, isOk) {
    input.classList.toggle('input-ok', isOk);
    input.classList.toggle('input-err', !isOk);
}

function renderFeedback(containerId, reglas) {
    const box = document.getElementById(containerId);
    if (!box) return false;
    if (!reglas.length || reglas.every(r => r.texto === '')) {
        box.classList.remove('visible');
        box.innerHTML = '';
        return false;
    }
    const allOk = reglas.every(r => r.ok);
    box.innerHTML = reglas.map(r => `<div class="val-item ${r.ok ? 'ok' : 'err'}"><i class="bi ${r.ok ? 'bi-check-circle-fill' : 'bi-x-circle-fill'} vi"></i><span>${r.texto}</span></div>`).join('');
    box.classList.add('visible');
    return allOk;
}

function clearField(input, feedbackId) {
    input.classList.remove('input-ok', 'input-err');
    const box = document.getElementById(feedbackId);
    if (box) { box.classList.remove('visible'); box.innerHTML = ''; }
}

document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('keydown', e => { if (e.key === 'Escape') cerrarModal(); });
    document.addEventListener('input', e => { if (['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) hasChanges = true; });
    document.addEventListener('submit', () => hasChanges = false);
    
    const alerta = document.querySelector('.alert');
    if (alerta) setTimeout(() => { alerta.classList.remove('show'); setTimeout(() => alerta.remove(), 300); }, 5000);
    
    filtrarTabla();
    
    document.getElementById('f_id').addEventListener('input', function() {
        if (this.readOnly) return;
        const v = this.value;
        if (v === '') { clearField(this, 'val_id'); return; }
        setInputState(this, renderFeedback('val_id', [
            { texto: 'No debe estar vacío', ok: v.trim() !== '' },
            { texto: 'Sin espacios', ok: !/\s/.test(v) },
            { texto: 'Sin caracteres * o "', ok: !/[*"]/.test(v) }
        ]));
    });
    
    document.getElementById('f_nom').addEventListener('input', function() {
        const v = this.value;
        if (v === '') { clearField(this, 'val_nom'); return; }
        setInputState(this, renderFeedback('val_nom', [
            { texto: 'No debe estar vacío', ok: v.trim() !== '' },
            { texto: 'Sin caracteres * o "', ok: !/[*"]/.test(v) }
        ]));
    });
    
    document.getElementById('f_mail').addEventListener('input', function() {
        const v = this.value;
        if (v === '') { clearField(this, 'val_mail'); return; }
        const emailReg = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/;
        setInputState(this, renderFeedback('val_mail', [
            { texto: 'Debe contener @', ok: v.includes('@') },
            { texto: 'Debe tener dominio', ok: v.includes('@') && v.split('@')[1]?.includes('.') },
            { texto: 'Formato válido', ok: emailReg.test(v) }
        ]));
    });
    
    document.getElementById('f_pass').addEventListener('input', function() {
        const v = this.value;
        if (v === '') { clearField(this, 'val_pass'); return; }
        const simbolos = /[!@#$%^&*()\-_=+\[\]{}|;:,.<>?\/\\~`'"]/;
        setInputState(this, renderFeedback('val_pass', [
            { texto: 'Mínimo 12 caracteres', ok: v.length >= 12 },
            { texto: 'Sin espacios', ok: !/\s/.test(v) },
            { texto: 'Al menos una mayúscula', ok: /[A-Z]/.test(v) },
            { texto: 'Al menos una minúscula', ok: /[a-z]/.test(v) },
            { texto: 'Al menos un número', ok: /[0-9]/.test(v) },
            { texto: 'Al menos un símbolo', ok: simbolos.test(v) }
        ]));
    });
});

window.addEventListener('beforeunload', e => { if (hasChanges) { e.preventDefault(); e.returnValue = ''; } });
</script>