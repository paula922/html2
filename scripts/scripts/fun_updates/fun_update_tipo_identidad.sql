CREATE OR REPLACE FUNCTION fun_update_tipo_identidad(wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
                                                     wnom_tipo   tab_tipo_identidad.nom_tipo%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad no puede estar vacío';
    END IF;

    IF wnom_tipo IS NULL OR TRIM(wnom_tipo) = '' THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad con ID % no existe', wid_tipo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tipo_identidad SET nom_tipo = wnom_tipo
    WHERE id_tipo = wid_tipo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;