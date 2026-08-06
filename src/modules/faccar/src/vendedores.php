<?php
// ==================================================
// Módulo: Vendedores (ERP ADSO)
// Tabla: tab_vendedores (extiende tab_empleados y tab_terceros)
// ==================================================

$pageTitle        = 'ERP ADSO — Vendedores';
$activeModule     = 'vendedores';
$page_title       = "ADSOERP | Vendedores";
$page_description = "Maestro de vendedores, comisiones y ventas acumuladas";
$page_icon        = "bi-person-badge";
$page_extra_css   = ["../modules/faccar/css/vendedores.css"];
$page_extra_js    = ["../modules/faccar/js/vendedores.js"];
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
// PREPARAR CONSULTAS ADICIONALES (no están en prepare_faccar)
// ============================================================
try {
    // Insertar en tab_terceros (para crear el tercero asociado al empleado)
    $ins_tercero = $pdo->prepare(
        "INSERT INTO tab_terceros (
            id_tercero, nom_tercero, ind_tipo_tercero, id_cat_tercero,
            id_tipo, id_ciudad, id_restriccion,
            dir_tercero, ind_estado, ind_borrado
        ) VALUES (
            :id_tercero, :nom_tercero, 'true', 1,
            'CC', 1, 1,
            ROW(:email, :direccion, :tel_fijo, :id_prefijo_movil, :tel_movil),
            true, false
        )"
    );

    // Insertar en tab_empleados (para crear el empleado)
    $ins_empleado = $pdo->prepare(
        "INSERT INTO tab_empleados (id_empleado, id_cargo, ind_estado, ind_borrado)
         VALUES (:id_empleado, 1, true, false)"
    );

    // Actualizar tab_terceros (para editar nombre)
    $upd_tercero = $pdo->prepare(
        "UPDATE tab_terceros SET nom_tercero = :nom_tercero WHERE id_tercero = :id_tercero"
    );

    // Verificar si el ID ya existe en tab_terceros (para evitar duplicados)
    $check_tercero = $pdo->prepare("SELECT 1 FROM tab_terceros WHERE id_tercero = :id");

} catch (PDOException $e) {
    error_log("Error preparando consultas adicionales: " . $e->getMessage());
    die("Error crítico al preparar consultas. Revise los logs.");
}

// ============================================================
// MANEJO DE PETICIONES POST (SIEMPRE RESPONDEN CON JSON)
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');
    $respuesta = ['success' => false, 'message' => '', 'errors' => []];

    try {
        // ---------- NUEVO VENDEDOR ----------
        if (isset($_POST['btn_nuevo'])) {
            $id_vendedor = trim($_POST['txt_id_vendedor'] ?? '');
            $nombre      = trim($_POST['txt_nombre'] ?? '');
            $comision    = (int)($_POST['txt_comision'] ?? 0);
            $estado      = isset($_POST['chk_estado']) && $_POST['chk_estado'] === 'true';

            $errores = [];

            // Validaciones
            if (empty($id_vendedor) || strlen($id_vendedor) < 6) {
                $errores['err-id-vendedor'] = 'Identificación requerida (mín. 6 caracteres).';
            } else {
                // Verificar que no exista ya en tab_terceros (para evitar duplicados)
                $check_tercero->execute([':id' => $id_vendedor]);
                if ($check_tercero->fetch()) {
                    $errores['err-id-vendedor'] = 'Ya existe un vendedor con esa identificación.';
                }
            }
            if (empty($nombre)) {
                $errores['err-nombre'] = 'El nombre es obligatorio.';
            }
            if ($comision < 1 || $comision > 99) {
                $errores['err-comision'] = 'La comisión debe estar entre 1 y 99.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $pdo->beginTransaction();

            // 1. Insertar en tab_terceros
            $ins_tercero->execute([
                ':id_tercero'       => $id_vendedor,
                ':nom_tercero'      => $nombre,
                ':email'            => '',
                ':direccion'        => '',
                ':tel_fijo'         => null,
                ':id_prefijo_movil' => null,
                ':tel_movil'        => null,
            ]);

            // 2. Insertar en tab_empleados (cargo 1 = VENDEDOR)
            $ins_empleado->execute([':id_empleado' => $id_vendedor]);

            // 3. Insertar en tab_vendedores usando función almacenada
            $ins_vendedor->execute([
                ':id_vendedor' => $id_vendedor,
                ':porcomision' => $comision,
            ]);

            // 4. Actualizar estado si es inactivo (por defecto true)
            if (!$estado) {
                $upd_estado = $pdo->prepare("UPDATE tab_vendedores SET ind_estado = false WHERE id_vendedor = :id");
                $upd_estado->execute([':id' => $id_vendedor]);
            }

            $pdo->commit();

            $respuesta['success'] = true;
            $respuesta['message'] = 'Vendedor creado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- EDITAR VENDEDOR ----------
        if (isset($_POST['btn_editar'])) {
            $id_vendedor = trim($_POST['hid_id_vendedor'] ?? '');
            $nombre      = trim($_POST['txt_edit_nombre'] ?? '');
            $comision    = (int)($_POST['txt_edit_comision'] ?? 0);
            $estado      = isset($_POST['chk_edit_estado']) && $_POST['chk_edit_estado'] === 'true';

            $errores = [];

            if (empty($id_vendedor)) {
                $errores['err-edit-id'] = 'ID de vendedor no válido.';
            }
            if (empty($nombre)) {
                $errores['err-edit-nombre'] = 'El nombre es obligatorio.';
            }
            if ($comision < 1 || $comision > 99) {
                $errores['err-edit-comision'] = 'La comisión debe estar entre 1 y 99.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $pdo->beginTransaction();

            // 1. Actualizar nombre en tab_terceros
            $upd_tercero->execute([
                ':nom_tercero' => $nombre,
                ':id_tercero'  => $id_vendedor,
            ]);

            // 2. Actualizar vendedor usando función almacenada
            $upd_vendedor->execute([
                ':id_vendedor'  => $id_vendedor,
                ':porcomision'  => $comision,
                ':ind_estado'   => $estado ? 'true' : 'false',
            ]);

            $pdo->commit();

            $respuesta['success'] = true;
            $respuesta['message'] = 'Vendedor actualizado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- ELIMINAR (borrado lógico) ----------
        if (isset($_POST['btn_eliminar'])) {
            $id_vendedor = trim($_POST['hid_del_id'] ?? '');
            if (empty($id_vendedor)) {
                throw new Exception('ID de vendedor no válido.');
            }
            // La función `fun_delete_vendedor` realiza borrado lógico en tab_vendedores
            $del_vendedor->execute([':id_vendedor' => $id_vendedor]);

            // También se podría marcar borrado en tab_empleados y tab_terceros,
            // pero asumimos que la función lo maneja o se deja consistente.
            $respuesta['success'] = true;
            $respuesta['message'] = 'Vendedor eliminado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- TOGGLE DE ESTADO ----------
        if (isset($_POST['btn_toggle'])) {
            $id_vendedor = trim($_POST['hid_toggle_id'] ?? '');
            if (empty($id_vendedor)) {
                throw new Exception('ID de vendedor no válido.');
            }
            $toggle_vendedor->execute([':id_vendedor' => $id_vendedor]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Estado actualizado.';
            echo json_encode($respuesta);
            exit;
        }

        // Si no se reconoce ninguna acción
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
$list_vendedores_completo->execute();
$vendedores = $list_vendedores_completo->fetchAll(PDO::FETCH_ASSOC);

// Estadísticas
$total = count($vendedores);
$activos = count(array_filter($vendedores, fn($v) => $v['ind_estado'] === 't' || $v['ind_estado'] === true));
$comisionProm = $total > 0 ? round(array_sum(array_column($vendedores, 'val_porcomision')) / $total) : 0;
$acumulado = array_sum(array_column($vendedores, 'val_ven_acumu'));

// ============================================================
// INICIO DEL HTML
// ============================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-vendedores" class="app-view active">

    <!-- ENCABEZADO -->
    <div class="module-header">
        <div class="module-header-text">
            <h1>Vendedores</h1>
            <p>Comisiones y ventas acumuladas por vendedor</p>
        </div>
        <button id="btn-add-vendedor" class="btn btn-primary">
            <i class="fas fa-plus"></i> Nuevo Vendedor
        </button>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-user-tie"></i></div>
            <div class="stat-info">
                <div class="stat-label">Total</div>
                <div class="stat-value" id="stat-total"><?= $total ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div class="stat-info">
                <div class="stat-label">Activos</div>
                <div class="stat-value" id="stat-activos"><?= $activos ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="fas fa-percent"></i></div>
            <div class="stat-info">
                <div class="stat-label">Comisión Prom.</div>
                <div class="stat-value" id="stat-comision"><?= $comisionProm ?>%</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-chart-line"></i></div>
            <div class="stat-info">
                <div class="stat-label">Ventas Acum.</div>
                <div class="stat-value" id="stat-acumulado">$<?= number_format($acumulado, 0, ',', '.') ?></div>
            </div>
        </div>
    </div>

    <!-- FILTROS -->
    <div class="filter-bar">
        <div class="search-wrapper">
            <span class="search-icon"><i class="fas fa-search"></i></span>
            <input type="text" id="vendedor-search" class="search-input" placeholder="Buscar por nombre o identificación...">
        </div>
        <div class="filter-toggle-group">
            <button class="filter-toggle active" data-filter="all">Todos</button>
            <button class="filter-toggle" data-filter="active">Activos</button>
            <button class="filter-toggle" data-filter="inactive">Inactivos</button>
        </div>
        <button id="btn-clear-filters" class="btn-clear-filter" style="display:none">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="vendedor-count"><?= $total ?> resultado<?= $total !== 1 ? 's' : '' ?></span>
    </div>

    <!-- GRID DE VENDEDORES -->
    <div class="card-grid" id="vendedor-grid">
    <?php if (empty($vendedores)): ?>
        <div class="empty-state">
            <i class="fas fa-user-tie"></i>
            <p>Sin vendedores registrados</p>
            <span>Agrega el primer vendedor del sistema</span>
        </div>
    <?php else: ?>
        <?php foreach ($vendedores as $v):
            $es_activo = ($v['ind_estado'] === 't' || $v['ind_estado'] === true);
            $iniciales = implode('', array_map(fn($p) => strtoupper($p[0] ?? ''), explode(' ', $v['nom_tercero'])));
        ?>
        <div class="vendedor-card <?= !$es_activo ? 'inactive' : '' ?>" data-id="<?= htmlspecialchars($v['id_vendedor']) ?>">
            <div class="vendedor-card-top">
                <div class="vendedor-avatar"><?= htmlspecialchars($iniciales) ?></div>
                <div>
                    <div class="vendedor-nombre"><?= htmlspecialchars($v['nom_tercero']) ?></div>
                    <div class="vendedor-id">ID: <?= htmlspecialchars($v['id_vendedor']) ?></div>
                    <?php if ($es_activo): ?>
                        <span class="badge badge-success" style="margin-top:4px;">ACTIVO</span>
                    <?php else: ?>
                        <span class="badge badge-danger" style="margin-top:4px;">INACTIVO</span>
                    <?php endif; ?>
                </div>
            </div>
            <div class="vendedor-divider"></div>
            <div class="vendedor-metric-row">
                <div>
                    <div class="vendedor-metric-label">Ventas Acumuladas</div>
                    <div class="vendedor-acumulado">$<?= number_format($v['val_ven_acumu'] ?? 0, 0, ',', '.') ?></div>
                </div>
                <div class="vendedor-comision-pill"><?= $v['val_porcomision'] ?>%</div>
            </div>
            <div class="vendedor-action-btns">
                <button class="btn-icon-sm edit" data-id="<?= htmlspecialchars($v['id_vendedor']) ?>"><i class="fas fa-pen"></i></button>
                <button class="btn-icon-sm toggle" data-id="<?= htmlspecialchars($v['id_vendedor']) ?>">
                    <i class="fas <?= $es_activo ? 'fa-toggle-on' : 'fa-toggle-off' ?>"></i>
                </button>
                <button class="btn-icon-sm reject" data-id="<?= htmlspecialchars($v['id_vendedor']) ?>"><i class="fas fa-trash"></i></button>
            </div>
        </div>
        <?php endforeach; ?>
    <?php endif; ?>
    </div>
</div>

<!-- MODAL NUEVO VENDEDOR -->
<div id="modal-new-vendedor" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="modal-header green">
            <div>
                <h2>Nuevo Vendedor</h2>
                <p>Ingrese los datos del vendedor</p>
            </div>
            <button class="modal-close btn-close-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="new-vendedor-form" novalidate>
                <input type="hidden" name="btn_nuevo" value="1">

                <div class="form-field">
                    <label class="form-label">Nombre Completo <span class="required">*</span></label>
                    <input type="text" id="new-vendedor-nombre" name="txt_nombre" class="form-input" placeholder="Ej: Carlos Ramírez">
                    <span class="field-error" id="err-nombre"></span>
                </div>
                <div class="form-field">
                    <label class="form-label">N° Identificación <span class="required">*</span></label>
                    <input type="text" id="new-vendedor-id" name="txt_id_vendedor" class="form-input" maxlength="10" placeholder="Mín. 6 caracteres">
                    <span class="field-error" id="err-id-vendedor"></span>
                </div>
                <div class="form-field">
                    <label class="form-label">% Comisión <span class="required">*</span></label>
                    <input type="number" id="new-vendedor-comision" name="txt_comision" class="form-input" min="1" max="99" placeholder="1-99">
                    <span class="field-error" id="err-comision"></span>
                </div>
                <div class="toggle-row">
                    <div>
                        <div class="toggle-label-text">Estado del Vendedor</div>
                        <div class="toggle-status active" id="new-vendedor-toggle-status">ACTIVO</div>
                    </div>
                    <div class="toggle-switch on" id="new-vendedor-toggle-switch">
                        <div class="toggle-thumb"></div>
                    </div>
                </div>
                <input type="hidden" id="new-vendedor-estado" name="chk_estado" value="true">

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-close-modal">Cancelar</button>
                    <button type="submit" class="btn btn-success"><i class="fas fa-save"></i> Agregar Vendedor</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL EDITAR VENDEDOR -->
<div id="modal-edit-vendedor" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="modal-header blue">
            <div>
                <h2>Editar Vendedor</h2>
                <p>Modifique los datos del vendedor</p>
            </div>
            <button class="modal-close btn-close-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="edit-vendedor-form" novalidate>
                <input type="hidden" name="btn_editar" value="1">
                <input type="hidden" name="hid_id_vendedor" id="edit-vendedor-hid" value="">

                <div class="toggle-row">
                    <div>
                        <div class="toggle-label-text">Estado del Vendedor</div>
                        <div class="toggle-status active" id="edit-vendedor-toggle-status">ACTIVO</div>
                    </div>
                    <div class="toggle-switch on" id="edit-vendedor-toggle-switch">
                        <div class="toggle-thumb"></div>
                    </div>
                </div>
                <input type="hidden" id="edit-vendedor-estado" name="chk_edit_estado" value="true">

                <div class="form-field">
                    <label class="form-label">Nombre Completo <span class="required">*</span></label>
                    <input type="text" id="edit-vendedor-nombre" name="txt_edit_nombre" class="form-input">
                    <span class="field-error" id="err-edit-nombre"></span>
                </div>
                <div class="form-field">
                    <label class="form-label">N° Identificación</label>
                    <input type="text" id="edit-vendedor-id" class="form-input" readonly disabled>
                </div>
                <div class="form-field">
                    <label class="form-label">% Comisión <span class="required">*</span></label>
                    <input type="number" id="edit-vendedor-comision" name="txt_edit_comision" class="form-input" min="1" max="99">
                    <span class="field-error" id="err-edit-comision"></span>
                </div>
                <div class="form-field">
                    <label class="form-label">Ventas Acumuladas</label>
                    <input type="text" id="edit-vendedor-acumulado" class="form-input" readonly disabled>
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
    const vendedoresData = <?= json_encode(array_values($vendedores), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>;
</script>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>