 CREATE OR REPLACE FUNCTION fun_update_pmtros_facturacion(wid_empresa          tab_pmtros_facturacion.id_empresa%TYPE,
                                             wval_res_aut         tab_pmtros_facturacion.val_res_aut%TYPE,
                                             wfec_venc            tab_pmtros_facturacion.fec_venc%TYPE,
                                             wfec_res_aut         tab_pmtros_facturacion.fec_res_aut%TYPE,
                                             wval_prefijofac      tab_pmtros_facturacion.val_prefijofac%TYPE,
                                             wval_facini          tab_pmtros_facturacion.val_facini%TYPE,
                                             wval_facactual       tab_pmtros_facturacion.val_facactual%TYPE,
                                             wval_facfin          tab_pmtros_facturacion.val_facfin%TYPE,
                                             wval_prefijocot      tab_pmtros_facturacion.val_prefijocot%TYPE,
                                             wval_cotini          tab_pmtros_facturacion.val_cotini%TYPE,
                                             wval_cotactual       tab_pmtros_facturacion.val_cotactual%TYPE,
                                             wval_porreteica      tab_pmtros_facturacion.val_porreteica%TYPE,
                                             wval_intcorriente    tab_pmtros_facturacion.val_intcorriente%TYPE,
                                             wval_pesosXpuntos    tab_pmtros_facturacion.val_pesosXpuntos%TYPE,
                                             wval_interesmora     tab_pmtros_facturacion.val_interesmora%TYPE,
                                             wval_diascartera     tab_pmtros_facturacion.val_diascartera%TYPE) RETURNS BOOLEAN AS
    $$
   DECLARE wwid_empresa tab_pmtros_facturacion.id_empresa%TYPE;
   BEGIN
 -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    IF wval_res_aut IS NULL THEN
        RAISE EXCEPTION 'El número de resolución de autorización no puede ser nulo';
    END IF;

    IF wfec_venc IS NULL THEN
        RAISE EXCEPTION 'La fecha de vencimiento de la resolución no puede ser nula';
    END IF;

    IF wfec_res_aut IS NULL THEN
        RAISE EXCEPTION 'La fecha de la resolución de autorización no puede ser nula';
    END IF;

    IF wval_prefijofac IS NULL OR TRIM(wval_prefijofac) = '' THEN
        RAISE EXCEPTION 'El prefijo de factura no puede estar vacío';
    END IF;

    IF wval_facini IS NULL THEN
        RAISE EXCEPTION 'El valor inicial de factura no puede ser nulo';
    END IF;

    IF wval_facactual IS NULL THEN
        RAISE EXCEPTION 'El valor actual de factura no puede ser nulo';
    END IF;

    IF wval_facfin IS NULL THEN
        RAISE EXCEPTION 'El valor final de factura no puede ser nulo';
    END IF;

    IF wval_prefijocot IS NULL OR TRIM(wval_prefijocot) = '' THEN
        RAISE EXCEPTION 'El prefijo de cotización no puede estar vacío';
    END IF;

    IF wval_cotini IS NULL THEN
        RAISE EXCEPTION 'El valor inicial de cotización no puede ser nulo';
    END IF;

    IF wval_cotactual IS NULL THEN
        RAISE EXCEPTION 'El valor actual de cotización no puede ser nulo';
    END IF;

    IF wval_porreteica IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de retención ICA no puede ser nulo';
    END IF;

    IF wval_intcorriente IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de interés corriente no puede ser nulo';
    END IF;

    IF wval_pesosXpuntos IS NULL THEN
        RAISE EXCEPTION 'El valor de pesos por puntos no puede ser nulo';
    END IF;

    IF wval_interesmora IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de interés por mora no puede ser nulo';
    END IF;

    IF wval_diascartera IS NULL THEN
        RAISE EXCEPTION 'El número de días de cartera no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- Resolución de autorización: entre 1000000000000 y 9999999999999
    IF wval_res_aut < 1000000000000 OR wval_res_aut > 9999999999999 THEN
        RAISE EXCEPTION 'El número de resolución de autorización debe tener exactamente 13 dígitos';
    END IF;

    -- Prefijos: entre 1 y 4 caracteres
    IF LENGTH(TRIM(wval_prefijofac)) < 1 OR LENGTH(TRIM(wval_prefijofac)) > 4 THEN
        RAISE EXCEPTION 'El prefijo de factura debe tener entre 1 y 4 caracteres';
    END IF;

    IF LENGTH(TRIM(wval_prefijocot)) < 1 OR LENGTH(TRIM(wval_prefijocot)) > 4 THEN
        RAISE EXCEPTION 'El prefijo de cotización debe tener entre 1 y 4 caracteres';
    END IF;

    -- Rangos de factura
    IF wval_facini <= 0 THEN
        RAISE EXCEPTION 'El valor inicial de factura debe ser mayor que 0';
    END IF;

    IF wval_facfin <= 0 THEN
        RAISE EXCEPTION 'El valor final de factura debe ser mayor que 0';
    END IF;

    IF wval_facfin <= wval_facini THEN
        RAISE EXCEPTION 'El valor final de factura debe ser mayor que el valor inicial';
    END IF;

    IF wval_facactual < wval_facini OR wval_facactual > wval_facfin THEN
        RAISE EXCEPTION 'El valor actual de factura debe estar entre el valor inicial y el final';
    END IF;

    -- Rangos de cotización
    IF wval_cotini <= 0 THEN
        RAISE EXCEPTION 'El valor inicial de cotización debe ser mayor que 0';
    END IF;

    IF wval_cotactual < wval_cotini THEN
        RAISE EXCEPTION 'El valor actual de cotización debe ser mayor o igual al valor inicial';
    END IF;

    -- Fechas de resolución
    IF wfec_venc < wfec_res_aut THEN
        RAISE EXCEPTION 'La fecha de vencimiento no puede ser anterior a la fecha de la resolución';
    END IF;

    -- Porcentajes (0-99 o 0-100 según el campo)
    IF wval_porreteica < 0 OR wval_porreteica > 99 THEN
        RAISE EXCEPTION 'El porcentaje de retención ICA debe estar entre 0 y 99';
    END IF;

    IF wval_intcorriente < 0 OR wval_intcorriente > 99 THEN
        RAISE EXCEPTION 'El porcentaje de interés corriente debe estar entre 0 y 99';
    END IF;

    IF wval_interesmora < 0 OR wval_interesmora > 100 THEN
        RAISE EXCEPTION 'El porcentaje de interés por mora debe estar entre 0 y 100';
    END IF;

    -- Pesos por puntos (mayor a 0)
    IF wval_pesosXpuntos <= 0 THEN
        RAISE EXCEPTION 'El valor de pesos por puntos debe ser mayor que 0';
    END IF;

    -- Días de cartera (0-180)
    IF wval_diascartera < 0 OR wval_diascartera > 180 THEN
        RAISE EXCEPTION 'El número de días de cartera debe estar entre 0 y 180';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO (PK)
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_pmtros_facturacion WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existen parámetros de facturación para la empresa %', wid_empresa;
    END IF;

    -- ACTUALIZACIÓN
    UPDATE tab_pmtros_facturacion
    SET val_res_aut       = wval_res_aut,
        fec_venc          = wfec_venc,
        fec_res_aut       = wfec_res_aut,
        val_prefijofac    = wval_prefijofac,
        val_facini        = wval_facini,
        val_facactual     = wval_facactual,
        val_facfin        = wval_facfin,
        val_prefijocot    = wval_prefijocot,
        val_cotini        = wval_cotini,
        val_cotactual     = wval_cotactual,
        val_porreteica    = wval_porreteica,
        val_intcorriente  = wval_intcorriente,
        val_pesosXpuntos  = wval_pesosXpuntos,
        val_interesmora   = wval_interesmora,
        val_diascartera   = wval_diascartera
    WHERE id_empresa = wid_empresa;
 
   RETURN TRUE;
 
        EXCEPTION
        WHEN OTHERS THEN
    RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
   
END;
$$ LANGUAGE plpgsql;