CREATE OR REPLACE FUNCTION fun_update_vendedor(wid_vendedor tab_vendedores.id_vendedor%TYPE, wval_porcomision  tab_vendedores.val_porcomision%TYPE, wind_estado tab_vendedores.ind_estado%TYPE)RETURNS BOOLEAN AS
$$
    DECLARE wwid_vendedor  tab_vendedores.id_vendedor%TYPE;
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

        -- =============================================
    -- VALIDACIÓN DE DUPLICADO (en la misma tabla)
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_vendedores WHERE id_vendedor = wid_vendedor) THEN
        RAISE EXCEPTION 'El vendedor con ID % no existe', wid_vendedor;
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA COMO EMPLEADO ACTIVO
    -- Y QUE SU CARGO SEA "VENDEDOR" (según tab_cargos)
    -- =============================================
    IF NOT EXISTS ( SELECT 1 FROM tab_empleados e
        JOIN tab_cargos c ON e.id_cargo = c.id_cargo
        WHERE e.id_empleado = wid_vendedor
          AND e.ind_estado = TRUE
          AND UPPER(TRIM(c.nom_cargo)) = 'VENDEDOR'   -- Ajusta 'VENDEDOR' si en tu BD se escribe diferente (ej. 'Vendedor')
    ) THEN
        RAISE EXCEPTION 'El empleado # % no está activo o no tiene el cargo de Vendedor', wid_vendedor;
    END IF;

    -- =============================================
    -- VALIDACIONES DE COMISIÓN
    -- =============================================
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