-- V.1.3 CORRECCIÓN: Función trigger para adicionar una opción nueva del menú al admin.
-- Ahora inserta en el menu en la tabla tab_menu_usuarios pero spolo para el admin.
CREATE OR REPLACE FUNCTION fun_trigger_menu_admin() RETURNS TRIGGER AS
$$
 DECLARE wid_usuario tab_usuarios.id_usuario%TYPE;
	BEGIN
        SELECT a.id_usuario INTO wid_usuario FROM tab_usuarios a
        WHERE a.id_usuario = 'admin';
        IF NOT FOUND THEN
            RETURN NULL;
        END IF;
        INSERT INTO tab_menu_usuarios VALUES(wid_usuario,NEW.id_menu);
        IF FOUND THEN
            RETURN NULL;
        END IF;
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_menu_dmin
AFTER INSERT ON tab_menus FOR EACH ROW
EXECUTE FUNCTION fun_trigger_menu_admin();