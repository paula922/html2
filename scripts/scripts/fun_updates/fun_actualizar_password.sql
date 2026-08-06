CREATE OR REPLACE FUNCTION fun_actualizar_password(
    wid_usuario TEXT,
    wpass_nuevo TEXT
) RETURNS TEXT AS $$
BEGIN
    UPDATE tab_usuarios 
    SET pass_usuario = wpass_nuevo
    WHERE id_usuario = wid_usuario;

    IF FOUND THEN
        RETURN 'OK';
    ELSE
        RETURN 'ERROR: Usuario no encontrado';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;