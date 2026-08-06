CREATE OR REPLACE FUNCTION fun_insert_areas(wid_area            tab_areas.id_area%TYPE,
                                            wid_responsable     tab_areas.id_responsable%TYPE,
                                            wnom_area           tab_areas.nom_area%TYPE,
                                            wdescrip_area       tab_areas.descrip_area%TYPE,
                                            wmail_area          tab_areas.mail_area%TYPE,
                                            wtel_oficina        tab_areas.tel_oficina%TYPE,
                                            wubi_oficina        tab_areas.ubi_oficina%TYPE,
                                            whorario_atencion   tab_areas.horario_atencion%TYPE,
                                            wind_estado         tab_areas.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_area IS NULL THEN
        RAISE EXCEPTION 'El ID del área no puede ser nulo';
    END IF;
    IF wid_responsable IS NULL OR TRIM(wid_responsable) = '' THEN
        RAISE EXCEPTION 'El responsable del área no puede estar vacío';
    END IF;
    IF wnom_area IS NULL OR TRIM(wnom_area) = '' THEN
        RAISE EXCEPTION 'El nombre del área no puede estar vacío';
    END IF;
    IF wmail_area IS NULL OR TRIM(wmail_area) = '' THEN
        RAISE EXCEPTION 'El email del área no puede estar vacío';
    END IF;
    IF wtel_oficina IS NULL THEN
        RAISE EXCEPTION 'El teléfono de la oficina no puede ser nulo';
    END IF;
    IF wubi_oficina IS NULL OR TRIM(wubi_oficina) = '' THEN
        RAISE EXCEPTION 'La ubicación de la oficina no puede estar vacía';
    END IF;
    IF whorario_atencion IS NULL OR TRIM(whorario_atencion) = '' THEN
        RAISE EXCEPTION 'El horario de atención no puede estar vacío';
    END IF;
    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID área: mayor a 0
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    -- Responsable: mínimo 5 caracteres + existe y está activo
    IF LENGTH(wid_responsable) < 5 THEN
        RAISE EXCEPTION 'El ID del responsable debe tener mínimo 5 caracteres';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM tab_usuarios
        WHERE id_usuario = wid_responsable
          AND ind_estado  = TRUE
          AND ind_borrado = FALSE
    ) THEN
        RAISE EXCEPTION 'El responsable % no existe o está inactivo', wid_responsable;
    END IF;

    -- Nombre área: mínimo 3 caracteres
    IF LENGTH(wnom_area) < 3 THEN
        RAISE EXCEPTION 'El nombre del área debe tener mínimo 3 caracteres';
    END IF;

    -- Email corporativo
    IF wmail_area !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$' THEN
        RAISE EXCEPTION 'El email del área no tiene un formato válido';
    END IF;

    -- Teléfono
    IF wtel_oficina < 0 OR wtel_oficina >= 9999999999 THEN
        RAISE EXCEPTION 'El teléfono debe estar entre 0 y 9999999999';
    END IF;

    -- Ubicación: mínimo 3 caracteres
    IF LENGTH(wubi_oficina) < 3 THEN
        RAISE EXCEPTION 'La ubicación de la oficina debe tener mínimo 3 caracteres';
    END IF;

    -- Horario: mínimo 3 caracteres
    IF LENGTH(whorario_atencion) < 3 THEN
        RAISE EXCEPTION 'El horario de atención debe tener mínimo 3 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area) THEN
        RAISE EXCEPTION 'Ya existe un área con el ID %', wid_area;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_areas (id_area, id_responsable, nom_area, descrip_area,mail_area, tel_oficina, ubi_oficina, horario_atencion,
                           ind_estado, ind_borrado) 
    VALUES (wid_area, wid_responsable, wnom_area,COALESCE(NULLIF(TRIM(wdescrip_area), ''), 'Sin descripción de área'),wmail_area, 
              wtel_oficina, wubi_oficina, whorario_atencion,wind_estado, FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;