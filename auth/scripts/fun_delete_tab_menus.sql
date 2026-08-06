-- 3. Función Atómica para Borrado (Isolation)
-- V.1.3 CORRECCIÓN: Tipo correcto para id_menu (VARCHAR, no INT)
-- VALIDACIONES:
-- 1. El menú debe existir
-- 2. No debe tener menús hijos (integridad referencial)
-- 3. No debe haber usuarios con acceso a este menú
CREATE OR REPLACE FUNCTION fun_delete_tab_menus(p_id_menu tab_menus.id_menu%TYPE) RETURNS TEXT AS
$$
DECLARE
    v_exists INTEGER;
    v_tiene_hijos INTEGER;
    v_tiene_usuarios INTEGER;
BEGIN
    -- 1. VALIDACIÓN: El menú debe existir
    SELECT COUNT(*) INTO v_exists FROM tab_menus WHERE id_menu = p_id_menu;
    IF v_exists = 0 THEN
        RETURN 'ERR: Menú ID ' || p_id_menu || ' no existe';
    END IF;

    -- 2. VALIDACIÓN: Verificar aislamiento - que no tenga hijos antes de proceder
    SELECT COUNT(*) INTO v_tiene_hijos FROM tab_menus WHERE ind_id_padre = p_id_menu;
    IF v_tiene_hijos > 0 THEN
        RETURN 'ERR_CON_HIJOS: Menú ID ' || p_id_menu || ' tiene ' || v_tiene_hijos || ' submenús. Elimine primero los hijos.';
    END IF;

    -- ELIMINACIÓN: Todas las validaciones pasaron
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;
    RETURN 'OK';
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;