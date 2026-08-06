<?php
/**
 * ============================================================================
 * MÓDULO: Clientes (ERP ADSO) - Versión Profesional
 * ============================================================================
 * Gestión completa de clientes con validación, auditoría y buenas prácticas
 * Funcionalidades: Listar, Nuevo, Editar, Eliminar, Detalle
 */

// Configuración de la página
$pageTitle        = 'ERP ADSO — Clientes';
$activeModule     = 'clientes';
$page_title       = 'ADSOERP | Clientes';
$page_description = 'Gestión integral de clientes, crédito y puntos de fidelidad';
$page_icon        = 'bi-people-fill';
$page_extra_css   = ['../modules/faccar/css/clientes.css'];
$page_extra_js    = ['../modules/faccar/js/clientes.js'];
$show_welcome     = false;

// Validar inclusor
if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

// Cargar dependencias
require_once(__DIR__ . '/../../compro/src/prepare_compro.php');
require_once('prepare_faccar.php');

// ============================================================================
// CONSTANTES Y CONFIGURACIÓN
// ============================================================================
const TIPOS_SOLO_NUMEROS = ['CC', 'TI', 'RC', 'NIT', 'NUIP'];
const RESPUESTA_JSON = 'Content-Type: application/json; charset=UTF-8';

// ============================================================================
// FUNCIONES AUXILIARES
// ============================================================================
function limpiar_error_pgsql(string $msg): string {
    if (preg_match('/ERROR:\s*ERROR:\s*(.+?)(?:\s+CONTEXT:|$)/s', $msg, $m)) {
        return trim($m[1]);
    }
    if (preg_match('/ERROR:\s*(.+?)(?:\s+CONTEXT:|$)/s', $msg, $m)) {
        return trim($m[1]);
    }
    return $msg;
}

function respuesta_json(bool $success, string $message = '', array $errors = [], array $extra = []): string {
    return json_encode(array_merge(
        ['success' => $success, 'message' => $message, 'errors' => $errors],
        $extra
    ), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
}

// ============================================================================
// CARGAR COMBOS (SELECT)
// ============================================================================
$list_tipos->execute();
$tipos = $list_tipos->fetchAll(PDO::FETCH_ASSOC);

$list_categorias->execute();
$categorias = $list_categorias->fetchAll(PDO::FETCH_ASSOC);

$list_ciudades->execute();
$ciudades_lista = $list_ciudades->fetchAll(PDO::FETCH_ASSOC);

$list_restricciones->execute();
$restricciones = $list_restricciones->fetchAll(PDO::FETCH_ASSOC);

$list_prefijos->execute();
$prefijos = $list_prefijos->fetchAll(PDO::FETCH_ASSOC);

$list_clientes_completo->execute();
$clientes_raw = $list_clientes_completo->fetchAll(PDO::FETCH_ASSOC);

// ============================================================================
// NORMALIZACIÓN DE DATOS
// ============================================================================
function normalizarCliente(array $c): array {
    $ind_credito = filter_var($c['ind_credito'] ?? false, FILTER_VALIDATE_BOOLEAN);
    $ind_estado_cliente = filter_var($c['ind_estado_cliente'] ?? false, FILTER_VALIDATE_BOOLEAN);
    $ind_tipo_tercero = filter_var($c['ind_tipo_tercero'] ?? false, FILTER_VALIDATE_BOOLEAN);

    return [
        'id_tercero'          => $c['id_tercero'] ?? '',
        'nom_tercero'         => $c['nom_tercero'] ?? '',
        'id_tipo'             => $c['id_tipo'] ?? '',
        'nom_tipo'            => $c['nom_tipo'] ?? '',
        'id_cat_tercero'      => (int)($c['id_cat_tercero'] ?? 0),
        'nom_cat_tercero'     => $c['nom_cat_tercero'] ?? '',
        'id_ciudad'           => $c['id_ciudad'] ?? '',
        'nom_ciudad'          => $c['nom_ciudad'] ?? '',
        'id_restriccion'      => (int)($c['id_restriccion'] ?? 0),
        'nom_restriccion'     => $c['nom_restriccion'] ?? '',
        'email'               => $c['email'] ?? '',
        'direccion'           => $c['direccion'] ?? '',
        'tel_fijo'            => $c['tel_fijo'] ?? '',
        'tel_movil'           => $c['tel_movil'] ?? '',
        'id_prefijo_movil'    => $c['id_prefijo_movil'] ?? null,
        'id_cliente'          => $c['id_cliente'] ?? '',
        'fec_nacimi'          => $c['fec_nacimi'] ?? '',
        'val_edad'            => (int)($c['val_edad'] ?? 0),
        'ind_genero'          => $c['ind_genero'] ?? 'F',
        'val_puntos'          => (int)($c['val_puntos'] ?? 0),
        'val_cupocredito'     => (float)($c['val_cupocredito'] ?? 0),
        'val_diascartera'     => (int)($c['val_diascartera'] ?? 0),
        'ind_credito'         => $ind_credito,
        'ind_estado_cliente'  => $ind_estado_cliente,
        'ind_estado'          => filter_var($c['ind_estado'] ?? false, FILTER_VALIDATE_BOOLEAN),
        'ind_tipo_tercero'    => $ind_tipo_tercero,
        'estado'              => $ind_estado_cliente,
        'tipo_cliente'        => $ind_tipo_tercero ? 'Jurídica' : 'Natural',
        'estado_texto'        => $ind_estado_cliente ? 'Activo' : 'Inactivo',
        'credito_texto'       => $ind_credito ? 'Sí' : 'No',
        'cupo_formato'        => number_format((float)($c['val_cupocredito'] ?? 0), 0, ',', '.'),
        'search' => strtolower(
            ($c['id_cliente'] ?? '') . ' ' .
            ($c['nom_tercero'] ?? '') . ' ' .
            ($c['email'] ?? '') . ' ' .
            ($c['nom_ciudad'] ?? '') . ' ' .
            ($c['nom_tipo'] ?? '')
        ),
    ];
}

$clientes = array_map('normalizarCliente', $clientes_raw);

// ============================================================================
// ESTADÍSTICAS
// ============================================================================
$total = count($clientes);
$activos = 0;
$con_credito = 0;
$cupo_total = 0;

foreach ($clientes as $cliente) {
    if ($cliente['ind_estado_cliente']) $activos++;
    if ($cliente['ind_credito']) $con_credito++;
    $cupo_total += $cliente['val_cupocredito'];
}

// ============================================================================
// MANEJO DE PETICIONES POST (AJAX)
// ============================================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header(RESPUESTA_JSON);

    try {
        // ================================================================
        // 1. NUEVO CLIENTE
        // ================================================================
        if (isset($_POST['btn_nuevo'])) {
            $errores = [];

            // Captura de datos
            $id_tipo = trim($_POST['txt_id_tipo'] ?? '');
            $id_tercero = strtoupper(trim($_POST['txt_id_tercero'] ?? ''));
            $ind_tipo_tercero = ($_POST['sel_tipo_tercero'] ?? '') === 'true';
            $id_cat_tercero = (int)($_POST['sel_categoria'] ?? 0);
            $nom_tercero = trim($_POST['txt_nom_tercero'] ?? '');
            $email = strtolower(trim($_POST['txt_email'] ?? ''));
            $direccion = trim($_POST['txt_direccion'] ?? '');
            $tel_fijo = trim($_POST['txt_tel_fijo'] ?? '');
            $tel_fijo = $tel_fijo !== '' ? $tel_fijo : null;
            $tel_movil = trim($_POST['txt_tel_movil'] ?? '');
            $tel_movil = $tel_movil !== '' ? $tel_movil : null;
            $id_prefijo_movil = trim($_POST['txt_prefijo_movil'] ?? '');
            $id_prefijo_movil = ($id_prefijo_movil !== '' && (int)$id_prefijo_movil > 0) ? (int)$id_prefijo_movil : null;
            $id_ciudad = trim($_POST['sel_ciudad'] ?? '');
            $id_restriccion = (int)($_POST['sel_restriccion'] ?? 0);
            $ind_estado = ($_POST['sel_estado'] ?? 'true') === 'true';
            
            $fec_nacimi = trim($_POST['txt_fec_nac'] ?? '');
            $genero = trim($_POST['sel_genero'] ?? 'F');
            $puntos = (int)($_POST['txt_puntos'] ?? 0);
            $credito = ($_POST['sel_credito'] ?? 'false') === 'true';
            $cupo = (float)($_POST['txt_cupo'] ?? 0);
            $dias_cartera = (int)($_POST['txt_dias_cartera'] ?? 0);

            // Validaciones
            if (empty($id_tipo)) {
                $errores['new-id-tipo'] = 'Seleccione el tipo de documento.';
            }
            if (empty($id_tercero)) {
                $errores['new-id-tercero'] = 'La identificación es obligatoria.';
            } elseif (in_array($id_tipo, TIPOS_SOLO_NUMEROS)) {
                if (!preg_match('/^[0-9]{7,10}$/', $id_tercero)) {
                    $errores['new-id-tercero'] = "Para $id_tipo use 7-10 dígitos numéricos.";
                }
            } else {
                if (!preg_match('/^[A-Z0-9]{7,10}$/', $id_tercero)) {
                    $errores['new-id-tercero'] = 'Use 7-10 caracteres alfanuméricos en mayúsculas.';
                }
            }
            if ($id_cat_tercero < 1) {
                $errores['new-cat-tercero'] = 'Seleccione una categoría válida.';
            }
            if (strlen($nom_tercero) < 4 || strlen($nom_tercero) > 50) {
                $errores['new-nom-tercero'] = 'El nombre debe tener entre 4 y 50 caracteres.';
            }
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errores['new-email'] = 'Ingrese un email válido.';
            }
            if (empty($direccion) || strlen($direccion) < 5) {
                $errores['new-direccion'] = 'Ingrese una dirección válida.';
            }
            if ($tel_fijo !== null && !preg_match('/^[0-9]{7,10}$/', $tel_fijo)) {
                $errores['new-tel-fijo'] = 'El teléfono debe tener 7-10 dígitos.';
            }
            if ($tel_movil !== null && $id_prefijo_movil === null) {
                $errores['new-tel-movil'] = 'Seleccione el prefijo si ingresa celular.';
            }
            if ($id_prefijo_movil !== null && $tel_movil === null) {
                $errores['new-tel-movil'] = 'Ingrese el celular si selecciona prefijo.';
            }
            if ($tel_movil !== null && !preg_match('/^[0-9]{7,15}$/', $tel_movil)) {
                $errores['new-tel-movil'] = 'El celular debe tener 7-15 dígitos.';
            }
            if (empty($id_ciudad)) {
                $errores['new-ciudad'] = 'Seleccione una ciudad.';
            }
            if ($id_restriccion < 1) {
                $errores['new-restriccion'] = 'Seleccione una restricción válida.';
            }
            if (empty($fec_nacimi)) {
                $errores['new-fec-nac'] = 'La fecha de nacimiento es obligatoria.';
            } else {
                $fec_obj = DateTime::createFromFormat('Y-m-d', $fec_nacimi);
                if (!$fec_obj || $fec_obj->format('Y-m-d') !== $fec_nacimi) {
                    $errores['new-fec-nac'] = 'Formato de fecha inválido.';
                }
            }
            if (empty($genero) || !in_array($genero, ['F', 'M', 'NB', 'T'])) {
                $errores['new-genero'] = 'Seleccione un género válido.';
            }
            if ($puntos < 0) {
                $errores['new-puntos'] = 'Los puntos no pueden ser negativos.';
            }
            if ($credito && $cupo <= 0) {
                $errores['new-cupo'] = 'Si tiene crédito, el cupo debe ser > 0.';
            }
            if ($credito && ($dias_cartera < 0 || $dias_cartera > 120)) {
                $errores['new-dias-cartera'] = 'Los días deben estar entre 0 y 120.';
            }

            if (!empty($errores)) {
                echo respuesta_json(false, 'Hay errores en el formulario', $errores);
                exit;
            }

            // Ejecutar transacción
            try {
                $pdo->beginTransaction();

                $ins_tercero->execute([
                    ':id_tipo' => $id_tipo,
                    ':id_tercero' => $id_tercero,
                    ':ind_tipo_tercero' => $ind_tipo_tercero,
                    ':id_cat_tercero' => $id_cat_tercero,
                    ':nom_tercero' => $nom_tercero,
                    ':direccion' => $direccion,
                    ':tel_fijo' => $tel_fijo,
                    ':id_prefijo_movil' => $id_prefijo_movil,
                    ':tel_movil' => $tel_movil,
                    ':email' => $email,
                    ':id_ciudad' => $id_ciudad,
                    ':id_restriccion' => $id_restriccion,
                    ':ind_estado' => $ind_estado
                ]);

                $ins_cliente->execute([
                    ':id_cliente' => $id_tercero,
                    ':id_tipo' => $id_tipo,
                    ':fec_nacimi' => $fec_nacimi,
                    ':genero' => $genero,
                    ':puntos' => $puntos,
                    ':credito' => $credito,
                    ':cupo' => $cupo,
                    ':dias_cartera' => $dias_cartera
                ]);

                $pdo->commit();
                echo respuesta_json(true, 'Cliente creado exitosamente');
            } catch (PDOException $e) {
                $pdo->rollBack();
                echo respuesta_json(false, "Error al crear cliente: " . limpiar_error_pgsql($e->getMessage()));
            }
            exit;
        }

        // ================================================================
        // 2. EDITAR CLIENTE
        // ================================================================
        if (isset($_POST['btn_editar'])) {
            $errores = [];

            // Captura de datos
            $id_cliente = trim($_POST['txt_edit_id_cliente'] ?? '');
            $id_tipo = trim($_POST['txt_edit_id_tipo'] ?? '');
            $nom_tercero = trim($_POST['txt_edit_nom_tercero'] ?? '');
            $nom_corto = $nom_tercero;
            $email = strtolower(trim($_POST['txt_edit_email'] ?? ''));
            $direccion = trim($_POST['txt_edit_direccion'] ?? '');
            $genero = trim($_POST['sel_edit_genero'] ?? 'F');
            $puntos = (int)($_POST['txt_edit_puntos'] ?? 0);
            $ind_estado = ($_POST['sel_edit_estado'] ?? 'true') === 'true';
            $credito = ($_POST['sel_edit_credito'] ?? 'false') === 'true';
            $ind_tipo_tercero = ($_POST['sel_edit_tipo_tercero'] ?? 'false') === 'true';
            $cupo = (float)($_POST['txt_edit_cupo'] ?? 0);
            $dias_cartera = (int)($_POST['txt_edit_dias_cartera'] ?? 0);
            $id_cat_tercero = (int)($_POST['sel_edit_categoria'] ?? 0);
            $tel_fijo = trim($_POST['txt_edit_tel_fijo'] ?? '');
            $tel_fijo = $tel_fijo !== '' ? $tel_fijo : null;
            $tel_movil = trim($_POST['txt_edit_tel_movil'] ?? '');
            $tel_movil = $tel_movil !== '' ? $tel_movil : null;
            $id_prefijo_movil = $_POST['sel_edit_prefijo_movil'] ?? null;
            $id_prefijo_movil = $id_prefijo_movil !== '' ? (int)$id_prefijo_movil : null;
            $id_ciudad = trim($_POST['sel_edit_ciudad'] ?? '');
            $id_restriccion = (int)($_POST['sel_edit_restriccion'] ?? 0);
            $fec_nacimi = trim($_POST['txt_edit_fec_nac'] ?? '');

            // Validaciones
            if ($id_cliente === '') {
                $errores['edit-id-cliente'] = 'Cliente inválido.';
            }
            if ($id_tipo === '') {
                $errores['edit-id-tipo'] = 'Seleccione el tipo de documento.';
            }
            if ($id_cat_tercero == '') {
                $errores['edit-categoria'] = 'Seleccione la categoría.';
            }
            if ($nom_tercero == '') {
                $errores['edit-nom-tercero'] = 'Ingrese el nombre.';
            } elseif (mb_strlen($nom_tercero) < 3) {
                $errores['edit-nom-tercero'] = 'Debe contener mínimo 3 caracteres.';
            } elseif (mb_strlen($nom_tercero) > 150) {
                $errores['edit-nom-tercero'] = 'No puede superar los 150 caracteres.';
            }
            if ($fec_nacimi != '' && !strtotime($fec_nacimi)) {
                $errores['edit-fec-nac'] = 'Fecha inválida.';
            }
            if (!in_array($genero, ['M', 'F', 'NB', 'T'])) {
                $errores['edit-genero'] = 'Seleccione un género válido.';
            }
            if ($id_prefijo_movil == '') {
                $errores['edit-prefijo'] = 'Seleccione el prefijo.';
            }
            if ($tel_movil == '') {
                $errores['edit-tel-movil'] = 'Ingrese el celular.';
            } elseif (!preg_match('/^[0-9]{7,15}$/', $tel_movil)) {
                $errores['edit-tel-movil'] = 'Número inválido.';
            }
            if ($tel_fijo != '' && !preg_match('/^[0-9]{7,15}$/', $tel_fijo)) {
                $errores['edit-tel-fijo'] = 'Número inválido.';
            }
            if ($email != '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errores['edit-email'] = 'Correo inválido.';
            }
            if ($direccion == '') {
                $errores['edit-direccion'] = 'Ingrese la dirección.';
            } elseif (mb_strlen($direccion) < 5) {
                $errores['edit-direccion'] = 'Dirección demasiado corta.';
            }
            if ($id_ciudad == '') {
                $errores['edit-ciudad'] = 'Seleccione una ciudad.';
            }
            if ($id_restriccion == '') {
                $errores['edit-restriccion'] = 'Seleccione la restricción.';
            }
            if ($puntos < 0) {
                $errores['edit-puntos'] = 'Valor inválido.';
            }
            if ($credito) {
                if ($cupo <= 0) {
                    $errores['edit-cupo'] = 'Ingrese un cupo válido.';
                }
                if ($dias_cartera <= 0) {
                    $errores['edit-dias-cartera'] = 'Ingrese los días de cartera.';
                }
            }

            if (!empty($errores)) {
                echo respuesta_json(false, 'Hay errores en el formulario', $errores);
                exit;
            }

            // Ejecutar transacción
            try {
                $pdo->beginTransaction();

                $upd_tercero->execute([
                    ':id_tercero' => $id_cliente,
                    ':ind_tipo_tercero' => $ind_tipo_tercero,
                    ':id_cat_tercero' => $id_cat_tercero,
                    ':nom_tercero' => $nom_tercero,
                    ':nom_corto' => $nom_corto,
                    ':direccion' => $direccion,
                    ':tel_fijo' => $tel_fijo,
                    ':id_prefijo_movil' => $id_prefijo_movil,
                    ':tel_movil' => $tel_movil,
                    ':email' => $email,
                    ':id_ciudad' => $id_ciudad,
                    ':id_restriccion' => $id_restriccion,
                    ':ind_estado' => $ind_estado
                ]);

                $upd_cliente->execute([
                    ':wid_cliente' => $id_cliente,
                    ':wid_tipo' => $id_tipo,
                    ':wfec_nacimi' => $fec_nacimi,
                    ':wind_genero' => $genero,
                    ':wval_puntos' => $puntos,
                    ':wind_credito' => $credito,
                    ':wval_cupocredito' => $cupo,
                    ':wval_diascartera' => $dias_cartera,
                    ':wind_estado' => $ind_estado
                ]);

                $pdo->commit();
                echo respuesta_json(true, 'Cliente actualizado correctamente.');
            } catch (PDOException $e) {
                $pdo->rollBack();
                echo respuesta_json(false, limpiar_error_pgsql($e->getMessage()));
            }
            exit;
        }

        // ================================================================
        // 3. ELIMINAR CLIENTE (BORRADO LÓGICO)
        // ================================================================
        if (isset($_POST['btn_eliminar'])) {
            $id_cliente = trim($_POST['txt_id_cliente'] ?? '');
            
            if (empty($id_cliente)) {
                echo respuesta_json(false, 'ID de cliente no válido');
                exit;
            }

            try {
                $del_cliente->execute([':id_cliente' => $id_cliente]);
                echo respuesta_json(true, 'Cliente eliminado correctamente');
            } catch (PDOException $e) {
                echo respuesta_json(false, "Error al eliminar: " . limpiar_error_pgsql($e->getMessage()));
            }
            exit;
        }

        // ================================================================
        // 4. ACCIÓN NO RECONOCIDA
        // ================================================================
        echo respuesta_json(false, 'Acción no válida');
        exit;

    } catch (Exception $e) {
        error_log("Error en clientes.php: " . $e->getMessage());
        echo respuesta_json(false, 'Error interno del servidor');
        exit;
    }
}


// ============================================================================
// VISTA HTML (GET)
// ============================================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<div id="mod-clientes" class="app-view active">

        <div class="module-header">
            <div class="module-header-text">
                <h1>Clientes</h1>
                <p>Gestión de clientes, crédito y puntos de fidelidad</p>
            </div>
            <!-- Encabezado con botón nuevo -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div></div>
                <button id="btn-add-cliente" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Nuevo Cliente
                </button>
            </div>
        </div>  

<!-- Estadísticas -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-icon blue"><i class="fas fa-users"></i></div>
        <div class="stat-info">
            <div class="stat-label">Total</div>
            <div class="stat-value" id="stat-total"><?= $total ?></div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
        <div class="stat-info">
            <div class="stat-label">Activos</div>
            <div class="stat-value" id="stat-activos"><?= $activos ?></div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon purple"><i class="fas fa-credit-card"></i></div>
        <div class="stat-info">
            <div class="stat-label">Con Crédito</div>
            <div class="stat-value" id="stat-credito"><?= $con_credito ?></div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon amber"><i class="fas fa-dollar-sign"></i></div>
        <div class="stat-info">
            <div class="stat-label">Cupo Total</div>
            <div class="stat-value" id="stat-cupo">$<?= number_format($cupo_total,0,',','.') ?></div>
        </div>
    </div>
</div>

<!-- Barra de búsqueda y filtros -->
<div class="filter-bar">
    <div class="search-wrapper">
        <i class="fas fa-search search-icon"></i>
        <input type="text" id="cliente-search" class="search-input" placeholder="Buscar por nombre o ID...">
    </div>
    <div class="filter-toggle-group">
        <button class="filter-toggle active" data-filter="all">Todos</button>
        <button class="filter-toggle" data-filter="active">Activos</button>
        <button class="filter-toggle" data-filter="inactive">Inactivos</button>
    </div>
    <button id="btn-clear-filters" class="btn-clear-filter" style="display:none;">
        <i class="fas fa-times"></i> Limpiar
    </button>
    <div class="filter-info" id="clientes-count"><?= $total ?> resultado<?= $total !== 1 ? 's' : '' ?></div>
</div>

<!-- Tabla de clientes -->
<div class="table-container">
    <table class="data-table">
        <thead>
    <tr>
        <th>Documento</th>
        <th>Cliente</th>
        <th>Tipo</th>
        <th>Crédito</th>
        <th class="text-end">Cupo</th>
        <th>Estado</th>
        <th class="col-actions">Acciones</th>
    </tr>
</thead>
        <tbody id="clientes-tbody">
<?php if (!empty($clientes)): ?>
    <?php foreach ($clientes as $c): ?>
        <tr>
            <td><strong><?= htmlspecialchars($c['id_cliente']) ?></strong></td>
            <td><?= htmlspecialchars($c['nom_tercero']) ?></td>
            <td><?php if($c['ind_tipo_tercero']): ?>
                <span class="badge badge-company"><i class="fas fa-building"></i>Jurídica</span>
            <?php else: ?>
                <span class="badge badge-person"><i class="fas fa-user"></i>Natural</span>
            <?php endif; ?>
            </td> 

            <td>
            <?php if($c['ind_credito']): ?>
                <span class="badge badge-credit">
                    <i class="fas fa-check-circle"></i>
                    Sí
                </span>
            <?php else: ?>
                <span class="badge badge-no-credit">
                    <i class="fas fa-times-circle"></i>
                    No
                </span>
            <?php endif; ?>
            </td>
            
            <td class="text-end">$<?= number_format($c['val_cupocredito'] ?? 0, 0, ',', '.') ?></td>
            <td>
                <?php if ($c['ind_estado_cliente']): ?>
                    <span class="badge badge-success">Activo</span>
                <?php else: ?>
                    <span class="badge badge-danger"> Inactivo</span>
                <?php endif; ?>
            </td>
            <!-- Acciones -->
            <td class="col-actions">
                <div class="btn-table-group">
                    <button class="btn-table-detail"
                            data-id="<?= htmlspecialchars($c['id_cliente']) ?>"
                            title="Ver detalles">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-table-edit"
                            data-id="<?= htmlspecialchars($c['id_cliente']) ?>"
                            title="Editar cliente">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-table-delete"
                            data-id="<?= htmlspecialchars($c['id_cliente']) ?>"
                            title="Eliminar cliente">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    <?php endforeach; ?>
<?php else: ?>
    <tr class="empty-row">
        <td colspan="7" style="text-align:center;padding:40px;">
            No hay clientes registrados
        </td>
    </tr>
<?php endif; ?>
</tbody>
    </table>
</div>
</div>

<!-- ============================================================================
     MODAL: editar Cliente
     ============================================================================ -->
<div id="modal-edit-cliente" class="modal-overlay hidden">

    <div class="modal-box modal-detail-box">

        <!-- HEADER -->
        <div class="modal-header blue">

            <div>
                <h2>
                    <i class="fas fa-user-edit"></i>
                    Editar Cliente
                </h2>
                <p>Actualiza la información del cliente.</p>
            </div>

            <button type="button"
                    class="modal-close btn-close-edit-modal">
                <i class="fas fa-times"></i>
            </button>

        </div>

        <form id="edit-cliente-form" method="post">
    <!-- targeta de cliente -->
    <div class="edit-client-card">

    <div class="edit-client-avatar">
        <i class="fas fa-user"></i>
    </div>
    <div class="edit-client-info">
        <h3 id="edit-card-nombre">
            Cliente
        </h3>
        <p>
            <span id="edit-card-id">
                CLI0001
            </span>
            <span class="separator">•</span>
            <span id="edit-card-tipo">
                Persona Natural
            </span>
            <span class="separator">•</span>
            <span
                id="edit-card-estado"
                class="status-badge active">
                Activo
            </span>
        </p>
    </div>
    </div>
            <!-- PESTAÑAS -->
            <div class="edit-tab">

                <button
                    type="button"
                    class="detail-tab active"
                    data-edit-tab="general">

                    <i class="fas fa-id-card"></i>
                    General

                </button>

                <button
                    type="button"
                    class="detail-tab"
                    data-edit-tab="contacto">

                    <i class="fas fa-phone"></i>
                    Contacto

                </button>

                <button
                    type="button"
                    class="detail-tab"
                    data-edit-tab="comercial">

                    <i class="fas fa-coins"></i>
                    Comercial

                </button>

            </div>

            <div class="modal-body">

                <!-- ===================================================== -->
                <!-- GENERAL -->
                <!-- ===================================================== -->

                <div id="edit-general" class="edit-section active">

                    <div class="form-grid">

                        <div class="form-field">
                            <label class="form-label"> Tipo Documento</label>
                            <select id="edit-id-tipo" name="txt_edit_id_tipo" class="form-select">
                                <option value="" selected >Seleccione...</option>
                                <?php foreach ($tipos as $tipo): ?>
                                    <option value="<?= htmlspecialchars($tipo['id_tipo']) ?>">
                                        <?= htmlspecialchars($tipo['nom_tipo']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="form-field">
                            <label class="form-label"> Número de Identificación </label>
                            <input id="edit-cliente-id" class="form-input" readonly>
                            <span class="field-error"></span>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">  Tipo Cliente </label>
                            <select id="edit-tipo-tercero" name="sel_edit_tipo_tercero" class="form-select">
                            <option value="" selected >Seleccione...</option>    
                            <option value="false">Persona Natural</option>
                            <option value="true">Persona Jurídica</option>
                            </select>
                            <span class="field-error"></span>
                        </div>
                        <div class="form-field">
                            <label class="form-label">
                                Categoría
                            </label>
                            <select id="edit-cat-tercero" name="sel_edit_categoria" class="form-select">
                                <option value="" selected >Seleccione...</option>
                                <?php foreach ($categorias as $categoria): ?>
                                    <option value="<?= $categoria['id_cat_tercero'] ?>">
                                        <?= htmlspecialchars($categoria['nom_cat_tercero']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <span class="field-error"></span>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-field full">
                            <label id="lbl-edit-nombre" class="form-label"> Nombre Completo</label>
                            <input
                                id="edit-cliente-nombre"
                                name="txt_edit_nom_tercero"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">  Fecha Nacimiento  </label>
                            <input
                                type="date"
                                id="edit-cliente-fec-nac"
                                name="txt_edit_fec_nac"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>

                        <div class="form-field">
                            <label class="form-label">  Género  </label>
                            <select id="edit-cliente-genero"  name="sel_edit_genero" class="form-select">
                                <option value="" selected >Seleccione...</option>
                                <option value="F">Femenino</option>
                                <option value="M">Masculino</option>
                                <option value="NB">No Binario</option>
                                <option value="T">Transgénero</option>
                            </select>
                            <span class="field-error"></span>
                        </div>
                    </div>

                </div>

                <!-- ===================================================== -->
                <!-- CONTACTO -->
                <!-- ===================================================== -->

                <div id="edit-contacto" class="edit-section">
                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">  Prefijo  </label>
                            <select id="edit-prefijo-movil"
                                    name="sel_edit_prefijo_movil"
                                    class="form-select">

                                <option value="">Seleccione...</option>

                                <?php foreach ($prefijos as $prefijo): ?>

                                    <option value="<?= $prefijo['id_prefijo_movil'] ?>">

                                        +<?= htmlspecialchars($prefijo['id_prefijo_movil']) ?>
                                        - <?= htmlspecialchars($prefijo['nom_pais']) ?>

                                    </option>

                                <?php endforeach; ?>

                            </select>
                            <span class="field-error"></span>
                        </div>

                        <div class="form-field">
                            <label class="form-label">  Celular</label>
                            <input
                                id="edit-cliente-tel-movil"
                                name="txt_edit_tel_movil"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>
                    </div>
                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">
                                Teléfono fijo
                            </label>
                            <input
                                id="edit-cliente-tel-fijo"
                                name="txt_edit_tel_fijo"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>
                        <div class="form-field">
                            <label class="form-label"> Correo</label>
                            <input
                                type="email"
                                id="edit-cliente-email"
                                name="txt_edit_email"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>
                    </div>
                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">Dirección</label>
                            <input
                                id="edit-cliente-direccion"
                                name="txt_edit_direccion"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>
                        <div class="form-field">
                            <label class="form-label">Ciudad</label>
                            <select id="edit-cliente-ciudad"  name="sel_edit_ciudad"  class="form-select">
                                <option value="" selected >Seleccione...</option>
                                <?php foreach ($ciudades_lista as $ciudad): ?>
                                    <option value="<?= htmlspecialchars($ciudad['id_ciudad']) ?>">
                                        <?= htmlspecialchars($ciudad['nom_ciudad']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <span class="field-error"></span>
                        </div>
                    </div>
                </div>

                <!-- ===================================================== -->
                <!-- COMERCIAL -->
                <!-- ===================================================== -->

                <div id="edit-comercial"  class="edit-section">
                    <div class="form-grid">
                         <div class="form-field">
                            <label class="form-label">
                                Restricción
                            </label>

                            <select id="edit-cliente-restriccion" name="sel_edit_restriccion" class="form-select">
                                <option value="" selected >Seleccione...</option>
                            <?php foreach ($restricciones as $restriccion): ?>
                                <option value="<?= $restriccion['id_restriccion'] ?>">
                                    <?= htmlspecialchars($restriccion['nom_restriccion']) ?>
                                </option>
                            <?php endforeach; ?>    
                            </select>
                            <span class="field-error"></span>

                        </div> 

                        <div class="form-field">

                            <label class="form-label">
                                Puntos
                            </label>

                            <input
                                type="number"
                                id="edit-cliente-puntos"
                                name="txt_edit_puntos"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">
                                Estado
                            </label>

                            <select
                                id="edit-cliente-estado"
                                name="sel_edit_estado"
                                class="form-select">
                                <option value=""selected >Seleccione...</option>
                                <option value="true">Activo</option>
                                <option value="false">Inactivo</option>

                            </select>
                                <span class="field-error"></span>
                        </div>

                        <div class="form-field">

                            <label class="form-label">
                                Crédito
                            </label>

                            <div
                                id="edit-credito-switch"
                                class="switch-toggle">

                                <span id="edit-credito-label">
                                    No
                                </span>

                            </div>

                            <input
                                type="hidden"
                                id="edit-credito-hidden"
                                name="sel_edit_credito">
                                <span class="field-error"></span>
                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">
                                Cupo Crédito
                            </label>

                            <input
                                type="number"
                                id="edit-cliente-cupo"
                                name="txt_edit_cupo"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>

                        <div class="form-field">

                            <label class="form-label">
                                Días Cartera
                            </label>

                            <input
                                type="number"
                                id="edit-cliente-diascartera"
                                name="txt_edit_dias_cartera"
                                class="form-input">
                                <span class="field-error"></span>
                        </div>

                    </div>

                </div>

            </div>

            <input
                type="hidden"
                name="btn_editar"
                value="1">
            <input
                type="hidden"
                id="hid-edit-id-cliente"
                name="txt_edit_id_cliente">

           

            <div class="modal-footer">

                <button
                    type="button"
                    class="btn btn-secondary btn-cancel-edit-modal">

                    Cancelar

                </button>

                <button
                    type="submit"
                    class="btn btn-success">

                    <i class="fas fa-save"></i>
                    Guardar Cambios

                </button>

            </div>

        </form>

    </div>

</div>

<!-- ============================================================================
     MODAL: Detalle Cliente
     ============================================================================ -->
<div id="modal-detail" class="modal-overlay hidden">
    <div class="modal-box modal-detail-box">

        <div class="modal-header modal-detail-header blue">
            <div>
                <h2><i class="fas fa-eye"></i> Detalle del Cliente</h2>
                <p>Información completa del cliente</p>
            </div>

            <button type="button" class="modal-close btn-close-detail-modal">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <!-- pestañas -->
        <div class="detail-tabs">
            <button class="detail-tab active" data-tab="general">
                <i class="fas fa-user"></i>
                General
            </button>

            <button class="detail-tab" data-tab="contacto">
                <i class="fas fa-phone"></i>
                Contacto
            </button>

            <button class="detail-tab" data-tab="comercial">
                <i class="fas fa-credit-card"></i>
                Comercial
            </button>
        </div>

        <div class="modal-body modal-detail-body">

            <div id="detail-general" class="detail-section active"></div>

            <div id="detail-contacto" class="detail-section"></div>

            <div id="detail-comercial" class="detail-section"></div>

        </div>

        <div class="modal-footer modal-detail-footer">
            <button class="btn btn-secondary btn-cancel-detail-modal">
                Cerrar
            </button>
        </div>

    </div>
</div>

<!-- ============================================================================
     MODAL: Confirmación de Eliminación
     ============================================================================ -->
<div id="modal-confirm" class="modal-overlay hidden">
    <div class="modal-box" style="max-width: 500px;">
        <div class="modal-header" style="background: #dc2626;">
            <div>
                <h2><i class="fas fa-exclamation-triangle"></i> Confirmar Eliminación</h2>
            </div>
            <button type="button" class="modal-close" onclick="ClienteManager.modals.closeConfirm()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <div id="confirm-message" style="font-size: 14px; color: #1e293b; line-height: 1.6; margin-bottom: 20px;">
                <!-- Se llena con JavaScript -->
            </div>
            <p style="font-size: 12px; color: #94a3b8;">Esta acción no se puede deshacer.</p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="confirm-cancel-btn">Cancelar</button>
            <button type="button" class="btn btn-danger" id="confirm-ok-btn">
                <i class="fas fa-trash"></i> Eliminar
            </button>
        </div>
    </div>
</div>

<!-- ============================================================================
     MODAL: nuevo cliente
     ============================================================================ -->
<div id="modal-new-cliente" class="modal-overlay hidden">

    <div class="modal-box modal-detail-box">

        <!-- HEADER -->
        <div class="modal-header green">

            <div>
                <h2>
                    <i class="fas fa-user-plus"></i>
                    Nuevo Cliente
                </h2>

                <p>Registrar un nuevo cliente en el sistema.</p>
            </div>

            <button
                type="button"
                class="modal-close btn-close-new-modal">

                <i class="fas fa-times"></i>

            </button>

        </div>

        <form id="new-cliente-form" method="post">

            <!--=========================================
            PESTAÑAS
            ==========================================-->

            <div class="edit-tab">

                <button
                    type="button"
                    class="detail-tab active"
                    data-new-tab="general">

                    <i class="fas fa-id-card"></i>
                    General

                </button>

                <button
                    type="button"
                    class="detail-tab"
                    data-new-tab="contacto">

                    <i class="fas fa-phone"></i>
                    Contacto

                </button>

                <button
                    type="button"
                    class="detail-tab"
                    data-new-tab="comercial">

                    <i class="fas fa-coins"></i>
                    Comercial

                </button>

            </div>

            <div class="modal-body">

                <!--=========================================
                GENERAL
                ==========================================-->

                <div id="new-general" class="edit-section active">

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">
                                Tipo Documento
                            </label>

                            <select
                                id="new-id-tipo"
                                name="txt_id_tipo"
                                class="form-select">

                                <option value="">Seleccione...</option>

                                <?php foreach($tipos as $tipo): ?>

                                <option value="<?= $tipo['id_tipo'] ?>">

                                    <?= htmlspecialchars($tipo['nom_tipo']) ?>

                                </option>

                                <?php endforeach; ?>

                            </select>

                        </div>

                        <div class="form-field">

                            <label class="form-label">
                                Número Identificación
                            </label>

                            <input
                                id="new-id-cliente"
                                name="txt_id_cliente"
                                class="form-input">
                                <span class="field-error"></span>

                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">

                                Tipo Cliente

                            </label>

                            <select
                                id="new-tipo-tercero"
                                name="sel_tipo_tercero"
                                class="form-select">

                                <option value="">Seleccione...</option>
                                <option value="false">Persona Natural</option>
                                <option value="true">Persona Jurídica</option>

                            </select>
                            <span class="field-error"></span>

                        </div>

                        <div class="form-field">

                            <label class="form-label">

                                Categoría

                            </label>

                            <select
                                id="new-cat-tercero"
                                name="sel_categoria"
                                class="form-select">

                                <option value="">Seleccione...</option>

                                <?php foreach($categorias as $categoria): ?>

                                <option value="<?= $categoria['id_cat_tercero'] ?>">

                                    <?= htmlspecialchars($categoria['nom_cat_tercero']) ?>

                                </option>

                                <?php endforeach; ?>

                            </select>
                            <span class="field-error"></span>

                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field full">

                            <label
                                id="lbl-new-nombre"
                                class="form-label">

                                Nombre Completo

                            </label>

                            <input
                                id="new-cliente-nombre"
                                name="txt_nom_tercero"
                                class="form-input">
                                <span class="field-error"></span>

                        </div>

                    </div>
                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">
                                Fecha Nacimiento
                            </label>
                            <input type="date" id="new-cliente-fec-nac" name="txt_fec_nac" class="form-input">
                                <span class="field-error"></span>
                        </div>
                        <div class="form-field">
                            <label class="form-label">
                                Género
                            </label>
                            <select id="new-cliente-genero" name="sel_genero" class="form-select">
                                <option value="">Seleccione...</option>
                                <option value="F">Femenino</option>
                                <option value="M">Masculino</option>
                                <option value="NB">No Binario</option>
                                <option value="T">Transgénero</option>

                            </select>
                            <span class="field-error"></span>

                        </div>

                    </div>

                </div>

                <!--=========================================
                CONTACTO
                ==========================================-->

                <div id="new-contacto" class="edit-section">

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">
                                Prefijo
                            </label>

                            <select
                                id="new-prefijo"
                                name="sel_prefijo_movil"
                                class="form-select">

                                <option value="">Seleccione...</option>

                                <?php foreach($prefijos as $prefijo): ?>

                                <option value="<?= $prefijo['id_prefijo_movil'] ?>">

                                    +<?= $prefijo['id_prefijo_movil'] ?>
                                    -
                                    <?= htmlspecialchars($prefijo['nom_pais']) ?>

                                </option>

                                <?php endforeach; ?>

                            </select>
                            <span class="field-error"></span>

                        </div>

                        <div class="form-field">

                            <label class="form-label">

                                Celular

                            </label>
                        <input id="new-cliente-tel-movil" name="txt_tel_movil" class="form-input">
                                    <span class="field-error"></span>
                        </div>

                    </div>

                    <div class="form-grid">
                        <div class="form-field">
                            <label class="form-label">
                                Teléfono Fijo
                            </label>
                        <input id="new-cliente-tel-fijo" name="txt_tel_fijo" class="form-input">
                                <span class="field-error"></span>

                        </div>
                        <div class="form-field">
                            <label class="form-label">
                                Correo
                            </label>
                        <input type="email" id="new-cliente-email" name="txt_email" class="form-input">
                                <span class="field-error"></span>
                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">

                                Dirección

                            </label>
                            <input id="new-cliente-direccion" name="txt_direccion" class="form-input">
                                    <span class="field-error"></span>
                        </div>

                        <div class="form-field">

                            <label class="form-label">

                                Ciudad

                            </label>
                            <select id="new-cliente-ciudad" name="sel_ciudad" class="form-select">
                                <option value="">Seleccione...</option>

                                <?php foreach($ciudades_lista as $ciudad): ?>

                                <option value="<?= $ciudad['id_ciudad'] ?>">

                                    <?= htmlspecialchars($ciudad['nom_ciudad']) ?>

                                </option>

                                <?php endforeach; ?>

                            </select>
                            <span class="field-error"></span>

                        </div>

                    </div>

                </div>

                <!--=========================================
                COMERCIAL
                ==========================================-->

                <div id="new-comercial" class="edit-section">

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">

                                Restricción

                            </label>
                            <select id="new-cliente-restriccion" name="sel_restriccion" class="form-select">
                                <option value="">Seleccione...</option>

                                <?php foreach($restricciones as $r): ?>

                                <option value="<?= $r['id_restriccion'] ?>">

                                    <?= htmlspecialchars($r['nom_restriccion']) ?>

                                </option>

                                <?php endforeach; ?>

                            </select>
                            <span class="field-error"></span>

                        </div>
                        <div class="form-field">
                            <label class="form-label">
                                Puntos
                            </label>
                            <input type="number" id="new-cliente-puntos" name="txt_puntos" class="form-input" value="0">
                                <span class="field-error"></span>
                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">

                                Estado

                            </label>
                            <select id="new-cliente-estado" name="sel_estado" class="form-select">
                                <option value="true" selected>Activo</option>
                                <option value="false">Inactivo</option>

                            </select>
                            <span class="field-error"></span>

                        </div>

                        <div class="form-field">

                            <label class="form-label">

                                Crédito

                            </label>

                            <div
                                id="new-credito-switch"
                                class="switch-toggle">

                                <span id="new-credito-label">

                                    No

                                </span>

                            </div>

                            <input
                                type="hidden"
                                id="new-credito-hidden"
                                name="sel_credito"
                                value="false">

                        </div>

                    </div>

                    <div class="form-grid">

                        <div class="form-field">

                            <label class="form-label">

                                Cupo Crédito

                            </label>

                            <input
                                type="number"
                                id="new-cliente-cupo"
                                name="txt_cupo"
                                class="form-input">


                        </div>

                        <div class="form-field">

                            <label class="form-label">

                                Días Cartera

                            </label>

                            <input
                                type="number"
                                id="new-cliente-diascartera"
                                name="txt_dias_cartera"
                                class="form-input">

                        </div>

                    </div>

                </div>

            </div>

            <input
                type="hidden"
                name="btn_guardar"
                value="1">

            <div class="modal-footer">

                <button
                    type="button"
                    class="btn btn-secondary btn-cancel-new-modal">

                    Cancelar

                </button>

                <button
                    type="submit"
                    class="btn btn-success">

                    <i class="fas fa-save"></i>
                    Guardar Cliente

                </button>

            </div>

        </form>

    </div>

</div>
<!-- ============================================================================
     TOAST (Notificaciones)
     ============================================================================ -->
<div id="toast" class="hidden">
    <span id="toast-message"></span>
</div>

<!-- ============================================================================
     DATOS PARA JAVASCRIPT
     ============================================================================ -->
<script>
const clientesData = <?= json_encode($clientes, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>;
</script>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>

