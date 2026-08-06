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