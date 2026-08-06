CREATE OR REPLACE FUNCTION fun_update_tab_usuarios(wid_usuario tab_usuarios.id_usuario%TYPE,
                                                   wnom_usuario tab_usuarios.nom_usuario%TYPE,
                                                   wpass_usuario tab_usuarios.pass_usuario%TYPE,
                                                   wmail_usuario tab_usuarios.mail_usuario%TYPE,
                                                   wind_usuario tab_usuarios.ind_usuario%TYPE,
                                                   wind_estado tab_usuarios.ind_estado%TYPE) RETURNS TEXT AS $$
BEGIN
    UPDATE tab_usuarios SET nom_usuario  = wnom_usuario,
                            pass_usuario = wpass_usuario,
                            mail_usuario = wmail_usuario,
                            ind_usuario  = wind_usuario,
                            ind_estado   = wind_estado
    WHERE id_usuario = wid_usuario;
    IF NOT FOUND THEN
        RETURN 'ERROR: El usuario ' || wid_usuario || ' no existe.';
    END IF;
    RETURN 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;