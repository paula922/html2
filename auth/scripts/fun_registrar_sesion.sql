CREATE OR REPLACE FUNCTION fun_registrar_sesion(
    p_user  TEXT, 
    p_token TEXT
) RETURNS TEXT AS $$
DECLARE
    v_state TEXT;
    v_msg   TEXT;
BEGIN
    -- Eliminamos el %TYPE del VALUES para evitar la confusión de esquema
    -- El motor hará el casting automático de TEXT a los tipos de la tabla
    INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio, ult_actividad)
    VALUES (p_user, p_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario) 
    DO UPDATE SET 
        token_sesion = EXCLUDED.token_sesion,
        ult_actividad = CURRENT_TIMESTAMP;

    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_state = RETURNED_SQLSTATE,
                                v_msg   = MESSAGE_TEXT;
        RAISE EXCEPTION 'SQLSTATE: %, MENSAJE: %', v_state, v_msg;
END;
$$ LANGUAGE plpgsql;