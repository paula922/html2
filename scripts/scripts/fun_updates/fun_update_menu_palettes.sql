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