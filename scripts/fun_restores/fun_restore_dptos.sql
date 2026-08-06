-- SELECT fun_restore_dptos('05')

CREATE OR REPLACE FUNCTION fun_restore_dptos(wid_dpto public.tab_dptos.id_dpto%TYPE) RETURNS VOID AS 
$$
BEGIN

    -- Validación de nulo
	IF wid_dpto IS NULL THEN
		RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
	END IF;

    -- Validar que el atributo sea numérico
	IF wid_dpto !~ '^[0-9]{2}$' THEN
		RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
	END IF;

    -- Validar existencia del departamento
    IF NOT EXISTS (SELECT 1 FROM public.tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'El departamento con id % no existe o no está eliminado', wid_dpto;
    END IF;
	
    -- restaurar lógico
    UPDATE public.tab_dptos SET ind_borrado = FALSE
    WHERE id_dpto = wid_dpto;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


