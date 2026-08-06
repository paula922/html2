CREATE OR REPLACE FUNCTION fun_insert_bancos(wid_banco       tab_bancos.id_banco%TYPE,
                                             wnom_banco      tab_bancos.nom_banco%TYPE,
                                             wind_estado     tab_bancos.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    IF wnom_banco IS NULL OR TRIM(wnom_banco) = '' THEN
        RAISE EXCEPTION 'El nombre del banco no puede estar vacío';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 6 y 10 caracteres
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    -- Nombre: entre 4 y 50 caracteres
    IF LENGTH(wnom_banco) < 4 OR LENGTH(wnom_banco) > 50 THEN
        RAISE EXCEPTION 'El nombre del banco debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco) THEN
        RAISE EXCEPTION 'Ya existe un banco con el ID %', wid_banco;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_bancos (id_banco,nom_banco,ind_estado,ind_borrado) 
    VALUES (wid_banco,wnom_banco,wind_estado,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;