<?phpPara que una vista se conecte a tu base de datos y consulte información sin recargar la página, lo ideal es combinar HTML con CSS, usar JavaScript (Fetch API o AJAX) para enviar la petición, un archivo PHP que reciba la orden y el archivo prepare para realizar la consulta segura

Aquí tienes un ejemplo de la estructura.



1. El archivo con la consulta (prepare)

Crea un archivo llamado prepare_faccar.php. Usaremos PDO y prepare (sentencia preparada). Esto es muy importante porque evita inyecciones SQL (cuando personas malintencionadas modifican tus consultas a la base de datos). 



2. El archivo de la Vista (PHP)

Crea tu archivo vendedores.php. Este archivo con los formularios y validaciones.Código PHP que reciba los datos enviados por JavaScript y utilice una consulta preparada (prepare) para insertar los datos en la base de datos 



3.style.css: crea un archivo vendedores.css Estilos para que la vista sea moderna, organizada y fácil de leer.

4.app.js (Frontend): crea un archivo vendedores.jsCódigo JavaScript que use la API fetch para enviar los datos del formulario a PHP y actualizar la lista en tiempo real sin recargar la página y con validaciones de los datos que ingresa el cliente.: Código JavaScript puro (sin librerías como jQuery) usando fetch para enviar los datos del formulario a un archivo PHP sin recargar la página (AJAX). 



te doy unas imagenes de referencia para el diseño de la interfaz, te envio las funciones y la tabla 



tabla:

CREATE TABLE IF NOT EXISTS tab_vendedores
(
	id_vendedor                     VARCHAR(10)                 NOT NULL DEFAULT '0000000000',                                            -- Número de identificación del empleado
    val_porcomision                 DECIMAL(2,0)                NOT NULL CHECK(val_porcomision>=1 AND val_porcomision<=99),               --el porcentaje de la comision que gana el vendedor
    val_ven_acumu                   DECIMAL(15,0)               NOT NULL CHECK(val_ven_acumu>=0 AND val_ven_acumu<=999999999999999),      --El Valor de ventas acomuladas del vendedor
    ind_estado                      BOOLEAN                     NOT NULL DEFAULT TRUE, --TRUE=Activo / FALSE=No activo                    --indicador del estado del vendedor
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo --indicador de borrado lógico
	PRIMARY KEY (id_vendedor),
    FOREIGN KEY(id_vendedor)        REFERENCES tab_empleados(id_empleado)
);

depende de la tabla empleados y cargos

CREATE TABLE IF NOT EXISTS tab_cargos
(
    id_cargo                VARCHAR(5)             NOT NULL DEFAULT 'CAR00',                          -- Número de identificación del cargo
    nom_cargo               VARCHAR(50)            NOT NULL DEFAULT 'SIN CARGO',                    -- Nombre del cargo
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_cargo)                                                          
);
CREATE INDEX idx_nom_cargo ON tab_cargos(nom_cargo);  

NO debe depender de terceros.




// ==================================================
// Módulo: Clientes (ERP ADSO)
// Basado en la estructura de proveedores.php
// ==================================================

// --- Configuración de la página ---
$pageTitle        = 'ERP ADSO — Clientes';
$activeModule     = 'clientes';
$page_title       = 'ADSOERP | Clientes';
$page_description = 'Gestión de clientes, crédito y puntos de fidelidad';
$page_icon        = 'bi-people';
$page_extra_css   = ['../modules/faccar/css/clientes.css'];
$page_extra_js    = ['../modules/faccar/js/clientes.js'];
$show_welcome     = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

// --- Cargar dependencias ---
require_once(__DIR__ . '/../../compro/src/prepare_compro.php');   // Para terceros
require_once('prepare_faccar.php');                               // Para clientes

// ============================================================
// FUNCIONES AUXILIARES
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

const TIPOS_SOLO_NUMEROS = ['CC', 'TI', 'RC', 'NIT', 'NUIP'];

// ============================================================
// CARGAR SELECTS (combos)
// ============================================================
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

// ============================================================
// MANEJO DE PETICIONES POST (AJAX) - IGUAL QUE EN PROVEEDORES
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');
    $respuesta = ['success' => false, 'message' => '', 'errors' => []];

    try {
        // ---------- NUEVO CLIENTE ----------
        if (isset($_POST['btn_nuevo'])) {
            $id_tipo          = trim($_POST['txt_id_tipo'] ?? '');
            $id_tercero       = strtoupper(trim($_POST['txt_id_tercero'] ?? ''));
            $ind_tipo_tercero = ($_POST['sel_tipo_tercero'] ?? '') === 'true';
            $id_cat_tercero   = (int)($_POST['sel_categoria'] ?? 0);
            $nom_tercero      = trim($_POST['txt_nom_tercero'] ?? '');
            $email            = strtolower(trim($_POST['txt_email'] ?? ''));
            $direccion        = trim($_POST['txt_direccion'] ?? '');
            $tel_fijo_raw     = trim($_POST['txt_tel_fijo'] ?? '');
            $tel_fijo         = ($tel_fijo_raw !== '') ? $tel_fijo_raw : null;
            $tel_movil_raw    = trim($_POST['txt_tel_movil'] ?? '');
            $tel_movil        = ($tel_movil_raw !== '') ? $tel_movil_raw : null;
            $prefijo_movil_raw = trim($_POST['txt_prefijo_movil'] ?? '');
            $id_prefijo_movil = ($prefijo_movil_raw !== '' && (int)$prefijo_movil_raw > 0) ? (int)$prefijo_movil_raw : null;
            $id_ciudad        = trim($_POST['sel_ciudad'] ?? '');
            $id_restriccion   = (int)($_POST['sel_restriccion'] ?? 0);
            $ind_estado       = ($_POST['sel_estado'] ?? 'true') === 'true';
            $val_sigla        = strtoupper(trim($_POST['txt_sigla'] ?? ''));

            // --- Datos de tab_clientes ---
            $fec_nacimi   = trim($_POST['txt_fec_nac'] ?? '');
            $genero       = trim($_POST['sel_genero'] ?? 'F');
            $puntos       = (int)($_POST['txt_puntos'] ?? 0);
            $credito      = ($_POST['sel_credito'] ?? 'false') === 'true';
            $cupo         = (float)($_POST['txt_cupo'] ?? 0);
            $dias_cartera = (int)($_POST['txt_dias_cartera'] ?? 0);

            // --- Validaciones ---
            $errores = [];

            // Validar terceros
            if (empty($id_tipo)) {
                $errores['err-new-id-tipo'] = 'Seleccione el tipo de documento.';
            }
            if (empty($id_tercero)) {
                $errores['err-new-id'] = 'El NIT / identificación es obligatorio.';
            } elseif (in_array($id_tipo, TIPOS_SOLO_NUMEROS)) {
                if (!preg_match('/^[0-9]{7,10}$/', $id_tercero)) {
                    $errores['err-new-id'] = 'Para ' . htmlspecialchars($id_tipo) . ' el ID debe tener entre 7 y 10 dígitos numéricos.';
                }
            } else {
                if (!preg_match('/^[A-Z0-9]{7,10}$/', $id_tercero)) {
                    $errores['err-new-id'] = 'El ID debe tener entre 7 y 10 caracteres alfanuméricos en mayúsculas.';
                }
            }
            if ($id_cat_tercero < 1 || $id_cat_tercero > 99) {
                $errores['err-new-cat-tercero'] = 'Seleccione una categoría válida.';
            }
            if (strlen($nom_tercero) < 4 || strlen($nom_tercero) > 50) {
                $errores['err-new-razon'] = 'El nombre completo debe tener entre 4 y 50 caracteres.';
            }
            if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errores['err-new-email'] = 'El email corporativo no es válido.';
            }
            if (empty($direccion)) {
                $errores['err-new-direccion'] = 'La dirección es obligatoria.';
            }
            if ($tel_fijo !== null && !preg_match('/^[0-9]{7,10}$/', $tel_fijo)) {
                $errores['err-new-tel-fijo'] = 'El teléfono fijo debe tener entre 7 y 10 dígitos.';
            }
            if ($tel_movil !== null && $id_prefijo_movil === null) {
                $errores['err-new-tel-movil'] = 'Si ingresa celular debe seleccionar también el prefijo (código de país).';
            }
            if ($id_prefijo_movil !== null && $tel_movil === null) {
                $errores['err-new-tel-movil'] = 'Si selecciona el prefijo debe ingresar el número de celular.';
            }
            if ($tel_movil !== null && !preg_match('/^[0-9]{7,15}$/', $tel_movil)) {
                $errores['err-new-tel-movil'] = 'El número de celular debe tener entre 7 y 15 dígitos.';
            }
            
            if (strlen($val_sigla) > 0 && (strlen($val_sigla) < 2 || strlen($val_sigla) > 10)) {
                $errores['err-new-sigla'] = 'La sigla debe tener entre 2 y 10 caracteres (opcional).';
            }
            if (empty($id_ciudad)) {
                $errores['err-new-ciudad'] = 'Seleccione una ciudad.';
            }
            if ($id_restriccion < 1 || $id_restriccion > 99) {
                $errores['err-new-restriccion'] = 'Seleccione una restricción válida.';
            }

            // Validar cliente
            if (empty($fec_nacimi)) {
                $errores['err-new-fecnac'] = 'La fecha de nacimiento es obligatoria.';
            } else {
                $edad = date_diff(date_create($fec_nacimi), date_create('today'))->y;
                if ($edad < 16) {
                    $errores['err-new-fecnac'] = 'El cliente debe tener al menos 16 años.';
                }
            }
            if (!in_array($genero, ['M','F','T','NB'])) {
                $errores['err-new-genero'] = 'Género no válido.';
            }
            if ($puntos < 0 || $puntos > 9999999999) {
                $errores['err-new-puntos'] = 'Los puntos deben estar entre 0 y 9.999.999.999.';
            }
            if ($credito) {
                if ($cupo < 0 || $cupo > 999999999999) {
                    $errores['err-new-cupo'] = 'El cupo debe estar entre 0 y 999.999.999.999.';
                }
                if ($dias_cartera < 0 || $dias_cartera > 120) {
                    $errores['err-new-diascartera'] = 'Los días de cartera deben estar entre 0 y 120.';
                }
            } else {
                $cupo = 0;
                $dias_cartera = 0;
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            // --- Inserción en BD ---
            $pdo->beginTransaction();

            // 1. Insertar en tab_terceros
            $ins_tercero->execute([
                ':id_tipo'          => $id_tipo,
                ':id_tercero'       => $id_tercero,
                ':ind_tipo_tercero' => $ind_tipo_tercero ? 'true' : 'false',
                ':id_cat_tercero'   => $id_cat_tercero,
                ':nom_tercero'      => $nom_tercero,
                ':nom_corto'        => null,
                ':direccion'        => $direccion,
                ':tel_fijo'         => $tel_fijo,
                ':id_prefijo_movil' => $id_prefijo_movil,
                ':tel_movil'        => $tel_movil,
                ':email'            => $email,
                ':id_ciudad'        => $id_ciudad,
                ':id_restriccion'   => $id_restriccion,
                ':ind_estado'       => $ind_estado ? 'true' : 'false',
            ]);

            // 2. Insertar en tab_clientes
            $ins_cliente->execute([
                ':id_cliente'   => $id_tercero,
                ':id_tipo'      => $id_tipo,
                ':fec_nacimi'   => $fec_nacimi,
                ':genero'       => $genero,
                ':puntos'       => $puntos,
                ':credito'      => $credito ? 'true' : 'false',
                ':cupo'         => $cupo,
                ':dias_cartera' => $dias_cartera,
            ]);
        // Ejemplo de respuesta:
            $respuesta['success'] = true;
            $respuesta['message'] = 'Cliente registrado exitosamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- EDITAR CLIENTE ----------
        if (isset($_POST['btn_editar'])) {
            // --- Recibir datos ---
            $id_tercero       = trim($_POST['txt_edit_id_tercero'] ?? '');
            $id_tipo          = trim($_POST['txt_edit_id_tipo'] ?? '');
            $ind_tipo_tercero = ($_POST['hid_edit_ind_tipo_tercero'] ?? '') === 'true';
            $id_cat_tercero   = (int)($_POST['sel_edit_categoria'] ?? 0);
            $nom_tercero      = trim($_POST['txt_edit_nom_tercero'] ?? '');
            $email            = strtolower(trim($_POST['txt_edit_email'] ?? ''));
            $direccion        = trim($_POST['txt_edit_direccion'] ?? '');
            $tel_fijo_raw     = trim($_POST['txt_edit_tel_fijo'] ?? '');
            $tel_fijo         = ($tel_fijo_raw !== '') ? $tel_fijo_raw : null;
            $tel_movil_raw    = trim($_POST['txt_edit_tel_movil'] ?? '');
            $tel_movil        = ($tel_movil_raw !== '') ? $tel_movil_raw : null;
            $prefijo_movil_raw = trim($_POST['txt_edit_prefijo_movil'] ?? '');
            $id_prefijo_movil = ($prefijo_movil_raw !== '' && (int)$prefijo_movil_raw > 0) ? (int)$prefijo_movil_raw : null;
            $id_ciudad        = trim($_POST['sel_edit_ciudad'] ?? '');
            $id_restriccion   = (int)($_POST['sel_edit_restriccion'] ?? 0);
            $ind_estado       = ($_POST['sel_edit_estado'] ?? 'true') === 'true';
            $val_sigla        = strtoupper(trim($_POST['txt_edit_sigla'] ?? ''));

            // Datos de cliente
            $fec_nacimi   = trim($_POST['txt_edit_fec_nac'] ?? '');
            $genero       = trim($_POST['sel_edit_genero'] ?? 'F');
            $puntos       = (int)($_POST['txt_edit_puntos'] ?? 0);
            $credito      = ($_POST['sel_edit_credito'] ?? 'false') === 'true';
            $cupo         = (float)($_POST['txt_edit_cupo'] ?? 0);
            $dias_cartera = (int)($_POST['txt_edit_dias_cartera'] ?? 0);

            // --- Validaciones (similares a nuevo) ---
            $errores = [];

            if (empty($id_tercero)) {
                $errores['err-edit-id'] = 'El ID del cliente es obligatorio.';
            }
            if ($id_cat_tercero < 1 || $id_cat_tercero > 99) {
                $errores['err-edit-cat-tercero'] = 'Seleccione una categoría válida.';
            }
            if (strlen($nom_tercero) < 4 || strlen($nom_tercero) > 50) {
                $errores['err-edit-razon'] = 'El nombre debe tener entre 4 y 50 caracteres.';
            }
            if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errores['err-edit-email'] = 'El email no es válido.';
            }
            if (empty($direccion)) {
                $errores['err-edit-direccion'] = 'La dirección es obligatoria.';
            }
            if ($tel_fijo !== null && !preg_match('/^[0-9]{7,10}$/', $tel_fijo)) {
                $errores['err-edit-tel-fijo'] = 'El teléfono fijo debe tener entre 7 y 10 dígitos.';
            }
            if ($tel_movil !== null && $id_prefijo_movil === null) {
                $errores['err-edit-tel-movil'] = 'Si ingresa celular debe seleccionar el prefijo.';
            }
            if ($id_prefijo_movil !== null && $tel_movil === null) {
                $errores['err-edit-tel-movil'] = 'Si selecciona el prefijo debe ingresar el número de celular.';
            }
            if ($tel_movil !== null && !preg_match('/^[0-9]{7,15}$/', $tel_movil)) {
                $errores['err-edit-tel-movil'] = 'El número de celular debe tener entre 7 y 15 dígitos.';
            }
            if (strlen($val_sigla) > 0 && (strlen($val_sigla) < 2 || strlen($val_sigla) > 10)) {
                $errores['err-edit-sigla'] = 'La sigla debe tener entre 2 y 10 caracteres (opcional).';
            }
            if (empty($id_ciudad)) {
                $errores['err-edit-ciudad'] = 'Seleccione una ciudad.';
            }
            if ($id_restriccion < 1 || $id_restriccion > 99) {
                $errores['err-edit-restriccion'] = 'Seleccione una restricción válida.';
            }
            if (empty($fec_nacimi)) {
                $errores['err-edit-fecnac'] = 'La fecha de nacimiento es obligatoria.';
            } else {
                $edad = date_diff(date_create($fec_nacimi), date_create('today'))->y;
                if ($edad < 16) {
                    $errores['err-edit-fecnac'] = 'El cliente debe tener al menos 16 años.';
                }
            }
            if (!in_array($genero, ['M','F','T','NB'])) {
                $errores['err-edit-genero'] = 'Género no válido.';
            }
            if ($puntos < 0 || $puntos > 9999999999) {
                $errores['err-edit-puntos'] = 'Los puntos deben estar entre 0 y 9.999.999.999.';
            }
            if ($credito) {
                if ($cupo < 0 || $cupo > 999999999999) {
                    $errores['err-edit-cupo'] = 'El cupo debe estar entre 0 y 999.999.999.999.';
                }
                if ($dias_cartera < 0 || $dias_cartera > 120) {
                    $errores['err-edit-diascartera'] = 'Los días de cartera deben estar entre 0 y 120.';
                }
            } else {
                $cupo = 0;
                $dias_cartera = 0;
            }

            if (!empty($errores)) {
                $respuesta['errors'] = $errores;
                echo json_encode($respuesta);
                exit;
            }

            // --- Actualizar en BD ---
            try {
                $pdo->beginTransaction();

                // 1. Actualizar tab_terceros
                $upd_tercero->execute([
                    ':id_tercero'       => $id_tercero,
                    ':ind_tipo_tercero' => $ind_tipo_tercero ? 'true' : 'false',
                    ':id_cat_tercero'   => $id_cat_tercero,
                    ':nom_tercero'      => $nom_tercero,
                    ':nom_corto'        => $val_sigla ?: null, // si quieres usar sigla como nom_corto
                    ':direccion'        => $direccion,
                    ':tel_fijo'         => $tel_fijo,
                    ':id_prefijo_movil' => $id_prefijo_movil,
                    ':tel_movil'        => $tel_movil,
                    ':email'            => $email,
                    ':id_ciudad'        => $id_ciudad,
                    ':id_restriccion'   => $id_restriccion,
                    ':ind_estado'       => $ind_estado ? 'true' : 'false',
                ]);

                // 2. Actualizar tab_clientes
                $upd_cliente->execute([
                    ':id_cliente'   => $id_tercero,
                    ':id_tipo'      => $id_tipo,
                    ':fec_nacimi'   => $fec_nacimi,
                    ':genero'       => $genero,
                    ':puntos'       => $puntos,
                    ':credito'      => $credito ? 'true' : 'false',
                    ':cupo'         => $cupo,
                    ':dias_cartera' => $dias_cartera,
                    ':ind_estado'   => $ind_estado ? 'true' : 'false',
                ]);

                $pdo->commit();

                $respuesta['success'] = true;
                $respuesta['message'] = 'Cliente actualizado correctamente.';
                echo json_encode($respuesta);
                exit;

            } catch (PDOException $e) {
                if ($pdo->inTransaction()) $pdo->rollBack();
                $mensaje = limpiar_error_pgsql($e->getMessage());
                $respuesta['message'] = $mensaje ?: $e->getMessage();
                echo json_encode($respuesta);
                exit;
            } catch (Exception $e) {
                if ($pdo->inTransaction()) $pdo->rollBack();
                $respuesta['success'] = false;
                $respuesta['message'] = 'Error en base de datos: ' . limpiar_error_pgsql($e->getMessage());
                echo json_encode($respuesta);
                error_log("Error en clientes (editar): " . $e->getMessage());
                exit;
            }
        }

        // ---------- ELIMINAR CLIENTE ----------
        if (isset($_POST['btn_eliminar'])) {
            // (Código de eliminación)
            $respuesta['success'] = true;
            $respuesta['message'] = 'Cliente eliminado correctamente.';
            echo json_encode($respuesta);
            exit;
        }

        // ---------- TOGGLE ESTADO ----------
        if (isset($_POST['btn_toggle'])) {
            // (Código de toggle)
            $respuesta['success'] = true;
            $respuesta['message'] = 'Estado del cliente cambiado.';
            echo json_encode($respuesta);
            exit;
        }

        // Si no se reconoce acción
        $respuesta['message'] = 'Acción no válida.';
        echo json_encode($respuesta);
        exit;

    } catch (PDOException $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        $mensaje = limpiar_error_pgsql($e->getMessage());
        $respuesta['message'] = $mensaje ?: $e->getMessage();
        echo json_encode($respuesta);
        exit;
    } catch (Exception $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        $respuesta['success'] = false;
        $respuesta['message'] = 'Error en base de datos: ' . limpiar_error_pgsql($e->getMessage());
        echo json_encode($respuesta);
        error_log("Error en clientes: " . $e->getMessage());
        exit;
    }
}

// ============================================================
// CARGAR LISTADO DE CLIENTES
// ============================================================
$sql = "
    SELECT DISTINCT ON (c.id_cliente)
        t.id_tercero,
        t.nom_tercero,
        t.ind_estado,
        t.id_tipo,
        ti.nom_tipo,
        t.id_cat_tercero,
        ct.nom_cat_tercero,
        t.id_ciudad,
        ci.nom_ciudad,
        t.id_restriccion,
        r.nom_restriccion,
        t.ind_tipo_tercero,
        (t.dir_tercero).email              AS email,
        (t.dir_tercero).direccion          AS direccion,
        (t.dir_tercero).tel_fijo           AS tel_fijo,
        (t.dir_tercero).id_prefijo_movil   AS id_prefijo_movil,
        (t.dir_tercero).tel_movil          AS tel_movil,
        c.id_cliente,
        c.fec_nacimi,
        c.val_edad,
        c.ind_genero,
        c.val_puntos,
        c.ind_credito,
        c.val_cupocredito,
        c.val_diascartera,
        c.ind_estado AS ind_estado_cliente
    FROM  tab_clientes c
    JOIN  tab_terceros       t  ON t.id_tercero  = c.id_cliente
    JOIN  tab_tipo_identidad ti ON ti.id_tipo    = t.id_tipo
    JOIN  tab_ciudades       ci ON ci.id_ciudad  = t.id_ciudad
    LEFT JOIN  tab_cat_terceros   ct ON ct.id_cat_tercero = t.id_cat_tercero
    LEFT JOIN  tab_restricciones  r  ON r.id_restriccion  = t.id_restriccion
    WHERE  c.ind_borrado = FALSE
      AND  t.ind_borrado = FALSE
      AND  c.id_cliente IS NOT NULL
    ORDER BY c.id_cliente, t.nom_tercero
";

$list_clientes_completo = $pdo->prepare($sql);
$list_clientes_completo->execute();
$clientes = $list_clientes_completo->fetchAll(PDO::FETCH_ASSOC);

// --- Normalización ---
foreach ($clientes as &$c) {
    $c['id_tercero']         = $c['id_tercero'] ?? null;
    $c['nom_tercero']        = $c['nom_tercero'] ?? '';
    $c['ind_estado']         = ($c['ind_estado'] === 't' || $c['ind_estado'] === true);
    $c['id_tipo']            = $c['id_tipo'] ?? '';
    $c['nom_tipo']           = $c['nom_tipo'] ?? '';
    $c['id_ciudad']          = $c['id_ciudad'] ?? '';
    $c['nom_ciudad']         = $c['nom_ciudad'] ?? '';
    $c['id_cliente']         = $c['id_cliente'] ?? '';
    $c['fec_nacimi']         = $c['fec_nacimi'] ?? null;
    $c['val_edad']           = (int)($c['val_edad'] ?? 0);
    $c['ind_genero']         = $c['ind_genero'] ?? 'F';
    $c['val_puntos']         = (int)($c['val_puntos'] ?? 0);
    $c['ind_credito']        = ($c['ind_credito'] === 't' || $c['ind_credito'] === true);
    $c['val_cupocredito']    = (float)($c['val_cupocredito'] ?? 0);
    $c['val_diascartera']    = (int)($c['val_diascartera'] ?? 0);
    $c['ind_estado_cliente'] = ($c['ind_estado_cliente'] === 't' || $c['ind_estado_cliente'] === true);
    $c['estado'] = $c['ind_estado_cliente'];
    $c['email']      = $c['email'] ?? '';
    $c['direccion']  = $c['direccion'] ?? '';
    $c['tel_fijo']   = $c['tel_fijo'] ?? '';
    $c['tel_movil']  = $c['tel_movil'] ?? '';
    $c['id_cat_tercero']   = $c['id_cat_tercero'] ?? 0;
    $c['id_restriccion']   = $c['id_restriccion'] ?? 0;
    $c['id_prefijo_movil'] = $c['id_prefijo_movil'] ?? null;
    $c['ind_tipo_tercero'] = $c['ind_tipo_tercero'] ?? false;
    $c['val_sigla']  = $c['val_sigla'] ?? '';
}

// ============================================================
// INICIO DEL HTML (IGUAL QUE EN PROVEEDORES)
// ============================================================
ob_start();
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-clientes" class="app-view active">

    <!-- ENCABEZADO -->
    <div class="module-header">
        <div class="module-header-text">
            <h1>Clientes</h1>
            <p>Gestión de clientes, crédito y puntos de fidelidad</p>
        </div>
        <button type="button" id="btn-add-cliente" class="btn btn-primary">
            <i class="fas fa-user-plus"></i> Nuevo Cliente
        </button>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <?php
        $total       = count($clientes);
        $activos     = count(array_filter($clientes, fn($c) => $c['estado'] === true));
        $inactivos   = $total - $activos;
        $con_credito = count(array_filter($clientes, fn($c) => $c['ind_credito'] === true));
        $cupo_total  = array_sum(array_column($clientes, 'val_cupocredito'));
        ?>
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-users"></i></div>
            <div class="stat-info">
                <div class="stat-label">Total</div>
                <div class="stat-value" id="stat-total"><?= $total ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-user-check"></i></div>
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
            <div class="stat-icon amber"><i class="fas fa-sack-dollar"></i></div>
            <div class="stat-info">
                <div class="stat-label">Cupo Total</div>
                <div class="stat-value" id="stat-cupo" style="font-size:20px;">$<?= number_format($cupo_total, 0, ',', '.') ?></div>
            </div>
        </div>
    </div>

    <!-- FILTROS -->
    <div class="filter-bar">
        <div class="search-wrapper">
            <span class="search-icon"><i class="fas fa-search"></i></span>
            <input type="text" id="cliente-search" class="search-input" placeholder="Buscar por nombre o documento...">
        </div>
        <div class="filter-toggle-group">
            <button class="filter-toggle active" data-filter="all">Todos</button>
            <button class="filter-toggle" data-filter="active">Activos</button>
            <button class="filter-toggle" data-filter="inactive">Inactivos</button>
        </div>
        <button id="btn-clear-filters" class="btn-clear-filter" style="display:none">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="clientes-count"><?= $total ?> resultado<?= $total !== 1 ? 's' : '' ?></span>
    </div>

    <!-- TABLA (EXACTAMENTE IGUAL QUE EN PROVEEDORES) -->
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Cliente</th>
                    <th>Documento</th>
                    <th>Género</th>
                    <th>Edad</th>
                    <th class="text-center">Crédito</th>
                    <th class="text-center">Puntos</th>
                    <th class="text-center">Estado</th>
                    <th class="text-center">Acciones</th>
                </tr>
            </thead>
            <tbody id="clientes-tbody">
            <?php if (empty($clientes)): ?>
                <tr class="empty-row">
                    <td colspan="8">
                        <div class="empty-state">
                            <i class="fas fa-users"></i>
                            <p>No hay clientes registrados</p>
                            <span>Haga clic en "Nuevo Cliente" para agregar el primero</span>
                        </div>
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($clientes as $c):
                    $es_activo = $c['estado'] === true;
                    $badge = $es_activo
                        ? '<span class="badge badge-active">Activo</span>'
                        : '<span class="badge badge-inactive">Inactivo</span>';
                    $credito_badge = $c['ind_credito']
                        ? '<span class="badge badge-success">APROBADO</span><br><small style="color:#475569;">$'.number_format($c['val_cupocredito'], 0, ',', '.').'</small>'
                        : '<span class="badge badge-neutral">SIN CRÉDITO</span>';
                    $genero_label = ['M'=>'Masculino','F'=>'Femenino','T'=>'Transgénero','NB'=>'No binario'][$c['ind_genero']] ?? $c['ind_genero'];
                ?>
                <tr onclick="openDetailModal('<?= htmlspecialchars($c['id_cliente']) ?>')">
                    <td>
                        <strong><?= htmlspecialchars($c['nom_tercero']) ?></strong><br>
                        <small style="color:#94a3b8;font-size:11px"><?= htmlspecialchars($c['id_ciudad'] ? $c['nom_ciudad'] : '') ?></small>
                    </td>
                    <td><?= htmlspecialchars($c['id_tipo']) ?> <?= htmlspecialchars($c['id_cliente']) ?></td>
                    <td><?= $genero_label ?></td>
                    <td><?= $c['val_edad'] ?> años</td>
                    <td class="text-center"><?= $credito_badge ?></td>
                    <td class="text-center"><?= number_format($c['val_puntos'], 0, ',', '.') ?></td>
                    <td class="text-center"><?= $badge ?></td>
                    <td class="text-center" onclick="event.stopPropagation()">
                        <button class="btn-icon-sm view"   onclick="openDetailModal('<?= htmlspecialchars($c['id_cliente']) ?>')"><i class="fas fa-eye"></i></button>
                        <button class="btn-icon-sm edit"   onclick="openEditModal('<?= htmlspecialchars($c['id_cliente']) ?>')"><i class="fas fa-edit"></i></button>
                        <button class="btn-icon-sm reject" onclick="eliminarCliente('<?= htmlspecialchars($c['id_cliente']) ?>', '<?= htmlspecialchars($c['nom_tercero'], ENT_QUOTES) ?>')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
                <?php endforeach; ?>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- ====================================================== -->
<!-- MODALES (NUEVO, DETALLE, EDITAR, CONFIRMAR)           -->
<!-- ====================================================== -->
<div id="modal-new-cliente" class="modal-overlay hidden">
    <div class="modal-box modal-box-wide">
        <div class="modal-header green">
            <div>
                <h2>Nuevo Cliente</h2>
                <p>Complete la información del cliente</p>
            </div>
            <button class="modal-close btn-close-new-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="new-cliente-form" novalidate>
                <input type="hidden" name="btn_nuevo" value="1">
                <!-- ===== IDENTIFICACIÓN ===== -->
                <div class="modal-section-title"><i class="fas fa-id-card"></i> Identificación</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Tipo de Documento <span class="required">*</span></label>
                        <select id="new-id-tipo" name="txt_id_tipo" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($tipos as $t): ?>
                                <option value="<?= htmlspecialchars($t['id_tipo']) ?>"><?= htmlspecialchars($t['nom_tipo']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-new-id-tipo"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">NIT / Identificación <span class="required">*</span></label>
                        <input type="text" id="new-cliente-id" name="txt_id_tercero" class="form-input" placeholder="Ej: 900123456">
                        <span class="field-error" id="err-new-id"></span>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Tipo de Persona <span class="required">*</span></label>
                        <select id="new-tipo-tercero" name="sel_tipo_tercero" class="form-select">
                            <option value="">Seleccione...</option>
                            <option value="true">Jurídica</option>
                            <option value="false">Natural</option>
                        </select>
                        <span class="field-error" id="err-new-tipo-tercero"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Categoría <span class="required">*</span></label>
                        <select id="new-cat-tercero" name="sel_categoria" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($categorias as $c): ?>
                                <option value="<?= htmlspecialchars($c['id_cat_tercero']) ?>"><?= htmlspecialchars($c['nom_cat_tercero']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-new-cat-tercero"></span>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Nombre <span class="required">*</span></label>
                        <input type="text" id="new-cliente-nombre" name="txt_nom_tercero" class="form-input" placeholder="Ej: Juan Pérez García">
                        <span class="field-error" id="err-new-razon"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Sigla <span style="font-weight:400; color:#94a3b8;">(opcional)</span></label>
                        <input type="text" id="new-cliente-sigla" name="txt_sigla" class="form-input" placeholder="Ej: JPG" maxlength="10">
                        <span class="field-error" id="err-new-sigla"></span>
                    </div>
                </div>
                <!-- ===== CONTACTO ===== -->
                <div class="modal-section-title"><i class="fas fa-address-card"></i> Contacto</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Celular</label>
                        <div class="input-prefix-group">
                            <select id="new-prefijo-movil" name="txt_prefijo_movil" class="form-select prefix-select">
                                <option value="">+</option>
                                <?php foreach ($prefijos as $pf): ?>
                                    <option value="<?= $pf['id_prefijo_movil'] ?>">+<?= $pf['id_prefijo_movil'] ?> <?= htmlspecialchars($pf['nom_pais']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="tel" id="new-cliente-tel-movil" name="txt_tel_movil" class="form-input" placeholder="Ej: 3001234567">
                        </div>
                        <span class="field-error" id="err-new-tel-movil"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Teléfono Fijo</label>
                        <input type="tel" id="new-cliente-tel-fijo" name="txt_tel_fijo" class="form-input" placeholder="Ej: 6012345678">
                        <span class="field-error" id="err-new-tel-fijo"></span>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Email <span class="required">*</span></label>
                        <input type="email" id="new-cliente-email" name="txt_email" class="form-input" placeholder="correo@empresa.com">
                        <span class="field-error" id="err-new-email"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Dirección <span class="required">*</span></label>
                        <input type="text" id="new-cliente-direccion" name="txt_direccion" class="form-input" placeholder="Cra 5 # 12-45">
                        <span class="field-error" id="err-new-direccion"></span>
                    </div>
                </div>
                <!-- ===== DATOS PERSONALES ===== -->
                <div class="modal-section-title"><i class="fas fa-user"></i> Datos Personales</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Fecha de Nacimiento <span class="required">*</span></label>
                        <input type="date" id="new-cliente-fecnac" name="txt_fec_nac" class="form-input">
                        <span class="field-error" id="err-new-fecnac"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Género <span class="required">*</span></label>
                        <select id="new-cliente-genero" name="sel_genero" class="form-select">
                            <option value="">Seleccione...</option>
                            <option value="F">Femenino</option>
                            <option value="M">Masculino</option>
                            <option value="NB">No binario</option>
                            <option value="T">Transgénero</option>
                        </select>
                        <span class="field-error" id="err-new-genero"></span>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Ciudad <span class="required">*</span></label>
                        <select id="new-cliente-ciudad" name="sel_ciudad" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($ciudades_lista as $c): ?>
                                <option value="<?= htmlspecialchars($c['id_ciudad']) ?>"><?= htmlspecialchars($c['nom_ciudad']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-new-ciudad"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Restricción <span class="required">*</span></label>
                        <select id="new-cliente-restriccion" name="sel_restriccion" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($restricciones as $r): ?>
                                <option value="<?= htmlspecialchars($r['id_restriccion']) ?>"><?= htmlspecialchars($r['nom_restriccion']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-new-restriccion"></span>
                    </div>
                </div>
                <!-- ===== CAMPOS OCULTOS ===== -->
                <input type="hidden" name="sel_credito" value="false">
                <input type="hidden" name="sel_estado" value="true">
                <input type="hidden" name="txt_puntos" value="0">
                <input type="hidden" name="txt_cupo" value="0">
                <input type="hidden" name="txt_dias_cartera" value="0">
                
                <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-cancel-new-modal">Cancelar</button>
                <button type="submit" class="btn btn-success" id="btn-new-submit">
                    <i class="fas fa-save"></i> Guardar Cliente
                </button>
            </form>
        </div>
    </div>
    </div>
</div>

<!-- MODAL: EDITAR CLIENTE -->
<div id="modal-edit-cliente" class="modal-overlay hidden">
    <div class="modal-box modal-box-wide">
        <div class="modal-header amber">
            <div>
                <h2>Editar Cliente</h2>
                <p>Actualice la información del cliente</p>
            </div>
            <button class="modal-close btn-close-edit-modal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="edit-cliente-form" novalidate>
                <input type="hidden" name="btn_editar" value="1">
                <input type="hidden" id="hid-edit-id-cliente" name="txt_edit_id_tercero">
                <input type="hidden" id="edit-tipo-doc-hidden" name="txt_edit_id_tipo">

                <!-- ===== IDENTIFICACIÓN ===== -->
                <div class="modal-section-title"><i class="fas fa-id-card"></i> Identificación</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Tipo de Documento <span class="required">*</span></label>
                        <select id="edit-id-tipo" class="form-select" disabled>
                            <option value="">Seleccione...</option>
                            <?php foreach ($tipos as $t): ?>
                                <option value="<?= htmlspecialchars($t['id_tipo']) ?>"><?= htmlspecialchars($t['nom_tipo']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-edit-id-tipo"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">NIT / Identificación <span class="required">*</span></label>
                        <input type="text" id="edit-cliente-id" class="form-input" readonly>
                        <span class="field-error" id="err-edit-id"></span>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Tipo de Persona <span class="required">*</span></label>
                        <select id="edit-tipo-tercero" name="hid_edit_ind_tipo_tercero" class="form-select">
                            <option value="">Seleccione...</option>
                            <option value="true">Jurídica</option>
                            <option value="false">Natural</option>
                        </select>
                        <span class="field-error" id="err-edit-tipo-tercero"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Categoría <span class="required">*</span></label>
                        <select id="edit-cat-tercero" name="sel_edit_categoria" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($categorias as $c): ?>
                                <option value="<?= htmlspecialchars($c['id_cat_tercero']) ?>"><?= htmlspecialchars($c['nom_cat_tercero']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-edit-cat-tercero"></span>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Nombre <span class="required">*</span></label>
                        <input type="text" id="edit-cliente-nombre" name="txt_edit_nom_tercero" class="form-input" placeholder="Ej: Juan Pérez García">
                        <span class="field-error" id="err-edit-razon"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Sigla <span style="font-weight:400; color:#94a3b8;">(opcional)</span></label>
                        <input type="text" id="edit-cliente-sigla" name="txt_edit_sigla" class="form-input" placeholder="Ej: JPG" maxlength="10">
                        <span class="field-error" id="err-edit-sigla"></span>
                    </div>
                </div>

                <!-- ===== CONTACTO ===== -->
                <div class="modal-section-title"><i class="fas fa-address-card"></i> Contacto</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Celular</label>
                        <div class="input-prefix-group">
                            <select id="edit-prefijo-movil" name="txt_edit_prefijo_movil" class="form-select prefix-select">
                                <option value="">+</option>
                                <?php foreach ($prefijos as $pf): ?>
                                    <option value="<?= $pf['id_prefijo_movil'] ?>">+<?= $pf['id_prefijo_movil'] ?> <?= htmlspecialchars($pf['nom_pais']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="tel" id="edit-cliente-tel-movil" name="txt_edit_tel_movil" class="form-input" placeholder="Ej: 3001234567">
                        </div>
                        <span class="field-error" id="err-edit-tel-movil"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Teléfono Fijo</label>
                        <input type="tel" id="edit-cliente-tel-fijo" name="txt_edit_tel_fijo" class="form-input" placeholder="Ej: 6012345678">
                        <span class="field-error" id="err-edit-tel-fijo"></span>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Email <span class="required">*</span></label>
                        <input type="email" id="edit-cliente-email" name="txt_edit_email" class="form-input" placeholder="correo@empresa.com">
                        <span class="field-error" id="err-edit-email"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Dirección <span class="required">*</span></label>
                        <input type="text" id="edit-cliente-direccion" name="txt_edit_direccion" class="form-input" placeholder="Cra 5 # 12-45">
                        <span class="field-error" id="err-edit-direccion"></span>
                    </div>
                </div>

                <!-- ===== DATOS PERSONALES ===== -->
                <div class="modal-section-title"><i class="fas fa-user"></i> Datos Personales</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Fecha de Nacimiento <span class="required">*</span></label>
                        <input type="date" id="edit-cliente-fecnac" name="txt_edit_fec_nac" class="form-input">
                        <span class="field-error" id="err-edit-fecnac"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Género <span class="required">*</span></label>
                        <select id="edit-cliente-genero" name="sel_edit_genero" class="form-select">
                            <option value="">Seleccione...</option>
                            <option value="F">Femenino</option>
                            <option value="M">Masculino</option>
                            <option value="NB">No binario</option>
                            <option value="T">Transgénero</option>
                        </select>
                        <span class="field-error" id="err-edit-genero"></span>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Ciudad <span class="required">*</span></label>
                        <select id="edit-cliente-ciudad" name="sel_edit_ciudad" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($ciudades_lista as $c): ?>
                                <option value="<?= htmlspecialchars($c['id_ciudad']) ?>"><?= htmlspecialchars($c['nom_ciudad']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-edit-ciudad"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Restricción <span class="required">*</span></label>
                        <select id="edit-cliente-restriccion" name="sel_edit_restriccion" class="form-select">
                            <option value="">Seleccione...</option>
                            <?php foreach ($restricciones as $r): ?>
                                <option value="<?= htmlspecialchars($r['id_restriccion']) ?>"><?= htmlspecialchars($r['nom_restriccion']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <span class="field-error" id="err-edit-restriccion"></span>
                    </div>
                </div>

                <!-- ===== FIDELIDAD Y CRÉDITO ===== -->
                <div class="modal-section-title"><i class="fas fa-credit-card"></i> Fidelidad y Crédito</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Puntos</label>
                        <input type="number" id="edit-cliente-puntos" name="txt_edit_puntos" class="form-input" min="0">
                        <span class="field-error" id="err-edit-puntos"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Estado</label>
                        <select id="edit-cliente-estado" name="sel_edit_estado" class="form-select">
                            <option value="true">Activo</option>
                            <option value="false">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">¿Tiene crédito?</label>
                        <div id="edit-credito-switch" class="switch-toggle">
                            <span id="edit-credito-label">No</span>
                        </div>
                        <input type="hidden" id="edit-credito-hidden" name="sel_edit_credito" value="false">
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <label class="form-label">Cupo de Crédito</label>
                        <input type="number" id="edit-cliente-cupo" name="txt_edit_cupo" class="form-input" min="0" disabled>
                        <span class="field-error" id="err-edit-cupo"></span>
                    </div>
                    <div class="form-field">
                        <label class="form-label">Días de Cartera</label>
                        <input type="number" id="edit-cliente-diascartera" name="txt_edit_dias_cartera" class="form-input" min="0" max="120" disabled>
                        <span class="field-error" id="err-edit-diascartera"></span>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-cancel-edit-modal">Cancelar</button>
                    <button type="submit" class="btn btn-success" id="btn-edit-submit">
                        <i class="fas fa-save"></i> Guardar Cambios
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ============================================================
     DATOS PARA EL JS (variables globales)
     ============================================================ -->
<script>
const clientesData = <?= json_encode($clientes, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>;
</script>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>





* ============================================
   CLIENTES - ESTILOS UNIFICADOS (versión completa)
   ============================================ */

@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&display=swap');

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

#mod-clientes {
    --dash-bg: #ffffff;
    --dash-card: #ffffff;
    --dash-border: #e9edf2;
    --dash-border-light: #f1f4f9;
    --dash-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.03), 0 1px 2px rgba(0, 0, 0, 0.05);
    --dash-shadow-md: 0 4px 12px rgba(0, 0, 0, 0.06);
    --dash-text-head: #0a0c1a;
    --dash-text-body: #1e293b;
    --dash-text-sub: #475569;
    --dash-text-muted: #94a3b8;
    --dash-blue: #3b82f6;
    --dash-blue-light: #eff6ff;
    --dash-green: #10b981;
    --dash-green-dark: #059669;
    --dash-green-light: #ecfdf5;
    --dash-red: #ef4444;
    --dash-red-light: #fef2f2;
    --dash-amber: #f59e0b;
    --dash-amber-light: #fffbeb;
    --dash-purple: #8b5cf6;
    --dash-purple-light: #f5f3ff;
    --dash-teal: #14b8a6;
    --dash-teal-light: #f0fdfa;
    --dash-rose: #f43f5e;
    --dash-rose-light: #fff1f2;
    --dash-radius: 16px;
    --dash-radius-sm: 10px;
    --dash-font: 'DM Sans', system-ui, sans-serif;

    font-family: var(--dash-font);
    background: var(--dash-bg);
    min-height: 100vh;
    padding: 0;
}

/* ---- ENCABEZADO ---- */
#mod-clientes .module-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 28px;
    flex-wrap: wrap;
    gap: 16px;
}

#mod-clientes .module-header-text h1 {
    font-size: 32px;
    font-weight: 700;
    color: var(--dash-text-head);
    letter-spacing: -0.4px;
    margin: 0 0 6px;
}

#mod-clientes .module-header-text p {
    font-size: 14px;
    font-weight: 400;
    color: var(--dash-text-sub);
    margin: 0;
}

/* ---- BOTONES PRINCIPALES ---- */
#mod-clientes .btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 22px;
    border-radius: 30px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
    font-family: var(--dash-font);
    border: none;
    text-transform: none;
    letter-spacing: 0;
    min-width: auto;
}

#mod-clientes .btn-primary {
    background: var(--dash-blue);
    color: white;
}

#mod-clientes .btn-primary:hover {
    background: #2563eb;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(59, 130, 246, 0.2);
}

#mod-clientes .btn-success {
    background: #2d8653;
    color: white;
}

#mod-clientes .btn-success:hover {
    background: #1e5c3a;
}

#mod-clientes .btn-secondary {
    background: #f1f5f9;
    color: #475569;
    border: 1.5px solid #c4c9d4;
}

#mod-clientes .btn-secondary:hover {
    background: #e2e8f0;
}

#mod-clientes .btn-danger {
    background: var(--dash-red);
    color: white;
}

#mod-clientes .btn-danger:hover {
    background: #dc2626;
}

/* ---- STATS ---- */
#mod-clientes .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 28px;
}

#mod-clientes .stat-card {
    background: var(--dash-card);
    border: 1px solid var(--dash-border);
    border-radius: var(--dash-radius);
    padding: 20px 24px;
    display: flex;
    align-items: center;
    gap: 16px;
    transition: all 0.2s;
    box-shadow: var(--dash-shadow-sm);
}

#mod-clientes .stat-card:hover {
    box-shadow: var(--dash-shadow-md);
    transform: translateY(-2px);
}

#mod-clientes .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--dash-radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    flex-shrink: 0;
}

#mod-clientes .stat-icon.blue { background: var(--dash-blue-light); color: var(--dash-blue); }
#mod-clientes .stat-icon.green { background: var(--dash-green-light); color: var(--dash-green-dark); }
#mod-clientes .stat-icon.purple { background: var(--dash-purple-light); color: var(--dash-purple); }
#mod-clientes .stat-icon.amber { background: var(--dash-amber-light); color: var(--dash-amber); }
#mod-clientes .stat-icon.red { background: var(--dash-red-light); color: var(--dash-red); }
#mod-clientes .stat-icon.teal { background: var(--dash-teal-light); color: var(--dash-teal); }

#mod-clientes .stat-info {
    display: flex;
    flex-direction: column;
}

#mod-clientes .stat-label {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    color: var(--dash-text-muted);
    margin-bottom: 4px;
}

#mod-clientes .stat-value {
    font-size: 28px;
    font-weight: 800;
    color: var(--dash-text-head);
    line-height: 1;
}

/* ---- FILTROS ---- */
#mod-clientes .filter-bar {
    background: var(--dash-card);
    border: 1px solid var(--dash-border);
    border-radius: var(--dash-radius-sm);
    padding: 8px 16px;
    margin-bottom: 28px;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 12px;
}

#mod-clientes .search-wrapper {
    position: relative;
    flex: 2;
    min-width: 220px;
}

#mod-clientes .search-icon {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--dash-text-muted);
    font-size: 13px;
}

#mod-clientes .search-input {
    width: 100%;
    padding: 10px 12px 10px 36px;
    border: 1px solid var(--dash-border);
    border-radius: 30px;
    font-family: var(--dash-font);
    font-size: 13px;
    outline: none;
    background: var(--dash-bg);
    color: var(--dash-text-body);
    transition: all 0.2s;
}

#mod-clientes .search-input:focus {
    border-color: var(--dash-blue);
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

#mod-clientes .filter-toggle-group {
    display: flex;
    gap: 6px;
}

#mod-clientes .filter-toggle {
    padding: 6px 14px;
    border-radius: 30px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    background: #f8fafc;
    border: 1px solid var(--dash-border);
    cursor: pointer;
    transition: all 0.2s;
    font-family: var(--dash-font);
    color: var(--dash-text-sub);
}

#mod-clientes .filter-toggle.active {
    background: var(--dash-blue);
    border-color: var(--dash-blue);
    color: white;
}

#mod-clientes .btn-clear-filter {
    background: none;
    border: none;
    font-size: 11px;
    font-weight: 600;
    color: var(--dash-rose);
    cursor: pointer;
    padding: 6px 12px;
    border-radius: 30px;
    display: flex;
    align-items: center;
    gap: 6px;
    font-family: var(--dash-font);
}

#mod-clientes .btn-clear-filter:hover {
    background: var(--dash-rose-light);
}

#mod-clientes .filter-info {
    font-size: 11px;
    font-weight: 500;
    color: var(--dash-text-muted);
    margin-left: auto;
}

/* ---- TABLA ---- */
#mod-clientes .table-container {
    background: var(--dash-card);
    border: 1px solid var(--dash-border);
    border-radius: var(--dash-radius);
    overflow-x: auto;
}

#mod-clientes .data-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}

#mod-clientes .data-table th {
    text-align: left;
    padding: 14px 16px;
    background: #f9fafb;
    font-weight: 700;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--dash-text-sub);
    border-bottom: 1px solid var(--dash-border);
}

#mod-clientes .data-table td {
    padding: 12px 16px;
    border-bottom: 1px solid var(--dash-border);
    color: var(--dash-text-body);
    vertical-align: middle;
}

#mod-clientes .data-table tr:last-child td {
    border-bottom: none;
}

#mod-clientes .data-table tbody tr:hover td {
    background: #fafcff;
    cursor: pointer;
}

#mod-clientes .text-center {
    text-align: center;
}
#mod-clientes .text-right {
    text-align: right;
}

/* ---- BADGES ---- */
#mod-clientes .badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 40px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
}

#mod-clientes .badge-active {
    background: var(--dash-green-light);
    color: var(--dash-green-dark);
}

#mod-clientes .badge-inactive {
    background: var(--dash-red-light);
    color: var(--dash-red);
}

#mod-clientes .badge-success {
    background: var(--dash-green-light);
    color: var(--dash-green-dark);
}

#mod-clientes .badge-neutral {
    background: #e2e8f0;
    color: #475569;
}

#mod-clientes .badge::before {
    content: '';
    width: 6px;
    height: 6px;
    border-radius: 50%;
}

#mod-clientes .badge-active::before {
    background: var(--dash-green-dark);
}

#mod-clientes .badge-inactive::before {
    background: var(--dash-red);
}

/* ---- BOTONES DE ACCIÓN (íconos) ---- */
#mod-clientes .btn-icon-sm {
    background: transparent;
    border: none;
    padding: 5px 10px;
    border-radius: 30px;
    font-size: 11px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-family: var(--dash-font);
}

#mod-clientes .btn-icon-sm.view {
    background: var(--dash-blue-light);
    color: var(--dash-blue);
}

#mod-clientes .btn-icon-sm.edit {
    background: var(--dash-amber-light);
    color: var(--dash-amber);
}

#mod-clientes .btn-icon-sm.reject {
    background: var(--dash-rose-light);
    color: var(--dash-rose);
}

#mod-clientes .btn-icon-sm:hover {
    transform: translateY(-1px);
    filter: brightness(0.95);
}

/* ---- EMPTY STATE ---- */
#mod-clientes .empty-row td {
    text-align: center;
    padding: 48px !important;
}

#mod-clientes .empty-state {
    text-align: center;
    background: transparent;
    border: none;
}

#mod-clientes .empty-state i {
    font-size: 48px;
    color: var(--dash-text-muted);
    opacity: 0.4;
    margin-bottom: 16px;
    display: block;
}

#mod-clientes .empty-state p {
    font-weight: 600;
    color: var(--dash-text-sub);
    margin-bottom: 4px;
}

#mod-clientes .empty-state span {
    font-size: 12px;
    color: var(--dash-text-muted);
}

/* ============================================
   MEJORAS PARA EL MODAL DE NUEVO CLIENTE
   ============================================ */

#modal-new-cliente .modal-box {
    max-width: 780px;
}

#modal-new-cliente .modal-body {
    padding: 20px 24px 16px;
    overflow-y: auto;
    max-height: calc(90vh - 130px);
}

.modal-section-title {
    font-size: 13px;
    font-weight: 700;
    color: #1e293b;
    margin: 20px 0 12px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid #e9edf2;
    display: flex;
    align-items: center;
    gap: 8px;
}

.modal-section-title i {
    color: #2d8653;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 8px;
}

.form-field {
    display: flex;
    flex-direction: column;
    margin-bottom: 12px;
}

.form-label {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    color: #64748b;
    margin-bottom: 4px;
    letter-spacing: 0.5px;
}

.form-input,
.form-select {
    height: 40px;
    padding: 8px 14px;
    border: 1.5px solid #b2d8c4;
    border-radius: 30px;
    font-family: 'DM Sans', system-ui, sans-serif;
    font-size: 13px;
    background: #ffffff;
    color: #1e293b;
    transition: all 0.2s;
    width: 100%;
    appearance: none;
    -webkit-appearance: none;
}

.form-input:focus,
.form-select:focus {
    border-color: #2d8653;
    box-shadow: 0 0 0 3px rgba(45, 134, 83, 0.12);
    outline: none;
    background: #f8fafc;
}

.form-input:hover,
.form-select:hover {
    background: #f1f5f9;
}

.form-input::placeholder {
    color: #b0b8c9;
}

.form-select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%2394a3b8' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 14px center;
    padding-right: 36px;
}

.input-prefix-group {
    display: flex;
    gap: 8px;
    align-items: center;
}

.input-prefix-group .prefix-select {
    flex: 0 0 100px;
    min-width: 80px;
}

.input-prefix-group .form-input {
    flex: 1;
}



.field-error {
    font-size: 11px;
    color: #ef4444;
    margin-top: 4px;
    min-height: 16px;
}

.field-error:empty {
    min-height: 0;
}

#btn-new-submit {
    background: #2d8653;
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 30px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

#btn-new-submit:hover {
    background: #1e5c3a;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(45, 134, 83, 0.2);
}

@media (max-width: 768px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
    #modal-new-cliente .modal-body {
        padding: 16px;
    }
    .input-prefix-group {
        flex-direction: column;
        gap: 6px;
    }
    .input-prefix-group .prefix-select {
        flex: 1;
        width: 100%;
        min-width: unset;
    }
}

/* ---- FORMULARIOS ---- */
#mod-clientes .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 16px;
}

#mod-clientes .form-field {
    display: flex;
    flex-direction: column;
    margin-bottom: 16px;
}

#mod-clientes .form-label {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    color: #64748b;
    margin-bottom: 6px;
    letter-spacing: 0.5px;
}

#mod-clientes .form-select,
#mod-clientes .form-input {
    width: 100%;
    padding: 11px 16px;
    height: 44px;
    border: 1.5px solid #b2d8c4;
    border-radius: 50px;
    font-family: var(--dash-font);
    font-size: 13px;
    outline: none;
    background: #ffffff;
    color: #1e293b;
    transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    appearance: none;
}

#mod-clientes .form-select:hover,
#mod-clientes .form-input:hover {
    background: #edf7f2;
    border-color: #7ecba4;
}

#mod-clientes .form-select:focus,
#mod-clientes .form-input:focus {
    background: #edf7f2;
    border-color: #2d8653;
    box-shadow: 0 0 0 3px rgba(45, 134, 83, 0.12);
}

#mod-clientes .form-select::placeholder,
#mod-clientes .form-input::placeholder {
    color: #b0b8c9;
}

#mod-clientes .form-select:disabled,
#mod-clientes .form-input:disabled {
    background: #f8fafc;
    border-color: #e2e8f0;
    color: #94a3b8;
    cursor: not-allowed;
}

#mod-clientes .required {
    color: #ef4444;
    margin-left: 2px;
}

#mod-clientes .field-error {
    font-size: 11px;
    color: #ef4444;
    margin-top: 4px;
    display: block;
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.2s;
}

#mod-clientes .field-error.visible {
    max-height: 3rem;
}

/* ---- TOGGLE SWITCH ---- */
#mod-clientes .toggle-switch {
    width: 52px;
    height: 28px;
    border-radius: 30px;
    background: #cbd5e1;
    border: 2px solid #94a3b8;
    position: relative;
    cursor: pointer;
    transition: all 0.25s;
    flex-shrink: 0;
    display: inline-block;
}

#mod-clientes .toggle-switch.on {
    background: #2d8653;
    border-color: #236b42;
}

#mod-clientes .toggle-thumb {
    position: absolute;
    top: 2px;
    left: 2px;
    width: 20px;
    height: 20px;
    background: white;
    border-radius: 50%;
    transition: all 0.25s;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.3);
}

#mod-clientes .toggle-switch.on .toggle-thumb {
    left: calc(100% - 22px);
}

/* ---- DETALLE (grid de información) ---- */
#mod-clientes .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}

#mod-clientes .detail-item {
    background: #f9fafb;
    border: 1px solid #e9edf2;
    border-radius: 12px;
    padding: 10px 14px;
}

#mod-clientes .detail-item .label {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    color: #94a3b8;
    letter-spacing: 0.5px;
}

#mod-clientes .detail-item .value {
    font-size: 13px;
    font-weight: 600;
    color: #1e293b;
    word-break: break-word;
}

/* ---- TOAST ---- */
#mod-clientes #toast {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #0f172a;
    color: white;
    padding: 12px 20px;
    border-radius: 40px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    font-weight: 500;
    z-index: 1100;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    animation: slideIn 0.3s ease;
}

#mod-clientes #toast.hidden {
    display: none;
}
.hidden {
    display: none;
}
/* ---- ANIMACIONES ---- */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: scale(0.96);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateX(20px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

/* ---- RESPONSIVE ---- */
@media (max-width: 900px) {
    #mod-clientes {
        padding: 20px;
    }
    #mod-clientes .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    #mod-clientes .filter-bar {
        flex-direction: column;
        align-items: stretch;
    }
    #mod-clientes .filter-info {
        margin-left: 0;
        text-align: center;
    }
    #mod-clientes .form-grid {
        grid-template-columns: 1fr;
    }
    #mod-clientes .detail-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 768px) {
    #mod-clientes .stats-grid {
        grid-template-columns: 1fr;
    }
    #mod-clientes .modal-box {
        width: 95vw;
        max-width: 95vw;
    }
}

/* ============================================
   ESTILOS PARA EL MODAL - ESTILO PROVEEDOR
   ============================================ */

/* --- Header verde --- */


.modal-header {
    padding: 18px 24px;
    display: flex; justify-content: space-between; align-items: center;
    flex-shrink: 0;
}

.modal-header.green { background: #2d8653; color: white; }
.modal-header.blue  { background: #3b82f6; color: white; }

.modal-header h2 {
    font-size: 18px; font-weight: 700; margin: 0;
    font-family: 'DM Sans', system-ui, sans-serif;
}

.modal-header p {
    font-size: 12px; opacity: 0.85; margin-top: 4px;
    font-family: 'DM Sans', system-ui, sans-serif;
}

.modal-close {
    background: rgba(255,255,255,0.2); border: none;
    width: 32px; height: 32px; border-radius: 50%;
    font-size: 16px; cursor: pointer; color: white;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0; transition: background 0.2s;
}

.modal-close:hover { background: rgba(255,255,255,0.35); }


/* --- Títulos de sección con ícono verde --- */
.modal-section-title i {
    color: #2d8653;
}

/* --- Botón guardar (ya es verde, pero reforzamos) --- */
#btn-new-submit {
    background: #2d8653;
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 30px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

#btn-new-submit:hover {
    background: #1e5c3a;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(45, 134, 83, 0.2);
}

/* --- Overlay con opacidad y blur --- */
.modal-overlay {
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.55);  /* más opaco */
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 1rem;
}

.modal-overlay.hidden {
    display: none;
}

/* --- Caja del modal con sombra y borde redondeado --- */
.modal-box {
    background: white;
    width: 100%;
    max-width: 780px;
    max-height: 90vh;
    border-radius: 24px;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    animation: fadeIn 0.2s ease;
}

/* --- Ajuste del scroll interno --- */
#modal-new-cliente .modal-body {
    padding: 20px 24px 16px;
    overflow-y: auto;
    max-height: calc(90vh - 130px);
}
/*BOTONES*/
#modal-new-cliente .btn-icon-sm {
    background: transparent; border: none;
    padding: 5px 10px; border-radius: 30px;
    font-size: 11px; font-weight: 600;
    cursor: pointer; transition: all 0.2s;
    display: inline-flex; align-items: center; gap: 5px;
    font-family: var(--dash-font);
}

#modal-new-cliente .btn-icon-sm.view   { background: var(--dash-blue-light);  color: var(--dash-blue); }
#modal-new-cliente .btn-icon-sm.edit   { background: var(--dash-amber-light); color: var(--dash-amber); }
#modal-new-cliente .btn-icon-sm.reject { background: var(--dash-rose-light);  color: var(--dash-rose); }
#modal-new-cliente .btn-icon-sm:hover  { transform: translateY(-1px); filter: brightness(0.95); }

#modal-new-cliente .btn,
.modal-footer .btn {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 10px 22px; border-radius: 30px;
    font-size: 13px; font-weight: 700;
    cursor: pointer; transition: all 0.2s;
    font-family: 'DM Sans', system-ui, sans-serif;
    border: none; text-transform: none; letter-spacing: 0;
    min-width: auto;
    margin: 12px 12px;
}

#modal-new-cliente .btn-primary:hover,
.modal-footer .btn-primary:hover { background: #2563eb; }

#modal-new-cliente .btn-success,
.modal-footer .btn-success {
    background: #2d8653; color: white;
}

#modal-new-cliente .btn-success:hover,
.modal-footer .btn-success:hover { background: #1e5c3a; }

#modal-new-cliente .btn-secondary,
.modal-footer .btn-secondary {
    background: #f1f5f9; color: #475569;
    border: 1.5px solid #c4c9d4 !important;
}

#modal-new-cliente .btn-secondary:hover,
.modal-footer .btn-secondary:hover { background: #e2e8f0; }


'use strict';

// ============================================================
// 1. ESTADO GLOBAL
// ============================================================
let currentDetailId = null;
let pendingDeleteId = null;

// ============================================================
// 2. FUNCIONES DE UTILIDAD
// ============================================================
function val(id)           { return document.getElementById(id)?.value ?? ''; }
function setVal(id, value) { const el = document.getElementById(id); if (el) el.value = value ?? ''; }
function setText(id, text) { const el = document.getElementById(id); if (el) el.textContent = text ?? ''; }
function show(id)          { document.getElementById(id)?.classList.remove('hidden'); }
function hide(id)          { document.getElementById(id)?.classList.add('hidden'); }
function setSelectVal(id, value) {
    const el = document.getElementById(id);
    if (el) el.value = value ?? '';
}

function showFieldError(spanId, mensaje, autoHideMs = 4000) {
    const el = document.getElementById(spanId);
    if (!el) return;
    el.textContent = mensaje;
    el.classList.add('visible');
    clearTimeout(el._hideTimer);
    el._hideTimer = setTimeout(() => {
        el.classList.remove('visible');
        setTimeout(() => { el.textContent = ''; }, 300);
    }, autoHideMs);
}

function clearFieldError(spanId) {
    const el = document.getElementById(spanId);
    if (!el) return;
    clearTimeout(el._hideTimer);
    el.classList.remove('visible');
    el.textContent = '';
}

function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    const span  = document.getElementById('toast-message');
    if (!toast || !span) return;
    const text = message && message.trim() ? message : (type === 'success' ? 'Operación exitosa' : 'Ocurrió un error');
    span.textContent = text;
    toast.style.background = type === 'error' ? '#ef4444' : '#0f172a';
    toast.classList.remove('hidden');
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => toast.classList.add('hidden'), 3500);
}

function formatCurrency(n) { return Number(n).toLocaleString('es-CO'); }

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
}

function sanitizeText(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/[\x00]/g,    '')
        .replace(/'/g,         '')
        .replace(/"/g,         '')
        .replace(/;/g,         '')
        .replace(/--/g,        '')
        .replace(/\/\*/g,      '')
        .replace(/\*\//g,      '')
        .replace(/xp_/gi,      '')
        .replace(/DROP\s/gi,   '')
        .replace(/DELETE\s/gi, '')
        .replace(/INSERT\s/gi, '')
        .replace(/UPDATE\s/gi, '')
        .replace(/EXEC\s/gi,   '')
        .replace(/UNION\s/gi,  '')
        .replace(/SELECT\s/gi, '')
        .replace(/</g,  '&lt;')
        .replace(/>/g,  '&gt;')
        .trim();
}

// ============================================================
// 3. ESTADÍSTICAS Y FILTROS (sin cambios)
// ============================================================
function updateStats(data) {
    const total     = data.length;
    const activos   = data.filter(c => c.estado === true).length;
    const inactivos = total - activos;
    const conCredito = data.filter(c => c.ind_credito === true).length;
    const cupoTotal = data.reduce((s, c) => s + (c.ind_credito ? c.val_cupocredito : 0), 0);
    setText('stat-total',   total);
    setText('stat-activos', activos);
    setText('stat-credito', conCredito);
    setText('stat-cupo',    '$' + cupoTotal.toLocaleString('es-CO'));
}

function applyFilters() {
    const query = sanitizeText(document.getElementById('cliente-search')?.value ?? '').toLowerCase();
    const activeToggle = document.querySelector('.filter-toggle.active')?.dataset.filter ?? 'all';
    const filas = document.querySelectorAll('#clientes-tbody tr:not(.empty-row)');
    let visible = 0;
    filas.forEach(fila => {
        const nombre = fila.cells[0]?.textContent.toLowerCase() ?? '';
        const doc    = fila.cells[1]?.textContent.toLowerCase() ?? '';
        const estado = fila.cells[6]?.textContent.trim().toLowerCase() ?? '';
        const pasaTexto = !query || nombre.includes(query) || doc.includes(query);
        const pasaEstado = activeToggle === 'all'
            || (activeToggle === 'active'   && estado.includes('activo') && !estado.includes('inactivo'))
            || (activeToggle === 'inactive' && estado.includes('inactivo'));
        const mostrar = pasaTexto && pasaEstado;
        fila.style.display = mostrar ? '' : 'none';
        if (mostrar) visible++;
    });
    setText('clientes-count', `${visible} resultado${visible !== 1 ? 's' : ''}`);
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = (query || activeToggle !== 'all') ? 'flex' : 'none';
}

function clearFilters() {
    const input = document.getElementById('cliente-search');
    if (input) input.value = '';
    document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
    document.querySelector('.filter-toggle[data-filter="all"]')?.classList.add('active');
    document.querySelectorAll('#clientes-tbody tr:not(.empty-row)')
        .forEach(fila => fila.style.display = '');
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = 'none';
    setText('clientes-count', `${clientesData.length} resultado${clientesData.length !== 1 ? 's' : ''}`);
}

// ============================================================
// 4. MODALES (con limpieza de errores al abrir)
// ============================================================
function openNewModal() {
    console.log('Abriendo modal nuevo cliente...');
    const form = document.getElementById('new-cliente-form');
    if (form) form.reset();

    // Limpiar errores y restaurar selects a su estado inicial
    document.querySelectorAll('#new-cliente-form .field-error').forEach(el => {
        el.textContent = '';
        el.classList.remove('visible');
    });

    // Restaurar selects a "Seleccione..."
    const selects = form.querySelectorAll('select');
    selects.forEach(select => {
        const firstOption = select.querySelector('option[value=""]') || select.querySelector('option:first-child');
        if (firstOption) select.value = firstOption.value;
    });

    show('modal-new-cliente');
    document.getElementById('new-cliente-id')?.focus();
}

function closeNewModal() {
    hide('modal-new-cliente');
}

function closeEditModal() {
    hide('modal-edit-cliente');
}

function openEditModal(id) {
    const c = clientesData.find(c => c.id_cliente === id);
    if (!c) {
        showToast('No se encontraron los datos del cliente', 'error');
        return;
    }

    // Limpiar errores
    document.querySelectorAll('#modal-edit-cliente .field-error')
        .forEach(el => clearFieldError(el.id));

    // IDs ocultos
    setVal('hid-edit-id-cliente', c.id_cliente);
    setVal('edit-tipo-doc-hidden', c.id_tipo ?? '');

    // Identificación (deshabilitados)
    setSelectVal('edit-id-tipo', c.id_tipo ?? '');
    setVal('edit-cliente-id', c.id_cliente);

    // Tipo de persona y categoría
    const tipoPersona = (c.ind_tipo_tercero === true || c.ind_tipo_tercero === 'true') ? 'true' : 'false';
    setSelectVal('edit-tipo-tercero', tipoPersona);
    setSelectVal('edit-cat-tercero', c.id_cat_tercero ?? '');

    // Nombre y sigla
    setVal('edit-cliente-nombre', c.nom_tercero ?? '');
    setVal('edit-cliente-sigla', c.val_sigla ?? '');

    // Contacto
    setSelectVal('edit-prefijo-movil', c.id_prefijo_movil ?? '');
    setVal('edit-cliente-tel-movil', c.tel_movil ?? '');
    setVal('edit-cliente-tel-fijo', c.tel_fijo ?? '');
    setVal('edit-cliente-email', c.email ?? '');
    setVal('edit-cliente-direccion', c.direccion ?? '');

    // Datos personales
    setVal('edit-cliente-fecnac', c.fec_nacimi ?? '');
    setSelectVal('edit-cliente-genero', c.ind_genero ?? 'F');
    setSelectVal('edit-cliente-ciudad', c.id_ciudad ?? '');
    setSelectVal('edit-cliente-restriccion', c.id_restriccion ?? '');

    // Fidelidad y crédito
    setVal('edit-cliente-puntos', c.val_puntos ?? 0);
    setSelectVal('edit-cliente-estado', c.estado ? 'true' : 'false');

    const credito = c.ind_credito === true;
    setToggle('edit-credito-switch', 'edit-credito-hidden', credito);

    const cupoInput = document.getElementById('edit-cliente-cupo');
    const diasInput = document.getElementById('edit-cliente-diascartera');
    if (cupoInput) {
        cupoInput.disabled = !credito;
        cupoInput.value = credito ? (c.val_cupocredito ?? 0) : 0;
    }
    if (diasInput) {
        diasInput.disabled = !credito;
        diasInput.value = credito ? (c.val_diascartera ?? 0) : 0;
    }

    show('modal-edit-cliente');
}

function setToggle(switchId, hiddenId, isOn) {
    const sw = document.getElementById(switchId);
    const hidden = document.getElementById(hiddenId);
    const label = document.getElementById(switchId.replace('-switch', '-label'));
    if (sw) sw.classList.toggle('on', isOn);
    if (hidden) hidden.value = isOn ? 'true' : 'false';
    if (label) label.textContent = isOn ? 'Sí' : 'No';
}

function openDetailModal(id) {
    const c = clientesData.find(c => c.id_cliente === id);
    if (!c) return;
    currentDetailId = id;
    setText('detail-title', c.nom_tercero ?? 'Detalle Cliente');
    const badge = c.estado
        ? '<span class="badge badge-active">Activo</span>'
        : '<span class="badge badge-inactive">Inactivo</span>';
    const creditoBadge = c.ind_credito
        ? '<span class="badge badge-success">APROBADO</span>'
        : '<span class="badge badge-neutral">SIN CRÉDITO</span>';
    const container = document.getElementById('detail-content');
    if (!container) return;
    container.innerHTML = `
        <div class="detail-grid">
            <div class="detail-item"><div class="label">Documento</div><div class="value">${escapeHtml(c.id_tipo)} ${escapeHtml(c.id_cliente)}</div></div>
            <div class="detail-item"><div class="label">Nombre</div><div class="value">${escapeHtml(c.nom_tercero ?? '—')}</div></div>
            <div class="detail-item"><div class="label">Género</div><div class="value">${escapeHtml(c.ind_genero)}</div></div>
            <div class="detail-item"><div class="label">Edad</div><div class="value">${c.val_edad} años</div></div>
            <div class="detail-item"><div class="label">Ciudad</div><div class="value">${escapeHtml(c.nom_ciudad ?? '—')}</div></div>
            <div class="detail-item"><div class="label">Estado</div><div class="value">${badge}</div></div>
            <div class="detail-item"><div class="label">Crédito</div><div class="value">${creditoBadge}</div></div>
            <div class="detail-item"><div class="label">Cupo</div><div class="value">${formatCurrency(c.val_cupocredito ?? 0)}</div></div>
            <div class="detail-item"><div class="label">Días Cartera</div><div class="value">${c.val_diascartera ?? 0}</div></div>
            <div class="detail-item"><div class="label">Puntos</div><div class="value">${Number(c.val_puntos ?? 0).toLocaleString('es-CO')}</div></div>
        </div>`;
    show('modal-detail');
}

function closeDetailModal() {
    hide('modal-detail');
    currentDetailId = null;
}

function editFromDetail() {
    const id = currentDetailId;
    closeDetailModal();
    if (id) openEditModal(id);
}

// ============================================================
// 5. ELIMINACIÓN (sin cambios)
// ============================================================
function eliminarCliente(id, nombre) {
    pendingDeleteId = id;
    document.getElementById('confirm-message').innerHTML = `¿Desea eliminar al cliente <strong>${escapeHtml(nombre)}</strong>?<br>Esta acción es reversible (borrado lógico).`;
    show('modal-confirm');
}

function closeConfirmModal() {
    hide('modal-confirm');
    pendingDeleteId = null;
}

function confirmDelete() {
    if (!pendingDeleteId) return;
    const formData = new FormData();
    formData.append('btn_eliminar', '1');
    formData.append('hid_del_id', pendingDeleteId);

    fetch(window.location.href, {
        method: 'POST',
        body: formData
    })
    .then(res => res.text())
    .then(text => {
        console.log('Respuesta eliminar:', text);
        let result;
        try { result = JSON.parse(text); } catch (e) { result = { success: false, message: 'Respuesta inválida' }; }
        if (result.success) {
            showToast(result.message, 'success');
            closeConfirmModal();
            location.reload();
        } else {
            showToast(result.message || 'Error al eliminar', 'error');
            closeConfirmModal();
        }
    })
    .catch(() => {
        showToast('Error de conexión', 'error');
        closeConfirmModal();
    });
}

// ============================================================
// 6. CÁLCULO DE EDAD
// ============================================================
function calcularEdad(fechaNacimiento) {
    if (!fechaNacimiento) return null;
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const diferenciaMes = hoy.getMonth() - nacimiento.getMonth();
    if (diferenciaMes < 0 || (diferenciaMes === 0 && hoy.getDate() < nacimiento.getDate())) {
        edad--;
    }
    return edad;
}

// ============================================================
// 7. VALIDACIONES EN TIEMPO REAL
// ============================================================

// Función auxiliar para validar selects con mensaje personalizado
function validarSelect(selectId, errorId, mensajeError) {
    const select = document.getElementById(selectId);
    const errorSpan = document.getElementById(errorId);
    if (!select || !errorSpan) return true;
    const val = select.value;
    if (!val || val === '') {
        errorSpan.textContent = mensajeError;
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarTipoDocumento() {
    return validarSelect('new-id-tipo', 'err-new-id-tipo', 'Seleccione el tipo de documento.');
}

function validarTipoPersona() {
    return validarSelect('new-tipo-tercero', 'err-new-tipo-tercero', 'Seleccione el tipo de persona.');
}

function validarCategoria() {
    const select = document.getElementById('new-cat-tercero');
    const errorSpan = document.getElementById('err-new-cat-tercero');
    if (!select || !errorSpan) return true;
    const val = parseInt(select.value);
    if (isNaN(val) || val < 1 || val > 99) {
        errorSpan.textContent = 'Seleccione una categoría válida.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarGenero() {
    const select = document.getElementById('new-cliente-genero');
    const errorSpan = document.getElementById('err-new-genero');
    if (!select || !errorSpan) return true;
    const val = select.value;
    if (!val || !['F','M','NB','T'].includes(val)) {
        errorSpan.textContent = 'Seleccione un género válido.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarCiudad() {
    return validarSelect('new-cliente-ciudad', 'err-new-ciudad', 'Seleccione una ciudad.');
}

function validarRestriccion() {
    const select = document.getElementById('new-cliente-restriccion');
    const errorSpan = document.getElementById('err-new-restriccion');
    if (!select || !errorSpan) return true;
    const val = parseInt(select.value);
    if (isNaN(val) || val < 1 || val > 99) {
        errorSpan.textContent = 'Seleccione una restricción válida.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

// Validaciones para campos de texto y email
function validarIdentificacion() {
    const input = document.getElementById('new-cliente-id');
    const errorSpan = document.getElementById('err-new-id');
    if (!input || !errorSpan) return true;
    const val = input.value.trim().toUpperCase();
    if (!val) {
        errorSpan.textContent = 'El NIT / identificación es obligatorio.';
        errorSpan.classList.add('visible');
        return false;
    }
    const tipoSelect = document.getElementById('new-id-tipo');
    const tipo = tipoSelect ? tipoSelect.value : '';
    const soloNumeros = ['CC', 'TI', 'RC', 'NIT', 'NUIP'];
    if (soloNumeros.includes(tipo)) {
        if (!/^[0-9]{7,10}$/.test(val)) {
            errorSpan.textContent = 'Para ' + tipo + ' el ID debe tener entre 7 y 10 dígitos numéricos.';
            errorSpan.classList.add('visible');
            return false;
        }
    } else {
        if (!/^[A-Z0-9]{7,10}$/.test(val)) {
            errorSpan.textContent = 'El ID debe tener entre 7 y 10 caracteres alfanuméricos en mayúsculas.';
            errorSpan.classList.add('visible');
            return false;
        }
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarNombre() {
    const input = document.getElementById('new-cliente-nombre');
    const errorSpan = document.getElementById('err-new-razon');
    if (!input || !errorSpan) return true;
    const val = input.value.trim();
    if (val.length < 4 || val.length > 50) {
        errorSpan.textContent = 'El nombre debe tener entre 4 y 50 caracteres.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarSigla() {
    const input = document.getElementById('new-cliente-sigla');
    const errorSpan = document.getElementById('err-new-sigla');
    if (!input || !errorSpan) return true;
    const val = input.value.trim().toUpperCase();
    if (val && (val.length < 2 || val.length > 10)) {
        errorSpan.textContent = 'La sigla debe tener entre 2 y 10 caracteres (opcional).';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarEmail() {
    const input = document.getElementById('new-cliente-email');
    const errorSpan = document.getElementById('err-new-email');
    if (!input || !errorSpan) return true;
    const val = input.value.trim().toLowerCase();
    if (!val || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)) {
        errorSpan.textContent = 'Ingrese un email válido.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

function validarDireccion() {
    const input = document.getElementById('new-cliente-direccion');
    const errorSpan = document.getElementById('err-new-direccion');
    if (!input || !errorSpan) return true;
    const val = input.value.trim();
    if (!val) {
        errorSpan.textContent = 'La dirección es obligatoria.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

// ============================================================
// VALIDACIONES PARA TELÉFONO FIJO Y CELULAR (CORREGIDAS)
// ============================================================

function validarTelFijo() {
    const input = document.getElementById('new-cliente-tel-fijo');
    const errorSpan = document.getElementById('err-new-tel-fijo');
    if (!input || !errorSpan) return true;

    const val = input.value.trim();
    if (val === '') {
        errorSpan.textContent = '';
        errorSpan.classList.remove('visible');
        input.style.borderColor = '#b2d8c4';
        return true;
    }
    if (!/^[0-9]{7,10}$/.test(val)) {
        errorSpan.textContent = 'El teléfono fijo debe tener entre 7 y 10 dígitos.';
        errorSpan.classList.add('visible');
        input.style.borderColor = '#ef4444';
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    input.style.borderColor = '#b2d8c4';
    return true;
}

function validarCelular() {
    const prefijo = document.getElementById('new-prefijo-movil');
    const numero = document.getElementById('new-cliente-tel-movil');
    const errorSpan = document.getElementById('err-new-tel-movil');
    if (!prefijo || !numero || !errorSpan) return true;

    const prefVal = prefijo.value;
    const numVal = numero.value.trim();

    if (prefVal === '' && numVal === '') {
        errorSpan.textContent = '';
        errorSpan.classList.remove('visible');
        numero.style.borderColor = '#b2d8c4';
        prefijo.style.borderColor = '#b2d8c4';
        return true;
    }
    if (prefVal === '' || numVal === '') {
        errorSpan.textContent = 'Debe seleccionar el prefijo y escribir el número de celular.';
        errorSpan.classList.add('visible');
        numero.style.borderColor = '#ef4444';
        prefijo.style.borderColor = '#ef4444';
        return false;
    }
    if (!/^[0-9]+$/.test(numVal)) {
        errorSpan.textContent = 'El número de celular solo debe contener dígitos.';
        errorSpan.classList.add('visible');
        numero.style.borderColor = '#ef4444';
        prefijo.style.borderColor = '#ef4444';
        return false;
    }
    if (numVal.length < 7 || numVal.length > 15) {
        errorSpan.textContent = 'El número de celular debe tener entre 7 y 15 dígitos.';
        errorSpan.classList.add('visible');
        numero.style.borderColor = '#ef4444';
        prefijo.style.borderColor = '#ef4444';
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    numero.style.borderColor = '#b2d8c4';
    prefijo.style.borderColor = '#b2d8c4';
    return true;
}
function validarFechaNacimiento() {
    const input = document.getElementById('new-cliente-fecnac');
    const errorSpan = document.getElementById('err-new-fecnac');
    if (!input || !errorSpan) return true;
    const val = input.value;
    if (!val) {
        errorSpan.textContent = 'La fecha de nacimiento es obligatoria.';
        errorSpan.classList.add('visible');
        return false;
    }
    const edad = calcularEdad(val);
    if (edad < 16) {
        errorSpan.textContent = 'El cliente debe tener al menos 16 años.';
        errorSpan.classList.add('visible');
        return false;
    }
    errorSpan.textContent = '';
    errorSpan.classList.remove('visible');
    return true;
}

// ============================================================
// 8. VALIDACIÓN COMPLETA DEL FORMULARIO
// ============================================================
function validarFormularioCliente() {
    const validaciones = [
        validarTipoDocumento(),
        validarIdentificacion(),
        validarTipoPersona(),
        validarCategoria(),
        validarNombre(),
        validarSigla(),
        validarEmail(),
        validarDireccion(),
        validarTelFijo(),
        validarCelular(),
        validarFechaNacimiento(),
        validarGenero(),
        validarCiudad(),
        validarRestriccion()
    ];
    return validaciones.every(v => v === true);
}

// ============================================================
// 9. CONFIGURACIÓN DEL FORMULARIO NUEVO CLIENTE
// ============================================================
function setupNewClienteForm() {
    const form = document.getElementById('new-cliente-form');
    const btn = document.getElementById('btn-new-submit');
    if (!form || !btn) return;

    // ---- Asignación de eventos de validación en tiempo real ----

    // Selects
    document.getElementById('new-id-tipo')?.addEventListener('change', function() {
        validarTipoDocumento();
        validarIdentificacion(); // Re-valida identificación al cambiar tipo
    });
    document.getElementById('new-tipo-tercero')?.addEventListener('change', validarTipoPersona);
    document.getElementById('new-cat-tercero')?.addEventListener('change', validarCategoria);
    document.getElementById('new-cliente-genero')?.addEventListener('change', validarGenero);
    document.getElementById('new-cliente-ciudad')?.addEventListener('change', validarCiudad);
    document.getElementById('new-cliente-restriccion')?.addEventListener('change', validarRestriccion);
    document.getElementById('new-prefijo-movil')?.addEventListener('change', validarCelular);

    // Inputs de texto
      document.getElementById('new-cliente-id')?.addEventListener('input', function() {
        // Limpia el error mientras escribe (mejora UX)
        const errorSpan = document.getElementById('err-new-id');
        if (errorSpan && errorSpan.classList.contains('visible')) {
            errorSpan.textContent = '';
            errorSpan.classList.remove('visible');
        }
    });
    document.getElementById('new-cliente-id')?.addEventListener('blur', validarIdentificacion);
    document.getElementById('new-cliente-nombre')?.addEventListener('blur', validarNombre);
    document.getElementById('new-cliente-sigla')?.addEventListener('blur', validarSigla);
    document.getElementById('new-cliente-email')?.addEventListener('blur', validarEmail);
    document.getElementById('new-cliente-direccion')?.addEventListener('blur', validarDireccion);
    document.getElementById('new-cliente-tel-fijo')?.addEventListener('blur', validarTelFijo);
    document.getElementById('new-cliente-tel-movil')?.addEventListener('blur', validarCelular);
    document.getElementById('new-cliente-fecnac')?.addEventListener('blur', validarFechaNacimiento);
    document.getElementById('new-cliente-fecnac')?.addEventListener('change', validarFechaNacimiento);

      let isSubmitting = false;
 
    // ---- Evento submit ----
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
 
        if (isSubmitting) return; // ya hay un envío en curso, se ignora
        isSubmitting = true;
 
        // Ejecutar todas las validaciones y mostrar errores
        if (!validarFormularioCliente()) {
            isSubmitting = false;
            // Enfocar el primer campo con error
            const firstError = document.querySelector('#new-cliente-form .field-error.visible');
            if (firstError) {
                const parentField = firstError.closest('.form-field');
                if (parentField) {
                    const input = parentField.querySelector('input, select');
                    if (input) input.focus();
                }
            }
            return;
        }
 
        // PREPARAR ENVÍO (si todas las validaciones pasan)
        const formData = new FormData(form);
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';
 
        try {
            const response = await fetch(window.location.href, {
                method: 'POST',
                body: formData
            });
            const text = await response.text();
            console.log('Respuesta servidor:', text);
            let result;
            try {
                result = JSON.parse(text);
            } catch {
                result = { success: false, message: 'Respuesta inválida del servidor.' };
            }
 


if (result.success) {
    showToast(result.message, 'success');
    closeNewModal();

    // Limpiar el tbody para evitar duplicados en la recarga
    const tbody = document.getElementById('clientes-tbody');
    if (tbody) tbody.innerHTML = '';

    // Forzar recarga sin caché
    window.location.href = window.location.href.split('?')[0] + '?t=' + Date.now();
    return;
}
 
            if (result.errors) {
                Object.entries(result.errors).forEach(([campo, mensaje]) => {
                    showFieldError(campo, mensaje);
                });
            } else {
                showToast(result.message || 'Error al guardar el cliente.', 'error');
            }
        } catch (error) {
            console.error(error);
            showToast('Error de conexión con el servidor.', 'error');
        } finally {
            isSubmitting = false;
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> Guardar Cliente';
        }
    });
}

// ============================================================
// 10. INICIALIZACIÓN
// ============================================================
document.addEventListener('DOMContentLoaded', function () {
    // Inicializar formulario Nuevo Cliente
    setupNewClienteForm();

    // --- Toggle Crédito (Editar) ---
    document.getElementById('edit-credito-switch')?.addEventListener('click', function() {
        const on = !this.classList.contains('on');
        setToggle('edit-credito-switch', 'edit-credito-hidden', on);
        document.getElementById('edit-cliente-cupo').disabled = !on;
        document.getElementById('edit-cliente-diascartera').disabled = !on;
        if (!on) {
            document.getElementById('edit-cliente-cupo').value = 0;
            document.getElementById('edit-cliente-diascartera').value = 0;
        }
    });

       // --- Envío del formulario de edición ---
    const editForm = document.getElementById('edit-cliente-form');
    if (editForm) {
        editForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            const btn = document.getElementById('btn-edit-submit');
            if (!btn) return;

            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';

            const formData = new FormData(editForm);

            try {
                const response = await fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                });
                const text = await response.text();
                let result;
                try {
                    result = JSON.parse(text);
                } catch {
                    result = { success: false, message: 'Respuesta inválida del servidor.' };
                }

                if (result.success) {
                    showToast(result.message, 'success');
                    closeEditModal();
                    // Recargar para ver cambios
                    window.location.href = window.location.href.split('?')[0] + '?t=' + Date.now();
                    return;
                }

                if (result.errors) {
                    Object.entries(result.errors).forEach(([campo, mensaje]) => {
                        showFieldError(campo, mensaje);
                    });
                } else {
                    showToast(result.message || 'Error al actualizar el cliente.', 'error');
                }
            } catch (error) {
                console.error(error);
                showToast('Error de conexión con el servidor.', 'error');
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> Guardar Cambios';
            }
        });
    }

    // --- Confirmar Eliminación ---
    document.getElementById('confirm-ok-btn')?.addEventListener('click', confirmDelete);

    // --- Cerrar modales ---
    document.querySelectorAll('.btn-close-new-modal, .btn-cancel-new-modal').forEach(b => b.addEventListener('click', closeNewModal));
    document.querySelectorAll('.btn-close-edit-modal, .btn-cancel-edit-modal').forEach(b => b.addEventListener('click', closeEditModal));
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                if (this.id === 'modal-new-cliente') closeNewModal();
                else if (this.id === 'modal-edit-cliente') closeEditModal();
                else if (this.id === 'modal-detail') closeDetailModal();
                else if (this.id === 'modal-confirm') closeConfirmModal();
            }
        });
    });

    // --- Filtros ---
    document.getElementById('cliente-search')?.addEventListener('input', applyFilters);
    document.querySelectorAll('.filter-toggle').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            applyFilters();
        });
    });
    document.getElementById('btn-clear-filters')?.addEventListener('click', clearFilters);

    // --- Botón Nuevo (CORREGIDO: fuera del forEach) ---
    document.getElementById('btn-add-cliente')?.addEventListener('click', openNewModal);

    // --- Inicializar estadísticas ---
    updateStats(clientesData);
    setText('clientes-count', `${clientesData.length} resultado${clientesData.length !== 1 ? 's' : ''}`);
});