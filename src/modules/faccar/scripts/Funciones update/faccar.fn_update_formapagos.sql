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