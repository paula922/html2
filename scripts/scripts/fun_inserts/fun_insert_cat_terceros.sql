CREATE OR REPLACE FUNCTION fun_insert_cat_terceros(wid_cat_tercero     tab_cat_terceros.id_cat_tercero%TYPE,
                                                   wnom_cat_tercero    tab_cat_terceros.nom_cat_tercero%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_cat_tercero IS NULL OR TRIM(wnom_cat_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre de la categoría no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 1 y 99
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres, solo letras y espacios
    IF LENGTH(wnom_cat_tercero) < 4 OR LENGTH(wnom_cat_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre de la categoría debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_cat_tercero !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la categoría solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'Ya existe una categoría con el ID %', wid_cat_tercero;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_cat_terceros (id_cat_tercero,nom_cat_tercero
    ) VALUES (wid_cat_tercero,wnom_cat_tercero);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;