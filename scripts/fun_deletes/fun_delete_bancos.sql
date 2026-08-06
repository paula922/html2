CREATE OR REPLACE FUNCTION fun_delete_bancos(wid_banco   tab_bancos.id_banco%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o ya fue eliminado', wid_banco;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_bancos SET ind_borrado = TRUE
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;