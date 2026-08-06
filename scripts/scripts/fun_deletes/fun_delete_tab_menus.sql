CREATE OR REPLACE FUNCTION fun_delete_tab_menus(p_id_menu   tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú con ID % no existe', p_id_menu;
    END IF;

    -- Verificar que no tenga submenús activos
    IF EXISTS (SELECT 1 FROM tab_menus WHERE ind_id_padre = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque tiene submenús asociados', p_id_menu;
    END IF;

    -- Verificar que no esté asignado a usuarios
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque está asignado a uno o más usuarios', p_id_menu;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;