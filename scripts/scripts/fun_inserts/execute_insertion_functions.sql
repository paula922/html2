-- =============================================
-- Función: fun_insert_areas
-- Descripción: Inserta un nuevo registro en la tabla tab_areas con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================

CREATE OR REPLACE FUNCTION fun_insert_areas(wid_area            tab_areas.id_area%TYPE,
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

    -- ID área: mayor a 0
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    -- Responsable: mínimo 5 caracteres + existe y está activo
    IF LENGTH(wid_responsable) < 5 THEN
        RAISE EXCEPTION 'El ID del responsable debe tener mínimo 5 caracteres';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM tab_usuarios
        WHERE id_usuario = wid_responsable
          AND ind_estado  = TRUE
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El responsable % no existe o está inactivo', wid_responsable;
    END IF;

    -- Nombre área: mínimo 3 caracteres
    IF LENGTH(wnom_area) < 3 THEN
        RAISE EXCEPTION 'El nombre del área debe tener mínimo 3 caracteres';
    END IF;

    -- Email corporativo
    IF wmail_area !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$' THEN
        RAISE EXCEPTION 'El email del área no tiene un formato válido';
    END IF;

    -- Teléfono
    IF wtel_oficina < 0 OR wtel_oficina >= 9999999999 THEN
        RAISE EXCEPTION 'El teléfono debe estar entre 0 y 9999999999';
    END IF;

    -- Ubicación: mínimo 3 caracteres
    IF LENGTH(wubi_oficina) < 3 THEN
        RAISE EXCEPTION 'La ubicación de la oficina debe tener mínimo 3 caracteres';
    END IF;

    -- Horario: mínimo 3 caracteres
    IF LENGTH(whorario_atencion) < 3 THEN
        RAISE EXCEPTION 'El horario de atención debe tener mínimo 3 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area) THEN
        RAISE EXCEPTION 'Ya existe un área con el ID %', wid_area;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_areas (id_area, id_responsable, nom_area, descrip_area,mail_area, tel_oficina, ubi_oficina, horario_atencion,
                           ind_estado, ind_borrado) 
    VALUES (wid_area, wid_responsable, wnom_area,COALESCE(NULLIF(TRIM(wdescrip_area), ''), 'Sin descripción de área'),wmail_area, 
              wtel_oficina, wubi_oficina, whorario_atencion,wind_estado, FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_bancos
-- Descripción: Inserta un nuevo registro en la tabla tab_bancos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_bancos(wid_banco       tab_bancos.id_banco%TYPE,
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

    -- ID: entre 6 y 10 caracteres
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    -- Nombre: entre 4 y 50 caracteres
    IF LENGTH(wnom_banco) < 4 OR LENGTH(wnom_banco) > 50 THEN
        RAISE EXCEPTION 'El nombre del banco debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco) THEN
        RAISE EXCEPTION 'Ya existe un banco con el ID %', wid_banco;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_bancos (id_banco,nom_banco,ind_estado,ind_borrado) 
    VALUES (wid_banco,wnom_banco,wind_estado,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_cat_terceros
-- Descripción: Inserta un nuevo registro en la tabla tab_cat_terceros con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_cat_terceros(wid_cat_tercero     tab_cat_terceros.id_cat_tercero%TYPE,
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

    -- ID: entre 1 y 99
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres, solo letras y espacios
    IF LENGTH(wnom_cat_tercero) < 4 OR LENGTH(wnom_cat_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre de la categoría debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_cat_tercero !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la categoría solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'Ya existe una categoría con el ID %', wid_cat_tercero;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_cat_terceros (id_cat_tercero,nom_cat_tercero
    ) VALUES (wid_cat_tercero,wnom_cat_tercero);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_ciudades
-- Descripción: Inserta un nuevo registro en la tabla tab_ciudades con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_ciudades(wid_ciudad      tab_ciudades.id_ciudad%TYPE,
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

    -- ID ciudad: exactamente 5 dígitos numéricos
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- Nombre ciudad: entre 3 y 30 caracteres, solo letras y espacios
    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios';
    END IF;

    -- ID departamento: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Código postal: exactamente 6 dígitos numéricos
    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de exactamente 6 dígitos (ej: 050001)';
    END IF;

    -- Latitud: entre -4 y 80
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    -- Longitud: entre -80 y -50
    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO Y EXISTENCIA FK
    -- =============================================

    -- Verificar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- Verificar duplicado de ciudad
    IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad) THEN
        RAISE EXCEPTION 'Ya existe una ciudad con el ID %', wid_ciudad;
    END IF;

    -- Solo puede haber una capital por departamento
    IF wind_capital = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_dpto = wid_dpto AND ind_capital = TRUE AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'El departamento % ya tiene una ciudad capital registrada', wid_dpto;
        END IF;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_ciudades (id_ciudad,nom_ciudad,id_dpto,ind_capital,cod_postal,val_latitud,val_longitud,ind_borrado) 
    VALUES (wid_ciudad,wnom_ciudad,wid_dpto,wind_capital,wcod_postal,wval_latitud,wval_longitud,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_dptos
-- Descripción: Inserta un nuevo registro en la tabla tab_dptos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_dptos(wid_dpto   tab_dptos.id_dpto%TYPE,
                                            wnom_dpto  tab_dptos.nom_dpto%TYPE) RETURNS BOOLEAN AS
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

    -- ID: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Nombre: entre 4 y 20 caracteres
    IF LENGTH(TRIM(wnom_dpto)) < 4 OR LENGTH(TRIM(wnom_dpto)) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    -- Nombre: solo letras y espacios
    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto) THEN
        RAISE EXCEPTION 'Ya existe un departamento con el ID %', wid_dpto;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_dptos (id_dpto,nom_dpto) 
    VALUES (wid_dpto,wnom_dpto);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menu_palettes
-- Descripción: Inserta un nuevo registro en la tabla tab_menu_palettes con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_menu_palettes(wid_palette             tab_menu_palettes.id_palette%TYPE,
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

    -- ID paleta: entre 1 y 30 caracteres, alfanumérico y guion bajo
    IF LENGTH(wid_palette) < 1 OR LENGTH(wid_palette) > 30 THEN
        RAISE EXCEPTION 'El ID de la paleta debe tener entre 1 y 30 caracteres';
    END IF;
    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    -- Nombre paleta: entre 1 y 50 caracteres
    IF LENGTH(wnom_palette) < 1 OR LENGTH(wnom_palette) > 50 THEN
        RAISE EXCEPTION 'El nombre de la paleta debe tener entre 1 y 50 caracteres';
    END IF;

    -- Orden: mayor o igual a 0
    IF wnum_orden < 0 THEN
        RAISE EXCEPTION 'El número de orden no puede ser negativo';
    END IF;

    -- Colores: formato hexadecimal #RRGGBB exactamente 7 caracteres
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
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RAISE EXCEPTION 'Ya existe una paleta con el ID %', wid_palette;
    END IF;

    -- Solo puede haber una paleta activa a la vez
    IF wind_active = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE ind_active = TRUE AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'Ya existe una paleta activa, desactívela antes de activar otra';
        END IF;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_menu_palettes (id_palette, nom_palette, des_palette,val_primary_color, val_secondary_color, val_accent_color,
                                   val_text_color, val_hover_color, val_sidebar_bg,val_sidebar_text, val_sidebar_hover, val_active_bg,
                                   num_orden, ind_active, ind_borrado) 
    VALUES (wid_palette, wnom_palette,COALESCE(NULLIF(TRIM(wdes_palette), ''), 'Sin descripción de la paleta'),wval_primary_color, 
            wval_secondary_color, wval_accent_color,wval_text_color, wval_hover_color, wval_sidebar_bg,wval_sidebar_text, wval_sidebar_hover, 
            wval_active_bg,wnum_orden, wind_active, FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menu_usuarios
-- Descripción: Inserta un nuevo registro en la tabla tab_menu_usuarios con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_menu_usuarios(p_id_usuario    tab_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_usuario IS NULL OR TRIM(p_id_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_id_usuario AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_id_usuario;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu   = p_id_menu AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El menú % no existe o está inactivo', p_id_menu;
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú % ya está asignado al usuario %', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
    VALUES (p_id_usuario, p_id_menu);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menus
-- Descripción: Inserta un nuevo registro en la tabla tab_menus con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_tab_menus(p_id_menu       tab_menus.id_menu%TYPE,
                                                p_nom_menu      tab_menus.nom_menu%TYPE,
                                                p_id_padre      tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa  tab_menus.nom_programa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;
    IF p_nom_menu IS NULL OR TRIM(p_nom_menu) = '' THEN
        RAISE EXCEPTION 'El nombre del menú no puede estar vacío';
    END IF;
    IF p_id_padre IS NULL THEN
        RAISE EXCEPTION 'El ID del padre no puede ser nulo';
    END IF;

    IF LENGTH(p_nom_menu) < 3 OR LENGTH(p_nom_menu) > 100 THEN
        RAISE EXCEPTION 'El nombre del menú debe tener entre 3 y 100 caracteres (actual: %)', LENGTH(p_nom_menu);
    END IF;

    IF p_id_padre != '0' THEN
        IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_padre) THEN
            RAISE EXCEPTION 'El menú padre con ID % no existe o está inactivo', p_id_padre;
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'Ya existe un menú con el ID %', p_id_menu;
    END IF;

    INSERT INTO tab_menus (id_menu, nom_menu, ind_id_padre, nom_programa)
    VALUES (p_id_menu,p_nom_menu,p_id_padre,COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica'));

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_pmtos_grales
-- Descripción: Inserta un nuevo registro en la tabla tab_pmtos_grales con validaciones de campos obligatorios, formato, rango y duplicados.    
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_pmtros_grales(wid_empresa         tab_pmtros_grales.id_empresa%TYPE,
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
DECLARE
    wanio_fiscal tab_pmtros_grales.anio_fiscal%TYPE;
    wmes_fiscal  tab_pmtros_grales.mes_fiscal%TYPE;
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

    -- ID empresa: numérico de 8 a 10 dígitos
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    -- Nombre empresa: entre 5 y 60 caracteres
    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    -- Nombre representante legal: entre 5 y 60 caracteres, solo letras y espacios
    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
    END IF;

    IF wnom_replegal !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del representante legal solo debe contener letras y espacios';
    END IF;

    -- Porcentajes
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

    -- Latitud y longitud
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- Riesgo ARL
    IF wriesgo_arl NOT IN ('1', '2', '3', '4', '5') THEN
        RAISE EXCEPTION 'El riesgo ARL debe ser 1 (0.522%%), 2 (1.044%%), 3 (2.436%%), 4 (4.350%%) o 5 (6.960%%)';
    END IF;

    -- Teléfono fijo (opcional)
    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Prefijo móvil y teléfono móvil: ambos obligatorios si se ingresa uno
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

    -- Email
    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existe un registro para la empresa con ID %', wid_empresa;
    END IF;

    -- =============================================
    -- ASIGNACIÓN AUTOMÁTICA AÑO Y MES FISCAL
    -- =============================================
    wanio_fiscal := EXTRACT(YEAR  FROM CURRENT_DATE);
    wmes_fiscal  := EXTRACT(MONTH FROM CURRENT_DATE);

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_pmtros_grales (id_empresa,nom_empresa,datos_residencia,nom_replegal,val_poriva,val_pordesc,val_porrete,val_reteica,val_porutil,
                                    val_latitud,val_longitud,anio_fiscal,mes_fiscal,ind_autorete,riesgo_arl,ind_borrado) 
    VALUES (wid_empresa,wnom_empresa,ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,wnom_replegal,
            wval_poriva,wval_pordesc,wval_porrete,wval_reteica,wval_porutil,wval_latitud,wval_longitud,wanio_fiscal,wmes_fiscal,wind_autorete,wriesgo_arl,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_restricciones
-- Descripción: Inserta un nuevo registro en la tabla tab_restricciones con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_restricciones(wid_restriccion     tab_restricciones.id_restriccion%TYPE,
                                                    wnom_restriccion    tab_restricciones.nom_restriccion%TYPE) RETURNS BOOLEAN AS
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

    -- ID: entre 1 y 99
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres, solo letras y espacios
    IF LENGTH(wnom_restriccion) < 4 OR LENGTH(wnom_restriccion) > 50 THEN
        RAISE EXCEPTION 'El nombre de la restricción debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_restriccion !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la restricción solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'Ya existe una restricción con el ID %', wid_restriccion;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_restricciones (id_restriccion,nom_restriccion) 
    VALUES (wid_restriccion,wnom_restriccion);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_tel_prefijos
-- Descripción: Inserta un nuevo registro en la tabla tab_tel_prefijos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_tel_prefijo(wid_prefijo     tab_tel_prefijo.id_prefijo%TYPE,
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

    -- ID: entre 1 y 9999
    IF wid_prefijo <= 0 OR wid_prefijo > 9999 THEN
        RAISE EXCEPTION 'El ID del prefijo debe estar entre 1 y 9999';
    END IF;

    -- Nombre país: entre 4 y 50 caracteres
    IF LENGTH(wnom_pais) < 4 OR LENGTH(wnom_pais) > 50 THEN
        RAISE EXCEPTION 'El nombre del país debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo) THEN
        RAISE EXCEPTION 'Ya existe un prefijo con el ID %', wid_prefijo;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_tel_prefijo (id_prefijo,nom_pais) 
    VALUES (wid_prefijo,wnom_pais);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_terceros
-- Descripción: Inserta un nuevo registro en la tabla tab_terceros con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_terceros(wid_tipo            tab_terceros.id_tipo%TYPE,
                                               wid_tercero         tab_terceros.id_tercero%TYPE,
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
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El tipo de documento no puede estar vacío';
    END IF;

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

    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- DATOS_UBICACION: solo email y dirección son obligatorios
    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- Tipo documento
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El tipo de documento debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    -- ID tercero: entre 7 y 10 caracteres alfanuméricos mayúsculas
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    -- Categoría: entre 1 y 99
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres
    IF LENGTH(wnom_tercero) < 4 OR LENGTH(wnom_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre del tercero debe tener entre 4 y 50 caracteres';
    END IF;

    -- Restricción: entre 1 y 99
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    -- Teléfono fijo: entre 7 y 10 dígitos (opcional)
    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Prefijo móvil y teléfono móvil: ambos obligatorios si se ingresa uno
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

    -- Email: formato básico
    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO Y EXISTENCIA FK
    -- =============================================

    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de documento % no existe', wid_tipo;
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

    IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo_movil) THEN
        RAISE EXCEPTION 'El prefijo móvil % no existe', wid_prefijo_movil;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero) THEN
        RAISE EXCEPTION 'Ya existe un tercero con el ID %', wid_tercero;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_terceros (id_tipo,id_tercero,ind_tipo_tercero,id_cat_tercero,nom_tercero,dir_tercero,id_ciudad,id_restriccion,ind_estado,ind_borrado) 
    VALUES (wid_tipo,wid_tercero,wind_tipo_tercero,wid_cat_tercero,wnom_tercero,ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
            wid_ciudad,wid_restriccion,wind_estado,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_usuarios 
-- Descripción: Inserta un nuevo registro en la tabla tab_usuarios con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================    
CREATE OR REPLACE FUNCTION fun_insert_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                               wnom_usuario    tab_usuarios.nom_usuario%TYPE,
                                               wpass_usuario   tab_usuarios.pass_usuario%TYPE,
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
    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RAISE EXCEPTION 'La contraseña no puede estar vacía';
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
    -- VALIDACIONES DE FORMATO
    -- =============================================

    -- ID usuario: mínimo 5 caracteres, sin espacios ni caracteres especiales
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;
    IF wid_usuario ~ '\s' THEN
        RAISE EXCEPTION 'El ID de usuario no puede contener espacios';
    END IF;
    IF wid_usuario ~ '[*"]' THEN
        RAISE EXCEPTION 'El ID de usuario contiene caracteres no permitidos (* o ")';
    END IF;

    -- Nombre completo: mínimo 8 caracteres
    IF LENGTH(wnom_usuario) < 8 THEN
        RAISE EXCEPTION 'El nombre completo debe tener mínimo 8 caracteres';
    END IF;

    -- Correo electrónico
    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico no tiene un formato válido';
    END IF;

    -- Contraseña: mínimo 12 caracteres, sin espacios,
    -- al menos 1 mayúscula, 1 minúscula, 1 número y 1 símbolo
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
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario) THEN
        RAISE EXCEPTION 'Ya existe un usuario con el ID %', wid_usuario;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE mail_usuario = wmail_usuario) THEN
        RAISE EXCEPTION 'Ya existe un usuario registrado con el correo %', wmail_usuario;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_usuarios (id_usuario, nom_usuario, pass_usuario, mail_usuario, ind_usuario, ind_estado, ind_borrado) 
    VALUES (wid_usuario, wnom_usuario, wpass_usuario, wmail_usuario, wind_usuario, wind_estado, FALSE);
    
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_registrar_sesion
-- Descripción: Inserta un nuevo registro en la tabla tab_registrar_sesion con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_registrar_sesion(p_user  tab_sesiones.id_usuario%TYPE,
                                                p_token tab_sesiones.token_sesion%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_user IS NULL OR TRIM(p_user) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_token IS NULL OR TRIM(p_token) = '' THEN
        RAISE EXCEPTION 'El token de sesión no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(p_user) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;
    IF LENGTH(p_token) < 10 THEN
        RAISE EXCEPTION 'El token de sesión debe tener mínimo 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDAR QUE EL USUARIO EXISTE Y ESTÁ ACTIVO
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_user AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_user;
    END IF;

    -- =============================================
    -- INSERT / UPDATE (lógica original intacta)
    -- =============================================
    INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio, ult_actividad)
    VALUES (p_user, p_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario)
    DO UPDATE SET
        token_sesion  = EXCLUDED.token_sesion,
        ult_actividad = CURRENT_TIMESTAMP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_tipo_identidad
-- Descripción: Inserta un nuevo registro en la tabla tab_tipo_identidad con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_tipo_identidad(wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
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

    -- ID: entre 2 y 5 letras mayúsculas
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    -- Nombre: entre 5 y 50 caracteres
    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'Ya existe un tipo de identidad con el ID %', wid_tipo;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_tipo_identidad (id_tipo,nom_tipo
    ) VALUES (wid_tipo,wnom_tipo);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;