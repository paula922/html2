CREATE OR REPLACE FUNCTION fun_update_pmtros_grales(
    p_id_empresa DECIMAL,
    p_nom_empresa VARCHAR,
    p_datos_residencia DATOS_UBICACION,
    p_nom_replegal VARCHAR,
    p_val_poriva DECIMAL,
    p_val_pordesc DECIMAL,
    p_val_porrete DECIMAL,
    p_val_reteica DECIMAL,
    p_val_porutil DECIMAL,
    p_val_latitud DECIMAL,
    p_val_longitud DECIMAL,
    p_val_color_letra VARCHAR,
    p_val_color_logo VARCHAR,
    p_val_color_fondo VARCHAR,
    p_ind_autorete BOOLEAN
)
RETURNS TEXT AS $$
DECLARE
    v_anio_fiscal DECIMAL(4,0);
    v_mes_fiscal DECIMAL(2,0);
BEGIN
    -- Obtener año y mes actual
    v_anio_fiscal := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mes_fiscal := EXTRACT(MONTH FROM CURRENT_DATE);
    
    -- Verificar que exista el registro
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = p_id_empresa AND ind_borrado = FALSE) THEN
        RETURN 'ERROR: No existe la empresa especificada';
    END IF;
    
    -- Actualizar registro
    UPDATE tab_pmtros_grales SET
        nom_empresa = p_nom_empresa,
        datos_residencia = p_datos_residencia,
        nom_replegal = p_nom_replegal,
        val_poriva = p_val_poriva,
        val_pordesc = p_val_pordesc,
        val_porrete = p_val_porrete,
        val_reteica = p_val_reteica,
        val_porutil = p_val_porutil,
        val_latitud = p_val_latitud,
        val_longitud = p_val_longitud,
        val_color_letra = p_val_color_letra,
        val_color_logo = p_val_color_logo,
        val_color_fondo = p_val_color_fondo,
        anio_fiscal = v_anio_fiscal,
        mes_fiscal = v_mes_fiscal,
        ind_autorete = p_ind_autorete
    WHERE id_empresa = p_id_empresa AND ind_borrado = FALSE;
    
    RETURN 'OK: Empresa actualizada correctamente';
END;
$$ LANGUAGE plpgsql;
