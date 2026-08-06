CREATE OR REPLACE FUNCTION fun_restore_pmtros_grales(wid_empresa public.tab_pmtros_grales.id_empresa%TYPE) RETURNS VOID AS 
$$
BEGIN

    -- Validación de nulo
    IF wid_empresa IS NULL THEN
        RAISE EXCEPTION 'El ID de la empresa no puede ser nulo';
    END IF;

    -- Validación de existencia y estado activo
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'La empresa con id % no existe o no está eliminada', wid_empresa;
    END IF;

    -- Borrado lógico
    UPDATE tab_pmtros_grales SET ind_borrado = FALSE 
    WHERE id_empresa = wid_empresa;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;