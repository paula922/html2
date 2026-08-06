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