<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title = "ADSOERP | Gestión de Áreas";
$page_description = "Administración de áreas de la empresa";
$page_icon = "bi-diagram-3";
$page_extra_css = [];
$page_extra_js = [];
$show_welcome = false;
// ==========================================

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

$w_mensaje = "";
$w_tipo_alerta = "success";
$js_redirect = "";

$f_id_area = "";
$f_nom_area = "";
$f_descrip = "";
$f_id_responsable = "";
$f_mail_area = "";
$f_tel_oficina = "";
$f_ubi_oficina = "";
$f_horario = "";
$f_estado = true;

// Cargar usuarios responsables
$stmt_usuarios = $pdo->query("SELECT id_usuario, nom_usuario FROM tab_usuarios WHERE ind_borrado = 'f' ORDER BY nom_usuario");
$usuarios = $stmt_usuarios->fetchAll();

// Obtener siguiente ID (secuencia manual)
$stmt_seq = $pdo->query("SELECT COALESCE(MAX(id_area), 0) + 1 as next_id FROM tab_areas");
$next_id = $stmt_seq->fetchColumn();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $redirect_url = 'menu_principal.php';
    $params = [];
    if (!empty($_POST['_padre'])) $params[] = 'padre=' . (int) $_POST['_padre'];
    if (!empty($_POST['_hijo']))  $params[] = 'hijo='  . (int) $_POST['_hijo'];
    if (!empty($_POST['_nieto'])) $params[] = 'nieto=' . (int) $_POST['_nieto'];
    if ($params) $redirect_url .= '?' . implode('&', $params);

    try {
        if (isset($_POST['btn_guardar'])) {
            $w_id_area = $_POST['txt_id_area'] ?? '';
            $w_nom_area = trim($_POST['txt_nom_area']);
            $w_descrip = trim($_POST['txt_descrip'] ?? '');
            $w_id_responsable = !empty($_POST['sel_responsable']) ? $_POST['sel_responsable'] : null;
            $w_mail_area = trim($_POST['txt_mail_area'] ?? '');
            $w_tel_oficina = !empty($_POST['txt_tel_oficina']) ? $_POST['txt_tel_oficina'] : null;
            $w_ubi_oficina = trim($_POST['txt_ubi_oficina'] ?? '');
            $w_horario = trim($_POST['txt_horario'] ?? '');
            $w_estado = isset($_POST['chk_estado']) ? 1 : 0;

            // Validaciones
            if (empty($w_nom_area)) throw new Exception("El nombre del área es obligatorio.");
            if (strlen($w_nom_area) < 3) throw new Exception("El nombre debe tener mínimo 3 caracteres.");
            if ($w_mail_area && !filter_var($w_mail_area, FILTER_VALIDATE_EMAIL)) throw new Exception("Email no válido.");

            if (!empty($w_id_area)) {
                // Actualizar
                $stmt = $pdo->prepare("UPDATE tab_areas SET nom_area = ?, descrip_area = ?, id_responsable = ?, mail_area = ?, tel_oficina = ?, ubi_oficina = ?, horario_atencion = ?, ind_estado = ? WHERE id_area = ?");
                $stmt->execute([$w_nom_area, $w_descrip, $w_id_responsable, $w_mail_area, $w_tel_oficina, $w_ubi_oficina, $w_horario, $w_estado, $w_id_area]);
                $w_mensaje = "Área actualizada correctamente.";
            } else {
                // Insertar nuevo
                $stmt = $pdo->prepare("INSERT INTO tab_areas (id_area, nom_area, descrip_area, id_responsable, mail_area, tel_oficina, ubi_oficina, horario_atencion, ind_estado, ind_borrado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'f')");
                $stmt->execute([$next_id, $w_nom_area, $w_descrip, $w_id_responsable, $w_mail_area, $w_tel_oficina, $w_ubi_oficina, $w_horario, $w_estado]);
                $w_mensaje = "Área registrada correctamente.";
            }

            $w_tipo_alerta = "success";
            $js_redirect = $redirect_url;
        }

        if (isset($_POST['btn_toggle_estado'])) {
            $w_id = $_POST['hid_id_area'];
            $w_nuevo_estado = $_POST['hid_nuevo_estado'] === 'true' ? 1 : 0;
            $stmt = $pdo->prepare("UPDATE tab_areas SET ind_estado = ? WHERE id_area = ?");
            $stmt->execute([$w_nuevo_estado, $w_id]);
            $w_mensaje = "Estado actualizado correctamente.";
            $w_tipo_alerta = "success";
            $js_redirect = $redirect_url;
        }

    } catch (Exception $e) {
        $w_mensaje = $e->getMessage();
        $w_tipo_alerta = "danger";
    }
}

// Cargar áreas
$stmt = $pdo->query("
    SELECT a.*, u.nom_usuario as responsable_nombre 
    FROM tab_areas a 
    LEFT JOIN tab_usuarios u ON a.id_responsable = u.id_usuario 
    WHERE a.ind_borrado = 'f'
    ORDER BY a.id_area
");
$areas = $stmt->fetchAll();
?>

<link rel="stylesheet" href="css/usuarios.css">

<style>
/* Estilos específicos para Áreas */
.crud-container {
    background: white;
    border-radius: 20px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.crud-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
    gap: 1rem;
}

.crud-title h2 {
    font-size: 1.5rem;
    font-weight: 700;
    margin: 0;
    color: #1e293b;
}

.crud-title p {
    margin: 0.25rem 0 0;
    color: #64748b;
    font-size: 0.85rem;
}

.btn-add {
    background: linear-gradient(135deg, #00d9ff, #0099cc);
    color: white;
    border: none;
    padding: 0.6rem 1.2rem;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    transition: all 0.2s;
}

.btn-add:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,217,255,0.3);
}

.table-responsive {
    overflow-x: auto;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
}

.table-custom {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.85rem;
}

.table-custom th {
    text-align: left;
    padding: 1rem;
    background: #f8fafc;
    font-weight: 600;
    color: #1e293b;
    border-bottom: 1px solid #e2e8f0;
}

.table-custom td {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #f1f5f9;
    vertical-align: middle;
}

.table-custom tr:hover {
    background: #f8fafc;
}

.table-custom tr.inactivo {
    background: #fef2f2;
    opacity: 0.7;
}

.badge-estado {
    padding: 0.25rem 0.75rem;
    border-radius: 30px;
    font-size: 0.7rem;
    font-weight: 600;
}

.badge-estado.activo {
    background: #dcfce7;
    color: #166534;
}

.badge-estado.inactivo {
    background: #fee2e2;
    color: #991b1b;
}

/* Botones de acción */
.btn-icon {
    background: none;
    border: none;
    padding: 0.4rem;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
    margin: 0 2px;
}

.btn-icon.edit {
    color: #3b82f6;
}

.btn-icon.edit:hover {
    background: #eff6ff;
    transform: scale(1.05);
}

.btn-icon.delete {
    color: #ef4444;
}

.btn-icon.delete:hover {
    background: #fef2f2;
    transform: scale(1.05);
}

.btn-icon.toggle-active {
    color: #10b981;
}

.btn-icon.toggle-inactive {
    color: #ef4444;
}

.btn-icon.toggle-active:hover,
.btn-icon.toggle-inactive:hover {
    background: #f1f5f9;
    transform: scale(1.05);
}

/* Modal */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(4px);
    z-index: 10000;
    display: none;
    align-items: center;
    justify-content: center;
}

.modal-overlay.show {
    display: flex;
    animation: modalFadeIn 0.2s ease;
}

@keyframes modalFadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-card {
    background: white;
    border-radius: 24px;
    width: 90%;
    max-width: 600px;
    max-height: 85vh;
    overflow-y: auto;
    box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
    animation: modalSlideIn 0.3s cubic-bezier(0.34, 1.2, 0.64, 1);
}

@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: scale(0.95) translateY(-20px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

.modal-card-header {
    padding: 1.25rem 1.5rem;
    background: linear-gradient(135deg, #1a1a2e, #16213e);
    color: white;
    border-radius: 24px 24px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
}

.modal-card-header span {
    font-weight: 600;
    font-size: 1.1rem;
}

.modal-close-btn {
    background: none;
    border: none;
    color: white;
    font-size: 1.2rem;
    cursor: pointer;
    padding: 0.25rem;
    border-radius: 8px;
    transition: all 0.2s;
}

.modal-close-btn:hover {
    background: rgba(255,255,255,0.2);
}

.modal-card-body {
    padding: 1.5rem;
}

.form-label-custom {
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: #64748b;
    margin-bottom: 0.5rem;
    display: block;
}

.form-control-sm {
    width: 100%;
    padding: 0.6rem 0.75rem;
    border: 1px solid #cbd5e1;
    border-radius: 12px;
    font-size: 0.85rem;
    transition: all 0.2s;
}

.form-control-sm:focus {
    outline: none;
    border-color: #00d9ff;
    box-shadow: 0 0 0 3px rgba(0,217,255,0.1);
}

textarea.form-control-sm {
    resize: vertical;
    font-family: inherit;
}

.form-check-custom {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin: 0.5rem 0;
}

.form-check-custom input {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: #00d9ff;
}

.form-check-custom label {
    cursor: pointer;
    font-size: 0.85rem;
    color: #334155;
}

.btn-guardar {
    background: linear-gradient(135deg, #00d9ff, #0099cc);
    color: white;
    border: none;
    padding: 0.7rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    width: 100%;
    transition: all 0.2s;
}

.btn-guardar:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,217,255,0.3);
}

.btn-nuevo {
    background: #f1f5f9;
    color: #475569;
    border: none;
    padding: 0.7rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    width: 100%;
    margin-top: 0.75rem;
    transition: all 0.2s;
}

.btn-nuevo:hover {
    background: #e2e8f0;
}

.row {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
}

.row .col {
    flex: 1;
}

.mb-3 {
    margin-bottom: 1rem;
}

.alert {
    padding: 0.75rem 1rem;
    border-radius: 12px;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.alert-success {
    background: #dcfce7;
    color: #166534;
    border: 1px solid #bbf7d0;
}

.alert-danger {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #fecaca;
}

.alert .btn-close {
    margin-left: auto;
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    opacity: 0.7;
}

.alert .btn-close:hover {
    opacity: 1;
}

/* Filtros */
.filtros-bar {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
    align-items: center;
}

.filtro-search {
    position: relative;
    flex: 1;
    max-width: 300px;
}

.filtro-search i {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
}

.filtro-search input {
    width: 100%;
    padding: 0.5rem 0.75rem 0.5rem 2rem;
    border: 1px solid #e2e8f0;
    border-radius: 30px;
    font-size: 0.85rem;
}

.filtro-search input:focus {
    outline: none;
    border-color: #00d9ff;
}

.filtro-select select {
    padding: 0.5rem 1rem;
    border: 1px solid #e2e8f0;
    border-radius: 30px;
    font-size: 0.85rem;
    background: white;
    cursor: pointer;
}

.filtro-count {
    font-size: 0.75rem;
    color: #64748b;
    background: #f1f5f9;
    padding: 0.25rem 0.75rem;
    border-radius: 30px;
}
</style>

<div class="crud-container">
    <div class="crud-header">
        <div class="crud-title">
            <h2><i class="bi bi-diagram-3" style="color:#00d9ff;"></i> Gestión de Áreas</h2>
            <p>Administración de áreas de la empresa</p>
        </div>
        <button class="btn-add" onclick="abrirModal()">
            <i class="bi bi-plus-circle"></i> Añadir Área
        </button>
    </div>

    <?php if ($w_mensaje): ?>
        <div class="alert alert-<?= $w_tipo_alerta == 'success' ? 'success' : 'danger' ?> alert-dismissible fade show mb-3">
            <i class="bi <?= $w_tipo_alerta == 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill' ?>"></i>
            <?= htmlspecialchars($w_mensaje) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar">&times;</button>
        </div>
    <?php endif; ?>

    <!-- Filtros -->
    <div class="filtros-bar">
        <div class="filtro-search">
            <i class="bi bi-search"></i>
            <input type="text" id="filtro_texto" placeholder="Buscar por nombre, responsable o email..." onkeyup="filtrarTabla()">
        </div>
        <div class="filtro-select">
            <select id="filtro_estado" onchange="filtrarTabla()">
                <option value="">Todos los estados</option>
                <option value="activo">Activos</option>
                <option value="inactivo">Inactivos</option>
            </select>
        </div>
        <span class="filtro-count" id="filtro_count"></span>
    </div>

    <div class="table-responsive">
        <table class="table-custom" id="tablaAreas">
            <thead>
                <tr>
                    <th style="width:8%">ID</th>
                    <th style="width:22%">ÁREA</th>
                    <th style="width:18%">RESPONSABLE</th>
                    <th style="width:22%">EMAIL</th>
                    <th style="width:12%">TELÉFONO</th>
                    <th style="width:8%">ESTADO</th>
                    <th style="width:10%">ACCIONES</th>
                </tr>
            </thead>
            <tbody>
                <?php if (count($areas) > 0): ?>
                    <?php foreach ($areas as $a): ?>
                        <tr data-nombre="<?= strtolower(htmlspecialchars($a['nom_area'])) ?>"
                            data-responsable="<?= strtolower(htmlspecialchars($a['responsable_nombre'] ?? '')) ?>"
                            data-email="<?= strtolower(htmlspecialchars($a['mail_area'] ?? '')) ?>"
                            data-estado="<?= $a['ind_estado'] ? 'activo' : 'inactivo' ?>">
                            
                            <td><?= htmlspecialchars($a['id_area']) ?></td>
                            <td><strong><?= htmlspecialchars($a['nom_area']) ?></strong></td>
                            <td><?= htmlspecialchars($a['responsable_nombre'] ?? '-') ?></td>
                            <td><?= htmlspecialchars($a['mail_area'] ?? '-') ?></td>
                            <td><?= htmlspecialchars($a['tel_oficina'] ?? '-') ?></td>
                            <td>
                                <span class="badge-estado <?= $a['ind_estado'] ? 'activo' : 'inactivo' ?>">
                                    <?= $a['ind_estado'] ? 'ACTIVO' : 'INACTIVO' ?>
                                </span>
                            </td>
                            <td>
                                <button class="btn-icon edit" onclick='abrirModalEdicion(<?= json_encode($a) ?>)' title="Editar">
                                    <i class="bi bi-pencil-square"></i>
                                </button>
                                <form method="POST" style="display:inline;">
                                    <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                                    <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                                    <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">
                                    <input type="hidden" name="hid_id_area" value="<?= $a['id_area'] ?>">
                                    <input type="hidden" name="hid_nuevo_estado" value="<?= $a['ind_estado'] ? 'false' : 'true' ?>">
                                    <button type="submit" name="btn_toggle_estado" class="btn-icon <?= $a['ind_estado'] ? 'toggle-inactive' : 'toggle-active' ?>" title="<?= $a['ind_estado'] ? 'Desactivar' : 'Activar' ?>">
                                        <i class="bi <?= $a['ind_estado'] ? 'bi-lock-fill' : 'bi-check-circle-fill' ?>"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php else: ?>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">
                            <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                            <p class="mt-2 mb-0">No hay áreas registradas</p>
                        </td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="bi bi-diagram-3"></i> Nueva Área</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-card-body">
            <form method="POST" id="formArea">
                <input type="hidden" name="txt_id_area" id="f_id" value="">
                <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">

                <div class="mb-3">
                    <label class="form-label-custom">NOMBRE DEL ÁREA *</label>
                    <input type="text" name="txt_nom_area" id="f_nom" class="form-control-sm" required placeholder="Ej: Recursos Humanos">
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">DESCRIPCIÓN</label>
                    <textarea name="txt_descrip" id="f_descrip" class="form-control-sm" rows="3" placeholder="Descripción de las funciones del área..."></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">RESPONSABLE</label>
                    <select name="sel_responsable" id="f_responsable" class="form-control-sm">
                        <option value="">-- Seleccionar responsable --</option>
                        <?php foreach($usuarios as $u): ?>
                            <option value="<?= $u['id_usuario'] ?>"><?= htmlspecialchars($u['nom_usuario']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">EMAIL CORPORATIVO</label>
                    <input type="email" name="txt_mail_area" id="f_mail" class="form-control-sm" placeholder="area@empresa.com">
                </div>

                <div class="row">
                    <div class="col">
                        <label class="form-label-custom">TELÉFONO</label>
                        <input type="text" name="txt_tel_oficina" id="f_tel" class="form-control-sm" placeholder="(601) 123-4567">
                    </div>
                    <div class="col">
                        <label class="form-label-custom">UBICACIÓN</label>
                        <input type="text" name="txt_ubi_oficina" id="f_ubi" class="form-control-sm" placeholder="Edificio, piso, oficina">
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">HORARIO DE ATENCIÓN</label>
                    <input type="text" name="txt_horario" id="f_horario" class="form-control-sm" placeholder="Lunes a Viernes 8am - 5pm">
                </div>

                <div class="mb-3">
                    <div class="form-check-custom">
                        <input type="checkbox" name="chk_estado" id="f_est" checked>
                        <label>Área activa</label>
                    </div>
                </div>

                <button type="submit" name="btn_guardar" class="btn-guardar">
                    <i class="bi bi-save"></i> GUARDAR
                </button>
                <button type="button" onclick="limpiarFormulario()" class="btn-nuevo">
                    <i class="bi bi-arrow-counterclockwise"></i> LIMPIAR
                </button>
            </form>
        </div>
    </div>
</div>

<script>
// Variables para paginación
let pagActualAreas = 1;
let filasFiltradasAreas = [];
const POR_PAGINA_AREAS = 15;

// Filtrar tabla
function filtrarTabla() {
    const texto = document.getElementById('filtro_texto').value.toLowerCase().trim();
    const estado = document.getElementById('filtro_estado').value;
    const tbody = document.querySelector('#tablaAreas tbody');
    if (!tbody) return;
    
    const filas = Array.from(tbody.querySelectorAll('tr'));
    let contador = 0;
    
    filas.forEach(tr => {
        if (tr.querySelector('td[colspan]')) return;
        
        const nombre = tr.dataset.nombre || '';
        const responsable = tr.dataset.responsable || '';
        const email = tr.dataset.email || '';
        const rowEstado = tr.dataset.estado || '';
        
        const matchTexto = !texto || nombre.includes(texto) || responsable.includes(texto) || email.includes(texto);
        const matchEstado = !estado || rowEstado === estado;
        
        if (matchTexto && matchEstado) {
            tr.style.display = '';
            contador++;
        } else {
            tr.style.display = 'none';
        }
    });
    
    document.getElementById('filtro_count').innerText = `${contador} área${contador !== 1 ? 's' : ''}`;
}

// Modal functions
function abrirModal() {
    document.getElementById('modalOverlay').classList.add('show');
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-diagram-3"></i> Nueva Área';
    document.getElementById('formArea').reset();
    document.getElementById('f_id').value = '';
    document.getElementById('f_est').checked = true;
}

function abrirModalEdicion(a) {
    document.getElementById('modalOverlay').classList.add('show');
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-pencil-square"></i> Editar Área';
    document.getElementById('f_id').value = a.id_area;
    document.getElementById('f_nom').value = a.nom_area;
    document.getElementById('f_descrip').value = a.descrip_area || '';
    document.getElementById('f_responsable').value = a.id_responsable || '';
    document.getElementById('f_mail').value = a.mail_area || '';
    document.getElementById('f_tel').value = a.tel_oficina || '';
    document.getElementById('f_ubi').value = a.ubi_oficina || '';
    document.getElementById('f_horario').value = a.horario_atencion || '';
    document.getElementById('f_est').checked = a.ind_estado;
}

function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('show');
}

function cerrarModalSiOverlay(e) {
    if (e.target === document.getElementById('modalOverlay')) cerrarModal();
}

function limpiarFormulario() {
    document.getElementById('formArea').reset();
    document.getElementById('f_id').value = '';
    document.getElementById('f_est').checked = true;
}

// Inicializar contador
document.addEventListener('DOMContentLoaded', () => {
    const total = document.querySelectorAll('#tablaAreas tbody tr:not([style*="display: none"])').length;
    document.getElementById('filtro_count').innerText = `${total} área${total !== 1 ? 's' : ''}`;
});

// Cerrar modal con ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') cerrarModal();
});

// Cerrar alertas
document.querySelectorAll('.alert .btn-close').forEach(btn => {
    btn.addEventListener('click', () => {
        btn.closest('.alert').remove();
    });
});
</script>

<?php if ($js_redirect): ?>
<script>setTimeout(function() { window.location.href = '<?= addslashes($js_redirect) ?>'; }, 1500);</script>
<?php endif; ?>