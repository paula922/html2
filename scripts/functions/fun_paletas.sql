-- ===================================================================
-- ARCHIVO: fun_menu_palettes.sql
-- DESCRIPCIÓN: Sistema de gestión de paletas de colores para menú principal
-- ESTILO: Funciones PL/pgSQL (estilo de fun_insert_menu)
-- BASE DE DATOS: PostgreSQL
-- ===================================================================

-- ===================================================================
-- 1. ELIMINAR FUNCIONES EXISTENTES (SI LAS HAY)
-- ===================================================================
DROP FUNCTION IF EXISTS fun_insert_palette(VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS fun_update_palette(VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS fun_delete_palette(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS fun_get_palette(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS fun_list_palettes() CASCADE;
DROP FUNCTION IF EXISTS fun_get_active_palette() CASCADE;
DROP FUNCTION IF EXISTS fun_set_company_palette(VARCHAR, BOOLEAN, VARCHAR, VARCHAR, VARCHAR) CASCADE;

-- ===================================================================
-- 2. FUNCIÓN: INSERTAR PALETA DE COLORES
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_insert_palette(
    wid_palette     tab_menu_palettes.id_palette%TYPE,
    wnombre         tab_menu_palettes.nombre%TYPE,
    wdescripcion    tab_menu_palettes.descripcion%TYPE DEFAULT NULL,
    wprimary_color  VARCHAR DEFAULT '#1a1a2e',
    wsecondary_color VARCHAR DEFAULT '#16213e',
    waccent_color   VARCHAR DEFAULT '#00d9ff',
    wtext_color     VARCHAR DEFAULT '#ffffff',
    whover_color    VARCHAR DEFAULT '#00d9ff',
    wsidebar_bg     VARCHAR DEFAULT '#ffffff',
    wsidebar_text   VARCHAR DEFAULT '#555555',
    wsidebar_hover  VARCHAR DEFAULT '#f4f7ff',
    wactive_bg      VARCHAR DEFAULT '#00aaff',
    worden          INTEGER DEFAULT 0,
    wis_active      BOOLEAN DEFAULT FALSE
) RETURNS VOID AS 
$$
BEGIN
    -- Validaciones de nulo
    IF wid_palette IS NULL THEN
        RAISE EXCEPTION 'El ID de la paleta no puede ser nulo';
    END IF;

    IF wnombre IS NULL OR TRIM(wnombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la paleta no puede estar vacío';
    END IF;

    -- Validar formato de colores (deben ser #RRGGBB)
    IF wprimary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'Color primario % no es válido. Formato: #RRGGBB', wprimary_color;
    END IF;

    IF waccent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'Color acento % no es válido. Formato: #RRGGBB', waccent_color;
    END IF;

    -- Validar que el ID no exista ya
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RAISE EXCEPTION 'La paleta con ID % ya existe', wid_palette;
    END IF;

    -- Insertar paleta
    INSERT INTO tab_menu_palettes (
        id_palette, nombre, descripcion,
        primary_color, secondary_color, accent_color, text_color, hover_color,
        sidebar_bg, sidebar_text, sidebar_hover, active_bg,
        orden, is_active
    ) VALUES (
        wid_palette, wnombre, wdescripcion,
        wprimary_color, wsecondary_color, waccent_color, wtext_color, whover_color,
        wsidebar_bg, wsidebar_text, wsidebar_hover, wactive_bg,
        worden, wis_active
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al insertar paleta: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 3. FUNCIÓN: ACTUALIZAR PALETA DE COLORES
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_update_palette(
    wid_palette     tab_menu_palettes.id_palette%TYPE,
    wnombre         tab_menu_palettes.nombre%TYPE,
    wdescripcion    tab_menu_palettes.descripcion%TYPE DEFAULT NULL,
    wprimary_color  VARCHAR DEFAULT '#1a1a2e',
    wsecondary_color VARCHAR DEFAULT '#16213e',
    waccent_color   VARCHAR DEFAULT '#00d9ff',
    wtext_color     VARCHAR DEFAULT '#ffffff',
    whover_color    VARCHAR DEFAULT '#00d9ff',
    wsidebar_bg     VARCHAR DEFAULT '#ffffff',
    wsidebar_text   VARCHAR DEFAULT '#555555',
    wsidebar_hover  VARCHAR DEFAULT '#f4f7ff',
    wactive_bg      VARCHAR DEFAULT '#00aaff',
    worden          INTEGER DEFAULT 0,
    wis_active      BOOLEAN DEFAULT FALSE
) RETURNS VOID AS 
$$
BEGIN
    -- Validaciones de nulo
    IF wid_palette IS NULL THEN
        RAISE EXCEPTION 'El ID de la paleta no puede ser nulo';
    END IF;

    IF wnombre IS NULL OR TRIM(wnombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la paleta no puede estar vacío';
    END IF;

    -- Validar formato de colores
    IF wprimary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'Color primario % no es válido. Formato: #RRGGBB', wprimary_color;
    END IF;

    IF waccent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'Color acento % no es válido. Formato: #RRGGBB', waccent_color;
    END IF;

    -- Validar que la paleta existe
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe', wid_palette;
    END IF;

    -- Actualizar paleta
    UPDATE tab_menu_palettes 
    SET nombre = wnombre,
        descripcion = wdescripcion,
        primary_color = wprimary_color,
        secondary_color = wsecondary_color,
        accent_color = waccent_color,
        text_color = wtext_color,
        hover_color = whover_color,
        sidebar_bg = wsidebar_bg,
        sidebar_text = wsidebar_text,
        sidebar_hover = wsidebar_hover,
        active_bg = wactive_bg,
        orden = worden,
        is_active = wis_active
    WHERE id_palette = wid_palette;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al actualizar paleta: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 4. FUNCIÓN: ELIMINAR PALETA (BORRADO LÓGICO)
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_delete_palette(
    wid_palette tab_menu_palettes.id_palette%TYPE
) RETURNS VOID AS 
$$
BEGIN
    -- Validar nulo
    IF wid_palette IS NULL THEN
        RAISE EXCEPTION 'El ID de la paleta no puede ser nulo';
    END IF;

    -- Validar que la paleta existe
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe', wid_palette;
    END IF;

    -- Validar que no sea la paleta activa de la empresa
    IF EXISTS (
        SELECT 1 FROM tab_pmtros_grales 
        WHERE menu_color_palette = wid_palette 
        AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar la paleta % porque está asignada a la empresa', wid_palette;
    END IF;

    -- Borrado lógico (no elimino físicamente por si hay referencias)
    -- En este caso, como es una tabla catálogo, eliminamos físicamente
    DELETE FROM tab_menu_palettes WHERE id_palette = wid_palette;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al eliminar paleta: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 5. FUNCIÓN: OBTENER UNA PALETA POR ID
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_get_palette(
    wid_palette tab_menu_palettes.id_palette%TYPE
) RETURNS TABLE(
    id_palette      tab_menu_palettes.id_palette%TYPE,
    nombre          tab_menu_palettes.nombre%TYPE,
    descripcion     tab_menu_palettes.descripcion%TYPE,
    primary_color   VARCHAR,
    secondary_color VARCHAR,
    accent_color    VARCHAR,
    text_color      VARCHAR,
    hover_color     VARCHAR,
    sidebar_bg      VARCHAR,
    sidebar_text    VARCHAR,
    sidebar_hover   VARCHAR,
    active_bg       VARCHAR,
    orden           INTEGER,
    is_active       BOOLEAN
) AS 
$$
BEGIN
    IF wid_palette IS NULL THEN
        RAISE EXCEPTION 'El ID de la paleta no puede ser nulo';
    END IF;

    RETURN QUERY
    SELECT 
        p.id_palette, p.nombre, p.descripcion,
        p.primary_color, p.secondary_color, p.accent_color, p.text_color, p.hover_color,
        p.sidebar_bg, p.sidebar_text, p.sidebar_hover, p.active_bg,
        p.orden, p.is_active
    FROM tab_menu_palettes p
    WHERE p.id_palette = wid_palette;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al obtener paleta: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 6. FUNCIÓN: LISTAR TODAS LAS PALETAS
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_list_palettes()
RETURNS TABLE(
    id_palette      VARCHAR,
    nombre          VARCHAR,
    descripcion     TEXT,
    primary_color   VARCHAR,
    accent_color    VARCHAR,
    sidebar_bg      VARCHAR,
    orden           INTEGER,
    is_active       BOOLEAN
) AS 
$$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_palette, 
        p.nombre, 
        p.descripcion,
        p.primary_color,
        p.accent_color,
        p.sidebar_bg,
        p.orden,
        p.is_active
    FROM tab_menu_palettes p
    ORDER BY p.orden;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al listar paletas: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 7. FUNCIÓN: OBTENER PALETA ACTIVA DE LA EMPRESA
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_get_active_palette()
RETURNS TABLE(
    id_palette      VARCHAR,
    nombre          VARCHAR,
    primary_color   VARCHAR,
    secondary_color VARCHAR,
    accent_color    VARCHAR,
    text_color      VARCHAR,
    hover_color     VARCHAR,
    sidebar_bg      VARCHAR,
    sidebar_text    VARCHAR,
    sidebar_hover   VARCHAR,
    active_bg       VARCHAR,
    is_custom       BOOLEAN
) AS 
$$
DECLARE
    w_custom_colors BOOLEAN;
    w_palette_id    VARCHAR;
BEGIN
    -- Obtener configuración de la empresa
    SELECT menu_custom_colors, menu_color_palette 
    INTO w_custom_colors, w_palette_id
    FROM tab_pmtros_grales 
    WHERE ind_borrado = FALSE 
    LIMIT 1;
    
    -- Si tiene colores personalizados
    IF w_custom_colors IS NOT NULL AND w_custom_colors = TRUE THEN
        RETURN QUERY
        SELECT 
            'custom'::VARCHAR,
            'Personalizado'::VARCHAR,
            COALESCE(menu_primary, '#1a1a2e'),
            COALESCE(menu_primary, '#1a1a2e'),
            COALESCE(menu_accent, '#00d9ff'),
            '#ffffff'::VARCHAR,
            COALESCE(menu_accent, '#00d9ff'),
            COALESCE(menu_sidebar_bg, '#ffffff'),
            '#555555'::VARCHAR,
            '#f4f7ff'::VARCHAR,
            '#00aaff'::VARCHAR,
            TRUE
        FROM tab_pmtros_grales 
        WHERE ind_borrado = FALSE 
        LIMIT 1;
        RETURN;
    END IF;
    
    -- Si no, retornar la paleta predefinida
    RETURN QUERY
    SELECT 
        p.id_palette,
        p.nombre,
        p.primary_color,
        p.secondary_color,
        p.accent_color,
        p.text_color,
        p.hover_color,
        p.sidebar_bg,
        p.sidebar_text,
        p.sidebar_hover,
        p.active_bg,
        FALSE
    FROM tab_menu_palettes p
    WHERE p.id_palette = COALESCE(w_palette_id, 'blue_pro');
    
    -- Si no se encuentra, retornar por defecto
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 'blue_pro', 'Azul Profesional', '#1a1a2e', '#16213e', '#00d9ff', '#ffffff', '#00d9ff', '#ffffff', '#555555', '#f4f7ff', '#00aaff', FALSE;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al obtener paleta activa: %', SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 8. FUNCIÓN: CONFIGURAR PALETA DE LA EMPRESA
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_set_company_palette(
    wid_palette     VARCHAR DEFAULT NULL,
    wcustom_colors  BOOLEAN DEFAULT FALSE,
    wprimary_color  VARCHAR DEFAULT '#1a1a2e',
    waccent_color   VARCHAR DEFAULT '#00d9ff',
    wsidebar_bg     VARCHAR DEFAULT '#ffffff'
) RETURNS TEXT AS 
$$
BEGIN
    -- Si usa colores personalizados
    IF wcustom_colors THEN
        -- Validar formato de colores
        IF wprimary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
            RETURN 'ERROR: Color primario ' || wprimary_color || ' no es válido. Formato: #RRGGBB';
        END IF;
        
        IF waccent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
            RETURN 'ERROR: Color acento ' || waccent_color || ' no es válido. Formato: #RRGGBB';
        END IF;
        
        IF wsidebar_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
            RETURN 'ERROR: Color de fondo ' || wsidebar_bg || ' no es válido. Formato: #RRGGBB';
        END IF;
        
        -- Actualizar con colores personalizados
        UPDATE tab_pmtros_grales 
        SET menu_custom_colors = TRUE,
            menu_primary = wprimary_color,
            menu_accent = waccent_color,
            menu_sidebar_bg = wsidebar_bg
        WHERE ind_borrado = FALSE;
        
        RETURN 'OK: Colores personalizados guardados';
    END IF;
    
    -- Si usa paleta predefinida
    IF wid_palette IS NULL THEN
        RETURN 'ERROR: Debe especificar una paleta o activar colores personalizados';
    END IF;
    
    -- Validar que la paleta existe
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RETURN 'ERROR: La paleta ' || wid_palette || ' no existe';
    END IF;
    
    -- Actualizar con paleta predefinida
    UPDATE tab_pmtros_grales 
    SET menu_color_palette = wid_palette,
        menu_custom_colors = FALSE
    WHERE ind_borrado = FALSE;
    
    RETURN 'OK: Paleta ' || wid_palette || ' aplicada';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 9. INSERTAR PALETAS POR DEFECTO (10 PALETAS EMPRESARIALES)
-- ===================================================================
DO $$
BEGIN
    -- Limpiar datos existentes
    DELETE FROM tab_menu_palettes;
    
    -- Insertar paletas
    PERFORM fun_insert_palette('blue_pro', 'Azul Profesional', 'Clásico corporativo azul oscuro con acento cyan', '#1a1a2e', '#16213e', '#00d9ff', '#ffffff', '#00d9ff', '#ffffff', '#555555', '#f4f7ff', '#00aaff', 1, TRUE);
    PERFORM fun_insert_palette('navy_exec', 'Azul Marino Ejecutivo', 'Sobrio, elegante y profesional', '#0a192f', '#0a2540', '#4a90e2', '#ffffff', '#4a90e2', '#ffffff', '#4a5568', '#e8f0fe', '#3b82f6', 2, FALSE);
    PERFORM fun_insert_palette('green_corp', 'Verde Corporativo', 'Natural, fresco y confiable', '#1a4d2e', '#0d3b1f', '#7cb342', '#ffffff', '#7cb342', '#f8fafc', '#2d3748', '#e8f5e9', '#2e7d32', 3, FALSE);
    PERFORM fun_insert_palette('gray_exec', 'Gris Ejecutivo', 'Neutro, moderno y minimalista', '#2d3748', '#1a202c', '#3182ce', '#ffffff', '#3182ce', '#ffffff', '#4a5568', '#edf2f7', '#2b6cb0', 4, FALSE);
    PERFORM fun_insert_palette('purple_innov', 'Morado Innovador', 'Creativo, moderno y distintivo', '#2d1b69', '#1a0f4a', '#9f7aea', '#ffffff', '#9f7aea', '#faf5ff', '#4a5568', '#f3e8ff', '#7c3aed', 5, FALSE);
    PERFORM fun_insert_palette('teal_modern', 'Teal Moderno', 'Fresco, tecnológico y dinámico', '#004d40', '#00332e', '#26a69a', '#ffffff', '#26a69a', '#e0f2f1', '#2d3748', '#e0f2f1', '#00897b', 6, FALSE);
    PERFORM fun_insert_palette('red_corp', 'Rojo Corporativo', 'Audaz, enérgico y poderoso', '#7f1d1d', '#5c1010', '#ef4444', '#ffffff', '#ef4444', '#fef2f2', '#4a5568', '#fee2e2', '#dc2626', 7, FALSE);
    PERFORM fun_insert_palette('orange_dynamic', 'Naranja Dinámico', 'Energético, creativo y moderno', '#7c2d12', '#5c1a04', '#f97316', '#ffffff', '#f97316', '#fff7ed', '#4a5568', '#ffedd5', '#ea580c', 8, FALSE);
    PERFORM fun_insert_palette('light_tech', 'Azul Claro Tecnológico', 'Limpio, moderno y digital', '#0ea5e9', '#0284c7', '#38bdf8', '#ffffff', '#38bdf8', '#f0f9ff', '#1e293b', '#e0f2fe', '#0ea5e9', 9, FALSE);
    PERFORM fun_insert_palette('dark_premium', 'Oscuro Premium', 'Elegante, sofisticado y moderno', '#0f0f1a', '#1a1a2e', '#00b4d8', '#ffffff', '#00b4d8', '#1e1e2e', '#a0a0b0', '#2a2a3e', '#00a8c5', 10, FALSE);
    
    RAISE NOTICE '10 paletas insertadas correctamente';
END $$;

-- ===================================================================
-- 10. AGREGAR CAMPOS A tab_pmtros_grales (si no existen)
-- ===================================================================
DO $$
BEGIN
    -- Agregar campo menu_color_palette
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tab_pmtros_grales' AND column_name = 'menu_color_palette'
    ) THEN
        ALTER TABLE tab_pmtros_grales ADD COLUMN menu_color_palette VARCHAR(30) DEFAULT 'blue_pro';
        RAISE NOTICE 'Campo menu_color_palette agregado';
    END IF;
    
    -- Agregar campo menu_custom_colors
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tab_pmtros_grales' AND column_name = 'menu_custom_colors'
    ) THEN
        ALTER TABLE tab_pmtros_grales ADD COLUMN menu_custom_colors BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Campo menu_custom_colors agregado';
    END IF;
    
    -- Agregar campo menu_primary
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tab_pmtros_grales' AND column_name = 'menu_primary'
    ) THEN
        ALTER TABLE tab_pmtros_grales ADD COLUMN menu_primary VARCHAR(7) DEFAULT '#1a1a2e';
        RAISE NOTICE 'Campo menu_primary agregado';
    END IF;
    
    -- Agregar campo menu_accent
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tab_pmtros_grales' AND column_name = 'menu_accent'
    ) THEN
        ALTER TABLE tab_pmtros_grales ADD COLUMN menu_accent VARCHAR(7) DEFAULT '#00d9ff';
        RAISE NOTICE 'Campo menu_accent agregado';
    END IF;
    
    -- Agregar campo menu_sidebar_bg
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tab_pmtros_grales' AND column_name = 'menu_sidebar_bg'
    ) THEN
        ALTER TABLE tab_pmtros_grales ADD COLUMN menu_sidebar_bg VARCHAR(7) DEFAULT '#ffffff';
        RAISE NOTICE 'Campo menu_sidebar_bg agregado';
    END IF;
    
END $$;

-- ===================================================================
-- 11. EJEMPLOS DE USO
-- ===================================================================

/*
╔═══════════════════════════════════════════════════════════════════╗
║                    EJEMPLOS DE USO                                ║
╚═══════════════════════════════════════════════════════════════════╝

┌───────────────────────────────────────────────────────────────────┐
│ 1. LISTAR TODAS LAS PALETAS                                      │
├───────────────────────────────────────────────────────────────────┤
SELECT * FROM fun_list_palettes();

┌───────────────────────────────────────────────────────────────────┐
│ 2. OBTENER PALETA ACTIVA DE LA EMPRESA                           │
├───────────────────────────────────────────────────────────────────┤
SELECT * FROM fun_get_active_palette();

┌───────────────────────────────────────────────────────────────────┐
│ 3. CAMBIAR A PALETA PREDEFINIDA                                  │
├───────────────────────────────────────────────────────────────────┤
SELECT fun_set_company_palette('teal_modern', FALSE, NULL, NULL, NULL);

┌───────────────────────────────────────────────────────────────────┐
│ 4. USAR COLORES PERSONALIZADOS                                   │
├───────────────────────────────────────────────────────────────────┤
SELECT fun_set_company_palette(NULL, TRUE, '#0f172a', '#f59e0b', '#1e293b');

┌───────────────────────────────────────────────────────────────────┐
│ 5. OBTENER UNA PALETA ESPECÍFICA                                 │
├───────────────────────────────────────────────────────────────────┤
SELECT * FROM fun_get_palette('green_corp');

┌───────────────────────────────────────────────────────────────────┐
│ 6. INSERTAR NUEVA PALETA PERSONALIZADA                           │
├───────────────────────────────────────────────────────────────────┤
SELECT fun_insert_palette('my_custom', 'Mi Estilo', 'Paleta personalizada', 
                          '#1e1e2e', '#313244', '#89b4fa', '#cdd6f4', '#89b4fa',
                          '#1e1e2e', '#a6adc8', '#313244', '#89b4fa', 99, FALSE);

┌───────────────────────────────────────────────────────────────────┐
│ 7. ACTUALIZAR UNA PALETA                                         │
├───────────────────────────────────────────────────────────────────┤
SELECT fun_update_palette('my_custom', 'Mi Estilo V2', 'Versión mejorada',
                          '#1e1e2e', '#313244', '#cba6f7', '#cdd6f4', '#cba6f7',
                          '#1e1e2e', '#a6adc8', '#313244', '#cba6f7', 99, FALSE);

*/

-- ===================================================================
-- FIN DEL ARCHIVO
-- ===================================================================