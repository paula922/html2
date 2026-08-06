CREATE OR REPLACE FUNCTION fun_insert_pmtros_grales(wid_empresa         tab_pmtros_grales.id_empresa%TYPE,
                                                    wnom_empresa        tab_pmtros_grales.nom_empresa%TYPE,
                                                    wnom_corto          VARCHAR,
                                                    wdireccion          VARCHAR,
                                                    wtel_fijo           DECIMAL,
                                                    wid_prefijo_movil   DECIMAL,
                                                    wtel_movil          DECIMAL,
                                                    wemail              VARCHAR,
                                                    wnom_replegal       tab_pmtros_grales.nom_replegal%TYPE,
                                                    wval_poriva         tab_pmtros_grales.val_poriva%TYPE,
                                                    wval_pordesc        tab_pmtros_grales.val_pordesc%TYPE,
                                                    wval_porrete        tab_pmtros_grales.val_porrete%TYPE,
                                                    wval_reteica        tab_pmtros_grales.val_reteica%TYPE,
                                                    wval_porutil        tab_pmtros_grales.val_porutil%TYPE,
                                                    wval_latitud        tab_pmtros_grales.val_latitud%TYPE,
                                                    wval_longitud       tab_pmtros_grales.val_longitud%TYPE,
                                                    wind_autorete       tab_pmtros_grales.ind_autorete%TYPE,
                                                    wriesgo_arl         tab_pmtros_grales.riesgo_arl%TYPE) RETURNS BOOLEAN AS
$$
DECLARE
    wanio_fiscal tab_pmtros_grales.anio_fiscal%TYPE;
    wmes_fiscal  tab_pmtros_grales.mes_fiscal%TYPE;
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    IF wnom_empresa IS NULL OR TRIM(wnom_empresa) = '' THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wnom_replegal IS NULL OR TRIM(wnom_replegal) = '' THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede estar vacío';
    END IF;

    IF wval_poriva IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de IVA no puede ser nulo';
    END IF;

    IF wval_pordesc IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de descuento no puede ser nulo';
    END IF;

    IF wval_porrete IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de retención no puede ser nulo';
    END IF;

    IF wval_reteica IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de reteica no puede ser nulo';
    END IF;

    IF wval_porutil IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de utilidad no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    IF wriesgo_arl IS NULL OR TRIM(wriesgo_arl) = '' THEN
        RAISE EXCEPTION 'El riesgo ARL no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID empresa: numérico de 8 a 10 dígitos
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    -- Nombre empresa: entre 5 y 60 caracteres
    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    -- Nombre representante legal: entre 5 y 60 caracteres, solo letras y espacios
    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
    END IF;

    IF wnom_replegal !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del representante legal solo debe contener letras y espacios';
    END IF;

    -- Porcentajes
    IF wval_poriva < 0 OR wval_poriva >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de IVA debe estar entre 0 y 99';
    END IF;

    IF wval_pordesc < 0 OR wval_pordesc >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de descuento debe estar entre 0 y 99';
    END IF;

    IF wval_porrete < 0 OR wval_porrete >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de retención debe estar entre 0 y 99';
    END IF;

    IF wval_reteica < 0 OR wval_reteica >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de reteica debe estar entre 0 y 99';
    END IF;

    IF wval_porutil < 0 OR wval_porutil > 100 THEN
        RAISE EXCEPTION 'El porcentaje de utilidad debe estar entre 0 y 100';
    END IF;

    -- Latitud y longitud
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- Riesgo ARL
    IF wriesgo_arl NOT IN ('1', '2', '3', '4', '5') THEN
        RAISE EXCEPTION 'El riesgo ARL debe ser 1 (0.522%%), 2 (1.044%%), 3 (2.436%%), 4 (4.350%%) o 5 (6.960%%)';
    END IF;

    -- Teléfono fijo (opcional)
    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Prefijo móvil y teléfono móvil: ambos obligatorios si se ingresa uno
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

    -- Email
    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existe un registro para la empresa con ID %', wid_empresa;
    END IF;

    -- =============================================
    -- ASIGNACIÓN AUTOMÁTICA AÑO Y MES FISCAL
    -- =============================================
    wanio_fiscal := EXTRACT(YEAR  FROM CURRENT_DATE);
    wmes_fiscal  := EXTRACT(MONTH FROM CURRENT_DATE);

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_pmtros_grales (id_empresa,nom_empresa,datos_residencia,nom_replegal,val_poriva,val_pordesc,val_porrete,val_reteica,val_porutil,
                                    val_latitud,val_longitud,anio_fiscal,mes_fiscal,ind_autorete,riesgo_arl,ind_borrado) 
    VALUES (wid_empresa,wnom_empresa,ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,wnom_replegal,
            wval_poriva,wval_pordesc,wval_porrete,wval_reteica,wval_porutil,wval_latitud,wval_longitud,wanio_fiscal,wmes_fiscal,wind_autorete,wriesgo_arl,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;