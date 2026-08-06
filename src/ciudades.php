<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title = "ADSOERP | Gestión de Ciudades";
$page_description = "Administración de ciudades de Colombia";
$page_icon = "bi-geo-alt";
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

$f_id_ciudad = "";
$f_nom_ciudad = "";
$f_id_dpto = "";
$f_capital = false;
$f_cod_postal = "";
$f_latitud = "";
$f_longitud = "";
$f_estado = true;

// Cargar departamentos para el select - CORREGIDO
$stmt_dptos = $pdo->query("SELECT id_dpto, nom_dpto FROM tab_dptos WHERE ind_borrado = 'f' ORDER BY nom_dpto");
$departamentos = $stmt_dptos->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $redirect_url = 'menu_principal.php';
    $params = [];
    if (!empty($_POST['_padre'])) $params[] = 'padre=' . (int) $_POST['_padre'];
    if (!empty($_POST['_hijo']))  $params[] = 'hijo='  . (int) $_POST['_hijo'];
    if (!empty($_POST['_nieto'])) $params[] = 'nieto=' . (int) $_POST['_nieto'];
    if ($params) $redirect_url .= '?' . implode('&', $params);

    try {
        if (isset($_POST['btn_guardar'])) {
            $w_id_ciudad = trim($_POST['txt_id_ciudad']);
            $w_nom_ciudad = ucfirst(trim($_POST['txt_nom_ciudad']));
            $w_id_dpto = $_POST['sel_id_dpto'];
            $w_capital = isset($_POST['chk_capital']) ? 1 : 0;
            $w_cod_postal = trim($_POST['txt_cod_postal']);
            $w_latitud = (float) $_POST['txt_latitud'];
            $w_longitud = (float) $_POST['txt_longitud'];
            $w_estado = isset($_POST['chk_estado']) ? 1 : 0;

            $f_id_ciudad = $w_id_ciudad;
            $f_nom_ciudad = $w_nom_ciudad;
            $f_id_dpto = $w_id_dpto;
            $f_capital = (bool) $w_capital;
            $f_cod_postal = $w_cod_postal;
            $f_latitud = $w_latitud;
            $f_longitud = $w_longitud;
            $f_estado = (bool) $w_estado;

            // Validaciones
            if (empty($w_id_ciudad)) throw new Exception("El ID de la ciudad es obligatorio.");
            if (strlen($w_id_ciudad) != 5) throw new Exception("El ID debe tener exactamente 5 dígitos.");
            if (!preg_match('/^[0-9]+$/', $w_id_ciudad)) throw new Exception("El ID solo debe contener números.");
            if (empty($w_nom_ciudad)) throw new Exception("El nombre de la ciudad es obligatorio.");
            if (strlen($w_nom_ciudad) < 3) throw new Exception("El nombre debe tener mínimo 3 caracteres.");
            if (strlen($w_nom_ciudad) > 30) throw new Exception("El nombre no puede exceder 30 caracteres.");
            if (empty($w_id_dpto)) throw new Exception("Debe seleccionar un departamento.");
            if (empty($w_cod_postal)) throw new Exception("El código postal es obligatorio.");
            if (strlen($w_cod_postal) != 6) throw new Exception("El código postal debe tener 6 dígitos.");
            if (!preg_match('/^[0-9]+$/', $w_cod_postal)) throw new Exception("El código postal solo debe contener números.");
            if ($w_latitud < -4 || $w_latitud > 80) throw new Exception("Latitud fuera de rango (-4 a 80)");
            if ($w_longitud < -80 || $w_longitud > -50) throw new Exception("Longitud fuera de rango (-80 a -50)");

            $stmt_check = $pdo->prepare("SELECT COUNT(*) FROM tab_ciudades WHERE id_ciudad = ?");
            $stmt_check->execute([$w_id_ciudad]);
            $existe = $stmt_check->fetchColumn();

            if ($existe) {
                $stmt = $pdo->prepare("UPDATE tab_ciudades SET nom_ciudad = ?, id_dpto = ?, ind_capital = ?, cod_postal = ?, val_latitud = ?, val_longitud = ?, ind_borrado = ? WHERE id_ciudad = ?");
                $stmt->execute([$w_nom_ciudad, $w_id_dpto, $w_capital, $w_cod_postal, $w_latitud, $w_longitud, $w_estado ? 'f' : 't', $w_id_ciudad]);
                $w_mensaje = "Ciudad actualizada correctamente.";
            } else {
                $stmt = $pdo->prepare("INSERT INTO tab_ciudades (id_ciudad, nom_ciudad, id_dpto, ind_capital, cod_postal, val_latitud, val_longitud, ind_borrado) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([$w_id_ciudad, $w_nom_ciudad, $w_id_dpto, $w_capital, $w_cod_postal, $w_latitud, $w_longitud, $w_estado ? 'f' : 't']);
                $w_mensaje = "Ciudad registrada correctamente.";
            }

            $w_tipo_alerta = "success";
            $js_redirect = $redirect_url;
            $f_id_ciudad = $f_nom_ciudad = $f_cod_postal = "";
            $f_latitud = $f_longitud = "";
            $f_capital = false;
            $f_estado = true;
        }

        if (isset($_POST['btn_toggle_estado'])) {
            $w_id = $_POST['hid_id_ciudad'];
            $w_nuevo_estado = $_POST['hid_nuevo_estado'] === 'true' ? 'f' : 't';
            $stmt = $pdo->prepare("UPDATE tab_ciudades SET ind_borrado = ? WHERE id_ciudad = ?");
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

// Cargar ciudades con los datos completos
$stmt = $pdo->query("
    SELECT c.id_ciudad, c.nom_ciudad, c.ind_capital, c.cod_postal, c.ind_borrado, c.val_latitud, c.val_longitud, c.id_dpto, d.nom_dpto as nom_dpto
    FROM tab_ciudades c 
    INNER JOIN tab_dptos d ON c.id_dpto = d.id_dpto 
    ORDER BY d.nom_dpto, c.nom_ciudad");
$ciudades = $stmt->fetchAll();
?>

<link rel="stylesheet" href="css/usuarios.css">

<style>
/* Estilos específicos para Ciudades */
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

.badge-capital {
    background: #fef3c7;
    color: #d97706;
    padding: 0.25rem 0.6rem;
    border-radius: 30px;
    font-size: 0.7rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 4px;
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
    max-width: 520px;
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

select.form-control-sm {
    cursor: pointer;
    background: white;
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

.mt-3 {
    margin-top: 1rem;
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

.text-center {
    text-align: center;
}

.py-4 {
    padding-top: 2rem;
    padding-bottom: 2rem;
}

.text-muted {
    color: #64748b;
}
</style>

<div class="crud-container">
    <div class="crud-header">
        <div class="crud-title">
            <h2><i class="bi bi-geo-alt" style="color:#00d9ff;"></i> Gestión de Ciudades</h2>
            <p>Administración de ciudades de Colombia</p>
        </div>
        <button class="btn-add" onclick="abrirModal()">
            <i class="bi bi-plus-circle"></i> Añadir Ciudad
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
            <input type="text" id="filtro_texto" placeholder="Buscar por ciudad, código o departamento..." onkeyup="filtrarTabla()">
        </div>
        <div class="filtro-select">
            <select id="filtro_estado" onchange="filtrarTabla()">
                <option value="">Todos los estados</option>
                <option value="activo">Activos</option>
                <option value="inactivo">Inactivos</option>
            </select>
        </div>
        <div class="filtro-select">
            <select id="filtro_capital" onchange="filtrarTabla()">
                <option value="">Todas</option>
                <option value="capital">Solo capitales</option>
                <option value="no_capital">No capitales</option>
            </select>
        </div>
        <span class="filtro-count" id="filtro_count"></span>
    </div>

    <div class="table-responsive">
        <table class="table-custom" id="tablaCiudades">
            <thead>
                <tr>
                    <th style="width:10%">CÓDIGO</th>
                    <th style="width:25%">CIUDAD</th>
                    <th style="width:20%">DEPARTAMENTO</th>
                    <th style="width:10%">CAPITAL</th>
                    <th style="width:12%">CÓDIGO POSTAL</th>
                    <th style="width:8%">ESTADO</th>
                    <th style="width:15%">ACCIONES</th>
                </tr>
            </thead>
            <tbody>
                <?php if (count($ciudades) > 0): ?>
                    <?php foreach ($ciudades as $c): ?>
                        <tr data-nombre="<?= strtolower(htmlspecialchars($c['nom_ciudad'])) ?>"
                            data-codigo="<?= htmlspecialchars($c['id_ciudad']) ?>"
                            data-departamento="<?= strtolower(htmlspecialchars($c['nom_dpto'])) ?>"
                            data-estado="<?= $c['ind_borrado'] === 't' ? 'inactivo' : 'activo' ?>"
                            data-capital="<?= $c['ind_capital'] ? 'capital' : 'no_capital' ?>"
                            class="<?= $c['ind_borrado'] === 't' ? 'inactivo' : '' ?>">
                            
                            <td><strong><?= htmlspecialchars($c['id_ciudad']) ?></strong></td>
                            <td><?= htmlspecialchars($c['nom_ciudad']) ?></td>
                            <td><?= htmlspecialchars($c['nom_dpto']) ?></td>
                            <td>
                                <?php if ($c['ind_capital']): ?>
                                    <span class="badge-capital"><i class="bi bi-star-fill"></i> Capital</span>
                                <?php else: ?>
                                    —
                                <?php endif; ?>
                            </td>
                            <td><?= htmlspecialchars($c['cod_postal']) ?></td>
                            <td>
                                <span class="badge-estado <?= $c['ind_borrado'] === 't' ? 'inactivo' : 'activo' ?>">
                                    <?= $c['ind_borrado'] === 't' ? 'INACTIVO' : 'ACTIVO' ?>
                                </span>
                            </td>
                            <td>
                                <button class="btn-icon edit" onclick='abrirModalEdicion(<?= json_encode($c) ?>)' title="Editar">
                                    <i class="bi bi-pencil-square"></i>
                                </button>
                                <form method="POST" style="display:inline;">
                                    <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                                    <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                                    <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">
                                    <input type="hidden" name="hid_id_ciudad" value="<?= $c['id_ciudad'] ?>">
                                    <input type="hidden" name="hid_nuevo_estado" value="<?= $c['ind_borrado'] === 't' ? 'true' : 'false' ?>">
                                    <button type="submit" name="btn_toggle_estado" class="btn-icon <?= $c['ind_borrado'] === 't' ? 'toggle-active' : 'toggle-inactive' ?>" title="<?= $c['ind_borrado'] === 't' ? 'Activar' : 'Desactivar' ?>">
                                        <i class="bi <?= $c['ind_borrado'] === 't' ? 'bi-check-circle-fill' : 'bi-lock-fill' ?>"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php else: ?>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">
                            <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                            <p class="mt-2 mb-0">No hay ciudades registradas</p>
                        </td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL - CORREGIDO el select de departamentos -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="bi bi-geo-alt"></i> Nueva Ciudad</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-card-body">
            <form method="POST" id="formCiudad">
                <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">

                <div class="mb-3">
                    <label class="form-label-custom">CÓDIGO DANE (5 dígitos) *</label>
                    <input type="text" name="txt_id_ciudad" id="f_id" class="form-control-sm" placeholder="Ej: 05001" maxlength="5" required>
                    <small class="text-muted">Código único DANE de la ciudad</small>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">NOMBRE DE LA CIUDAD *</label>
                    <input type="text" name="txt_nom_ciudad" id="f_nom" class="form-control-sm" required placeholder="Ej: Medellín">
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">DEPARTAMENTO *</label>
                    <select name="sel_id_dpto" id="f_dpto" class="form-control-sm" required>
                        <option value="">-- Seleccionar departamento --</option>
                        <?php foreach($departamentos as $d): ?>
                            <option value="<?= htmlspecialchars($d['id_dpto']) ?>"><?= htmlspecialchars($d['nom_dpto']) ?> (<?= htmlspecialchars($d['id_dpto']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="mb-3">
                    <div class="form-check-custom">
                        <input type="checkbox" name="chk_capital" id="f_capital">
                        <label>¿Es capital del departamento?</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">CÓDIGO POSTAL (6 dígitos) *</label>
                    <input type="text" name="txt_cod_postal" id="f_cod" class="form-control-sm" maxlength="6" required placeholder="Ej: 050001">
                </div>

                <div class="row">
                    <div class="col">
                        <label class="form-label-custom">LATITUD *</label>
                        <input type="number" step="any" name="txt_latitud" id="f_lat" class="form-control-sm" required placeholder="Ej: 6.2442">
                    </div>
                    <div class="col">
                        <label class="form-label-custom">LONGITUD *</label>
                        <input type="number" step="any" name="txt_longitud" id="f_lon" class="form-control-sm" required placeholder="Ej: -75.5812">
                    </div>
                </div>

                <div class="mb-3 mt-3">
                    <div class="form-check-custom">
                        <input type="checkbox" name="chk_estado" id="f_est" checked>
                        <label>Ciudad activa</label>
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
// Filtrar tabla
function filtrarTabla() {
    const texto = document.getElementById('filtro_texto').value.toLowerCase().trim();
    const estado = document.getElementById('filtro_estado').value;
    const capital = document.getElementById('filtro_capital').value;
    const tbody = document.querySelector('#tablaCiudades tbody');
    if (!tbody) return;
    
    const filas = Array.from(tbody.querySelectorAll('tr'));
    let contador = 0;
    
    filas.forEach(tr => {
        if (tr.querySelector('td[colspan]')) return;
        
        const nombre = tr.dataset.nombre || '';
        const codigo = tr.dataset.codigo || '';
        const departamento = tr.dataset.departamento || '';
        const rowEstado = tr.dataset.estado || '';
        const rowCapital = tr.dataset.capital || '';
        
        const matchTexto = !texto || nombre.includes(texto) || codigo.includes(texto) || departamento.includes(texto);
        const matchEstado = !estado || rowEstado === estado;
        const matchCapital = !capital || rowCapital === capital;
        
        if (matchTexto && matchEstado && matchCapital) {
            tr.style.display = '';
            contador++;
        } else {
            tr.style.display = 'none';
        }
    });
    
    document.getElementById('filtro_count').innerText = `${contador} ciudad${contador !== 1 ? 'es' : ''}`;
}

// Modal functions
function abrirModal() {
    document.getElementById('modalOverlay').classList.add('show');
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-geo-alt"></i> Nueva Ciudad';
    document.getElementById('formCiudad').reset();
    document.getElementById('f_id').readOnly = false;
    document.getElementById('f_est').checked = true;
    document.getElementById('f_capital').checked = false;
    // Asegurar que el select tenga la opción por defecto
    document.getElementById('f_dpto').value = '';
}

function abrirModalEdicion(ciudad) {
    document.getElementById('modalOverlay').classList.add('show');
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-pencil-square"></i> Editar Ciudad';
    document.getElementById('f_id').value = ciudad.id_ciudad;
    document.getElementById('f_id').readOnly = true;
    document.getElementById('f_nom').value = ciudad.nom_ciudad;
    document.getElementById('f_dpto').value = ciudad.id_dpto;
    document.getElementById('f_capital').checked = ciudad.ind_capital == 1 || ciudad.ind_capital === true;
    document.getElementById('f_cod').value = ciudad.cod_postal;
    document.getElementById('f_lat').value = ciudad.val_latitud;
    document.getElementById('f_lon').value = ciudad.val_longitud;
    document.getElementById('f_est').checked = ciudad.ind_borrado !== 't';
}

function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('show');
}

function cerrarModalSiOverlay(e) {
    if (e.target === document.getElementById('modalOverlay')) cerrarModal();
}

function limpiarFormulario() {
    document.getElementById('formCiudad').reset();
    document.getElementById('f_id').readOnly = false;
    document.getElementById('f_est').checked = true;
    document.getElementById('f_capital').checked = false;
    document.getElementById('f_dpto').value = '';
}

// Inicializar contador
document.addEventListener('DOMContentLoaded', () => {
    const total = document.querySelectorAll('#tablaCiudades tbody tr:not([style*="display: none"])').length;
    document.getElementById('filtro_count').innerText = `${total} ciudad${total !== 1 ? 'es' : ''}`;
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