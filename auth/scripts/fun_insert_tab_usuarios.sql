CREATE OR REPLACE FUNCTION fun_insert_tab_usuarios(
    wid_usuario     tab_usuarios.id_usuario%TYPE,
    wnom_usuario    tab_usuarios.nom_usuario%TYPE,
    wpass_usuario   tab_usuarios.pass_usuario%TYPE,
    wmail_usuario   tab_usuarios.mail_usuario%TYPE,
    wind_usuario    tab_usuarios.ind_usuario%TYPE,
    wind_estado     tab_usuarios.ind_estado%TYPE
) RETURNS TEXT AS $$
BEGIN

    -- VALIDACIÓN 1: Nombre de usuario (sin espacios)
    IF wnom_usuario IS NULL OR TRIM(wnom_usuario) = '' THEN
        RETURN 'ERROR: El nombre de usuario no puede estar vacío.';
    END IF;

    IF wid_usuario ~ '\s' THEN
        RETURN 'ERROR: El usuario no puede contener espacios.';
    END IF;

    -- VALIDACIÓN 2: Nombre completo (pa evitar el sql iyeccion)
    IF wid_usuario ~ '[*"]' THEN
        RETURN 'ERROR: El nombre de usuario contiene caracteres no permitidos (* o ").';
    END IF;

    -- VALIDACIÓN 3: Correo electrónico con formato válido
    -- Regla: local@dominio.extension

    IF wmail_usuario IS NULL OR TRIM(wmail_usuario) = '' THEN
        RETURN 'ERROR: El correo electrónico no puede estar vacío.';
    END IF;

    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RETURN 'ERROR: El correo electrónico no tiene un formato válido.';
    END IF;

    -- VALIDACIÓN 4: Contraseña
    --   - Mínimo 12 caracteres
    --   - Sin espacios
    --   - Al menos 1 mayúscula
    --   - Al menos 1 minúscula
    --   - Al menos 1 número
    --   - Al menos 1 símbolo especial

    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RETURN 'ERROR: La contraseña no puede estar vacía.';
    END IF;

    IF LENGTH(wpass_usuario) < 12 THEN
        RETURN 'ERROR: La contraseña debe tener mínimo 12 caracteres.';
    END IF;

    IF wpass_usuario ~ '\s' THEN
        RETURN 'ERROR: La contraseña no puede contener espacios.';
    END IF;

    IF wpass_usuario !~ '[A-Z]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos una letra mayúscula.';
    END IF;

    IF wpass_usuario !~ '[a-z]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos una letra minúscula.';
    END IF;

    IF wpass_usuario !~ '[0-9]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos un número.';
    END IF;

    IF wpass_usuario !~ '[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/\\~`''""]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos un símbolo especial (!@#$%^&* etc.).';
    END IF;

    -- INSERT: Todas las validaciones pasaron
    INSERT INTO tab_usuarios
    VALUES (wid_usuario, wnom_usuario, wpass_usuario, wmail_usuario, wind_usuario, wind_estado);

    RETURN 'OK';

EXCEPTION WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;

END;
$$ LANGUAGE plpgsql;