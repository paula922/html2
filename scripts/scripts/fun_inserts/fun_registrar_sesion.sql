CREATE OR REPLACE FUNCTION fun_registrar_sesion(p_user  tab_sesiones.id_usuario%TYPE,
                                                p_token tab_sesiones.token_sesion%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_user IS NULL OR TRIM(p_user) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_token IS NULL OR TRIM(p_token) = '' THEN
        RAISE EXCEPTION 'El token de sesión no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(p_user) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;
    IF LENGTH(p_token) < 10 THEN
        RAISE EXCEPTION 'El token de sesión debe tener mínimo 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDAR QUE EL USUARIO EXISTE Y ESTÁ ACTIVO
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_user AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_user;
    END IF;

    -- =============================================
    -- INSERT / UPDATE (lógica original intacta)
    -- =============================================
    INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio, ult_actividad)
    VALUES (p_user, p_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario)
    DO UPDATE SET
        token_sesion  = EXCLUDED.token_sesion,
        ult_actividad = CURRENT_TIMESTAMP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;