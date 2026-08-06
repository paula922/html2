CREATE OR REPLACE FUNCTION fun_delete_menu_usuarios(p_id_usuario    tab_menu_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menu_usuarios.id_menu%TYPE) RETURNS BOOLEAN AS
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
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'La asignación del menú % al usuario % no existe', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menu_usuarios
    WHERE id_usuario = p_id_usuario AND id_menu    = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;