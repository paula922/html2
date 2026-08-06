CREATE OR REPLACE FUNCTION fun_delete_formapago(
    wid_formapago tab_forma_pagos.id_formapago%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / RANGO BÁSICO
    -- =============================================
    IF wid_formapago IS NULL THEN
        RAISE EXCEPTION 'El ID de forma de pago no puede ser nulo.';
    END IF;

    IF wid_formapago < 0 OR wid_formapago > 9 THEN
        RAISE EXCEPTION 'El ID de forma de pago debe estar entre 0 y 9.';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (
        SELECT 1 FROM tab_forma_pagos
        WHERE id_formapago = wid_formapago
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'La forma de pago con ID % no existe o ya fue eliminada', wid_formapago;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
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