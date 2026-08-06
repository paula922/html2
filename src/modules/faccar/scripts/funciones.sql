 
-- ============================================================
-- INSERTAR CLIENTES
-- ============================================================
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
    -- VALIDACIONES DE NULO / VACÍO
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

    -- VALIDACIONES DE FORMATO Y RANGO
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

    -- VALIDACIÓN DE EXISTENCIA DE CLAVES FORÁNEAS
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_cliente) THEN
        RAISE EXCEPTION 'El id_cliente % no existe como tercero. Debe registrarse primero en la tabla de terceros.', wid_cliente;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad % no existe en tab_tipo_identidad.', wid_tipo;
    END IF;

    -- VALIDACIÓN DE DUPLICADO
    IF EXISTS (SELECT 1 FROM tab_clientes WHERE id_cliente = wid_cliente) THEN
        RAISE EXCEPTION 'Ya existe un cliente con el ID %', wid_cliente;
    END IF;

    -- INSERCIÓN
    -- El campo val_edad se deja como NULL porque el trigger lo calculará.
    -- Los campos adicionales (true, false) corresponden a los valores por defecto
    -- que estaban en la función original (ind_activo = true, ind_borrado = false).
    INSERT INTO tab_clientes
        (id_cliente, id_tipo, fec_nacimi, val_edad,
         ind_genero, val_puntos, ind_credito,
         val_cupocredito, val_diascartera,
         ind_activo, ind_borrado)
    VALUES
        (wid_cliente, wid_tipo, wfec_nacimi,0000,
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


-- ============================================================
-- UPDATE CLIENTES
-- ============================================================
CREATE OR REPLACE FUNCTION fn_update_cliente(  wid_cliente            tab_clientes.id_cliente%TYPE,
                                                        wid_tipo               tab_clientes.id_tipo%TYPE,
                                                        wfec_nacimi            tab_clientes.fec_nacimi%TYPE, -- El Trigger calcula val_edad
                                                        wind_genero            tab_clientes.ind_genero%TYPE,
                                                        wval_puntos            tab_clientes.val_puntos%TYPE,
                                                        wind_credito           tab_clientes.ind_credito%TYPE,
                                                        wval_cupocredito       tab_clientes.val_cupocredito%TYPE,
                                                        wval_diascartera       tab_clientes.val_diascartera%TYPE,
                                                        wind_estado            tab_clientes.ind_estado%TYPE)RETURNS BOOLEAN AS 
    $$
    DECLARE wwid_cliente tab_clientes.id_cliente%TYPE;
    BEGIN
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


    -- VALIDACIONES DE FORMATO Y RANGO

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

    -- VALIDACIÓN DE EXISTENCIA DE CLAVES FORÁNEAS
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_cliente) THEN
        RAISE EXCEPTION 'El id_cliente % no existe como tercero. Debe registrarse primero en la tabla de terceros.', wid_cliente;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad % no existe en tab_tipo_identidad.', wid_tipo;
    END IF;

-- ACTUALIZACIÓN (val_edad NO se asigna, el Trigger lo hará automáticamente)
        UPDATE tab_clientes SET
        id_tipo     	= wid_tipo,
        fec_nacimi      = wfec_nacimi,
        val_edad        = 0000, -- El Trigger calculará val_edad automáticamente
        ind_genero      = wind_genero,
        val_puntos      = wval_puntos,
        ind_credito     = wind_credito,
        val_cupocredito = wval_cupocredito,
        val_diascartera = wval_diascartera,
        ind_estado      = wind_estado 
       WHERE id_cliente = wid_cliente;
        RETURN TRUE;

        EXCEPTION
        WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
           END;
$$ 
LANGUAGE plpgsql;

-- ============================================================
-- DELETE CLIENTES
-- ============================================================
CREATE OR REPLACE FUNCTION fun_logicadelete_cliente(wid_cliente tab_clientes.id_cliente%TYPE) RETURNS BOOLEAN AS
$$
    BEGIN
-- VALIDAR LA LLAVE PRIMARIA
        IF NOT EXISTS ( SELECT 1 FROM tab_clientes WHERE id_cliente = wid_cliente AND ind_borrado = FALSE) THEN
       RAISE EXCEPTION 'ERROR: El cliente % no existe', wid_cliente;
	   END IF;
        UPDATE tab_clientes SET ind_estado = fALSE,ind_borrado = TRUE
                            WHERE id_cliente = wid_cliente;
                return true;
        EXCEPTION
        WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
           END;
$$
language plpgsql;

-- -- ============================================================
-- -- INSERT DE VENDEDOR
-- -- ============================================================
CREATE OR REPLACE FUNCTION fun_insertar_vendedor(
    wid_vendedor       tab_vendedores.id_vendedor%TYPE,
    wval_porcomision   tab_vendedores.val_porcomision%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO / FORMATO
    IF wid_vendedor IS NULL OR TRIM(wid_vendedor) = '' THEN
        RAISE EXCEPTION 'El ID del vendedor no puede estar vacío';
    END IF;
    IF LENGTH(TRIM(wid_vendedor)) < 6 THEN
        RAISE EXCEPTION 'El ID del vendedor debe tener mínimo 6 caracteres';
    END IF;
    IF wid_vendedor !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del vendedor solo puede contener letras y números';
    END IF;

    -- VALIDACIÓN DE DUPLICADO (en la misma tabla)
    IF EXISTS (SELECT 1 FROM tab_vendedores WHERE id_vendedor = wid_vendedor) THEN
        RAISE EXCEPTION 'El vendedor con ID % ya existe', wid_vendedor;
    END IF;

    -- VALIDACIÓN DE EXISTENCIA COMO EMPLEADO ACTIVO
    -- Y QUE SU CARGO SEA "VENDEDOR" (según tab_cargos)
    IF NOT EXISTS (
        SELECT 1
        FROM tab_empleados e
        JOIN tab_cargos c ON e.id_cargo = c.id_cargo
        WHERE e.id_empleado = wid_vendedor
          AND e.ind_estado = TRUE
          AND UPPER(TRIM(c.nom_cargo)) = 'VENDEDOR'   -- Ajusta 'VENDEDOR' si en tu BD se escribe diferente (ej. 'Vendedor')
    ) THEN
        RAISE EXCEPTION 'El empleado # % no está activo o no tiene el cargo de Vendedor', wid_vendedor;
    END IF;

    -- VALIDACIONES DE COMISIÓN
    IF wval_porcomision IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de comisión no puede ser nulo';
    END IF;

    IF wval_porcomision < 1 OR wval_porcomision > 99 THEN
        RAISE EXCEPTION 'El porcentaje de comisión debe estar entre 1 y 99';
    END IF;

    -- INSERCIÓN
    INSERT INTO tab_vendedores
        (id_vendedor, val_porcomision, val_comisionactual, ind_estado, ind_borrado)
    VALUES
        (wid_vendedor, wval_porcomision, 0, TRUE, FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;


-- -- ============================================================
-- -- UPDATE DE VENDEDOR
-- -- ============================================================
CREATE OR REPLACE FUNCTION fun_update_vendedor(wid_vendedor tab_vendedores.id_vendedor%TYPE, wval_porcomision  tab_vendedores.val_porcomision%TYPE, wind_estado tab_vendedores.ind_estado%TYPE)RETURNS BOOLEAN AS
$$
    BEGIN
        -- VALIDACIONES DE NEGOCIO
        IF wid_vendedor IS NULL OR TRIM(wid_vendedor) = '' THEN
        RAISE EXCEPTION 'El ID del vendedor no puede estar vacío';
    END IF;
    IF LENGTH(TRIM(wid_vendedor)) < 6 THEN
        RAISE EXCEPTION 'El ID del vendedor debe tener mínimo 6 caracteres';
    END IF;
    IF wid_vendedor !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del vendedor solo puede contener letras y números';
    END IF;

    -- VALIDACIÓN DE DUPLICADO (en la misma tabla)
    IF NOT EXISTS (SELECT 1 FROM tab_vendedores WHERE id_vendedor = wid_vendedor) THEN
        RAISE EXCEPTION 'NO existe el vendedor %', wid_vendedor;
    END IF;

    -- VALIDACIÓN DE EXISTENCIA COMO EMPLEADO ACTIVO
    -- Y QUE SU CARGO SEA "VENDEDOR" (según tab_cargos)
    IF NOT EXISTS ( SELECT 1 FROM tab_empleados e
        JOIN tab_cargos c ON e.id_cargo = c.id_cargo
        WHERE e.id_empleado = wid_vendedor
          AND e.ind_estado = TRUE
          AND UPPER(TRIM(c.nom_cargo)) = 'VENDEDOR'   -- Ajusta 'VENDEDOR' si en tu BD se escribe diferente (ej. 'Vendedor')
    ) THEN
        RAISE EXCEPTION 'El empleado # % no está activo o no tiene el cargo de Vendedor', wid_vendedor;
    END IF;

    -- VALIDACIONES DE COMISIÓN
    IF wval_porcomision IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de comisión no puede ser nulo';
    END IF;
    IF wval_porcomision < 1 OR wval_porcomision > 99 THEN
        RAISE EXCEPTION 'El porcentaje de comisión debe estar entre 1 y 99';
    END IF;
         UPDATE tab_vendedores SET 
            val_porcomision = wval_porcomision,
            ind_estado = wind_estado
            WHERE id_vendedor = wid_vendedor;

            RETURN TRUE;

        EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM); 
    END;
$$ 
LANGUAGE plpgsql;


-- -- ============================================================
-- -- DELETE DE VENDEDOR
-- -- ============================================================
CREATE OR REPLACE FUNCTION fun_delete_vendedor(
    wid_vendedor tab_vendedores.id_vendedor%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO
    IF wid_vendedor IS NULL OR TRIM(wid_vendedor) = '' THEN
        RAISE EXCEPTION 'El ID del vendedor no puede estar vacío';
    END IF;
    -- VALIDACIONES DE FORMATO
    IF LENGTH(TRIM(wid_vendedor)) < 6 THEN
        RAISE EXCEPTION 'El ID del vendedor debe tener mínimo 6 caracteres';
    END IF;
    IF wid_vendedor !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del vendedor solo puede contener letras y números';
    END IF;
    -- VALIDACIÓN DE EXISTENCIA
    IF NOT EXISTS (
        SELECT 1 FROM tab_vendedores
        WHERE id_vendedor = wid_vendedor
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El vendedor con ID % no existe o ya fue eliminado', wid_vendedor;
    END IF;
    -- BORRADO LÓGICO
    UPDATE tab_vendedores
    SET ind_borrado = TRUE
    WHERE id_vendedor = wid_vendedor;
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;

-- ============================================================
-- INSERT DE PARAMETROS
-- ============================================================
CREATE OR REPLACE FUNCTION fun_insert_pmtros_facturacion(
    wid_empresa         tab_pmtros_facturacion.id_empresa%TYPE,
    wval_res_aut        tab_pmtros_facturacion.val_res_aut%TYPE,
    wfec_venc           tab_pmtros_facturacion.fec_venc%TYPE,
    wfec_res_aut        tab_pmtros_facturacion.fec_res_aut%TYPE,
    wval_prefijofac     tab_pmtros_facturacion.val_prefijofac%TYPE,
    wval_facini         tab_pmtros_facturacion.val_facini%TYPE,
    wval_facactual      tab_pmtros_facturacion.val_facactual%TYPE,
    wval_facfin         tab_pmtros_facturacion.val_facfin%TYPE,
    wval_prefijocot     tab_pmtros_facturacion.val_prefijocot%TYPE,
    wval_cotini         tab_pmtros_facturacion.val_cotini%TYPE,
    wval_cotactual      tab_pmtros_facturacion.val_cotactual%TYPE,
    wval_porreteica     tab_pmtros_facturacion.val_porreteica%TYPE,
    wval_intcorriente   tab_pmtros_facturacion.val_intcorriente%TYPE,
    wval_pesosXpuntos   tab_pmtros_facturacion.val_pesosXpuntos%TYPE,
    wval_interesmora    tab_pmtros_facturacion.val_interesmora%TYPE,
    wval_diascartera    tab_pmtros_facturacion.val_diascartera%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO
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

    -- VALIDACIONES DE FORMATO Y RANGO
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

    -- VALIDACIÓN DE DUPLICADO (PK)
    IF EXISTS (SELECT 1 FROM tab_pmtros_facturacion WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existen parámetros de facturación para la empresa %', wid_empresa;
    END IF;

    -- INSERCIÓN
    INSERT INTO tab_pmtros_facturacion 
    VALUES (
        wid_empresa,
        wval_res_aut,
        wfec_venc,
        wfec_res_aut,
        wval_prefijofac,
        wval_facini,
        wval_facactual,
        wval_facfin,
        wval_prefijocot,
        wval_cotini,
        wval_cotactual,
        wval_porreteica,
        wval_intcorriente,
        wval_pesosXpuntos,
        wval_interesmora,
        wval_diascartera
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;

-- ============================================================
-- UPDATE DE PARAMETROS
-- ============================================================
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
    -- VALIDACIONES DE NULO / VACÍO
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

    -- VALIDACIONES DE FORMATO Y RANGO
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

    -- 
    -- VALIDACIÓN DE DUPLICADO (PK)
    -- 
    IF not EXISTS (SELECT 1 FROM tab_pmtros_facturacion WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'No existen parámetros de facturación para la empresa %', wid_empresa;
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
-- ============================================================
-- DELETE DE PARAMETROS
-- ============================================================
CREATE OR REPLACE FUNCTION fun_delete_pmtros_facturacion(
    wid_empresa tab_pmtros_facturacion.id_empresa%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    -- VALIDACIONES DE FORMATO
    -- id_empresa es VARCHAR(10); validamos longitud mínima 1
    IF LENGTH(TRIM(wid_empresa)) < 1 OR LENGTH(TRIM(wid_empresa)) > 10 THEN
        RAISE EXCEPTION 'El ID de la empresa debe tener entre 1 y 10 caracteres';
    END IF;

    -- VALIDACIÓN DE EXISTENCIA
    IF NOT EXISTS (
        SELECT 1 FROM tab_pmtros_facturacion
        WHERE id_empresa = wid_empresa
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'Los parámetros de facturación para la empresa % no existen o ya fueron eliminados', wid_empresa;
    END IF;

    -- BORRADO LÓGICO
    UPDATE tab_pmtros_facturacion
    SET ind_borrado = TRUE
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;
-- ============================================================
-- INSERT DE MOTIVO NOTA
-- ============================================================
CREATE OR REPLACE FUNCTION fun_insertar_motivo_nota(
    wid_motivo_nota tab_motivo_nota.id_motivo_nota%TYPE,  -- DECIMAL(3,0) > 0
    wind_tipo_nota  tab_motivo_nota.ind_tipo_nota%TYPE,   -- BOOLEAN (FALSE=Crédito, TRUE=Débito)
    wcod_dian       tab_motivo_nota.cod_dian%TYPE,        -- DECIMAL(1,0) entre 1 y 6
    wnom_motivo     tab_motivo_nota.nom_motivo%TYPE       -- VARCHAR(100) min 5 chars
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO / RANGO BÁSICO
    IF wid_motivo_nota IS NULL OR wid_motivo_nota <= 0 THEN
        RAISE EXCEPTION 'El ID del motivo de nota debe ser mayor a 0 .';
    END IF;

    IF wind_tipo_nota IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de nota (Crédito/Débito) no puede ser nulo.';
    END IF;

    IF wcod_dian IS NULL OR wcod_dian < 1 OR wcod_dian > 6 THEN
        RAISE EXCEPTION 'El código DIAN debe estar entre 1 y 6.';
    END IF;

    -- Aplicar la restricción de negocio: débito solo usa códigos 1-3
    IF wind_tipo_nota = TRUE AND (wcod_dian < 1 OR wcod_dian > 3) THEN
        RAISE EXCEPTION 'Para nota Débito, el código DIAN debe estar entre 1 y 3.';
    END IF;

    IF wnom_motivo IS NULL OR LENGTH(TRIM(wnom_motivo)) < 5 THEN
        RAISE EXCEPTION 'La descripción del motivo debe tener mínimo 5 caracteres.';
    END IF;

    -- VALIDACIÓN DE DUPLICADOS
    -- Llave primaria
    IF EXISTS (SELECT 1 FROM tab_motivo_nota WHERE id_motivo_nota = wid_motivo_nota) THEN
        RAISE EXCEPTION 'El motivo de nota con ID % ya existe.', wid_motivo_nota;
    END IF;

    -- Unicidad de la combinación código DIAN + tipo de nota
    IF EXISTS (
        SELECT 1 FROM tab_motivo_nota
        WHERE cod_dian = wcod_dian
          AND ind_tipo_nota = wind_tipo_nota
    ) THEN
        RAISE EXCEPTION 'El código DIAN % ya está asignado para el tipo de nota %'
            , wcod_dian, CASE WHEN wind_tipo_nota THEN 'Débito' ELSE 'Crédito' END;
    END IF;

    -- INSERCIÓN
    INSERT INTO tab_motivo_nota
    VALUES (
        wid_motivo_nota,
        wind_tipo_nota,
        wcod_dian,
        wnom_motivo,
        FALSE, FALSE, FALSE, FALSE, TRUE, FALSE
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;


-- ============================================================
-- UPDATE MOTIVO NOTA
-- ============================================================
CREATE OR REPLACE FUNCTION fun_update_motivo_nota(wid_motivo_nota     tab_motivo_nota.id_motivo_nota%TYPE,
                                                      wind_tipo_nota      tab_motivo_nota.ind_tipo_nota%TYPE,
                                                      wcod_dian           tab_motivo_nota.cod_dian%TYPE,
                                                      wnom_motivo         tab_motivo_nota.nom_motivo%TYPE,
                                                      wafecta_inventario  tab_motivo_nota.afecta_inventario%TYPE,
                                                      wafecta_cliente     tab_motivo_nota.afecta_cliente%TYPE,
                                                      wafecta_cartera     tab_motivo_nota.afecta_cartera%TYPE,
                                                      wafecta_comision    tab_motivo_nota.afecta_comision%TYPE)RETURNS BOOLEAN AS 
$$
BEGIN
    -- VALIDACIONES DE NULO / VACÍO / RANGO BÁSICO
    IF wid_motivo_nota IS NULL OR wid_motivo_nota <= 0 THEN
        RAISE EXCEPTION 'El ID del motivo de nota debe ser mayor a 0.';
    END IF;

    IF wind_tipo_nota IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de nota (Crédito/Débito) no puede ser nulo.';
    END IF;

    IF wcod_dian IS NULL OR wcod_dian < 1 OR wcod_dian > 6 THEN
        RAISE EXCEPTION 'El código DIAN debe estar entre 1 y 6.';
    END IF;

    -- Aplicar la restricción de negocio: débito solo usa códigos 1-3
    IF wind_tipo_nota = TRUE AND (wcod_dian < 1 OR wcod_dian > 3) THEN
        RAISE EXCEPTION 'Para nota Débito, el código DIAN debe estar entre 1 y 3.';
    END IF;

    IF wnom_motivo IS NULL OR LENGTH(TRIM(wnom_motivo)) < 5 THEN
        RAISE EXCEPTION 'La descripción del motivo debe tener mínimo 5 caracteres.';
    END IF;

    -- VALIDACIÓN DE DUPLICADOS
    -- Llave primaria
    IF NOT EXISTS (SELECT 1 FROM tab_motivo_nota WHERE id_motivo_nota = wid_motivo_nota) THEN
        RAISE EXCEPTION 'No existe el motivo de nota con ID %.', wid_motivo_nota;
    END IF;

    -- Unicidad de la combinación código DIAN + tipo de nota
    IF EXISTS (
    SELECT 1
    FROM tab_motivo_nota
    WHERE cod_dian = wcod_dian
      AND ind_tipo_nota = wind_tipo_nota
      AND id_motivo_nota <> wid_motivo_nota
) THEN
    RAISE EXCEPTION
        'El código DIAN % ya está asignado para el tipo de nota %',
        wcod_dian,
        CASE
            WHEN wind_tipo_nota THEN 'Débito'
            ELSE 'Crédito'
        END;
END IF;

    UPDATE tab_motivo_nota
    SET ind_tipo_nota      = wind_tipo_nota,
        cod_dian           = wcod_dian,
        nom_motivo         = wnom_motivo,
        afecta_inventario  = wafecta_inventario,
        afecta_cliente     = wafecta_cliente,
        afecta_cartera     = wafecta_cartera,
        afecta_comision    = wafecta_comision
    WHERE id_motivo_nota = wid_motivo_nota;
 
    RETURN TRUE;
 
EXCEPTION
        WHEN OTHERS THEN
    RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
       
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- DELETE MOTIVO NOTA
-- ============================================================
CREATE OR REPLACE FUNCTION fun_delete_motivo_nota(
    wid_motivo_nota tab_motivo_nota.id_motivo_nota%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / RANGO BÁSICO
    IF wid_motivo_nota IS NULL OR wid_motivo_nota <= 0 THEN
        RAISE EXCEPTION 'El ID del motivo de nota debe ser mayor a 0.';
    END IF;

    -- VALIDACIÓN DE EXISTENCIA
    IF NOT EXISTS (
        SELECT 1 FROM tab_motivo_nota
        WHERE id_motivo_nota = wid_motivo_nota
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El motivo de nota con ID % no existe o ya fue eliminado', wid_motivo_nota;
    END IF;

    -- BORRADO LÓGICO
    UPDATE tab_motivo_nota
    SET ind_borrado = TRUE
    WHERE id_motivo_nota = wid_motivo_nota;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;

-- ============================================================
-- INSERT FORMA DE PAGOS
-- ============================================================

CREATE OR REPLACE FUNCTION  fun_insert_formapago (wid_formapago tab_forma_pagos.id_formapago%TYPE,
											 	 wnom_formapago tab_forma_pagos.nom_formapago%TYPE) RETURNS BOOLEAN AS
$$
	BEGIN

  -- VALIDACIONES DE NULO / VACÍO
    IF wid_formapago IS NULL THEN
        RAISE EXCEPTION 'El ID de la forma de pago no puede ser nulo';
    END IF;
 
    IF wnom_formapago IS NULL OR TRIM(wnom_formapago) = '' THEN
        RAISE EXCEPTION 'El nombre de la forma de pago no puede estar vacío';
    END IF;
 
    -- VALIDACIONES DE FORMATO Y RANGO
    IF wid_formapago < 0 OR wid_formapago > 9 THEN
        RAISE EXCEPTION 'El ID de la forma de pago debe estar entre 0 y 9';
    END IF;
 
    IF LENGTH(TRIM(wnom_formapago)) < 3 THEN
        RAISE EXCEPTION 'El nombre de la forma de pago debe tener mínimo 3 caracteres';
    END IF;
 
    -- VALIDACIÓN DE DUPLICADO
    IF EXISTS (SELECT 1 FROM tab_forma_pagos WHERE id_formapago = wid_formapago) THEN
        RAISE EXCEPTION 'La forma de pago ID % ya existe', wid_formapago;
    END IF;
 
    -- INSERCIÓN
    INSERT INTO tab_forma_pagos (
        id_formapago, nom_formapago, ind_borrado
    )
    VALUES (
        wid_formapago, wnom_formapago, FALSE
    );
 
    RETURN TRUE;
 
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- UPDATE FORMA DE PAGOS
-- ============================================================
CREATE OR REPLACE FUNCTION fn_update_formapagos(
    wid_formapago tab_forma_pagos.id_formapago%TYPE,
    wnom_formapago tab_forma_pagos.nom_formapago%TYPE
) RETURNS BOOLEAN AS $$
BEGIN
    -- Validaciones de nulo / vacío
    IF wid_formapago IS NULL THEN
        RAISE EXCEPTION 'El ID de la forma de pago no puede ser nulo';
    END IF;
    
    IF wnom_formapago IS NULL OR TRIM(wnom_formapago) = '' THEN
        RAISE EXCEPTION 'El nombre de la forma de pago no puede estar vacío';
    END IF;
    
    -- Validaciones de formato y rango
    IF wid_formapago < 0 OR wid_formapago > 9 THEN
        RAISE EXCEPTION 'El ID de la forma de pago debe estar entre 0 y 9';
    END IF;
    
    IF LENGTH(TRIM(wnom_formapago)) < 3 THEN
        RAISE EXCEPTION 'El nombre de la forma de pago debe tener mínimo 3 caracteres';
    END IF;
    
    -- Verificar que el registro exista (no que NO exista)
    IF NOT EXISTS (SELECT 1 FROM tab_forma_pagos WHERE id_formapago = wid_formapago) THEN
        RAISE EXCEPTION 'La forma de pago con ID % no existe', wid_formapago;
    END IF;
    
    -- Actualizar
    UPDATE tab_forma_pagos 
    SET nom_formapago = wnom_formapago
    WHERE id_formapago = wid_formapago;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- DELETE FORMA DE PAGOS
-- ============================================================
CREATE OR REPLACE FUNCTION fun_delete_formapago(
    wid_formapago tab_forma_pagos.id_formapago%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- VALIDACIONES DE NULO / RANGO BÁSICO
    IF wid_formapago IS NULL THEN
        RAISE EXCEPTION 'El ID de forma de pago no puede ser nulo.';
    END IF;

    IF wid_formapago < 0 OR wid_formapago > 9 THEN
        RAISE EXCEPTION 'El ID de forma de pago debe estar entre 0 y 9.';
    END IF;

    -- VALIDACIÓN DE EXISTENCIA
    IF NOT EXISTS (
        SELECT 1 FROM tab_forma_pagos
        WHERE id_formapago = wid_formapago
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'La forma de pago con ID % no existe o ya fue eliminada', wid_formapago;
    END IF;

    -- BORRADO LÓGICO
    UPDATE tab_forma_pagos
    SET ind_borrado = TRUE
    WHERE id_formapago = wid_formapago;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE plpgsql;

-- ============================================================
-- TRIGGER PARA CALCULAR LA EDAD DEL CLIENTE
-- ============================================================
CREATE OR REPLACE FUNCTION fn_calcular_val_edad()RETURNS TRIGGER AS 
$$
    BEGIN
       --Calcular la edad a partir de la fecha de nacimiento
        NEW.val_edad = EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.fec_nacimi));

        -- Validaciones de edad mínima
        IF NEW.val_edad < 16 THEN
            RAISE NOTICE '¡ERROR DE VALIDACIÓN! La edad calculada (% años) es menor a 16. La fecha de nacimiento % es inválida.', NEW.val_edad, NEW.fec_nacimi;
            RETURN NULL;
        END IF;

        -- Regresa la nueva fila para que la operación (INSERT/UPDATE) se complete con el valor de edad calculado.
        RETURN NEW;
    END;
$$ 
LANGUAGE plpgsql;

--Trigger para calcular la edad del cliente 
CREATE OR REPLACE TRIGGER trg_calcular_edad_clientes
BEFORE INSERT OR UPDATE OF fec_nacimi ON tab_clientes
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_val_edad();