-- 1. Función Atómica para Inserción (V.1.3: Incluye nom_programa)
-- VALIDACIONES REQUERIDAS POR EL MODELO:
-- 1. nom_menu: VARCHAR NOT NULL, LENGTH >= 3 AND <= 25
-- 2. ind_id_padre: VARCHAR NOT NULL
-- 3. nom_programa: VARCHAR NOT NULL DEFAULT 'no_aplica'
-- 4. id_menu: PK (no debe duplicarse)
CREATE OR REPLACE FUNCTION fun_insert_tab_menus(p_id_menu tab_menus.id_menu%TYPE,
                                                p_nom_menu tab_menus.nom_menu%TYPE,
                                    0            p_id_padre tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa tab_menus.nom_programa%TYPE) RETURNS TEXT AS
$$
DECLARE
    v_exists INTEGER;
    v_nom_len INTEGER;
    v_padre_exists INTEGER;
BEGIN
    -- 1. VALIDACIÓN: id_menu debe ser único (PK)
    SELECT COUNT(*) INTO v_exists FROM tab_menus WHERE id_menu = p_id_menu;
    IF v_exists > 0 THEN
        RETURN 'ERR: ID Menú ' || p_id_menu || ' ya existe';
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

    -- 4. VALIDACIÓN: Si padre no es '0', verificar que existe
    IF p_id_padre != '0' THEN
        SELECT COUNT(*) INTO v_padre_exists FROM tab_menus WHERE id_menu = p_id_padre;
        IF v_padre_exists = 0 THEN
            RETURN 'ERR: Menú padre ID ' || p_id_padre || ' no existe';
        END IF;
    END IF;

    -- INSERCIÓN: Todos los validados, proceder
    INSERT INTO tab_menus VALUES(
        p_id_menu, 
        p_nom_menu, 
        p_id_padre, 
        COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica')
    );
    RETURN 'OK';
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;