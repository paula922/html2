CREATE OR REPLACE FUNCTION fun_insert_tel_prefijo(wid_prefijo     tab_tel_prefijo.id_prefijo%TYPE,
                                                  wnom_pais       tab_tel_prefijo.nom_pais%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_prefijo IS NULL THEN
        RAISE EXCEPTION 'El ID del prefijo no puede ser nulo';
    END IF;

    IF wnom_pais IS NULL OR TRIM(wnom_pais) = '' THEN
        RAISE EXCEPTION 'El nombre del país no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 1 y 9999
    IF wid_prefijo <= 0 OR wid_prefijo > 9999 THEN
        RAISE EXCEPTION 'El ID del prefijo debe estar entre 1 y 9999';
    END IF;

    -- Nombre país: entre 4 y 50 caracteres
    IF LENGTH(wnom_pais) < 4 OR LENGTH(wnom_pais) > 50 THEN
        RAISE EXCEPTION 'El nombre del país debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo) THEN
        RAISE EXCEPTION 'Ya existe un prefijo con el ID %', wid_prefijo;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_tel_prefijo (id_prefijo,nom_pais) 
    VALUES (wid_prefijo,wnom_pais);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;