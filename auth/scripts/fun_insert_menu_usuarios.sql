-- ===================================================================
-- Función: fun_insert_menu_usuarios
-- Descripción: Inserta la relación entre usuario y menú en tab_menu_usuarios
-- Parámetros:
--   p_id_usuario: ID del usuario (VARCHAR)
--   p_id_menu: ID del menú (VARCHAR)
-- Retorna: VOID
-- Autor: Sistema SistNomina V.1.3
-- ===================================================================

CREATE OR REPLACE FUNCTION fun_insert_menu_usuarios(
    p_id_usuario tab_usuarios.id_usuario%TYPE,
    p_id_menu tab_menus.id_menu%TYPE
) RETURNS VOID AS
$$
BEGIN
    -- Validar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_id_usuario) THEN
        RAISE EXCEPTION 'El usuario % no existe en tab_usuarios', p_id_usuario;
    END IF;

    -- Validar que el menú existe
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú % no existe en tab_menus', p_id_menu;
    END IF;

    -- Insertar la relación
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
    VALUES (p_id_usuario, p_id_menu);

EXCEPTION
    WHEN unique_violation THEN
        -- El usuario ya tiene ese menú asignado, ignorar silenciosamente
        NULL;
    WHEN FOREIGN_KEY_VIOLATION THEN
        RAISE EXCEPTION 'Error de integridad referencial en fun_insert_menu_usuarios: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en fun_insert_menu_usuarios: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
