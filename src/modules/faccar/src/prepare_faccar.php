<?php
/**
 * CENTRAL DE INSTRUCCIONES PREPARADAS - Módulo Facturación y Cartera (Maestros)
 * Versión: 3.0 — Incluye funciones de terceros y clientes
 * Mantiene todas las consultas previas (vendedores, parámetros, formas de pago, motivos de nota)
 */

require_once('config.php');

try {
    $pdo = getDBConnection();

    // =========================================================================
    // SELECTS MAESTROS (para combos y listas desplegables)
    // =========================================================================

    $list_tipos = $pdo->prepare(
        "SELECT id_tipo, nom_tipo
           FROM tab_tipo_identidad
          ORDER BY nom_tipo"
    );

    $list_ciudades = $pdo->prepare(
        "SELECT id_ciudad, nom_ciudad
           FROM tab_ciudades
          WHERE ind_borrado = FALSE
          ORDER BY nom_ciudad"
    );

    $list_areas = $pdo->prepare(
        "SELECT id_area, nom_area
           FROM tab_areas
          WHERE ind_estado = TRUE
            AND ind_borrado = FALSE
          ORDER BY nom_area"
    );

    $list_productos = $pdo->prepare(
        "SELECT id_producto, nom_producto, val_venta, val_poriva
           FROM tab_productos
          WHERE ind_estado = TRUE
            AND ind_borrado = FALSE
          ORDER BY nom_producto"
    );

    $list_clientes = $pdo->prepare(
        "SELECT c.id_cliente AS id,
                t.nom_tercero AS nombre
           FROM tab_clientes c
           JOIN tab_terceros t ON t.id_tercero = c.id_cliente
          WHERE c.ind_estado  = TRUE
            AND c.ind_borrado = FALSE
            AND t.ind_borrado = FALSE
          ORDER BY t.nom_tercero"
    );

    $list_vendedores = $pdo->prepare(
        "SELECT v.id_vendedor AS id,
                t.nom_tercero AS nombre
           FROM tab_vendedores v
           JOIN tab_empleados e ON e.id_empleado = v.id_vendedor
           JOIN tab_terceros   t ON t.id_tercero = e.id_empleado
          WHERE v.ind_estado  = TRUE
            AND v.ind_borrado = FALSE
            AND e.ind_estado  = TRUE
            AND t.ind_borrado = FALSE
          ORDER BY t.nom_tercero"
    );

    $list_formas_pago = $pdo->prepare(
        "SELECT id_formapago AS id,
                nom_formapago AS nombre
           FROM tab_forma_pagos
          WHERE ind_borrado = FALSE
          ORDER BY nom_formapago"
    );

    $list_motivos_nota = $pdo->prepare(
        "SELECT id_motivo_nota AS id,
                nom_motivo     AS nombre
           FROM tab_motivo_nota
          WHERE ind_estado  = TRUE
            AND ind_borrado = FALSE
          ORDER BY nom_motivo"
    );
      $list_empresas = $pdo->prepare(
        "SELECT id_empresa,
                nom_empresa
           FROM tab_pmtros_grales
          WHERE ind_borrado = FALSE
          ORDER BY nom_empresa"
    );

    // =========================================================================
    // NUEVOS SELECTS PARA TERCEROS (necesarios para clientes)
    // =========================================================================

    $list_categorias = $pdo->prepare(
        "SELECT id_cat_tercero, nom_cat_tercero
           FROM tab_cat_terceros
          ORDER BY nom_cat_tercero"
    );

    $list_restricciones = $pdo->prepare(
        "SELECT id_restriccion, nom_restriccion
           FROM tab_restricciones
          ORDER BY nom_restriccion"
    );

    $list_prefijos = $pdo->prepare(
        "SELECT id_prefijo AS id_prefijo_movil, nom_pais
           FROM tab_tel_prefijo
          ORDER BY nom_pais"
    );

    // =========================================================================
    // LISTADOS PRINCIPALES CON TODOS LOS CAMPOS
    // =========================================================================
    
    $list_clientes_completo = $pdo->prepare(
        "SELECT  t.id_tercero,
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
            AND c.id_cliente IS NOT NULL 
          ORDER BY t.nom_tercero"
    );

    $list_vendedores_completo = $pdo->prepare(
        "SELECT v.id_vendedor,
                t.nom_tercero,
                e.id_cargo,
                c.nom_cargo,
                v.val_porcomision,
                v.val_ven_acumu,
                v.ind_estado
           FROM tab_vendedores v
           JOIN tab_empleados e ON e.id_empleado = v.id_vendedor
           JOIN tab_terceros   t ON t.id_tercero  = e.id_empleado
           JOIN tab_cargos     c ON c.id_cargo    = e.id_cargo
          WHERE v.ind_borrado = FALSE
            AND e.ind_borrado = FALSE
            AND t.ind_borrado = FALSE
          ORDER BY t.nom_tercero"
    );

    $list_pmtros_facturacion = $pdo->prepare(
        "SELECT id_empresa,
                val_res_aut,
                fec_venc,
                fec_res_aut,
                val_prefijofac,
                val_facini,
                val_facactual,
                val_facfin,
                val_prefijocot,
                val_cotini,
                val_cotactual,
                val_porreteica,
                val_intcorriente,
                val_pesosXpuntos,
                val_interesmora,
                val_diascartera
           FROM tab_pmtros_facturacion
          WHERE ind_borrado = FALSE
          ORDER BY id_empresa"
    );

    $list_motivos_nota_completo = $pdo->prepare(
        "SELECT id_motivo_nota,
                ind_tipo_nota,
                cod_dian,
                nom_motivo,
                afecta_inventario,
                afecta_cliente,
                afecta_cartera,
                afecta_comision,
                ind_estado
           FROM tab_motivo_nota
          WHERE ind_borrado = FALSE
          ORDER BY id_motivo_nota"
    );

    $list_formas_pago_completo = $pdo->prepare(
        "SELECT id_formapago,
                nom_formapago,
                ind_borrado
           FROM tab_forma_pagos
          ORDER BY id_formapago"
    );

    // =========================================================================
    // FUNCIONES PARA TERCEROS (INSERT, UPDATE, DELETE)
    // =========================================================================

    $ins_tercero = $pdo->prepare(
        "SELECT fun_insert_terceros(
            :id_tipo, :id_tercero, :ind_tipo_tercero, :id_cat_tercero,
            :nom_tercero, :direccion, :tel_fijo,
            :id_prefijo_movil, :tel_movil, :email, :id_ciudad,
            :id_restriccion, :ind_estado
        )"
    );

    $upd_tercero = $pdo->prepare("
    SELECT fun_update_terceros(
        :id_tercero,
        :ind_tipo_tercero,
        :id_cat_tercero,
        :nom_tercero,
        :nom_corto,
        :direccion,
        :tel_fijo,
        :id_prefijo_movil,
        :tel_movil,
        :email,
        :id_ciudad,
        :id_restriccion,
        :ind_estado

    )
");

    $del_tercero = $pdo->prepare(
        "SELECT fun_delete_terceros(:id_tercero)"
    );

    // =========================================================================
    // FUNCIONES PARA CLIENTES
    // =========================================================================

    $ins_cliente = $pdo->prepare(
        "SELECT fn_insert_cliente(
            :id_cliente,
            :id_tipo,
            :fec_nacimi,
            :genero,
            :puntos,
            :credito,
            :cupo,
            :dias_cartera
        )"
    );

   $upd_cliente = $pdo->prepare("
    SELECT fn_update_cliente(
        :wid_cliente,
        :wid_tipo,
        :wfec_nacimi,
        :wind_genero,
        :wval_puntos,
        :wind_credito,
        :wval_cupocredito,
        :wval_diascartera,
        :wind_estado
    )
");

    $del_cliente = $pdo->prepare(
        "SELECT fun_logicadelete_cliente(:id_cliente)"
    );

    $toggle_cliente = $pdo->prepare(
        "UPDATE tab_clientes
            SET ind_estado = NOT ind_estado
          WHERE id_cliente = :id_cliente"
    );

    // =========================================================================
    // INSERT — fun_insert_* (ya estaban)
    // =========================================================================

    $ins_vendedor = $pdo->prepare(
        "SELECT fun_insertar_vendedor(
            :id_vendedor,
            :porcomision
        )"
    );

    $ins_pmtros_facturacion = $pdo->prepare(
        "SELECT fun_insert_pmtros_facturacion(
            :id_empresa,
            :val_res_aut,
            :fec_venc,
            :fec_res_aut,
            :val_prefijofac,
            :val_facini,
            :val_facactual,
            :val_facfin,
            :val_prefijocot,
            :val_cotini,
            :val_cotactual,
            :val_porreteica,
            :val_intcorriente,
            :val_pesosXpuntos,
            :val_interesmora,
            :val_diascartera
        )"
    );

    $ins_motivo_nota = $pdo->prepare(
        "SELECT fun_insertar_motivo_nota(
            :id_motivo_nota,
            :ind_tipo_nota,
            :cod_dian,
            :nom_motivo
        )"
    );

    $ins_formapago = $pdo->prepare(
        "SELECT fun_insert_formapago(
            :id_formapago,
            :nom_formapago
        )"
    );

    // =========================================================================
    // UPDATE — fun_update_*
    // =========================================================================

    $upd_vendedor = $pdo->prepare(
        "SELECT fun_update_vendedor(
            :id_vendedor,
            :porcomision,
            :ind_estado
        )"
    );

    $upd_pmtros_facturacion = $pdo->prepare(
        "SELECT fun_update_pmtros_facturacion(
            :id_empresa,
            :val_res_aut,
            :fec_venc,
            :fec_res_aut,
            :val_prefijofac,
            :val_facini,
            :val_facactual,
            :val_facfin,
            :val_prefijocot,
            :val_cotini,
            :val_cotactual,
            :val_porreteica,
            :val_intcorriente,
            :val_pesosXpuntos,
            :val_interesmora,
            :val_diascartera
        )"
    );

    $upd_motivo_nota = $pdo->prepare(
        "SELECT fun_update_motivo_nota(
            :id_motivo_nota,
            :ind_tipo_nota,
            :cod_dian,
            :nom_motivo,
            :afecta_inventario,
            :afecta_cliente,
            :afecta_cartera,
            :afecta_comision
        )"
    );

    $upd_formapago = $pdo->prepare(
        "SELECT fn_update_formapagos(
            :id_formapago,
            :nom_formapago
        )"
    );

    // =========================================================================
    // DELETE — fun_delete_* (borrado lógico)
    // =========================================================================

    $del_vendedor = $pdo->prepare(
        "SELECT fun_delete_vendedor(:id_vendedor)"
    );

    $del_pmtros_facturacion = $pdo->prepare(
        "SELECT fun_delete_pmtros_facturacion(:id_empresa)"
    );

    $del_motivo_nota = $pdo->prepare(
        "SELECT fun_delete_motivo_nota(:id_motivo_nota)"
    );

    $del_formapago = $pdo->prepare(
        "SELECT fun_delete_formapago(:id_formapago)"
    );

    // =========================================================================
    // TOGGLES DE ESTADO
    // =========================================================================

    $toggle_vendedor = $pdo->prepare(
        "UPDATE tab_vendedores
            SET ind_estado = NOT ind_estado
          WHERE id_vendedor = :id_vendedor"
    );

    $toggle_motivo_nota = $pdo->prepare(
        "UPDATE tab_motivo_nota
            SET ind_estado = NOT ind_estado
          WHERE id_motivo_nota = :id_motivo_nota"
    );

    $toggle_producto = $pdo->prepare(
        "UPDATE tab_productos
            SET ind_estado = NOT ind_estado
          WHERE id_producto = :id_producto"
    );

} catch (PDOException $e) {
    error_log("Error en prepare_faccar.php: " . $e->getMessage());
    die("Error crítico al preparar consultas. Revise los logs del servidor.");
}
?>

