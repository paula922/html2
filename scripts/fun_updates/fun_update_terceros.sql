CREATE OR REPLACE FUNCTION fun_update_terceros(wid_tercero         tab_terceros.id_tercero%TYPE,
                                               wind_tipo_tercero   tab_terceros.ind_tipo_tercero%TYPE,
                                               wid_cat_tercero     tab_terceros.id_cat_tercero%TYPE,
                                               wnom_tercero        tab_terceros.nom_tercero%TYPE,
                                               wnom_corto          VARCHAR,
                                               wdireccion          VARCHAR,
                                               wtel_fijo           DECIMAL,
                                               wid_prefijo_movil   DECIMAL,
                                               wtel_movil          DECIMAL,
                                               wemail              VARCHAR,
                                               wid_ciudad          tab_terceros.id_ciudad%TYPE,
                                               wid_restriccion     tab_terceros.id_restriccion%TYPE,
                                               wind_estado         tab_terceros.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    IF wind_tipo_tercero IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de tercero no puede ser nulo';
    END IF;

    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_tercero IS NULL OR TRIM(wnom_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre del tercero no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres alfanuméricos en mayúsculas (ej: CC1234567)';
    END IF;

    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_tercero) < 4 OR LENGTH(wnom_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre del tercero debe tener entre 4 y 50 caracteres';
    END IF;

    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El tercero con ID % no existe o está inactivo', wid_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo_movil) THEN
            RAISE EXCEPTION 'El prefijo móvil % no existe', wid_prefijo_movil;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_terceros SET ind_tipo_tercero = wind_tipo_tercero,
                            id_cat_tercero   = wid_cat_tercero,
                            nom_tercero      = wnom_tercero,
                            dir_tercero      = ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
                            id_ciudad        = wid_ciudad,
                            id_restriccion   = wid_restriccion,
                            ind_estado       = wind_estado
    WHERE id_tercero = wid_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;