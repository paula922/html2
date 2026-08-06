CREATE OR REPLACE FUNCTION fun_update_tel_prefijo(wid_prefijo     tab_tel_prefijo.id_prefijo%TYPE,
                                                  wnom_pais       tab_tel_prefijo.nom_pais%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_prefijo IS NULL THEN
        RAISE EXCEPTION 'El ID del prefijo no puede ser nulo';
    END IF;

    IF wnom_pais IS NULL OR TRIM(wnom_pais) = '' THEN
        RAISE EXCEPTION 'El nombre del país no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_prefijo <= 0 OR wid_prefijo > 9999 THEN
        RAISE EXCEPTION 'El ID del prefijo debe estar entre 1 y 9999';
    END IF;

    IF LENGTH(wnom_pais) < 4 OR LENGTH(wnom_pais) > 50 THEN
        RAISE EXCEPTION 'El nombre del país debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo) THEN
        RAISE EXCEPTION 'El prefijo con ID % no existe', wid_prefijo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tel_prefijo SET nom_pais = wnom_pais
    WHERE id_prefijo = wid_prefijo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;