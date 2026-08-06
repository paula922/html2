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