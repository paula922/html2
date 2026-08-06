CREATE OR REPLACE FUNCTION fun_delete_areas(wid_area    tab_areas.id_area%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_area IS NULL THEN
        RAISE EXCEPTION 'El ID del área no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El área con ID % no existe o ya fue eliminada', wid_area;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_areas SET ind_borrado = TRUE
    WHERE id_area = wid_area;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;