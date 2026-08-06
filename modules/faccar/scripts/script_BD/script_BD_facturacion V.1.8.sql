----------------------------------------------------------
-- SENTENCIA DE ELIMINACION DE TABLAS ---
----------------------------------------------------------
DROP TABLE IF EXISTS tab_pmtros_facturacion;                                         
DROP TABLE IF EXISTS tab_aplicacion_nota;
DROP TABLE IF EXISTS tab_nota_elect;
DROP TABLE IF EXISTS tab_det_notas;
DROP TABLE IF EXISTS tab_enc_notas;
DROP TABLE IF EXISTS tab_motivo_nota;                                                                                                                                             
DROP TABLE IF EXISTS tab_carteras;
DROP TABLE IF EXISTS tab_pagos; 
DROP TABLE IF EXISTS tab_fac_electronicas;                                           
DROP TABLE IF EXISTS tab_det_facturas;                                               
DROP TABLE IF EXISTS tab_enc_facturas;                                               
DROP TABLE IF EXISTS tab_det_cotizaciones;                                           
DROP TABLE IF EXISTS tab_enc_cotizaciones;                                            
DROP TABLE IF EXISTS tab_vendedores;                                                                                               
DROP TABLE IF EXISTS tab_clientes;                                                   
DROP TABLE IF EXISTS tab_forma_pagos;                                           

-- ----------------------------------------------------------------
-- MÓDULO DE FACTURACIÓN
-- ----------------------------------------------------------------
----------------------------------------------------------
--TABLA PARA PARÁMETROS DE PROCESO FACTURACIÓN Y CARTERA -
----------------------------------------------------------

CREATE TABLE tab_pmtros_facturacion
(
    id_empresa                      VARCHAR(10)                 NOT NULL,                                                                                --identificador de la empresa                                                                  
    val_res_aut                     DECIMAL(13,0)               NOT NULL CHECK(val_res_aut>=1000000000000 AND val_res_aut <=9999999999999),              -- Numero de resolucion de autorizacion de factura
    fec_venc                        DATE                        NOT NULL CHECK(fec_venc >= fec_res_aut),                                                 -- fecha de vencimiento de la rango 
    fec_res_aut                     DATE                        NOT NULL CHECK(fec_res_aut <= fec_venc),                                                 -- fecha de creacion de la resolucion autorizada
    val_prefijofac                  VARCHAR(4)                  NOT NULL CHECK(LENGTH(TRIM(val_prefijofac)) >=1 AND LENGTH(TRIM(val_prefijofac)) <=4 ),  --el prefijo de la factura
    val_facini   	                DECIMAL(6,0)		        NOT NULL CHECK(val_facini > 0),                                                          -- Valor inicial de la factura 
    val_facactual                   DECIMAL(6,0)                NOT NULL CHECK(val_facactual >= val_facini AND val_facactual <= val_facfin),             -- Valor actual de la factura 
	val_facfin		                DECIMAL(6,0)		        NOT NULL CHECK(val_facfin > 0 AND val_facfin > val_facini),                              -- Valor final de la factura 
    val_prefijocot                  VARCHAR(4)                  NOT NULL CHECK(LENGTH(TRIM(val_prefijocot)) >=1 AND LENGTH(TRIM(val_prefijocot)) <=4 ),  --el prefijo de la cotizacion
	val_cotini	                    DECIMAL(6,0)		        NOT NULL CHECK(val_cotini > 0),                                                          -- Valor inicial de la cotizacion 
    val_cotactual                   DECIMAL(6,0)                NOT NULL CHECK(val_cotactual >= val_cotini),                                             -- Valor actual de la cotizacion 
    val_porreteica                  DECIMAL(2,0)                NOT NULL CHECK( val_porreteica >= 0 AND val_porreteica <= 99),                           --valor de porcentaje de impuesto de retencion ICA   (Este porcentaje se aplica a la factura y a la cotizacion)   
    val_intcorriente                DECIMAL(2,0)                NOT NULL CHECK( val_intcorriente >= 0 AND val_intcorriente <= 99  ),                     --valor de porcentaje de interés de corrección monetaria
    val_pesosXpuntos                DECIMAL(10,0)               NOT NULL CHECK(val_pesosXpuntos > 0),                                                    -- Valor equivalente de pesos por puntos (Ejmp: Por cada 10 mil se da un punto)
    val_interesmora                 DECIMAL(3,0)                NOT NULL CHECK(val_interesmora >= 0 AND val_interesmora <= 100),                         -- Valor porcentaje de interés por mora en cartera
    val_diascartera                 DECIMAL(3,0)                NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 180),                         -- Número de días máximo para castigar cartera
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	             --indicador de borrado lógico
    PRIMARY KEY(id_empresa),
    FOREIGN KEY(id_empresa) REFERENCES tab_pmtros_grales(id_empresa)
); 
------------------------
--TABLA PARA CLIENTES --
------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS tab_clientes
(
    id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),	                           -- identificador del cliente	
    id_tipo        		            VARCHAR(5)                  NOT NULL CHECK(id_tipo ~ '^[A-Z]{2,5}$'),                                   --  tipo de documento						                                           --identificaion del tipo de documentacion
    fec_nacimi      	            DATE                        NOT NULL CHECK (EXTRACT(YEAR FROM AGE(fec_nacimi)) >= 16),                 -- fecha de nacimiento del cliente
    val_edad                        DECIMAL(2,0)                NOT NULL CHECK(val_edad >=0 AND val_edad <=99),                            -- edad del cliente
    ind_genero                      VARCHAR                     NOT NULL CHECK (ind_genero IN ('M','F', 'T', 'NB')),                       -- genero del cliente
    val_puntos                      DECIMAL(10,0)               NOT NULL CHECK (val_puntos >=0 AND val_puntos <=9999999999),               -- Puntaje para valoracion del credito al cliente
    ind_credito                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE=APROBADO O FALSE = NO APROBADO,             -- el cliente puede tener credito para pago
    val_cupocredito                 DECIMAL(12,0)               NOT NULL CHECK(val_cupocredito >= 0 AND val_cupocredito <=999999999999),   -- valor aprobado de credito al cliente
    val_diascartera                 DECIMAL(3,0)                NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 120),           -- Días de cartera para el cliente en facturas
    ind_estado                      BOOLEAN                     NOT NULL DEFAULT TRUE, --TRUE=Activo / FALSE=No activo                     -- Indicador de estado del cliente
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo  -- indicador de borrado lógico
    PRIMARY KEY(id_cliente),
    FOREIGN KEY(id_cliente)         REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_tipo)         REFERENCES tab_tipo_identidad(id_tipo)
);

-------------------------
-- TABLA DE VENDEDORES --
-------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS tab_vendedores
(
	id_vendedor                     VARCHAR(10)                 NOT NULL DEFAULT '0000000000',                                            -- Número de identificación del empleado
    val_porcomision                 DECIMAL(2,0)                NOT NULL CHECK(val_porcomision>=1 AND val_porcomision<=99),               --el porcentaje de la comision que gana el vendedor
    val_ven_acumu                   DECIMAL(15,0)               NOT NULL CHECK(val_ven_acumu>=0 AND val_ven_acumu<=999999999999999),      --El Valor de ventas acomuladas del vendedor
    ind_estado                      BOOLEAN                     NOT NULL DEFAULT TRUE, --TRUE=Activo / FALSE=No activo                    --indicador del estado del vendedor
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo --indicador de borrado lógico
	PRIMARY KEY (id_vendedor),
    FOREIGN KEY(id_vendedor)        REFERENCES tab_empleados(id_empleado)
);

-----------------------------------------
-- TABLA DE ENCABEZADO DE COTIZACIONES --
-----------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_cotizaciones
(
	id_cotizacion                   VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cotizacion))>=8),                             --identificador de la cotizacionss
	id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),           					--identificador del cliente
    id_ciudad                       VARCHAR                     NOT NULL CHECK(LENGTH(id_ciudad)=5),                                        --identificador de la ciudad
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),          					--identificador del vendedor
	fec_cotizacion                  DATE                        NOT NULL CHECK(fec_cotizacion <= CURRENT_DATE),                             --fecha de la creacion de la cotizacion
	fec_vencimiento                 DATE                        NOT NULL CHECK(fec_vencimiento >= fec_cotizacion),                          --fecha de vencimiento de la cotizacion
    val_total_des                   DECIMAL(10,0)               NOT NULL CHECK(val_total_des <= 9999999999),                                 --total de descuennto  de la cotizacion
    val_total_IVA                   DECIMAL(10,0)               NOT NULL CHECK(val_total_IVA <= 9999999999),                                 --total de IVA de la cotizacion
	val_total                       DECIMAL(10,0)               NOT NULL CHECK(val_total <= 9999999999),                                    --total de la cotizacion
	ind_estado                      BOOLEAN                     NOT NULL DEFAULT TRUE, -- TRUE=Vigente / FALSE=Vencida                      --indicador de estado de la cotizacion
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,--TRUE: Borrado lógico (Inactivo) / FALSE: Activo	--indicador de borrado lógico
	PRIMARY KEY (id_cotizacion),
	FOREIGN KEY (id_cliente)        REFERENCES tab_clientes(id_cliente),
    FOREIGN KEY (id_vendedor)       REFERENCES tab_vendedores(id_vendedor),
	FOREIGN KEY (id_ciudad)         REFERENCES tab_ciudades(id_ciudad)
);

--------------------------------------
-- TABLA DE DETALLE DE COTIZACIONES --
--------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_cotizaciones
(
    id_cotizacion                   VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cotizacion)) >=8),                      --identificador de la cotizacion
    id_producto                     DECIMAL(3,0)                NOT NULL CHECK(id_producto >=0 AND id_producto <=999),                --identificador del producto 
    val_cantidad                    DECIMAL(4,0)                NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999),             --cantidad de productos cotizados
    val_pordesc                     DECIMAL(3,0)                NOT NULL CHECK(val_pordesc >=0 AND val_pordesc <=100),                --el porcentaje del descuento
	val_descuento		            DECIMAL(10,0)		        NOT NULL CHECK(val_descuento>=0 AND val_descuento<=9999999999),       --valor de decuento de la cotizacion
    val_iva                         DECIMAL(10,0)               NOT NULL CHECK(val_iva <= 9999999999),	                              --valor del impuesto del iva
    val_reteica                     DECIMAL(10,0)               NOT NULL CHECK(val_reteica <= 9999999999),                            --valor de impuesto de retencion ICA
    val_neto                        DECIMAL(10,0)               NOT NULL CHECK(val_neto <= 9999999999),                               --valor neto de la cotizacion
    val_observa                     VARCHAR(255)                NOT NULL DEFAULT 'Sin observaciones',                                 --observaciones de la cotizacion
	PRIMARY KEY(id_cotizacion,id_producto),
    FOREIGN KEY(id_cotizacion)      REFERENCES tab_enc_cotizaciones(id_cotizacion),
    FOREIGN KEY(id_producto)        REFERENCES tab_productos(id_producto)
);

--------------------------
-- TABLA DE FORMA PAGOS --
--------------------------
CREATE TABLE IF NOT EXISTS tab_forma_pagos
(
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),   --identificador de la forma de pago
	nom_formapago                   VARCHAR                     NOT NULL CHECK(LENGTH(nom_formapago) >= 3),                --nombre de la forma de pago
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,                                    --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	     --indicador de borrado lógico
	PRIMARY KEY(id_formapago)
);

------------------------------------
-- TABLA DE ENCABEZADO DE FACTURA --
------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_facturas
(
	id_factura                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_factura)) >=8),   	             --identificador de la factura
	id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),                    --identificador del cliente
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),                   --identificador del vendedor
	fec_factura                     DATE                        NOT NULL CHECK(fec_factura <= CURRENT_DATE),                     --fecha de la creacion de la factura
    id_ciudad                       VARCHAR                     NOT NULL CHECK(LENGTH(id_ciudad)=5),                             --identificador de la ciudad
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),         --identificador de la forma de pago
    val_total_des                   DECIMAL(10,0)               NOT NULL CHECK(val_total_des <= 9999999999),                     --total de descuennto  de la factura
    val_total_IVA                   DECIMAL(10,0)               NOT NULL CHECK(val_total_IVA <= 9999999999),                     --total de IVA de la factura
	val_total                       DECIMAL(10,0)               NOT NULL CHECK(val_total <= 9999999999),                         --total de la factura
	ind_estado                      BOOLEAN                     NOT NULL DEFAULT TRUE, -- TRUE=Activa / FALSE=Vencida            --indicador de estado de la factura
    ind_cerrada                     BOOLEAN                     NOT NULL DEFAULT FALSE, -- TRUE=impresa / FALSE=Abierta          --indicador de cierre de la factura impresa
	PRIMARY KEY (id_factura),
	FOREIGN KEY (id_cliente)        REFERENCES tab_clientes(id_cliente),
    FOREIGN KEY (id_ciudad)         REFERENCES tab_ciudades(id_ciudad),
	FOREIGN KEY (id_vendedor)       REFERENCES tab_vendedores(id_vendedor),
	FOREIGN KEY (id_formapago)      REFERENCES tab_forma_pagos(id_formapago)
);

---------------------------------
-- TABLA DE DETALLE DE FACTURA --
---------------------------------
CREATE TABLE IF NOT EXISTS tab_det_facturas
(
    id_factura                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_factura)) >=8),                    --identificador de la factura
    id_producto                     DECIMAL(3,0)                NOT NULL CHECK(id_producto >=0 AND id_producto <=999),           --identificador del producto 
    val_cantidad                    DECIMAL(4,0)                NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999),        --cantidad de venta del producto
	val_bruto			            DECIMAL(10,0)		        NOT NULL CHECK (val_bruto >=0 AND val_bruto<=9999999999),        --valor bruto de la factura
    por_descuento                   DECIMAL(3,0)                NOT NULL CHECK(por_descuento >=0 AND por_descuento <= 100),      --el porcentaje del descuento de la factura
    val_descuento                   DECIMAL(10,0)               NOT NULL CHECK(val_descuento <= 9999999999),                     --valor descuento de la factura
    val_iva                         DECIMAL(10,0)               NOT NULL CHECK(val_iva >=0 AND val_iva <= 9999999999),	         --valor del impuesto del iva
    val_reica                       DECIMAL(10,0)               NOT NULL CHECK(val_reica >= 0 AND val_reica <= 9999999999),      --valor de impuesto de retencion ICA
    val_neto                        DECIMAL(10,0)               NOT NULL CHECK(val_neto >= 0 AND val_neto <= 9999999999),	     --valor neto de la factura	
    val_observa                     VARCHAR(255)                NOT NULL DEFAULT 'Sin observaciones',                            --observaciones de la factura
    PRIMARY KEY(id_factura,id_producto),
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas(id_factura),
    FOREIGN KEY(id_producto)        REFERENCES tab_productos(id_producto)
);
---------------------------------
-- TABLA DE FACTURA ELECTRONICA--
---------------------------------
CREATE TABLE IF NOT EXISTS tab_fac_electronicas
(
    id_factura                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_factura)) >=8),                                    --Identificador de factura
    cufe                            VARCHAR                     NOT NULL UNIQUE,                                                                 --Código Único de Factura Electrónica (CUFE) generado por el sistema de facturación electrónica    
    qr_code                         TEXT                        NOT NULL UNIQUE,                                                                 --Código QR generado por el sistema de facturación electrónica                        
    xml_firmado                     TEXT                        NOT NULL UNIQUE,                                                                 --Archivo XML firmado de la factura electrónica       
    estado_dian                     VARCHAR(20)                 NOT NULL CHECK(estado_dian IN('pendiente', 'enviado', 'rechazado','aceptado')),  --Estado de la factura electrónica según la DIAN
    fec_envio_dian                  DATE                        NOT NULL CHECK(fec_envio_dian <= CURRENT_DATE),                                  --Fecha de envío de la factura electrónica a la DIAN
    mensaje_dian                    VARCHAR(500)                NOT NULL DEFAULT 'Sin observaciones',                                            --Mensaje de respuesta de la DIAN al enviar la factura electrónica    
    -- respuesta_dian               VARCHAR(500)                NULL,                                                                            --Respuesta de la DIAN al consultar el estado de la factura electrónica
    PRIMARY KEY(id_factura),
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas(id_factura)
);

------------------------
-- TABLA DE LOS PAGOS --
------------------------
CREATE TABLE IF NOT EXISTS tab_pagos
(
    id_pago          	            DECIMAL(5,0)                 NOT NULL CHECK(id_pago >=0 AND id_pago<=99999), 							--identificador de pago
    id_factura                      VARCHAR(10)                  NOT NULL CHECK(LENGTH(TRIM(id_factura)) >=8),								--identificador de la factura
    fec_pago                        DATE                         NOT NULL CHECK(fec_pago <=CURRENT_DATE),     								--fecha de Realizacion del pago
    val_pagar                       DECIMAL(12,0)                NOT NULL  CHECK(val_pagar >=0 AND val_pagar<=999999999999),				--valor del pago a realizar
    referencia_pago                 VARCHAR                      NOT NULL  CHECK(LENGTH(referencia_pago) <=100),							--referencia de pago	
    ind_est_pag                     VARCHAR                      NOT NULL  CHECK(ind_est_pag IN('APROBADO','RECHAZADO','PENDIENTE')),		--estado de pago
    val_observa       	            VARCHAR                      NOT NULL  DEFAULT 'Sin observaciones',										--observaciones de la factura
    ind_borrado                     BOOLEAN                      NOT NULL  DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	--indicador de borrado lógico					
    PRIMARY KEY (id_pago),   
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas (id_factura)
    
);
----------------------
--TABLA DE CARTERAS --
----------------------
-- ESTA TABLA ES PARA LAS FACTURAS QUE SE OBTUVIERON POR MEDIO DE CREDITO
CREATE TABLE IF NOT EXISTS tab_carteras
(
    id_cartera                      DECIMAL(5,0)                NOT NULL CHECK(id_cartera >=0 AND id_cartera <=99999),					     --identificador del credito
    id_factura                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_factura)) >=8),                                --Identificador de factura
    val_monto                       DECIMAL(12,0)               NOT NULL CHECK(val_monto >=0 AND val_monto <=999999999999),				     --valor de la cuota a pagar
    val_pendiente                   DECIMAL(12,0)               NOT NULL CHECK(val_pendiente >=0),		                                     --saldo pendiente a pagar de la cartera
    fec_ini_pago                    DATE                        NOT NULL CHECK(fec_ini_pago >= CURRENT_DATE),								 --fecha inicial del pago a realizar
    fec_prox_pago                   DATE                        NOT NULL CHECK(fec_prox_pago >= fec_ini_pago),								 --Fecha del proximo pago a realizar
    val_intecorri                   DECIMAL(10,0)               NOT NULL CHECK(val_intecorri>= 0),							                 --valor de intereses de corriente de la cartera
    val_mora                        DECIMAL(10,0)               NOT NULL CHECK(val_mora>=0),							                     --valor de moras de la cartera
    id_pago                         DECIMAL(5,0)                NULL CHECK(id_pago >=0 AND id_pago<=99999),                                  --identificador de pago
    ind_estado                      VARCHAR                     NOT NULL CHECK(ind_estado IN ('Pagada','vencida','pendiente','perdida')),    --indicador de estado de la cartera
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	 --indicador de borrado lógico
    PRIMARY KEY(id_cartera),
    FOREIGN KEY(id_factura)       REFERENCES tab_enc_facturas(id_factura),
    FOREIGN KEY(id_pago)          REFERENCES tab_pagos(id_pago)
);

-- =============================================================================
-- CATÁLOGO DE MOTIVOS DIAN
-- =============================================================================
CREATE TABLE IF NOT EXISTS tab_motivo_nota
(
    id_motivo_nota      DECIMAL(3,0)    NOT NULL CHECK(id_motivo_nota > 0),                     -- Identificador del motivo de la nota
    ind_tipo_nota       BOOLEAN         NOT NULL DEFAULT FALSE, -- FALSE: CREDITO / TRUE:DEBITO --INDICADOR DE TIPO DE NOTA
    cod_dian            DECIMAL(1,0)    NOT NULL CHECK(cod_dian >= 1 AND cod_dian <= 6),        -- NC: códigos 1-6 | ND: códigos 1-3 (Res. 000042)
    nom_motivo          VARCHAR(100)    NOT NULL CHECK(LENGTH(TRIM(nom_motivo)) >= 5),          -- Descripción del motivo de la nota (Ej: "Devolución total por incumplimiento de pago")
    afecta_inventario   BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- TRUE: La nota afecta inventario  / FALSE: No afecta inventario
    afecta_cliente      BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- TRUE: La nota afecta tercero / FALSE: No afecta tercero 
    afecta_cartera      BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- Solo afecta cartera en caso de que el motivo sea por incumplimiento de pago o por corrección de datos (cod_dian = 3 o 4)
    afecta_comision     BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- Solo afecta comisión en caso de que el motivo sea por devolución total o parcial (cod_dian = 1 o 2)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- Solo los motivos activos pueden ser usados en la creación de notas
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo
    PRIMARY KEY(id_motivo_nota)  
);


-- =============================================================================
    -- ENCABEZADO DE LA NOTA
-- =============================================================================
CREATE TABLE IF NOT EXISTS tab_enc_notas
(
    id_nota             DECIMAL(10,0)   NOT NULL CHECK(id_nota > 0),                                                                                                    -- Identificador único de la nota de crédito o débito
    ind_tipo_nota       BOOLEAN         NOT NULL DEFAULT FALSE, -- FALSE: CREDITO / TRUE:DEBITO                                                                         --INDICADOR DE TIPO DE NOTA                                                                                         -- Relación con el tipo de nota (1=NC, 2=ND)
    id_motivo_nota      DECIMAL(3,0)    NOT NULL CHECK(id_motivo_nota > 0),                                                                                             -- Relación con el motivo de la nota (ver tabla tab_motivo_nota)                                                                                                                      --identificador de la empresa
    id_cliente          VARCHAR(10)     NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >= 6),                                                                                  -- Relación con el cliente al que se le emite la nota 
    id_vendedor         VARCHAR(10)     NULL CHECK(id_vendedor IS NULL OR LENGTH(TRIM(id_vendedor)) >= 6),                                                              -- Relación con el vendedor asociado a la nota. Puede ser NULL si no se desea asociar un vendedor.
    id_factura_ref      VARCHAR(10)     NOT NULL CHECK(LENGTH(TRIM(id_factura_ref)) >= 8),                                                                              -- Relación con la factura a la que se refiere la nota. Se asume que toda nota hace referencia a una factura, aunque en algunos casos podría no ser obligatorio.
    cufe_ref            VARCHAR(96)     NOT NULL,                                                                                                                       -- CUFE de la factura referenciada (SHA-384, 96 chars)
    prefijo_nota        VARCHAR(4)      NOT NULL CHECK(LENGTH(TRIM(prefijo_nota)) >= 1),                                                                                -- 'NC' o 'ND'
    num_nota            DECIMAL(10,0)   NOT NULL CHECK(num_nota > 0),                                                                                                   -- Número consecutivo de la nota por empresa y tipo de nota 
    fec_emi_nota        DATE            NOT NULL CHECK(fec_emi_nota <= CURRENT_DATE),                                                                                   --   Fecha de emisión de la nota 
    fec_ven_nota        DATE            NOT NULL CHECK(fec_ven_nota >= fec_emi_nota),                                                                                   -- En NC = fec_emi_nota; en ND puede ser posterior
    val_subtotal        DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_subtotal >= 0),                                                                                    -- Valor subtotal de la nota                                     
    val_descuento       DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_descuento >= 0),                                                                                   -- Valor total de descuentos aplicados en la nota 
    val_iva             DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_iva >= 0),                                                                                         -- Valor total de IVA aplicado en la nota 
    val_total           DECIMAL(15,0)   NOT NULL CHECK(val_total >= 0),                                                                                                 -- Valor total de la nota . En NC este valor es el que se le descuenta al cliente, en ND es el que se le suma.
    val_aplicado        DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_aplicado >= 0),                                                                                    -- Valor total aplicado de la nota a facturas o cartera . En NC este valor se va descontando del val_total a medida que se aplica la nota, en ND se va sumando al val_total.
    val_pendiente       DECIMAL(15,0)   NOT NULL           CHECK(val_pendiente >= 0),                                                                                   -- Valor pendiente por aplicar de la nota a facturas o cartera . En NC este valor se va descontando del val_total a medida que se aplica la nota, en ND se va sumando al val_total.
    observacion         VARCHAR(255)    NOT NULL DEFAULT 'Sin observaciones',                                                                                           -- Observaciones generales de la nota
     ind_estado          VARCHAR(20)    NOT NULL CHECK(ind_estado IN ( 'BORRADOR', 'EMITIDA', 'ENVIADA_DIAN', 'ACEPTADA_DIAN', 'RECHAZADA_DIAN', 'ANULADA' )),          -- Indicador del estado de la nota en su ciclo de vida
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                                                                         -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo
    PRIMARY KEY(id_nota),
    FOREIGN KEY(id_motivo_nota) REFERENCES tab_motivo_nota(id_motivo_nota),
    FOREIGN KEY(id_cliente)     REFERENCES tab_clientes(id_cliente),
    FOREIGN KEY(id_vendedor)    REFERENCES tab_vendedores(id_vendedor),
    FOREIGN KEY(id_factura_ref) REFERENCES tab_enc_facturas(id_factura),
    UNIQUE( prefijo_nota, num_nota)
);
CREATE INDEX IF NOT EXISTS idx_enc_notas_factura_ref ON tab_enc_notas(id_factura_ref);
CREATE INDEX IF NOT EXISTS idx_enc_notas_cliente_fecha ON tab_enc_notas(id_cliente, fec_emi_nota);
CREATE INDEX IF NOT EXISTS idx_enc_notas_estado ON tab_enc_notas(ind_estado) WHERE ind_borrado = FALSE;

-- =============================================================================
--  – DETALLE DE NOTA 
-- =============================================================================
CREATE TABLE IF NOT EXISTS tab_det_notas
(
    id_nota             DECIMAL(10,0)   NOT NULL CHECK(id_nota > 0 ),                                                        -- identificador de la nota al que se relaciona el detalle 
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto >= 0 AND id_producto <= 999),                            -- identificador del producto o servicio de la línea de detalle
    val_cantidad        DECIMAL(4,0)    NOT NULL CHECK(val_cantidad > 0 AND val_cantidad <= 9999),                          -- cantidad de producto o servicio de la línea de detalle
    val_precio_unit     DECIMAL(15,0)   NOT NULL CHECK(val_precio_unit >= 0),                                               -- valor del precio unitario del producto o servicio de la línea de detalle
    por_descuento       DECIMAL(3,0)    NOT NULL DEFAULT 0 CHECK(por_descuento >= 0 AND por_descuento <= 100),              -- porcentaje de descuento aplicado en la línea de detalle (en caso de que el descuento sea proporcional al porcentaje, sino se puede calcular a partir del val_descuento)
    val_descuento       DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_descuento >= 0 AND val_descuento <=999999999999999),   --   valor del descuento aplicado en la línea de detalle
    val_iva             DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(val_iva >= 0 AND val_iva <=999999999999999),               -- valor del IVA aplicado en la línea de detalle   
    val_neto            DECIMAL(15,0)   NOT NULL CHECK(val_neto >= 0 AND val_neto <=999999999999999),                       -- valor neto
    PRIMARY KEY(id_nota, id_producto),
    FOREIGN KEY(id_nota) REFERENCES tab_enc_notas(id_nota),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);
 
-- =============================================================================
-- TRANSMISIÓN ELECTRÓNICA DIAN (CUDE, XML, QR)
-- =============================================================================
CREATE TABLE IF NOT EXISTS tab_nota_elect
(
    id_nota             DECIMAL(10,0)   NOT NULL CHECK(id_nota > 0),                                                        -- identificador de la nota al que se relaciona la información electrónica
    cude                VARCHAR(96)     NOT NULL UNIQUE,                                                                    -- Código Único de Documento Electrónico (CUDE) 
    xml_firmado         TEXT            NOT NULL UNIQUE,                                                                    -- Archivo XML firmado de la nota electrónica
    qr_code             TEXT            NOT NULL UNIQUE,                                                                    -- Código QR generado por el sistema de facturación electrónica
    estado_dian         VARCHAR(20)     NOT NULL CHECK(estado_dian IN ('pendiente','enviado','rechazado','aceptado')),      -- Estado de la nota electrónica según la DIAN
    fec_envio_dian      DATE            NOT NULL DEFAULT CURRENT_DATE CHECK(fec_envio_dian <= CURRENT_DATE),                -- Fecha de envío de la nota electrónica a la DIAN
    mensaje_dian        VARCHAR(500)    NOT NULL DEFAULT 'SIN MENSAJE',                                                     -- Mensaje de respuesta de la DIAN al enviar la nota electrónica 
    PRIMARY KEY(id_nota),
    FOREIGN KEY(id_nota) REFERENCES tab_enc_notas(id_nota)
);
 
 
-- =============================================================================
-- APLICACIÓN DE NOTAS A FACTURAS O CARTERA
-- =============================================================================
CREATE TABLE IF NOT EXISTS tab_aplicacion_nota
(
    id_aplicacion           DECIMAL(10,0)   NOT NULL CHECK(id_aplicacion > 0),                                                  -- Identificador único de la aplicación de la nota a una factura o cartera
    id_nota                 DECIMAL(10,0)   NOT NULL CHECK(id_nota > 0),                                                        -- Relación con la nota que se está aplicando
    id_factura              VARCHAR(10)     NULL CHECK(id_factura IS NULL OR LENGTH(TRIM(id_factura)) >= 8),                    -- Relación con la factura a la que se aplica la nota. Puede ser NULL si la nota se aplica a cartera en lugar de a una factura específica.
    id_cartera              DECIMAL(5,0)    NULL CHECK(id_cartera IS NULL OR (id_cartera >= 0 AND id_cartera <= 99999)),        -- Relación con la cartera a la que se aplica la nota. Puede ser NULL si la nota se aplica a una factura específica en lugar de a cartera.
    valor_aplicado          DECIMAL(15,0)   NOT NULL CHECK(valor_aplicado > 0),                                                 -- Valor de la nota que se está aplicando en esta aplicación. 
    saldo_anterior_nota     DECIMAL(15,0)   NOT NULL CHECK(saldo_anterior_nota >= 0),                                           -- Saldo de la nota antes de aplicar esta aplicación. 
    saldo_despues_nota      DECIMAL(15,0)   NOT NULL CHECK(saldo_despues_nota >= 0),                                            -- Saldo de la nota después de aplicar esta aplicación. 
    fec_aplicacion          DATE            NOT NULL DEFAULT CURRENT_DATE,                                                      -- Fecha en la que se realiza la aplicación de la nota. No puede ser una fecha futura.
    observacion             VARCHAR(250)    NOT NULL DEFAULT 'Sin observaciones',                                               -- Observaciones específicas de esta aplicación de la nota 
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                                                             -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo
 
    PRIMARY KEY(id_aplicacion),
    FOREIGN KEY(id_nota) REFERENCES tab_enc_notas(id_nota),
    FOREIGN KEY(id_factura) REFERENCES tab_enc_facturas(id_factura),
    FOREIGN KEY(id_cartera) REFERENCES tab_carteras(id_cartera),
 
    -- La nota aplica a UNA factura O a UNA cartera, nunca a ambas ni a ninguna
    CONSTRAINT chk_aplica_exactamente_uno CHECK ((id_factura IS NOT NULL AND id_cartera IS NULL) OR (id_factura IS NULL AND id_cartera IS NOT NULL))
);

 

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_pmtros_facturacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_motivo_nota
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_enc_notas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_det_notas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail  AFTER INSERT OR UPDATE OR DELETE ON tab_nota_elect
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_aplicacion_nota
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_pagos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_carteras
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_fac_electronicas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_det_facturas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_enc_facturas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_det_cotizaciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_enc_cotizaciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_vendedores
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_clientes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_forma_pagos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

