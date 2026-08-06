CREATE OR REPLACE FUNCTION fn_calcular_val_edad() RETURNS TRIGGER AS
$$
    BEGIN
        -- Calcular la edad a partir de la fecha de nacimiento
        NEW.val_edad = EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.fec_nacimi));
        IF NEW.val_edad < 16 THEN
            RAISE EXCEPTION 'La edad calculada (% años) es menor a 16. La fecha de nacimiento % es inválida.',
                NEW.val_edad, NEW.fec_nacimi;
        END IF;
        -- Regresa la nueva fila para que la operación (INSERT/UPDATE)
        -- se complete con el valor de edad ya calculado.
        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;

-- Trigger para calcular la edad del cliente
CREATE OR REPLACE TRIGGER trg_calcular_edad_clientes
BEFORE INSERT OR UPDATE OF fec_nacimi ON tab_clientes
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_val_edad();

-- Trigger para calcular la edad del vendedor
CREATE OR REPLACE TRIGGER trg_calcular_edad_vendedores
BEFORE INSERT OR UPDATE OF fec_nacimi ON tab_vendedores
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_val_edad();