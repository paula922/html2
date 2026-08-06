<?php
/**
 * GESTIÓN DE ACCESOS DE USUARIOS - SistNomina V.3.1
 * - Selección jerárquica (padre → hijo → nieto)
 * - Búsqueda en tiempo real
 * - Botones: Todo, Ninguno, Limpiar
 * - Contador visual de seleccionados
 * - Jerarquía visual clara
 */

// Verificar que está siendo incluido desde menu_principal.php
if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

// Inicializar variables
$lista_usuarios = [];
$lista_menus = [];
$error_carga = '';
$mensaje = '';
$tipo_mensaje = '';

try {
    $stmt_list_usuarios->execute();
    $lista_usuarios = $stmt_list_usuarios->fetchAll(PDO::FETCH_ASSOC);

    $stmt_list_todos_menus->execute();
    $lista_menus_raw = $stmt_list_todos_menus->fetchAll(PDO::FETCH_ASSOC);
    
    // Organizar menús por jerarquía
    $menus_organizados = [];

    // Separar padres
    foreach ($lista_menus_raw as $m) {
        if ($m['ind_id_padre'] == '0') {
            $menus_organizados[$m['id_menu']] = $m;
            $menus_organizados[$m['id_menu']]['hijos'] = [];
        }
    }

    // Separar hijos
    foreach ($lista_menus_raw as $m) {
        if ($m['ind_id_padre'] != '0' && isset($menus_organizados[$m['ind_id_padre']])) {
            $menus_organizados[$m['ind_id_padre']]['hijos'][$m['id_menu']] = $m;
            $menus_organizados[$m['ind_id_padre']]['hijos'][$m['id_menu']]['nietos'] = [];
        }
    }

    // Separar nietos
    foreach ($lista_menus_raw as $m) {
        if ($m['ind_id_padre'] != '0') {
            foreach ($menus_organizados as $pid => &$padre) {
                if (isset($padre['hijos'][$m['ind_id_padre']])) {
                    $padre['hijos'][$m['ind_id_padre']]['nietos'][$m['id_menu']] = $m;
                }
            }
            unset($padre);
        }
    }

    // Guardado POST
    if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] === 'guardar_accesos') {
        $id_usuario = $_POST['hid_usuario'] ?? '';
        $menus_seleccionados = $_POST['chk_menu'] ?? [];

        if (empty($id_usuario)) {
            $mensaje = "Debe seleccionar un usuario";
            $tipo_mensaje = "danger";
        } else {
            try {
                $pdo->beginTransaction();

                $stmt_del = $pdo->prepare("DELETE FROM tab_menu_usuarios WHERE id_usuario = CAST(? AS TEXT)");
                $stmt_del->execute([$id_usuario]);

                if (!empty($menus_seleccionados)) {
                    $stmt_ins = $pdo->prepare("INSERT INTO tab_menu_usuarios (id_usuario, id_menu) VALUES (CAST(? AS TEXT), CAST(? AS TEXT))");
                    foreach ($menus_seleccionados as $id_menu) {
                        $stmt_ins->execute([$id_usuario, $id_menu]);
                    }
                    $mensaje = "✅ Accesos guardados. Se asignaron " . count($menus_seleccionados) . " menús.";
                } else {
                    $mensaje = "✅ Accesos actualizados. Sin menús asignados.";
                }
                $tipo_mensaje = "success";
                $pdo->commit();

            } catch (Exception $e) {
                $pdo->rollBack();
                $mensaje = "❌ Error: " . $e->getMessage();
                $tipo_mensaje = "danger";
            }
        }
    }

} catch (Exception $e) {
    $error_carga = $e->getMessage();
}
?>

<style>
    .accesos-container {
        max-width: 100%;
        margin: 0;
        padding: 0;
    }

    .accesos-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
        padding-bottom: 0.75rem;
        border-bottom: 2px solid #e2e8f0;
        flex-wrap: wrap;
        gap: 1rem;
    }

    .accesos-title h2 {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 0;
        color: #1a1a2e;
    }

    .accesos-title p {
        margin: 0;
        font-size: 0.8rem;
        color: #6c7a8a;
    }

    .contador-global {
        background: #64748b;
        color: white;
        padding: 5px 15px;
        border-radius: 30px;
        font-size: 0.8rem;
        font-weight: 600;
        transition: background 0.3s;
    }

    .accesos-layout {
        display: flex;
        gap: 1.5rem;
        flex-wrap: wrap;
    }

    .panel-usuario {
        flex: 1;
        min-width: 280px;
    }

    .panel-menus {
        flex: 2;
        min-width: 300px;
    }

    .card-acceso {
        background: white;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        overflow: hidden;
        margin-bottom: 1.5rem;
    }

    .card-acceso-header {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        padding: 0.75rem 1.25rem;
        color: white;
        font-weight: 600;
        font-size: 0.9rem;
    }

    .card-acceso-header i {
        margin-right: 0.5rem;
        color: #00d9ff;
    }

    .card-acceso-body {
        padding: 1.25rem;
    }

    .card-acceso-body.p-0 {
        padding: 0;
    }

    .select-usuario {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        font-size: 0.9rem;
        background: white;
        cursor: pointer;
    }

    .select-usuario:focus {
        outline: none;
        border-color: #00d9ff;
    }

    .table-menus-container {
        max-height: 55vh;
        overflow-y: auto;
    }

    .table-menus {
        width: 100%;
        margin-bottom: 0;
        font-size: 0.85rem;
        border-collapse: collapse;
    }

    .table-menus thead {
        background: #f1f5f9;
        position: sticky;
        top: 0;
        z-index: 10;
    }

    .table-menus thead th {
        padding: 0.75rem 1rem;
        font-weight: 600;
        color: #1e293b;
        font-size: 0.75rem;
        text-transform: uppercase;
    }

    .table-menus tbody td {
        padding: 0.6rem 1rem;
        border-bottom: 1px solid #eef2f7;
        vertical-align: middle;
    }

    .table-menus tbody tr:hover {
        background: #f8fafc;
    }

    /* ========== JERARQUÍA VISUAL ========== */
    .menu-padre {
        background: #fafcff;
        border-left: 4px solid #00d9ff;
    }

    .menu-padre td {
        padding: 12px 1rem !important;
    }

    .menu-padre .menu-nombre {
        font-weight: 700;
        font-size: 1rem;
    }

    .menu-hijo {
        background: white;
    }

    .menu-hijo td {
        padding: 8px 1rem !important;
    }

    .menu-hijo .menu-nombre {
        font-weight: normal;
    }

    .menu-hijo-con-hijos .menu-nombre {
        font-weight: 700;
        color: #1a1a2e;
    }

    .menu-nieto {
        background: #fefefe;
    }

    .menu-nieto td {
        padding: 6px 1rem !important;
    }

    .menu-nieto .menu-nombre {
        font-weight: normal;
        color: #475569;
    }

    /* Sangrías */
    .menu-hijo .menu-nombre {
        padding-left: 28px !important;
    }

    .menu-nieto .menu-nombre {
        padding-left: 52px !important;
    }

    .checkbox-custom {
        width: 18px;
        height: 18px;
        accent-color: #00d9ff;
        cursor: pointer;
    }

    .badge-programa {
        background: #e6f7ff;
        color: #0088cc;
        padding: 0.2rem 0.5rem;
        border-radius: 20px;
        font-size: 0.7rem;
    }

    .badge-submenu {
        background: #e2e8f0;
        color: #475569;
        padding: 2px 8px;
        border-radius: 20px;
        font-size: 0.6rem;
        margin-left: 8px;
        font-weight: normal;
    }

    .btn-guardar {
        width: 100%;
        background: linear-gradient(135deg, #00b4d8 0%, #0077b6 100%);
        border: none;
        padding: 0.7rem;
        font-weight: 600;
        color: white;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .btn-guardar:hover:not(:disabled) {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0,180,216,0.3);
    }

    .btn-guardar:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .info-box {
        background: #f0f9ff;
        border-left: 3px solid #00d9ff;
        padding: 0.75rem;
        border-radius: 10px;
        margin-top: 1rem;
        font-size: 0.75rem;
        color: #475569;
    }

    .alert-custom {
        border-radius: 12px;
        padding: 10px 15px;
        margin-bottom: 1rem;
    }

    .alert-success {
        background: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }

    .alert-danger {
        background: #fee2e2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }

    .fila-oculta {
        display: none;
    }

    .usuario-info {
        background: #dcfce7;
        border-radius: 10px;
        padding: 8px 12px;
        font-size: 0.8rem;
        margin-top: 12px;
    }

    .toolbar {
        display: flex;
        gap: 0.5rem;
        flex-wrap: wrap;
        padding: 0.75rem 1rem;
        background: #f8fafc;
        border-bottom: 1px solid #eef2f7;
        align-items: center;
    }

    .search-box {
        flex: 2;
        min-width: 180px;
        position: relative;
    }

    .search-box input {
        width: 100%;
        padding: 6px 10px 6px 28px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 0.8rem;
        box-sizing: border-box;
    }

    .search-box i {
        position: absolute;
        left: 8px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 0.8rem;
        color: #94a3b8;
    }

    .btn-tool {
        background: white;
        border: 1px solid #e2e8f0;
        padding: 5px 12px;
        border-radius: 8px;
        font-size: 0.7rem;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 500;
    }

    .btn-tool:hover {
        background: #e2e8f0;
        border-color: #00d9ff;
    }

    /* Iconos jerárquicos */
    .icon-padre {
        color: #00d9ff;
        margin-right: 8px;
        font-size: 1rem;
    }

    .icon-hijo {
        color: #64748b;
        margin-right: 8px;
        font-size: 0.9rem;
    }

    .icon-nieto {
        color: #94a3b8;
        margin-right: 8px;
        font-size: 0.85rem;
    }

    @media (max-width: 768px) {
        .accesos-layout {
            flex-direction: column;
        }
        .toolbar {
            flex-direction: column;
            align-items: stretch;
        }
        .search-box {
            width: 100%;
        }
        .btn-tool {
            text-align: center;
        }
        .badge-programa, .badge-submenu {
            display: none;
        }
        .menu-hijo .menu-nombre {
            padding-left: 20px !important;
        }
        .menu-nieto .menu-nombre {
            padding-left: 36px !important;
        }
    }
</style>

<div class="accesos-container">
    <div class="accesos-header">
        <div class="accesos-title">
            <h2><i class="bi bi-shield-lock-fill" style="color: #00d9ff;"></i> Gestión de Accesos</h2>
            <p>Asignación de menús por usuario</p>
        </div>
        <span id="contador_global" class="contador-global">0 seleccionados</span>
    </div>

    <?php if ($mensaje): ?>
        <div class="alert-custom alert-<?= $tipo_mensaje ?>"><?= htmlspecialchars($mensaje) ?></div>
    <?php endif; ?>

    <?php if ($error_carga): ?>
        <div class="alert-custom alert-danger">Error: <?= htmlspecialchars($error_carga) ?></div>
    <?php endif; ?>

    <div class="accesos-layout">
        <!-- Panel Usuario -->
        <div class="panel-usuario">
            <div class="card-acceso">
                <div class="card-acceso-header">
                    <i class="bi bi-person-badge"></i> Seleccionar Usuario
                </div>
                <div class="card-acceso-body">
                    <select id="sel_usuario" class="select-usuario">
                        <option value="">-- Seleccione un usuario --</option>
                        <?php foreach ($lista_usuarios as $u): ?>
                            <option value="<?= htmlspecialchars($u['id_usuario']) ?>">
                                <?= htmlspecialchars($u['nom_usuario']) ?> (<?= htmlspecialchars($u['id_usuario']) ?>)
                            </option>
                        <?php endforeach; ?>
                    </select>

                    <div class="info-box">
                        <i class="bi bi-info-circle-fill"></i>
                        Seleccione un usuario para ver y editar sus menús asignados.
                        Al marcar un padre, se marcan todos sus hijos y nietos automáticamente.
                    </div>

                    <div id="usuario_seleccionado_info" style="display: none;">
                        <div class="usuario-info">
                            <i class="bi bi-check-circle-fill" style="color: #15803d;"></i>
                            Usuario: <strong id="info_nombre_usuario"></strong> (<span id="info_id_usuario"></span>)
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Panel Menús -->
        <div class="panel-menus">
            <div class="card-acceso">
                <div class="card-acceso-header">
                    <i class="bi bi-list-ul"></i> Menús Disponibles
                </div>
                <div class="card-acceso-body p-0">
                    <div class="toolbar">
                        <div class="search-box">
                            <i class="bi bi-search"></i>
                            <input type="text" id="buscar_menu" placeholder="Buscar menú...">
                        </div>
                        <button type="button" id="btn_todos" class="btn-tool">✓ Seleccionar Todo</button>
                        <button type="button" id="btn_ninguno" class="btn-tool">✗ Deseleccionar Todo</button>
                        <button type="button" id="btn_limpiar" class="btn-tool">🗑 Limpiar</button>
                    </div>

                    <form id="form_accesos" method="POST">
                        <input type="hidden" name="action" value="guardar_accesos">
                        <input type="hidden" name="hid_usuario" id="hid_usuario">

                        <div class="table-menus-container">
                            <table class="table-menus">
                                <thead>
                                    <tr>
                                        <th style="width: 40px;"></th>
                                        <th>Menú</th>
                                        <th>Programa</th>
                                    </tr>
                                </thead>
                                <tbody id="tbody_menus">
                                    <?php foreach ($menus_organizados as $padre): ?>

                                        <!-- FILA PADRE (NEGRITA, BORDE AZUL) -->
                                        <tr data-id="<?= $padre['id_menu'] ?>"
                                            data-padre="0"
                                            data-nivel="padre"
                                            class="menu-padre">
                                            <td>
                                                <input type="checkbox"
                                                       class="checkbox-custom"
                                                       id="chk_<?= $padre['id_menu'] ?>"
                                                       name="chk_menu[]"
                                                       value="<?= $padre['id_menu'] ?>"
                                                       data-nivel="padre"
                                                       data-id-padre="0">
                                            </td>
                                            <td class="menu-nombre" data-nombre="<?= htmlspecialchars($padre['nom_menu']) ?>">
                                                <i class="bi bi-folder-fill icon-padre"></i>
                                                <strong><?= htmlspecialchars($padre['nom_menu']) ?></strong>
                                            </td>
                                            <td>
                                                <?php if (!empty($padre['nom_programa']) && $padre['nom_programa'] != '#'): ?>
                                                    <span class="badge-programa"><?= htmlspecialchars($padre['nom_programa']) ?></span>
                                                <?php else: ?>
                                                    —
                                                <?php endif; ?>
                                            </td>
                                        </tr>

                                        <?php if (!empty($padre['hijos'])): ?>
                                            <?php foreach ($padre['hijos'] as $hijo): ?>
                                                <?php $tiene_nietos = !empty($hijo['nietos']); ?>

                                                <!-- FILA HIJO (NEGRITA si tiene nietos) -->
                                                <tr data-id="<?= $hijo['id_menu'] ?>"
                                                    data-padre="<?= $padre['id_menu'] ?>"
                                                    data-nivel="hijo"
                                                    class="menu-hijo <?= $tiene_nietos ? 'menu-hijo-con-hijos' : '' ?>">
                                                    <td>
                                                        <input type="checkbox"
                                                               class="checkbox-custom"
                                                               id="chk_<?= $hijo['id_menu'] ?>"
                                                               name="chk_menu[]"
                                                               value="<?= $hijo['id_menu'] ?>"
                                                               data-nivel="hijo"
                                                               data-id-padre="<?= $padre['id_menu'] ?>">
                                                    </td>
                                                    <td class="menu-nombre" data-nombre="<?= htmlspecialchars($hijo['nom_menu']) ?>">
                                                        <i class="bi bi-<?= $tiene_nietos ? 'folder' : 'file-earmark-fill' ?> icon-hijo"></i>
                                                        <span <?= $tiene_nietos ? 'style="font-weight: 700;"' : '' ?>>
                                                            <?= htmlspecialchars($hijo['nom_menu']) ?>
                                                        </span>
                                                        <?php if ($tiene_nietos): ?>
                                                            <span class="badge-submenu">📁 tiene submenús</span>
                                                        <?php endif; ?>
                                                    </td>
                                                    <td>
                                                        <?php if (!empty($hijo['nom_programa']) && $hijo['nom_programa'] != '#'): ?>
                                                            <span class="badge-programa"><?= htmlspecialchars($hijo['nom_programa']) ?></span>
                                                        <?php else: ?>
                                                            —
                                                        <?php endif; ?>
                                                    </td>
                                                </tr>

                                                <?php if ($tiene_nietos): ?>
                                                    <?php foreach ($hijo['nietos'] as $nieto): ?>

                                                        <!-- FILA NIETO (SIN NEGRITA, SANGRIADOBLE) -->
                                                        <tr data-id="<?= $nieto['id_menu'] ?>"
                                                            data-padre="<?= $hijo['id_menu'] ?>"
                                                            data-nivel="nieto"
                                                            class="menu-nieto">
                                                            <td>
                                                                <input type="checkbox"
                                                                       class="checkbox-custom"
                                                                       id="chk_<?= $nieto['id_menu'] ?>"
                                                                       name="chk_menu[]"
                                                                       value="<?= $nieto['id_menu'] ?>"
                                                                       data-nivel="nieto"
                                                                       data-id-padre="<?= $hijo['id_menu'] ?>">
                                                            </td>
                                                            <td class="menu-nombre" data-nombre="<?= htmlspecialchars($nieto['nom_menu']) ?>">
                                                                <i class="bi bi-file-text-fill icon-nieto"></i>
                                                                <?= htmlspecialchars($nieto['nom_menu']) ?>
                                                            </td>
                                                            <td>
                                                                <?php if (!empty($nieto['nom_programa']) && $nieto['nom_programa'] != '#'): ?>
                                                                    <span class="badge-programa"><?= htmlspecialchars($nieto['nom_programa']) ?></span>
                                                                <?php else: ?>
                                                                    —
                                                                <?php endif; ?>
                                                            </td>
                                                        </tr>

                                                    <?php endforeach; ?>
                                                <?php endif; ?>

                                            <?php endforeach; ?>
                                        <?php endif; ?>

                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>

                        <div class="card-acceso-body">
                            <button type="submit" id="btn_guardar" class="btn-guardar" disabled>
                                <i class="bi bi-save"></i> GUARDAR ACCESOS
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// ============================================
// VARIABLES GLOBALES
// ============================================
let hasChanges = false;
let usuarioActual = '';

// ============================================
// ACTUALIZAR CONTADOR GLOBAL
// ============================================
function actualizarContadorGlobal() {
    const total = document.querySelectorAll('.checkbox-custom').length;
    const seleccionados = document.querySelectorAll('.checkbox-custom:checked').length;
    const contadorSpan = document.getElementById('contador_global');
    if (contadorSpan) {
        contadorSpan.textContent = `${seleccionados} de ${total} seleccionados`;
        contadorSpan.style.background = seleccionados > 0 ? '#00d9ff' : '#64748b';
    }
}

// ============================================
// HABILITAR GUARDAR
// ============================================
function habilitarGuardar() {
    if (usuarioActual) {
        hasChanges = true;
        const btn = document.getElementById('btn_guardar');
        if (btn) btn.disabled = false;
    }
}

// ============================================
// OBTENER CHECKBOXES HIJOS DIRECTOS
// ============================================
function obtenerHijosDirectos(padreId) {
    const hijos = [];
    document.querySelectorAll('#tbody_menus tr').forEach(fila => {
        if (fila.getAttribute('data-padre') == padreId) {
            const chk = fila.querySelector('.checkbox-custom');
            if (chk) hijos.push(chk);
        }
    });
    return hijos;
}

// ============================================
// OBTENER TODOS LOS DESCENDIENTES (hijos y nietos)
// ============================================
function obtenerTodosDescendientes(padreId) {
    const descendientes = [];
    document.querySelectorAll('#tbody_menus tr').forEach(fila => {
        let padre = fila.getAttribute('data-padre');
        // Buscar recursivamente
        while (padre && padre != '0') {
            if (padre == padreId) {
                const chk = fila.querySelector('.checkbox-custom');
                if (chk && !descendientes.includes(chk)) descendientes.push(chk);
                break;
            }
            const filaPadre = document.querySelector(`#tbody_menus tr[data-id="${padre}"]`);
            padre = filaPadre ? filaPadre.getAttribute('data-padre') : null;
        }
    });
    return descendientes;
}

// ============================================
// PADRE: marcar todos sus descendientes
// ============================================
function onPadreChange(checkbox) {
    const padreId = checkbox.value;
    const estado = checkbox.checked;
    
    const descendientes = obtenerTodosDescendientes(padreId);
    descendientes.forEach(desc => {
        desc.checked = estado;
    });
    
    actualizarContadorGlobal();
    habilitarGuardar();
}

// ============================================
// HIJO: marcar sus nietos y actualizar padre
// ============================================
function onHijoChange(checkbox) {
    const fila = checkbox.closest('tr');
    const padreId = fila.getAttribute('data-padre');
    const estado = checkbox.checked;
    
    // Marcar sus nietos
    const nietos = obtenerHijosDirectos(checkbox.value);
    nietos.forEach(nieto => {
        nieto.checked = estado;
    });
    
    // Actualizar el padre
    if (padreId && padreId != '0') {
        const hermanos = obtenerHijosDirectos(padreId);
        const padreChk = document.getElementById(`chk_${padreId}`);
        if (padreChk) {
            if (hermanos.every(h => h.checked)) {
                padreChk.checked = true;
            } else if (hermanos.every(h => !h.checked)) {
                padreChk.checked = false;
            }
        }
    }
    
    actualizarContadorGlobal();
    habilitarGuardar();
}

// ============================================
// NIETO: actualizar su padre y abuelo
// ============================================
function onNietoChange(checkbox) {
    const fila = checkbox.closest('tr');
    const padreId = fila.getAttribute('data-padre'); // el hijo
    
    if (padreId && padreId != '0') {
        const hermanos = obtenerHijosDirectos(padreId);
        const padreChk = document.getElementById(`chk_${padreId}`);
        if (padreChk) {
            if (hermanos.every(h => h.checked)) {
                padreChk.checked = true;
                // Actualizar abuelo
                const filaPadre = document.querySelector(`#tbody_menus tr[data-id="${padreId}"]`);
                const abueloId = filaPadre ? filaPadre.getAttribute('data-padre') : null;
                if (abueloId && abueloId != '0') {
                    const tios = obtenerHijosDirectos(abueloId);
                    const abueloChk = document.getElementById(`chk_${abueloId}`);
                    if (abueloChk && tios.every(h => h.checked)) {
                        abueloChk.checked = true;
                    }
                }
            } else if (hermanos.every(h => !h.checked)) {
                padreChk.checked = false;
            }
        }
    }
    
    actualizarContadorGlobal();
    habilitarGuardar();
}

// ============================================
// ASIGNAR EVENTOS
// ============================================
function asignarEventosCheckboxes() {
    document.querySelectorAll('#tbody_menus tr').forEach(fila => {
        const nivel = fila.getAttribute('data-nivel');
        const chk = fila.querySelector('.checkbox-custom');
        if (!chk || chk._eventAsignado) return;
        
        if (nivel === 'padre') {
            chk.addEventListener('change', function() { onPadreChange(this); });
        } else if (nivel === 'hijo') {
            chk.addEventListener('change', function() { onHijoChange(this); });
        } else if (nivel === 'nieto') {
            chk.addEventListener('change', function() { onNietoChange(this); });
        }
        chk._eventAsignado = true;
    });
}

// ============================================
// CARGAR MENÚS DEL USUARIO
// ============================================
async function cargarMenusUsuario(usuarioId) {
    if (!usuarioId) return;
    
    usuarioActual = usuarioId;
    document.getElementById('hid_usuario').value = usuarioId;
    
    const select = document.getElementById('sel_usuario');
    const opcion = select.options[select.selectedIndex];
    const nombre = opcion ? opcion.text.split('(')[0].trim() : usuarioId;
    
    document.getElementById('info_nombre_usuario').textContent = nombre;
    document.getElementById('info_id_usuario').textContent = usuarioId;
    document.getElementById('usuario_seleccionado_info').style.display = 'block';
    
    try {
        const formData = new FormData();
        formData.append('action', 'get_menus_usuario');
        formData.append('id_usuario', usuarioId);
        
        const response = await fetch('ajax_accesos.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Limpiar todos
            document.querySelectorAll('.checkbox-custom').forEach(chk => chk.checked = false);
            
            // Marcar asignados
            if (data.menus_asignados && data.menus_asignados.length > 0) {
                data.menus_asignados.forEach(menuId => {
                    const chk = document.getElementById(`chk_${menuId}`);
                    if (chk) chk.checked = true;
                });
            }
            
            hasChanges = false;
            document.getElementById('btn_guardar').disabled = true;
            actualizarContadorGlobal();
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

// ============================================
// EVENTOS DE CONTROLES
// ============================================
document.getElementById('sel_usuario').addEventListener('change', function() {
    if (this.value) {
        cargarMenusUsuario(this.value);
    } else {
        usuarioActual = '';
        document.getElementById('hid_usuario').value = '';
        document.getElementById('usuario_seleccionado_info').style.display = 'none';
        document.querySelectorAll('.checkbox-custom').forEach(chk => chk.checked = false);
        hasChanges = false;
        document.getElementById('btn_guardar').disabled = true;
        actualizarContadorGlobal();
    }
});

document.getElementById('btn_todos').addEventListener('click', function() {
    if (!usuarioActual) return;
    document.querySelectorAll('.checkbox-custom').forEach(chk => chk.checked = true);
    actualizarContadorGlobal();
    habilitarGuardar();
});

document.getElementById('btn_ninguno').addEventListener('click', function() {
    if (!usuarioActual) return;
    document.querySelectorAll('.checkbox-custom').forEach(chk => chk.checked = false);
    actualizarContadorGlobal();
    habilitarGuardar();
});

document.getElementById('btn_limpiar').addEventListener('click', function() {
    document.getElementById('sel_usuario').value = '';
    document.getElementById('hid_usuario').value = '';
    document.getElementById('usuario_seleccionado_info').style.display = 'none';
    document.querySelectorAll('.checkbox-custom').forEach(chk => chk.checked = false);
    document.getElementById('buscar_menu').value = '';
    document.querySelectorAll('#tbody_menus tr').forEach(fila => fila.classList.remove('fila-oculta'));
    usuarioActual = '';
    hasChanges = false;
    document.getElementById('btn_guardar').disabled = true;
    actualizarContadorGlobal();
});

document.getElementById('buscar_menu').addEventListener('input', function() {
    const termino = this.value.toLowerCase().trim();
    document.querySelectorAll('#tbody_menus tr').forEach(fila => {
        const nombreCelda = fila.querySelector('.menu-nombre');
        if (!nombreCelda) return;
        const nombre = (nombreCelda.getAttribute('data-nombre') || '').toLowerCase();
        if (termino === '' || nombre.includes(termino)) {
            fila.classList.remove('fila-oculta');
        } else {
            fila.classList.add('fila-oculta');
        }
    });
});

document.getElementById('form_accesos').addEventListener('submit', function(e) {
    if (!usuarioActual) {
        e.preventDefault();
        alert('❌ Por favor, seleccione un usuario primero.');
        return;
    }
    const seleccionados = document.querySelectorAll('.checkbox-custom:checked').length;
    if (!confirm(`¿Guardar los cambios?\n\nSe asignarán ${seleccionados} menús.`)) {
        e.preventDefault();
    }
});


document.addEventListener('DOMContentLoaded', function() {
    asignarEventosCheckboxes();
    actualizarContadorGlobal();
});

const observer = new MutationObserver(function() {
    asignarEventosCheckboxes();
});
observer.observe(document.getElementById('tbody_menus'), { childList: true, subtree: true });
</script>