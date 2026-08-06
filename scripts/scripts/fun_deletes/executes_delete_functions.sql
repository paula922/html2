CREATE OR REPLACE FUNCTION fun_delete_areas(wid_area    tab_areas.id_area%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_area IS NULL THEN
        RAISE EXCEPTION 'El ID del área no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El área con ID % no existe o ya fue eliminada', wid_area;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_areas SET ind_borrado = TRUE
    WHERE id_area = wid_area;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_bancos(wid_banco   tab_bancos.id_banco%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o ya fue eliminado', wid_banco;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_bancos SET ind_borrado = TRUE
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_delete_ciudades(wid_ciudad  tab_ciudades.id_ciudad%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o ya fue eliminada', wid_ciudad;
    END IF;

    -- Verificar que no esté referenciada en terceros
    IF EXISTS (SELECT 1 FROM tab_terceros WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'No se puede eliminar la ciudad % porque está referenciada en terceros activos', wid_ciudad;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_ciudades SET ind_borrado = TRUE
    WHERE id_ciudad = wid_ciudad;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_menu_palettes(wid_palette     tab_menu_palettes.id_palette%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe o ya fue eliminada', wid_palette;
    END IF;

    -- No se puede eliminar la paleta activa
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_active = TRUE) THEN
        RAISE EXCEPTION 'No se puede eliminar la paleta % porque está activa, desactívela primero', wid_palette;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_menu_palettes SET ind_borrado = TRUE
    WHERE id_palette = wid_palette;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_menu_usuarios(p_id_usuario    tab_menu_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menu_usuarios.id_menu%TYPE) RETURNS BOOLEAN AS
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
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'La asignación del menú % al usuario % no existe', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menu_usuarios
    WHERE id_usuario = p_id_usuario AND id_menu    = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_delete_pmtros_grales(wid_empresa     tab_pmtros_grales.id_empresa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con ID % no existe o ya fue eliminada', wid_empresa;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_pmtros_grales SET ind_borrado = TRUE
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_tab_menus(p_id_menu   tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú con ID % no existe', p_id_menu;
    END IF;

    -- Verificar que no tenga submenús activos
    IF EXISTS (SELECT 1 FROM tab_menus WHERE ind_id_padre = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque tiene submenús asociados', p_id_menu;
    END IF;

    -- Verificar que no esté asignado a usuarios
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque está asignado a uno o más usuarios', p_id_menu;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_terceros(wid_tercero     tab_terceros.id_tercero%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El tercero con ID % no existe o ya fue eliminado', wid_tercero;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_terceros SET ind_borrado = TRUE
    WHERE id_tercero = wid_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o ya fue eliminado', wid_usuario;
    END IF;

    -- Verificar que no sea el único administrador activo
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE ind_usuario = TRUE AND ind_borrado  = FALSE AND id_usuario  <> wid_usuario) THEN
        RAISE EXCEPTION 'No se puede eliminar el único administrador activo del sistema';
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_usuarios SET ind_borrado = TRUE,
                            ind_estado  = FALSE
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;