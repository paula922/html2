CREATE OR REPLACE FUNCTION fun_insert_ciudades(wid_ciudad      tab_ciudades.id_ciudad%TYPE,
                                               wnom_ciudad     tab_ciudades.nom_ciudad%TYPE,
                                               wid_dpto        tab_ciudades.id_dpto%TYPE,
                                               wind_capital    tab_ciudades.ind_capital%TYPE,
                                               wcod_postal     tab_ciudades.cod_postal%TYPE,
                                               wval_latitud    tab_ciudades.val_latitud%TYPE,
                                               wval_longitud   tab_ciudades.val_longitud%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wnom_ciudad IS NULL OR TRIM(wnom_ciudad) = '' THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede estar vacío';
    END IF;

    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL OR TRIM(wcod_postal) = '' THEN
        RAISE EXCEPTION 'El código postal no puede estar vacío';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID ciudad: exactamente 5 dígitos numéricos
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- Nombre ciudad: entre 3 y 30 caracteres, solo letras y espacios
    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios';
    END IF;

    -- ID departamento: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Código postal: exactamente 6 dígitos numéricos
    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de exactamente 6 dígitos (ej: 050001)';
    END IF;

    -- Latitud: entre -4 y 80
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    -- Longitud: entre -80 y -50
    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO Y EXISTENCIA FK
    -- =============================================

    -- Verificar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- Verificar duplicado de ciudad
    IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad) THEN
        RAISE EXCEPTION 'Ya existe una ciudad con el ID %', wid_ciudad;
    END IF;

    -- Solo puede haber una capital por departamento
    IF wind_capital = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_dpto = wid_dpto AND ind_capital = TRUE AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'El departamento % ya tiene una ciudad capital registrada', wid_dpto;
        END IF;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_ciudades (id_ciudad,nom_ciudad,id_dpto,ind_capital,cod_postal,val_latitud,val_longitud,ind_borrado) 
    VALUES (wid_ciudad,wnom_ciudad,wid_dpto,wind_capital,wcod_postal,wval_latitud,wval_longitud,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;