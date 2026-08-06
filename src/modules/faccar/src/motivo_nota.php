<?php
// ==================================================
// Módulo: Motivos DIAN (ERP ADSO)
// Tabla: tab_motivo_nota
// Estilo unificado con PUC
// ==================================================

$pageTitle        = 'ERP ADSO — Motivos Nota';
$activeModule     = 'motivos_nota';
$page_title       = "ADSOERP | Motivos Nota";
$page_description = "Catálogo de motivos para notas crédito y débito según DIAN";
$page_icon        = "bi-file-earmark-text";
$page_extra_css   = ["../modules/faccar/css/motivo_nota.css"];
$page_extra_js    = ["../modules/faccar/js/motivo_nota.js"];
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
        // ---------- NUEVO MOTIVO ----------
        if (isset($_POST['btn_nuevo'])) {
            $cod_dian = (int)($_POST['txt_cod_dian'] ?? 0);
            $tipo     = $_POST['sel_tipo_nota'] ?? 'false';
            $nombre   = trim($_POST['txt_nombre'] ?? '');
            $afecta_inventario = isset($_POST['chk_afecta_inventario']) ? 'true' : 'false';
            $afecta_cliente    = isset($_POST['chk_afecta_cliente']) ? 'true' : 'false';
            $afecta_cartera    = isset($_POST['chk_afecta_cartera']) ? 'true' : 'false';
            $afecta_comision   = isset($_POST['chk_afecta_comision']) ? 'true' : 'false';
            $estado            = ($_POST['sel_estado'] ?? 'true') === 'true';

            $errores = [];

            if ($cod_dian < 1 || $cod_dian > 6) {
                $errores['err-cod-dian'] = 'El código DIAN debe estar entre 1 y 6.';
            }
            if (strlen($nombre) < 5) {
                $errores['err-nombre'] = 'El motivo debe tener al menos 5 caracteres.';
            }
            // Verificar código DIAN único
            $check = $pdo->prepare("SELECT 1 FROM tab_motivo_nota WHERE cod_dian = :cod AND ind_borrado = FALSE");
            $check->execute([':cod' => $cod_dian]);
            if ($check->fetch()) {
                $errores['err-cod-dian'] = 'El código DIAN ya está registrado.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $pdo->beginTransaction();

            $ins_motivo_nota->execute([
                ':id_motivo_nota' => null,
                ':ind_tipo_nota'  => $tipo === 'true' ? 'true' : 'false',
                ':cod_dian'       => $cod_dian,
                ':nom_motivo'     => $nombre,
            ]);

            $id = $pdo->lastInsertId('tab_motivo_nota_id_motivo_nota_seq');

            $upd_afecta = $pdo->prepare("
                UPDATE tab_motivo_nota
                SET afecta_inventario = :af_inv,
                    afecta_cliente    = :af_cli,
                    afecta_cartera    = :af_car,
                    afecta_comision   = :af_com,
                    ind_estado        = :estado
                WHERE id_motivo_nota = :id
            ");
            $upd_afecta->execute([
                ':af_inv' => $afecta_inventario,
                ':af_cli' => $afecta_cliente,
                ':af_car' => $afecta_cartera,
                ':af_com' => $afecta_comision,
                ':estado' => $estado ? 'true' : 'false',
                ':id'     => $id,
            ]);

            $pdo->commit();

            $respuesta['success'] = true;
            $respuesta['message'] = 'Motivo creado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- EDITAR MOTIVO ----------
        if (isset($_POST['btn_editar'])) {
            $id = (int)($_POST['hid_id_motivo'] ?? 0);
            $cod_dian = (int)($_POST['txt_edit_cod_dian'] ?? 0);
            $tipo     = $_POST['sel_edit_tipo_nota'] ?? 'false';
            $nombre   = trim($_POST['txt_edit_nombre'] ?? '');
            $afecta_inventario = isset($_POST['chk_edit_afecta_inventario']) ? 'true' : 'false';
            $afecta_cliente    = isset($_POST['chk_edit_afecta_cliente']) ? 'true' : 'false';
            $afecta_cartera    = isset($_POST['chk_edit_afecta_cartera']) ? 'true' : 'false';
            $afecta_comision   = isset($_POST['chk_edit_afecta_comision']) ? 'true' : 'false';
            $estado            = ($_POST['sel_edit_estado'] ?? 'true') === 'true';

            $errores = [];

            if ($id <= 0) {
                $errores['err-id'] = 'ID de motivo no válido.';
            }
            if ($cod_dian < 1 || $cod_dian > 6) {
                $errores['err-edit-cod-dian'] = 'El código DIAN debe estar entre 1 y 6.';
            }
            if (strlen($nombre) < 5) {
                $errores['err-edit-nombre'] = 'El motivo debe tener al menos 5 caracteres.';
            }
            $check = $pdo->prepare("SELECT 1 FROM tab_motivo_nota WHERE cod_dian = :cod AND id_motivo_nota != :id AND ind_borrado = FALSE");
            $check->execute([':cod' => $cod_dian, ':id' => $id]);
            if ($check->fetch()) {
                $errores['err-edit-cod-dian'] = 'El código DIAN ya está registrado en otro motivo.';
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            $upd_motivo_nota->execute([
                ':id_motivo_nota'      => $id,
                ':ind_tipo_nota'       => $tipo === 'true' ? 'true' : 'false',
                ':cod_dian'            => $cod_dian,
                ':nom_motivo'          => $nombre,
                ':afecta_inventario'   => $afecta_inventario,
                ':afecta_cliente'      => $afecta_cliente,
                ':afecta_cartera'      => $afecta_cartera,
                ':afecta_comision'     => $afecta_comision,
            ]);

            $upd_estado = $pdo->prepare("UPDATE tab_motivo_nota SET ind_estado = :estado WHERE id_motivo_nota = :id");
            $upd_estado->execute([':estado' => $estado ? 'true' : 'false', ':id' => $id]);

            $respuesta['success'] = true;
            $respuesta['message'] = 'Motivo actualizado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- ELIMINAR MOTIVO (borrado lógico) ----------
        if (isset($_POST['btn_eliminar'])) {
            $id = (int)($_POST['hid_del_id'] ?? 0);
            if ($id <= 0) {
                throw new Exception('ID de motivo no válido.');
            }
            $del_motivo_nota->execute([':id_motivo_nota' => $id]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Motivo eliminado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- TOGGLE DE ESTADO ----------
        if (isset($_POST['btn_toggle'])) {
            $id = (int)($_POST['hid_toggle_id'] ?? 0);
            if ($id <= 0) {
                throw new Exception('ID de motivo no válido.');
            }
            $toggle_motivo_nota->execute([':id_motivo_nota' => $id]);
            $respuesta['success'] = true;
            $respuesta['message'] = 'Estado actualizado.';
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
$list_motivos_nota_completo->execute();
$motivos = $list_motivos_nota_completo->fetchAll(PDO::FETCH_ASSOC);

// ============================================================
// INICIO DEL HTML
// ============================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div class="crud-motivo-container">
    <div class="crud-header">
        <div class="crud-title">
            <h2><i class="bi bi-file-earmark-text"></i> Motivos Nota</h2>
            <p>Catálogo de motivos para la emisión de notas crédito y débito según DIAN</p>
        </div>
        <button class="btn-add" onclick="abrirModal()">
            <i class="fas fa-plus"></i> Nuevo Motivo
        </button>
    </div>

    <?php if (!empty($w_mensaje)): ?>
        <div class="alert alert-<?= $w_tipo_alerta ?> alert-dismissible fade show mb-3">
            <i class="bi <?= $w_tipo_alerta === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill' ?> me-2"></i>
            <?= nl2br(htmlspecialchars($w_mensaje)) ?>
            <button type="button" class="btn-close" onclick="this.parentElement.remove()">&times;</button>
        </div>
    <?php endif; ?>

    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="search-motivo" placeholder="Buscar por código o motivo..." oninput="filtrarTabla()">
        </div>
        <select id="filter-tipo" class="filter-select" onchange="filtrarTabla()">
            <option value="all">Todos los tipos</option>
            <option value="nc">Nota Crédito</option>
            <option value="nd">Nota Débito</option>
        </select>
        <select id="filter-estado" class="filter-select" onchange="filtrarTabla()">
            <option value="all">Todos los estados</option>
            <option value="activo">Activo</option>
            <option value="inactivo">Inactivo</option>
        </select>
        <button id="clear-filters" class="btn-clear-filter" style="display: none;" onclick="limpiarFiltros()">
            <i class="fas fa-times"></i> Limpiar Filtros
        </button>
    </div>

    <div class="table-container">
        <div class="scroll-lista-custom">
            <table class="table-custom" id="tablaMotivos">
                <thead>
                    <tr>
                        <th>Cód. DIAN</th>
                        <th>Motivo</th>
                        <th>Tipo</th>
                        <th>Afecta</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (count($motivos) > 0): ?>
                        <?php foreach ($motivos as $m): 
                            $es_activo = ($m['ind_estado'] === 't' || $m['ind_estado'] === true);
                            $tipo_label = ($m['ind_tipo_nota'] === 't' || $m['ind_tipo_nota'] === true) ? 'ND' : 'NC';
                            $tipo_clase = $tipo_label === 'ND' ? 'tipo-nd' : 'tipo-nc';
                            $estado_clase = $es_activo ? 'activo' : 'inactivo';
                            $afecta = [];
                            if ($m['afecta_inventario'] === 't' || $m['afecta_inventario'] === true) $afecta[] = 'Inventario';
                            if ($m['afecta_cliente']    === 't' || $m['afecta_cliente']    === true) $afecta[] = 'Cliente';
                            if ($m['afecta_cartera']    === 't' || $m['afecta_cartera']    === true) $afecta[] = 'Cartera';
                            if ($m['afecta_comision']   === 't' || $m['afecta_comision']   === true) $afecta[] = 'Comisión';
                            $afecta_str = !empty($afecta) ? implode(', ', $afecta) : '—';
                        ?>
                            <tr data-id="<?= $m['id_motivo_nota'] ?>"
                                data-codigo="<?= strtolower(htmlspecialchars($m['cod_dian'])) ?>"
                                data-nombre="<?= strtolower(htmlspecialchars($m['nom_motivo'])) ?>"
                                data-tipo="<?= $tipo_label ?>"
                                data-estado="<?= $estado_clase ?>">
                                <td data-label="Código"><strong><?= htmlspecialchars($m['cod_dian']) ?></strong></td>
                                <td data-label="Motivo"><?= htmlspecialchars($m['nom_motivo']) ?></td>
                                <td data-label="Tipo"><span class="badge-motivo <?= $tipo_clase ?>"><?= $tipo_label ?></span></td>
                                <td data-label="Afecta"><?= htmlspecialchars($afecta_str) ?></td>
                                <td data-label="Estado"><span class="badge-motivo <?= $estado_clase ?>"><i class="fas fa-<?= $es_activo ? 'check-circle' : 'ban' ?>"></i> <?= $es_activo ? 'Activo' : 'Inactivo' ?></span></td>
                                <td data-label="Acciones">
                                    <button class="btn-icon edit" onclick="abrirEditar(<?= $m['id_motivo_nota'] ?>)" title="Editar"><i class="fas fa-edit"></i></button>
                                    <button class="btn-icon toggle" onclick="toggleEstado(<?= $m['id_motivo_nota'] ?>)" title="Cambiar estado"><i class="fas <?= $es_activo ? 'fa-toggle-on' : 'fa-toggle-off' ?>"></i></button>
                                    <button class="btn-icon delete" onclick="confirmarEliminar(<?= $m['id_motivo_nota'] ?>, '<?= addslashes($m['nom_motivo']) ?>')" title="Eliminar"><i class="fas fa-trash"></i></button>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <tr><td colspan="6" class="text-center py-4 text-muted"><i class="fas fa-inbox" style="font-size:2rem;"></i><p class="mt-2">No hay motivos registrados</p></td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="fas fa-plus-circle"></i> Nuevo Motivo</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-card-body">
            <form method="POST" id="formMotivo">
                <input type="hidden" name="btn_nuevo" id="hid-btn-nuevo" value="1">
                <input type="hidden" name="btn_editar" id="hid-btn-editar" value="">
                <input type="hidden" name="hid_id_motivo" id="hid-id-motivo" value="">

                <div class="form-row">
                    <div class="mb-3">
                        <label class="form-label-custom">Código DIAN (1-6) <span class="text-danger">*</span></label>
                        <input type="number" name="txt_cod_dian" id="f_cod_dian" class="form-control-sm" min="1" max="6" placeholder="Ej: 1" required>
                        <div id="codigo-feedback" class="validation-feedback"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">Tipo de Nota <span class="text-danger">*</span></label>
                        <select name="sel_tipo_nota" id="f_tipo" class="form-control-sm">
                            <option value="false">Nota Crédito</option>
                            <option value="true">Nota Débito</option>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Descripción del Motivo <span class="text-danger">*</span></label>
                    <input type="text" name="txt_nombre" id="f_nombre" class="form-control-sm" maxlength="100" placeholder="Ej: Devolución total por incumplimiento de pago" required>
                    <div id="nombre-feedback" class="validation-feedback"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Efectos del Motivo</label>
                    <div class="checkbox-group">
                        <label class="checkbox-label"><input type="checkbox" name="chk_afecta_inventario" id="f_afecta_inventario"> Afecta inventario</label>
                        <label class="checkbox-label"><input type="checkbox" name="chk_afecta_cliente" id="f_afecta_cliente" checked> Afecta tercero / cliente</label>
                        <label class="checkbox-label"><input type="checkbox" name="chk_afecta_cartera" id="f_afecta_cartera" checked> Afecta cartera</label>
                        <label class="checkbox-label"><input type="checkbox" name="chk_afecta_comision" id="f_afecta_comision"> Afecta comisión del vendedor</label>
                    </div>
                </div>

                <div class="toggle-row">
                    <div>
                        <div class="toggle-label">Estado del Motivo</div>
                        <div class="toggle-status activo" id="f_toggle_status">ACTIVO</div>
                    </div>
                    <div class="toggle-switch on" id="f_toggle_switch">
                        <div class="toggle-thumb"></div>
                    </div>
                </div>

                <button type="submit" name="btn_guardar" class="btn-guardar"><i class="fas fa-save me-1"></i> GUARDAR</button>
                <button type="button" onclick="limpiarFormulario()" class="btn-nuevo"><i class="fas fa-undo-alt me-1"></i> LIMPIAR</button>
            </form>
        </div>
    </div>
</div>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>