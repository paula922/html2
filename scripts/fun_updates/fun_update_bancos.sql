CREATE OR REPLACE FUNCTION fun_update_bancos(wid_banco       tab_bancos.id_banco%TYPE,
                                             wnom_banco      tab_bancos.nom_banco%TYPE,
                                             wind_estado     tab_bancos.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    IF wnom_banco IS NULL OR TRIM(wnom_banco) = '' THEN
        RAISE EXCEPTION 'El nombre del banco no puede estar vacío';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    IF LENGTH(wnom_banco) < 4 OR LENGTH(wnom_banco) > 50 THEN
        RAISE EXCEPTION 'El nombre del banco debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o está inactivo', wid_banco;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_bancos SET nom_banco  = wnom_banco,
                          ind_estado = wind_estado
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;