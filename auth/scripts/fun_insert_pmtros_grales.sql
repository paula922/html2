CREATE OR REPLACE FUNCTION fun_insert_pmtros_grales(
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
    
    -- Validar que no exista ya un registro con ese ID
    IF EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = p_id_empresa AND ind_borrado = FALSE) THEN
        RETURN 'ERROR: Ya existe una empresa con este ID';
    END IF;
    
    -- Insertar nuevo registro
    INSERT INTO tab_pmtros_grales (
        id_empresa, nom_empresa, datos_residencia, nom_replegal,
        val_poriva, val_pordesc, val_porrete, val_reteica, val_porutil,
        val_latitud, val_longitud, val_color_letra, val_color_logo, val_color_fondo,
        anio_fiscal, mes_fiscal, ind_autorete, ind_borrado
    ) VALUES (
        p_id_empresa, p_nom_empresa, p_datos_residencia, p_nom_replegal,
        p_val_poriva, p_val_pordesc, p_val_porrete, p_val_reteica, p_val_porutil,
        p_val_latitud, p_val_longitud, p_val_color_letra, p_val_color_logo, p_val_color_fondo,
        v_anio_fiscal, v_mes_fiscal, p_ind_autorete, FALSE
    );
    
    RETURN 'OK: Empresa registrada correctamente';
END;
$$ LANGUAGE plpgsql;