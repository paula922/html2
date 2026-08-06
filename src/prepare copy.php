<?php
/**
 * CENTRAL DE INSTRUCCIONES PREPARADAS - SistNomina V.1.2
 * 
 * Este archivo es el más importante del sistema. Aquí:
 * 1. Conecto a la base de datos
 * 2. Preparo TODAS las consultas SQL que voy a usar
 * 3. Las dejo listas en variables globales para usarlas donde sea
 * 
 * La ventaja es que las consultas se preparan UNA SOLA VEZ y se ejecutan muchas veces
 */

// Cargo la configuración (que ya tiene las constantes del .env)
require_once('config.php');

try {
    // ============================================
    // CONEXIÓN A POSTGRESQL
    // ============================================
    
    // Armo el DSN (Data Source Name) con las constantes de config.php
    $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
    
    // Creo la conexión PDO
    // Las opciones: 
    // - ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION: lanza excepciones en errores
    // - ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC: devuelve arrays asociativos
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    // ============================================
    // 1. SECCIÓN DE AUTENTICACIÓN Y LOGIN
    // ============================================
    
    // Buscar usuario por ID (para login)
    // CAST(? AS TEXT) porque id_usuario es VARCHAR pero a veces llega como string
    $sql_login = "SELECT id_usuario, nom_usuario, pass_usuario, mail_usuario, ind_usuario, ind_estado 
                  FROM tab_usuarios WHERE id_usuario = CAST(? AS TEXT)";
    $stmt_login = $pdo->prepare($sql_login);

    // Validar usuario activo por ID (para recuperar contraseña)
    $sql_fun_valida_usr = "SELECT id_usuario, nom_usuario FROM tab_usuarios WHERE id_usuario = ?::TEXT AND ind_estado = TRUE";
    $stmt_fun_valida_usr = $pdo->prepare($sql_fun_valida_usr);

    // Login completo (versión anterior, por si acaso)
    $sql_fun_valida_login = "SELECT id_usuario, nom_usuario, pass_usuario FROM tab_usuarios WHERE id_usuario = ?::TEXT AND ind_estado = TRUE";
    $stmt_fun_valida_login = $pdo->prepare($sql_fun_valida_login);

    // ============================================
    // 2. SECCIÓN DE MAESTRO DE USUARIOS
    // ============================================
    
    // Insertar usuario (llama a la función de PostgreSQL)
    $sql_fun_ins_user = "SELECT fun_insert_tab_usuarios(?::TEXT, ?::TEXT, ?::TEXT, ?::TEXT, ?::BOOLEAN, ?::BOOLEAN)";
    $stmt_fun_ins_user = $pdo->prepare($sql_fun_ins_user);

    // Actualizar usuario
    $sql_fun_upd_user = "SELECT fun_update_tab_usuarios(?::TEXT, ?::TEXT, ?::TEXT, ?::TEXT, ?::BOOLEAN, ?::BOOLEAN)";
    $stmt_fun_upd_user = $pdo->prepare($sql_fun_upd_user);

    // Listar todos los usuarios (para el CRUD)
    $sql_list_users = "SELECT id_usuario, nom_usuario, mail_usuario, ind_usuario, ind_estado FROM tab_usuarios ORDER BY id_usuario ASC";
    $stmt_list_users = $pdo->prepare($sql_list_users);

    // ============================================
    // 3. SECCIÓN DE RECUPERACIÓN DE CONTRASEÑA
    // ============================================
    
    // Validar que el correo coincida con el usuario
    $sql_valida_mail = "SELECT mail_usuario FROM tab_usuarios WHERE id_usuario = ? AND mail_usuario = ?";
    $stmt_valida_mail = $pdo->prepare($sql_valida_mail);

    // Actualizar contraseña (para recuperación)
    $sql_temp_pass = "UPDATE tab_usuarios SET pass_usuario = ?::TEXT WHERE id_usuario = ?::TEXT";
    $stmt_upd_pass = $pdo->prepare($sql_temp_pass);

    // ============================================
    // 4. SECCIÓN DE NAVEGACIÓN Y MENÚS
    // ============================================
    
    // Obtener menús de un usuario específico (para el sidebar)
    $sql_menu = "SELECT m.id_menu, m.nom_menu, m.ind_id_padre, m.nom_programa 
                 FROM tab_menu_usuarios mu INNER JOIN tab_menus m ON mu.id_menu = m.id_menu
                 WHERE mu.id_usuario = CAST(? AS TEXT) ORDER BY m.id_menu ASC";
    $stmt_menu = $pdo->prepare($sql_menu);

    // Listar todos los menús (para el CRUD de menús)
    $sql_list_todos_menus = "SELECT id_menu, nom_menu, ind_id_padre, nom_programa FROM tab_menus ORDER BY id_menu ASC";
    $stmt_list_todos_menus = $pdo->prepare($sql_list_todos_menus);

    // =====================================================
    // SECCIÓN PARÁMETROS GENERALES (tab_pmtros_grales)
    // =====================================================

    // Listar todos los parámetros (no borrados)
    $sql_list_pmtros_grales = "SELECT * FROM tab_pmtros_grales WHERE ind_borrado = FALSE ORDER BY id_empresa";
    $stmt_list_pmtros_grales = $pdo->prepare($sql_list_pmtros_grales);

    // Obtener un parámetro específico
    $sql_get_pmtros_grales = "SELECT * FROM tab_pmtros_grales WHERE id_empresa = ? AND ind_borrado = FALSE";
    $stmt_get_pmtros_grales = $pdo->prepare($sql_get_pmtros_grales);

    // Funciones almacenadas para CRUD
    $sql_fun_ins_pmtros_grales = "SELECT fun_insert_pmtros_grales(?::DECIMAL, ?::VARCHAR, ?::DATOS_UBICACION, ?::VARCHAR, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::VARCHAR, ?::VARCHAR, ?::VARCHAR, ?::BOOLEAN)";
    $stmt_fun_ins_pmtros_grales = $pdo->prepare($sql_fun_ins_pmtros_grales);

    $sql_fun_upd_pmtros_grales = "SELECT fun_update_pmtros_grales(?::DECIMAL, ?::VARCHAR, ?::DATOS_UBICACION, ?::VARCHAR, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::DECIMAL, ?::VARCHAR, ?::VARCHAR, ?::VARCHAR, ?::BOOLEAN)";
    $stmt_fun_upd_pmtros_grales = $pdo->prepare($sql_fun_upd_pmtros_grales);

    $sql_fun_del_pmtros_grales = "SELECT fun_delete_pmtros_grales(?::DECIMAL)";
    $stmt_fun_del_pmtros_grales = $pdo->prepare($sql_fun_del_pmtros_grales);

    // Insertar menú
    $sql_fun_ins_menu = "SELECT fun_insert_tab_menus(?::TEXT, ?::TEXT, ?::TEXT, ?::TEXT)";
    $stmt_ins_menu = $pdo->prepare($sql_fun_ins_menu);

    // Actualizar menú
    $sql_fun_upd_menu = "SELECT fun_update_tab_menus(?::TEXT, ?::TEXT, ?::TEXT, ?::TEXT)";
    $stmt_upd_menu = $pdo->prepare($sql_fun_upd_menu);

    // Eliminar menú
    $sql_fun_del_menu = "SELECT fun_delete_tab_menus(?::TEXT)";
    $stmt_del_menu = $pdo->prepare($sql_fun_del_menu);

    // ============================================
    // 5. SECCIÓN DE SESIONES Y PARÁMETROS
    // ============================================
    
    // Obtener tiempo de sesión activa (de la tabla de parámetros)
    $sql_pmtros = "SELECT time_sesion_activa FROM tab_pmtros LIMIT 1";
    $stmt_pmtros = $pdo->prepare($sql_pmtros);

    // Validar si existe una sesión activa para el usuario
    $sql_valida_sesion = "SELECT token_sesion FROM tab_sesiones WHERE id_usuario = ?";
    $stmt_valida_sesion = $pdo->prepare($sql_valida_sesion);

    // Insertar nueva sesión
    $sql_ins_sesion = "INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio) VALUES (?, ?, CURRENT_TIMESTAMP)";
    $stmt_ins_sesion = $pdo->prepare($sql_ins_sesion);

    // Eliminar sesión (para logout)
    $sql_del_sesion = "DELETE FROM tab_sesiones WHERE id_usuario = ?";
    $stmt_del_sesion = $pdo->prepare($sql_del_sesion);

    // ============================================
    // 6. SECCIÓN DE MAESTROS BÁSICOS
    // ============================================
    
    // Listar departamentos (para combos)
    $sql_list_dptos = "SELECT id_dpto, nom_dpto FROM tab_dptos ORDER BY nom_dpto ASC";
    $stmt_list_dptos = $pdo->prepare($sql_list_dptos);

    // Listar cargos (para combos)
    $sql_list_cargos = "SELECT id_cargo, nom_cargo FROM tab_cargos ORDER BY id_cargo ASC";
    $stmt_list_cargos = $pdo->prepare($sql_list_cargos);

    // ============================================
    // 7. SECCIÓN PERFILES
    // ============================================
    
    // Insertar perfil (asignar menú a usuario)
    $sql_ins_perfil = "SELECT fun_insert_menu_usuarios(?::VARCHAR, ?::VARCHAR)";
    $stmt_ins_perfil = $pdo->prepare($sql_ins_perfil);

    // Eliminar perfil (quitar todos los menús de un usuario)
    $sql_del_perfil = "SELECT fun_delete_perfil_usuario(?::VARCHAR)";
    $stmt_del_perfil = $pdo->prepare($sql_del_perfil);

    // Listar usuarios (para combos de asignación)
    $stmt_list_usuarios = $pdo->prepare("SELECT id_usuario, nom_usuario FROM tab_usuarios WHERE id_usuario <> 'admin' ORDER BY nom_usuario");

} catch (PDOException $e) {
    // Si hay error de conexión, no puedo hacer nada más que morir
    // Muestro el error pero en producción debería ser un mensaje genérico
    die("Error crítico en prepare.php: " . $e->getMessage());
}
?>