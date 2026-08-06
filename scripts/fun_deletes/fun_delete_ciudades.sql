CREATE OR REPLACE FUNCTION fun_delete_ciudades(wid_ciudad  tab_ciudades.id_ciudad%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o ya fue eliminada', wid_ciudad;
    END IF;

    -- Verificar que no esté referenciada en terceros
    IF EXISTS (SELECT 1 FROM tab_terceros WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'No se puede eliminar la ciudad % porque está referenciada en terceros activos', wid_ciudad;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_ciudades SET ind_borrado = TRUE
    WHERE id_ciudad = wid_ciudad;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;