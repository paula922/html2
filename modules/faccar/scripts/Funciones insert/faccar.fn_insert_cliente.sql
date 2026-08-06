CREATE OR REPLACE FUNCTION fn_insert_cliente(
    wid_cliente      tab_clientes.id_cliente%TYPE,
    wid_tipo         tab_clientes.id_tipo%TYPE,
    wfec_nacimi      tab_clientes.fec_nacimi%TYPE, -- El trigger calculará val_edad
    wind_genero      tab_clientes.ind_genero%TYPE,
    wval_puntos      tab_clientes.val_puntos%TYPE,
    wind_credito     tab_clientes.ind_credito%TYPE,
    wval_cupocredito tab_clientes.val_cupocredito%TYPE,
    wval_diascartera tab_clientes.val_diascartera%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_cliente IS NULL OR TRIM(wid_cliente) = '' THEN
        RAISE EXCEPTION 'El ID del cliente no puede estar vacío';
    END IF;

    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El tipo de identidad no puede estar vacío';
    END IF;

    IF wfec_nacimi IS NULL THEN
        RAISE EXCEPTION 'La fecha de nacimiento no puede ser nula';
    END IF;

    IF wind_genero IS NULL THEN
        RAISE EXCEPTION 'El indicador de género no puede ser nulo';
    END IF;

    IF wval_puntos IS NULL THEN
        RAISE EXCEPTION 'El valor de puntos no puede ser nulo';
    END IF;

    IF wind_credito IS NULL THEN
        RAISE EXCEPTION 'El indicador de crédito no puede ser nulo';
    END IF;

    -- val_cupocredito se permite nulo, pero si se da, no puede ser negativo (se valida después)
    IF wval_diascartera IS NULL THEN
        RAISE EXCEPTION 'El valor de días cartera no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    -- ID: mínimo 6 caracteres, solo letras y números
    IF LENGTH(TRIM(wid_cliente)) < 6 THEN
        RAISE EXCEPTION 'El ID del cliente debe tener mínimo 6 caracteres';
    END IF;

    IF wid_cliente !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del cliente solo puede contener letras y números';
    END IF;

    -- Género
    IF wind_genero NOT IN ('M', 'F', 'T', 'NB') THEN
        RAISE EXCEPTION 'Género inválido. Valores permitidos: M, F, T, NB';
    END IF;

    -- Puntos no negativos
    IF wval_puntos < 0 THEN
        RAISE EXCEPTION 'Los puntos no pueden ser negativos';
    END IF;

    -- Cupo de crédito no negativo (si se proporciona)
    IF wval_cupocredito IS NOT NULL AND wval_cupocredito < 0 THEN
        RAISE EXCEPTION 'El cupo de crédito no puede ser negativo';
    END IF;

    -- Días cartera entre 0 y 120
    IF wval_diascartera < 0 OR wval_diascartera >= 120 THEN
        RAISE EXCEPTION 'Los días cartera deben estar entre 0 y 120';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA DE CLAVES FORÁNEAS
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_cliente) THEN
        RAISE EXCEPTION 'El id_cliente % no existe como tercero. Debe registrarse primero en la tabla de terceros.', wid_cliente;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad % no existe en tab_tipo_identidad.', wid_tipo;
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_clientes WHERE id_cliente = wid_cliente) THEN
        RAISE EXCEPTION 'Ya existe un cliente con el ID %', wid_cliente;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    -- El campo val_edad se deja como NULL porque el trigger lo calculará.
    -- Los campos adicionales (true, false) corresponden a los valores por defecto
    -- que estaban en la función original (ind_activo = true, ind_borrado = false).
    INSERT INTO tab_clientes
        (id_cliente, id_tipo, fec_nacimi, val_edad,
         ind_genero, val_puntos, ind_credito,
         val_cupocredito, val_diascartera,
         ind_estado, ind_borrado)
    VALUES
        (wid_cliente, wid_tipo, wfec_nacimi, NULL,
         wind_genero, wval_puntos, wind_credito,
         wval_cupocredito, wval_diascartera,
         TRUE, FALSE);

    RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
    RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
        
END;
$$
LANGUAGE plpgsql;