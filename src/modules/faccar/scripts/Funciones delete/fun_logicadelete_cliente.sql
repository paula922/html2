CREATE OR REPLACE FUNCTION fun_logicadelete_cliente(wid_cliente tab_clientes.id_cliente%TYPE) RETURNS BOOLEAN AS
$$
    DECLARE wwid_cliente  tab_clientes.id_cliente%TYPE;
    BEGIN

-- VALIDAR LA LLAVE PRIMARIA
        IF NOT EXISTS ( SELECT 1 FROM tab_clientes WHERE id_cliente = wid_cliente AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'ERROR: El cliente ' || wid_cliente || ' no existe o ya está borrado.';
        END IF;
        UPDATE tab_clientes SET ind_estado = fALSE,ind_borrado = TRUE
                            WHERE id_cliente = wid_cliente;
                RETURN 'OK';
        
        EXCEPTION WHEN OTHERS THEN  RAISE EXCEPTION 'ERROR: ' || SQLERRM;
        END;
$$
language plpgsql;