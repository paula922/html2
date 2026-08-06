<?php
/**
 * CENTRAL DE INSTRUCCIONES PREPARADAS - SistNomina V.1.2
 *
 * Este archivo es el más importante del sistema. Aquí:
 * 1. Conecto a la base de datos
 * 2. Preparo TODAS las consultas SQL que voy a usar
 * 3. Las dejo listas en variables globales para usarlas donde sea
 */

require_once('config.php');


try {
    $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

        //deja el usuario y la IP listos para que cualquier trigger de auditoría
     //los pueda leer, ANTES de que se ejecute cualquier $stmt->execute() de aquí abajo.
  


    // =========================================================================
    // SECCIÓN DE USUARIOS
    // =========================================================================

    $stmt_list_users = $pdo->prepare(
        "SELECT id_usuario, nom_usuario, mail_usuario, ind_usuario, ind_estado
           FROM tab_usuarios
          ORDER BY id_usuario ASC"
    );

    $stmt_check_usuario = $pdo->prepare(
        "SELECT COUNT(*)
           FROM tab_usuarios
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    $stmt_update_usuario_con_pass = $pdo->prepare(
        "UPDATE tab_usuarios
            SET nom_usuario  = ?,
                pass_usuario = ?,
                mail_usuario = ?,
                ind_usuario  = ?,
                ind_estado   = ?
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    $stmt_update_usuario_sin_pass = $pdo->prepare(
        "UPDATE tab_usuarios
            SET nom_usuario  = ?,
                mail_usuario = ?,
                ind_usuario  = ?,
                ind_estado   = ?
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    $stmt_insert_usuario = $pdo->prepare(
        "INSERT INTO tab_usuarios
                (id_usuario, nom_usuario, pass_usuario, mail_usuario, ind_usuario, ind_estado)
         VALUES (CAST(? AS TEXT), ?, ?, ?, ?, ?)"
    );

    $stmt_toggle_estado = $pdo->prepare(
        "UPDATE tab_usuarios
            SET ind_estado = ?
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    $stmt_check_usuario_menu = $pdo->prepare(
        "SELECT COUNT(*)
           FROM tab_menu_usuarios
          WHERE id_usuario = CAST(? AS TEXT)
            AND id_menu    = ?"
    );

    // Listar usuarios para combos
    $stmt_list_usuarios = $pdo->prepare(
        "SELECT id_usuario, nom_usuario
           FROM tab_usuarios
          WHERE id_usuario <> 'admin'
          ORDER BY nom_usuario"
    );

    // =========================================================================
    // SECCIÓN DE MENÚS
    // =========================================================================

    $stmt_list_todos_menus = $pdo->prepare(
        "SELECT id_menu, nom_menu, ind_id_padre, nom_programa
           FROM tab_menus
          ORDER BY id_menu ASC"
    );

    $stmt_menu_usuario = $pdo->prepare(
        "SELECT m.id_menu, m.nom_menu, m.ind_id_padre, m.nom_programa
           FROM tab_menu_usuarios mu
          INNER JOIN tab_menus m ON mu.id_menu = m.id_menu
          WHERE mu.id_usuario = CAST(? AS TEXT)
          ORDER BY m.id_menu ASC"
    );

    // =========================================================================
    // SECCIÓN DE PERFILES (menús por usuario)
    // =========================================================================

    $stmt_ins_menu_usuario = $pdo->prepare(
        "INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
         VALUES (CAST(? AS TEXT), CAST(? AS TEXT))"
    );

    $stmt_del_menu_usuario = $pdo->prepare(
        "DELETE FROM tab_menu_usuarios
          WHERE id_usuario = CAST(? AS TEXT)
            AND id_menu    = CAST(? AS TEXT)"
    );

    $stmt_del_all_menus_usuario = $pdo->prepare(
        "DELETE FROM tab_menu_usuarios
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    $stmt_get_menus_usuario = $pdo->prepare(
        "SELECT id_menu
           FROM tab_menu_usuarios
          WHERE id_usuario = CAST(? AS TEXT)"
    );

    // =========================================================================
    // SECCIÓN DE DEPARTAMENTOS
    // =========================================================================

    $stmt_list_dptos = $pdo->prepare(
        "SELECT id_dpto, nom_dpto
           FROM tab_dptos
          WHERE ind_borrado = FALSE
          ORDER BY nom_dpto ASC"
    );

    // =========================================================================
    // SECCIÓN DE PARÁMETROS GENERALES
    // =========================================================================

    $stmt_list_pmtros_grales = $pdo->prepare(
        "SELECT id_empresa,
                nom_empresa,
                nom_replegal,
                datos_residencia,
                val_poriva,
                val_pordesc,
                val_porrete,
                val_reteica,
                val_porutil,
                val_latitud,
                val_longitud,
                val_color_letra,
                val_color_logo,
                val_color_fondo,
                ind_autorete
           FROM tab_pmtros_grales
          WHERE ind_borrado = FALSE
          ORDER BY id_empresa"
    );


// =========================================================================
// OBTENER EMPRESA CON CAMPOS DEL COMPOSITE DATOS_UBICACION DESGLOSADOS
// =========================================================================
    $stmt_get_empresa_detalle = $pdo->prepare(
        "SELECT id_empresa,
                nom_empresa,
                nom_replegal,
                (datos_residencia).nom_corto   AS barrio,
                (datos_residencia).direccion   AS direccion,
                (datos_residencia).tel_fijo    AS tel_fijo,
                (datos_residencia).tel_movil   AS tel_movil,
                (datos_residencia).email       AS email,
                val_poriva,
                val_pordesc,
                val_porrete,
                val_reteica,
                val_porutil,
                val_latitud,
                val_longitud,
                val_color_letra,
                val_color_logo,
                val_color_fondo,
                ind_autorete
           FROM tab_pmtros_grales
          WHERE ind_borrado = FALSE
       ORDER BY id_empresa
          LIMIT 1"
    );
    // Llama a fun_insert_pmtros_grales(id_empresa, nom_empresa, datos_residencia,
    //   nom_replegal, val_poriva, val_pordesc, val_porrete, val_reteica,
    //   val_porutil, val_latitud, val_longitud, val_color_letra,
    //   val_color_logo, val_color_fondo, ind_autorete)
    $stmt_fun_ins_pmtros_grales = $pdo->prepare(
        "SELECT fun_insert_pmtros_grales(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    );

    // Mismos parámetros que el insert — la función update identifica
    // el registro por id_empresa (primer parámetro)
    $stmt_fun_upd_pmtros_grales = $pdo->prepare(
        "SELECT fun_update_pmtros_grales(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    );

} catch (PDOException $e) {
    die("Error crítico en prepare.php: " . $e->getMessage());
}
?>