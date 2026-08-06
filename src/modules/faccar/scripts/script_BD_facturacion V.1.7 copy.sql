
-- SENTENCIA DE ELIMINACION DEL ESQUEMA ---
DROP SCHEMA IF EXISTS FACCAR;  -- Facturación y Cartera
-- SENTENCIA DE CREACON DEL ESQUEMA ---
CREATE SCHEMA IF NOT EXISTS FACCAR;
----------------------------------------------------------
--TABLA PARA PARÁMETROS DE PROCESO FACTURACIÓN Y CARTERA -
----------------------------------------------------------

CREATE TABLE faccar.tab_pmtros_facturacion
(
    val_res_aut                     DECIMAL(13,0)               NOT NULL CHECK(val_res_aut>=1000000000000 AND val_res_aut <=9999999999999),      -- Numero de resolucion de autorizacion de factura
    fec_venc                        DATE                        NOT NULL,                                                                       -- fecha de vencimiento de la rango 
    id_empresa                      DECIMAL(10,0)               NOT NULL CHECK(id_empresa >=1000000000 AND id_empresa<=9999999999),               --identificador de la empresa                                                                  
    fec_res_aut                     DATE                        NOT NULL,                                                                       -- fecha de creacion de la resolucion autorizada
    val_prefijo                     VARCHAR(4)                  NOT NULL CHECK(LENGTH(TRIM(val_prefijo)) >=1 AND LENGTH(TRIM(val_prefijo)) <=4 ),    --el prefijo de la factura
	val_facini			            DECIMAL(6,0)		        NOT NULL CHECK(val_facini > 0),                                                 -- Valor inicial de la factura 
    val_facactual                   DECIMAL(6,0)                NOT NULL CHECK(val_facactual >= val_facini AND val_facactual <= val_facfin),    -- Valor actual de la factura 
	val_facfin			            DECIMAL(6,0)		        NOT NULL CHECK(val_facfin > 0 AND val_facfin > val_facini),                     -- Valor final de la factura 
    val_pesosXpuntos                DECIMAL(10,0)               NOT NULL,                                                                       -- Valor equivalente de pesos por puntos (Ejmp: Por cada 10 mil se da un punto)
    val_interesmora                 DECIMAL(3,0)                NOT NULL CHECK(val_interesmora >= 0 AND val_interesmora <= 100),                -- Valor porcentaje de interés por mora en cartera
    val_diascartera                 DECIMAL(3,0)                NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 180),                -- Número de días máximo para castigar cartera
    PRIMARY KEY(id_empresa)
); 

------------------------
--TABLA PARA CLIENTES --
------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS faccar.tab_clientes
(
    id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),	                                                                 --identificador del cliente							
    ind_tipodoc                     DECIMAL(8,0)                NOT NULL CHECK(ind_tipodoc >= 1 AND ind_tipodoc <= 8), --1=CC 2=TI 3=NIT 4=CE 5=PP 6=PEP 7=CS 8=TMF              --indicador del tipo de documento
    fec_nacimi      	            DATE                        NOT NULL CHECK (EXTRACT(YEAR FROM AGE(fec_nacimi)) >= 16),                                                       --fecha de nacimiento del cliente
    val_edad                        DECIMAL(2,0)                NOT NULL CHECK(val_edad >=0 AND val_edad <=99),                                                                  --edad del cliente
    ind_genero                      VARCHAR                     NOT NULL CHECK (ind_genero IN ('M','F', 'T', 'NB')),                                                             --genero del cliente
    val_puntos                      DECIMAL(10,0)               NOT NULL CHECK (val_puntos >=0 AND val_puntos <=9999999999),                                                     --Puntaje para valoracion del credito al cliente
    ind_credito                     BOOLEAN                     NOT NULL, --TRUE=APROBADO O FALSE = NO APROBADO,                                                                 --el cliente puede tener credito para pago
    val_cupocredito                 DECIMAL(12,0)               NOT NULL CHECK(val_cupocredito >= 0 AND val_cupocredito <=999999999999),                                         --valor aprobado de credito al cliente
    val_diascartera                 DECIMAL(3,0)                NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 120),                                                 -- Días de cartera para el cliente en facturas
    ind_estado                      BOOLEAN                     NOT NULL, --TRUE=Activo / FALSE=No activo                                                                        -- Indicador de estado del cliente
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	                                     --indicador de borrado lógico
    PRIMARY KEY(id_cliente),
    FOREIGN KEY(id_cliente)         REFERENCES public.tab_terceros(id_tercero)

);

---------------------------------------------------------
--TABLA DE PRODUCTOS PROPIOS PARA FACTURACIÓN A CLIENTES -
----------------------------------------------------------
 CREATE TABLE IF NOT EXISTS faccar.tab_productos
(
    id_producto                     DECIMAL(3,0)                NOT NULL CHECK(id_producto >0 AND id_producto <=999), 				--identificador del producto
    ind_tip_producto                BOOLEAN                     NOT NULL, --TRUE=PRODUCTO O FALSE=SERVICIO,							--indicador del tipo de producto 
    nom_producto                    VARCHAR                     NOT NULL CHECK (LENGTH(nom_producto) <=70),							--nombre del producto
    val_exist                       DECIMAL(4,0)                NOT NULL CHECK(val_exist>0 AND val_exist <= 9999),                   --cantidad del producto para venta
    val_poriva                      DECIMAL(2,0)                NOT NULL CHECK(val_poriva >= 0 AND val_poriva <= 99),               --porcentaje de iva del producto
    val_venta                       DECIMAL(11,0)               NOT NULL CHECK(val_venta >=0 AND val_venta <=99999999999),          --valor de la venta
    ind_disponible                  BOOLEAN                     NOT NULL, --TRUE=DISPONIBLE O FALSE =NO DISPONIBLE,					--indicador de disponibilidad
    ind_estado                      BOOLEAN                     NOT NULL,--TRUE=ACTIVO O FALSE=INACTIVO								--indicador de estado del producto
    PRIMARY KEY(id_producto)
);

-------------------------
-- TABLA DE VENDEDORES --
-------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS faccar.tab_vendedores
(
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),                                                                   --identificador del vendedor
    ind_tipodoc                     DECIMAL(7,0)                NOT NULL CHECK(ind_tipodoc >= 1 AND ind_tipodoc <= 7),  --1=CC  2=NIT 3=CE 4=PP 5=PEP 6=CS                       --indicador del tipo de documento
    fec_nacimi      	            DATE                        NOT NULL CHECK (EXTRACT(YEAR FROM AGE(fec_nacimi)) >= 16),                                                       --fecha de nacimiento del cliente
    val_edad                        DECIMAL(2,0)                NOT NULL CHECK(val_edad >= 0 AND val_edad <= 99),                                                                --edad del cliente
    ind_genero                      VARCHAR                     NOT NULL CHECK (ind_genero IN ('M', 'F', 'T', 'NB')),                                                            --genero del cliente   
    val_porcomision                 DECIMAL(2,0)                NULL     CHECK(val_porcomision>=1 AND val_porcomision<=99),                                                          --el porcentaje de la comision que gana el vendedor
	val_comision                    DECIMAL(7,0)                NULL     CHECK(val_comision > 0 AND val_comision<=9999999),                                                          --el valor de la comision
    val_ven_acomu                   DECIMAL(3,0)                NOT NULL CHECK(val_ven_acomu>=0 AND val_ven_acomu<=999),                                                         --El Valor de ventas acomuladas del vendedor
    ind_estado                      BOOLEAN                     NOT NULL, --TRUE=Activo / FALSE=No activo                                                                        --indicador del estado del vendedor
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	                                     --indicador de borrado lógico
	PRIMARY KEY (id_vendedor),
    FOREIGN KEY(id_vendedor)        REFERENCES public.tab_terceros(id_tercero)
);

-----------------------------------------
-- TABLA DE ENCABEZADO DE COTIZACIONES --
-----------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_enc_cotizaciones
(
	id_cotizacion                   DECIMAL(6,0)                NOT NULL CHECK(id_cotizacion>=0 AND id_cotizacion<=999999),                 --identificador de la cotizacionss
	id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),           					--identificador del cliente
    id_ciudad                       VARCHAR                     NOT NULL,                                                                   --indificador de la ciudad
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),          					--identificador del vendedor
	fec_cotizacion                  DATE                        NOT NULL CHECK(fec_cotizacion <= CURRENT_DATE),                              --fecha de la creacion de la cotizacion
	fec_vencimiento                 DATE                        NOT NULL CHECK(fec_vencimiento >= fec_cotizacion),                          --fecha de vencimiento de la cotizacion
	val_total                       DECIMAL(10,0)               NOT NULL CHECK(val_total <= 9999999999),                                    --total de la cotizacion
	ind_estado                      BOOLEAN                     NOT NULL, -- TRUE=Vigente / FALSE=Vencida                                   --indicador de estado de la cotizacion
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,--TRUE: Borrado lógico (Inactivo) / FALSE: Activo	--indicador de borrado lógico
	PRIMARY KEY (id_cotizacion),
	FOREIGN KEY (id_cliente)        REFERENCES faccar.tab_clientes(id_cliente),
    FOREIGN KEY (id_vendedor)       REFERENCES faccar.tab_vendedores(id_vendedor),
	FOREIGN KEY (id_ciudad)         REFERENCES public.tab_ciudades(id_ciudad)
);

--------------------------------------
-- TABLA DE DETALLE DE COTIZACIONES --
--------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_det_cotizaciones
(
    id_cotizacion                   DECIMAL(6,0)                NOT NULL CHECK(id_cotizacion >=0 AND id_cotizacion <=999999),           --identificador de la cotizacion
    id_producto                     DECIMAL(3,0)                NOT NULL CHECK(id_producto >=0 AND id_producto <=999),                  --identificador del producto 
    val_cantidad                    DECIMAL(4,0)                NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999),               --cantidad de productos cotizados
    val_bruto                       DECIMAL(12,0)               NOT NULL CHECK(val_bruto <= 9999999999),                                --valor bruto de  los productos cotizados
    val_pordesc                     DECIMAL(3,0)                NOT NULL CHECK(val_pordesc >=0 AND val_pordesc <=100),                  --el porcentaje del descuento
	val_descuento		            DECIMAL(10,0)		        NOT NULL CHECK(val_descuento>=0 AND val_descuento<=9999999999),         --valor de decuento de la cotizacion
    val_iva                         DECIMAL(10,0)               NOT NULL CHECK(val_iva <= 9999999999),	                                --valor del impuesto del iva
    val_reteica                     DECIMAL(10,0)               NOT NULL CHECK(val_reteica <= 9999999999),                              --valor de impuesto de retencion ICA
    val_neto                        DECIMAL(10,0)               NOT NULL CHECK(val_neto <= 9999999999),                                 --valor neto de la cotizacion
    val_observa                     VARCHAR                     NOT NULL,                               --observaciones de la cotizacion
	PRIMARY KEY(id_cotizacion,id_producto),
    FOREIGN KEY(id_cotizacion)      REFERENCES faccar.tab_enc_cotizaciones(id_cotizacion),
    FOREIGN KEY(id_producto)        REFERENCES faccar.tab_productos(id_producto)
);

--------------------------
-- TABLA DE FORMA PAGOS --
--------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_forma_pagos
(
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),                        --identificador de la forma de pago
	nom_formapago                   VARCHAR                     NOT NULL CHECK(LENGTH(nom_formapago) >= 3),                                     --nombre de la forma de pago
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
	PRIMARY KEY(id_formapago)
);

------------------------------------
-- TABLA DE ENCABEZADO DE FACTURA --
------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_enc_facturas
(
	id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >=0 AND id_factura<=999999),	                        --identificador de la factura
	id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),            						--identificador del cliente
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),          							--identificador del vendedor
	fec_factura                     DATE                        NOT NULL CHECK(fec_factura <= CURRENT_DATE),                                     --fecha de la creacion de la factura
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),                        --identificador de la forma de pago
	val_total                       DECIMAL(10,0)               NOT NULL CHECK(val_total <= 9999999999),                                        --total de la factura
	ind_estado                      BOOLEAN                     NOT NULL, -- TRUE=Activa / FALSE=Vencida,                                       --estado en el que se encuentra la factura
	PRIMARY KEY (id_factura),
	FOREIGN KEY (id_cliente)        REFERENCES faccar.tab_clientes(id_cliente),
	FOREIGN KEY (id_vendedor)       REFERENCES faccar.tab_vendedores(id_vendedor),
	FOREIGN KEY (id_formapago)      REFERENCES faccar.tab_forma_pagos(id_formapago)
);

---------------------------------
-- TABLA DE DETALLE DE FACTURA --
---------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_det_facturas
(
    id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >=0 AND id_factura <=99999),                          --identificador de la factura
    id_producto                     DECIMAL(3,0)                NOT NULL CHECK(id_producto >=0 AND id_producto <=999),                          --identificador del producto 
    val_cantidad                    DECIMAL(4,0)                NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999),                       --cantidad de venta del producto
	val_bruto			            DECIMAL(10,0)		        NOT NULL CHECK (val_bruto >=0 AND val_bruto<=9999999999),                       --valor bruto de la factura
    por_descuento                   DECIMAL(3,0)                NOT NULL CHECK(por_descuento >=0 AND por_descuento <= 100),                     --el porcentaje del descuento de la factura
    val_descuento                   DECIMAL(10,0)               NOT NULL CHECK(val_descuento <= 9999999999),                                    --valor descuento de la factura
    val_iva                         DECIMAL(10,0)               NOT NULL CHECK(val_iva >=0 AND val_iva <= 9999999999),	                        --valor del impuesto del iva
    val_reica                       DECIMAL(10,0)               NOT NULL CHECK(val_reica >= 0 AND val_reica <= 9999999999),                     --valor de impuesto de retencion ICA
    val_neto                        DECIMAL(10,0)               NOT NULL CHECK(val_neto >= 0 AND val_neto <= 9999999999),	                    --valor neto de la factura	
    val_observa                     VARCHAR,                                                                                            --observaciones de la factura
    PRIMARY KEY(id_factura,id_producto),
    FOREIGN KEY(id_factura)         REFERENCES faccar.tab_enc_facturas(id_factura),
    FOREIGN KEY(id_producto)        REFERENCES faccar.tab_productos(id_producto)
);

---------------------------------
-- TABLA DE FACTURA ELECTRONICA--
---------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_fac_electronicas
(
    id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >=0 AND id_factura<=99999),                                           --Identificador de factura
    cufe                            VARCHAR                     NOT NULL UNIQUE,                                                                                --Código Único de Factura Electrónica (CUFE) generado por el sistema de facturación electrónica    
    qr_code                         TEXT                        NULL,                                                                                           --Código QR generado por el sistema de facturación electrónica                        
    xml_firmado                     TEXT                        NULL,                                                                                           --Archivo XML firmado de la factura electrónica       
    estado_dian                     VARCHAR(20)                 NOT NULL CHECK(estado_dian IN('pendiente', 'enviado', 'rechazado','aceptado')),                 --Estado de la factura electrónica según la DIAN
    fec_envio_dian                  DATE                        NOT NULL CHECK(fec_envio_dian <= CURRENT_DATE),                                                  --Fecha de envío de la factura electrónica a la DIAN
    mensaje_dian                    VARCHAR(500)                NULL,                                                                                           --Mensaje de respuesta de la DIAN al enviar la factura electrónica    
    -- respuesta_dian               VARCHAR(500)                NULL,                                                                                        --Respuesta de la DIAN al consultar el estado de la factura electrónica
    PRIMARY KEY(id_factura),
    FOREIGN KEY(id_factura)         REFERENCES faccar.tab_enc_facturas(id_factura)
);

-- --------------------------------
-- TABLA DE CONDICIONES DE PAGOS --
-- ---------------------------------------------------
-- ESTA TABLA ES PARA LOS USUARIOS QUE TIENEN CREDITO
-- APROBADO PARA PODER REALIZAR EL PAGO DE LA FACTURA
-- POR ESTE MEDIO LA FACTURA
-- ---------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_cond_pagos
(
	id_cond_pago                    DECIMAL(5,0)                NOT NULL CHECK(id_cond_pago >= 0 AND id_cond_pago <= 99999),                    --identificador de condicion de pago
    id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >= 0 AND id_factura <= 999999),                       --identificador de la factura
	val_plazofinanciado             DECIMAL(3,0)                NOT NULL CHECK(val_plazofinanciado >= 0 AND val_plazofinanciado <= 120),        --plazo al que se financio el la cartera
	val_tasainteres                 DECIMAL(3,0)                NOT NULL CHECK(val_tasainteres >= 0 AND val_tasainteres <= 100),                --la tasa de interes las condicones de pago
	val_total_finan                 DECIMAL(10,0)               NOT NULL CHECK(val_total_finan >= 0 AND val_total_finan <= 9999999999),         --valor total finaciado
	val_observacion                 VARCHAR                     NOT NULL CHECK(LENGTH(val_observacion)<=255),                                   --descripcion de la condicon del pago
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	        --indicador de borrado lógico
	PRIMARY KEY (id_cond_pago),
	FOREIGN KEY (id_factura)        REFERENCES faccar.tab_enc_facturas(id_factura)
);

----------------------
--TABLA DE CARTERAS --
----------------------
-- ESTA TABLA ES PARA LOS QUE REALIZARON EL PAGO DE LA FACTURA POR MEDIO DE CREDITO
CREATE TABLE IF NOT EXISTS faccar.tab_carteras
(
    id_cartera                      DECIMAL(5,0)                NOT NULL CHECK(id_cartera >=0 AND id_cartera <=99999),					    --identificador del credito
    id_cond_pago                    DECIMAL(5,0)                NOT NULL CHECK(id_cond_pago >=0 AND id_cond_pago <=99999),				    --identificador de condicion de pago
    val_monto                       DECIMAL(12,0)               NOT NULL CHECK(val_monto >=0 AND val_monto <=999999999999),				    --valor de la cuota a pagar
    val_pendiente                   DECIMAL(12,0)               NOT NULL CHECK(val_pendiente >=0),		    --saldo pendiente a pagar de la cartera
    fec_pago                        DATE                        NOT NULL CHECK(fec_pago <= CURRENT_DATE),									--fecha  a realizar el pago
    fec_prox_pago                   DATE                        NOT NULL CHECK(fec_prox_pago >= fec_pago),								    --Fecha del proximo pago a realizar
    dias_mora                       DECIMAL(3,0)                NOT NULL CHECK(dias_mora >=0 AND dias_mora<=120),							--dias de moras de la cartera
    ind_estado                      VARCHAR                     NOT NULL CHECK(ind_estado IN ('Pagada','vencida','pendiente','perdida')),   --indicador de estado de la cartera
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	--indicador de borrado lógico
    PRIMARY KEY(id_cartera),
    FOREIGN KEY(id_cond_pago)       REFERENCES faccar.tab_cond_pagos(id_cond_pago)
);

--------------------------------------
-- TABLA DE SEGUIMIENTO DE CARTERAS --
--------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_segui_carteras
(
	id_segui_cart                   DECIMAL(5,0)                NOT NULL CHECK(id_segui_cart>=0 AND id_segui_cart<=99999),															--identificador unico del seguimiento de cartera
	id_cartera                      DECIMAL(5,0)                NOT NULL CHECK(id_cartera>=0 AND id_cartera<=99999),																--identificador de la cartera
	fec_seg                         DATE                        NOT NULL CHECK(Fec_seg <= current_date),																				--fecha en ques e hace el seguimiento de cartera
	ind_tip_Acc                     VARCHAR                     NOT NULL CHECK(ind_tip_Acc IN('recordatorio de pago','dias en mora','acuerdo de pago','cartera castigada')),		--tipo deaccion al seguimiento de cartera
	val_resul                       VARCHAR                     NOT NULL CHECK(LENGTH(val_resul)<=255),																				--resultado del seguimiento de cartera con el cliente
	val_observa                     VARCHAR                     NULL     CHECK(LENGTH(val_observa)<=255),																				--obsevaciones de seguimiento de cartera
	ind_pro_acc                     VARCHAR                     NOT NULL CHECK(ind_pro_acc IN ('recordatorio de pago','dias en mora','acuerdo de pago')),							--la proxima accion a hacer el  seguimiento
	fec_pro_acc                     DATE                        NOT NULL CHECK(fec_pro_acc >= CURRENT_DATE),																		--la proxima fecha a hacer seguimiento
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	                                        --indicador de borrado lógico
	PRIMARY KEY (id_segui_cart),
	FOREIGN KEY (id_cartera)        REFERENCES faccar.tab_carteras (id_cartera)
);

------------------------
-- TABLA DE LOS PAGOS --
------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_pagos
(
    id_pago          	            DECIMAL(5,0)                NOT NULL CHECK(id_pago >=0 AND id_pago<=99999), 																--identificador de pago
    id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >=0 AND id_factura<=999999),														--identificador de la factura
    id_cartera                      DECIMAL(5,0)                NULL     CHECK(id_cartera >=0 AND id_cartera <=99999),														    --identificador de la cartera
    fec_pago                        DATE                        NOT NULL CHECK(fec_pago <=CURRENT_DATE),     																	--fecha de Realizacion del pago
    val_pagar                       DECIMAL(12,0)               NOT NULL CHECK(val_pagar >=0 AND val_pagar<=999999999999),													--valor del pago a realizar
    ind_met_pago                    VARCHAR                     NOT NULL CHECK( ind_met_pago IN('EFECTIVO','PSE','TARJETA CREDITO','TARJETA DEBITO','TRANSFERENCIAS')),		--metodo de realizacion del pago
    referencia_pago                 VARCHAR                     NOT NULL CHECK(LENGTH(referencia_pago) <=100),																--referencia de pago	
    ind_est_pag                     VARCHAR                     NOT NULL CHECK(ind_est_pag IN('APROBADO','RECHAZADO','PENDIENTE')),											--estado de pago
    val_observa      	            VARCHAR                     NULL     CHECK(LENGTH(val_observa)<=255),																			--observaciones de la factura
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	                                    --indicador de borrado lógico					
    PRIMARY KEY(id_pago),
    FOREIGN KEY(id_factura)         REFERENCES faccar.tab_enc_facturas (id_factura),
    FOREIGN KEY(id_cartera)         REFERENCES faccar.tab_carteras (id_cartera)
);

----------------------------------------------------------
-- TIPO DE NOTAS 
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_tipo_nota (
    id_tipo_nota                    DECIMAL(1,0)                NOT NULL CHECK(id_tipo_nota IN(1,2)),                                  --identificador del tipo de nota 1.credito 2.debito             
    cod_tipo_nota                   VARCHAR(2)                  NOT NULL CHECK(cod_tipo_nota IN('NC','ND')),                           --codigo del tipo de nota credito o debito
    nom_tipo_nota                   VARCHAR(30)                 NOT NULL CHECK(nom_tipo_nota IN('NOTA CREDITO','NOTA DEBITO')),        --nombre del tipo de nota credito o debito  
    activo                          BOOLEAN                     NOT NULL DEFAULT TRUE,                                                 --estado del tipo de nota, activo (true) o inactivo (false)                 
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,                                                --indicador de borrado lógico
    PRIMARY KEY (id_tipo_nota)
);

----------------------------------------------------------
-- MOTIVO DE NOTA CRÉDITO O DÉBITO 
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_motivo_nota (
    id_motivo_nota                  DECIMAL(3,0)                NOT NULL CHECK(id_motivo_nota >=0 AND id_motivo_nota <=999),   --identificador del motivo de nota
    id_tipo_nota                    DECIMAL(1,0)                NOT NULL CHECK(id_tipo_nota IN(1,2)),                          --tipo de nota asociada
    cod_motivo                      VARCHAR(15)                 NOT NULL CHECK(LENGTH(cod_motivo)<=15),                        --codigo del motivo de nota
    nom_motivo                      VARCHAR(255)                NOT NULL CHECK(LENGTH(nom_motivo) <= 255),                     --nombre del motivo de nota
    afecta_cartera                  BOOLEAN                     NOT NULL DEFAULT TRUE,                                         --AFECTA CARTERA ES CREDITO
    afecta_comision                 BOOLEAN                     NOT NULL DEFAULT FALSE,                                        --afecta la comsion del vendedor si es asi(true) o no (false)
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,                                        --indicador de borrado lógico
    PRIMARY KEY (id_motivo_nota),
    FOREIGN KEY (id_tipo_nota) REFERENCES faccar.tab_tipo_nota(id_tipo_nota)
);

----------------------------------------------------------
-- NOTA CRÉDITO Y DÉBITO (MODIFICADA)
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_nota (
    id_nota                         DECIMAL(5,0)                NOT NULL CHECK(id_nota >=0 AND id_nota <=99999),
    id_tipo_nota                    DECIMAL(1,0)                NOT NULL CHECK(id_tipo_nota IN(1,2)),
    cude                            VARCHAR(96)                 NOT NULL CHECK(LENGTH(cude)=96),  
    qr_code                         TEXT                        NULL,
    xml_firmado                     TEXT                        NULL,
    estado_dian                     VARCHAR(20)                 NOT NULL CHECK(estado_dian IN('pendiente','enviado','rechazado','aceptado')),
    fec_envio_dian                  DATE                        NOT NULL DEFAULT CURRENT_DATE,
    mensaje_dian                    VARCHAR(500)                NULL,
    id_motivo_nota                  DECIMAL(3,0)                NOT NULL CHECK(id_motivo_nota >=0 AND id_motivo_nota <=999),
    fec_ven_nota                    DATE                        NOT NULL CHECK(fec_ven_nota >= fec_emi_nota),
    fec_emi_nota                    DATE                        NOT NULL DEFAULT CURRENT_DATE,
    val_total_nota                  DECIMAL(12,0)               NOT NULL CHECK(val_total_nota > 0 AND val_total_nota <=999999999999),
    val_aplicado                    DECIMAL(12,0)               NOT NULL CHECK(val_aplicado >= 0),                   
    val_pendiente                   DECIMAL(12,0)               NOT NULL CHECK(val_pendiente >= 0),
    ind_estado_nota                 VARCHAR(30)                 NOT NULL CHECK(ind_estado_nota IN('BORRADOR','EMITIDA','ENVIADA_DIAN','ACEPTADA_DIAN','RECHAZADA_DIAN','PENDIENTE_APLICACION','ANULADA')), 
    observacion_nota                VARCHAR(255)                NULL     CHECK(LENGTH(observacion_nota) <= 255),
    -- Restricción de integridad entre valores
    CONSTRAINT chk_saldo_nota CHECK (val_total_nota = val_aplicado + val_pendiente),
    PRIMARY KEY (id_nota),
    FOREIGN KEY (id_tipo_nota)      REFERENCES faccar.tab_tipo_nota(id_tipo_nota),
    FOREIGN KEY (id_motivo_nota)    REFERENCES faccar.tab_motivo_nota(id_motivo_nota)
);

----------------------------------------------------------
-- APLICACIÓN DE NOTAS (MODIFICADA)
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_aplicacion_nota (
    id_aplicacion                   DECIMAL(5,0)                NOT NULL CHECK(id_aplicacion >0 AND id_aplicacion <=99999),
    id_nota                         DECIMAL(5,0)                NOT NULL CHECK(id_nota >=0 AND id_nota <=99999),
    id_cartera                      DECIMAL(5,0)                NULL     CHECK(id_cartera >=0 AND id_cartera <=99999),
    id_factura                      DECIMAL(6,0)                NULL     CHECK(id_factura >=0 AND id_factura <=999999),   -- NUEVA COLUMNA
    valor_aplicado                  DECIMAL(12,0)               NOT NULL CHECK(valor_aplicado > 0),
    saldo_anterior_nota             DECIMAL(12,0)               NOT NULL,
    saldo_despues_nota              DECIMAL(12,0)               NOT NULL,
    fec_aplicacion                  DATE                        NOT NULL DEFAULT CURRENT_DATE,
    observacion_aplicacion          VARCHAR(250)                NULL     CHECK(LENGTH(observacion_aplicacion) <= 250),
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,
    -- Al menos una referencia (factura o cartera) debe estar presente
    CONSTRAINT chk_referencia CHECK (id_factura IS NOT NULL OR id_cartera IS NOT NULL),
    PRIMARY KEY(id_aplicacion),
    FOREIGN KEY(id_nota)            REFERENCES faccar.tab_nota(id_nota),
    FOREIGN KEY(id_factura)         REFERENCES faccar.tab_enc_facturas(id_factura),
    FOREIGN KEY(id_cartera)         REFERENCES faccar.tab_carteras(id_cartera)
);

----------------------------------------------------------
-- PRESUPUESTO 
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_presupuesto (
    id_presupuesto                  DECIMAL(5,0)                NOT NULL CHECK(id_presupuesto >=0 AND id_presupuesto <=99999),
    concepto                        VARCHAR(255)                NOT NULL CHECK(LENGTH(concepto)<=255),
    tipo_presupuesto                VARCHAR(15)                 NOT NULL CHECK(tipo_presupuesto IN('INGRESOS','EGRESOS')),
    val_presupuesto                 DECIMAL(14,0)               NOT NULL CHECK(val_presupuesto >=0 AND val_presupuesto <=999999999999),
    periodo                         VARCHAR(7)                  NOT NULL DEFAULT TO_CHAR(CURRENT_DATE, 'YYYY-MM'),
    fec_presupuesto                 DATE                        NOT NULL DEFAULT CURRENT_DATE,
    observacion                     VARCHAR(255)                NULL     CHECK(LENGTH(observacion)<=255),
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_presupuesto)
);



CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_pmtros_facturacion
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_presupuesto
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_aplicacion_nota
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_nota
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_motivo_nota
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_tipo_nota
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_pagos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_segui_carteras
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_carteras
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_cond_pagos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_fac_electronicas
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_det_facturas
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_enc_facturas
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_det_cotizaciones
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_enc_cotizaciones
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_vendedores
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_productos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_clientes
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();
CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON faccar.tab_forma_pagos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();


CREATE TABLE IF NOT EXISTS faccar.tab_motivo_nota (
    id_motivo_nota       DECIMAL(3,0)         NOT NULL CHECK(id_motivo_nota >=0 AND id_motivo_nota <=999) ,                 --identificador del motivo de nota
    id_tipo_nota         DECIMAL (1,0)        NOT NULL CHECK(id_tipo_nota IN(1,2)),                                         --tipo de nota asociada
    cod_motivo           VARCHAR(15)          NOT NULL CHECK(LENGTH(cod_motivo)<=15),                                       --codigo del motivo de nota
    nom_motivo           VARCHAR(255)         NOT NULL CHECK(LENGTH(nom_motivo) <= 255),                                    --nombre del motivo de nota
    afecta_cartera       BOOLEAN              NOT NULL DEFAULT TRUE,                                                        --AFECTA CARTERA ES CREDITO
    afecta_comision      BOOLEAN              NOT NULL DEFAULT FALSE,                                                       --afecta la comsion del vendedor si es asi(true) o no (false)
    ind_borrado          BOOLEAN              NOT NULL DEFAULT FALSE ,--TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
    ind_estado           BOOLEAN              NOT NULL DEFAULT TRUE,                                                        --estado del motivo de nota, activo (true) o inactivo (false)
    PRIMARY KEY (id_motivo_nota),
    FOREIGN KEY (id_tipo_nota) REFERENCES faccar.tab_tipo_nota(id_tipo_nota)
); 
-- -- Motivos de Nota CRÉDITO (id_tipo_nota = 1)
-- INSERT INTO faccar.tab_motivo_nota (id_motivo_nota, id_tipo_nota, cod_motivo, nom_motivo_nota, afecta_inventario, afecta_cartera, afecta_comision, dias_validez, activo) VALUES
-- (1, 1, 'DEV_TOTAL', 'Devolución total de mercancía', TRUE, TRUE, TRUE, 30, TRUE),
-- (2, 1, 'DEV_PARCIAL', 'Devolución parcial de mercancía', TRUE, TRUE, TRUE, 30, TRUE),
-- (3, 1, 'REBAJA_POST', 'Rebaja o descuento post-venta', FALSE, TRUE, FALSE, 15, TRUE),
-- (4, 1, 'ERROR_FACTURA', 'Error en facturación', FALSE, TRUE, FALSE, 10, TRUE),
-- (5, 1, 'DESC_PRONTO_PAGO', 'Descuento por pronto pago', FALSE, FALSE, FALSE, 5, TRUE),  -- no afecta cartera
-- (6, 1, 'GARANTIA', 'Garantía de producto', TRUE, TRUE, FALSE, 90, TRUE),
-- (7, 1, 'BONIFICACION', 'Bonificación comercial', FALSE, TRUE, TRUE, 60, TRUE);

-- -- Motivos de Nota DÉBITO (id_tipo_nota = 2)
-- INSERT INTO faccar.tab_motivo_nota (id_motivo_nota, id_tipo_nota, cod_motivo, nom_motivo_nota, afecta_inventario, afecta_cartera, afecta_comision, dias_validez, activo) VALUES
-- (101, 2, 'INT_MORA', 'Intereses de mora', FALSE, TRUE, FALSE, 0, TRUE),
-- (102, 2, 'INT_FINAN', 'Intereses financieros', FALSE, TRUE, FALSE, 0, TRUE),
-- (103, 2, 'GASTOS_COBRO', 'Gastos de cobranza', FALSE, TRUE, FALSE, 0, TRUE),
-- (104, 2, 'AJUSTE_PRECIO', 'Ajuste de precio al alza', FALSE, TRUE, FALSE, 15, TRUE),
-- (105, 2, 'ERROR_FACTURA_ND', 'Error en facturación (valor faltante)', FALSE, TRUE, FALSE, 10, TRUE),
-- (106, 2, 'RECARGO_MORA', 'Recargo por mora', FALSE, TRUE, FALSE, 0, TRUE);