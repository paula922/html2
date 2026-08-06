CREATE OR REPLACE FUNCTION fun_delete_pmtros_facturacion(
    wid_empresa tab_pmtros_facturacion.id_empresa%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    -- id_empresa es VARCHAR(10); validamos longitud mínima 1
    IF LENGTH(TRIM(wid_empresa)) < 1 OR LENGTH(TRIM(wid_empresa)) > 10 THEN
        RAISE EXCEPTION 'El ID de la empresa debe tener entre 1 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (
        SELECT 1 FROM tab_pmtros_facturacion
        WHERE id_empresa = wid_empresa
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'Los parámetros de facturación para la empresa % no existen o ya fueron eliminados', wid_empresa;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_pmtros_facturacion
    SET ind_borrado = TRUE
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;