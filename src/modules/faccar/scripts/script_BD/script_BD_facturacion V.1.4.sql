-- SENTENCIA DE ELIMINACION DE TABLAS ---
DROP SCHEMA IF EXISTS FACCAR;  -- Facturación y Cartera
CREATE SCHEMA IF NOT EXISTS FACCAR;

DROP TABLE IF EXISTS faccar.tab_pmtros_facturacion;
DROP TABLE IF EXISTS faccar.tab_not_dvols;
DROP TABLE IF EXISTS faccar.tab_pagos;
DROP TABLE IF EXISTS faccar.tab_segui_carteras;
DROP TABLE IF EXISTS faccar.tab_carteras;
DROP TABLE IF EXISTS faccar.tab_cond_pagos;
DROP TABLE IF EXISTS faccar.tab_det_facturas;
DROP TABLE IF EXISTS faccar.tab_enc_facturas;
DROP TABLE IF EXISTS faccar.tab_det_cotizaciones;
DROP TABLE IF EXISTS faccar.tab_enc_cotizaciones;
DROP TABLE IF EXISTS faccar.tab_vendedores;
DROP TABLE IF EXISTS faccar.tab_productos;
DROP TABLE IF EXISTS faccar.tab_clientes;
DROP TABLE IF EXISTS faccar.tab_forma_pagos;

----------------------------------------------------------
--TABLA PARA PARÁMETROS DE PROCESO FACTURACIÓN Y CARTERA -
----------------------------------------------------------

CREATE TABLE faccar.tab_pmtros_facturacion
(
    id_empresa          DECIMAL(10,0)       NOT NULL,                                                            -- Id de la empresa
	val_facini			DECIMAL(6,0)		NOT NULL CHECK(val_facini > 0),                                      -- Valor de la factura inicial
	val_facfin			DECIMAL(6,0)		NOT NULL CHECK(val_facfin > 0 AND val_facfin > val_facini),          -- Valor de factura final
    val_pesosXpuntos    DECIMAL(10,0)       NOT NULL,                                                            -- Valor equivalente de pesos por puntos (Ejmp: Por cada 10 mil se da un punto)
    val_interesmora     DECIMAL(3,0)        NOT NULL CHECK(val_interesmora >= 0 AND val_interesmora <= 100),     -- Valor porcentaje de interés por mora en cartera
    val_diascartera     DECIMAL(3,0)        NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 180),     -- Número de días máximo para castigar cartera
    PRIMARY KEY(id_empresa)
);

------------------------
--TABLA PARA CLIENTES --
------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS faccar.tab_clientes
(
    id_cliente          DECIMAL(10,0)       NOT NULL CHECK(id_cliente >=10000000 AND id_cliente<=9999999999),	        --identificador del cliente							
    ind_tipodoc         DECIMAL(1,0)        NOT NULL CHECK(ind_tipodoc >= 1 AND ind_tipodoc <= 9),                      --indicador del tipo de documento
    fec_nacimi      	DATE                NOT NULL CHECK (EXTRACT(YEAR FROM AGE(fec_nacimi)) >= 16),                  --fecha de nacimiento del cliente
    val_edad            DECIMAL(2,0)        NOT NULL CHECK(val_edad >=0 AND val_edad <=99),                             --edad del cliente
    ind_genero          VARCHAR             NOT NULL CHECK (ind_genero IN ('M', 'F', 'T', 'NB')),                       --genero del cliente
    val_puntos          DECIMAL(10,0)       NOT NULL CHECK (val_puntos >=0 AND val_puntos <=9999999999),                --Puntaje para valoracion del credito al cliente
    ind_credito         BOOLEAN             NOT NULL, --TRUE=APROBADO O FALSE = NO APROBADO,                            --el cliente puede tener credito para pago
    val_cupocredito     DECIMAL(12,0)       NOT NULL CHECK(val_cupocredito >= 0 AND val_cupocredito <=999999999999),    --valor aprobado de credito al cliente
    val_diascartera     DECIMAL(3,0)        NOT NULL CHECK(val_diascartera >= 0 AND val_diascartera <= 120),            -- Días de cartera para el cliente en facturas
    ind_estado          BOOLEAN             NOT NULL, --TRUE=Activo / FALSE=No activo                                   -- Indicador de estado del cliente
    id_restriccion      DECIMAL(2,0)        NOT NULL,                                                                   -- Restricion para entrar al aplicativo
    PRIMARY KEY(id_cliente),
    FOREIGN KEY(id_cliente)         REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_restriccion)     REFERENCES public.tab_restricciones(id_restriccion)
);

----------------------------------------------------------
--TABLA DE PRODUCTOS PROPIOS PARA FACTURACIÓN A CLIENTES -
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_productos
(
    id_producto             DECIMAL(3,0)        NOT NULL CHECK(id_producto >0 AND id_producto <=999), 				--identificador del producto
    ind_tip_producto        BOOLEAN             NOT NULL, --TRUE=PRODUCTO O FALSE=SERVICIO,							--indicador del tipo de producto 
    nom_producto            VARCHAR             NOT NULL CHECK (LENGTH(nom_producto) <=70),							--nombre del producto
    val_exist               DECIMAL(3,0)        NOT NULL CHECK(val_exist>0 AND val_exist <= 999),                   --cantidad del producto para venta
    val_poriva              DECIMAL(2,0)        NOT NULL CHECK(val_poriva >= 0 AND val_poriva <= 99),               --porcentaje de iva del producto
    val_venta               DECIMAL(11,0)       NOT NULL CHECK(val_venta >=0 AND val_venta <=99999999999),          --valor de la venta
    ind_disponible          BOOLEAN             NOT NULL, --TRUE=DISPONIBLE O FALSE =NO DISPONIBLE,					--indicador de disponibilidad
    ind_estado              BOOLEAN             NOT NULL,--TRUE=ACTIVO O FALSE=INACTIVO								--indicador de estado del producto
    PRIMARY KEY(id_producto)
);

-------------------------
-- TABLA DE VENDEDORES --
-------------------------
--CUANDO CATEGORÍA DEL TERCERO LO SEA
CREATE TABLE IF NOT EXISTS faccar.tab_vendedores
(
	id_vendedor         DECIMAL(10,0)       NOT NULL CHECK(id_vendedor >= 10000000 AND id_vendedor<=9999999999),        --identificador del vendedor
    ind_tipodoc         DECIMAL(1,0)        NOT NULL CHECK(ind_tipodoc >= 1 AND ind_tipodoc <= 9),                      --indicador del tipo de documento
    fec_nacimi      	DATE                NOT NULL CHECK (EXTRACT(YEAR FROM AGE(fec_nacimi)) >= 16),                  --fecha de nacimiento del cliente
    val_edad            DECIMAL(2,0)        NOT NULL CHECK(val_edad >= 0 AND val_edad <= 99),                           --edad del cliente
    ind_genero          VARCHAR             NOT NULL CHECK (ind_genero IN ('M', 'F', 'T', 'NB')),                       --genero del cliente    val_porcomision     DECIMAL(2,0)        NULL CHECK(val_porcomision>=1 AND val_porcomision<=99),                     --el porcentaje de la comision que gana el vendedor
	val_comision        DECIMAL(7,0)        NULL CHECK(val_comision>=9999999),                                          --el valor de la comision
    ind_estado          BOOLEAN             NOT NULL, --TRUE=Activo / FALSE=No activo                                   --indicador del estado del vendedor
    id_restriccion      DECIMAL(2,0)        NOT NULL,                                                                   --restricion para entrar al aplicativo
	PRIMARY KEY (id_vendedor),
    FOREIGN KEY(id_vendedor)        REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_restriccion)     REFERENCES public.tab_restricciones(id_restriccion)
);

-----------------------------------------
-- TABLA DE ENCABEZADO DE COTIZACIONES --
-----------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_enc_cotizaciones
(
	id_cotizacion       DECIMAL(6,0)        NOT NULL CHECK(id_cotizacion>=0 AND id_cotizacion<=99999),                  --identificador de la cotizacion
	id_cliente          DECIMAL(10,0)       NOT NULL CHECK(id_cliente >=10000000 AND id_cliente<=9999999999),           --identificador del cliente
    id_ciudad           VARCHAR             NOT NULL,                                                                   --indificador de la ciudad
	id_vendedor         DECIMAL(10,0)       NOT NULL CHECK(id_vendedor>=10000000 AND id_vendedor<=9999999999),          --identificador del vendedor
	fec_cotizacion      DATE                NOT NULL CHECK(fec_cotizacion = CURRENT_DATE),                              --fecha de la creacion de la cotizacion
	fec_vencimiento     DATE                NOT NULL CHECK(fec_vencimiento >= fec_cotizacion),                          --fecha de vencimiento de la cotizacion
	val_total           DECIMAL(10,0)       NOT NULL CHECK(val_total <= 9999999999),                                    --total de la cotizacion
	ind_estado          BOOLEAN             NOT NULL, -- TRUE=Vigente / FALSE=Vencida                                   --indicador de estado de la cotizacion
	PRIMARY KEY (id_cotizacion),
	FOREIGN KEY (id_cliente)        REFERENCES faccar.tab_clientes(id_cliente),
	FOREIGN KEY (id_ciudad)         REFERENCES public.tab_ciudades(id_ciudad)
);

--------------------------------------
-- TABLA DE DETALLE DE COTIZACIONES --
--------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_det_cotizaciones
(
    id_cotizacion       DECIMAL(5,0)        NOT NULL CHECK(id_cotizacion >=0 AND id_cotizacion <=99999), --identificador de la cotizacion
    id_producto         DECIMAL(3,0)        NOT NULL CHECK(id_producto >=0 AND id_producto <=999), --identificador del producto 
    val_cantidad        DECIMAL(4,0)        NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999), --cantidad de productos cotizados
    val_bruto           DECIMAL(12,0)       NOT NULL CHECK(val_bruto <= 9999999999), --valor bruto de  los productos cotizados
    val_pordesc         DECIMAL(3,0)        NOT NULL CHECK(val_pordesc >=0 AND val_pordesc <=100), --el porcentaje del descuento
	val_descuento		DECIMAL(10,0)		NOT NULL CHECK(val_descuento>=0 AND val_descuento<=9999999999), --valor de decuento de la cotizacion
    val_iva             DECIMAL(10,0)       NOT NULL CHECK(val_iva <= 9999999999),	--valor del impuesto del iva
    val_reteica         DECIMAL(10,0)       NOT NULL CHECK(val_reteica <= 9999999999), --valor de impuesto de retencion ICA
    val_neto            DECIMAL(10,0)       NOT NULL CHECK(val_neto <= 9999999999), --valor neto de la cotizacion
    val_observa         DECIMAL(10,0)       NOT NULL CHECK(val_observa <= 9999999999), --observaciones de la cotizacion
	PRIMARY KEY(id_cotizacion,id_producto),
    FOREIGN KEY(id_cotizacion)      REFERENCES faccar.tab_enc_cotizaciones(id_cotizacion),
    FOREIGN KEY(id_producto)        REFERENCES faccar.tab_productos(id_producto)
);

--------------------------
-- TABLA DE FORMA PAGOS --
--------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_forma_pagos
(
	id_formapago        DECIMAL(1,0)        NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9), --identificador de la forma de pago
	nom_formapago       VARCHAR             NOT NULL CHECK(LENGTH(nom_formapago) >= 3), --nombre de la forma de pago
	PRIMARY KEY(id_formapago)
);

------------------------------------
-- TABLA DE ENCABEZADO DE FACTURA --
------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_enc_facturas
(
	id_factura          DECIMAL(6,0)        NOT NULL CHECK(id_factura >=0 AND id_factura<=999999),	--identificador de la factura
	id_cliente          DECIMAL(10,0)       NOT NULL CHECK(id_cliente >= 10000000 AND id_cliente <= 9999999999), --identificador del cliente
	id_vendedor         DECIMAL(10,0)       NOT NULL CHECK(id_vendedor >= 10000000 AND id_vendedor <= 9999999999), --identificador del vendedor
	fec_factura         DATE                NOT NULL CHECK(fec_factura = CURRENT_DATE), --fecha de la creacion de la factura
	id_formapago        DECIMAL(1,0)        NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9), --identificador de la forma de pago
	val_total           DECIMAL(10,0)       NOT NULL CHECK(val_total <= 9999999999), --total de la factura
	ind_estado          BOOLEAN             NOT NULL, -- TRUE=Activa / FALSE=Vencida, --estado en el que se encuentra la factura
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
    id_factura          DECIMAL(6,0)        NOT NULL CHECK(id_factura >=0 AND id_factura <=99999), --identificador de la factura
    id_producto         DECIMAL(3,0)        NOT NULL CHECK(id_producto >=0 AND id_producto <=999), --identificador del producto 
    val_cantidad        DECIMAL(4,0)        NOT NULL CHECK(val_cantidad >=0 AND val_cantidad <=9999), --cantidad de venta del producto
	val_bruto			DECIMAL(10,0)		NOT NULL CHECK (val_bruto >=0 AND val_bruto<=999999999999), --valor bruto de la factura
    por_descuento       DECIMAL(3,0)        NOT NULL CHECK(por_descuento >=0 AND por_descuento <= 100), --el porcentaje del descuento de la factura
    val_descuento       DECIMAL(10,0)       NOT NULL CHECK(val_descuento <= 9999999999), --valor descuento de la factura
    val_iva             DECIMAL(10,0)       NOT NULL CHECK(val_iva >=0 AND val_iva <= 9999999999),	--valor del impuesto del iva
    val_reica           DECIMAL(10,0)       NOT NULL CHECK(val_reica >= 0 AND val_reica <= 9999999999), --valor de impuesto de retencion ICA
    val_neto            DECIMAL(10,0)       NOT NULL CHECK(val_neto >= 0 AND val_neto <= 9999999999),	--valor neto de la factura	
    val_observa         VARCHAR, --observaciones de la factura
    PRIMARY KEY(id_factura,id_producto),
    FOREIGN KEY(id_factura)         REFERENCES faccar.tab_enc_facturas(id_factura),
    FOREIGN KEY(id_producto)        REFERENCES faccar.tab_productos(id_producto)
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
	id_cond_pago        DECIMAL(5,0)        NOT NULL CHECK(id_cond_pago >= 0 AND id_cond_pago <= 99999), --identificador de condicion de pago
    id_cliente          DECIMAL(10,0)       NOT NULL CHECK(id_cliente >= 10000000 AND id_cliente <= 9999999999), --identificador del cliente
	id_factura          DECIMAL(6,0)        NOT NULL CHECK(id_factura >= 0 AND id_factura <= 999999), --identificador de la factura
	val_plazofinanciado DECIMAL(3,0)        NOT NULL CHECK(val_plazofinanciado >= 0 AND val_plazofinanciado <= 120), --plazo al que se financio el la cartera
	val_tasainteres     DECIMAL(3,0)        NOT NULL CHECK(val_tasainteres >= 0 AND val_tasainteres <= 100), --la tasa de interes las condicones de pago
	val_total_finan     DECIMAL(10,0)       NOT NULL CHECK(val_total_finan >= 0 AND val_total_finan <= 9999999999), --valor total finaciado
	val_observacion     VARCHAR             NOT NULL CHECK(LENGTH(val_observacion)<=255), --descripcion de la condicon del pago
	PRIMARY KEY (id_cond_pago),
	FOREIGN KEY (id_cliente) REFERENCES public.tab_terceros(id_tercero),
	FOREIGN KEY (id_factura) REFERENCES faccar.tab_enc_facturas(id_factura)
);

----------------------
--TABLA DE CARTERAS --
----------------------
-- ESTA TABLA ES PARA LOS QUE REALIZARON EL PAGO DE LA FACTURA POR MEDIO DE CREDITO
CREATE TABLE IF NOT EXISTS faccar.tab_carteras
(
    id_cartera             DECIMAL(5,0)                   NOT NULL CHECK(id_cartera >=0 AND id_cartera <=99999),					--identificador del credito
    id_cond_pago           DECIMAL(5,0)                   NOT NULL CHECK(id_cond_pago >=0 AND id_cond_pago <=99999),				--identificador de condicion de pago
    val_monto              DECIMAL(12,0)                  NOT NULL CHECK(val_monto >=0 AND val_monto <=999999999999),				--valor de la cuota a pagar
    val_pendiente          DECIMAL(12,0)                  NOT NULL CHECK(val_pendiente >=0 AND val_pendiente <=999999999999),		--saldo pendiente a pagar de la cartera
    fec_pago               DATE                           NOT NULL CHECK(fec_pago = CURRENT_DATE),									--fecha  a realizar el pago
    fec_prox_pago          DATE                           NOT NULL CHECK(fec_prox_pago >= fec_pago),								--Fecha del proximo pago a realizar
    dias_mora              DECIMAL(3,0)                   NOT NULL CHECK(dias_mora >=0 AND dias_mora<=120),							--dias de moras de la cartera
    ind_estado             VARCHAR                        NOT NULL,																	--indicador de estado de la cartera
    PRIMARY KEY(id_cartera),
    FOREIGN KEY(id_cond_pago)REFERENCES faccar.tab_cond_pagos(id_cond_pago)
);

--------------------------------------
-- TABLA DE SEGUIMIENTO DE CARTERAS --
--------------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_segui_carteras
(
	id_segui_cart       DECIMAL(5,0)        NOT NULL CHECK(id_segui_cart>=0 AND id_segui_cart<=99999),																									--identificador unico del seguimiento de cartera
	id_cartera          DECIMAL(5,0)        NOT NULL CHECK(id_cartera>=0 AND id_cartera<=99999),																										--identificador de la cartera
	fec_seg             DATE                NOT NULL CHECK(Fec_seg = current_date),																														--fecha en ques e hace el seguimiento de cartera
	ind_tip_Acc         VARCHAR             NOT NULL CHECK(ind_tip_Acc='recordatorio de pago' OR ind_tip_Acc='dias en mora' OR ind_tip_Acc='acuerdo de pago' OR ind_tip_Acc='cartera castigada'),		--tipo deaccion al seguimiento de cartera
	val_resul           VARCHAR             NOT NULL CHECK(LENGTH(val_resul)<=255),																														--resultado del seguimiento de cartera con el cliente
	val_observa         VARCHAR             NULL CHECK(LENGTH(val_observa)<=255),																														--obsevaciones de seguimiento de cartera
	ind_pro_acc         VARCHAR             NOT NULL CHECK(ind_pro_acc='recordatorio de pago' OR ind_pro_acc='dias en mora' OR ind_pro_acc='acuerdo de pago'),											--la proxima accion a hacer el  seguimiento
	fec_pro_acc         DATE                NOT NULL CHECK(fec_pro_acc >= CURRENT_DATE),																												--la proxima fecha a hacer seguimiento
	PRIMARY KEY (id_segui_cart),
	FOREIGN KEY (id_cartera) REFERENCES faccar.tab_carteras (id_cartera)
);

------------------------
-- TABLA DE LOS PAGOS --
------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_pagos
(
    id_pago          	   DECIMAL(5,0)                   NOT NULL CHECK(id_pago >=0 AND id_pago<=99999), 																														--identificador de pago
    id_factura             DECIMAL(5,0)                   NOT NULL CHECK(id_factura >=0 AND id_factura<=99999),																													--identificador de la factura
    id_cartera             DECIMAL(5,0)                   NOT NULL CHECK(id_cartera >=0 AND id_cartera <=99999),																												--identificador de la cartera
    fec_pago               DATE                           NOT NULL CHECK(fec_pago =CURRENT_DATE),     																															--fecha de Realizacion del pago
    val_pagar              DECIMAL(4,0)                   NOT NULL CHECK(val_pagar >=0 AND val_pagar<=9999),																													--valor del apgo a realizar
    ind_met_pago           VARCHAR                        NOT NULL,CHECK( ind_met_pago='EFECTIVO' OR  ind_met_pago='PSE' OR  ind_met_pago='TARJETA CREDITOO' OR  ind_met_pago='TARJETA DEBITO' OR  ind_met_pago='TRANSFERENCIAS'),		--metodo de realizacion del pago
    referencia_pago        VARCHAR                        NOT NULL CHECK(LENGTH(referencia_pago) <=100),																														--referencia de pago	
    ind_est_pag            VARCHAR                        NOT NULL,CHECK(ind_est_pag='APROVADO' OR ind_est_pag='RECHAZADO' OR ind_est_pag='PENDIENTE'),																			--estado de pago
    val_observa      	   VARCHAR             	          NULL CHECK(LENGTH(val_observa)<=255),																																	--observaciones de la factura					
    PRIMARY KEY(id_pago),
    FOREIGN KEY(id_factura) REFERENCES faccar.tab_enc_facturas (id_factura),
    FOREIGN KEY(id_cartera) REFERENCES faccar.tab_carteras (id_cartera)
);

----------------------------------
-- TABLLA DE NOTAS DEVOLUCIONES --
----------------------------------
CREATE TABLE IF NOT EXISTS faccar.tab_not_dvols
(
	id_notaCredito      VARCHAR         NOT NULL CHECK(LENGTH(id_notaCredito) = 12),								--identificador de la nota credito	
	id_factura          DECIMAL(5,0)    NOT NULL CHECK(id_factura>=0 AND id_factura<=99999),							--identificador de la factura
	fec_emision         DATE            NOT NULL CHECK(Fec_emision=current_date),									--fecha que se hace la devolución
	val_motivo          VARCHAR         NOT NULL CHECK(LENGTH(val_motivo)<=255),										--motivo por que se hace devolucion
	val_devolucion      DECIMAL(12,0)   NOT NULL CHECK(val_devolucion>=0 AND val_devolucion<=99999999999999),				--valor de la devolución
	ind_estado          BOOLEAN         NOT NULL, --true = efectiva OR False = cancelada							--estado de la nota credito de la devolucion
	PRIMARY KEY (id_notaCredito),
	FOREIGN KEY (id_factura) REFERENCES faccar.tab_enc_facturas(id_factura)
);

