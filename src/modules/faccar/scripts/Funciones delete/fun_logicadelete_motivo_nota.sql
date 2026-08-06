CREATE OR REPLACE FUNCTION fun_delete_motivo_nota(
    wid_motivo_nota tab_motivo_nota.id_motivo_nota%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / RANGO BÁSICO
    -- =============================================
    IF wid_motivo_nota IS NULL OR wid_motivo_nota <= 0 THEN
        RAISE EXCEPTION 'El ID del motivo de nota debe ser mayor a 0.';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (
        SELECT 1 FROM tab_motivo_nota
        WHERE id_motivo_nota = wid_motivo_nota
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El motivo de nota con ID % no existe o ya fue eliminado', wid_motivo_nota;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_motivo_nota
    SET ind_borrado = TRUE
    WHERE id_motivo_nota = wid_motivo_nota;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;