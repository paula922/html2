CREATE OR REPLACE FUNCTION fun_insert_restricciones(wid_restriccion     tab_restricciones.id_restriccion%TYPE,
                                                    wnom_restriccion    tab_restricciones.nom_restriccion%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wnom_restriccion IS NULL OR TRIM(wnom_restriccion) = '' THEN
        RAISE EXCEPTION 'El nombre de la restricción no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 1 y 99
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres, solo letras y espacios
    IF LENGTH(wnom_restriccion) < 4 OR LENGTH(wnom_restriccion) > 50 THEN
        RAISE EXCEPTION 'El nombre de la restricción debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_restriccion !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la restricción solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'Ya existe una restricción con el ID %', wid_restriccion;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_restricciones (id_restriccion,nom_restriccion) 
    VALUES (wid_restriccion,wnom_restriccion);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;