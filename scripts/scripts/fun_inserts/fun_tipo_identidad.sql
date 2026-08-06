CREATE OR REPLACE FUNCTION fun_insert_tipo_identidad( wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
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

    -- ID: entre 2 y 5 letras mayúsculas
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    -- Nombre: entre 5 y 50 caracteres
    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'Ya existe un tipo de identidad con el ID %', wid_tipo;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_tipo_identidad (id_tipo,nom_tipo
    ) VALUES (wid_tipo,wnom_tipo);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;