CREATE OR REPLACE FUNCTION fun_delete_pmtros_grales(
    p_id_empresa DECIMAL
)
RETURNS TEXT AS $$
BEGIN
    -- Verificar que exista el registro
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = p_id_empresa AND ind_borrado = FALSE) THEN
        RETURN 'ERROR: No existe la empresa especificada';
    END IF;
    
    -- Borrado lógico
    UPDATE tab_pmtros_grales SET ind_borrado = TRUE WHERE id_empresa = p_id_empresa;
    
    RETURN 'OK: Empresa eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- 4. FUNCIÓN GET (Obtener todos los activos)
CREATE OR REPLACE FUNCTION fun_get_pmtros_grales()
RETURNS SETOF tab_pmtros_grales AS $$
BEGIN
    RETURN QUERY SELECT * FROM tab_pmtros_grales WHERE ind_borrado = FALSE ORDER BY id_empresa;
END;
$$ LANGUAGE plpgsql;