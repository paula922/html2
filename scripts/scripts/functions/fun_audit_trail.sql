--select * from tab_audit_trail


CREATE OR REPLACE FUNCTION fun_audit_trail() RETURNS TRIGGER AS $$
DECLARE
    wid_usuario         tab_usuarios.id_usuario%TYPE;  -- Esto es TEXT
    wip                 VARCHAR;
    woperacion          varchar;
    wind_borrado        BOOLEAN;
    wold_borrado        BOOLEAN;
    wnew_borrado        BOOLEAN;
    old_diff            JSONB;
    new_diff            JSONB;
BEGIN
    -- 1. Recuperar el ID de usuario desde las variables de sesión (TEXTO)
    wid_usuario := COALESCE(current_setting('myapp.user_id', TRUE), '0');

    -- 2. Si no se recibió o es '0', asignar un usuario por defecto que EXISTA en tab_usuarios
    IF wid_usuario = '0' OR wid_usuario IS NULL OR wid_usuario = '' THEN
        wid_usuario := 'admin';   -- Cambia por un ID real que exista en tu tabla
    END IF;

    -- 3. IP
    wip := COALESCE(current_setting('myapp.user_ip', TRUE), '0.0.0.0');
	 IF wip = '::1' OR wip = '127.0.0.1' THEN
        wip := 'localhost';
    END IF;

    -- 4. Validar que el usuario exista en tab_usuarios (comparación TEXT vs TEXT)
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario) THEN
        -- Si no existe, asignar un fallback (por ejemplo, 'admin')
        wid_usuario := 'admin';
        RAISE NOTICE 'Usuario % no encontrado, usando admin', wid_usuario;
    END IF;

    -- 5. Lógica para INSERT
    IF (TG_OP = 'INSERT') THEN 
        INSERT INTO tab_audit_trail (id_usuario, ip_conexion, nom_operacion, dato_viejo, dato_nuevo, nom_tabla)
        VALUES (wid_usuario, wip, 'INSERT', '{}'::jsonb, to_jsonb(NEW), TG_TABLE_NAME);
        RETURN NEW;
    END IF;

    -- 6. Lógica para DELETE
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO tab_audit_trail (id_usuario, ip_conexion, nom_operacion, dato_viejo, dato_nuevo, nom_tabla)
        VALUES (wid_usuario, wip, 'DELETE FISICO', to_jsonb(OLD), '{}'::jsonb, TG_TABLE_NAME); 
        RETURN OLD;
    END IF;

    -- 7. Lógica para UPDATE (detectando borrado lógico)
    wind_borrado := (to_jsonb(NEW) ? 'ind_borrado');
    IF wind_borrado THEN
        wold_borrado := (to_jsonb(OLD)->>'ind_borrado')::BOOLEAN;
        wnew_borrado := (to_jsonb(NEW)->>'ind_borrado')::BOOLEAN;
        
        IF (wold_borrado = FALSE AND wnew_borrado = TRUE) THEN
            woperacion := 'BORRADO LOGICO';
        ELSIF (wold_borrado = TRUE AND wnew_borrado = FALSE) THEN
            woperacion := 'RESTAURAR';
        ELSE
            woperacion := 'UPDATE';
        END IF;
    ELSE
        woperacion := 'UPDATE'; 
    END IF;

    -- 8. Calcular diferencias (JSONB)
     IF woperacion IN ('UPDATE', 'LOGICAL_DELETE', 'RESTORE') THEN
        IF to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW) THEN
            SELECT jsonb_object_agg(o.key, o.value) INTO old_diff
            FROM jsonb_each(to_jsonb(OLD)) o
            WHERE to_jsonb(OLD) -> o.key IS DISTINCT FROM to_jsonb(NEW) -> o.key;
            
            SELECT jsonb_object_agg(n.key, n.value) INTO new_diff
            FROM jsonb_each(to_jsonb(NEW)) n
            WHERE to_jsonb(OLD) -> n.key IS DISTINCT FROM to_jsonb(NEW) -> n.key;
        ELSE
            old_diff := to_jsonb(OLD);
            new_diff := to_jsonb(NEW);
        END IF;
    ELSE
        old_diff := to_jsonb(OLD);
        new_diff := to_jsonb(NEW);
    END IF;

    -- 9. Enmascarar datos sensibles
    IF TG_TABLE_NAME = 'tab_usuarios' THEN
        old_diff := old_diff - 'pass_usuario';
        new_diff := new_diff - 'pass_usuario';
    END IF;

    -- 10. Insertar en la tabla de auditoría
    INSERT INTO tab_audit_trail (id_usuario, ip_conexion, nom_operacion, dato_viejo, dato_nuevo, nom_tabla)
    VALUES (wid_usuario, wip, woperacion, old_diff, new_diff, TG_TABLE_NAME);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;