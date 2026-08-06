
CREATE OR REPLACE FUNCTION  fun_insert_formapago (wid_formapago tab_forma_pagos.id_formapago%TYPE,
											 	 wnom_formapago tab_forma_pagos.nom_formapago%TYPE) RETURNS TEXT AS
$$
	DECLARE wwid_formapago tab_forma_pagos.id_formapago%TYPE;
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
