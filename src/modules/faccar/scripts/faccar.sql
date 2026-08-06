-- TABLA 18: Notas Contables
CREATE TABLE IF NOT EXISTS CONPRE.tab_notas
(
    id_nota             DECIMAL(10,0)   NOT NULL CHECK(id_nota > 0),                     -- ID de la nota
    id_comprobante      DECIMAL(10,0)   NOT NULL,                                        -- Comprobante (FK)
    id_tipo_nota        DECIMAL(10,0)   NOT NULL,                                        -- Tipo de nota (FK)
    id_empresa          DECIMAL(10,0)   NOT NULL CHECK(id_empresa >= 10000000 AND id_empresa <= 9999999999), -- Empresa
    id_tercero          VARCHAR         NOT NULL,                                        -- Tercero (FK)
    num_nota            DECIMAL(10,0)   NOT NULL,                                        -- Número de la nota
    fecha_nota          DATE            NOT NULL CHECK(fecha_nota <= CURRENT_DATE),      -- Fecha
    concepto            VARCHAR(200)    NOT NULL,                                        -- Concepto
    monto_nota          DECIMAL(15,0)   NOT NULL CHECK(monto_nota > 0),                  -- Monto
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_nota),                                                              -- Llave primaria
    FOREIGN KEY(id_comprobante) REFERENCES CONPRE.tab_comprobantes_contab(id_comprobante), -- FK a comprobante
    FOREIGN KEY(id_tipo_nota) REFERENCES CONPRE.tab_tip_notas(id_tipo_nota),            -- FK a tipo de nota
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),            -- FK a empresa
    FOREIGN KEY(id_tercero) REFERENCES public.tab_terceros(id_tercero),                 -- FK a tercero
    UNIQUE(id_tipo_nota, num_nota)                                                      -- No duplicar tipo+número
);
CREATE INDEX IF NOT EXISTS idx_notas_comprobante ON CONPRE.tab_notas(id_comprobante);   -- Búsqueda por comprobante


-- TABLA 6: Tipos de Notas Contables (Crédito, Débito, Ajuste...)
CREATE TABLE IF NOT EXISTS CONPRE.tab_tip_notas
(
    id_tipo_nota        DECIMAL(10,0)   NOT NULL CHECK(id_tipo_nota > 0),                  -- ID del tipo
    nom_tipo_nota       VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipo_nota) >= 3),        -- Nombre
    afecta_inventario   BOOLEAN         NOT NULL DEFAULT FALSE,                           -- TRUE=afecta inventario
    afecta_tercero      BOOLEAN         NOT NULL DEFAULT TRUE,                            -- TRUE=afecta tercero
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                            -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                           -- Borrado lógico
    PRIMARY KEY(id_tipo_nota)                                                           -- Llave primaria
);
CREATE INDEX IF NOT EXISTS idx_tip_notas_estado ON CONPRE.tab_tip_notas(ind_estado);    -- Filtro por estado
