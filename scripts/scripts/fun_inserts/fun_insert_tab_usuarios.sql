select * from tab_usuarios
select * from tab_menu_usuarios
select * from tab_menus


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