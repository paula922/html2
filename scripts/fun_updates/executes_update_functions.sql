CREATE OR REPLACE FUNCTION fun_update_areas(wid_area            tab_areas.id_area%TYPE,
                                            wid_responsable     tab_areas.id_responsable%TYPE,
                                            wnom_area           tab_areas.nom_area%TYPE,
                                            wdescrip_area       tab_areas.descrip_area%TYPE,
                                            wmail_area          tab_areas.mail_area%TYPE,
                                            wtel_oficina        tab_areas.tel_oficina%TYPE,
                                            wubi_oficina        tab_areas.ubi_oficina%TYPE,
                                            whorario_atencion   tab_areas.horario_atencion%TYPE,
                                            wind_estado         tab_areas.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_area IS NULL THEN
        RAISE EXCEPTION 'El ID del área no puede ser nulo';
    END IF;

    IF wid_responsable IS NULL OR TRIM(wid_responsable) = '' THEN
        RAISE EXCEPTION 'El responsable del área no puede estar vacío';
    END IF;

    IF wnom_area IS NULL OR TRIM(wnom_area) = '' THEN
        RAISE EXCEPTION 'El nombre del área no puede estar vacío';
    END IF;

    IF wmail_area IS NULL OR TRIM(wmail_area) = '' THEN
        RAISE EXCEPTION 'El email del área no puede estar vacío';
    END IF;

    IF wtel_oficina IS NULL THEN
        RAISE EXCEPTION 'El teléfono de la oficina no puede ser nulo';
    END IF;

    IF wubi_oficina IS NULL OR TRIM(wubi_oficina) = '' THEN
        RAISE EXCEPTION 'La ubicación de la oficina no puede estar vacía';
    END IF;

    IF whorario_atencion IS NULL OR TRIM(whorario_atencion) = '' THEN
        RAISE EXCEPTION 'El horario de atención no puede estar vacío';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    IF LENGTH(wid_responsable) < 5 THEN
        RAISE EXCEPTION 'El ID del responsable debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wnom_area) < 3 THEN
        RAISE EXCEPTION 'El nombre del área debe tener mínimo 3 caracteres';
    END IF;

    IF wmail_area !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$' THEN
        RAISE EXCEPTION 'El email del área no tiene un formato válido';
    END IF;

    IF wtel_oficina < 0 OR wtel_oficina >= 9999999999 THEN
        RAISE EXCEPTION 'El teléfono debe estar entre 0 y 9999999999';
    END IF;

    IF LENGTH(wubi_oficina) < 3 THEN
        RAISE EXCEPTION 'La ubicación de la oficina debe tener mínimo 3 caracteres';
    END IF;

    IF LENGTH(whorario_atencion) < 3 THEN
        RAISE EXCEPTION 'El horario de atención debe tener mínimo 3 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El área con ID % no existe o está inactiva', wid_area;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_responsable AND ind_estado = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El responsable % no existe o está inactivo', wid_responsable;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_areas SET id_responsable   = wid_responsable,
                         nom_area         = wnom_area,
                         descrip_area     = COALESCE(NULLIF(TRIM(wdescrip_area), ''), 'Sin descripción de área'),
                         mail_area        = wmail_area,
                         tel_oficina      = wtel_oficina,
                         ubi_oficina      = wubi_oficina,
                         horario_atencion = whorario_atencion,
                         ind_estado       = wind_estado
    WHERE id_area = wid_area;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_bancos(wid_banco       tab_bancos.id_banco%TYPE,
                                             wnom_banco      tab_bancos.nom_banco%TYPE,
                                             wind_estado     tab_bancos.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    IF wnom_banco IS NULL OR TRIM(wnom_banco) = '' THEN
        RAISE EXCEPTION 'El nombre del banco no puede estar vacío';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    IF LENGTH(wnom_banco) < 4 OR LENGTH(wnom_banco) > 50 THEN
        RAISE EXCEPTION 'El nombre del banco debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o está inactivo', wid_banco;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_bancos SET nom_banco  = wnom_banco,
                          ind_estado = wind_estado
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_cat_terceros(wid_cat_tercero     tab_cat_terceros.id_cat_tercero%TYPE,
                                                   wnom_cat_tercero    tab_cat_terceros.nom_cat_tercero%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_cat_tercero IS NULL OR TRIM(wnom_cat_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre de la categoría no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_cat_tercero) < 4 OR LENGTH(wnom_cat_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre de la categoría debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_cat_tercero !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la categoría solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_cat_terceros SET nom_cat_tercero = wnom_cat_tercero
    WHERE id_cat_tercero = wid_cat_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_ciudades(wid_ciudad      tab_ciudades.id_ciudad%TYPE,
                                               wnom_ciudad     tab_ciudades.nom_ciudad%TYPE,
                                               wid_dpto        tab_ciudades.id_dpto%TYPE,
                                               wind_capital    tab_ciudades.ind_capital%TYPE,
                                               wcod_postal     tab_ciudades.cod_postal%TYPE,
                                               wval_latitud    tab_ciudades.val_latitud%TYPE,
                                               wval_longitud   tab_ciudades.val_longitud%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wnom_ciudad IS NULL OR TRIM(wnom_ciudad) = '' THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede estar vacío';
    END IF;

    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL OR TRIM(wcod_postal) = '' THEN
        RAISE EXCEPTION 'El código postal no puede estar vacío';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios';
    END IF;

    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de exactamente 6 dígitos (ej: 050001)';
    END IF;

    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- Solo puede haber una capital por departamento (excluyendo la ciudad actual)
    IF wind_capital = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_dpto = wid_dpto AND ind_capital = TRUE AND ind_borrado = FALSE AND id_ciudad <> wid_ciudad) THEN
            RAISE EXCEPTION 'El departamento % ya tiene una ciudad capital registrada', wid_dpto;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_ciudades SET nom_ciudad  = wnom_ciudad,
                            id_dpto     = wid_dpto,
                            ind_capital = wind_capital,
                            cod_postal  = wcod_postal,
                            val_latitud = wval_latitud,
                            val_longitud = wval_longitud
    WHERE id_ciudad = wid_ciudad;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_dptos(wid_dpto    tab_dptos.id_dpto%TYPE,
                                            wnom_dpto   tab_dptos.nom_dpto%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wnom_dpto IS NULL OR TRIM(wnom_dpto) = '' THEN
        RAISE EXCEPTION 'El nombre del departamento no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    IF LENGTH(wnom_dpto) < 4 OR LENGTH(wnom_dpto) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_dptos SET nom_dpto = wnom_dpto
    WHERE id_dpto = wid_dpto;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_menu_palettes(wid_palette             tab_menu_palettes.id_palette%TYPE,
                                                    wnom_palette            tab_menu_palettes.nom_palette%TYPE,
                                                    wdes_palette            tab_menu_palettes.des_palette%TYPE,
                                                    wval_primary_color      tab_menu_palettes.val_primary_color%TYPE,
                                                    wval_secondary_color    tab_menu_palettes.val_secondary_color%TYPE,
                                                    wval_accent_color       tab_menu_palettes.val_accent_color%TYPE,
                                                    wval_text_color         tab_menu_palettes.val_text_color%TYPE,
                                                    wval_hover_color        tab_menu_palettes.val_hover_color%TYPE,
                                                    wval_sidebar_bg         tab_menu_palettes.val_sidebar_bg%TYPE,
                                                    wval_sidebar_text       tab_menu_palettes.val_sidebar_text%TYPE,
                                                    wval_sidebar_hover      tab_menu_palettes.val_sidebar_hover%TYPE,
                                                    wval_active_bg          tab_menu_palettes.val_active_bg%TYPE,
                                                    wnum_orden              tab_menu_palettes.num_orden%TYPE,
                                                    wind_active             tab_menu_palettes.ind_active%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;

    IF wnom_palette IS NULL OR TRIM(wnom_palette) = '' THEN
        RAISE EXCEPTION 'El nombre de la paleta no puede estar vacío';
    END IF;

    IF wval_primary_color IS NULL OR TRIM(wval_primary_color) = '' THEN
        RAISE EXCEPTION 'El color primario no puede estar vacío';
    END IF;

    IF wval_secondary_color IS NULL OR TRIM(wval_secondary_color) = '' THEN
        RAISE EXCEPTION 'El color secundario no puede estar vacío';
    END IF;

    IF wval_accent_color IS NULL OR TRIM(wval_accent_color) = '' THEN
        RAISE EXCEPTION 'El color de acento no puede estar vacío';
    END IF;

    IF wval_text_color IS NULL OR TRIM(wval_text_color) = '' THEN
        RAISE EXCEPTION 'El color del texto no puede estar vacío';
    END IF;

    IF wval_hover_color IS NULL OR TRIM(wval_hover_color) = '' THEN
        RAISE EXCEPTION 'El color hover no puede estar vacío';
    END IF;

    IF wval_sidebar_bg IS NULL OR TRIM(wval_sidebar_bg) = '' THEN
        RAISE EXCEPTION 'El fondo del sidebar no puede estar vacío';
    END IF;

    IF wval_sidebar_text IS NULL OR TRIM(wval_sidebar_text) = '' THEN
        RAISE EXCEPTION 'El color del texto del sidebar no puede estar vacío';
    END IF;

    IF wval_sidebar_hover IS NULL OR TRIM(wval_sidebar_hover) = '' THEN
        RAISE EXCEPTION 'El color hover del sidebar no puede estar vacío';
    END IF;

    IF wval_active_bg IS NULL OR TRIM(wval_active_bg) = '' THEN
        RAISE EXCEPTION 'El color del item activo no puede estar vacío';
    END IF;

    IF wnum_orden IS NULL THEN
        RAISE EXCEPTION 'El número de orden no puede ser nulo';
    END IF;

    IF wind_active IS NULL THEN
        RAISE EXCEPTION 'El indicador de paleta activa no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_palette) < 1 OR LENGTH(wid_palette) > 30 THEN
        RAISE EXCEPTION 'El ID de la paleta debe tener entre 1 y 30 caracteres';
    END IF;

    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    IF LENGTH(wnom_palette) < 1 OR LENGTH(wnom_palette) > 50 THEN
        RAISE EXCEPTION 'El nombre de la paleta debe tener entre 1 y 50 caracteres';
    END IF;

    IF wnum_orden < 0 THEN
        RAISE EXCEPTION 'El número de orden no puede ser negativo';
    END IF;

    IF wval_primary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color primario debe tener formato hexadecimal válido (ej: #1a1a2e)';
    END IF;

    IF wval_secondary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color secundario debe tener formato hexadecimal válido (ej: #16213e)';
    END IF;

    IF wval_accent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color de acento debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;

    IF wval_text_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;

    IF wval_hover_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;

    IF wval_sidebar_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El fondo del sidebar debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;

    IF wval_sidebar_text !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto del sidebar debe tener formato hexadecimal válido (ej: #555555)';
    END IF;

    IF wval_sidebar_hover !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover del sidebar debe tener formato hexadecimal válido (ej: #f4f7ff)';
    END IF;

    IF wval_active_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del item activo debe tener formato hexadecimal válido (ej: #00aaff)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe o está inactiva', wid_palette;
    END IF;

    -- Solo puede haber una paleta activa a la vez (excluyendo la actual)
    IF wind_active = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE ind_active = TRUE AND ind_borrado = FALSE AND id_palette <> wid_palette) THEN
            RAISE EXCEPTION 'Ya existe una paleta activa, desactívela antes de activar otra';
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_menu_palettes SET nom_palette         = wnom_palette,
                                 des_palette         = COALESCE(NULLIF(TRIM(wdes_palette), ''), 'Sin descripción de la paleta'),
                                 val_primary_color   = wval_primary_color,
                                 val_secondary_color = wval_secondary_color,
                                 val_accent_color    = wval_accent_color,
                                 val_text_color      = wval_text_color,
                                 val_hover_color     = wval_hover_color,
                                 val_sidebar_bg      = wval_sidebar_bg,
                                 val_sidebar_text    = wval_sidebar_text,
                                 val_sidebar_hover   = wval_sidebar_hover,
                                 val_active_bg       = wval_active_bg,
                                 num_orden           = wnum_orden,
                                 ind_active          = wind_active
    WHERE id_palette = wid_palette;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_password(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                               wpass_usuario   tab_usuarios.pass_usuario%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RAISE EXCEPTION 'La contraseña no puede estar vacía';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wpass_usuario) < 12 THEN
        RAISE EXCEPTION 'La contraseña debe tener mínimo 12 caracteres';
    END IF;

    IF wpass_usuario ~ '\s' THEN
        RAISE EXCEPTION 'La contraseña no puede contener espacios';
    END IF;

    IF wpass_usuario !~ '[A-Z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra mayúscula';
    END IF;

    IF wpass_usuario !~ '[a-z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra minúscula';
    END IF;

    IF wpass_usuario !~ '[0-9]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un número';
    END IF;

    IF wpass_usuario !~ '[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/\\~`''""]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un símbolo especial (!@#$%% etc.)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o está inactivo', wid_usuario;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_usuarios SET pass_usuario = wpass_usuario
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_pmtros_grales(wid_empresa         tab_pmtros_grales.id_empresa%TYPE,
                                                    wnom_empresa        tab_pmtros_grales.nom_empresa%TYPE,
                                                    wnom_corto          VARCHAR,
                                                    wdireccion          VARCHAR,
                                                    wtel_fijo           DECIMAL,
                                                    wid_prefijo_movil   DECIMAL,
                                                    wtel_movil          DECIMAL,
                                                    wemail              VARCHAR,
                                                    wnom_replegal       tab_pmtros_grales.nom_replegal%TYPE,
                                                    wval_poriva         tab_pmtros_grales.val_poriva%TYPE,
                                                    wval_pordesc        tab_pmtros_grales.val_pordesc%TYPE,
                                                    wval_porrete        tab_pmtros_grales.val_porrete%TYPE,
                                                    wval_reteica        tab_pmtros_grales.val_reteica%TYPE,
                                                    wval_porutil        tab_pmtros_grales.val_porutil%TYPE,
                                                    wval_latitud        tab_pmtros_grales.val_latitud%TYPE,
                                                    wval_longitud       tab_pmtros_grales.val_longitud%TYPE,
                                                    wind_autorete       tab_pmtros_grales.ind_autorete%TYPE,
                                                    wriesgo_arl         tab_pmtros_grales.riesgo_arl%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    IF wnom_empresa IS NULL OR TRIM(wnom_empresa) = '' THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wnom_replegal IS NULL OR TRIM(wnom_replegal) = '' THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede estar vacío';
    END IF;

    IF wval_poriva IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de IVA no puede ser nulo';
    END IF;

    IF wval_pordesc IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de descuento no puede ser nulo';
    END IF;

    IF wval_porrete IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de retención no puede ser nulo';
    END IF;

    IF wval_reteica IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de reteica no puede ser nulo';
    END IF;

    IF wval_porutil IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de utilidad no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    IF wriesgo_arl IS NULL OR TRIM(wriesgo_arl) = '' THEN
        RAISE EXCEPTION 'El riesgo ARL no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
    END IF;

    IF wnom_replegal !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del representante legal solo debe contener letras y espacios';
    END IF;

    IF wval_poriva < 0 OR wval_poriva >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de IVA debe estar entre 0 y 99';
    END IF;

    IF wval_pordesc < 0 OR wval_pordesc >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de descuento debe estar entre 0 y 99';
    END IF;

    IF wval_porrete < 0 OR wval_porrete >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de retención debe estar entre 0 y 99';
    END IF;

    IF wval_reteica < 0 OR wval_reteica >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de reteica debe estar entre 0 y 99';
    END IF;

    IF wval_porutil < 0 OR wval_porutil > 100 THEN
        RAISE EXCEPTION 'El porcentaje de utilidad debe estar entre 0 y 100';
    END IF;

    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    IF wriesgo_arl NOT IN ('1', '2', '3', '4', '5') THEN
        RAISE EXCEPTION 'El riesgo ARL debe ser 1 (0.522%%), 2 (1.044%%), 3 (2.436%%), 4 (4.350%%) o 5 (6.960%%)';
    END IF;

    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con ID % no existe o está inactiva', wid_empresa;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN (anio_fiscal y mes_fiscal no se tocan)
    -- =============================================
    UPDATE tab_pmtros_grales SET nom_empresa      = wnom_empresa,
                                 datos_residencia = ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
                                 nom_replegal     = wnom_replegal,
                                 val_poriva       = wval_poriva,
                                 val_pordesc      = wval_pordesc,
                                 val_porrete      = wval_porrete,
                                 val_reteica      = wval_reteica,
                                 val_porutil      = wval_porutil,
                                 val_latitud      = wval_latitud,
                                 val_longitud     = wval_longitud,
                                 ind_autorete     = wind_autorete,
                                 riesgo_arl       = wriesgo_arl
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_restricciones(
    wid_restriccion     tab_restricciones.id_restriccion%TYPE,
    wnom_restriccion    tab_restricciones.nom_restriccion%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wnom_restriccion IS NULL OR TRIM(wnom_restriccion) = '' THEN
        RAISE EXCEPTION 'El nombre de la restricción no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_restriccion) < 4 OR LENGTH(wnom_restriccion) > 50 THEN
        RAISE EXCEPTION 'El nombre de la restricción debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_restriccion !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la restricción solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_restricciones SET nom_restriccion = wnom_restriccion
    WHERE id_restriccion = wid_restriccion;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tab_menus(p_id_menu       tab_menus.id_menu%TYPE,
                                                p_nom_menu      tab_menus.nom_menu%TYPE,
                                                p_id_padre      tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa  tab_menus.nom_programa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    IF p_nom_menu IS NULL OR TRIM(p_nom_menu) = '' THEN
        RAISE EXCEPTION 'El nombre del menú no puede estar vacío';
    END IF;

    IF p_id_padre IS NULL THEN
        RAISE EXCEPTION 'El ID del padre no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(p_nom_menu) < 3 OR LENGTH(p_nom_menu) > 100 THEN
        RAISE EXCEPTION 'El nombre del menú debe tener entre 3 y 100 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El menú con ID % no existe o está inactivo', p_id_menu;
    END IF;

    IF p_id_padre <> '0' THEN
        IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_padre AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'El menú padre con ID % no existe o está inactivo', p_id_padre;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_menus SET nom_menu     = p_nom_menu,
                         ind_id_padre = p_id_padre,
                         nom_programa = COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica')
    WHERE id_menu = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tel_prefijo(wid_prefijo     tab_tel_prefijo.id_prefijo%TYPE,
                                                  wnom_pais       tab_tel_prefijo.nom_pais%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_prefijo IS NULL THEN
        RAISE EXCEPTION 'El ID del prefijo no puede ser nulo';
    END IF;

    IF wnom_pais IS NULL OR TRIM(wnom_pais) = '' THEN
        RAISE EXCEPTION 'El nombre del país no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_prefijo <= 0 OR wid_prefijo > 9999 THEN
        RAISE EXCEPTION 'El ID del prefijo debe estar entre 1 y 9999';
    END IF;

    IF LENGTH(wnom_pais) < 4 OR LENGTH(wnom_pais) > 50 THEN
        RAISE EXCEPTION 'El nombre del país debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo) THEN
        RAISE EXCEPTION 'El prefijo con ID % no existe', wid_prefijo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tel_prefijo SET nom_pais = wnom_pais
    WHERE id_prefijo = wid_prefijo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_terceros(wid_tercero         tab_terceros.id_tercero%TYPE,
                                               wind_tipo_tercero   tab_terceros.ind_tipo_tercero%TYPE,
                                               wid_cat_tercero     tab_terceros.id_cat_tercero%TYPE,
                                               wnom_tercero        tab_terceros.nom_tercero%TYPE,
                                               wnom_corto          VARCHAR,
                                               wdireccion          VARCHAR,
                                               wtel_fijo           DECIMAL,
                                               wid_prefijo_movil   DECIMAL,
                                               wtel_movil          DECIMAL,
                                               wemail              VARCHAR,
                                               wid_ciudad          tab_terceros.id_ciudad%TYPE,
                                               wid_restriccion     tab_terceros.id_restriccion%TYPE,
                                               wind_estado         tab_terceros.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    IF wind_tipo_tercero IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de tercero no puede ser nulo';
    END IF;

    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_tercero IS NULL OR TRIM(wnom_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre del tercero no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_tercero) < 4 OR LENGTH(wnom_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre del tercero debe tener entre 4 y 50 caracteres';
    END IF;

    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El tercero con ID % no existe o está inactivo', wid_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo_movil) THEN
            RAISE EXCEPTION 'El prefijo móvil % no existe', wid_prefijo_movil;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_terceros SET ind_tipo_tercero = wind_tipo_tercero,
                            id_cat_tercero   = wid_cat_tercero,
                            nom_tercero      = wnom_tercero,
                            dir_tercero      = ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
                            id_ciudad        = wid_ciudad,
                            id_restriccion   = wid_restriccion,
                            ind_estado       = wind_estado
    WHERE id_tercero = wid_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tipo_identidad(wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
                                                     wnom_tipo   tab_tipo_identidad.nom_tipo%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad no puede estar vacío';
    END IF;

    IF wnom_tipo IS NULL OR TRIM(wnom_tipo) = '' THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad con ID % no existe', wid_tipo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tipo_identidad SET nom_tipo = wnom_tipo
    WHERE id_tipo = wid_tipo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                                wnom_usuario    tab_usuarios.nom_usuario%TYPE,
                                                wmail_usuario   tab_usuarios.mail_usuario%TYPE,
                                                wind_usuario    tab_usuarios.ind_usuario%TYPE,
                                                wind_estado     tab_usuarios.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    IF wnom_usuario IS NULL OR TRIM(wnom_usuario) = '' THEN
        RAISE EXCEPTION 'El nombre de usuario no puede estar vacío';
    END IF;

    IF wmail_usuario IS NULL OR TRIM(wmail_usuario) = '' THEN
        RAISE EXCEPTION 'El correo electrónico no puede estar vacío';
    END IF;

    IF wind_usuario IS NULL THEN
        RAISE EXCEPTION 'El indicador de administrador no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wnom_usuario) < 8 THEN
        RAISE EXCEPTION 'El nombre completo debe tener mínimo 8 caracteres';
    END IF;

    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico no tiene un formato válido';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o está inactivo', wid_usuario;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE mail_usuario = wmail_usuario AND id_usuario <> wid_usuario) THEN
        RAISE EXCEPTION 'El correo % ya está registrado en otro usuario', wmail_usuario;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_usuarios SET nom_usuario  = wnom_usuario,
                            mail_usuario = wmail_usuario,
                            ind_usuario  = wind_usuario,
                            ind_estado   = wind_estado
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;