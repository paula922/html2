CREATE OR REPLACE FUNCTION fun_update_motivo_nota(wid_motivo_nota     tab_motivo_nota.id_motivo_nota%TYPE,
                                                      wind_tipo_nota      tab_motivo_nota.ind_tipo_nota%TYPE,
                                                      wcod_dian           tab_motivo_nota.cod_dian%TYPE,
                                                      wnom_motivo         tab_motivo_nota.nom_motivo%TYPE,
                                                      wafecta_inventario  tab_motivo_nota.afecta_inventario%TYPE,
                                                      wafecta_cliente     tab_motivo_nota.afecta_cliente%TYPE,
                                                      wafecta_cartera     tab_motivo_nota.afecta_cartera%TYPE,
                                                      wafecta_comision    tab_motivo_nota.afecta_comision%TYPE)RETURNS BOOLEAN AS 
$$
BEGIN
     -- =============================================
    -- VALIDACIONES DE NULO / VACÍO / RANGO BÁSICO
    -- =============================================
    IF wid_motivo_nota IS NULL OR wid_motivo_nota <= 0 THEN
        RAISE EXCEPTION 'El ID del motivo de nota debe ser mayor a 0.';
    END IF;

    IF wind_tipo_nota IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de nota (Crédito/Débito) no puede ser nulo.';
    END IF;

    IF wcod_dian IS NULL OR wcod_dian < 1 OR wcod_dian > 6 THEN
        RAISE EXCEPTION 'El código DIAN debe estar entre 1 y 6.';
    END IF;

    -- Aplicar la restricción de negocio: débito solo usa códigos 1-3
    IF wind_tipo_nota = TRUE AND (wcod_dian < 1 OR wcod_dian > 3) THEN
        RAISE EXCEPTION 'Para nota Débito, el código DIAN debe estar entre 1 y 3.';
    END IF;

    IF wnom_motivo IS NULL OR LENGTH(TRIM(wnom_motivo)) < 5 THEN
        RAISE EXCEPTION 'La descripción del motivo debe tener mínimo 5 caracteres.';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADOS
    -- =============================================
    -- Llave primaria
    IF EXISTS (SELECT 1 FROM tab_motivo_nota WHERE id_motivo_nota = wid_motivo_nota) THEN
        RAISE EXCEPTION 'El motivo de nota con ID % ya existe.', wid_motivo_nota;
    END IF;

    -- Unicidad de la combinación código DIAN + tipo de nota
    IF EXISTS (
        SELECT 1 FROM tab_motivo_nota
        WHERE cod_dian = wcod_dian
          AND ind_tipo_nota = wind_tipo_nota
    ) THEN
        RAISE EXCEPTION 'El código DIAN % ya está asignado para el tipo de nota %'
            , wcod_dian, CASE WHEN wind_tipo_nota THEN 'Débito' ELSE 'Crédito' END;
    END IF;

    UPDATE tab_motivo_nota
    SET ind_tipo_nota      = wind_tipo_nota,
        cod_dian           = wcod_dian,
        nom_motivo         = wnom_motivo,
        afecta_inventario  = wafecta_inventario,
        afecta_cliente     = wafecta_cliente,
        afecta_cartera     = wafecta_cartera,
        afecta_comision    = wafecta_comision
    WHERE id_motivo_nota = wid_motivo_nota;
 
    RETURN TRUE;
 
EXCEPTION
        WHEN OTHERS THEN
    RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
       
END;
$$ LANGUAGE plpgsql;
 