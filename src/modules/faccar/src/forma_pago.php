<?php
// ==================================================
// Módulo: Forma de Pago (ERP ADSO)
// ==================================================

$pageTitle        = 'ERP ADSO — Forma de Pago';
$activeModule     = 'forma_pago';
$page_title       = "ADSOERP | Forma de Pago";
$page_description = "Catálogo de formas de pago admitidas en facturación";
$page_icon        = "bi-credit-card";
$page_extra_css   = ["../modules/faccar/css/forma_pago.css"];
$page_extra_js    = ["../modules/faccar/js/forma_pago.js"];
$show_welcome     = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare_faccar.php');

// ============================================================
// LIMPIAR MENSAJE DE ERROR DE POSTGRESQL
// ============================================================
function limpiar_error_pgsql(string $msg): string {
    if (preg_match('/ERROR:\s*ERROR:\s*(.+?)(?:\s+CONTEXT:|$)/s', $msg, $m)) {
        return trim($m[1]);
    }
    if (preg_match('/ERROR:\s*(.+?)(?:\s+CONTEXT:|$)/s', $msg, $m)) {
        return trim($m[1]);
    }
    return $msg;
}

// ============================================================
// MANEJO DE PETICIONES POST (SIEMPRE RESPONDEN CON JSON)
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');
    $respuesta = ['success' => false, 'message' => '', 'errors' => []];

    try {
        // ---------- NUEVA FORMA DE PAGO ----------
        if (isset($_POST['btn_nuevo'])) {
            $codigo = (int)($_POST['txt_codigo'] ?? -1);
            $nombre = trim($_POST['txt_nombre'] ?? '');

            $errores = [];

            if ($codigo < 0 || $codigo > 9) {
                $errores['err-codigo-cliente'] = 'El código debe ser un dígito entre 0 y 9.';
            } else {
                // Verificar que el código no exista ya (activo o eliminado)
                $check = $pdo->prepare("SELECT 1 FROM tab_forma_pagos WHERE id_formapago = :id");
                $check->execute([':id' => $codigo]);
                if ($check->fetch()) {
                    $errores['err-codigo-cliente'] = 'El código ya está registrado.';
                }
            }
            if (strlen($nombre) < 3) {
                $errores['err-nombre-cliente'] = 'El nombre debe tener al menos 3 caracteres.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            // Insertar usando la función almacenada
            $ins_formapago->execute([
                ':id_formapago' => $codigo,
                ':nom_formapago' => $nombre,
            ]);

            $respuesta['success'] = true;
            $respuesta['message'] = 'Forma de pago creada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- EDITAR FORMA DE PAGO ----------
        if (isset($_POST['btn_editar'])) {
            $codigo = (int)($_POST['hid_id_formapago'] ?? -1);
            $nombre = trim($_POST['txt_edit_nombre'] ?? '');

            $errores = [];

            if ($codigo < 0 || $codigo > 9) {
                $errores['err-edit-id'] = 'Código no válido.';
            }
            if (strlen($nombre) < 3) {
                $errores['err-edit-nombre'] = 'El nombre debe tener al menos 3 caracteres.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $upd_formapago->execute([
                ':id_formapago' => $codigo,
                ':nom_formapago' => $nombre,
            ]);

            $respuesta['success'] = true;
            $respuesta['message'] = 'Forma de pago actualizada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- ELIMINAR (borrado lógico) ----------
        if (isset($_POST['btn_eliminar'])) {
            $codigo = (int)($_POST['hid_del_id'] ?? -1);
            if ($codigo < 0 || $codigo > 9) {
                throw new Exception('Código de forma de pago no válido.');
            }
            $del_formapago->execute([':id_formapago' => $codigo]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Forma de pago eliminada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- RESTAURAR (cambiar ind_borrado a FALSE) ----------
        if (isset($_POST['btn_restaurar'])) {
            $codigo = (int)($_POST['hid_restore_id'] ?? -1);
            if ($codigo < 0 || $codigo > 9) {
                throw new Exception('Código de forma de pago no válido.');
            }
            $restore = $pdo->prepare("UPDATE tab_forma_pagos SET ind_borrado = FALSE WHERE id_formapago = :id");
            $restore->execute([':id' => $codigo]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Forma de pago restaurada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        $respuesta['message'] = 'Acción no válida.';
        echo json_encode($respuesta);
        exit;

    } catch (Exception $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        $mensaje = limpiar_error_pgsql($e->getMessage());
        if (empty($mensaje)) {
            $mensaje = $e->getMessage();
        }
        $respuesta['message'] = $mensaje;
        echo json_encode($respuesta);
        exit;
    }
}

// ============================================================
// CARGAR DATOS PARA LA VISTA INICIAL
// ============================================================
$list_formas_pago_completo->execute();
$formas = $list_formas_pago_completo->fetchAll(PDO::FETCH_ASSOC);

// ============================================================
// INICIO DEL HTML
// ============================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-formapago" class="app-view active">

    <!-- ENCABEZADO -->
    <div class="module-header">
        <div class="module-header-text">
            <h1>Formas de Pago</h1>
            <p>Catálogo de medios de pago disponibles para facturas y cotizaciones</p>
        </div>
        <button id="btn-add-fp" class="btn btn-primary">
            <i class="fas fa-plus"></i> Nueva Forma de Pago
        </button>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <?php
        $total      = count($formas);
        $activas    = count(array_filter($formas, fn($f) => $f['ind_borrado'] === 'f' || $f['ind_borrado'] === false));
        $eliminadas = $total - $activas;
        ?>
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-credit-card"></i></div>
            <div class="stat-info">
                <div class="stat-label">Total</div>
                <div class="stat-value" id="stat-total"><?= $total ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div class="stat-info">
                <div class="stat-label">Activas</div>
                <div class="stat-value" id="stat-activas"><?= $activas ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-trash-can"></i></div>
            <div class="stat-info">
                <div class="stat-label">Eliminadas</div>
                <div class="stat-value" id="stat-eliminadas"><?= $eliminadas ?></div>
            </div>
        </div>
    </div>

    <!-- FILTROS -->
    <div class="filter-bar">
        <div class="search-wrapper">
            <span class="search-icon"><i class="fas fa-search"></i></span>
            <input type="text" id="fp-search" class="search-input" placeholder="Buscar por código o nombre...">
        </div>
        <div class="filter-toggle-group">
            <button class="filter-toggle active" data-filter="all">Todos</button>
            <button class="filter-toggle" data-filter="active">Activas</button>
            <button class="filter-toggle" data-filter="inactive">Eliminadas</button>
        </div>
        <button id="btn-clear-filters" class="btn-clear-filter" style="display:none">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="fp-count"><?= $total ?> resultado<?= $total !== 1 ? 's' : '' ?></span>
    </div>

    <!-- TABLA -->
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="90">Código</th>
                    <th>Nombre</th>
                    <th width="120">Estado</th>
                    <th width="150">Acciones</th>
                </tr>
            </thead>
            <tbody id="fp-tbody">
            <?php if (empty($formas)): ?>
                <tr class="empty-row">
                    <td colspan="4">
                        <div class="empty-state">
                            <i class="fas fa-credit-card"></i>
                            <p>No hay formas de pago registradas</p>
                            <span>Agrega la primera forma de pago del sistema</span>
                        </div>
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($formas as $f):
                    $es_activa = ($f['ind_borrado'] === 'f' || $f['ind_borrado'] === false);
                    $badge = $es_activa
                        ? '<span class="badge badge-active">Activa</span>'
                        : '<span class="badge badge-inactive">Eliminada</span>';
                ?>
                <tr data-codigo="<?= $f['id_formapago'] ?>">
                    <td><strong><?= htmlspecialchars($f['id_formapago']) ?></strong></td>
                    <td><?= htmlspecialchars($f['nom_formapago']) ?></td>
                    <td><?= $badge ?></td>
                    <td>
                        <div class="row-actions">
                            <button class="btn-icon-sm edit" data-codigo="<?= $f['id_formapago'] ?>"><i class="fas fa-edit"></i></button>
                            <?php if ($es_activa): ?>
                                <button class="btn-icon-sm reject" data-codigo="<?= $f['id_formapago'] ?>"><i class="fas fa-trash"></i></button>
                            <?php else: ?>
                                <button class="btn-icon-sm toggle" data-codigo="<?= $f['id_formapago'] ?>"><i class="fas fa-undo-alt"></i></button>
                            <?php endif; ?>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL NUEVA FORMA DE PAGO -->
<div id="modal-new-fp" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="modal-header green">
            <div>
                <h2>Nueva Forma de Pago</h2>
                <p>Complete la información del medio de pago</p>
            </div>
            <button class="modal-close btn-close-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="new-fp-form" novalidate>
                <input type="hidden" name="btn_nuevo" value="1">
                <div class="form-field">
                    <label class="form-label">Código (0-9) <span class="required">*</span></label>
                    <input type="text" inputmode="numeric" id="new-fp-codigo" name="txt_codigo" class="form-input" maxlength="1" placeholder="Ej: 1">
                    <span class="field-error" id="err-codigo-cliente"></span>
                </div>
                <div class="form-field">
                    <label class="form-label">Nombre <span class="required">*</span></label>
                    <input type="text" id="new-fp-nombre" name="txt_nombre" class="form-input" placeholder="Ej: Efectivo">
                    <span class="field-error" id="err-nombre-cliente"></span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-close-modal">Cancelar</button>
                    <button type="submit" class="btn btn-success"><i class="fas fa-save"></i> Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL EDITAR FORMA DE PAGO -->
<div id="modal-edit-fp" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="modal-header blue">
            <div>
                <h2>Editar Forma de Pago</h2>
                <p>Modifique el nombre de la forma de pago</p>
            </div>
            <button class="modal-close btn-close-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="edit-fp-form" novalidate>
                <input type="hidden" name="btn_editar" value="1">
                <input type="hidden" name="hid_id_formapago" id="edit-fp-hid-codigo" value="">
                <div class="form-field">
                    <label class="form-label">Código</label>
                    <input type="text" id="edit-fp-codigo" class="form-input" readonly disabled>
                </div>
                <div class="form-field">
                    <label class="form-label">Nombre <span class="required">*</span></label>
                    <input type="text" id="edit-fp-nombre" name="txt_edit_nombre" class="form-input" placeholder="Ej: Efectivo">
                    <span class="field-error" id="err-edit-nombre"></span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-close-modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Guardar Cambios</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL CONFIRMACIÓN -->
<div id="modal-confirm" class="modal-overlay hidden">
    <div class="modal-box confirm-box">
        <div class="confirm-icon"><i class="fas fa-exclamation-triangle"></i></div>
        <h4 id="confirm-title"></h4>
        <p id="confirm-body"></p>
        <div class="confirm-buttons">
            <button class="btn btn-secondary" id="confirm-cancel-btn">Cancelar</button>
            <button class="btn btn-danger" id="confirm-ok-btn">Confirmar</button>
        </div>
    </div>
</div>

<!-- TOAST -->
<div id="toast" class="hidden"><span id="toast-message"></span></div>

<script>
    const formasPagoData = <?= json_encode(array_values($formas), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>;
</script>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>