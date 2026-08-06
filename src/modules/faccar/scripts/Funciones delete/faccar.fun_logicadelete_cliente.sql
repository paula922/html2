CREATE OR REPLACE FUNCTION fun_logicadelete_cliente(wid_cliente tab_clientes.id_cliente%TYPE) RETURNS BOOLEAN AS
$$
    DECLARE wwid_cliente  tab_clientes.id_cliente%TYPE;
    BEGIN
    IF wid_cliente IS NULL OR TRIM(wid_cliente) = '' THEN
        RAISE EXCEPTION 'El ID del cliente no puede estar vacío';
    END IF;
    -- ID: mínimo 6 caracteres, solo letras y números
    IF LENGTH(TRIM(wid_cliente)) < 6 THEN
        RAISE EXCEPTION 'El ID del cliente debe tener mínimo 6 caracteres';
    END IF;

    IF wid_cliente !~ '^[A-Za-z0-9]+$' THEN
        RAISE EXCEPTION 'El ID del cliente solo puede contener letras y números';
    END IF;
-- VALIDAR LA LLAVE PRIMARIA
        IF NOT EXISTS ( SELECT 1 FROM tab_clientes WHERE id_cliente = wid_cliente AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'ERROR: El cliente ' || wid_cliente || ' no existe o ya está borrado.';
        END IF;
        UPDATE tab_clientes SET ind_estado = fALSE,ind_borrado = TRUE
                            WHERE id_cliente = wid_cliente;
                RETURN TRUE;      
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
$$
language plpgsql;