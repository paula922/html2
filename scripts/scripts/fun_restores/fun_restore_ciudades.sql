-- INSERT INTO tab_dptos VALUES ('05','Antioquia')
-- SELECT * FROM tab_dptos
-- SELECT * FROM tab_ciudades
-- SELECT fun_restore_ciudades('05001')

CREATE OR REPLACE FUNCTION fun_restore_ciudades(wid_ciudad	public.tab_ciudades.id_ciudad%TYPE) RETURNS VOID AS 
$$
DECLARE wwid_ciudad public.tab_ciudades.id_ciudad%TYPE;

BEGIN

	-- Validación de nulo
	IF wid_ciudad IS NULL THEN
		RAISE EXCEPTION 'El ID de la ciudad no puede ser nula';
	END IF;

	-- Validar que el atributo sea numérico
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de 5 dígitos.';
    END IF;

	-- Validar existencia de la ciudad
    IF NOT EXISTS (SELECT 1 FROM public.tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'La ciudad con id % no existe o no está eliminada', wid_ciudad;
    END IF;
	
    -- restaurar lógico
	UPDATE public.tab_ciudades SET ind_borrado = FALSE
	WHERE id_ciudad = wid_ciudad;
		
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;