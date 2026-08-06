CREATE OR REPLACE FUNCTION fun_insert_menu_usuarios(p_id_usuario    tab_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_usuario IS NULL OR TRIM(p_id_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_id_usuario AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_id_usuario;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu   = p_id_menu AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El menú % no existe o está inactivo', p_id_menu;
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú % ya está asignado al usuario %', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
    VALUES (p_id_usuario, p_id_menu);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;
