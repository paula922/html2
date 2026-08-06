-- 2. Función Atómica para Actualización (V.1.3: Incluye nom_programa)
-- VALIDACIONES REQUERIDAS POR EL MODELO:
-- 1. nom_menu: VARCHAR NOT NULL, LENGTH >= 3 AND <= 25
-- 2. ind_id_padre: VARCHAR NOT NULL
-- 3. nom_programa: VARCHAR NOT NULL DEFAULT 'no_aplica'
-- 4. id_menu: DEBE EXISTIR (PK)
CREATE OR REPLACE FUNCTION fun_update_tab_menus(p_id_menu tab_menus.id_menu%TYPE,
                                                p_nom_menu tab_menus.nom_menu%TYPE,
                                                p_id_padre tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa tab_menus.nom_programa%TYPE) RETURNS TEXT AS
$$
DECLARE
    v_exists INTEGER;
    v_nom_len INTEGER;
    v_padre_exists INTEGER;
BEGIN
    -- 1. VALIDACIÓN: Verificar que el menú a actualizar existe
    SELECT COUNT(*) INTO v_exists FROM tab_menus WHERE id_menu = p_id_menu;
    IF v_exists = 0 THEN
        RETURN 'ERR: Menú ID ' || p_id_menu || ' no existe';
    END IF;

    -- 2. VALIDACIÓN: nom_menu debe tener longitud 3-50
    v_nom_len := LENGTH(p_nom_menu);
    IF v_nom_len < 3 OR v_nom_len > 50 THEN
        RETURN 'ERR: Nombre de menú debe tener entre 3 y 50 caracteres (actual: ' || v_nom_len || ')';
    END IF;

    -- 3. VALIDACIÓN: ind_id_padre no puede ser NULL
    IF p_id_padre IS NULL THEN
        RETURN 'ERR: ID Padre no puede ser nulo';
    END IF;

    -- 4. VALIDACIÓN: nom_programa no puede ser NULL (usar 'no_aplica' si es vacío)
    IF p_nom_programa IS NULL OR TRIM(p_nom_programa) = '' THEN
        -- Usar 'no_aplica' por defecto
    END IF;

    -- 5. VALIDACIÓN: Si padre no es '0', verificar que existe
    IF p_id_padre != '0' THEN
        SELECT COUNT(*) INTO v_padre_exists FROM tab_menus WHERE id_menu = p_id_padre;
        IF v_padre_exists = 0 THEN
            RETURN 'ERR: Menú padre ID ' || p_id_padre || ' no existe';
        END IF;
    END IF;

    -- ACTUALIZACIÓN: Todos los validados, proceder
    UPDATE tab_menus SET nom_menu     = p_nom_menu, 
                         ind_id_padre = p_id_padre,
                         nom_programa = COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica')
    WHERE id_menu = p_id_menu;
    
    RETURN 'OK';
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;