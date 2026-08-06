CREATE OR REPLACE FUNCTION fun_delete_vendedor(
    wid_vendedor tab_vendedores.id_vendedor%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_vendedor IS NULL OR TRIM(wid_vendedor) = '' THEN
        RAISE EXCEPTION 'El ID del vendedor no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(TRIM(wid_vendedor)) < 6 THEN
        RAISE EXCEPTION 'El ID del vendedor debe tener mínimo 6 caracteres';
    END IF;

    IF wid_vendedor !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del vendedor solo puede contener letras y números';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (
        SELECT 1 FROM tab_vendedores
        WHERE id_vendedor = wid_vendedor
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El vendedor con ID % no existe o ya fue eliminado', wid_vendedor;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_vendedores
    SET ind_borrado = TRUE
    WHERE id_vendedor = wid_vendedor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;