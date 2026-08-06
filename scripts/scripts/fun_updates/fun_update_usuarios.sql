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