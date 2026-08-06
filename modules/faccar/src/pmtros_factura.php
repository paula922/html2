<?php
// ==================================================
// Módulo: Parámetros de Facturación (ERP ADSO)
// Tabla: tab_pmtros_facturacion
// ==================================================

$pageTitle        = 'ERP ADSO — Parámetros de Facturación';
$activeModule     = 'parametros';
$page_title       = "ADSOERP | Parámetros";
$page_description = "Resoluciones de facturación, rangos autorizados y parámetros de cartera";
$page_icon        = "bi-sliders";
$page_extra_css   = ["../modules/faccar/css/pmtros_factura.css"];
$page_extra_js    = ["../modules/faccar/js/pmtros_factura.js"];
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
        // ---------- NUEVA RESOLUCIÓN ----------
        if (isset($_POST['btn_nuevo'])) {
            $id_empresa       = trim($_POST['txt_id_empresa'] ?? '');
            $val_res_aut      = trim($_POST['txt_res_aut'] ?? '');
            $fec_res_aut      = $_POST['txt_fec_res'] ?? '';
            $fec_venc         = $_POST['txt_fec_venc'] ?? '';
            $val_prefijofac   = trim($_POST['txt_prefijofac'] ?? '');
            $val_facini       = (int)($_POST['txt_facini'] ?? 0);
            $val_facactual    = $val_facini;
            $val_facfin       = (int)($_POST['txt_facfin'] ?? 0);
            $val_prefijocot   = trim($_POST['txt_prefijocot'] ?? '');
            $val_cotini       = (int)($_POST['txt_cotini'] ?? 0);
            $val_cotactual    = $val_cotini;
            $val_porreteica   = (float)($_POST['txt_reteica'] ?? 0);
            $val_intcorriente = (float)($_POST['txt_intcorriente'] ?? 0);
            $val_pesosXpuntos = (int)($_POST['txt_pesospuntos'] ?? 0);
            $val_interesmora  = (float)($_POST['txt_interesmora'] ?? 0);
            $val_diascartera  = (int)($_POST['txt_diascartera'] ?? 0);

            $errores = [];

            if (empty($id_empresa) || strlen($id_empresa) > 10) {
                $errores['err-id-empresa'] = 'Id. empresa requerido (máx. 10 caracteres).';
            } else {
                $check = $pdo->prepare("SELECT 1 FROM tab_pmtros_facturacion WHERE id_empresa = :id AND ind_borrado = FALSE");
                $check->execute([':id' => $id_empresa]);
                if ($check->fetch()) {
                    $errores['err-id-empresa'] = 'Ya existe una resolución para esta empresa.';
                }
            }
            if (!preg_match('/^\d{13}$/', $val_res_aut)) {
                $errores['err-res-aut'] = 'N° Resolución debe tener exactamente 13 dígitos.';
            }
            if (empty($fec_res_aut)) {
                $errores['err-fec-res'] = 'Fecha de resolución requerida.';
            }
            if (empty($fec_venc)) {
                $errores['err-fec-venc'] = 'Fecha de vencimiento requerida.';
            }
            if ($fec_res_aut && $fec_venc && $fec_venc < $fec_res_aut) {
                $errores['err-fec-venc'] = 'Fecha de vencimiento debe ser igual o posterior a la de resolución.';
            }
            if (empty($val_prefijofac) || strlen($val_prefijofac) > 4) {
                $errores['err-prefijofac'] = 'Prefijo de factura de 1 a 4 caracteres.';
            }
            if ($val_facini <= 0) {
                $errores['err-facini'] = 'N° inicial debe ser mayor a 0.';
            }
            if ($val_facfin <= 0 || $val_facfin <= $val_facini) {
                $errores['err-facfin'] = 'N° final debe ser mayor al inicial.';
            }
            if (empty($val_prefijocot) || strlen($val_prefijocot) > 4) {
                $errores['err-prefijocot'] = 'Prefijo de cotización de 1 a 4 caracteres.';
            }
            if ($val_cotini <= 0) {
                $errores['err-cotini'] = 'N° inicial de cotización debe ser mayor a 0.';
            }
            if ($val_porreteica < 0 || $val_porreteica > 99) {
                $errores['err-reteica'] = 'Retención ICA entre 0 y 99.';
            }
            if ($val_intcorriente < 0 || $val_intcorriente > 99) {
                $errores['err-intcorriente'] = 'Interés corriente entre 0 y 99.';
            }
            if ($val_interesmora < 0 || $val_interesmora > 100) {
                $errores['err-interesmora'] = 'Interés por mora entre 0 y 100.';
            }
            if ($val_diascartera < 0 || $val_diascartera > 180) {
                $errores['err-diascartera'] = 'Días de cartera entre 0 y 180.';
            }
            if ($val_pesosXpuntos <= 0) {
                $errores['err-pesospuntos'] = 'Pesos por punto debe ser mayor a 0.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $ins_pmtros_facturacion->execute([
                ':id_empresa'       => $id_empresa,
                ':val_res_aut'      => $val_res_aut,
                ':fec_venc'         => $fec_venc,
                ':fec_res_aut'      => $fec_res_aut,
                ':val_prefijofac'   => $val_prefijofac,
                ':val_facini'       => $val_facini,
                ':val_facactual'    => $val_facactual,
                ':val_facfin'       => $val_facfin,
                ':val_prefijocot'   => $val_prefijocot,
                ':val_cotini'       => $val_cotini,
                ':val_cotactual'    => $val_cotactual,
                ':val_porreteica'   => $val_porreteica,
                ':val_intcorriente' => $val_intcorriente,
                ':val_pesosXpuntos' => $val_pesosXpuntos,
                ':val_interesmora'  => $val_interesmora,
                ':val_diascartera'  => $val_diascartera,
            ]);

            $respuesta['success'] = true;
            $respuesta['message'] = 'Resolución creada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- EDITAR RESOLUCIÓN ----------
        if (isset($_POST['btn_editar'])) {
            $id_empresa       = trim($_POST['hid_id_empresa'] ?? '');
            $val_res_aut      = trim($_POST['txt_edit_res_aut'] ?? '');
            $fec_res_aut      = $_POST['txt_edit_fec_res'] ?? '';
            $fec_venc         = $_POST['txt_edit_fec_venc'] ?? '';
            $val_prefijofac   = trim($_POST['txt_edit_prefijofac'] ?? '');
            $val_facini       = (int)($_POST['txt_edit_facini'] ?? 0);
            $val_facactual    = (int)($_POST['txt_edit_facactual'] ?? 0);
            $val_facfin       = (int)($_POST['txt_edit_facfin'] ?? 0);
            $val_prefijocot   = trim($_POST['txt_edit_prefijocot'] ?? '');
            $val_cotini       = (int)($_POST['txt_edit_cotini'] ?? 0);
            $val_cotactual    = (int)($_POST['txt_edit_cotactual'] ?? 0);
            $val_porreteica   = (float)($_POST['txt_edit_reteica'] ?? 0);
            $val_intcorriente = (float)($_POST['txt_edit_intcorriente'] ?? 0);
            $val_pesosXpuntos = (int)($_POST['txt_edit_pesospuntos'] ?? 0);
            $val_interesmora  = (float)($_POST['txt_edit_interesmora'] ?? 0);
            $val_diascartera  = (int)($_POST['txt_edit_diascartera'] ?? 0);

            $errores = [];

            if (empty($id_empresa)) {
                $errores['err-edit-id'] = 'Id. empresa no válido.';
            }
            if (!preg_match('/^\d{13}$/', $val_res_aut)) {
                $errores['err-edit-res-aut'] = 'N° Resolución debe tener exactamente 13 dígitos.';
            }
            if (empty($fec_res_aut)) {
                $errores['err-edit-fec-res'] = 'Fecha de resolución requerida.';
            }
            if (empty($fec_venc)) {
                $errores['err-edit-fec-venc'] = 'Fecha de vencimiento requerida.';
            }
            if ($fec_res_aut && $fec_venc && $fec_venc < $fec_res_aut) {
                $errores['err-edit-fec-venc'] = 'Fecha de vencimiento debe ser igual o posterior a la de resolución.';
            }
            if (empty($val_prefijofac) || strlen($val_prefijofac) > 4) {
                $errores['err-edit-prefijofac'] = 'Prefijo de factura de 1 a 4 caracteres.';
            }
            if ($val_facini <= 0) {
                $errores['err-edit-facini'] = 'N° inicial debe ser mayor a 0.';
            }
            if ($val_facfin <= 0 || $val_facfin <= $val_facini) {
                $errores['err-edit-facfin'] = 'N° final debe ser mayor al inicial.';
            }
            if ($val_facactual < $val_facini || $val_facactual > $val_facfin) {
                $errores['err-edit-facactual'] = 'N° actual debe estar entre inicial y final.';
            }
            if (empty($val_prefijocot) || strlen($val_prefijocot) > 4) {
                $errores['err-edit-prefijocot'] = 'Prefijo de cotización de 1 a 4 caracteres.';
            }
            if ($val_cotini <= 0) {
                $errores['err-edit-cotini'] = 'N° inicial de cotización debe ser mayor a 0.';
            }
            if ($val_cotactual < $val_cotini) {
                $errores['err-edit-cotactual'] = 'N° actual de cotización debe ser mayor o igual al inicial.';
            }
            if ($val_porreteica < 0 || $val_porreteica > 99) {
                $errores['err-edit-reteica'] = 'Retención ICA entre 0 y 99.';
            }
            if ($val_intcorriente < 0 || $val_intcorriente > 99) {
                $errores['err-edit-intcorriente'] = 'Interés corriente entre 0 y 99.';
            }
            if ($val_interesmora < 0 || $val_interesmora > 100) {
                $errores['err-edit-interesmora'] = 'Interés por mora entre 0 y 100.';
            }
            if ($val_diascartera < 0 || $val_diascartera > 180) {
                $errores['err-edit-diascartera'] = 'Días de cartera entre 0 y 180.';
            }
            if ($val_pesosXpuntos <= 0) {
                $errores['err-edit-pesospuntos'] = 'Pesos por punto debe ser mayor a 0.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $upd_pmtros_facturacion->execute([
                ':id_empresa'       => $id_empresa,
                ':val_res_aut'      => $val_res_aut,
                ':fec_venc'         => $fec_venc,
                ':fec_res_aut'      => $fec_res_aut,
                ':val_prefijofac'   => $val_prefijofac,
                ':val_facini'       => $val_facini,
                ':val_facactual'    => $val_facactual,
                ':val_facfin'       => $val_facfin,
                ':val_prefijocot'   => $val_prefijocot,
                ':val_cotini'       => $val_cotini,
                ':val_cotactual'    => $val_cotactual,
                ':val_porreteica'   => $val_porreteica,
                ':val_intcorriente' => $val_intcorriente,
                ':val_pesosXpuntos' => $val_pesosXpuntos,
                ':val_interesmora'  => $val_interesmora,
                ':val_diascartera'  => $val_diascartera,
            ]);

            $respuesta['success'] = true;
            $respuesta['message'] = 'Resolución actualizada correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- ELIMINAR ----------
        if (isset($_POST['btn_eliminar'])) {
            $id_empresa = trim($_POST['hid_del_id'] ?? '');
            if (empty($id_empresa)) {
                throw new Exception('Id. empresa no válido.');
            }
            $del_pmtros_facturacion->execute([':id_empresa' => $id_empresa]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Resolución eliminada correctamente.';
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
// FUNCIONES DE AYUDA
// ============================================================
function estadoResolucion($fecVenc) {
    $hoy = new DateTime();
    $venc = new DateTime($fecVenc);
    $dias = $hoy->diff($venc)->days;
    if ($venc < $hoy) return 'Vencida';
    if ($dias <= 30) return 'Por Vencer';
    return 'Vigente';
}

function fmtDate($fecha) {
    if (empty($fecha)) return '—';
    $d = new DateTime($fecha);
    return $d->format('d/m/Y');
}

// ============================================================
// CARGAR DATOS
// ============================================================
$list_pmtros_facturacion->execute();
$parametros = $list_pmtros_facturacion->fetchAll(PDO::FETCH_ASSOC);

$total = count($parametros);
$vigentes = 0; $porVencer = 0; $vencidas = 0;
foreach ($parametros as $p) {
    $est = estadoResolucion($p['fec_venc']);
    if ($est === 'Vigente') $vigentes++;
    elseif ($est === 'Por Vencer') $porVencer++;
    else $vencidas++;
}

// ============================================================
// INICIO DEL HTML
// ============================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div class="crud-puc-container" id="mod-parametros">

    <!-- ENCABEZADO -->
    <div class="crud-header">
        <div class="crud-title">
            <h2><i class="fas fa-sliders-h"></i> Parámetros de Facturación</h2>
            <p>Resoluciones DIAN, rangos numéricos y parámetros financieros por empresa</p>
        </div>
        <button class="btn-add" id="btn-add-param">
            <i class="fas fa-plus"></i> Nueva Resolución
        </button>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-file-invoice"></i></div>
            <div class="stat-info">
                <div class="stat-label">Resoluciones</div>
                <div class="stat-value" id="stat-total"><?= $total ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div class="stat-info">
                <div class="stat-label">Vigentes</div>
                <div class="stat-value" id="stat-vigentes"><?= $vigentes ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-hourglass-half"></i></div>
            <div class="stat-info">
                <div class="stat-label">Por Vencer (30d)</div>
                <div class="stat-value" id="stat-porvencer"><?= $porVencer ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-ban"></i></div>
            <div class="stat-info">
                <div class="stat-label">Vencidas</div>
                <div class="stat-value" id="stat-vencidas"><?= $vencidas ?></div>
            </div>
        </div>
    </div>

    <!-- FILTROS -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="param-search" placeholder="Buscar por empresa o prefijo..." oninput="aplicarFiltros()">
        </div>
        <select id="filter-estado" class="filter-select" onchange="aplicarFiltros()">
            <option value="all">Todos los estados</option>
            <option value="Vigente">Vigente</option>
            <option value="Por Vencer">Por Vencer</option>
            <option value="Vencida">Vencida</option>
        </select>
        <button id="btn-clear-filters" class="btn-clear-filter" style="display: none;" onclick="limpiarFiltros()">
            <i class="fas fa-times"></i> Limpiar Filtros
        </button>
        <span class="filter-info" id="param-count"><?= $total ?> resultado<?= $total !== 1 ? 's' : '' ?></span>
    </div>

    <!-- TABLA -->
    <div class="table-container">
        <div class="scroll-lista-custom">
            <table class="table-custom" id="tablaParametros">
                <thead>
                    <tr>
                        <th>Empresa</th>
                        <th>Resolución</th>
                        <th>Facturas</th>
                        <th>Cotizaciones</th>
                        <th>Días Cartera</th>
                        <th>Vencimiento</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="param-tbody">
                <?php if (empty($parametros)): ?>
                    <tr class="empty-row">
                        <td colspan="7">
                            <div class="empty-state">
                                <i class="fas fa-file-invoice"></i>
                                <p>Sin resoluciones registradas</p>
                                <span>Crea la primera resolución de facturación</span>
                            </div>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($parametros as $p):
                        $est = estadoResolucion($p['fec_venc']);
                        $badge = '<span class="status-badge activo">VIGENTE</span>';
                        if ($est === 'Por Vencer') $badge = '<span class="status-badge warning">POR VENCER</span>';
                        elseif ($est === 'Vencida') $badge = '<span class="status-badge inactivo">VENCIDA</span>';
                    ?>
                    <tr data-id="<?= htmlspecialchars($p['id_empresa']) ?>" data-estado="<?= $est ?>">
                        <td data-label="Empresa"><strong><?= htmlspecialchars($p['id_empresa']) ?></strong></td>
                        <td data-label="Resolución"><?= htmlspecialchars($p['val_res_aut']) ?></td>
                        <td data-label="Facturas"><?= htmlspecialchars($p['val_prefijofac']) ?> <?= $p['val_facini'] ?>–<?= $p['val_facfin'] ?></td>
                        <td data-label="Cotizaciones"><?= htmlspecialchars($p['val_prefijocot']) ?> desde <?= $p['val_cotini'] ?></td>
                        <td data-label="Días Cartera"><?= $p['val_diascartera'] ?> días</td>
                        <td data-label="Vencimiento"><?= fmtDate($p['fec_venc']) ?> <?= $badge ?></td>
                        <td data-label="Acciones">
                            <div class="row-actions">
                                <button class="btn-icon edit" data-id="<?= htmlspecialchars($p['id_empresa']) ?>" title="Editar"><i class="fas fa-edit"></i></button>
                                <button class="btn-icon delete" data-id="<?= htmlspecialchars($p['id_empresa']) ?>" title="Eliminar"><i class="fas fa-trash"></i></button>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- MODAL NUEVA / EDITAR RESOLUCIÓN (OCULTO POR DEFECTO) -->
<div class="modal-overlay" id="modalOverlay" style="display: none !important;" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="fas fa-plus-circle"></i> Nueva Resolución</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-card-body">
            <form id="param-form" method="POST" novalidate>
                <input type="hidden" name="btn_nuevo" id="hid-btn-nuevo" value="1">
                <input type="hidden" name="btn_editar" id="hid-btn-editar" value="">
                <input type="hidden" name="hid_id_empresa" id="hid-id-empresa" value="">

                <div class="form-section-title">Identificación</div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Id. Empresa <span class="required">*</span></label>
                        <input type="text" id="param-id-empresa" name="txt_id_empresa" class="form-control-sm" maxlength="10" placeholder="Ej: EMP001">
                        <div class="validation-feedback" id="err-id-empresa"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">N° Resolución DIAN <span class="required">*</span></label>
                        <input type="text" inputmode="numeric" id="param-res-aut" name="txt_res_aut" class="form-control-sm" maxlength="13" placeholder="13 dígitos">
                        <div class="validation-feedback" id="err-res-aut"></div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Fecha de Resolución <span class="required">*</span></label>
                        <input type="date" id="param-fec-res" name="txt_fec_res" class="form-control-sm">
                        <div class="validation-feedback" id="err-fec-res"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">Fecha de Vencimiento <span class="required">*</span></label>
                        <input type="date" id="param-fec-venc" name="txt_fec_venc" class="form-control-sm">
                        <div class="validation-feedback" id="err-fec-venc"></div>
                    </div>
                </div>

                <div class="form-section-title">Rango de Facturación</div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Prefijo <span class="required">*</span></label>
                        <input type="text" id="param-prefijofac" name="txt_prefijofac" class="form-control-sm" maxlength="4" placeholder="Ej: FE">
                        <div class="validation-feedback" id="err-prefijofac"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">N° Inicial <span class="required">*</span></label>
                        <input type="number" id="param-facini" name="txt_facini" class="form-control-sm" min="1">
                        <div class="validation-feedback" id="err-facini"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">N° Final <span class="required">*</span></label>
                        <input type="number" id="param-facfin" name="txt_facfin" class="form-control-sm" min="1">
                        <div class="validation-feedback" id="err-facfin"></div>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label-custom">N° Actual (actualmente en uso)</label>
                    <input type="number" id="param-facactual" name="txt_facactual" class="form-control-sm" min="1">
                    <div class="validation-feedback" id="err-facactual"></div>
                    <small class="text-muted">En nuevo registro se asigna igual al N° Inicial.</small>
                </div>

                <div class="form-section-title">Rango de Cotización</div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Prefijo <span class="required">*</span></label>
                        <input type="text" id="param-prefijocot" name="txt_prefijocot" class="form-control-sm" maxlength="4" placeholder="Ej: COT">
                        <div class="validation-feedback" id="err-prefijocot"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">N° Inicial <span class="required">*</span></label>
                        <input type="number" id="param-cotini" name="txt_cotini" class="form-control-sm" min="1">
                        <div class="validation-feedback" id="err-cotini"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">N° Actual (cotizaciones)</label>
                        <input type="number" id="param-cotactual" name="txt_cotactual" class="form-control-sm" min="1">
                        <div class="validation-feedback" id="err-cotactual"></div>
                        <small class="text-muted">En nuevo registro se asigna igual al N° Inicial.</small>
                    </div>
                </div>

                <div class="form-section-title">Parámetros Financieros</div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Retención ICA (%) <span class="required">*</span></label>
                        <input type="number" id="param-reteica" name="txt_reteica" class="form-control-sm" min="0" max="99" step="0.01">
                        <div class="validation-feedback" id="err-reteica"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">Interés Corriente (%) <span class="required">*</span></label>
                        <input type="number" id="param-intcorriente" name="txt_intcorriente" class="form-control-sm" min="0" max="99" step="0.01">
                        <div class="validation-feedback" id="err-intcorriente"></div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Interés por Mora (%) <span class="required">*</span></label>
                        <input type="number" id="param-interesmora" name="txt_interesmora" class="form-control-sm" min="0" max="100" step="0.01">
                        <div class="validation-feedback" id="err-interesmora"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">Días Máx. Cartera <span class="required">*</span></label>
                        <input type="number" id="param-diascartera" name="txt_diascartera" class="form-control-sm" min="0" max="180">
                        <div class="validation-feedback" id="err-diascartera"></div>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label-custom">Pesos por Punto de Fidelidad <span class="required">*</span></label>
                    <input type="number" id="param-pesospuntos" name="txt_pesospuntos" class="form-control-sm" min="1">
                    <div class="validation-feedback" id="err-pesospuntos"></div>
                </div>

                <button type="submit" name="btn_guardar" class="btn-guardar"><i class="fas fa-save me-1"></i> GUARDAR RESOLUCIÓN</button>
                <button type="button" onclick="limpiarFormulario()" class="btn-nuevo"><i class="fas fa-undo-alt me-1"></i> LIMPIAR</button>
            </form>
        </div>
    </div>
</div>

<!-- MODAL CONFIRMACIÓN (OCULTO POR DEFECTO) -->
<div class="modal-overlay" id="modalConfirm" style="display: none !important;" onclick="cerrarConfirmSiOverlay(event)">
    <div class="modal-card confirm-box">
        <div class="modal-card-header" style="background: #ef4444;">
            <span><i class="fas fa-exclamation-triangle"></i> Confirmar eliminación</span>
            <button class="modal-close-btn" onclick="cerrarConfirm()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-card-body">
            <p id="confirm-body" style="font-size:1rem;margin:1rem 0;text-align:center;">¿Estás seguro de eliminar esta resolución?</p>
            <div style="display:flex;gap:1rem;justify-content:center;">
                <button class="btn-secondary" id="confirm-cancel-btn">Cancelar</button>
                <button class="btn-danger" id="confirm-ok-btn">Eliminar</button>
            </div>
        </div>
    </div>
</div>

<!-- TOAST -->
<div id="toast" class="toast-message hidden"><span id="toast-message"></span></div>

<script>
    const parametrosData = <?= json_encode(array_values($parametros), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>;
</script>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>