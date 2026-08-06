CREATE OR REPLACE FUNCTION fun_delete_menu_palettes(wid_palette     tab_menu_palettes.id_palette%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe o ya fue eliminada', wid_palette;
    END IF;

    -- No se puede eliminar la paleta activa
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_active = TRUE) THEN
        RAISE EXCEPTION 'No se puede eliminar la paleta % porque está activa, desactívela primero', wid_palette;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_menu_palettes SET ind_borrado = TRUE
    WHERE id_palette = wid_palette;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


