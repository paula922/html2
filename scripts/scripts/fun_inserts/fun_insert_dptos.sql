CREATE OR REPLACE FUNCTION fun_insert_dptos(wid_dpto   tab_dptos.id_dpto%TYPE,
                                            wnom_dpto  tab_dptos.nom_dpto%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wnom_dpto IS NULL OR TRIM(wnom_dpto) = '' THEN
        RAISE EXCEPTION 'El nombre del departamento no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Nombre: entre 4 y 20 caracteres
    IF LENGTH(TRIM(wnom_dpto)) < 4 OR LENGTH(TRIM(wnom_dpto)) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    -- Nombre: solo letras y espacios
    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto) THEN
        RAISE EXCEPTION 'Ya existe un departamento con el ID %', wid_dpto;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_dptos (id_dpto,nom_dpto) 
    VALUES (wid_dpto,wnom_dpto);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;