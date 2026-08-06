-- --------------------------------------------------------
-- script_create_erp_schemas.sql
-- Script DDL para la creación de la estructura base 
-- modular de la Base de Datos del ERP ADSO en PostgreSQL.
-- Autor: Carlos Eduardo Perez & equipo de ADSO 3171727
-- --------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- -------------------------------------------------------------------
-- 1. CONFIGURACIÓN INICIAL
-- Establecer que si algo falla, se detenga el script inmediatamente.
-- -------------------------------------------------------------------
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
-- ----------------------------------------------
-- 3. BORRADO DE TABLAS PARA INSTALACIÓN INICIAL
-- ----------------------------------------------
DROP TABLE IF EXISTS tab_areas;
DROP TABLE IF EXISTS tab_sesiones;
DROP TABLE IF EXISTS tab_menu_usuarios;
DROP TABLE IF EXISTS tab_menus;
DROP TABLE IF EXISTS tab_usuarios;
DROP TABLE IF EXISTS tab_terceros;
DROP TABLE IF EXISTS tab_cat_terceros;
DROP TABLE IF EXISTS tab_restricciones;
DROP TABLE IF EXISTS tab_ciudades;
DROP TABLE IF EXISTS tab_dptos;
DROP TABLE IF EXISTS tab_pmtros_grales;
DROP TABLE IF EXISTS tab_audit_trail;
DROP TABLE IF EXISTS tab_cat_errores;
DROP TYPE  IF EXISTS DATOS_UBICACION;

-- ------------------------------------------------------------
-- 4. CREACIÓN DE TABLAS TRANSVERSALES (Esquema 'public')
-- Estas tablas son esenciales y usadas por todos los módulos.
-- Se colocan en 'public' para un acceso más sencillo.
-- ------------------------------------------------------------

--ESTRUCTURA DE DATOS DE UBICACIÓN DE LOS TERCEROS DEL SISTEMA (Se usa en la tabla de terceros y en la tabla de parámetros generales para la empresa)
CREATE TYPE DATOS_UBICACION AS
(
	nom_corto   VARCHAR,             --nombre corto del lugar (ej: Barrio, Vereda, etc.)
    direccion   VARCHAR,             --direcion del tercero
    tel_fijo    DECIMAL,                   --telefono fijo del tercero (7 a 10 dígitos dependiendo de la ciudad)
    tel_movil   DECIMAL,                 --celular del tercero
    email       VARCHAR      --email del tercero
);

-- MANEJO DE ERRORES TRANSVERSAL (Tabla de códigos de error SQLSTATE y mensajes asociados)
CREATE TABLE tab_cat_errores (
    cod_sqlstate    VARCHAR     NOT NULL CHECK(LENGTH(cod_sqlstate) = 5),                        -- Codigo SQLSTATE del error
    mensaje         VARCHAR     NOT NULL CHECK(LENGTH(mensaje) >= 4 AND LENGTH(mensaje) <= 255), -- Mensaje descriptivo del error    
    PRIMARY KEY(cod_sqlstate)
);

-- 1. SEGURIDAD Y ACCESOS (Usuarios creados en Bases de Datos)
CREATE TABLE tab_usuarios
(
    id_usuario          VARCHAR         NOT NULL CHECK(LENGTH(id_usuario) >= 5),                                                -- Identificador único del usuario (ej: admin, jdoe, etc.)
    nom_usuario         VARCHAR         NOT NULL CHECK(LENGTH(nom_usuario) >= 8),                                               -- Nombre completo del usuario para mostrar en la interfaz 
    pass_usuario        VARCHAR         NOT NULL CHECK(LENGTH(pass_usuario) >= 12),                                             -- Se recomienda almacenar la contraseña en formato hash
    mail_usuario        VARCHAR         NOT NULL CHECK(mail_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),     -- Email del usuario para notificaciones y recuperación de contraseña
    ind_usuario         BOOLEAN         NOT NULL DEFAULT FALSE,                                                                 -- TRUE= Si es administrador / FALSE= Es un usuario normal.
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                                  -- Si está inhabilitado o modificado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                                 --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	           
    PRIMARY KEY(id_usuario)
);

-- 2. TABLA PARA CUMPLIMIENTO DE SESIÓN ÚNICA (Requerimientos)
CREATE TABLE tab_sesiones
(
    id_usuario          VARCHAR NOT NULL CHECK(LENGTH(id_usuario) >= 5),    -- ID del usuario que inició sesión (FK a tab_usuarios)
    token_sesion        VARCHAR NOT NULL check(LENGTH(token_sesion) >= 10),                   -- Token de sesión para validar sesión única
    fec_inicio          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ult_actividad       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id_usuario),
    FOREIGN KEY(id_usuario) REFERENCES tab_usuarios(id_usuario) ON DELETE CASCADE
);

-- 3. TABLAS DE MENUS (Menus que se crean para asignar a los usuarios y evitar usar roles)

CREATE TABLE tab_menus
(
    id_menu             VARCHAR   NOT NULL,                                 -- Identificador único del menú (ej: 1, 11, 111, etc. para reflejar la jerarquía)
    nom_menu            VARCHAR   NOT NULL CHECK(LENGTH(nom_menu) <= 100),  -- Nombre del menú para mostrar en la interfaz (ej: Configuración, Parámetros, etc.)
    ind_id_padre        VARCHAR   NOT NULL,                                 -- Identificador del menú padre (ej: 0 para menús principales, 1 para submenús de Configuración, etc.)
    nom_programa        VARCHAR   NOT NULL DEFAULT 'no_aplica',             -- Nombre del programa o ruta que se ejecuta al hacer clic en el menú (ej: 'modules/compro/productos.php')
    ind_borrado         BOOLEAN   NOT NULL DEFAULT FALSE,                   -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    
    PRIMARY KEY(id_menu)
);
-- 4. TABLAS DE MENUS POR USUARIO (para asignar menus sin necesidad de que todos los usuarios tengan los mismos)

CREATE TABLE tab_menu_usuarios
(
    id_usuario          VARCHAR NOT NULL CHECK(LENGTH(id_usuario) >= 5) REFERENCES tab_usuarios(id_usuario),    -- ID del usuario al que se le asigna el menú (FK a tab_usuarios)
    id_menu             VARCHAR NOT NULL REFERENCES tab_menus(id_menu),                                         -- ID del menú asignado al usuario (FK a tab_menus)
    PRIMARY KEY(id_usuario, id_menu)
);

-- 5. TABLA DE ÁREAS DE LA EMPRESA (Áreas creadas y asignadas a un responsable por su id de usuario del sistema)

CREATE TABLE IF NOT EXISTS public.tab_areas
(
    id_area             DECIMAL(5,0)    NOT NULL CHECK (id_area > 0),                                                       -- ID del área
    id_responsable      VARCHAR         DEFAULT NULL,                                                                       -- Usuario responsable del área
    nom_area            VARCHAR         NOT NULL CHECK (LENGTH(nom_area) >= 3),                                             -- Nombre del área (ej: Finanzas, Recursos Humanos, etc.)
    descrip_area        TEXT,                                                                                               -- Descripción detallada del área y sus funciones
    mail_area           VARCHAR         NOT NULL CHECK(mail_area ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),    -- Email corporativo del área
    tel_oficina         DECIMAL(10,0)   NOT NULL CHECK(tel_oficina >= 0 AND tel_oficina < 9999999999),                      -- Teléfono de la oficina del área
    ubi_oficina         VARCHAR         NOT NULL CHECK(LENGTH(ubi_oficina) >= 3),                                           -- Edificio, piso, oficina
    horario_atencion    VARCHAR         NOT NULL CHECK(LENGTH(horario_atencion) >= 3),                                      -- Lunes a Viernes 8am-5pm
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                              -- Activo/Inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	       
    PRIMARY KEY (id_area),
    FOREIGN KEY (id_responsable) REFERENCES public.tab_usuarios(id_usuario)
);

-- 6. TABLA PARAMETROS GENERALES

CREATE TABLE IF NOT EXISTS tab_pmtros_grales
(
    id_empresa	        DECIMAL(10,0)	NOT NULL CHECK(id_empresa >=10000000 AND id_empresa<=9999999999),               --identificador de la empresa
    nom_empresa	        VARCHAR         NOT NULL CHECK(LENGTH(nom_empresa) >= 5 AND LENGTH(nom_empresa) <= 60),         --nombre de la empresa
    datos_residencia    DATOS_UBICACION,                                                                                --Estructura de datos de residencia de la empresa
    nom_replegal        VARCHAR	        NOT NULL CHECK(LENGTH(nom_replegal) >= 5 AND LENGTH(nom_replegal) <= 60),       --nombre del representante legal
    val_poriva	        DECIMAL(2,0)	NOT NULL CHECK(val_poriva   >= 0   AND val_poriva   < 100) DEFAULT 0,           --valor porcentaje iva
    val_pordesc	        DECIMAL(2,0)	NOT NULL CHECK(val_pordesc   >= 0   AND val_pordesc < 100) DEFAULT 0,           --valor porcentaje descuento
    val_porrete	        DECIMAL(2,0)	NOT NULL CHECK(val_porrete  >= 0   AND val_porrete < 100) DEFAULT 0,            --valor porcentaje retencion
    val_reteica	        DECIMAL(2,0)	NOT NULL CHECK(val_reteica  >= 0   AND val_reteica  < 100) DEFAULT 0,           --valor porcentaje reteica
    val_porutil	        DECIMAL(3,0)	NOT NULL CHECK(val_porutil  >= 0   AND val_porutil  <= 100) DEFAULT 0,          --valor porcentaje utilidad
    val_latitud	        DECIMAL(18,16)	NOT NULL CHECK(val_latitud  >= -4  AND val_latitud  <= 80),	                    --valor latitud
    val_longitud	    DECIMAL(18,16)	NOT NULL CHECK(val_longitud >= -80 AND val_longitud <= -50),                    --valor longitud
    val_color_letra     VARCHAR         NOT NULL CHECK(LENGTH(val_color_letra) = 7),                                    --valor  del color de la letra
    val_color_logo      VARCHAR         NOT NULL CHECK(LENGTH(val_color_logo) = 7),                                     --valor del color del logo
    val_color_fondo     VARCHAR         NOT NULL CHECK(LENGTH(val_color_fondo) = 7),                                    --valor del color del fondo
    anio_fiscal         DECIMAL(4,0)    NOT NULL,                                                                       --Año fiscal en el estamos actualmente
    mes_fiscal          DECIMAL(2,0)    NOT NULL,                                                                       --mes fiscal en el que estamos actualmente
    ind_autorete        BOOLEAN	        NOT NULL, --TRUE = autorete / FALSE = no autorete                               --indicador autoretenedor
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico

    PRIMARY KEY(id_empresa),
    CONSTRAINT verificar_anio CHECK(anio_fiscal = EXTRACT (YEAR FROM CURRENT_DATE)), 
    CONSTRAINT verificar_mes  CHECK(mes_fiscal = EXTRACT (MONTH FROM CURRENT_DATE)) 
);


CREATE TABLE IF NOT EXISTS tab_menu_palettes
(
    id_palette          VARCHAR(30)     NOT NULL,                           -- Identificador único de la paleta (ej: 'blue_pro')
    nom_palette         VARCHAR(50)     NOT NULL,                           -- Nombre descriptivo (ej: 'Azul Profesional')
    des_palette         TEXT,                                               -- Descripción de la paleta
    val_primary_color   VARCHAR(7)      NOT NULL DEFAULT '#1a1a2e',       -- Color principal del menú (gradiente inicio)
    val_secondary_color VARCHAR(7)      NOT NULL DEFAULT '#16213e',       -- Color secundario del menú (gradiente fin)
    val_accent_color    VARCHAR(7)      NOT NULL DEFAULT '#00d9ff',       -- Color de acento (hover, active, iconos)
    val_text_color      VARCHAR(7)      NOT NULL DEFAULT '#ffffff',       -- Color del texto en el menú superior
    val_hover_color     VARCHAR(7)      NOT NULL DEFAULT '#00d9ff',       -- Color al pasar el mouse
    val_sidebar_bg      VARCHAR(7)      NOT NULL DEFAULT '#ffffff',       -- Fondo del sidebar
    val_sidebar_text    VARCHAR(7)      NOT NULL DEFAULT '#555555',       -- Color del texto en sidebar
    val_sidebar_hover   VARCHAR(7)      NOT NULL DEFAULT '#f4f7ff',       -- Fondo al pasar el mouse
    val_active_bg       VARCHAR(7)      NOT NULL DEFAULT '#00aaff',       -- Color del item activo
    num_orden           INTEGER         NOT NULL DEFAULT 0,                 -- Orden de visualización
    ind_active          BOOLEAN         NOT NULL DEFAULT FALSE,             -- Si es la paleta por defecto
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,             -- TRUE: Borrado lógico / FALSE: Activo
    PRIMARY KEY (id_palette)
);

-- 7. TABLA DEPARTAMENTOS DE COLOMBIA 

CREATE TABLE IF NOT EXISTS tab_dptos
(
    id_dpto	            VARCHAR         NOT NULL CHECK(LENGTH(id_dpto) = 2),                                            --identificador del departamento
    nom_dpto	        VARCHAR	        NOT NULL CHECK(LENGTH(nom_dpto) >= 4 AND LENGTH(nom_dpto) <= 20),               --nombre del departamento
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, -- --TRUE: Borrado lógico (Inactivo) / FALSE: Activo    --indicador de borrado lógico
    PRIMARY KEY(id_dpto)
);


-- 8. TABLA CIUDADES DE COLOMBIA

CREATE TABLE IF NOT EXISTS tab_ciudades
(
    id_ciudad	        VARCHAR	        NOT NULL CHECK(LENGTH(id_ciudad) = 5),									    	--identificador de la ciudad									
    nom_ciudad	        VARCHAR	        NOT NULL CHECK(LENGTH(nom_ciudad) >= 3 AND LENGTH(nom_ciudad) <= 30), 		    --nombre de la ciudad
    id_dpto     	    VARCHAR	        NOT NULL CHECK(LENGTH(id_dpto) = 2),											--identidicador del departamento
    ind_capital	        BOOLEAN	        NOT NULL,   --True = capital / false = no capital							    --indicador de la capital
    cod_postal	        VARCHAR	        NOT NULL CHECK(LENGTH(cod_postal) = 6),										    --codigo postal
    val_latitud         DECIMAL(18,16)	NOT NULL CHECK(val_latitud >= -4    AND val_latitud <= 80), 					--valor latitud
    val_longitud        DECIMAL(18,16)  NOT NULL CHECK(val_longitud >= -80  AND val_longitud <= -50), 				    --valor longitud
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico

    PRIMARY KEY(id_ciudad),
    FOREIGN KEY (id_dpto) REFERENCES tab_dptos(id_dpto)
);

-- TABLA GENERAL DE CATEGORÍAS DE TERCEROS DEL SISTEMA
-- ESTA TABLA PERMITE LA CARACTERIZACIÓN DE LOS TERCEROS EN TODO EL SISTEMA.			
CREATE TABLE IF NOT EXISTS tab_cat_terceros
(			
	id_cat_tercero 		DECIMAL(2,0)	NOT NULL CHECK(id_cat_tercero > 0 AND id_cat_tercero <= 99),					    --identificador de la categoria 
	nom_cat_tercero		VARCHAR			NOT NULL CHECK(LENGTH(nom_cat_tercero) >= 4 AND LENGTH(nom_cat_tercero) <= 50),	    --Nombre de la categoria tercero
	PRIMARY KEY(id_cat_tercero)			
);			
INSERT INTO tab_cat_terceros VALUES(1,'CLIENTE');			
INSERT INTO tab_cat_terceros VALUES(2,'VENDEDOR');			
INSERT INTO tab_cat_terceros VALUES(3,'EMPLEADO');			
INSERT INTO tab_cat_terceros VALUES(4,'LEAD');			
INSERT INTO tab_cat_terceros VALUES(5,'PROVEEDOR');			
			
-----------------------------------------------------------------------------------
-- TABLA DE RESTRICCIONES DE LOS TERCEROS, QUE IMPIDEN SU ACCESO AL SISTEMA	 --
-----------------------------------------------------------------------------------			
CREATE TABLE IF NOT EXISTS tab_restricciones			
(			
	id_restriccion		DECIMAL(2,0)	NOT NULL CHECK(id_restriccion > 0 AND id_restriccion <= 99),				        --identificador de la restrinción	
	nom_restriccion		VARCHAR			NOT NULL CHECK(LENGTH(nom_restriccion) >= 4 AND LENGTH(nom_restriccion) <= 50),	    --Nombre de la restrinción
	PRIMARY KEY(id_restriccion)			
);			
INSERT INTO tab_restricciones VALUES(1,'Finalización Contrato Mutuo Acuerdo');			
INSERT INTO tab_restricciones VALUES(2,'Vacaciones Colectivas');			
INSERT INTO tab_restricciones VALUES(3,'Inhabilidad Legal');			
INSERT INTO tab_restricciones VALUES(4,'Restricción Día Festivo');			
			
-------------------------
-- TABLA DE TERCEROS.  --
------------------------- 
--ES TRANSVERSAL. TODA PERSONA DEBE ESTAR REGISTRADA EN ESTA TABLA.			
-- TIENE EXTENSIONES COMO CLIENTES, VENDEDORES, EMPLEADO, ETC. Y CADA EXTENSIÓN TIENE LOS DATOS PARTICULARES			
CREATE TABLE IF NOT EXISTS tab_terceros			
(			
	id_tercero			VARCHAR     	NOT NULL,		                                                            --identificador de terceros
	ind_tipo_tercero	BOOLEAN			NOT NULL, --TRUE:Jurídica / FALSE:Natural								    --tipo de tercero si es persona natural o jurídica
	id_cat_tercero		DECIMAL(2,0)	NOT NULL CHECK(id_cat_tercero > 0 AND id_cat_tercero <= 99),			    --identifiador de la categoria 
	nom_tercero			VARCHAR			NOT NULL CHECK(LENGTH(nom_tercero) >= 4 AND LENGTH(nom_tercero) <= 50),	    --nombre del tercero
	dir_tercero			DATOS_UBICACION,																		    --Estructura de   datos de ubicación de terceros
	id_ciudad			VARCHAR			NOT NULL ,																    --identificador de ciudad
	id_restriccion		DECIMAL(2,0)	NOT NULL CHECK(id_restriccion > 0 AND id_restriccion <= 99),			    --identificador de las restrincion
	ind_estado			BOOLEAN			NOT NULL, --TRUE:Activo ( FALSE:Inactivo)								    --indicador de estado del tercero
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo   --indicador de borrado lógico
	PRIMARY KEY(id_tercero),			
	FOREIGN KEY(id_ciudad)			REFERENCES tab_ciudades(id_ciudad),			
	FOREIGN KEY(id_cat_tercero)		REFERENCES tab_cat_terceros(id_cat_tercero),			
	FOREIGN KEY(id_restriccion)		REFERENCES tab_restricciones(id_restriccion)
);

-------------------------
-- TABLA DE BANCOS.  --
------------------------- 
CREATE TABLE IF NOT EXISTS tab_bancos
(
    id_banco			DECIMAL(10,0)	NOT NULL CHECK(id_banco >= 1 AND id_banco <= 9999999999),			    --identificador del banco
    nom_banco			VARCHAR			NOT NULL CHECK(LENGTH(nom_banco) >= 4 AND LENGTH(nom_banco) <= 50),	    --nombre del banco
    ind_estado			BOOLEAN			NOT NULL, --TRUE:Activo ( FALSE:Inactivo)								    --indicador de estado del banco
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo   --indicador de borrado lógico
    PRIMARY KEY(id_banco)
);

----------------------------
-- TABLA DE PRESUPUESTO.  --
---------------------------- 
CREATE TABLE IF NOT EXISTS tab_presupuesto
(
--    id_area             
    id_mes              DECIMAL(10,0)   NOT NULL,                                    -- Período (FK)
    descrip_presupuesto     VARCHAR(200)    DEFAULT '',                                  -- Descripción
    fecha_aprobacion        DATE,                                                        -- Fecha de aprobación
    TOTAL PRESUPUESTO (SUMATORIA DE LOS ITEMS DEL MES)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                      -- Borrado lógico
    PRIMARY KEY(id_presupuesto),                                                        -- Llave primaria
    FOREIGN KEY(id_periodo) REFERENCES tab_period_presupuesto(id_periodo),       -- FK a período
    FOREIGN KEY(id_tipo_presupuesto) REFERENCES tab_tipo_presupuesto(id_tipo_presupuesto), -- FK a tipo
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),            -- FK a empresa
    UNIQUE(id_periodo, id_tipo_presupuesto, version)                                    -- No duplicar mismo período+tipo+versión
);

----------------------------
-- TABLA DE DETALLE PRESUPUESTO.  --
---------------------------- 

CREATE TABLE IF NOT EXISTS tab_det_presupuestos
(
     id_plan                 DECIMAL(10,0)   NOT NULL,                                     -- Plan (FK)
    monto_aprobado          DECIMAL(15,0)   NOT NULL CHECK(monto_aprobado >= 0),          -- Monto aprobado
    monto_comprometido      DECIMAL(15,0)   NOT NULL DEFAULT 0,                           -- Monto comprometido (pedidos)
    monto_ejecutado         DECIMAL(15,0)   NOT NULL DEFAULT 0,                           -- Monto ejecutado (real)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                       -- Borrado lógico
    PRIMARY KEY(id_detalle_presupuesto),                                                 -- Llave primaria
    FOREIGN KEY(id_plan) REFERENCES tab_planeacion_presupuesto(id_plan),          -- FK a plan
    CONSTRAINT chk_det_presupuesto_comprometido CHECK (monto_comprometido <= monto_aprobado), -- No comprometer más de lo aprobado
    CONSTRAINT chk_det_presupuesto_ejecutado CHECK (monto_ejecutado <= monto_aprobado)   -- No ejecutar más de lo aprobado
);

----------------------------
-- TABLA DE PERIODO DE PRESUPUESTO.  --
---------------------------- 

CREATE TABLE IF NOT EXISTS tab_period_presupuesto
(
    id_periodo          DECIMAL(10,0)   NOT NULL CHECK(id_periodo > 0),                    -- ID del período
    anio_periodo        DECIMAL(4,0)    NOT NULL CHECK(anio_periodo BETWEEN 2000 AND 2100), -- Año (2000-2100)
    mes_periodo         DECIMAL(2,0)    NOT NULL CHECK(mes_periodo BETWEEN 1 AND 12),      -- Mes (1-12)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                             -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                            -- Borrado lógico
    PRIMARY KEY(id_periodo)                                                               -- Llave primaria
);

----------------------------
-- TABLA DE TIPO DE PRESUPUESTO.  --
---------------------------- 

CREATE TABLE IF NOT EXISTS tab_tipo_presupuesto
(
    id_tipo_presupuesto DECIMAL(10,0)   NOT NULL CHECK(id_tipo_presupuesto > 0),           -- ID del tipo
    nom_tipo            VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipo) >= 3),             -- Nombre del tipo
    descrip_tipo        VARCHAR(200)    DEFAULT '',                                        -- Descripción
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                             -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                            -- Borrado lógico
    PRIMARY KEY(id_tipo_presupuesto)                                                      -- Llave primaria
);

----------------------------
-- TABLA DE PLANEACION DE PRESUPUESTO.  --
---------------------------- 

CREATE TABLE IF NOT EXISTS tab_planeacion_presupuesto
(
    AREA
    MES
    CUENTA PUC
    VALOR_PLANEADO
    VALOR EJECUTADO
    IND DE MES CERRADO (BOOLEAN)
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_plan),                                                             -- Llave primaria
    FOREIGN KEY(id_area) REFERENCES public.tab_areas(id_area),                         -- FK a área
    FOREIGN KEY(id_presupuesto) REFERENCES tab_presupuesto(id_presupuesto),     -- FK a presupuesto
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc)  -- FK a PUC
);

----------------------------
-- TABLA DE EJECUCIÓN DE PRESUPUESTO.  --
---------------------------- 
CREATE TABLE IF NOT EXISTS tab_ejecucion_presupuesto
(
    id_ejecucion        DECIMAL(10,0)   NOT NULL,                                         -- ID de ejecución
    id_plan             DECIMAL(10,0)   NOT NULL,                                         -- Plan (FK)
    id_comprobante      DECIMAL(10,0)   NOT NULL,                                         -- Comprobante (FK)
    id_detalle_presupuesto DECIMAL(10,0) NOT NULL,                                        -- Detalle (FK)
    valor_real          DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_real >= 0),       -- Valor real ejecutado
    fecha_registro      DATE            NOT NULL DEFAULT CURRENT_DATE,                   -- Fecha de registro
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_ejecucion),                                                          -- Llave primaria
    FOREIGN KEY(id_plan) REFERENCES tab_planeacion_presupuesto(id_plan),         -- FK a plan
    FOREIGN KEY(id_comprobante) REFERENCES tab_comprobantes_contab(id_comprobante), -- FK a comprobante
    FOREIGN KEY(id_detalle_presupuesto) REFERENCES tab_det_presupuestos(id_detalle_presupuesto) -- FK a detalle
);

-------------------------------------
-- TABLA TIPO DE CATEGORIAS RIESGO --
-------------------------------------

CREATE TABLE IF NOT EXISTS tab_categoria_riesgo
(
	id_categoria_riesgo		DECIMAL(1,0)						 NOT NULL,
	tipo_categoria			VARCHAR								 NOT NULL,
	desc_riesgo				VARCHAR								 NOT NULL,
	ind_borrado				BOOLEAN							     NOT NULL 		DEFAULT FALSE,	

	PRIMARY KEY(id_categoria_riesgo)
);

------------------------------
-- TABLA TIPO DE RIESGOS --
------------------------------

CREATE TABLE IF NOT EXISTS tab_riesgos
(
	id_riesgo				DECIMAL(1,0)							 NOT NULL,
	nivel_riesgo			DECIMAL(1,0)						 	 NOT NULL,
	id_categoria_riesgo		DECIMAL(1,0)						 	 NOT NULL,
	nom_riesgo				VARCHAR                                  NOT NULL,
	ind_borrado				BOOLEAN									 NOT NULL 		DEFAULT FALSE,	
	PRIMARY KEY(id_riesgo),
	FOREIGN KEY(id_categoria_riesgo) REFERENCES tab_categoria_riesgo(id_categoria_riesgo)
);

------------------------------
-- TABLA TIPO DE COMPROBANTES --
------------------------------
CREATE TABLE IF NOT EXISTS tab_tip_comprobantes
(
    id_tipcomprobante       SMALLINT        NOT NULL CHECK(id_tipcomprobante > 0),           -- ID del tipo
    nom_tipcomprobante      VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipcomprobante) >= 3), -- Nombre
    num_inicial             
    num_final
    num_actual
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                           -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_tipcomprobante)                                                      -- Llave primaria
);

------------------------------
-- TABLA ENCABEZADO DE COMPROBANTES --
------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_comprobantes
(
    id_tipcomprobante   DECIMAL(10,0)   NOT NULL,                                       -- Tipo (FK)
    NUMERO DE COMPROBANTE
    MES
    num_comprobante     DECIMAL(10,0)   NOT NULL,                                       -- Número del comprobante
    fecha_comprobante   DATE            NOT NULL CHECK(fecha_comprobante <= CURRENT_DATE), -- Fecha
    concepto            VARCHAR(200)    NOT NULL,                                       -- Concepto/descripción
    total_debe          DECIMAL(15,0)   NOT NULL DEFAULT 0,                             -- Total débitos
    total_haber         DECIMAL(15,0)   NOT NULL DEFAULT 0,                             -- Total créditos
    estado              CHAR(1)         NOT NULL DEFAULT 'B' CHECK(estado IN ('B', 'C', 'A')), -- B=Borrador, C=Contabilizado, A=Anulado
    usuario_creacion    VARCHAR(50)     DEFAULT CURRENT_USER,                           -- Usuario que creó
    fecha_creacion      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,                      -- Fecha de creación
    usuario_contabilizacion VARCHAR(50),                                                -- Usuario que contabilizó
    fecha_contabilizacion TIMESTAMP,                                                    -- Fecha de contabilización
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_comprobante),                                                       -- Llave primaria
    FOREIGN KEY(id_tipcomprobante) REFERENCES tab_tip_comprobantes(id_tipcomprobante), -- FK a tipo
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),           -- FK a empresa
    FOREIGN KEY(id_tercero) REFERENCES public.tab_terceros(id_tercero),                -- FK a tercero
    UNIQUE(id_tipcomprobante, id_periodo_contable, num_comprobante),                   -- No duplicar tipo+período+número
    CONSTRAINT chk_comprobante_cuadrado CHECK (estado != 'C' OR total_debe = total_haber) -- Si está contabilizado, debe estar cuadrado
);
------------------------------
-- TABLA DETALLE DE COMPROBANTES --
------------------------------
CREATE TABLE IF NOT EXISTS tab_det_comprobantes
(
   id_tipcomprobante   DECIMAL(10,0)   NOT NULL,                                       -- Tipo (FK)
    NUMERO DE COMPROBANTE
    CUENTA PUC
    descrip_det_comp    VARCHAR(200)    DEFAULT '',                                     -- Descripción de la línea
    valor_debito        DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_debito >= 0),    -- Valor débito
    valor_credito       DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_credito >= 0),   -- Valor crédito
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_det_comp),                                                          -- Llave primaria
    FOREIGN KEY(id_comprobante) REFERENCES tab_enc_comprobantes(id_comprobante), -- FK a comprobante (si se borra el comprobante, se borran sus líneas)
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc), -- FK a PUC
    CONSTRAINT chk_det_comprobante_xor CHECK (                                          -- Una línea NO puede tener débito y crédito a la vez
        (valor_debito > 0 AND valor_credito = 0) OR 
        (valor_debito = 0 AND valor_credito > 0)
    )
);

-------------------------------------
-- MODULO DE COMPRAS Y PROVEEDORES --
-------------------------------------

-----------------------
-- TABLA PROVEEDORES --
-----------------------
CREATE TABLE IF NOT EXISTS tab_proveedores
(
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[1-9][0-9]{7,9}$'),                                             -- Identificador del proveedor (ID empresa)
    val_sigla           VARCHAR         NOT NULL CHECK(LENGTH(val_sigla) >= 2 AND LENGTH(val_sigla) <= 10),                             -- Sigla del proveedor (ej. "PROV1")
    val_latitud         DECIMAL(18,16)  NOT NULL CHECK(val_latitud >= -4 AND val_latitud <= 80) DEFAULT 0,                              -- Latitud geográfica del proveedor
    val_longitud        DECIMAL(18,16)  NOT NULL CHECK(val_longitud >= -80 AND val_longitud <= -50) DEFAULT 0,                          -- Longitud geográfica del proveedor
    nom_contacto        VARCHAR         NOT NULL CHECK(LENGTH(nom_contacto) >= 5 AND LENGTH(nom_contacto) <= 60) DEFAULT 'N/A',         -- Nombre del contacto
    tel_contacto        DECIMAL(10,0)   NOT NULL CHECK(tel_contacto >= 0) DEFAULT 0,                                                    -- Teléfono del contacto
    nom_cont_contab     VARCHAR         NOT NULL CHECK(LENGTH(nom_cont_contab) >= 5 AND LENGTH(nom_cont_contab) <= 60) DEFAULT 'N/A',   -- Nombre del contacto contable
    tel_cont_contab     DECIMAL(10,0)   NOT NULL CHECK(tel_cont_contab >= 0) DEFAULT 0,                                                 -- Teléfono del contacto contable
    ind_dias_pago       DECIMAL(3,0)    NOT NULL CHECK(ind_dias_pago <= 180) DEFAULT 0,                                                 -- Días de pago acordados con el proveedor
    val_saldo_deuda     DECIMAL(11,0)   NOT NULL CHECK(val_saldo_deuda >= 0 AND val_saldo_deuda <= 99999999999) DEFAULT 0,              -- Saldo de deuda actual con el proveedor
    val_tiempo_entrega  DECIMAL(3,0)    NOT NULL CHECK(val_tiempo_entrega >= 0 AND val_tiempo_entrega <= 365) DEFAULT 0,                -- Días de entrega del proveedor
    fec_registro        DATE            NOT NULL DEFAULT CURRENT_DATE,                                                                  -- Fecha de registro del proveedor
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                                         -- TRUE = Borrado / FALSE = Activo 
    PRIMARY KEY(id_proveedor),
    FOREIGN KEY(id_proveedor) REFERENCES public.tab_terceros(id_tercero)
);

-------------------------------------
-- TABLA EVALUACIÓN DE PROVEEDORES --
-------------------------------------
CREATE TABLE IF NOT EXISTS tab_eval_prov
(
    id_eva_prov         DECIMAL(3,0)    NOT NULL CHECK(id_eva_prov > 0 AND id_eva_prov <= 999),                            -- Identificador de la evaluación
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[1-9][0-9]{7,9}$'),                                -- Identificador del proveedor
    fec_evaluacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Fecha de la evaluación
    val_punt_calidad    DECIMAL(3,0)    NOT NULL CHECK(val_punt_calidad >= 0 AND val_punt_calidad <= 100) DEFAULT 0,       -- Puntaje de calidad (0-100)
    val_punt_puntual    DECIMAL(3,0)    NOT NULL CHECK(val_punt_puntual >= 0 AND val_punt_puntual <= 100) DEFAULT 0,       -- Puntaje de puntualidad (0-100)
    val_puntaje_total   DECIMAL(4,2)    NOT NULL CHECK(val_puntaje_total >= 0 AND val_puntaje_total <= 100) DEFAULT 0,     -- Puntaje total (calculado por trigger)
    val_coments         TEXT            NOT NULL CHECK(LENGTH(TRIM(val_coments)) > 0)DEFAULT 'N/A',                        -- Comentarios de la evaluación
    nom_evaluador       VARCHAR         NOT NULL CHECK(LENGTH(nom_evaluador) >= 5 AND LENGTH(nom_evaluador) <= 60),        -- Nombre del evaluador
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_eva_prov),
    FOREIGN KEY(id_proveedor) REFERENCES tab_proveedores(id_proveedor)
);

---------------------
-- TABLA PRODUCTOS --
---------------------
CREATE TABLE IF NOT EXISTS tab_productos
(
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    ind_tip_producto    BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Bien / FALSE = Servicio
    nom_producto        VARCHAR         NOT NULL CHECK(LENGTH(nom_producto) >= 4 AND LENGTH(nom_producto) <= 60),          -- Nombre del producto
    val_poriva          DECIMAL(2,0)    NOT NULL CHECK(val_poriva >= 0 AND val_poriva < 100) DEFAULT 0,                    -- % IVA del producto
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Activo / FALSE = Inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_producto)
);

---------------------------------
-- TABLA PRODUCTOS COMERCIALES --
---------------------------------
CREATE TABLE IF NOT EXISTS tab_prod_comerciales
(
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_exist           DECIMAL(3,0)    NOT NULL CHECK(val_exist >= 0 AND val_exist <= 999) DEFAULT 0,                     -- Existencias del producto
    val_venta           DECIMAL(11,0)   NOT NULL CHECK(val_venta >= 0 AND val_venta <= 99999999999) DEFAULT 0,             -- Valor de venta
    ind_disponible      BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Disponible / FALSE = No disponible
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_producto),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);

------------------------------
-- TABLA PRODUCTOS INTERNOS --
------------------------------
CREATE TABLE IF NOT EXISTS tab_prod_internos
(
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    id_area             DECIMAL(5,0)    NOT NULL CHECK(id_area > 0),                                                       -- Área a la que pertenece el producto
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_producto),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto),
    FOREIGN KEY(id_area)     REFERENCES public.tab_areas(id_area)
);

-----------------------------------
-- TABLA PRODUCTOS POR PROVEEDOR --
-----------------------------------
CREATE TABLE IF NOT EXISTS tab_prodxprov
(
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[1-9][0-9]{7,9}$'),                                -- Identificador del proveedor
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_costo           DECIMAL(11,0)   NOT NULL CHECK(val_costo >= 0 AND val_costo <= 99999999999) DEFAULT 0,             -- Costo del producto
    val_pordesc         DECIMAL(2,0)    NOT NULL CHECK(val_pordesc >= 0 AND val_pordesc < 100) DEFAULT 0,                  -- % Descuento del proveedor
    ind_disponible      BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Disponible / FALSE = No disponible
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_proveedor, id_producto),
    FOREIGN KEY(id_proveedor) REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY(id_producto)  REFERENCES tab_productos(id_producto)
);

-----------------------------------------------------------------
-- TABLA ENCABEZADO SOLICITUD DE COMPRA POR ÁREA (REQUISICIÓN) --
-----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_solcomp
(
    id_solcompra        DECIMAL(6,0)    NOT NULL CHECK(id_solcompra > 0),                                                  -- Identificador de la solicitud
    id_area             DECIMAL(5,0)    NOT NULL CHECK(id_area > 0),                                                       -- Área que solicita la compra
    fec_solicitud       DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Fecha de solicitud
    fec_requerida       DATE            NOT NULL,                                                                          -- Fecha requerida (>= fec_solicitud)
    val_justificacion   TEXT            NOT NULL CHECK(LENGTH(TRIM(val_justificacion)) > 0) DEFAULT 'N/A',                 -- Justificación de la solicitud
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado >= 1 AND ind_estado <= 3) DEFAULT 2,                     -- 1=Aprobado, 2=Pendiente, 3=Anulado
    PRIMARY KEY(id_solcompra),
    FOREIGN KEY(id_area) REFERENCES public.tab_areas(id_area),
    CONSTRAINT fec_requerida_valida CHECK(fec_requerida >= fec_solicitud)
);

------------------------------------------------
-- TABLA DETALLE SOLICITUD DE COMPRA POR ÁREA --
------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_solcomp
(
    id_solcompra        DECIMAL(6,0)    NOT NULL CHECK(id_solcompra > 0),                                                  -- Identificador de la solicitud
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_cantidad        DECIMAL(3,0)    NOT NULL CHECK(val_cantidad > 0 AND val_cantidad <= 999) DEFAULT 1,                -- Cantidad solicitada
    PRIMARY KEY(id_solcompra, id_producto),
    FOREIGN KEY(id_solcompra) REFERENCES tab_enc_solcomp(id_solcompra),
    FOREIGN KEY(id_producto)  REFERENCES tab_productos(id_producto)
);

-------------------------------------------
-- TABLA ENCABEZADO DE ÓRDENES DE COMPRA --
-------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_ordcomp
(
    id_ordencompra      DECIMAL(6,0)    NOT NULL CHECK(id_ordencompra > 0),                                                -- Identificador de la orden de compra
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[1-9][0-9]{7,9}$'),                                -- Identificador del proveedor
    id_solcompra        DECIMAL(6,0)    NOT NULL DEFAULT 0,                                                                -- ID de solicitud de compra asociada (0 si no viene de una solicitud) 
    fec_emision         DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Fecha de emisión
    id_ciudad           VARCHAR         NOT NULL CHECK(LENGTH(id_ciudad) = 5),                                             -- Identificador de la ciudad
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado >= 1 AND ind_estado <= 3) DEFAULT 2,                     -- 1=Aprobado, 2=Pendiente, 3=Anulado
    val_total           DECIMAL(11,0)   NOT NULL CHECK(val_total >= 0 AND val_total <= 99999999999) DEFAULT 0,             -- Valor total de la orden
    PRIMARY KEY(id_ordencompra),
    FOREIGN KEY(id_proveedor) REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY(id_ciudad)    REFERENCES public.tab_ciudades(id_ciudad),
    FOREIGN KEY(id_solcompra) REFERENCES tab_enc_solcomp(id_solcompra)
);

----------------------------------------
-- TABLA DETALLE DE ÓRDENES DE COMPRA --
----------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_ordcomp
(
    id_ordencompra      DECIMAL(6,0)    NOT NULL CHECK(id_ordencompra > 0),                                                -- Identificador de la orden de compra
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_cantidad        DECIMAL(3,0)    NOT NULL CHECK(val_cantidad > 0 AND val_cantidad <= 999) DEFAULT 1,                -- Cantidad pedida
    val_descuento       DECIMAL(11,0)   NOT NULL CHECK(val_descuento >= 0 AND val_descuento <= 99999999999) DEFAULT 0,     -- Valor descuento (costo * %desc)
    val_bruto           DECIMAL(11,0)   NOT NULL CHECK(val_bruto >= 0 AND val_bruto <= 99999999999) DEFAULT 0,             -- Valor bruto
    val_iva             DECIMAL(11,0)   NOT NULL CHECK(val_iva >= 0 AND val_iva <= 99999999999) DEFAULT 0,                 -- Valor IVA
    val_neto            DECIMAL(11,0)   NOT NULL CHECK(val_neto >= 0 AND val_neto <= 99999999999) DEFAULT 0,               -- Valor neto
    PRIMARY KEY(id_ordencompra, id_producto),
    FOREIGN KEY(id_ordencompra) REFERENCES tab_enc_ordcomp(id_ordencompra),
    FOREIGN KEY(id_producto)    REFERENCES tab_productos(id_producto)
);

--------------------------------------------------
-- TABLA SEGUIMIENTO DE ÓRDENES DE COMPRA (ENC) --
--------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_seg_ordcomp
(
    id_ordencompra      DECIMAL(6,0)    NOT NULL CHECK(id_ordencompra > 0),                                                -- Identificador de la orden de compra
    fec_aprobacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Se llena via trigger cuando ind_estado cambia a 1
    fec_limite          DATE            NOT NULL,                                                                          -- fec_aprobacion + val_tiempo_entrega de tab_proveedores (se llena via trigger)
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado >= 1 AND ind_estado <= 3) DEFAULT 1,                     -- 1=En espera, 2=Parcial, 3=Completo
    val_observacion     TEXT            NOT NULL  CHECK(LENGTH(TRIM(val_observacion)) > 0)DEFAULT 'N/A',                   -- Detalles si hubo problema
    PRIMARY KEY(id_ordencompra),
    FOREIGN KEY(id_ordencompra) REFERENCES tab_enc_ordcomp(id_ordencompra)
);

----------------------------------------------------
-- TABLA DETALLE SEGUIMIENTO DE ÓRDENES DE COMPRA --
----------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_seg_ordcomp
(
    id_ordencompra      DECIMAL(6,0)    NOT NULL CHECK(id_ordencompra > 0),                                                -- Identificador de la orden de compra
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_cant_esperada   DECIMAL(3,0)    NOT NULL CHECK(val_cant_esperada > 0 AND val_cant_esperada <= 999),                -- Cantidad pedida original (no cambia)
    val_cant_recibida   DECIMAL(3,0)    NOT NULL CHECK(val_cant_recibida >= 0 AND val_cant_recibida <= 999) DEFAULT 0,     -- Cantidad recibida acumulada
    fec_recepcion       DATE            NULL,                                                                              -- Fecha de última recepción (NULL si aún no llega)
    PRIMARY KEY(id_ordencompra, id_producto),
    FOREIGN KEY(id_ordencompra) REFERENCES tab_seg_ordcomp(id_ordencompra),
    FOREIGN KEY(id_producto)    REFERENCES tab_productos(id_producto),
    CONSTRAINT cant_valida CHECK(val_cant_recibida <= val_cant_esperada)                                                   -- No puede recibirse más de lo pedido
);

--------------------------------------------
-- VISTA SEMAFORIZACIÓN ÓRDENES DE COMPRA --
--------------------------------------------
CREATE OR REPLACE VIEW vw_semaforo_ordcomp AS
SELECT
    s.id_ordencompra,
    o.id_proveedor,
    s.fec_aprobacion,
    s.fec_limite,
    s.ind_estado,
    s.fec_limite - CURRENT_DATE AS dias_restantes,
    CASE
        WHEN s.ind_estado = 3                           THEN 'COMPLETO'  -- ⚪
        WHEN s.fec_limite - CURRENT_DATE < 0            THEN 'VENCIDO'   -- 🔴
        WHEN s.fec_limite - CURRENT_DATE <= 3           THEN 'CRITICO'   -- 🔴
        WHEN s.fec_limite - CURRENT_DATE <= 7           THEN 'PROXIMO'   -- 🟡
        ELSE                                                 'A TIEMPO'  -- 🟢
    END AS semaforo
FROM tab_seg_ordcomp s
JOIN tab_enc_ordcomp o ON s.id_ordencompra = o.id_ordencompra;

--------------------------------------------
-- MÓDULO DE GESTIÓN HUMANA Y NÓMINA --
--------------------------------------------

-- 2. TABLA DE PARAMETROS LEGALES 
CREATE TABLE IF NOT EXISTS tab_pmtros_legales
(
    id_parametro            VARCHAR(5)            NOT NULL,                                                                                     -- ID texto corto
    ano                     INTEGER               NOT NULL UNIQUE,                                                                              -- Año de vigencia
    salario_minimo          DECIMAL(10,2)         NOT NULL,                                                                                     -- Sueldo base legal
    aux_transporte          DECIMAL(10,2)         NOT NULL,                                                                                     -- Subsidio transporte
    valor_uvt               DECIMAL(10,2)         NOT NULL,                                                                                     -- Valor tributario
    tope_ibc                DECIMAL(10,2)         NOT NULL CHECK(tope_ibc >= 0),                                                                -- Límite de cotización
        -- Porcentajes empleado
    pct_salud_emplea        DECIMAL(5,2)          NOT NULL DEFAULT 4.00,
    pct_pension_empld       DECIMAL(5,2)          NOT NULL DEFAULT 4.00,
    pct_solidaridad         DECIMAL(5,2)          NOT NULL DEFAULT 1.00,
    -- Porcentajes empleador
    pct_salud_emplr         DECIMAL(5,2)          NOT NULL DEFAULT 8.50,
    pct_pension_emplr       DECIMAL(5,2)          NOT NULL DEFAULT 12.00,
    pct_arl                 DECIMAL(5,2)          NOT NULL DEFAULT 0.522,
    pct_sena                DECIMAL(5,2)          NOT NULL DEFAULT 2.00,
    pct_icbf                DECIMAL(5,2)          NOT NULL DEFAULT 3.00,
    pct_ccf                 DECIMAL(5,2)          NOT NULL DEFAULT 4.00,
    pct_prima               DECIMAL(5,2)          NOT NULL DEFAULT 8.33,
    -- prestaciones sociales
    pct_cesantias           DECIMAL(5,2)          NOT NULL DEFAULT 8.33,
    pct_intereses_ces       DECIMAL(5,2)          NOT NULL DEFAULT 12.00,
    dias_vacaciones         INTEGER               NOT NULL DEFAULT 15,
        -- Jornada y recargos (Ley 2026)
    jornada_max_horas       INTEGER               NOT NULL DEFAULT 42,
    hora_inicio_noct        TIME                  NOT NULL DEFAULT '19:00:00',
    hora_fin_noct           TIME                  NOT NULL DEFAULT '06:00:00',
    pct_rec_nocturno        DECIMAL(5,2)          NOT NULL DEFAULT 35.00,
    pct_rec_dominical       DECIMAL(5,2)          NOT NULL DEFAULT 90.00,
    pct_rec_dom_noct        DECIMAL(5,2)          NOT NULL DEFAULT 125.00,
    pct_extra_diurna        DECIMAL(5,2)          NOT NULL DEFAULT 25.00,
    pct_extra_nocturna      DECIMAL(5,2)          NOT NULL DEFAULT 75.00,
    pct_extra_dominical     DECIMAL(5,2)          NOT NULL DEFAULT 100.00,
    -- Fechas de vigencia
    vigencia_desde          DATE                  NOT NULL,
    vigencia_hasta          DATE,
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_parametro)                                                          
);

-- TABLA TIPO DE DOTACIÓN
CREATE TABLE IF NOT EXISTS tab_dotacion
(
    id_dotacion             VARCHAR(5)            NOT NULL,
    nom_dotacion         VARCHAR(100)          NOT NULL,
    descripcion             VARCHAR(200)          NOT NULL,
    tallas_disponibles      VARCHAR(5)            NOT NULL,
    genero                  BOOLEAN               NOT NULL,                                                                                        --TRUE:Masculino , False:Femenino
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_dotacion)
);

-- 3. TABLA DE PERSONAS (Maestra de identidad)
CREATE TABLE IF NOT EXISTS tab_personas
(
    id_persona              VARCHAR(10)           NOT NULL,                                                                                         -- Documento o ID único
    tipo_doc                VARCHAR(5)            NOT NULL,                                                                                         -- CC, CE, TI, etc.
    nom_persona             VARCHAR(100)          NOT NULL,                                                                                         -- Nombres
    ape_persona             VARCHAR(100)          NOT NULL,                                                                                         -- Apellidos
    fecha_nacimiento        DATE                  NOT NULL,                                                                                         -- Fecha nacimiento
    ind_gen_biologico       BOOLEAN               NOT NULL,                                                                                         -- Indicador de género
    id_departamento         VARCHAR(2)            NOT NULL,                                                                                         -- Relación con dpto
    id_ciudad               VARCHAR(5)            NOT NULL,                                                                                         -- Relación con ciudad
    data_residencia         DATOS_UBICACION,                                                                                                              -- Tipo compuesto (Dirección)
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,                                                                   
    PRIMARY KEY(id_persona),                                                                                                                        -- PK Única
    FOREIGN KEY(id_ciudad) REFERENCES public.tab_ciudades(id_ciudad),                                                                               -- Enlace a ciudades
    FOREIGN KEY(id_departamento) REFERENCES public.tab_dptos(id_dpto)                                                                               -- Enlace a dptos
);                                                                  
CREATE INDEX idx_nom_persona ON tab_personas(nom_persona);                                                                                   -- Agiliza búsqueda por nombre
CREATE INDEX idx_ape_persona ON tab_personas(ape_persona);                                                                                   -- Agiliza búsqueda por apellido

-- 4. TABLA DE EDUCACIÓN 
CREATE TABLE IF NOT EXISTS tab_educacion
(
    id_educacion            VARCHAR(5)             NOT NULL CHECK(LENGTH(id_educacion) = 5 ),                                           -- ID título
    id_persona              VARCHAR(10)            NOT NULL,                                                                                        -- Dueño del título
    nivel_estudio           VARCHAR                NOT NULL,                                                                                        -- Profesional, etc.
    titulo_obtenido         VARCHAR(200)           NOT NULL,                                                                                        -- Nombre título
    institucion             VARCHAR(200)           NOT NULL,                                                                                        -- Universidad/Colegio
    ind_prof_principal      BOOLEAN                DEFAULT FALSE,                                                                                 
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_educacion),                                                            
    FOREIGN KEY(id_persona) REFERENCES tab_personas(id_persona)                                                                              -- Relación persona
);
CREATE INDEX idx_nivel_estudio ON tab_educacion(nivel_estudio);                                                                              -- Búsqueda por nivel educativo

-- 5. TABLA DE CARGOS
CREATE TABLE IF NOT EXISTS tab_cargos
(
    id_cargo                VARCHAR(5)             NOT NULL,                                                                                            -- ID puesto
    nombre_cargo            VARCHAR                NOT NULL CHECK(LENGTH(nombre_cargo) BETWEEN 3 AND 50),                                               -- Nombre puesto
    descripcion             VARCHAR                NOT NULL CHECK(LENGTH(descripcion) BETWEEN 5 AND 200),                                               -- Funciones
    salario_maximo          DECIMAL(10,2)          NOT NULL CHECK (salario_maximo >= salario_minimo),                
    salario_minimo          DECIMAL(10,2)          NOT NULL CHECK(salario_minimo >= 1),              
    nivel_jerarquico        VARCHAR                NOT NULL CHECK(LENGTH(nivel_jerarquico) BETWEEN 3 AND 20),                                        -- Rango
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_cargo)                                                          
);
CREATE INDEX idx_nom_cargo ON tab_cargos(nombre_cargo);                                                                      -- Búsqueda por nombre de cargo

-- 6. TABLA DE VACANTES 
CREATE TABLE IF NOT EXISTS tab_vacantes
(
    id_vacante              VARCHAR(5)             NOT NULL,                                                                        -- ID oferta
    nom_vacante             VARCHAR                NOT NULL,                                                                        -- Título oferta
    id_cargo                VARCHAR(5)             NOT NULL,                                                                        -- Cargo asociado
    salario_ofrecido        DECIMAL(10,2)          NOT NULL,                                                                        -- Salario ofrecido
    fecha_cierre            DATE                   NOT NULL,                                                                        -- Fecha límite
    cant_vacantes           INTEGER                NOT NULL,                                                                        -- Cupos disponibles
    modalidad               VARCHAR                NOT NULL,                                                                        -- Presencial, remoto, mixto
    estado_vacante          BOOLEAN                NOT NULL,                                                                        -- Activa o cerrada
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_vacante),                                  
    FOREIGN KEY(id_cargo) REFERENCES tab_cargos(id_cargo)                                                                -- Relación cargo
);
CREATE INDEX idx_nom_vacante ON tab_vacantes(nom_vacante);                                                              -- Búsqueda por nombre de vacante

-- 7. TABLA DE REQUISITOS DE VACANTE 
CREATE TABLE IF NOT EXISTS tab_requisitos_vacante 
(
    id_requisito            VARCHAR(5)            NOT NULL,                                                                    -- ID requisito
    id_vacante              VARCHAR               NOT NULL,                                                                    -- ID vacante
    desc_requisito          VARCHAR               NOT NULL,                                                                    -- Texto del requisito
    ind_cumplimiento        BOOLEAN               NOT NULL,                                                                    -- ¿Es obligatorio?
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_requisito),                               -- PK
    FOREIGN KEY(id_vacante) REFERENCES tab_vacantes(id_vacante)                                                          -- Relación vacante
);

-- 8. TABLA DE CANDIDATOS
CREATE TABLE IF NOT EXISTS tab_candidatos
(
    id_candidato            INTEGER                 NOT NULL,                                                                   -- ID aspirante (Autoincrementable)
    id_persona              VARCHAR(10)             NOT NULL UNIQUE,                                                            -- Persona vinculada
    ind_estado              BOOLEAN                 NOT NULL DEFAULT FALSE,                                                     -- ¿Sigue en proceso?
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_candidato),                                     
    FOREIGN KEY(id_persona) REFERENCES tab_personas(id_persona)                                                        -- Relación a la persona
);
CREATE INDEX idx_id_persona ON tab_candidatos(id_persona);                                                             -- Búsqueda rápida por persona

-- 9. TABLA POSTULACIONES
CREATE TABLE IF NOT EXISTS tab_postulaciones
(
    id_postulacion          INTEGER                 NOT NULL,                                                              -- ID aplicación (Autoincrementable)
    id_candidato            INTEGER                 NOT NULL,                                                           -- Candidato que aplica
    id_vacante              VARCHAR                 NOT NULL,                                                           -- Vacante deseada
    fecha_postulacion       DATE                    NOT NULL,                                                           -- Cuándo 
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_postulacion),                                             
    FOREIGN KEY(id_candidato) REFERENCES tab_candidatos(id_candidato),                                           -- Relación candidato
    FOREIGN KEY(id_vacante) REFERENCES tab_vacantes(id_vacante)                                                  -- Relación vacante
);

-- 10. TABLA DE PRUEBAS
CREATE TABLE IF NOT EXISTS tab_pruebas 
(
    id_prueba               VARCHAR                 NOT NULL,                                                               -- ID examen
    nom_prueba              VARCHAR                 NOT NULL,                                                               -- Nombre examen
    puntaje_min             DECIMAL(5,2)            NOT NULL CHECK(puntaje_min >= 0),                                       -- Nota mínima para pasar
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_prueba)                           
);
CREATE INDEX idx_nom_prueba ON tab_pruebas(nom_prueba); -- Búsqueda por nombre de prueba

-- 11. TABLA DE RESULTADO DE PRUEBAS
CREATE TABLE IF NOT EXISTS tab_resultado_pruebas 
(
    id_resultado            VARCHAR                 NOT NULL,                                                                   -- ID resultado
    id_prueba               VARCHAR                 NOT NULL,                                                                   -- Prueba tomada
    id_candidato            VARCHAR(20)             NOT NULL,                                                                   -- Candidato evaluado
    puntaje_obtenido        DECIMAL(5,2)            NOT NULL CHECK(puntaje_obtenido >= 0),                                      -- Nota sacada
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_resultado),                                                                                                  -- PK
    FOREIGN KEY(id_prueba) REFERENCES tab_pruebas(id_prueba),                                                            -- Relación prueba
    FOREIGN KEY(id_candidato) REFERENCES tab_candidatos(id_candidato)                                                    -- Relación candidato
);
 

-- TABLA DE EVENTOS DE CAPACITACIÓN
CREATE TABLE IF NOT EXISTS tab_capacitaciones 
(
    id_capacitacion         VARCHAR(20)             NOT NULL,
    nom_capacitacion        VARCHAR(150)            NOT NULL,
    fecha_programada        TIMESTAMP               NOT NULL,
    lugar                   VARCHAR(100),
    instructor              VARCHAR(100),
    tematica                VARCHAR(50),                                                                                -- Ej: Seguridad, Técnica, Habilidades
    horas_duracion          INTEGER,
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_capacitacion)
);

-- 14. TABLA DE EMPLEADOS
CREATE TABLE IF NOT EXISTS tab_empleados
(
    id_empleado             VARCHAR(10)             NOT NULL,                             -- Código empleado
    id_persona              VARCHAR(10)             NOT NULL UNIQUE,                      -- Persona vinculada
    rh_empleado             VARCHAR                 NOT NULL,                             -- Tipo de sangre
    fec_ingreso             DATE                    NOT NULL,                             -- Fecha ingreso
    email_corporativo       VARCHAR                 NOT NULL,                             -- Correo empresa
    data_residencia         DATOS_UBICACION,                                              -- Ubicación actual
    ind_auditor             BOOLEAN                 NOT NULL DEFAULT FALSE,               -- ¿Es perfil auditor?
    ind_estado              BOOLEAN                 NOT NULL,                             -- ¿Activo o Inactivo?
    ind_disponibilidad      BOOLEAN                 NOT NULL,                             -- ¿Puede viajar/traslados?
    ind_tipo_empleado       BOOLEAN                 NOT NULL,                             -- ¿Es de planta o contratista?
    id_area                 DECIMAL(15,0)           NOT NULL,                             -- Área de trabajo
    id_cuenta               VARCHAR(20)             NOT NULL,                             -- Cuenta para pagos
    id_riesgo               DECIMAL(1,0)            NOT NULL,
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_empleado),                                                             -- PK
    FOREIGN KEY(id_persona) REFERENCES tab_personas(id_persona),                   -- Relación persona
    FOREIGN KEY(id_cuenta)  REFERENCES PUBLIC.tab_bancos(id_cuenta),                      -- Relación banco
    FOREIGN KEY (id_area)   REFERENCES PUBLIC.tab_areas(id_area),                         --Relación área
    FOREIGN KEY(id_riesgo)  REFERENCES tab_riesgos(id_riesgo)                     -- Relación tabla de riesgos de SST
);

-- TABLA DE ASISTENCIAS Y RESULTADOS
CREATE TABLE IF NOT EXISTS tab_asistencias_capacitacion (
    id_asistencia           VARCHAR(20)             NOT NULL,
    id_capacitacion         VARCHAR(20)             NOT NULL,
    id_empleado             VARCHAR(20)             NOT NULL,
    estado_asistencia       BOOLEAN                 NOT NULL DEFAULT FALSE,         
    calificacion            DECIMAL(5,2),           
    observaciones           TEXT,
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_asistencia),
    FOREIGN KEY (id_capacitacion) REFERENCES tab_capacitaciones(id_capacitacion),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);

-- REGISTRO DE EVALUACIONES
CREATE TABLE IF NOT EXISTS tab_evaluaciones (
    id_evaluacion           VARCHAR(20)             NOT NULL,
    id_empleado             VARCHAR(10)             NOT NULL,
    nombre_evaluador        VARCHAR(20)             NOT NULL,
    tipo_evaluacion         VARCHAR(50)             NOT NULL,                                                               -- Desempeño, 360, etc.
    fecha_evaluacion        DATE                    NOT NULL,
    puntaje_final           DECIMAL(5,2),
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_evaluacion),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);

-- TABLA ENTREGA DOTACIÓN
CREATE TABLE IF NOT EXISTS tab_dotacion_entregas
(
    id_entrega              VARCHAR(10)             NOT NULL,
    id_empleado             VARCHAR(10)             NOT NULL,
    id_dotacion             VARCHAR(10)             NOT NULL,
    fecha_entrega           DATE                    NOT NULL,
    talla                   VARCHAR(8)              NOT NULL,
    cantidad                INTEGER                 NOT NULL CHECK(cantidad >= 1),
    periodo_entrega         VARCHAR(20),                                                                                    -- ABRIL, AGOSTO, DICIEMBRE
    observaciones           VARCHAR(200),
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_entrega),
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),
    FOREIGN KEY(id_dotacion) REFERENCES tab_dotacion(id_dotacion)
);
CREATE INDEX idx_dotacion_empleado ON tab_dotacion_entregas(id_empleado);

-- TABLA HORAS EXTRAS
CREATE TABLE IF NOT EXISTS tab_h_extras
(
    id_h_extras             VARCHAR(20)                  NOT NULL,
    id_empleado             VARCHAR(10)                  NOT NULL,
    fecha                   DATE                         NOT NULL,
    horas                   DECIMAL(4,2) NOT NULL CHECK(horas > 0),
    tipo_hora               VARCHAR(20)                  NOT NULL,
    estado                  VARCHAR(20)                  NOT NULL,
    aprobado_por            VARCHAR(10)                  NOT NULL,
    fecha_aprobacion        DATE,
    observaciones           VARCHAR(200),
    ind_borrado             BOOLEAN                      NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_h_extras),
    FOREIGN KEY(id_empleado)    REFERENCES tab_empleados(id_empleado),
    FOREIGN KEY(aprobado_por)   REFERENCES tab_empleados(id_empleado)
);

-- 15. TABLA DE CONTRATOS
CREATE TABLE IF NOT EXISTS tab_contratos 
(
    id_contrato             VARCHAR(20)                   NOT NULL,                               -- ID contrato
    id_empleado             VARCHAR(10)                   NOT NULL,                               -- Empleado contratado
    salario                 DECIMAL(10,2)                 NOT NULL,                               -- Sueldo pactado
    fecha_inicio            DATE                          NOT NULL,           -- Inicio contrato
    fecha_fin               DATE  CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),                                                                 -- Fin (si aplica)
    tipo_contrato           VARCHAR(20)                   NOT NULL,                               -- Término fijo/indef.
    id_riesgo               DECIMAL(1,0)                  NOT NULL,
    modalidad               VARCHAR(20)                   NOT NULL,                               -- Presencial, remoto, mixto
    ind_estado              BOOLEAN                       NOT NULL,                               -- ¿Vigente?
    id_cargo                VARCHAR(5)                    NOT NULL,                               -- Cargo contratado
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_contrato),                                                                     -- PK
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),                        -- Relación empleado
    FOREIGN KEY(id_cargo) REFERENCES tab_cargos(id_cargo),                                 -- Relación cargo
    FOREIGN KEY(id_riesgo)  REFERENCES tab_riesgos(id_riesgo)                              -- Relación tabla de riesgos de SST
);

-- 16. TABLA DE PRESTAMOS
CREATE TABLE IF NOT EXISTS tab_prestamos
(
    id_prestamo             VARCHAR(20)                   NOT NULL,                             -- ID préstamo
    id_empleado             VARCHAR(10)                   NOT NULL,                             -- Empleado deudor
    val_prestamo            DECIMAL(12,2)                 NOT NULL CHECK(val_prestamo > 0),                             -- Monto prestado
    num_cuotas              INTEGER                       NOT NULL CHECK(num_cuotas > 0),       -- Plazo en meses
    tasa_intereses          DECIMAL(5,2)                  NOT NULL,                             -- Interés cobrado
    fecha_inicio            DATE                          NOT NULL,                             -- Fecha entrega
    fecha_fin               DATE                          NOT NULL,                             -- Fecha fin pago
    ind_estado              BOOLEAN                       NOT NULL,                             -- ¿Deuda vigente?
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_prestamo),                                          
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado) -- Relación empleado
);

-- 17. TABLA DE EXPERIENCIA LABORAL 
CREATE TABLE IF NOT EXISTS tab_exp_laboral
(
    id_experiencia          VARCHAR(20)                   NOT NULL,                                                                     -- ID registro laboral
    id_empleado             VARCHAR(10)                   NOT NULL,                                                                     -- Empleado que tiene la exp.
    nom_empresa             VARCHAR(100)                  NOT NULL,                              
    fecha_inicio            DATE                          NOT NULL,                                                                     -- Cuándo empezó
    fecha_fin               DATE         CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),                                                                                                       -- Cuándo terminó
    cargo_ocupado           VARCHAR(100)                  NOT NULL,                                                                     -- Qué hacía
    funciones               VARCHAR(255)                  NOT NULL,                                                                     -- Qué funciones tenía
    logros                  VARCHAR(255),                                                                                               -- Qué consiguió
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_experiencia),                                                                        -- PK
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado)                               -- Relación empleado
);

-- 18. TABLA DE REFERENCIA LABORAL
CREATE TABLE IF NOT EXISTS tab_ref_laboral
(
    id_referencia           VARCHAR(20)                    NOT NULL,                                                                     -- ID referencia
    id_experiencia          VARCHAR(20)                    NOT NULL,                                                                     -- Vinculado a que empresa
    nom_ref                 VARCHAR(100)                   NOT NULL,                                
    num_telefono            VARCHAR(20)                    NOT NULL,                                                                     -- Contacto referencia
    cargo_referencia        VARCHAR(100)                   NOT NULL,                                                                     -- Cargo del contacto
    ind_borrado             BOOLEAN                        NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_referencia),                                        
    FOREIGN KEY (id_experiencia) REFERENCES tab_exp_laboral(id_experiencia) -- Relación experiencia
);

-- LIQUIDACIONES (para retiros de empleados)
CREATE TABLE IF NOT EXISTS tab_liquidaciones
(
    id_liquidacion          VARCHAR(10)                     NOT NULL,
    id_contrato             VARCHAR(20)                     NOT NULL,
    fecha_retiro            DATE                            NOT NULL,
    motivo_retiro           VARCHAR(50)                     NOT NULL,                                                           -- RENUNCIA, DESPIDO, JUBILACION, etc.
    dias_trabajados         INTEGER                         NOT NULL CHECK(dias_trabajados > 0),
    salario_base            DECIMAL(12,2)                   NOT NULL,
    valor_cesantias         DECIMAL(12,2)                   NOT NULL,
    valor_intereses         DECIMAL(12,2)                   NOT NULL,
    valor_prima             DECIMAL(12,2)                   NOT NULL,
    valor_vacaciones        DECIMAL(12,2)                   NOT NULL,
    otras_prestaciones      DECIMAL(12,2)                   DEFAULT 0,
    total_liquidacion       DECIMAL(12,2)                   NOT NULL,
    fecha_pago              DATE,
    estado                  VARCHAR(20)                     DEFAULT 'PENDIENTE',
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_liquidacion),
    FOREIGN KEY(id_contrato) REFERENCES tab_contratos(id_contrato)
);

-- 19. TABLA DE CONCEPTO DE NOMINA
CREATE TABLE IF NOT EXISTS tab_conceptos_nomina
(
    id_concepto             VARCHAR(10)                     NOT NULL,                                                               -- ID concepto (ej: 001)
    tipo_concepto           VARCHAR(50)                     NOT NULL,                                                               -- --Salario, Hora Extra, Recargo Nocturno, Incapacidad, Prima, o Deducción.
    nom_concepto            VARCHAR(100)                    NOT NULL,                                                               -- Nombre (ej: Salario)
    cant_concepto           DECIMAL(5,2)                    NOT NULL,                                                               -- Cantidad fija o variable (ej: 1 para salario, horas para extras)
    ind_obligatorio         BOOLEAN                         NOT NULL,                                                               -- ¿Es por ley?
    ind_naturaleza          BOOLEAN                         NOT NULL,                                                               -- ¿Suma o Resta?
    ind_periodo             BOOLEAN                         NOT NULL,                                                               -- ¿Frecuencia?
    ind_porc_valor          BOOLEAN                         NOT NULL,                                                               -- ¿Es % o valor fijo?
    val_porcentaje          DECIMAL(5,2)                    NOT NULL,                                                               -- % si aplica
    val_valor               DECIMAL(12,2)                   NOT NULL,                                                               -- Valor si aplica
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_concepto)                                                                                                        -- PK
);
CREATE INDEX idx_nom_concepto ON tab_conceptos_nomina(nom_concepto); -- Búsqueda por nombre concepto

-- 21. TABLA DE CABECERA DE NOMINA
CREATE TABLE IF NOT EXISTS tab_cabecera_nom
(
    id_cabecera_nom         VARCHAR(20)                     NOT NULL,                                                               -- ID volante pago
    id_empleado             VARCHAR(10)                     NOT NULL ,                                                              -- Empleado pagado
    dias_trabajados         INTEGER                         NOT NULL CHECK(dias_trabajados BETWEEN 0 AND 31),                       -- Días del periodo
    periodo_mes             INTEGER                         NOT NULL CHECK(periodo_mes BETWEEN 1 AND 12),                           -- Mes pagado
    periodo_ano             INTEGER                         NOT NULL CHECK(periodo_ano >= 2000),                                    -- Año pagado
    total_devengado         DECIMAL(10,2)                   NOT NULL,                                                               -- Total ingresos
    total_deducido          DECIMAL(10,2)                   NOT NULL,                                                               -- Total descuentos
    neto_pagar              DECIMAL(10,2)                   NOT NULL,                                                               -- Pago final bolsillo
    fecha_pago              DATE                            NOT NULL,                                                               -- Fecha desembolso
    estado_pago             BOOLEAN                         NOT NULL,                                                               -- ¿Pagado/Pendiente?
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_cabecera_nom),                                                                                                   -- PK
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado)                                                           -- Relación empleado
);


-- 20. TABLA DE NOVEDADES
CREATE TABLE IF NOT EXISTS tab_novedades
(
    id_novedad              VARCHAR(20)                     NOT NULL,                                                 -- ID registro novedad
    id_empleado             VARCHAR(10)                     NOT NULL,                                                 -- Empleado afectado
    id_concepto             VARCHAR(10)                     NOT NULL,                                                 -- Tipo de novedad
    id_cabecera_nom         VARCHAR(20)                     NOT NULL,                                                 -- Nómina asociada (si aplica)
    cantidad                DECIMAL(10,2)                   NOT NULL,                                                 -- Horas o montos
    fecha_novedad           DATE                            NOT NULL,                                                 -- Fecha del suceso
    estado                  BOOLEAN                         NOT NULL,                                                 -- ¿Procesada?
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_novedad),                                                                                            -- PK
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),                                              -- Relación empleado
    FOREIGN KEY(id_concepto) REFERENCES tab_conceptos_nomina(id_concepto),                                       -- Relación concepto
    FOREIGN KEY(id_cabecera_nom) REFERENCES tab_cabecera_nom(id_cabecera_nom)                                    -- Relación cabecera nómina
);

-- PROCESOS DISCIPLINARIOS
CREATE TABLE IF NOT EXISTS tab_procesos_disciplinarios (
    id_proceso              VARCHAR(20)                     NOT NULL,
    id_empleado             VARCHAR(10)                     NOT NULL,
    fecha_apertura          DATE                            NOT NULL,
    motivo                  TEXT                            NOT NULL,
    estado_proceso          VARCHAR(20),                                                                            -- 'En descargos', 'Cerrado', 'Anulado'
    sancion_final           VARCHAR(100),                                                                           -- 'Llamado de atención', 'Suspension X días'
    id_novedad              VARCHAR(20),                                                                            -- FK opcional a tab_novedades si hay descuento
    ind_borrado             BOOLEAN                             NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_proceso),
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),
    FOREIGN KEY(id_novedad)  REFERENCES tab_novedades(id_novedad)
);

-- 22. TABLA DE DETALLE DE NOMINA
CREATE TABLE IF NOT EXISTS tab_detalle_nom 
(
    id_detalle_nom          VARCHAR(20)                     NOT NULL,                                    -- ID línea de pago
    id_cabecera_nom         VARCHAR(20)                     NOT NULL,                                    -- ID volante padre
    id_concepto             VARCHAR(10)                     NOT NULL,                                    -- Concepto (ej: Salud)
    base_calculo            DECIMAL(10,2)                   NOT NULL,                                    -- Salario base para el cálculo
    valor_total             DECIMAL(10,2)                   NOT NULL,                                    -- Resultado del cálculo
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_detalle_nom),                                               -- PK
    FOREIGN KEY(id_cabecera_nom) REFERENCES tab_cabecera_nom(id_cabecera_nom), -- Enlace cabecera
    FOREIGN KEY(id_concepto) REFERENCES tab_conceptos_nomina(id_concepto)      -- Enlace concepto
);

-- 23. TABLA DE PROVISIONES Y PRESTACIONES
CREATE TABLE IF NOT EXISTS tab_prov_prest
(
    id_prov_prest           VARCHAR(20)                     NOT NULL,                                    -- ID provisión
    id_cabecera_nom         VARCHAR(20)                     NOT NULL,                                    -- Nómina asociada
    valor_prima             DECIMAL(10,2)                   NOT NULL,                                    -- Ahorro Prima
    valor_cesantias         DECIMAL(10,2)                   NOT NULL,                                    -- Ahorro Cesantías
    valor_intereses         DECIMAL(10,2)                   NOT NULL,                                    -- Intereses sobre Ces.
    valor_vacaciones        DECIMAL(10,2)                   NOT NULL,                                    -- Provisión vacaciones
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_prov_prest),                                                 -- PK
    FOREIGN KEY(id_cabecera_nom) REFERENCES tab_cabecera_nom(id_cabecera_nom) -- Enlace cabecera
);

-- NÓMINA ELECTRÓNICA (DIAN)
CREATE TABLE IF NOT EXISTS tab_nomina_electronica
(
    id_nomina_electronica   VARCHAR(10)                     NOT NULL,
    id_cabecera_nom         VARCHAR(20)                     NOT NULL,
    periodo_mes             INTEGER                         NOT NULL,
    periodo_ano             INTEGER                         NOT NULL,
    archivo_xml             TEXT,                                                      -- XML generado
    track_id                VARCHAR(100),                                              -- ID de envío a DIAN
    estado_envio            VARCHAR(30)                     DEFAULT 'PENDIENTE',  -- PENDIENTE, ENVIADO, ACEPTADO, RECHAZADO
    fecha_envio             DATE,
    respuesta_dian          TEXT,
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_nomina_electronica),
    FOREIGN KEY(id_cabecera_nom) REFERENCES tab_cabecera_nom(id_cabecera_nom)
);

----------------------------------------------
-- MÓDULO DE SEGURIDAD Y SALUD EN EL TRABAJO -
----------------------------------------------

-------------------------------------
-- TABLA TIPO DE CATEGORIAS RIESGO --
-------------------------------------

CREATE TABLE IF NOT EXISTS  tab_categoria_riesgo
(
	id_categoria_riesgo		DECIMAL(1,0)						 NOT NULL,
	tipo_categoria			VARCHAR								 NOT NULL,
	desc_riesgo				VARCHAR								 NOT NULL,
	ind_borrado				BOOLEAN							     NOT NULL 		DEFAULT FALSE,	

	PRIMARY KEY(id_categoria_riesgo)
);

------------------------------
-- TABLA TIPO DE RIESGOS --
------------------------------

CREATE TABLE IF NOT EXISTS 	tab_riesgos
(
	id_riesgo				DECIMAL(1,0)							 NOT NULL,
	nivel_riesgo			DECIMAL(1,0)						 	 NOT NULL,
	id_categoria_riesgo		DECIMAL(1,0)						 	 NOT NULL,
	nom_riesgo				VARCHAR                                  NOT NULL,
	ind_borrado				BOOLEAN									 NOT NULL 		DEFAULT FALSE,	
	PRIMARY KEY(id_riesgo),
	FOREIGN KEY(id_categoria_riesgo) REFERENCES tab_categoria_riesgo(id_categoria_riesgo)
);

------------------------------
-- TABLA TIPO DE ACCIDENTES --
------------------------------

CREATE TABLE IF NOT EXISTS  tab_tipo_acc
(
    id_tipo_acc         	DECIMAL(4,0)		NOT NULL      	CHECK(id_tipo_acc >= 0 AND id_tipo_acc <= 9999),                        --IDENTIFICADOR PARA EL TIPO DE ACCIDENTE
    nom_acc              	VARCHAR     		NOT NULL      	CHECK(LENGTH(nom_acc) >= 0 AND LENGTH(nom_acc) <= 60),                  --NOMBRE DEL ACCIDENTE
    ind_clase_acc        	CHAR(3)     		NOT NULL      	CHECK(ind_clase_acc='L' OR ind_clase_acc='G'OR ind_clase_acc='M'),      --INDICADOR CLASE DE ACCIDENTE (L) LEVE (G) GRAVE (M) MORTAL
    descri_acc           	TEXT        		NOT NULL,                                                                               --DESCRIPCIÓN DEL ACCIDENTE
    obser_tipo_acc         	TEXT,                                                                                                       --OBSERVACIONES DEL ACCIDENTE
    ind_borrado				BOOLEAN				NOT NULL 		DEFAULT FALSE, 						  
	PRIMARY KEY (id_tipo_acc)
);


---------------------------
-- TABLA CATEGORIA DE EPP--
---------------------------

CREATE TABLE IF NOT EXISTS tab_categoria_epp 
(

	id_categoria_epp        DECIMAL(1,0) 		NOT NULL,                                                                               --IDENTIFICADOR DE LA CATEGORIA DE EPP 
	nom_categoria	  		VARCHAR 			NOT NULL        CHECK(LENGTH(nom_categoria) >= 0 AND LENGTH(nom_categoria) <= 60),      --NOMBRE DE LA CATEGORÍA DEL EPP (ej: Cabeza, Ojos, Manos, Vías respiratorias, Caídas, Auditiva, etc.)
	ind_borrado				BOOLEAN				NOT NULL 		DEFAULT FALSE,                                                          --INDICADOR DE BORRADO LÓGICO PARA LA CATEGORÍA DE EPP
	PRIMARY KEY (id_categoria_epp)
);

----------------------
-- TABLA TIPO DE EPP--
----------------------
CREATE TABLE IF NOT EXISTS tab_epp
(
    id_epp             			DECIMAL(4,0)    NOT NULL,
    nom_epp            		 	VARCHAR(100)    NOT NULL CHECK (LENGTH(nom_epp) >= 5), 		                -- NOMBRE DESCRIPTIVO DEL TIPO DE EPP (EJ: 'CASCO DIELÉCTRICO CLASE E', 'ARNÉS DE CUERPO COMPLETO')
    id_categoria_epp            DECIMAL(1,0)    NOT NULL,   									            -- CABEZA, OJOS, MANOS, VÍAS RESPIRATORIAS, CAÍDAS, AUDITIVA, ETC.
	valor_riesgo				DECIMAL(1,0)	NOT NULL, CHECK(valor_riesgo >= 0 AND valor_riesgo <= 4),   -- ID IDENTIFICADOR QUE VIENE DE LA TABLA DE CATEGORIA EPP.
    desc_epp             	TEXT, 														  	                -- DESCRIPCIÓN DETALLADA DEL EPP: MATERIALES, ESPECIFICACIONES TÉCNICAS, USOS RECOMENDADOS
    vida_util_m             	DECIMAL(3,0)    NOT NULL CHECK (vida_util_m > 0), 				            -- VIDA ÚTIL DEL EPP EN MESES (EJ: 12 = 1 AÑO, 36 = 3 AÑOS)
	requiere_certi         		BOOLEAN         NOT NULL 		DEFAULT FALSE, 						        -- INDICA SI EL EPP REQUIERE CERTIFICACIÓN INDIVIDUAL (EJ: ARNESES, EQUIPOS RESPIRATORIOS), TRUE = REQUIERE CERTIFICACIÓN POR ORGANISMO EXTERNO, FALSE = NO REQUIERE
	cant_epp					DECIMAL(2,0)	NOT NULL 		DEFAULT 0,                                  -- CANTIDAD DEL EPP DISPONIBLE PARA PODER ASIGNAR.
    ind_activo              	BOOLEAN         NOT NULL 		DEFAULT TRUE,   						    -- ESTADO DEL REGISTRO: TRUE = ACTIVO PARA NUEVAS ASIGNACIONES, FALSE = DESCONTINUADO
    ind_borrado					BOOLEAN			NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_epp),
	FOREIGN KEY (id_categoria_epp) REFERENCES tab_categoria_epp(id_categoria_epp)
);

-----------------------------
-- TABLA ASIGNACIÓN DE EPP  --
-----------------------------
CREATE TABLE IF NOT EXISTS tab_epp_asignacion
(
    id_asignacion       DECIMAL(10,0)   NOT NULL,                                                   -- Identificador de la asignación del epp para cada empleado.
    id_epp         		DECIMAL(4,0)    NOT NULL,                                                   -- Referencia al tipo de EPP asignado (ej: Casco, Gafas, Arnés)
    id_empleado         VARCHAR(10)     NOT NULL,		                                            -- Empleado que recibe el EPP (puede ser NULL si se asigna a contratista)
    fecha_asignacion    DATE            NOT NULL CHECK (fecha_asignacion <= CURRENT_DATE),          -- Fecha en que se entregó físicamente el EPP al trabajador,  Debe ser menor o igual a la fecha actual (no se puede asignar en futuro)
    fecha_venci         DATE            NOT NULL CHECK (fecha_venci > fecha_asignacion),            -- Fecha hasta la cual el EPP es válido (basado en vida_util_meses + fecha_asignacion)
    ind_estado          CHAR(1)         NOT NULL CHECK (ind_estado IN ('A', 'D', 'V', 'B')),        -- ind para saber el estado del epp asignado. Asignado, devuelto, vencido, dado de baja
    obser_epp_asig      TEXT, 						                                                -- Observaciones generales: condición al entregar, instrucciones especiales, etc.
    ind_borrado			BOOLEAN		    NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_asignacion),
    FOREIGN KEY (id_epp) 			REFERENCES tab_epp(id_epp),
    FOREIGN KEY (id_empleado) 		REFERENCES tab_empleados(id_empleado),
    FOREIGN KEY (id_contratista) 	REFERENCES tab_contratista(id_contratista)
);

-----------------------------
-- TABLA INSPECCIÓN DE EPP  --
-----------------------------

CREATE TABLE IF NOT EXISTS tab_epp_inspeccion
(
    id_inspeccion_epp   DECIMAL(10,0)   NOT NULL,                                                                                   -- Identificador único de cada inspección realizada
    id_asignacion       DECIMAL(10,0)   NOT NULL,                                                                                   -- Referencia a la asignación específica que se está inspeccionando, Permite saber qué trabajador tiene el EPP y desde cuándo
    fecha_inspeccion    DATE            NOT NULL CHECK (fecha_inspeccion <= CURRENT_DATE OR fecha_inspeccion >= CURRENT_DATE),      -- Fecha en que se realizó la inspección física del EPP, No puede ser futura (solo inspecciones pasadas o actuales)
    resultado           CHAR(1)         NOT NULL CHECK (resultado IN ('A', 'N', 'R')),                                              -- A = APROBADO, N = NO APROBADO, R = REQUIERE MANTENIMIENTO.
    proxima_inspeccion  DATE, 					                                                                                    -- Fecha sugerida para la próxima inspección (ej: 3 meses, 6 meses según riesgo)
    obser_inspeccion    TEXT, 					                                                                                    -- Detalles específicos de la inspección: qué se revisó, qué se encontró, Ej: 'Grietas en la suela del casco', 'Arnés con costuras desgastadas'
    id_empleado         VARCHAR(10)     NOT NULL,                                                                                   -- Nombre de la persona que realizó la inspección (SST, supervisor, brigadista),Permite trazabilidad y rendición de cuentas
    ind_borrado		    BOOLEAN		    NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_inspeccion_epp),
    FOREIGN KEY (id_asignacion) REFERENCES tab_epp_asignacion(id_asignacion),
    FOREIGN KEY (id_empleado)   REFERENCES tab_empleados(id_empleado)
);

-------------------------------
--TABLA DEL PROGRAMA DE SALUD--
-------------------------------

CREATE TABLE IF NOT EXISTS tab_programa_salud 
(
    id_programa           INTEGER                                     NOT NULL,
    nom_programa          VARCHAR                                     NOT NULL CHECK (LENGTH(nom_programa) >= 5 AND LENGTH(nom_programa) <= 100),   --EJ: pausas activas, vacunacion 
    tipo_programa         BOOLEAN                                     NOT NULL,                                                                     -- TRUE: PREVENCIÓN , FALSE: PROMOCIÓN
	ind_borrado			  BOOLEAN									  NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY(id_programa)
);


--------------------------------------
--TABLA DE PARTICIPACION DE PROGRAMA--
--------------------------------------

CREATE TABLE IF NOT EXISTS tab_partici_programa 
(
    id_programa          INTEGER                                     NOT NULL,
    id_empleado          DECIMAL(10,0)                               NOT NULL,     
    fecha_partici        DATE                                        NOT NULL CHECK (fecha_partici <= CURRENT_DATE),
    ind_asistencia       BOOLEAN                                     NOT NULL,
	ind_borrado			 BOOLEAN									 NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY(id_programa,id_empleado),
    FOREIGN KEY (id_programa) REFERENCES tab_programa_salud(id_programa),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);


---------------------
--TABLA DE EXAMENES--
---------------------

CREATE TABLE IF NOT EXISTS tab_examenes 
(
  id_examen             DECIMAL(4,0)                                 NOT NULL,
  nom_examen            VARCHAR                                      NOT NULL CHECK (LENGTH(nom_examen) >= 5 AND LENGTH(nom_examen) <= 100),
  obser_examen          TEXT,
  ind_borrado		    BOOLEAN				NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_examen)
);

-----------------------------------------
--TABLA DE ENCABEZADO EXAMEN DE INGRESO--
-----------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_ex_ingreso
(
  id_empleado         DECIMAL(10,0)                                NOT NULL,
  fec_examen          TIMESTAMP WITHOUT TIME ZONE                  NOT NULL CHECK (fec_examen <= CURRENT_TIMESTAMP),
  ind_tipo_examen     CHAR(3)                                      NOT NULL CHECK (ind_tipo_examen IN ('ING', 'PER', 'RET', 'POS')), --INGRESO, PERIODICO, RETIRO, POST-INCAPACIDAD
  ind_aptitud         CHAR(1)                                      NOT NULL CHECK (ind_aptitud IN ('A', 'N', 'R')), -- APTO, NO APTO, APTO CON RESTRICCIONES.
  aclaraciones        VARCHAR(300)                                 NOT NULL,
  ruta_emision        VARCHAR                                      NOT NULL,
  tipo_novedad        DECIMAL(1,0)                                 NOT NULL CHECK (tipo_novedad >= 1 AND tipo_novedad <= 9),
  ind_restri_lab      BOOLEAN                                      NOT NULL,
  medico_examen       TEXT                                         NOT NULL,
  res_examen          VARCHAR                                      NOT NULL, --resolucion del examen
  ind_borrado		  BOOLEAN									   NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_empleado,fec_examen),
  FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);


-----------------------------------------
--TABLA DE DETALLE EXAMEN DE INGRESO   --
-----------------------------------------

CREATE TABLE IF NOT EXISTS tab_det_ex_ingreso
(
 id_empleado        DECIMAL(10,0)                                 NOT NULL,
 id_examen          DECIMAL(4,0)                                  NOT NULL,
 val_resultado      VARCHAR                                       NOT NULL CHECK (LENGTH(val_resultado) >= 1),
 ruta_resultado     VARCHAR                                       NOT NULL,
 ind_borrado		BOOLEAN										  NOT NULL 		DEFAULT FALSE,	
 PRIMARY KEY(id_empleado,id_examen),
 FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado),
 FOREIGN KEY (id_examen)   REFERENCES tab_examenes(id_examen)
);


-------------------------------
--TABLA TIPO DE INCAPACIDADES--
-------------------------------

CREATE TABLE IF NOT EXISTS tab_tipo_incapacidad
(
 id_tipo_inca           DECIMAL(4,0)                               NOT NULL,
 nom_tipo_inca          VARCHAR                                        NOT NULL,
 desc_tipo_inca         TEXT,
 clasi_tipo_incapacidad CHAR(3)                                        NOT NULL CHECK (resultado IN ('IT', 'IPP', 'IPT')), --INCAPACIDAD TEMPORAL, INCAPACIDAD PERMAMENTE PARCIAL , INCAPACIDAD PERMANENTE TOTAL, clasificaciones de INCAPACIDADES
 ind_borrado	        BOOLEAN										 NOT NULL 		DEFAULT FALSE,	
 PRIMARY KEY(id_tipo_inca)
);


---------------------------
-- TABLA DE INCAPACIDADES--
---------------------------

CREATE TABLE IF NOT EXISTS tab_incapacidades
(
 id_incapacidad   DECIMAL(4,0)                                   NOT NULL,
 id_empleado      DECIMAL(10,0)                                  NOT NULL,
 id_tipo_inca     DECIMAL(4,0)                                   NOT NULL,
 id_empresa       DECIMAL(10,0)                                  NOT NULL, ????????????????
 fecha_inicio     DATE                                           NOT NULL   CHECK(fecha_inicio <= CURRENT_DATE),
 fecha_fin        DATE                                           NOT NULL   CHECK (fecha_fin >= fecha_inicio),
 ind_borrado	  BOOLEAN										 NOT NULL   DEFAULT FALSE,	
PRIMARY KEY(id_incapacidad),
FOREIGN KEY (id_empleado)   REFERENCES tab_empleados(id_empleado),
FOREIGN KEY (id_tipo_inca)  REFERENCES tab_tipo_incapacidad(id_tipo_inca),
FOREIGN KEY (id_empresa)    REFERENCES PUBLIC.tab_pmtros_grales(id_empresa)
);

-------------------------------
--TABLA TEMAS DE CAPACITACIÓN--
-------------------------------
CREATE TABLE IF NOT EXISTS tab_temas_cap
(
    id_tema_cap             DECIMAL(4,0)                          NOT NULL         CHECK(id_tema_cap >= 0),                                               --IDENTIFICADOR DEL TEMA DE CAPACITACIÓN
    nom_tema                VARCHAR                               NOT NULL         CHECK(LENGTH(nom_tema) >= 0 AND LENGTH(nom_tema) <= 60),                --NOMBRE TEMA DE LA CAPACITACIÓN
    ind_borrado				BOOLEAN								  NOT NULL 		   DEFAULT FALSE,	
    PRIMARY KEY (id_tema_cap)
);

---------------------
--TABLA DE DOCENTES--
---------------------

CREATE TABLE IF NOT EXISTS tab_docentes
(
  id_docente                DECIMAL(10,0)                         NOT NULL,
  id_empresa                DECIMAL(10,0)                         NOT NULL,
  nom_docente               VARCHAR                               NOT NULL CHECK (LENGTH(nom_docente) >= 2 AND LENGTH(nom_docente) <= 50),
  ape_docente               VARCHAR                               NOT NULL CHECK (LENGTH(ape_docente) >= 2 AND LENGTH(ape_docente) <= 50),
  correo_docente            VARCHAR                               NOT NULL CHECK (correo_docente LIKE '%@%' AND correo_docente LIKE '%.%'),
  TELÉFONO
  ind_borrado				BOOLEAN								  NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_docente),
  FOREIGN KEY (id_empresa) REFERENCES tab_empresas(id_empresa)
);


---------------------------
--TABLA DE CAPACITACIONES--
---------------------------

CREATE TABLE IF NOT EXISTS tab_capacitaciones
(
 id_capacitacion          DECIMAL(4,0)                          NOT NULL,
 id_docente               DECIMAL(10,0)                         NOT NULL,
 id_tema_cap              DECIMAL(4,0)                          NOT NULL,
 fec_capacita             TIMESTAMP WITHOUT TIME ZONE           NOT NULL    CHECK (fec_capacita <= CURRENT_TIMESTAMP),
 val_durac_capaci         DECIMAL(3,0)                          NOT NULL    CHECK (val_durac_capaci > 0),
 mod_capaci               CHAR(1)                               NOT NULL    CHECK (modalidad IN ('P', 'V', 'M')), --PRESENCIAL, VIRTUAL, MIXTA
 ind_borrado			  BOOLEAN								NOT NULL    DEFAULT FALSE,	
PRIMARY KEY(id_capacitacion),
FOREIGN KEY (id_docente) REFERENCES tab_docentes(id_docente),
FOREIGN KEY (id_tema_cap) REFERENCES tab_temas_cap(id_tema_cap)
);

-----------------------------------
--TABLA ASISTENCIA A CAPACITACIÓN--
-----------------------------------

CREATE TABLE IF NOT EXISTS tab_asis_cap
(
    id_capacitacion         DECIMAL(4,0)                          NOT NULL,                                      --IDENTIFICADOR DE LA ASISTENCIA A LA CAPACITACIÓN
    id_empleado             DECIMAL(10,0)                         NOT NULL,                                               --IDENTIFICADOR DEL EMPLEADO
    fec_asis                DATE                                  NOT NULL         CHECK(fec_asis <= CURRENT_DATE),                                  --FECHA DE ASISTENCIA A LA CAPACITACIÓN
    ind_asistio             BOOLEAN                               NOT NULL,
    ind_borrado				BOOLEAN								  NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_capacitacion, id_empleado),
    FOREIGN KEY (id_capacitacion) REFERENCES tab_capacitaciones(id_capacitacion),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);

---------------------
--TABLA  DE BRIGADA--
---------------------
CREATE TABLE IF NOT EXISTS tab_brigada
(
  id_brigada               DECIMAL(4,0)                          NOT NULL,
  nom_brigada              VARCHAR                               NOT NULL  CHECK (LENGTH(nom_brigada) >= 5),
  ind_borrado			   BOOLEAN								 NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_brigada)
);

-------------------------
--TABLA  DE BRIGADISTAS--
-------------------------
CREATE TABLE IF NOT EXISTS tab_brigadistas
(
  id_brigadista             VARCHAR(10)                        NOT NULL,
  id_brigada                DECIMAL(4,0)                         NOT NULL,
  id_empleado               DECIMAL(10,0)                        NOT NULL         CHECK(id_empleado >= 0),
  id_contratista            DECIMAL(10,0)                        NOT NULL         CHECK(id_contratista >=0),
  rol_brigadista            CHAR(1)                              NOT NULL         CHECK(rol IN ('L', 'E')), --LIDERAZGO Y OPERACIÓN, EQUIPOS OPERATIVOS ESPECIALIZADOS.
  ind_borrado			    BOOLEAN							   NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_brigadista),
  FOREIGN KEY (id_brigada) REFERENCES tab_brigada(id_brigada),
  FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);
                           
------------------------
--TABLA  DE EMERGENCIA--
------------------------                        
CREATE TABLE IF NOT EXISTS tab_emergencia
(
  id_emergencia        DECIMAL(4,0)                          NOT NULL,
  fecha_emer           TIMESTAMP WITHOUT TIME ZONE           NOT NULL  CHECK (fecha_emer <= CURRENT_TIMESTAMP),
  tipo_emer            CHAR(1)                               NOT NULL  CHECK (tipo_emer IN ('I', 'S', 'M', 'O')), --INCENDIO, SISMO, MÉDICA, OTRO
  desc_emer            TEXT                                  NOT NULL,
  ind_borrado		   BOOLEAN								 NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_emergencia),
  FOREIGN KEY (id_brigada) REFERENCES tab_brigada(id_brigada)
);

-----------------
--TABLA COPASST--
-----------------

CREATE TABLE IF NOT EXISTS tab_copasst
(
    id_copasst             DECIMAL(4,0)             NOT NULL                        CHECK(id_copasst >= 0),                     --IDENTIFICADOR DEL COPASST
    periodo_inicio         DATE                                                     CHECK(periodo_inicio <= CURRENT_DATE),      --FECHA DE INICIO DEL COPASST
    periodo_fin            DATE                                                     CHECK(periodo_fin <= CURRENT_DATE),         --FECHA DE FIN DEL COPASST
    num_act_consti         DECIMAL(4,0)                                             CHECK(num_act_consti >= 0),                 --NUMERO ACTA DE CONSTITUCION DEL COPASST
    ind_borrado			   BOOLEAN					NOT NULL 						DEFAULT FALSE,	
    PRIMARY KEY (id_copasst)
);

-------------------------
--TABLA MIEMBRO COPASST--
-------------------------

CREATE TABLE IF NOT EXISTS tab_miem_copasst
(
    id_copasst              DECIMAL(4,0)            NOT NULL                         CHECK(id_copasst >= 0),                    --IDENTIFICADOR DEL COPASST
    id_empleado             DECIMAL(10,0)           NOT NULL                         CHECK(id_empleado >= 0),                   
    ind_rol                 BOOLEAN                 NOT NULL,
    ind_tipo                BOOLEAN                 NOT NULL,
    ind_borrado				BOOLEAN				    NOT NULL 						 DEFAULT FALSE,	
    PRIMARY KEY (id_miembro),               
    FOREIGN KEY (id_copasst) REFERENCES tab_copasst(id_copasst),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);

-------------------------
--TABLA REUNIÓN COPASST--
-------------------------
CREATE TABLE IF NOT EXISTS tab_reu_copasst
(
    id_reunion              DECIMAL(4,0)                        NOT NULL                           CHECK(id_reunion >= 0),
    id_copasst              DECIMAL(4,0)                        NOT NULL                           CHECK(id_copasst >= 0),
    fec_reu                 TIMESTAMP WITHOUT TIME ZONE         NOT NULL                           CHECK(fec_reu <= CURRENT_DATE),
    temas_reu               TEXT                                NOT NULL,
    acuer_reu_copasst       TEXT                                NOT NULL,
    num_act_reu             DECIMAL(4,0)                        NOT NULL,
    ind_borrado				BOOLEAN								NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_reunion),
    FOREIGN KEY (id_copasst) REFERENCES tab_copasst(id_copasst)
);

----------------------------
--TABLA ASISTENCIA COPASST-- (CORREGIR EMPLEADO)
----------------------------
CREATE TABLE IF NOT EXISTS tab_asist_copasst
(
  id_asistencia           DECIMAL(10,0)                         NOT NULL,
  id_reunion              DECIMAL(4,0)                          NOT NULL,
  id_miembro              DECIMAL(10,0)                         NOT NULL,
  ind_asistio             BOOLEAN                               NOT NULL,
  ind_borrado			  BOOLEAN								NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_asistencia),
  FOREIGN KEY (id_reunion) REFERENCES tab_reu_copasst(id_reunion),
  FOREIGN KEY (id_miembro) REFERENCES tab_miem_copasst(id_miembro)
);

-----------------------
--TABLA DE INSPECCION--
-----------------------
CREATE TABLE IF NOT EXISTS tab_inspeccion
(
  id_inspeccion          DECIMAL(4,0)                         NOT NULL,
  id_contratista         DECIMAL(10,0)                        NOT NULL, HACE LA INSPECCIÓN
  fec_inspeccion         TIMESTAMP WITHOUT TIME ZONE          NOT NULL,
  val_resultado          BOOLEAN                              NOT NULL,
  plan_accion            TEXT                                 NOT NULL,
  ind_borrado			 BOOLEAN							  NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_inspeccion),
  FOREIGN KEY (id_contratista) REFERENCES tab_contratista(id_contratista)
);

---------------------------
--TABLA DE AUDITORIAS SST--
---------------------------
CREATE TABLE IF NOT EXISTS tab_auditorias_sst
( 
  id_auditorias         DECIMAL(4,0)                          NOT NULL,
  id_empleado           DECIMAL(10,0)                         NOT NULL,
  id_area               DECIMAL(4,0)                          NOT NULL,
  fecha_audi            TIMESTAMP WITHOUT TIME ZONE           NOT NULL,
  val_hallazgos         VARCHAR                               NOT NULL,
  acciones_correc       TEXT                                  NOT NULL,
  ind_conformidad       BOOLEAN                               NOT NULL,
  ind_borrado			BOOLEAN								  NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_auditorias),
  FOREIGN KEY (id_empleado) 	REFERENCES tab_empleados(id_empleado),
  FOREIGN KEY (id_area) 		REFERENCES PUBLIC.tab_areas(id_area)
);

--------------------
--TABLA ACCIDENTES--
--------------------
CREATE TABLE IF NOT EXISTS tab_accidentes
(
	 id_accidente     	DECIMAL(4,0)                           NOT NULL,
	 id_empleado      	DECIMAL(10,0)                          NOT NULL,
	 id_tipo_acc      	DECIMAL(4,0)                           NOT NULL,
	 id_contratista   	DECIMAL(10,0)                          NOT NULL,
	 causa_acc        	VARCHAR                                NOT NULL,
	 obser_acc        	TEXT                                   NOT NULL,  --OBSERVACIONES DEL ACCIDENTE
	 fec_acc          	TIMESTAMP WITHOUT TIME ZONE            NOT NULL        CHECK(fec_acc <= CURRENT_DATE),                                                  --FECHA EN QUE OCURRIÓ EL ACCIDENTE
	 ind_borrado	  	BOOLEAN								   NOT NULL 		DEFAULT FALSE,
	 
 PRIMARY KEY(id_accidente),
 FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado),
 FOREIGN KEY (id_tipo_acc) REFERENCES tab_tipo_acc(id_tipo_acc),
 FOREIGN KEY (id_contratista) REFERENCES tab_contratista(id_contratista)
);

-----------------------------------
--MÓDULO DE MARKETING Y COMERCIAL--
-----------------------------------


CREATE TABLE IF NOT EXISTS tab_pmtros_marcom
(
    id_empresa                  DECIMAL(10,0)   NOT NULL CHECK(id_empresa >= 10000000 AND id_empresa <= 9999999999),
    val_dias_sin_interaccion    DECIMAL(3,0)    NOT NULL CHECK(val_dias_sin_interaccion >= 1 AND val_dias_sin_interaccion <= 365)          DEFAULT 15,      --Valor de dias sin interactuar el lead
    val_dias_expiracion_lead    DECIMAL(3,0)    NOT NULL CHECK(val_dias_expiracion_lead >= 1 AND val_dias_expiracion_lead <= 365)           DEFAULT 90,     --Valor de dias a los cuales expira un lead
    val_score_min_tibio         DECIMAL(3,0)    NOT NULL CHECK(val_score_min_tibio >= 1 AND val_score_min_tibio <= 99)                     DEFAULT 40,      --Score minimo para ser tibio   
    val_score_min_caliente      DECIMAL(3,0)    NOT NULL CHECK(val_score_min_caliente >= 2 AND val_score_min_caliente <= 100)              DEFAULT 70,      --Score minimo para ser Caliente
    val_max_contactos_adic      DECIMAL(2,0)    NOT NULL CHECK(val_max_contactos_adic >= 1 AND val_max_contactos_adic <= 20)               DEFAULT 2,       --Valor de contactos adicionales maximos
    val_presupuesto_defecto     DECIMAL(12,0)   NOT NULL CHECK(val_presupuesto_defecto >= 0)                                               DEFAULT 0,       --Valor de presupuesto por defecto de campañas
    val_meta_apertura_email     DECIMAL(3,0)    NOT NULL CHECK(val_meta_apertura_email >= 1 AND val_meta_apertura_email <= 100)            DEFAULT 20,      --Valor de las metas de apertura por email
    val_penalizacion_inactividad DECIMAL(2,0)   NOT NULL CHECK(val_penalizacion_inactividad >= 1 AND val_penalizacion_inactividad <= 20)   DEFAULT 5,       --Valores de penalizacion por inactividad, si el lead ni interactua su puntaje cambia
    val_puntos_interaccion      DECIMAL(2,0)    NOT NULL CHECK(val_puntos_interaccion >= 1 AND val_puntos_interaccion <= 20)               DEFAULT 5,       -- Valor de puntor por interacion
    val_puntos_apertura_email   DECIMAL(2,0)    NOT NULL CHECK(val_puntos_apertura_email >= 1 AND val_puntos_apertura_email <= 20)         DEFAULT 3,       -- Valor de puntos por aperturas de emails
    val_puntos_clic_email       DECIMAL(2,0)    NOT NULL CHECK(val_puntos_clic_email >= 1 AND val_puntos_clic_email <= 20)                 DEFAULT 5,       -- Valor de puntos por clics
    val_max_pts_segmentacion    DECIMAL(2,0)    NOT NULL CHECK(val_max_pts_segmentacion >= 1 AND val_max_pts_segmentacion <= 100)          DEFAULT 30,      -- valores maximos de puntos para  segmentacion
    val_max_pts_interacciones   DECIMAL(2,0)    NOT NULL CHECK(val_max_pts_interacciones >= 1 AND val_max_pts_interacciones <= 100)        DEFAULT 20,      -- Valores maximos de puntos por interacciones
    val_max_pts_aperturas       DECIMAL(2,0)    NOT NULL CHECK(val_max_pts_aperturas >= 1 AND val_max_pts_aperturas <= 100)                DEFAULT 15,      -- Valores maximos de puntos por aperturas     
    val_max_pts_clics           DECIMAL(2,0)    NOT NULL CHECK(val_max_pts_clics >= 1 AND val_max_pts_clics <= 100)                        DEFAULT 15,      -- Valores maximos de puntos por clics 
    val_max_pts_compra          DECIMAL(2,0)    NOT NULL CHECK(val_max_pts_compra >= 1 AND val_max_pts_compra <= 100)                      DEFAULT 20,      -- Valores maximos de puntos por compras 
    PRIMARY KEY(id_empresa),
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),

    -- Temperatura coherente
    CONSTRAINT chk_score_coherente CHECK(val_score_min_caliente > val_score_min_tibio),

    -- Techos suman exactamente 100
    CONSTRAINT chk_techos_score CHECK(
        val_max_pts_segmentacion +
        val_max_pts_interacciones +
        val_max_pts_aperturas +
        val_max_pts_clics +
        val_max_pts_compra = 100
    )
);

-- ------------------------------------------------
-- TABLA DE ETAPAS DEL FUNNEL DE VENTAS
-- Define las etapas por las que atraviesa un lead
-- desde el primer contacto hasta el cierre.
-- Configurable para adaptarse al negocio.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_etapas_funnel
(
    id_etapa                DECIMAL(2,0)    NOT NULL CHECK(id_etapa > 0 AND id_etapa <= 99),        --identificador de la tabla etapas funnel
    nom_etapa               VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_etapa)) >= 3),           -- Ampliado: 30 era justo para etapas personalizadas
    des_etapa               VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_etapa)) >= 10),          -- Tipado: VARCHAR sin límite → VARCHAR(250)
    ind_etapa_final         BOOLEAN         NOT NULL,                                               --
    ind_estado              BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- Indicador de estado que 
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                                 --
    ind_es_perdido          BOOLEAN         NOT NULL DEFAULT FALSE,                                 --ind
    PRIMARY KEY(id_etapa)
);

INSERT INTO tab_etapas_funnel (id_etapa, nom_etapa, des_etapa, ind_etapa_final, ind_estado, ind_borrado)VALUES
    (1, 'Prospecto',        'Lead identificado pero aún sin contacto',            FALSE, TRUE, FALSE),
    (2, 'Contactado',       'Se realizó el primer contacto con el lead',          FALSE, TRUE, FALSE),
    (3, 'Interesado',       'El lead mostró interés en el producto o servicio',   FALSE, TRUE, FALSE),
    (4, 'Propuesta enviada','Se envió una propuesta comercial formal',            FALSE, TRUE, FALSE),
    (5, 'Negociación',      'En proceso de negociación de condiciones',           FALSE, TRUE, FALSE),
    (6, 'Ganado',           'Lead convertido en cliente, primera factura emitida',TRUE,  TRUE, FALSE),
    (7, 'Perdido',          'Lead que no convirtió, negocio no cerrado',          TRUE,  TRUE, FALSE);

-- ------------------------------------------------
-- TABLA DE CANALES DE DIFUSIÓN DE CAMPAÑAS
-- Define los medios digitales por los que se puede
-- lanzar y difundir una campaña de marketing.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_canales
(
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),             -- Identificador unico de canal
    nom_canal           VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_canal)) >= 3),                -- Nombre de canal 
    des_canal           VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_canal)) >= 10),               -- Descripcion de canal, para ddescripciones cortas
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                       -- Indicador de estado de canales para saber si esta activo o inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                      -- Indicador de borrado
    PRIMARY KEY(id_canal)
);

INSERT INTO tab_canales (id_canal, nom_canal, des_canal, ind_estado, ind_borrado) VALUES
    (1, 'Email',     'Campañas enviadas por correo electrónico masivo',         TRUE, FALSE),
    (2, 'Instagram', 'Publicaciones y anuncios en Instagram',                   TRUE, FALSE),
    (3, 'Facebook',  'Publicaciones y anuncios en Facebook',                    TRUE, FALSE),
    (4, 'LinkedIn',  'Publicaciones y anuncios en LinkedIn',                    TRUE, FALSE),
    (5, 'WhatsApp',  'Mensajes promocionales masivos por WhatsApp Business',    TRUE, FALSE);
-- ------------------------------------------------
-- TABLA DE CRITERIOS DE SEGMENTACIÓN
-- Define los aspectos estratégicos por los que se 
-- clasifican leads y clientes. Solo modificable 
-- por el rol administrador via módulo SECURE.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_criterios_segmentacion
(
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),           -- Identificador unico de criterio
    nom_criterio    VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_criterio)) >= 3),                 -- Nombre de criterio (minimo 3 digitos)
    des_criterio    VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_criterio)) >= 10),                -- Descripcion de criterios de segmentacion 
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                           -- Indicador de estados de los criterios de segmentacion
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,                                          -- Indicador de borrado
    PRIMARY KEY(id_criterio)
);

INSERT INTO tab_criterios_segmentacion (id_criterio, nom_criterio, des_criterio, ind_estado, ind_borrado) VALUES
    (1, 'Origen',            'Define de dónde proviene el lead o cliente',                          TRUE, FALSE),
    (2, 'Temperatura',       'Indica qué tan cerca está el lead de tomar una decisión de compra',   TRUE, FALSE),
    (3, 'Tamaño de empresa', 'Clasifica según el tamaño de la empresa del lead o cliente',          TRUE, FALSE),
    (4, 'Otro',              'Criterio adicional configurable según las necesidades del negocio',   TRUE, FALSE); 

-- ------------------------------------------------
-- TABLA DE VALORES DE SEGMENTACIÓN
-- Define las opciones específicas de cada criterio
-- e incluye un peso para calcular Lead Scoring.
-- Solo modificable por el rol administrador.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_valores_segmentacion
(
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),             -- Identificador de criterio pk
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),                   -- Identificador de valor pk,fk
    nom_valor       VARCHAR(60)     NOT NULL CHECK(LENGTH(TRIM(nom_valor)) >= 3),                      -- Nombre del valor de segmentacion
    des_valor       VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_valor)) >= 10),                     -- Descripcion del valor de segmentacion      
    val_peso        DECIMAL(4,2)    NOT NULL CHECK(val_peso >= 0.00 AND val_peso <= 10.00),            -- valor peso de criterio
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                             -- Indicador de estado para valores de segmentacion
    PRIMARY KEY(id_criterio, id_valor),
    FOREIGN KEY(id_criterio) REFERENCES tab_criterios_segmentacion(id_criterio),
    UNIQUE(id_criterio, nom_valor)
);

INSERT INTO tab_valores_segmentacion (id_criterio, id_valor, nom_valor, des_valor, val_peso, ind_estado) VALUES
    -- Origen (id_criterio = 1)
    (1, 1, 'Redes Sociales',    'Lead captado por redes sociales',              2.00, TRUE),
    (1, 2, 'Referido',          'Lead recomendado por otro cliente',            3.00, TRUE),
    (1, 3, 'Búsqueda Orgánica', 'Lead captado por búsqueda en internet',        1.00, TRUE),
    (1, 4, 'Email',             'Lead captado por campaña de email',            2.00, TRUE),
    -- Temperatura (id_criterio = 2)
    (2, 1, 'Frío',              'Sin interés claro aún',                        1.00, TRUE),
    (2, 2, 'Tibio',             'Mostró algún interés pero no decide',          2.00, TRUE),
    (2, 3, 'Caliente',          'Listo para tomar una decisión de compra',      3.00, TRUE),
    -- Tamaño de empresa (id_criterio = 3)
    (3, 1, 'Pequeña',           'Empresa con menos de 50 empleados',            1.00, TRUE),
    (3, 2, 'Mediana',           'Empresa entre 50 y 200 empleados',             2.00, TRUE),
    (3, 3, 'Grande',            'Empresa con más de 200 empleados',             3.00, TRUE);
-- ------------------------------------------------
-- TABLA DE CAMPOS DE SEGMENTACIÓN
-- Catálogo de campos del sistema que pueden ser
-- evaluados en las reglas de segmentación.
-- Evita el uso de strings sueltos en las condiciones
-- referenciando cada campo por su ID numérico.
-- Incluye la tabla origen del campo para que PHP
-- y el agente de IA sepan dónde consultarlo.
-- Solo modificable por el rol administrador.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_campos_segmentacion
(
    id_campo    DECIMAL(3,0)    NOT NULL CHECK(id_campo > 0 AND id_campo <= 999),
    nom_campo   VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_campo)) >= 3),
    des_campo   VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_campo)) >= 10),    -- Tipado: TEXT → VARCHAR(250) consistencia con esquema
    nom_tabla   VARCHAR(80)     NOT NULL CHECK(LENGTH(TRIM(nom_tabla)) >= 3),     -- Ampliado: 60 → 80 para acomodar esquema + tabla (ej: public.tab_terceros)
    tipo_dato   VARCHAR(10)     NOT NULL CHECK(tipo_dato IN ('NUMERICO', 'TEXTO', 'FECHA')),
    ind_estado  BOOLEAN         NOT NULL DEFAULT TRUE,                             -- Añadido NOT NULL
    PRIMARY KEY(id_campo),
    UNIQUE(nom_campo)
);

INSERT INTO tab_campos_segmentacion 0(id_campo, nom_campo, des_campo, nom_tabla, tipo_dato, ind_estado) VALUES
    (1, 'id_canal',         'Canal por el que llegó el lead o cliente',          'tab_leads',   'NUMERICO', TRUE),  -- Corregido: esquema explícito
    (2, 'id_etapa',         'Etapa del pipeline en la que está el lead',         'tab_leads',   'NUMERICO', TRUE),  -- Corregido: esquema explícito
    (3, 'ind_tipo_tercero', 'Indica si el tercero es persona jurídica o natural','public.tab_terceros','NUMERICO', TRUE);  -- Corregido: esquema explícito
-- ------------------------------------------------
-- TABLA DE REGLAS DE SEGMENTACIÓN AUTOMÁTICA
-- Define las reglas que disparan la asignación
-- automática de valores de segmentación a leads y
-- clientes. Cada regla apunta a un valor de
-- segmentación y agrupa una o más condiciones
-- definidas en tab_condiciones_regla.
-- La lógica AND/OR determina cómo se combinan
-- dichas condiciones para que la regla se cumpla.
-- Solo modificable por el rol administrador.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_reglas_segmentacion
(
    id_regla        DECIMAL(3,0)    NOT NULL CHECK(id_regla > 0 AND id_regla <= 999),
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),  
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),        
    tipo_logica     VARCHAR(3)      NOT NULL DEFAULT 'AND' CHECK(tipo_logica IN ('AND', 'OR')),
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                   -- Añadido NOT NULL
    PRIMARY KEY(id_regla),
    FOREIGN KEY(id_criterio, id_valor) REFERENCES tab_valores_segmentacion(id_criterio, id_valor),              

INSERT INTO tab_reglas_segmentacion
    (id_regla, id_criterio, id_valor, tipo_logica, ind_estado)
VALUES
    (1, 1, 1, 'OR',  TRUE),  -- Criterio Origen,       valor Redes Sociales → LinkedIn, Instagram, Facebook
    (2, 1, 4, 'AND', TRUE),  -- Criterio Origen,       valor Email
    (3, 2, 3, 'AND', TRUE),  -- Criterio Temperatura,  valor Caliente → etapa Negociación
    (4, 2, 2, 'AND', TRUE);  -- Criterio Temperatura,  valor Tibio    → etapa Contactado

-- ------------------------------------------------
-- TABLA DE CONDICIONES DE REGLA
-- Define las condiciones concretas que deben
-- evaluarse para que una regla de segmentación
-- se cumpla. Cada condición referencia un campo
-- del catálogo, un operador de comparación y
-- el valor a comparar según el tipo de dato.
-- Una regla puede tener múltiples condiciones
-- combinadas con AND/OR según tab_reglas_segmentacion.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_condiciones_regla
(
    id_regla        DECIMAL(3,0)    NOT NULL CHECK(id_regla > 0 AND id_regla <= 999),
    id_condicion    DECIMAL(3,0)    NOT NULL CHECK(id_condicion > 0 AND id_condicion <= 999), --→ DECIMAL(3,0) reinicia por regla, 999 condiciones por regla es suficiente
    id_campo        DECIMAL(3,0)    NOT NULL CHECK(id_campo > 0 AND id_campo <= 999),
    operador        VARCHAR(3)      NOT NULL CHECK(operador IN ('=', '>', '<', '>=', '<=')),  --→ VARCHAR(3) margen defensivo para operadores de 2 caracteres
    val_condicion   TEXT            NOT NULL CHECK(LENGTH(TRIM(val_condicion)) > 0),

    PRIMARY KEY(id_regla, id_condicion),
    FOREIGN KEY(id_regla)  REFERENCES tab_reglas_segmentacion(id_regla),
    FOREIGN KEY(id_campo)  REFERENCES tab_campos_segmentacion(id_campo)
);

INSERT INTO tab_condiciones_regla (id_regla, id_condicion, id_campo, operador, val_condicion) VALUES
    Regla 1 (OR → Redes Sociales): LinkedIn, Instagram o Facebook
    (1, 1, 1, '=', '4'),  -- id_canal = LinkedIn
    (1, 2, 1, '=', '2'),  -- id_canal = Instagram
    (1, 3, 1, '=', '3'),  -- id_canal = Facebook
    -- Regla 2 (AND → Email)
    (2, 1, 1, '=', '1'),  -- id_canal = Email
    -- Regla 3 (AND → Caliente)
    (3, 1, 2, '=', '5'),  -- id_etapa = Negociación
    -- Regla 4 (AND → Tibio)
    (4, 1, 2, '=', '2');  -- id_etapa = Contactado
-- ============================================================
-- TABLA DE SEGMENTACIÓN DE TERCEROS
-- Conecta leads y clientes con sus valores de segmentación.
-- Una sola tabla para ambos usando ind_tipo como diferenciador.
-- PHP inserta aquí después de evaluar tab_reglas_segmentacion
-- y luego actualiza val_score en tab_leads.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_segmentacion_tercero
(
    id_tercero      VARCHAR(10)   NOT NULL CHECK(id_tercero >= 10000000 AND id_tercero <= 9999999999),      --
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),                  -- Añadido: necesario para FK compuesta y garantizar un valor por criterio
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),                        -- Corregido: DECIMAL(3,0) → DECIMAL(2,0) consistente con PK compuesta
    fec_asignacion  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,                                     -- Añadido NOT NULL
    
    PRIMARY KEY(id_tercero, id_criterio),                                                   
    FOREIGN KEY(id_tercero)             REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_criterio, id_valor)  REFERENCES tab_valores_segmentacion(id_criterio, id_valor) -- Corregido: FK simple → FK compuesta
);

-- ------------------------------------------------
-- TABLA DE TIPOS DE CAMPAÑA
-- Define el propósito y objetivo de cada campaña,
-- permitiendo establecer esquemas de medición
-- adecuados según su naturaleza.
-- Solo modificable por el rol administrador.
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_campana
(
    id_tipo_campana     DECIMAL(2,0)    NOT NULL CHECK(id_tipo_campana > 0 AND id_tipo_campana <= 99),      --
    nom_tipo_campana    VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_tipo_campana)) >= 3),                -- Ampliado: 40 → 50. Añadido CHECK faltante
    des_tipo_campana    VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_tipo_campana)) >= 10),               -- Tipado: TEXT → VARCHAR(250). Añadido CHECK faltante
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                              -- Añadido NOT NULL y DEFAULT TRUE
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                             -- Añadido NOT NULL
    PRIMARY KEY(id_tipo_campana)
);

INSERT INTO tab_tipo_campana (id_tipo_campana, nom_tipo_campana, des_tipo_campana, ind_estado, ind_borrado)VALUES
    (1, 'Venta de Producto',   'Campaña orientada a generar ventas directas de productos o servicios',          TRUE, FALSE),
    (2, 'Generación de Marca', 'Campaña orientada al reconocimiento y posicionamiento de la marca',             TRUE, FALSE),
    (3, 'Captación de Leads',  'Campaña orientada a conseguir nuevos prospectos interesados',                   TRUE, FALSE),
    (4, 'Fidelización',        'Campaña orientada a clientes existentes para generar recompra o lealtad',       TRUE, FALSE),
    (5, 'Lanzamiento',         'Campaña orientada a introducir un nuevo producto o servicio al mercado',        TRUE, FALSE);

-- ============================================================
-- TABLA DE CAMPAÑAS
-- Núcleo del módulo. Cada fila es una campaña digital.
-- La asignación de vendedores ocurre en tab_lead_camp.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_campanas
(
    id_campana      DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_tipo_campana DECIMAL(2,0)    NOT NULL CHECK(id_tipo_campana > 0 AND id_tipo_campana <= 99),
    nom_campana     VARCHAR(120)    NOT NULL CHECK(LENGTH(TRIM(nom_campana)) >= 3),
    des_objetivo    VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_objetivo)) >= 10),
    fec_inicio      DATE            NOT NULL,
    fec_fin         DATE            NOT NULL,
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_campana),
    FOREIGN KEY(id_tipo_campana) REFERENCES tab_tipo_campana(id_tipo_campana),
    CONSTRAINT chk_fechas_campana CHECK(fec_fin > fec_inicio)  -- Corregido: >= → > mínimo 1 día de duración
);

-- ============================================================
-- TABLA CAMPAÑA CANAL
-- Relación muchos a muchos entre campañas y canales.
-- Define por qué canales se difunde cada campaña.
-- v2.0: agregar presupuesto por canal.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_campana_canal
(
    id_campana      DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_canal        DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    PRIMARY KEY(id_campana, id_canal),
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_canal)   REFERENCES tab_canales(id_canal)
);

-- ============================================================
-- TABLA DE MOTIVOS DE PÉRDIDA
-- Registra las razones por las que un lead no convirtió.
-- Da inteligencia al negocio para mejorar la estrategia comercial.
-- Debe ir antes de tab_leads en el script final.
-- ============================================================
-- Primero actualizamos tab_motivos_perdida
CREATE TABLE IF NOT EXISTS tab_motivos_perdida
(
    id_motivo_perdida   DECIMAL(2,0)    NOT NULL CHECK(id_motivo_perdida >= 0 AND id_motivo_perdida <= 99), -- Corregido: >= 0 para permitir el registro especial
    nom_motivo          VARCHAR(60)     NOT NULL CHECK(LENGTH(TRIM(nom_motivo)) >= 3),
    des_motivo          VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_motivo)) >= 10),
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_motivo_perdida)
);

INSERT INTO tab_motivos_perdida (id_motivo_perdida, nom_motivo, des_motivo, ind_estado, ind_borrado) VALUES
    (0, 'Sin pérdida',              'Lead activo en el funnel, sin motivo de pérdida asignado',         TRUE, TRUE),  -- Registro especial: ind_borrado=TRUE para que nunca aparezca en opciones del formulario
    (1, 'Precio muy alto',          'El lead consideró que el precio no se ajustaba a su presupuesto',  TRUE, FALSE),
    (2, 'Eligió la competencia',    'El lead decidió contratar con un competidor',                      TRUE, FALSE),
    (3, 'Sin presupuesto',          'El lead no contaba con presupuesto disponible en ese momento',     TRUE, FALSE),
    (4, 'No era el momento',        'El lead mostró interés pero no estaba listo para decidir',         TRUE, FALSE),
    (5, 'Sin respuesta',            'El lead no respondió tras varios intentos de contacto',            TRUE, FALSE),
    (6, 'Producto no se ajusta',    'El producto o servicio no cubría la necesidad del lead',           TRUE, FALSE);

-- ============================================================
-- TABLA DE LEADS
-- Extiende tab_terceros del public. Todo lead debe estar
-- primero registrado en tab_terceros con id_cat_tercero = 4.
-- El score lo calcula y actualiza PHP sumando los pesos
-- de tab_valores_segmentacion. El motivo de pérdida es NULL
-- mientras el lead esté activo en el funnel.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_leads
(
    id_lead             DECIMAL(10,0)   NOT NULL CHECK(id_lead >= 10000000 AND id_lead <= 9999999999),
    fec_registro        DATE            NOT NULL DEFAULT CURRENT_DATE,
    val_score           DECIMAL(3,0)    NOT NULL CHECK(val_score >= 0 AND val_score <= 100) DEFAULT 0,
    id_etapa            DECIMAL(2,0)    NOT NULL CHECK(id_etapa > 0 AND id_etapa <= 99),
    id_motivo_perdida   DECIMAL(2,0)    NOT NULL CHECK(id_motivo_perdida >= 0 AND id_motivo_perdida <= 99) DEFAULT 0, -- Corregido: NULL → NOT NULL DEFAULT 0, usa registro especial de tab_motivos_perdida
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_lead),
    FOREIGN KEY(id_lead)           REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_etapa)          REFERENCES tab_etapas_funnel(id_etapa),
    FOREIGN KEY(id_motivo_perdida) REFERENCES tab_motivos_perdida(id_motivo_perdida)
    -- Coherencia entre id_etapa e id_motivo_perdida garantizada por:
    -- trg_validar_motivo_perdida usando ind_es_perdido de tab_etapas_funnel
);
-- ============================================================
-- TABLA LEAD CAMPAÑA
-- Relación muchos a muchos entre leads y campañas.
-- Guarda cómo y cuándo entró ese lead a esa campaña.
-- El vendedor no va aquí — se asigna en tab_interacciones_lead.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_lead_camp
(
    id_lead             DECIMAL(10,0)   NOT NULL CHECK(id_lead >= 10000000 AND id_lead <= 9999999999),
    id_campana          DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    fec_asignacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                              -- Añadido NOT NULL
    id_etapa_entrada    DECIMAL(2,0)    NOT NULL CHECK(id_etapa_entrada > 0 AND id_etapa_entrada <= 99), -- Renombrado: id_etapa → id_etapa_entrada, valor histórico que nunca cambia
    ind_origen          DECIMAL(1,0)    NOT NULL CHECK(ind_origen IN (1, 2, 3)),                    -- Corregido: CHECK >= 1 AND <= 3 → IN (1,2,3) más explícito -- 1=Manual / 2=Automático / 3=Importado
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                      -- Añadido NOT NULL y DEFAULT TRUE
    PRIMARY KEY(id_lead, id_campana),
    FOREIGN KEY(id_lead)            REFERENCES tab_leads(id_lead),
    FOREIGN KEY(id_campana)         REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_etapa_entrada)   REFERENCES tab_etapas_funnel(id_etapa)                  -- FK hacia etapas para integridad referencial
);
-- ============================================================
-- TABLA DE INTERACCIONES DEL LEAD
-- Historial completo de cada contacto vendedor-lead.
-- Cada llamada, email, WhatsApp, visita o reunión queda aquí.
-- PHP usa fec_proxima_accion para enviar recordatorios al vendedor.
-- La etapa del funnel la gestiona tab_lead_camp.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_interacciones_lead
(
    id_interaccion  DECIMAL(10,0)   NOT NULL CHECK(id_interaccion > 0 AND id_interaccion <= 9999999999), -- Ampliado: DECIMAL(6,0) → DECIMAL(10,0)
    id_lead         VARCHAR(10)     NOT NULL,                                                             -- Corregido: DECIMAL(10,0) → VARCHAR(10)
    id_vendedor     VARCHAR(10)     NOT NULL,                                                             -- Corregido: DECIMAL(10,0) → VARCHAR(10)
    id_canal        DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    fec_interaccion TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,                                  -- Añadido NOT NULL
    ind_tipo        DECIMAL(1,0)    NOT NULL CHECK(ind_tipo IN (1, 2, 3, 4, 5)),                        -- Corregido: CHECK >= 1 AND <= 5 → IN (1,2,3,4,5)
    des_resultado   VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_resultado)) >= 3),                    -- Corregido: TRIM faltante
    PRIMARY KEY(id_interaccion),
    FOREIGN KEY(id_lead)     REFERENCES tab_leads(id_lead),
    FOREIGN KEY(id_vendedor) REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_canal)    REFERENCES tab_canales(id_canal)
    -- fec_proxima_accion eliminada: ahora vive en tab_proximas_acciones
);

--============================================================
--tabla de proximas acciones
--===========================================================
CREATE TABLE IF NOT EXISTS tab_proximas_acciones
(
    id_accion       DECIMAL(10,0)   NOT NULL CHECK(id_accion > 0 AND id_accion <= 9999999999),
    id_interaccion  DECIMAL(10,0)   NOT NULL CHECK(id_interaccion > 0 AND id_interaccion <= 9999999999),
    fec_accion      DATE            NOT NULL,                                                            -- Validación de fecha futura en PHP: no en BD para no romper datos históricos
    des_accion      VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_accion)) >= 10),
    ind_completada  BOOLEAN         NOT NULL DEFAULT FALSE,
    fec_completada  DATE            NOT NULL DEFAULT '9999-12-31',                                      -- 9999-12-31 = acción pendiente, fecha real = acción completada
    PRIMARY KEY(id_accion),
    FOREIGN KEY(id_interaccion) REFERENCES tab_interacciones_lead(id_interaccion),
    CONSTRAINT chk_fec_completada CHECK(
        (ind_completada = FALSE AND fec_completada = '9999-12-31'  ) OR  -- pendiente → sin fecha real
        (ind_completada = TRUE  AND fec_completada < '9999-12-31'  )     -- completada → con fecha real
    )
);
-- ============================================================
-- TABLA DE EVENTOS
-- Acciones presenciales o virtuales puntuales como ferias,
-- webinars o lanzamientos. La campaña es opcional.
-- El responsable es cualquier tercero registrado en public.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_evento
(
    id_evento       DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    id_campana      DECIMAL(6,0)    NULL     CHECK(id_campana > 0 AND id_campana <= 999999), -- NULL justificado: evento puede existir sin campaña
    id_responsable  VARCHAR(10)     NOT NULL,                                                 -- Corregido: DECIMAL(10,0) → VARCHAR(10)
    nom_evento      VARCHAR(120)    NOT NULL CHECK(LENGTH(TRIM(nom_evento)) >= 3),            -- Añadido CHECK faltante
    des_evento      VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_evento)) >= 10),           -- Tipado: TEXT → VARCHAR(250). Añadido CHECK faltante
    lug_evento      VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(lug_evento)) >= 3),            -- Ampliado: 150 → 250 para direcciones largas. Añadido CHECK faltante
    val_cupo        DECIMAL(4,0)    NOT NULL CHECK(val_cupo > 0 AND val_cupo <= 9999),
    fec_inicio      TIMESTAMP       NOT NULL,                                                 -- Corregido: DATE → TIMESTAMP, renombrado fec_evento → fec_inicio
    fec_fin         TIMESTAMP       NOT NULL,                                                 -- Añadido: para eventos de varios días
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                    -- Añadido NOT NULL y DEFAULT TRUE
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,                                   -- Añadido: borrado lógico faltante
    PRIMARY KEY(id_evento),
    FOREIGN KEY(id_campana)     REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_responsable) REFERENCES public.tab_terceros(id_tercero),
    CONSTRAINT chk_fechas_evento CHECK(fec_fin > fec_inicio)                                 -- Garantiza mínimo un instante de duración
);

-- ============================================================
-- TABLA EVENTO LEAD
-- Registra qué leads están vinculados a qué eventos.
-- Maneja el ciclo completo: invitación, confirmación y asistencia.
-- Los NULL son justificados — un lead invitado puede no confirmar
-- y uno confirmado puede no asistir.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_even_lead
(
    id_evento           DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    id_lead             VARCHAR(10)     NOT NULL,                                                          -- Corregido: DECIMAL(10,0) → VARCHAR(10)
    fec_invitacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                                     -- Añadido NOT NULL
    fec_confirmacion    DATE            NOT NULL DEFAULT '9999-12-31',                                     -- Corregido: NULL → NOT NULL DEFAULT '9999-12-31'
    fec_asistencia      DATE            NOT NULL DEFAULT '9999-12-31',                                     -- Corregido: NULL → NOT NULL DEFAULT '9999-12-31'
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado IN (1, 2, 3, 4)),                       -- Corregido: CHECK >= 1 AND <= 4 → IN (1,2,3,4)
    PRIMARY KEY(id_evento, id_lead),
    FOREIGN KEY(id_evento)  REFERENCES tab_evento(id_evento),
    FOREIGN KEY(id_lead)    REFERENCES tab_leads(id_lead),
    CONSTRAINT chk_coherencia_estado CHECK(
        -- Invitado: sin confirmación ni asistencia
        (ind_estado = 1 AND fec_confirmacion = '9999-12-31' AND fec_asistencia = '9999-12-31')
        OR
        -- Confirmado: con confirmación, sin asistencia
        (ind_estado = 2 AND fec_confirmacion < '9999-12-31' AND fec_asistencia = '9999-12-31')
        OR
        -- Asistió: con confirmación y con asistencia
        (ind_estado = 3 AND fec_confirmacion < '9999-12-31' AND fec_asistencia < '9999-12-31')
        OR
        -- No asistió: con confirmación, sin fecha de asistencia
        (ind_estado = 4 AND fec_confirmacion < '9999-12-31' AND fec_asistencia = '9999-12-31')
    )
);
-- ============================================================
-- TABLA PRODUCTO CAMPAÑA
-- Relación muchos a muchos entre productos y campañas.
-- Define qué productos o servicios se promocionan en cada campaña.
-- v2.0: agregar metas de unidades e ingresos por producto.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_prod_camp
(
    id_campana      DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_producto     DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),
    fec_asignacion  DATE            NOT NULL DEFAULT CURRENT_DATE,  -- Añadido: trazabilidad de cuándo se asignó el producto
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,          -- Añadido: desactivar producto sin eliminar registro
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,         -- Añadido: borrado lógico consistente con el esquema
    PRIMARY KEY(id_campana, id_producto),
    FOREIGN KEY(id_campana)  REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);
-- ============================================================
-- TABLAS DE PRESUPUESTO
-- Registra el presupuesto asignado y ejecutado por campaña o evento.
-- Nunca puede pertenecer a campaña Y evento al mismo tiempo.
-- val_ejecutado empieza en NULL y PHP lo actualiza conforme
-- se van registrando los gastos reales.
-- El flujo de aprobación por SECURE se integra en v1.1.
-- ============================================================
-- ============================================================
-- TABLA DE PRESUPUESTO DE CAMPAÑA
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_presupuesto_campana
(
    id_presupuesto      DECIMAL(6,0)    NOT NULL CHECK(id_presupuesto > 0 AND id_presupuesto <= 999999),
    id_campana          DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    val_aprobado        DECIMAL(12,0)   NOT NULL CHECK(val_aprobado >= 0),
    val_ejecutado       DECIMAL(12,0)   NOT NULL CHECK(val_ejecutado >= 0)                      DEFAULT 0,      -- DEFAULT 0: sin gastos al inicio
    des_presupuesto     VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_presupuesto)) >= 10),
    fec_presupuesto     DATE            NOT NULL DEFAULT CURRENT_DATE,
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado IN (1, 2, 3))                 DEFAULT 1,      -- 1=Pendiente / 2=Aprobado / 3=Rechazado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_presupuesto),
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    CONSTRAINT chk_ejecutado_campana CHECK(val_ejecutado <= val_aprobado)                                       -- No puede ejecutarse más de lo aprobado
);

-- ============================================================
-- TABLA DE PRESUPUESTO DE EVENTO
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_presupuesto_evento
(
    id_presupuesto      DECIMAL(6,0)    NOT NULL CHECK(id_presupuesto > 0 AND id_presupuesto <= 999999),
    id_evento           DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    val_aprobado        DECIMAL(12,0)   NOT NULL CHECK(val_aprobado >= 0),
    val_ejecutado       DECIMAL(12,0)   NOT NULL CHECK(val_ejecutado >= 0)                      DEFAULT 0,      -- DEFAULT 0: sin gastos al inicio
    des_presupuesto     VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_presupuesto)) >= 10),
    fec_presupuesto     DATE            NOT NULL DEFAULT CURRENT_DATE,
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado IN (1, 2, 3))                 DEFAULT 1,      -- 1=Pendiente / 2=Aprobado / 3=Rechazado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_presupuesto),
    FOREIGN KEY(id_evento) REFERENCES tab_evento(id_evento),
    CONSTRAINT chk_ejecutado_evento CHECK(val_ejecutado <= val_aprobado)                                        -- No puede ejecutarse más de lo aprobado
);

-- ============================================================
-- TABLA DE KPIs DE CAMPAÑA
-- Define qué KPIs se miden en el módulo 
-- Para agregar un KPI nuevo solo se inserta una fila aquí
-- sin alterar ninguna estructura. Totalmente escalable.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_kpis_campana
(
    id_kpi              DECIMAL(2,0)    NOT NULL CHECK(id_kpi > 0 AND id_kpi <= 99),
    nom_kpi             VARCHAR(60)     NOT NULL CHECK(LENGTH(nom_kpi) >= 3),
    des_kpi             TEXT            NOT NULL,
    ind_estado          BOOLEAN         NOT NULL, -- TRUE = activo / FALSE = inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, -- TRUE = KPI eliminado (solo para referencia histórica, no aparece en opciones activas)
    PRIMARY KEY(id_kpi)
);

INSERT INTO tab_kpis_campana VALUES(1, 'Leads Generados',    'Cantidad de leads nuevos captados en el período',                          TRUE);
INSERT INTO tab_kpis_campana VALUES(2, 'Correos Abiertos',   'Cantidad de correos abiertos por los destinatarios',                       TRUE);
INSERT INTO tab_kpis_campana VALUES(3, 'Clics en Correo',    'Cantidad de clics en enlaces dentro del correo',                           TRUE);
INSERT INTO tab_kpis_campana VALUES(4, 'Conversiones',       'Leads que se convirtieron en clientes en el período',                      TRUE);
INSERT INTO tab_kpis_campana VALUES(5, 'Alcance',            'Cantidad de personas que vieron la campaña en el período',                 TRUE);
INSERT INTO tab_kpis_campana VALUES(6, 'Costo por Lead',     'Presupuesto ejecutado dividido entre leads generados en el período',       TRUE);
INSERT INTO tab_kpis_campana VALUES(7, 'ROI',                'Retorno sobre inversión expresado en porcentaje',                          TRUE);

-- ============================================================
-- TABLA DE MEDICIÓN DE KPIs
-- Guarda los valores de cada KPI por campaña y por período.
-- PHP inserta una fila por KPI por mes por campaña.
-- PK compuesta garantiza una sola medición por KPI por mes.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_medicion_kpi
(
    id_campana                  DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_kpi                      DECIMAL(2,0)    NOT NULL CHECK(id_kpi > 0 AND id_kpi <= 99),
    fec_periodo                 DATE            NOT NULL,                                                    -- Corregido: num_anio + num_mes → DATE truncado al primer día del mes
    val_medicion                DECIMAL(12,2)   NOT NULL,                                                   -- Corregido: CHECK >= 0 eliminado, permite ROI negativo. Validación en PHP
    fec_ultima_actualizacion    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,                         -- Añadido: saber cuándo fue la última actualización
    PRIMARY KEY(id_campana, id_kpi, fec_periodo),                                                           -- Corregido: num_anio + num_mes → fec_periodo
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_kpi)     REFERENCES tab_kpis_campana(id_kpi),
    CONSTRAINT chk_periodo_primer_dia CHECK(EXTRACT(DAY FROM fec_periodo) = 1)                               -- Garantiza que fec_periodo siempre sea el primer día del mes
    
);

-- ============================================================
-- TABLA DE PLANTILLAS DE CORREO
-- Plantillas reutilizables para email y WhatsApp.
-- Genéricas, no atadas a ninguna campaña específica.
-- PHP las consulta al momento de crear un envío.
-- La IA puede generar o mejorar el contenido desde PHP.
-- des_asunto es NULL justificado cuando el canal es WhatsApp.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_plantillas_correo
(
    id_plantilla        DECIMAL(4,0)    NOT NULL CHECK(id_plantilla > 0 AND id_plantilla <= 9999),
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    nom_plantilla       VARCHAR(120)    NOT NULL CHECK(LENGTH(nom_plantilla) >= 3),
    des_asunto          VARCHAR(150)    NULL, -- NULL justificado cuando el canal es WhatsApp
    des_contenido       TEXT            NOT NULL,
    ind_generada_ia     BOOLEAN         NOT NULL DEFAULT FALSE, -- TRUE si la generó la IA
    ind_estado          BOOLEAN         NOT NULL, -- TRUE = activa / FALSE = inactiva
    PRIMARY KEY(id_plantilla),
    FOREIGN KEY(id_canal) REFERENCES tab_canales(id_canal)
);

-- ============================================================
-- TABLA DE CONTACTOS ADICIONALES
-- Guarda contactos adicionales de terceros jurídicos (empresas).
-- Ejemplos: gerente, contador, representante legal.
-- PHP valida que id_tercero sea jurídico (ind_tipo_tercero = TRUE)
-- antes de insertar. El máximo de contactos por tercero lo
-- controla val_max_contactos_adic en tab_pmtros_
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_contactos_adicionales
(
    id_contacto     DECIMAL(6,0)    NOT NULL CHECK(id_contacto > 0 AND id_contacto <= 999999),
    id_tercero      VARCHAR(10)     NOT NULL,                                                        -- Corregido: DECIMAL(10,0) → VARCHAR(10)
    nom_contacto    VARCHAR(120)    NOT NULL CHECK(LENGTH(TRIM(nom_contacto)) >= 3),                -- Añadido CHECK faltante
    car_contacto    VARCHAR(60)     NOT NULL CHECK(LENGTH(TRIM(car_contacto)) >= 2),                -- Añadido CHECK faltante
    tel_contacto    DECIMAL(10,0)   NOT NULL CHECK(tel_contacto >= 1000000000),                     -- Mantenido: 10 dígitos para Colombia
    email_contacto  VARCHAR(120)    NOT NULL CHECK(LENGTH(TRIM(email_contacto)) >= 6),              -- Añadido CHECK mínimo a@b.co
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                           -- Añadido NOT NULL y DEFAULT TRUE
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,                                          -- Añadido: borrado lógico faltante
    PRIMARY KEY(id_contacto),
    FOREIGN KEY(id_tercero) REFERENCES public.tab_terceros(id_tercero)
    -- PHP valida que id_tercero sea jurídico (ind_tipo_tercero = TRUE)
    -- antes de insertar — no es posible validarlo en BD sin trigger
);

-- ============================================================
-- TABLA DE ENVÍOS INDIVIDUALES
-- Registra cada mensaje enviado a cada tercero por campaña.
-- Es la base del rastreo de aperturas y clics.
-- cod_tracking es el código único que PHP incrusta como pixel
-- en cada correo para detectar apertura y clic individual.
-- fec_apertura y fec_clic son NULL hasta que el tercero
-- interactúe con el mensaje.
-- ============================================================
CREATE TABLE IF NOT EXISTS tab_envios
(
    id_envio        DECIMAL(10,0)   NOT NULL CHECK(id_envio > 0 AND id_envio <= 9999999999),
    id_campana      DECIMAL(6,0)    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_plantilla    DECIMAL(4,0)    NOT NULL CHECK(id_plantilla > 0 AND id_plantilla <= 9999),
    id_tercero      VARCHAR(10)     NOT NULL,
    id_canal        DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    fec_envio       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cod_tracking    VARCHAR(64)     NOT NULL CHECK(LENGTH(TRIM(cod_tracking)) = 36),                  -- Añadido CHECK: exactamente 36 caracteres → formato UUID
    fec_apertura    TIMESTAMP       NOT NULL DEFAULT '9999-12-31 00:00:00',
    fec_clic        TIMESTAMP       NOT NULL DEFAULT '9999-12-31 00:00:00',
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_envio),
    UNIQUE(cod_tracking),
    FOREIGN KEY(id_campana)   REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_plantilla) REFERENCES tab_plantillas_correo(id_plantilla),
    FOREIGN KEY(id_tercero)   REFERENCES public.tab_terceros(id_tercero),
    FOREIGN KEY(id_canal)     REFERENCES tab_canales(id_canal),
    CONSTRAINT chk_fec_apertura CHECK(                                                                -- Añadido: apertura debe ser posterior al envío
        fec_apertura = '9999-12-31 00:00:00' OR fec_apertura >= fec_envio
    ),
    CONSTRAINT chk_fec_clic CHECK(                                                                    -- Añadido: clic debe ser posterior al envío
        fec_clic = '9999-12-31 00:00:00' OR fec_clic >= fec_envio
    ),
    CONSTRAINT chk_tracking_coherente CHECK(
        -- Sin apertura → sin clic
        (fec_apertura = '9999-12-31 00:00:00' AND fec_clic = '9999-12-31 00:00:00')
        OR
        -- Con apertura → sin clic todavía
        (fec_apertura < '9999-12-31 00:00:00' AND fec_clic = '9999-12-31 00:00:00')
        OR
        -- Con apertura y con clic
        (fec_apertura < '9999-12-31 00:00:00' AND fec_clic < '9999-12-31 00:00:00')
    )
);

----------------------------------------
--MÓDULO DE CONTABILIDAD Y PRESUPUESTO--
----------------------------------------


-- TABLA 1: Plan Único de Cuentas (catálogo maestro de cuentas contables)
CREATE TABLE IF NOT EXISTS tab_puc
(
    id_nivel            DECIMAL(1,0)    NOT NULL CHECK(id_nivel >=  1 AND id_nivel <= 9),        -- Nivel jerárquico (1-9)
    id_cod_puc          VARCHAR(20)     NOT NULL CHECK(id_cod_puc > 0),                          -- Código de la cuenta (ej: 110505)
    nom_cuenta          VARCHAR(60)     NOT NULL CHECK(LENGTH(nom_cuenta) >= 3),                 -- Nombre de la cuenta
    ind_natura          BOOLEAN         NOT NULL,                                                -- TRUE=Débito, FALSE=Crédito
    descrip_puc         VARCHAR(200)    DEFAULT 'N/A',                                           -- Descripción opcional
    cod_superior        VARCHAR(20)     NOT NULL,                                                -- Código del padre (0 si nivel 1)
    ind_req_tercero     BOOLEAN         NOT NULL DEFAULT FALSE,                                  -- Requiere tercero (cliente/proveedor)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                   -- TRUE=activo, FALSE=inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                  -- Borrado lógico
    PRIMARY KEY(id_nivel, id_cod_puc),                                                           -- Llave primaria compuesta
    CONSTRAINT chk_puc_codigo   CHECK(id_cod_puc ~ '^[0-9]+$'),                                   -- Solo números en el código  -- REVISAR CON PEREZ  --
    CONSTRAINT chk_puc_superior
    CHECK(                                                          -- Regla jerárquica
        (id_nivel = 1 AND cod_superior = '0') OR                                                 -- Nivel 1: superior = 0
        (id_nivel > 1 AND cod_superior != '0' AND LENGTH(cod_superior) < LENGTH(id_cod_puc))     -- Niveles >1: superior existe y es más corto
    )
);
CREATE INDEX IF NOT EXISTS idx_puc_cod_superior ON tab_puc(cod_superior);          -- Para búsquedas jerárquicas
CREATE INDEX IF NOT EXISTS idx_puc_nivel_estado ON tab_puc(id_nivel, ind_estado);  -- Para filtros por nivel y estado

-- TABLA 2: Categorías de Activos Fijos (clasificación para depreciación)
CREATE TABLE IF NOT EXISTS tab_cat_activos
(
    id_categoria_act    DECIMAL(2,0)    NOT NULL CHECK(id_categoria_act BETWEEN 1 AND 99), -- ID de categoría (1-99)
    nom_categoria       VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_categoria) >= 3),        -- Nombre (ej: Equipo de Cómputo)
    vida_util_meses     DECIMAL(3,0)    NOT NULL DEFAULT 60,                               -- Vida útil en meses
    metodo_depreciacion CHAR(1)         NOT NULL DEFAULT 'L' CHECK(metodo_depreciacion IN ('L', 'S')), -- L=Linea Recta, S=Saldo Decreciente
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                             -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                            -- Borrado lógico
    PRIMARY KEY(id_categoria_act)                                                         -- Llave primaria simple
);
CREATE INDEX IF NOT EXISTS idx_cat_activos_estado ON tab_cat_activos(ind_estado);  -- Filtro por estado

-- TABLA 4: Períodos de Presupuesto (año + mes)
CREATE TABLE IF NOT EXISTS tab_period_presupuesto
(
    id_periodo          DECIMAL(10,0)   NOT NULL CHECK(id_periodo > 0),                    -- ID del período
    anio_periodo        DECIMAL(4,0)    NOT NULL CHECK(anio_periodo BETWEEN 2000 AND 2100), -- Año (2000-2100)
    mes_periodo         DECIMAL(2,0)    NOT NULL CHECK(mes_periodo BETWEEN 1 AND 12),      -- Mes (1-12)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                             -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                            -- Borrado lógico
    PRIMARY KEY(id_periodo)                                                               -- Llave primaria
);
CREATE INDEX IF NOT EXISTS idx_periodo_anio_mes ON tab_period_presupuesto(anio_periodo, mes_periodo); -- Búsqueda por año/mes

-- TABLA 5: Tipos de Presupuesto (Operativo, Inversión, Caja...)
CREATE TABLE IF NOT EXISTS tab_tipo_presupuesto
(
    id_tipo_presupuesto DECIMAL(10,0)   NOT NULL CHECK(id_tipo_presupuesto > 0),           -- ID del tipo
    nom_tipo            VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipo) >= 3),             -- Nombre del tipo
    descrip_tipo        VARCHAR(200)    DEFAULT '',                                        -- Descripción
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                             -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                            -- Borrado lógico
    PRIMARY KEY(id_tipo_presupuesto)                                                      -- Llave primaria
);
CREATE INDEX IF NOT EXISTS idx_tipo_presupuesto_estado ON tab_tipo_presupuesto(ind_estado); -- Filtro por estado


-- TABLA 7: Tipos de Comprobantes (Diario, Ingreso, Egreso)
CREATE TABLE IF NOT EXISTS tab_tip_comprobantes
(
    id_tipcomprobante       SMALLINT        NOT NULL CHECK(id_tipcomprobante > 0),           -- ID del tipo
    nom_tipcomprobante      VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipcomprobante) >= 3), -- Nombre
    num_inicial             
    num_final
    num_actual
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                           -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_tipcomprobante)                                                      -- Llave primaria
);
CREATE INDEX IF NOT EXISTS idx_tip_comprobante_codigo ON tab_tip_comprobantes(cod_tipcomprobante); -- Búsqueda por código

-- TABLA 8: Parámetros Contables (solo UN registro por empresa)
CREATE TABLE IF NOT EXISTS tab_parametros_contab
(
    id_empresa          DECIMAL(10,0)   NOT NULL CHECK(id_empresa >= 10000000 AND id_empresa <= 9999999999), -- Empresa
    anio_contable       DECIMAL(4,0)    NOT NULL CHECK(anio_contable >= 2000),           -- Año contable actual
    mes_contable        DECIMAL(2,0)    NOT NULL CHECK(mes_contable BETWEEN 1 AND 12),   -- Mes contable actual
    ind_estado_period   BOOLEAN         NOT NULL DEFAULT TRUE,                           -- TRUE=período activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_empresa),                                                          -- Llave primaria
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),            -- FK a empresa
    CONSTRAINT chk_parametros_fechas CHECK (fec_cierre >= fec_apertura)                 -- Fechas coherentes
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_parametros_empresa ON tab_parametros_contab(id_empresa); -- Solo UN registro por empresa

-- TABLA 10: Activos Fijos (bienes de la empresa)
CREATE TABLE IF NOT EXISTS tab_act_fijos
(
    id_activo               DECIMAL(10,0)   NOT NULL CHECK(id_activo > 0),                    -- ID del activo
    id_categoria_act        DECIMAL(2,0)    NOT NULL,                                        -- Categoría (FK)
    num_placa               VARCHAR(20)     NOT NULL UNIQUE,                                 -- Código único del activo
    nom_activo              VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_activo) >= 3),         -- Nombre
    fecha_compra            DATE            NOT NULL CHECK(fecha_compra <= CURRENT_DATE),    -- Fecha de compra
    val_compra              DECIMAL(15,0)   NOT NULL CHECK(val_compra > 0),                  -- Valor de compra
    val_residual            DECIMAL(15,0)   NOT NULL DEFAULT 0,                              -- Valor residual
    depreciacion_acumulada  DECIMAL(15,0)   NOT NULL DEFAULT 0,                             -- Depreciación acumulada
    ind_estado_activo       CHAR(1)         NOT NULL DEFAULT 'A' CHECK(ind_estado_activo IN ('A', 'B', 'D')), -- A=Activo, B=Baja, D=Depreciado
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_activo),                                                             -- Llave primaria
    FOREIGN KEY(id_categoria_act) REFERENCES tab_cat_activos(id_categoria_act),  -- FK a categoría
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),            -- FK a empresa
    FOREIGN KEY(id_tercero) REFERENCES public.tab_terceros(id_tercero),                 -- FK a proveedor
    CONSTRAINT chk_activo_residual CHECK (val_residual < val_compra),                   -- Residual debe ser menor a compra
    CONSTRAINT chk_activo_depreciacion CHECK (depreciacion_acumulada <= (val_compra - val_residual)) -- No depreciar más de lo debido
);
CREATE INDEX IF NOT EXISTS idx_act_fijos_categoria ON tab_act_fijos(id_categoria_act); -- Índice FK

-- TABLA 11: Depreciación de Activos (registro periódico)
CREATE TABLE IF NOT EXISTS tab_depreciacion
(
    id_activo                       DECIMAL(10,0)   NOT NULL,                                        -- Activo (FK)
    id_mes                          DECIMAL(10,0)   NOT NULL,                                        -- Período contable (FK)
    val_depreciacion                DECIMAL(15,0)   NOT NULL CHECK(val_depreciacion > 0),            -- Valor depreciado este período
    depreciacion_acumulada_antes    DECIMAL(15,0)   NOT NULL,                                        -- Acumulado ANTES de esta depreciación
    depreciacion_acumulada_despues  DECIMAL(15,0)   NOT NULL,                                        -- Acumulado DESPUÉS de esta depreciación
    id_comprobante                  DECIMAL(10,0),                                                   -- Comprobante contable asociado
    ind_borrado                     BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_depreciacion),                                                                    -- Llave primaria
    FOREIGN KEY(id_activo) REFERENCES tab_act_fijos(id_activo),                               -- FK a activo
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),                         -- FK a empresa
    FOREIGN KEY(id_periodo_contable) REFERENCES tab_periodos_contables(id_periodo_contable),  -- FK a período
    CONSTRAINT chk_depreciacion_aumenta CHECK (depreciacion_acumulada_despues > depreciacion_acumulada_antes) -- La depreciación siempre aumenta
);
CREATE INDEX IF NOT EXISTS idx_depreciacion_activo ON tab_depreciacion(id_activo); -- Búsqueda por activo


-- TABLA 13: Presupuesto (cabecera)
CREATE TABLE IF NOT EXISTS tab_presupuesto
(
    id_area             
    id_mes              DECIMAL(10,0)   NOT NULL,                                    -- Período (FK)
    descrip_presupuesto     VARCHAR(200)    DEFAULT '',                                  -- Descripción
    fecha_aprobacion        DATE,                                                        -- Fecha de aprobación
    TOTAL PRESUPUESTO (SUMATORIA DE LOS ITEMS DEL MES)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                      -- Borrado lógico
    PRIMARY KEY(id_presupuesto),                                                        -- Llave primaria
    FOREIGN KEY(id_periodo) REFERENCES tab_period_presupuesto(id_periodo),       -- FK a período
    FOREIGN KEY(id_tipo_presupuesto) REFERENCES tab_tipo_presupuesto(id_tipo_presupuesto), -- FK a tipo
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),            -- FK a empresa
    UNIQUE(id_periodo, id_tipo_presupuesto, version)                                    -- No duplicar mismo período+tipo+versión
);
CREATE INDEX IF NOT EXISTS idx_presupuesto_periodo ON tab_presupuesto(id_periodo); -- Búsqueda por período

-- TABLA 14: Planeación de Presupuesto (detalle por cuenta y área)
CREATE TABLE IF NOT EXISTS tab_planeacion_presupuesto
(
    AREA
    MES
    CUENTA PUC
    VALOR_PLANEADO
    VALOR EJECUTADO
    IND DE MES CERRADO (BOOLEAN)
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_plan),                                                             -- Llave primaria
    FOREIGN KEY(id_area) REFERENCES public.tab_areas(id_area),                         -- FK a área
    FOREIGN KEY(id_presupuesto) REFERENCES tab_presupuesto(id_presupuesto),     -- FK a presupuesto
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc)  -- FK a PUC
);
CREATE INDEX IF NOT EXISTS idx_planeacion_presupuesto ON tab_planeacion_presupuesto(id_presupuesto); -- Búsqueda por presupuesto
CREATE INDEX IF NOT EXISTS idx_planeacion_area ON tab_planeacion_presupuesto(id_area); -- Búsqueda por área
CREATE INDEX IF NOT EXISTS idx_planeacion_puc ON tab_planeacion_presupuesto(id_nivel, id_cod_puc); -- Búsqueda por PUC

-- TABLA 15: Comprobantes Contables (cabecera)
CREATE TABLE IF NOT EXISTS tab_comprobantes_contab
(
    id_tipcomprobante   DECIMAL(10,0)   NOT NULL,                                       -- Tipo (FK)
    NUMERO DE COMPROBANTE
    MES
    num_comprobante     DECIMAL(10,0)   NOT NULL,                                       -- Número del comprobante
    fecha_comprobante   DATE            NOT NULL CHECK(fecha_comprobante <= CURRENT_DATE), -- Fecha
    concepto            VARCHAR(200)    NOT NULL,                                       -- Concepto/descripción
    total_debe          DECIMAL(15,0)   NOT NULL DEFAULT 0,                             -- Total débitos
    total_haber         DECIMAL(15,0)   NOT NULL DEFAULT 0,                             -- Total créditos
    estado              CHAR(1)         NOT NULL DEFAULT 'B' CHECK(estado IN ('B', 'C', 'A')), -- B=Borrador, C=Contabilizado, A=Anulado
    usuario_creacion    VARCHAR(50)     DEFAULT CURRENT_USER,                           -- Usuario que creó
    fecha_creacion      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,                      -- Fecha de creación
    usuario_contabilizacion VARCHAR(50),                                                -- Usuario que contabilizó
    fecha_contabilizacion TIMESTAMP,                                                    -- Fecha de contabilización
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_comprobante),                                                       -- Llave primaria
    FOREIGN KEY(id_tipcomprobante) REFERENCES tab_tip_comprobantes(id_tipcomprobante), -- FK a tipo
    FOREIGN KEY(id_empresa) REFERENCES public.tab_pmtros_grales(id_empresa),           -- FK a empresa
    FOREIGN KEY(id_tercero) REFERENCES public.tab_terceros(id_tercero),                -- FK a tercero
    FOREIGN KEY(id_periodo_contable) REFERENCES tab_periodos_contables(id_periodo_contable), -- FK a período
    UNIQUE(id_tipcomprobante, id_periodo_contable, num_comprobante),                   -- No duplicar tipo+período+número
    CONSTRAINT chk_comprobante_cuadrado CHECK (estado != 'C' OR total_debe = total_haber) -- Si está contabilizado, debe estar cuadrado
);
CREATE INDEX IF NOT EXISTS idx_comprobantes_fecha ON tab_comprobantes_contab(fecha_comprobante); -- Búsqueda por fecha
CREATE INDEX IF NOT EXISTS idx_comprobantes_estado ON tab_comprobantes_contab(estado); -- Búsqueda por estado

-- TABLA 16: Detalle de Presupuesto (montos comprometidos y ejecutados)
CREATE TABLE IF NOT EXISTS tab_det_presupuestos
(
     id_plan                 DECIMAL(10,0)   NOT NULL,                                     -- Plan (FK)
    monto_aprobado          DECIMAL(15,0)   NOT NULL CHECK(monto_aprobado >= 0),          -- Monto aprobado
    monto_comprometido      DECIMAL(15,0)   NOT NULL DEFAULT 0,                           -- Monto comprometido (pedidos)
    monto_ejecutado         DECIMAL(15,0)   NOT NULL DEFAULT 0,                           -- Monto ejecutado (real)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                       -- Borrado lógico
    PRIMARY KEY(id_detalle_presupuesto),                                                 -- Llave primaria
    FOREIGN KEY(id_plan) REFERENCES tab_planeacion_presupuesto(id_plan),          -- FK a plan
    CONSTRAINT chk_det_presupuesto_comprometido CHECK (monto_comprometido <= monto_aprobado), -- No comprometer más de lo aprobado
    CONSTRAINT chk_det_presupuesto_ejecutado CHECK (monto_ejecutado <= monto_aprobado)   -- No ejecutar más de lo aprobado
);
CREATE INDEX IF NOT EXISTS idx_det_presupuesto_plan ON tab_det_presupuestos(id_plan); -- Búsqueda por plan

-- TABLA 17: Ejecución de Presupuesto (real vs planeado)
CREATE TABLE IF NOT EXISTS tab_ejecucion_presupuesto
(
    id_ejecucion        DECIMAL(10,0)   NOT NULL,                                         -- ID de ejecución
    id_plan             DECIMAL(10,0)   NOT NULL,                                         -- Plan (FK)
    id_comprobante      DECIMAL(10,0)   NOT NULL,                                         -- Comprobante (FK)
    id_detalle_presupuesto DECIMAL(10,0) NOT NULL,                                        -- Detalle (FK)
    valor_real          DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_real >= 0),       -- Valor real ejecutado
    fecha_registro      DATE            NOT NULL DEFAULT CURRENT_DATE,                   -- Fecha de registro
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                          -- Borrado lógico
    PRIMARY KEY(id_ejecucion),                                                          -- Llave primaria
    FOREIGN KEY(id_plan) REFERENCES tab_planeacion_presupuesto(id_plan),         -- FK a plan
    FOREIGN KEY(id_comprobante) REFERENCES tab_comprobantes_contab(id_comprobante), -- FK a comprobante
    FOREIGN KEY(id_detalle_presupuesto) REFERENCES tab_det_presupuestos(id_detalle_presupuesto) -- FK a detalle
);
CREATE INDEX IF NOT EXISTS idx_ejecucion_fecha ON tab_ejecucion_presupuesto(fecha_registro); -- Búsqueda por fecha

-- TABLA 19: Detalle de Comprobantes (partida doble)
CREATE TABLE IF NOT EXISTS tab_det_comprobantes
(
   id_tipcomprobante   DECIMAL(10,0)   NOT NULL,                                       -- Tipo (FK)
    NUMERO DE COMPROBANTE
    CUENTA PUC
    descrip_det_comp    VARCHAR(200)    DEFAULT '',                                     -- Descripción de la línea
    valor_debito        DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_debito >= 0),    -- Valor débito
    valor_credito       DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_credito >= 0),   -- Valor crédito
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                         -- Borrado lógico
    PRIMARY KEY(id_det_comp),                                                          -- Llave primaria
    FOREIGN KEY(id_comprobante) REFERENCES tab_comprobantes_contab(id_comprobante) ON DELETE CASCADE, -- FK a comprobante (si se borra el comprobante, se borran sus líneas)
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc), -- FK a PUC
    CONSTRAINT chk_det_comprobante_xor CHECK (                                          -- Una línea NO puede tener débito y crédito a la vez
        (valor_debito > 0 AND valor_credito = 0) OR 
        (valor_debito = 0 AND valor_credito > 0)
    )
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_det_comprobantes_unico ON tab_det_comprobantes(id_comprobante, id_nivel, id_cod_puc, linea); -- Evita líneas duplicadas
CREATE INDEX IF NOT EXISTS idx_det_comprobantes_puc ON tab_det_comprobantes(id_nivel, id_cod_puc); -- Búsqueda por cuenta PUC

-- ----------------------------------------------------------------
-- MÓDULO DE FACTURACIÓN
-- ----------------------------------------------------------------

CREATE TABLE tab_pmtros_facturacion
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
CREATE TABLE IF NOT EXISTS tab_clientes
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
 CREATE TABLE IF NOT EXISTS tab_productos
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
CREATE TABLE IF NOT EXISTS tab_vendedores
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
CREATE TABLE IF NOT EXISTS tab_enc_cotizaciones
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
	FOREIGN KEY (id_cliente)        REFERENCES tab_clientes(id_cliente),
    FOREIGN KEY (id_vendedor)       REFERENCES tab_vendedores(id_vendedor),
	FOREIGN KEY (id_ciudad)         REFERENCES public.tab_ciudades(id_ciudad)
);

--------------------------------------
-- TABLA DE DETALLE DE COTIZACIONES --
--------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_cotizaciones
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
    FOREIGN KEY(id_cotizacion)      REFERENCES tab_enc_cotizaciones(id_cotizacion),
    FOREIGN KEY(id_producto)        REFERENCES tab_productos(id_producto)
);

--------------------------
-- TABLA DE FORMA PAGOS --
--------------------------
CREATE TABLE IF NOT EXISTS tab_forma_pagos
(
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),                        --identificador de la forma de pago
	nom_formapago                   VARCHAR                     NOT NULL CHECK(LENGTH(nom_formapago) >= 3),                                     --nombre de la forma de pago
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
	PRIMARY KEY(id_formapago)
);

------------------------------------
-- TABLA DE ENCABEZADO DE FACTURA --
------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_facturas
(
	id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >=0 AND id_factura<=999999),	                        --identificador de la factura
	id_cliente                      VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_cliente)) >=6),            						--identificador del cliente
	id_vendedor                     VARCHAR(10)                 NOT NULL CHECK(LENGTH(TRIM(id_vendedor)) >=6),          							--identificador del vendedor
	fec_factura                     DATE                        NOT NULL CHECK(fec_factura <= CURRENT_DATE),                                     --fecha de la creacion de la factura
	id_formapago                    DECIMAL(1,0)                NOT NULL CHECK(id_formapago >= 0 AND id_formapago <= 9),                        --identificador de la forma de pago
	val_total                       DECIMAL(10,0)               NOT NULL CHECK(val_total <= 9999999999),                                        --total de la factura
	ind_estado                      BOOLEAN                     NOT NULL, -- TRUE=Activa / FALSE=Vencida,                                       --estado en el que se encuentra la factura
	PRIMARY KEY (id_factura),
	FOREIGN KEY (id_cliente)        REFERENCES tab_clientes(id_cliente),
	FOREIGN KEY (id_vendedor)       REFERENCES tab_vendedores(id_vendedor),
	FOREIGN KEY (id_formapago)      REFERENCES tab_forma_pagos(id_formapago)
);

---------------------------------
-- TABLA DE DETALLE DE FACTURA --
---------------------------------
CREATE TABLE IF NOT EXISTS tab_det_facturas
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
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas(id_factura),
    FOREIGN KEY(id_producto)        REFERENCES tab_productos(id_producto)
);

---------------------------------
-- TABLA DE FACTURA ELECTRONICA--
---------------------------------
CREATE TABLE IF NOT EXISTS tab_fac_electronicas
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
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas(id_factura)
);

-- --------------------------------
-- TABLA DE CONDICIONES DE PAGOS --
-- ---------------------------------------------------
-- ESTA TABLA ES PARA LOS USUARIOS QUE TIENEN CREDITO
-- APROBADO PARA PODER REALIZAR EL PAGO DE LA FACTURA
-- POR ESTE MEDIO LA FACTURA
-- ---------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_cond_pagos
(
	id_cond_pago                    DECIMAL(5,0)                NOT NULL CHECK(id_cond_pago >= 0 AND id_cond_pago <= 99999),                    --identificador de condicion de pago
    id_factura                      DECIMAL(6,0)                NOT NULL CHECK(id_factura >= 0 AND id_factura <= 999999),                       --identificador de la factura
	val_plazofinanciado             DECIMAL(3,0)                NOT NULL CHECK(val_plazofinanciado >= 0 AND val_plazofinanciado <= 120),        --plazo al que se financio el la cartera
	val_tasainteres                 DECIMAL(3,0)                NOT NULL CHECK(val_tasainteres >= 0 AND val_tasainteres <= 100),                --la tasa de interes las condicones de pago
	val_total_finan                 DECIMAL(10,0)               NOT NULL CHECK(val_total_finan >= 0 AND val_total_finan <= 9999999999),         --valor total finaciado
	val_observacion                 VARCHAR                     NOT NULL CHECK(LENGTH(val_observacion)<=255),                                   --descripcion de la condicon del pago
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	        --indicador de borrado lógico
	PRIMARY KEY (id_cond_pago),
	FOREIGN KEY (id_factura)        REFERENCES tab_enc_facturas(id_factura)
);

----------------------
--TABLA DE CARTERAS --
----------------------
-- ESTA TABLA ES PARA LOS QUE REALIZARON EL PAGO DE LA FACTURA POR MEDIO DE CREDITO
CREATE TABLE IF NOT EXISTS tab_carteras
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
    FOREIGN KEY(id_cond_pago)       REFERENCES tab_cond_pagos(id_cond_pago)
);

--------------------------------------
-- TABLA DE SEGUIMIENTO DE CARTERAS --
--------------------------------------
CREATE TABLE IF NOT EXISTS tab_segui_carteras
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
	FOREIGN KEY (id_cartera)        REFERENCES tab_carteras (id_cartera)
);

------------------------
-- TABLA DE LOS PAGOS --
------------------------
CREATE TABLE IF NOT EXISTS tab_pagos
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
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas (id_factura),
    FOREIGN KEY(id_cartera)         REFERENCES tab_carteras (id_cartera)
);

----------------------------------------------------------
-- TIPO DE NOTAS 
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_nota (
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
CREATE TABLE IF NOT EXISTS tab_motivo_nota (
    id_motivo_nota                  DECIMAL(3,0)                NOT NULL CHECK(id_motivo_nota >=0 AND id_motivo_nota <=999),   --identificador del motivo de nota
    id_tipo_nota                    DECIMAL(1,0)                NOT NULL CHECK(id_tipo_nota IN(1,2)),                          --tipo de nota asociada
    cod_motivo                      VARCHAR(15)                 NOT NULL CHECK(LENGTH(cod_motivo)<=15),                        --codigo del motivo de nota
    nom_motivo                      VARCHAR(255)                NOT NULL CHECK(LENGTH(nom_motivo) <= 255),                     --nombre del motivo de nota
    afecta_cartera                  BOOLEAN                     NOT NULL DEFAULT TRUE,                                         --AFECTA CARTERA ES CREDITO
    afecta_comision                 BOOLEAN                     NOT NULL DEFAULT FALSE,                                        --afecta la comsion del vendedor si es asi(true) o no (false)
    ind_borrado                     BOOLEAN                     NOT NULL DEFAULT FALSE,                                        --indicador de borrado lógico
    PRIMARY KEY (id_motivo_nota),
    FOREIGN KEY (id_tipo_nota) REFERENCES tab_tipo_nota(id_tipo_nota)
);

----------------------------------------------------------
-- NOTA CRÉDITO Y DÉBITO (MODIFICADA)
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_nota (
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
    FOREIGN KEY (id_tipo_nota)      REFERENCES tab_tipo_nota(id_tipo_nota),
    FOREIGN KEY (id_motivo_nota)    REFERENCES tab_motivo_nota(id_motivo_nota)
);

----------------------------------------------------------
-- APLICACIÓN DE NOTAS (MODIFICADA)
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_aplicacion_nota (
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
    FOREIGN KEY(id_nota)            REFERENCES tab_nota(id_nota),
    FOREIGN KEY(id_factura)         REFERENCES tab_enc_facturas(id_factura),
    FOREIGN KEY(id_cartera)         REFERENCES tab_carteras(id_cartera)
);

----------------------------------------------------------
-- PRESUPUESTO 
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_presupuesto (
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

----------------------------------------------
-- MÓDULO DE TESORERIA
-------------------------------------------

-- ----------------------------------------
-- TABLA DE PARÁMETROS DE TESORERÍA Y CXP -
-- ----------------------------------------

CREATE TABLE IF NOT EXISTS tab_pmtros_tescxp
(
    id_empresa          DECIMAL(10,0)       NOT NULL CHECK((id_empresa) >= 1 AND (id_empresa) <= 9999999999), -- Identificador (NIT) de la empresa
    fec_diapago1        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago1) >= 1 AND (fec_diapago1) <= 7),      -- Día #1 en el que la empresa decide pagar
    fec_diapago2        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago2) >= 1 AND (fec_diapago2) <= 7),      -- Día #2 en el que la empresa decide pagar
    fec_diapago3        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago3) >= 1 AND (fec_diapago3) <= 7),      -- Día #3 en el que la empresa decide pagar

    PRIMARY KEY(id_empresa)
);

--------------------------------------------------
--        TABLA DE BANCOS POR PROVEEDORES       --
--------------------------------------------------

CREATE TABLE IF NOT EXISTS tab_bancoxprov
(
    id_proveedor	    DECIMAL(10,0)	    NOT NULL CHECK((id_proveedor) >= 1 AND (id_proveedor) <= 9999999999),       -- Identificador (NIT) del proveedor
    id_banco            DECIMAL(10,0)	    NOT NULL CHECK((id_banco >= 1 AND id_banco <= 9999999999)),                 -- Identificador (NIT) del banco  
    num_cuenta          VARCHAR             NOT NULL CHECK(LENGTH(num_cuenta) >= 10 AND LENGTH(num_cuenta) <= 16),      -- Número de cuenta bancaria
    ind_tipocuenta      BOOLEAN             NOT NULL DEFAULT FALSE,                                                     -- TRUE=Corriente / FALSE=Ahorros
    ind_ctapropia       BOOLEAN             NOT NULL DEFAULT FALSE,                                                     -- TRUE=Es cuenta propia de la empresa para pagar / FALSE=No es cuenta propia

    PRIMARY KEY         (id_proveedor,id_banco),
    FOREIGN KEY         (id_proveedor)      REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY         (id_banco)          REFERENCES public.tab_bancos(id_banco)
);

------------------------------------
--        TABLA DE FACTURAS       --
------------------------------------

CREATE TABLE IF NOT EXISTS tab_facturas
(
    id_factura          DECIMAL(8,0)        NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),       --Identificador de la factura
    id_proveedor        DECIMAL(10,0)       NOT NULL CHECK((id_proveedor) >= 1 AND (id_proveedor) <= 9999999999), --Identificador (NIT) del proveedor
    fec_emision         DATE                NOT NULL DEFAULT CURRENT_DATE,                                        --Fecha de emisión de la factura
    fec_vencimiento     DATE                NOT NULL,                                                             --Fecha de vencimiento de la factura
    val_factura         DECIMAL(10,0)       NOT NULL CHECK((val_factura) >= 0 AND (val_factura) <= 9999999999),   --Monto total de la factura
    val_saldo           DECIMAL(10,0)                CHECK(val_saldo >= 0),                                       --Valor restante para terminar de pagar la factura
    ind_estado          BOOLEAN             NOT NULL DEFAULT FALSE,                                               --TRUE = Pagado O FALSE = En deuda

    PRIMARY KEY         (id_factura),
    FOREIGN KEY         (id_proveedor)      REFERENCES tab_proveedores(id_proveedor)   
);

------------------------------------------------
--        TABLA DE PROGRAMACIÓN DE PAGOS      --
------------------------------------------------

CREATE TABLE IF NOT EXISTS tab_progpagos
(
    id_programacion     DECIMAL(10,0)   NOT NULL CHECK ((id_programacion) >= 1 AND (id_programacion) <= 9999999999),    -- Identificador de la programación del pago
    id_factura          DECIMAL(8,0)    NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                 -- Identificador de la factura
    descripcion         VARCHAR,                                                                                        -- Descripción de la programación de pagos
    fec_programada      DATE            NOT NULL DEFAULT CURRENT_DATE,                                                  -- Fecha en la que se realiza la programación del pago
    monto_programado    DECIMAL(9,0)    NOT NULL CHECK((monto_programado) >= 0 AND (monto_programado) <= 999999999),    -- Monto que se va a pagar en la programaci+on de pagos a cada factura
    num_cuota           DECIMAL(2,0)    NOT NULL CHECK((num_cuota) >= 0 AND (num_cuota) <= 99),                         -- Número de cuotas a pagar
    ind_estado_pago     BOOLEAN         NOT NULL,                                                                       -- Indicador que muestra si se realizó la programación de pago
    metodo_pago			DECIMAL(1,0)	NOT NULL CHECK((metodo_pago) >= 1 AND (metodo_pago) <= 4),                      -- Método de pago (Transferencia, cheque, contado o tarjeta)

    PRIMARY KEY         (id_programacion),
    FOREIGN KEY         (id_factura)      REFERENCES tab_facturas(id_factura) 
);

------------------------------------
--         TABLA DE PAGOS         --
------------------------------------

CREATE TABLE IF NOT EXISTS tab_pagos
(
    id_pago             INTEGER        		NOT NULL        CHECK((id_pago) >= 1),                                                       --Identificador del pago
    id_factura          DECIMAL(8,0)        NOT NULL        CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                       --Identificador de la factura                                                                                 
    fec_pago            DATE                NOT NULL        DEFAULT CURRENT_DATE,                                                        --Fecha de cuando se realizó el pago
	val_pagado			DECIMAL(9,0)        NOT NULL        CHECK((val_pagado) >= 1 AND (val_pagado) <= 999999999),                      --Valor que se pagó
    val_saldo        	DECIMAL(9,0)                        CHECK((val_saldo) >= 0 AND (val_saldo) <= 999999999),                        --Valor restante para terminar de pagar la factura
	num_cuota			DECIMAL(2,0)		NOT NULL		CHECK((num_cuota) >= 1 AND (num_cuota) <= 99),                               --Número de cuotas a las que se van a realizar los pagos
    ind_estado_pago     BOOLEAN             NOT NULL        DEFAULT FALSE,                                                               --TRUE = Pagado o FALSE = Pendiente
    id_proveedor	    DECIMAL(10,0)	    NOT NULL        CHECK((id_proveedor) >= 1 AND (id_proveedor) <= 9999999999),                 -- Identificador (NIT) del proveedor
    id_banco            DECIMAL(10,0)	    NOT NULL        CHECK((id_banco) >= 1 AND (id_banco) <= 9999999999),                         -- Identificador del banco       
	nom_autorizado_por	VARCHAR	            NOT NULL        CHECK(LENGTH(nom_autorizado_por) >= 2 AND LENGTH(nom_autorizado_por) <= 60), --Nombre de la persona que autoriza el pago 
	metodo_pago			DECIMAL(1,0)		NOT NULL		CHECK((metodo_pago) >= 1 AND (metodo_pago) <= 4),                            --Método de pago (Transferencia, cheque, contado o tarjeta)
    
    PRIMARY KEY         (id_pago),
    FOREIGN KEY         (id_factura)            REFERENCES tab_facturas(id_factura),
    FOREIGN KEY         (id_proveedor,id_banco) REFERENCES tab_bancoxprov(id_proveedor,id_banco)
);


--------------------------------------
-- MÓDULO DE GESTION DE CALIDAD
--------------------------------------

CREATE TABLE IF NOT EXISTS tab_pmtros
(
    id_parametro         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_parametro)) BETWEEN 1 AND 50),                      -- Identificador único del parámetro, utilizado para su referencia en la aplicación y en otros objetos de la base de datos.
    nom_parametro        VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_parametro)) BETWEEN 1 AND 100),                    -- Nombre descriptivo del parámetro, utilizado para su identificación y presentación en la interfaz de usuario.
    val_parametro        VARCHAR(255)               NOT NULL,                                                                               -- Valor del parámetro, almacenado como texto para permitir flexibilidad en el tipo de dato, pero con validaciones específicas según el tipo definido.
    tipo_dato            VARCHAR(20)                NOT NULL CHECK (tipo_dato IN ('STRING','NUMERO','FECHA','BOOLEANO','JSON','TEXTO')),    -- Tipo de dato del parámetro, utilizado para validar el formato del valor ingresado y para su correcta interpretación en la aplicación.
    categoria            VARCHAR(50)                NOT NULL CHECK (char_length(trim(categoria)) BETWEEN 1 AND 50),                         -- Categoría o módulo al que pertenece el parámetro, utilizado para organizar y clasificar los parámetros según su ámbito de aplicación.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del parámetro, utilizada para proporcionar información contextual sobre su propósito, uso o restricciones.
    ind_editable         BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador que determina si el parámetro puede ser editado a través de la interfaz de usuario, permitiendo proteger ciertos parámetros críticos o de configuración fija.                        
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador que determina si el parámetro está activo o inactivo, permitiendo deshabilitar temporalmente ciertos parámetros sin eliminarlos de la base de datos. 
    orden                DECIMAL(3,0)               NOT NULL DEFAULT 0 CHECK (orden >= 0),                                                  -- Campo numérico para definir el orden de presentación de los parámetros dentro de su categoría, facilitando la organización y usabilidad en la interfaz de usuario. 
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de parámetros sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.  
    PRIMARY KEY (id_parametro)                                                                                                              -- Clave primaria basada en el identificador único del parámetro, garantizando la integridad y unicidad de cada registro en la tabla de parámetros.
);
-- Índice para optimizar consultas por categoría y estado, criterios comunes
-- al momento de cargar parámetros activos por módulo o funcionalidad.
CREATE INDEX idx_pmtros_categoria ON tab_pmtros(categoria);
CREATE INDEX idx_pmtros_estado    ON tab_pmtros(ind_estado);
--------------------------------------------------------------------------------------------------------
-- TABLA NIVELES DE ACCESO
--------------------------------------------------------------------------------------------------------
-- Catálogo de niveles de acceso para clasificar la correspondencia y los expedientes
-- digitales, facilitando la aplicación de políticas de seguridad, control de acceso
-- y gestión de autorizaciones en función de la sensibilidad de la información.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_nivel_acceso
(
    id_nivel             DECIMAL(2,0)               NOT NULL CHECK (id_nivel BETWEEN 1 AND 5),                                              -- Identificador numérico del nivel de acceso, utilizado para establecer jerarquías y aplicar políticas de control de acceso basadas en niveles de sensibilidad.
    nom_nivel            VARCHAR(60)                NOT NULL CHECK (char_length(trim(nom_nivel)) BETWEEN 1 AND 60),                         -- Nombre descriptivo del nivel de acceso, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de los niveles de seguridad establecidos.
    any_descripcion      VARCHAR(255)               NOT NULL DEFAULT,                                                                       -- Descripción adicional del nivel de acceso, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de los niveles de seguridad en la gestión documental.                                        
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de niveles de acceso sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.    
    PRIMARY KEY (id_nivel)                                                                                                                  -- Clave primaria basada en el identificador numérico del nivel de acceso, garantizando la integridad y unicidad de cada registro en la tabla de niveles de acceso.
);
--------------------------------------------------------------------------------------------------------
-- TABLA ORÍGENES DE CORRESPONDENCIA
--------------------------------------------------------------------------------------------------------
-- Catálogo de canales o medios por los cuales se recibe la correspondencia,
-- para fines de trazabilidad y análisis estadístico.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_origen_correspondencia
(
    id_origen            DECIMAL(2,0)               NOT NULL CHECK (id_origen BETWEEN 1 AND 99),                                            -- Identificador numérico del origen de correspondencia, utilizado para clasificar y analizar los canales o medios por los cuales se recibe la correspondencia, facilitando la trazabilidad y el análisis estadístico de las fuentes de correspondencia.
    nom_origen           VARCHAR(60)                NOT NULL CHECK (char_length(trim(nom_origen)) BETWEEN 1 AND 60),                        -- Nombre descriptivo del origen de correspondencia, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de las fuentes de correspondencia establecidas.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del origen de correspondencia, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de los orígenes de correspondencia en la gestión documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de orígenes de correspondencia sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_origen)                                                                                                                 -- Clave primaria basada en el identificador numérico del origen de correspondencia, garantizando la integridad y unicidad de cada registro en la tabla de orígenes de correspondencia.
);
--------------------------------------------------------------------------------------------------------
-- TIPOS DE DOCUMENTO
--------------------------------------------------------------------------------------------------------
-- Catálogo de tipos de documento para clasificar la correspondencia y los expedientes
-- digitales, facilitando su gestión, búsqueda y aplicación de políticas de retención.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_documento
(
    id_tipo              DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 999),                                             -- Identificador numérico del tipo de documento, utilizado para clasificar y organizar la correspondencia y los expedientes digitales, facilitando su gestión, búsqueda y aplicación de políticas de retención basadas en el tipo de documento.
    nom_tipo             VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_tipo)) BETWEEN 1 AND 100),                         -- Nombre descriptivo del tipo de documento, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de los tipos de documento establecidos.
    cod_tipo             VARCHAR(10)                NOT NULL CHECK (char_length(trim(cod_tipo)) > 0),                                       -- Código alfanumérico del tipo de documento, utilizado para su referencia rápida y estandarizada en la aplicación, facilitando la clasificación y búsqueda de documentos según su código.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del tipo de documento, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de los tipos de documento en la gestión documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de tipos de documento sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_tipo),                                                                                                                  -- Clave primaria basada en el identificador numérico del tipo de documento, garantizando la integridad y unicidad de cada registro en la tabla de tipos de documento.
    CONSTRAINT uq_tipo_documento_cod UNIQUE (cod_tipo)                                                                                      -- Restricción de unicidad para el código del tipo de documento, garantizando que cada tipo de documento tenga un código único para su referencia rápida y estandarizada en la aplicación.   
);
--------------------------------------------------------------------------------------------------------
-- TABLA DE RETENCIÓN DOCUMENTAL (TRD)
--------------------------------------------------------------------------------------------------------
-- Definición de la tabla de retención documental para establecer las políticas
-- de conservación, archivo y eliminación de documentos y expedientes digitales.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tabla_retencion
(
    id_retencion          VARCHAR(50)               NOT NULL CHECK (char_length(trim(id_retencion)) BETWEEN 1 AND 50),                                                                                                 -- Identificador único de la tabla de retención documental, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de las políticas de retención asociadas a cada tipo de documento.  
    id_tipo               DECIMAL(3,0)              NOT NULL CHECK (id_tipo > 0),                                                                                                                                      -- Identificador del tipo de documento al que se aplica la política de retención, utilizado para establecer la relación entre la tabla de retención documental y el catálogo de tipos de documento, facilitando la aplicación de las políticas de retención basadas en el tipo de documento.                                               
    nom_serie             VARCHAR(150)              NOT NULL CHECK (char_length(trim(nom_serie)) BETWEEN 1 AND 150),                                                                                                   -- Nombre de la serie documental, utilizado para clasificar y organizar los documentos y expedientes digitales según su temática o función, facilitando su gestión, búsqueda y aplicación de políticas de retención basadas en la serie documental.
    nom_subserie          VARCHAR(150),                                                                                                                                                                                -- Nombre de la subserie documental, utilizado para una clasificación más detallada de los documentos y expedientes digitales dentro de una serie, facilitando su gestión, búsqueda y aplicación de políticas de retención basadas en la subserie documental.
    anos_archivo_gestion  DECIMAL(3,0)              NOT NULL DEFAULT 2  CHECK (anos_archivo_gestion  >= 0),                                                                                                            -- Años de conservación en el archivo de gestión, utilizado para definir el período durante el cual los documentos y expedientes digitales deben mantenerse en el archivo de gestión antes de ser transferidos al archivo central o eliminados, facilitando la aplicación de las políticas de retención basadas en los plazos establecidos para el archivo de gestión.
    anos_archivo_central  DECIMAL(3,0)              NOT NULL DEFAULT 8  CHECK (anos_archivo_central  >= 0),                                                                                                            -- Años de conservación en el archivo central, utilizado para definir el período durante el cual los documentos y expedientes digitales deben mantenerse en el archivo central antes de ser eliminados, facilitando la aplicación de las políticas de retención basadas en los plazos establecidos para el archivo central.
    disposicion_final     VARCHAR(20)               NOT NULL CHECK (disposicion_final IN ('CONSERVACION_TOTAL','ELIMINACION','SELECCION','DIGITALIZACION','MICROFILMACION')),                                          -- Disposición final del documento según la política de retención, utilizada para definir el destino final de los documentos y expedientes digitales una vez cumplidos los plazos de conservación establecidos en los archivos de gestión y central.
    soporte_fisico        BOOLEAN                   NOT NULL DEFAULT TRUE,                                                                                                                                             -- Indicador que determina si el documento o expediente digital debe conservarse en soporte físico según la política de retención, facilitando la aplicación de las políticas de retención basadas en el tipo de soporte requerido para la conservación de los documentos.
    soporte_electronico   BOOLEAN                   NOT NULL DEFAULT TRUE,                                                                                                                                             -- Indicador que determina si el documento o expediente digital debe conservarse en soporte electrónico según la política de retención, facilitando la aplicación de las políticas de retención basadas en el tipo de soporte requerido para la conservación de los documentos.
    any_descripcion       VARCHAR(255),                                                                                                                                                                                -- Descripción adicional de la tabla de retención documental, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de las políticas de retención en la gestión documental.
    ind_borrado           BOOLEAN                   NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de retención documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_retencion),                                                                                                                                                                                        -- Clave primaria basada en el identificador único de la tabla de retención documental, garantizando la integridad y unicidad de cada registro en la tabla de retención documental.
    FOREIGN KEY (id_tipo) REFERENCES tab_tipo_documento(id_tipo)                                                                                                                                                -- Clave foránea que establece la relación entre la tabla de retención documental y el catálogo de tipos de documento, garantizando la integridad referencial y facilitando la aplicación de las políticas de retención basadas en el tipo de documento.
);
-- Índice para optimizar consultas por tipo de documento en la tabla de retención documental.
CREATE INDEX idx_trd_tipo ON tab_tabla_retencion(id_tipo);
--------------------------------------------------------------------------------------------------------
-- ESTADOS DE CORRESPONDENCIA
--------------------------------------------------------------------------------------------------------
-- Catálogo de estados para la gestión del ciclo de vida de la correspondencia, facilitando
-- su seguimiento, análisis estadístico y aplicación de políticas de atención y respuesta.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_correspondencia
(
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 99),                                            -- Identificador numérico del estado de correspondencia, utilizado para clasificar y organizar la correspondencia según su estado en el ciclo de vida, facilitando su seguimiento, análisis estadístico y aplicación de políticas de atención y respuesta basadas en el estado de la correspondencia.
    val_estado           VARCHAR(60)                NOT NULL CHECK (char_length(trim(val_estado)) BETWEEN 1 AND 60),                        -- Valor descriptivo del estado de correspondencia, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de los estados de correspondencia establecidos.  
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del estado de correspondencia, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de los estados de correspondencia en la gestión documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de estados de correspondencia sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_estado)                                                                                                                 -- Clave primaria basada en el identificador numérico del estado de correspondencia, garantizando la integridad y unicidad de cada registro en la tabla de estados de correspondencia.
);
--------------------------------------------------------------------------------------------------------
-- ACCIONES DE WORKFLOW DOCUMENTAL
--------------------------------------------------------------------------------------------------------
-- Catálogo de acciones que pueden realizarse en el flujo de trabajo documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_accion_workflow_doc
(
    id_accion            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_accion)) BETWEEN 1 AND 50),                         -- Identificador único de la acción de workflow documental, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de las acciones disponibles en el flujo de trabajo documental.
    nom_accion           VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_accion)) BETWEEN 1 AND 100),                       -- Nombre descriptivo de la acción de workflow documental, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de las acciones disponibles en el flujo de trabajo documental.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional de la acción de workflow documental, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas, facilitando la correcta aplicación de las acciones en el flujo de trabajo documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de acciones de workflow documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_accion)                                                                                                                 -- Clave primaria basada en el identificador único de la acción de workflow documental, garantizando la integridad y unicidad de cada registro en la tabla de acciones de workflow documental.
);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA INDEXACIÓN (DETALLE CORRESPONDENCIA)
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada registro de indexación 
-- en el detalle de correspondencia.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_indexacion START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- ENCABEZADO DE CORRESPONDENCIA
--------------------------------------------------------------------------------------------------------
-- Tabla principal que registra la información básica de cada correspondencia recibida.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_correspondencia
(
    id_correspondencia      VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_correspondencia)) BETWEEN 1 AND 50),             -- Identificador único de la correspondencia, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de la correspondencia recibida.
    num_radicado            VARCHAR(20)                NOT NULL CHECK (char_length(trim(num_radicado)) BETWEEN 1 AND 20),                   -- Número de radicado asignado a la correspondencia, utilizado para su identificación y seguimiento en el proceso de gestión documental, facilitando la trazabilidad y el análisis estadístico de la correspondencia recibida.
    id_tipo                 DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 999),                                          -- Identificador del tipo de documento asociado a la correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de tipos de documento, facilitando la clasificación y aplicación de políticas de retención basadas en el tipo de documento.
    id_origen               DECIMAL(2,0)               NOT NULL CHECK (id_origen BETWEEN 1 AND 99),                                         -- Identificador del origen de correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de orígenes de correspondencia, facilitando la clasificación y análisis estadístico de las fuentes de correspondencia.
    id_estado               DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 99),                                         -- Identificador del estado de correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de estados de correspondencia, facilitando su seguimiento, análisis estadístico y aplicación de políticas de atención y respuesta basadas en el estado de la correspondencia.
    id_nivel_acceso         DECIMAL(2,0)               NOT NULL CHECK (id_nivel_acceso BETWEEN 1 AND 5),                                    -- Identificador del nivel de acceso asociado a la correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de niveles de acceso, facilitando la aplicación de políticas de seguridad, control de acceso y gestión de autorizaciones en función de la sensibilidad de la información contenida en la correspondencia.
    id_retencion            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_retencion)) BETWEEN 1 AND 50),                   -- Identificador de la tabla de retención documental asociada a la correspondencia, utilizado para establecer la relación entre la correspondencia y las políticas de retención definidas en la tabla de retención documental, facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de documento asociado a la correspondencia.
    nom_remitente           VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_remitente)) BETWEEN 1 AND 255),                 -- Nombre del remitente de la correspondencia, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la procedencia de la correspondencia recibida.
    ent_remitente           VARCHAR(255),                                                                                                   -- Entidad o institución del remitente de la correspondencia, utilizada para proporcionar información adicional sobre la procedencia de la correspondencia recibida, facilitando su identificación y análisis estadístico.
    asunto                  VARCHAR(500)               NOT NULL CHECK (char_length(trim(asunto)) BETWEEN 1 AND 500),                        -- Asunto o descripción breve de la correspondencia, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido o propósito de la correspondencia recibida.
    fec_documento           DATE                       NOT NULL CHECK (fec_documento <= CURRENT_DATE),                                      -- Fecha del documento asociado a la correspondencia, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad de la correspondencia recibida y su relación con otros documentos o eventos.
    fec_recepcion           TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                              -- Fecha y hora de recepción de la correspondencia, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad de la correspondencia recibida y su relación con otros documentos o eventos.
    fec_limite_respuesta    TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT NOW() + INTERVAL '15 days',                                         -- Fecha límite para la respuesta de la correspondencia, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los plazos de atención y respuesta establecidos para la correspondencia recibida.
    ind_fisico              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                              -- Indicador que determina si la correspondencia se encuentra en formato físico, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del formato de la correspondencia recibida y su relación con los procesos de gestión documental asociados al formato físico.
    id_area_destino         DECIMAL(5,0)               NOT NULL CHECK (id_area_destino > 0),                                                -- Identificador del área de destino de la correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de áreas, facilitando la clasificación y gestión de la correspondencia según el área responsable de su atención y respuesta.
    id_tercero              VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_tercero)) BETWEEN 1 AND 20),                     -- Identificador del tercero asociado a la correspondencia, utilizado para establecer la relación entre la correspondencia y el catálogo de terceros, facilitando la clasificación y gestión de la correspondencia según el tercero involucrado en su atención y respuesta.
    ind_borrado             BOOLEAN                    NOT NULL DEFAULT FALSE,                                                              -- Indicador de borrado lógico para permitir la eliminación suave de acciones de workflow documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este catálogo.
    PRIMARY KEY (id_correspondencia),                                                                                                       -- Clave primaria basada en el identificador único de la correspondencia, garantizando la integridad y unicidad de cada registro en la tabla de encabezado de correspondencia.
    CONSTRAINT uq_enc_corr_radicado UNIQUE (num_radicado),                                                                                  -- Restricción de unicidad para el número de radicado, garantizando que cada correspondencia tenga un número de radicado único para su identificación y seguimiento en el proceso de gestión documental.
    FOREIGN KEY (id_tipo)          REFERENCES tab_tipo_documento(id_tipo),                                                           -- Clave foránea que establece la relación entre la correspondencia y el catálogo de tipos de documento, garantizando la integridad referencial y facilitando la clasificación y aplicación de políticas de retención basadas en el tipo de documento asociado a la correspondencia.
    FOREIGN KEY (id_origen)        REFERENCES tab_origen_correspondencia(id_origen),                                                 -- Clave foránea que establece la relación entre la correspondencia y el catálogo de orígenes de correspondencia, garantizando la integridad referencial y facilitando la clasificación y análisis estadístico de las fuentes de correspondencia.
    FOREIGN KEY (id_estado)        REFERENCES tab_estado_correspondencia(id_estado),                                                 -- Clave foránea que establece la relación entre la correspondencia y el catálogo de estados de correspondencia, garantizando la integridad referencial y facilitando su seguimiento, análisis estadístico y aplicación de políticas de atención y respuesta basadas en el estado de la correspondencia.
    FOREIGN KEY (id_nivel_acceso)  REFERENCES tab_nivel_acceso(id_nivel),                                                            -- Clave foránea que establece la relación entre la correspondencia y el catálogo de niveles de acceso, garantizando la integridad referencial y facilitando la aplicación de políticas de seguridad, control de acceso y gestión de autorizaciones en función de la sensibilidad de la información contenida en la correspondencia.
    FOREIGN KEY (id_retencion)     REFERENCES tab_tabla_retencion(id_retencion),                                                     -- Clave foránea que establece la relación entre la correspondencia y la tabla de retención documental, garantizando la integridad referencial y facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de documento asociado a la correspondencia.
    FOREIGN KEY (id_area_destino)  REFERENCES public.tab_areas(id_area),                                                                    -- Clave foránea que establece la relación entre la correspondencia y el catálogo de áreas, garantizando la integridad referencial y facilitando la clasificación y gestión de la correspondencia según el área responsable de su atención y respuesta.
    FOREIGN KEY (id_tercero)       REFERENCES public.tab_terceros(id_tercero)                                                               -- Clave foránea que establece la relación entre la correspondencia y el catálogo de terceros, garantizando la integridad referencial y facilitando la clasificación y gestión de la correspondencia según el tercero involucrado en su atención y respuesta.
);
-- Índices para optimizar consultas frecuentes en la tabla de correspondencia.
CREATE INDEX idx_enc_corr_estado           ON tab_enc_correspondencia(id_estado);
CREATE INDEX idx_enc_corr_area             ON tab_enc_correspondencia(id_area_destino);
CREATE INDEX idx_enc_corr_recepcion        ON tab_enc_correspondencia(fec_recepcion);
CREATE INDEX idx_enc_corr_radicado         ON tab_enc_correspondencia(num_radicado);
CREATE INDEX idx_enc_corr_limite_respuesta ON tab_enc_correspondencia(fec_limite_respuesta) WHERE fec_limite_respuesta IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- DETALLE DE CORRESPONDENCIA (INDEXACIÓN)
--------------------------------------------------------------------------------------------------------
-- Información detallada de cada documento dentro de la correspondencia.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_correspondencia
(
    id_indexacion        DECIMAL(10,0)              NOT NULL DEFAULT nextval('seq_indexacion'),                                      -- Identificador único de la indexación, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de la información detallada de cada documento dentro de la correspondencia.
    id_correspondencia   VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_correspondencia)) BETWEEN 1 AND 50),                -- Identificador de la correspondencia a la que pertenece el documento indexado, utilizado para establecer la relación entre el detalle de correspondencia y el encabezado de correspondencia, facilitando la gestión de la información detallada de cada documento dentro de la correspondencia.
    num_folio            INTEGER                    NOT NULL CHECK (num_folio >= 1),                                                        -- Número de folio del documento dentro de la correspondencia, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la secuencia y organización de los documentos dentro de la correspondencia.
    num_version          INTEGER                    NOT NULL DEFAULT 1 CHECK (num_version >= 1),                                            -- Número de versión del documento indexado, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de las diferentes versiones de los documentos dentro de la correspondencia.
    palabras_clave       VARCHAR(500),                                                                                                      -- Palabras clave asociadas al documento indexado, utilizadas para su identificación y presentación en la interfaz de usuario, facilitando la búsqueda y recuperación de los documentos dentro de la correspondencia en función de las palabras clave asociadas.
    id_retencion         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_retencion)) BETWEEN 1 AND 50),                      -- Identificador de la tabla de retención documental asociada al documento indexado, utilizado para establecer la relación entre el detalle de correspondencia y las políticas de retención definidas en la tabla de retención documental, facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de documento asociado a cada documento indexado dentro de la correspondencia.
    cod_clasificacion    VARCHAR(50),                                                                                                       -- Código de clasificación asociado al documento indexado, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y organización de los documentos dentro de la correspondencia en función de su código de clasificación.
    fec_indexacion       TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                 -- Fecha y hora de indexación del documento, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la trazabilidad y auditoría de las acciones realizadas sobre el documento indexado dentro de la correspondencia.
    observaciones        VARCHAR(500),                                                                                                      -- Observaciones adicionales sobre el documento indexado, utilizadas para proporcionar información contextual sobre el contenido, características o restricciones asociadas al documento, facilitando su identificación y análisis estadístico dentro de la correspondencia.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en el detalle de correspondencia sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan este detalle.
    PRIMARY KEY (id_indexacion),                                                                                                            -- Clave primaria basada en el identificador único de la indexación, garantizando la integridad y unicidad de cada registro en la tabla de detalle de correspondencia.
    FOREIGN KEY (id_correspondencia) REFERENCES tab_enc_correspondencia(id_correspondencia),                                         -- Clave foránea que establece la relación entre el detalle de correspondencia y el encabezado de correspondencia, garantizando la integridad referencial y facilitando la gestión de la información detallada de cada documento dentro de la correspondencia.
    FOREIGN KEY (id_retencion)       REFERENCES tab_tabla_retencion(id_retencion)                                                    -- Clave foránea que establece la relación entre el detalle de correspondencia y la tabla de retención documental, garantizando la integridad referencial y facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de documento asociado a cada documento indexado dentro de la correspondencia.
);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA ARCHIVO DIGITAL
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada archivo digital asociado 
-- a los documentos de la correspondencia.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_archivo_digital START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- ARCHIVO DIGITAL
--------------------------------------------------------------------------------------------------------
-- Tabla para almacenar la información de los archivos digitales asociados a cada
-- documento de la correspondencia, incluyendo metadatos técnicos y de gestión.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_archivo_digital
(
    id_archivo           DECIMAL(10,0)              NOT NULL DEFAULT nextval('seq_archivo_digital'),                                 -- Identificador único del archivo digital, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de los archivos digitales asociados a los documentos de la correspondencia.
    id_indexacion        DECIMAL(10,0)              NOT NULL,                                                                               -- Identificador de la indexación a la que pertenece el archivo digital, utilizado para establecer la relación entre el archivo digital y el detalle de correspondencia, facilitando la gestión de los archivos digitales asociados a cada documento de la correspondencia.
    nom_archivo          VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_archivo)) > 0),                                    -- Nombre del archivo digital, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido o propósito del archivo digital asociado a cada documento de la correspondencia.
    url_acceso           VARCHAR(500),                                                                                                      -- URL de acceso al archivo digital, utilizada para su identificación y acceso en el sistema de gestión documental, facilitando la localización y recuperación de los archivos digitales asociados a cada documento de la correspondencia a través de enlaces directos.
    tamano_bytes         BIGINT                     CHECK (tamano_bytes IS NULL OR tamano_bytes > 0),                                       -- Tamaño del archivo digital en bytes, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la magnitud del archivo digital asociado a cada documento de la correspondencia.
    ind_original_fisico  BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador que determina si el archivo digital es una copia de un documento físico original, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del origen del archivo digital asociado a cada documento de la correspondencia.
    fec_digitalizacion   TIMESTAMP WITH TIME ZONE,                                                                                          -- Fecha y hora de digitalización del documento, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la trazabilidad y auditoría de las acciones realizadas sobre el archivo digital asociado a cada documento de la correspondencia.
    num_paginas          INTEGER                    CHECK (num_paginas IS NULL OR num_paginas > 0),                                         -- Número de páginas del documento digitalizado, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la extensión del documento asociado a cada archivo digital dentro de la correspondencia.                                          
    resolucion_dpi       INTEGER                    CHECK (resolucion_dpi IS NULL OR resolucion_dpi > 0),                                   -- Resolución en DPI del documento digitalizado, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la calidad del documento asociado a cada archivo digital dentro de la correspondencia.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de archivos digitales sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_archivo),                                                                                                               -- Clave primaria basada en el identificador único del archivo digital, garantizando la integridad y unicidad de cada registro en la tabla de archivos digitales.
    FOREIGN KEY (id_indexacion) REFERENCES tab_det_correspondencia(id_indexacion)                                                    -- Clave foránea que establece la relación entre el archivo digital y el detalle de correspondencia, garantizando la integridad referencial y facilitando la gestión de los archivos digitales asociados a cada documento de la correspondencia.
);
-- Índices para optimizar consultas frecuentes en la tabla de archivos digitales.
CREATE INDEX idx_archivo_indexacion ON tab_archivo_digital(id_indexacion);
CREATE INDEX idx_archivo_mime       ON tab_archivo_digital(tipo_mime);
--------------------------------------------------------------------------------------------------------
-- EXPEDIENTES DIGITALES
--------------------------------------------------------------------------------------------------------
-- Tabla para gestionar los expedientes digitales que agrupan y organizan
-- la correspondencia y los documentos relacionados.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_expediente
(
    id_expediente        VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_expediente)) BETWEEN 1 AND 50),                     -- Identificador único del expediente digital, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de los expedientes digitales que agrupan y organizan la correspondencia y los documentos relacionados.  
    nom_expediente       VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_expediente)) BETWEEN 1 AND 255),                   -- Nombre del expediente digital, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido o propósito del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados.
    cod_expediente       VARCHAR(30)                NOT NULL CHECK (char_length(trim(cod_expediente)) BETWEEN 1 AND 30),                    -- Código del expediente digital, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido o propósito del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, así como su clasificación y organización en función de su código.
    id_tipo              DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 999),                                             -- Identificador del tipo de expediente digital, utilizado para establecer la relación entre el expediente digital y el catálogo de tipos de documento, facilitando la clasificación y aplicación de políticas de retención basadas en el tipo de expediente digital.               
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                                           -- Identificador del área responsable del expediente digital, utilizado para establecer la relación entre el expediente digital y el catálogo de áreas, facilitando la clasificación y gestión de los expedientes digitales según el área responsable de su atención y respuesta.
    id_nivel_acceso      DECIMAL(2,0)               NOT NULL CHECK (id_nivel_acceso BETWEEN 1 AND 5),                                       -- Identificador del nivel de acceso asociado al expediente digital, utilizado para establecer la relación entre el expediente digital y el catálogo de niveles de acceso, facilitando la aplicación de políticas de seguridad, control de acceso y gestión de autorizaciones en función de la sensibilidad de la información contenida en el expediente digital.
    id_retencion         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_retencion)) BETWEEN 1 AND 50),                      -- Identificador de la tabla de retención documental asociada al expediente digital, utilizado para establecer la relación entre el expediente digital y las políticas de retención definidas en la tabla de retención documental, facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de expediente digital.
    fec_apertura         DATE                       NOT NULL CHECK (fec_apertura <= CURRENT_DATE),                                          -- Fecha de apertura del expediente digital, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados.
    fec_cierre           DATE                                CHECK (fec_cierre IS NULL OR fec_cierre >= fec_apertura),                      -- Fecha de cierre del expediente digital, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, así como su estado de apertura o cierre.
    fec_disposicion      DATE                                CHECK (fec_disposicion IS NULL OR fec_disposicion >= fec_apertura),            -- Fecha de disposición final del expediente digital, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, así como su estado en el ciclo de vida documental.
    ind_activo           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador que determina si el expediente digital se encuentra activo, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del estado del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, así como su inclusión o exclusión en los procesos de gestión documental asociados a los expedientes digitales activos.
    resumen              VARCHAR(500),                                                                                                      -- Resumen o descripción adicional del expediente digital, utilizado para proporcionar información contextual sobre el contenido o propósito del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, facilitando su identificación y análisis estadístico.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del expediente digital, utilizada para proporcionar información contextual sobre el contenido o propósito del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, facilitando su identificación y análisis estadístico.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de expedientes digitales sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_expediente),                                                                                                            -- Clave primaria basada en el identificador único del expediente digital, garantizando la integridad y unicidad de cada registro en la tabla de expedientes digitales.
    CONSTRAINT uq_expediente_cod UNIQUE (cod_expediente),                                                                                   -- Restricción de unicidad para el código del expediente digital, garantizando que cada expediente digital tenga un código único para su identificación y clasificación en la interfaz de usuario, facilitando la comprensión del contenido o propósito del expediente digital que agrupa y organiza la correspondencia y los documentos relacionados, así como su clasificación y organización en función de su código.
    FOREIGN KEY (id_tipo)         REFERENCES tab_tipo_documento(id_tipo),                                                            -- Clave foránea que establece la relación entre el expediente digital y el catálogo de tipos de documento, garantizando la integridad referencial y facilitando la clasificación y aplicación de políticas de retención basadas en el tipo de expediente digital.
    FOREIGN KEY (id_area)         REFERENCES public.tab_areas(id_area),                                                                     -- Clave foránea que establece la relación entre el expediente digital y el catálogo de áreas, garantizando la integridad referencial y facilitando la clasificación y gestión de los expedientes digitales según el área responsable de su atención y respuesta.
    FOREIGN KEY (id_nivel_acceso) REFERENCES tab_nivel_acceso(id_nivel),                                                             -- Clave foránea que establece la relación entre el expediente digital y el catálogo de niveles de acceso, garantizando la integridad referencial y facilitando la aplicación de políticas de seguridad, control de acceso y gestión de autorizaciones en función de la sensibilidad de la información contenida en el expediente digital.
    FOREIGN KEY (id_retencion)    REFERENCES tab_tabla_retencion(id_retencion)                                                       -- Clave foránea que establece la relación entre el expediente digital y la tabla de retención documental, garantizando la integridad referencial y facilitando la aplicación de las políticas de conservación, archivo y eliminación basadas en el tipo de expediente digital.
);
-- Índices para optimizar consultas frecuentes en la tabla de expedientes digitales.
CREATE INDEX idx_expediente_area   ON tab_expediente(id_area);
CREATE INDEX idx_expediente_activo ON tab_expediente(ind_activo);
CREATE INDEX idx_expediente_cod    ON tab_expediente(cod_expediente);
--------------------------------------------------------------------------------------------------------
-- RELACIÓN DOCUMENTO–EXPEDIENTE
--------------------------------------------------------------------------------------------------------
-- Tabla intermedia para establecer la relación entre los documentos de correspondencia
-- y los expedientes digitales, permitiendo la organización y agrupación de la 
-- información documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_expediente
(
    id_expediente        VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_expediente)) BETWEEN 1 AND 50),                     -- Identificador del expediente digital al que se asocia el documento de correspondencia, utilizado para establecer la relación entre el documento de correspondencia y el expediente digital, facilitando la organización y agrupación de la información documental.
    id_correspondencia   VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_correspondencia)) BETWEEN 1 AND 50),                -- Identificador de la correspondencia a la que se asocia el expediente digital, utilizado para establecer la relación entre el documento de correspondencia y el expediente digital, facilitando la organización y agrupación de la información documental.
    num_orden            INTEGER                    NOT NULL CHECK (num_orden >= 1),                                                        -- Número de orden para establecer la secuencia de los documentos dentro del expediente digital, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la secuencia y organización de los documentos dentro del expediente digital.
    fec_incorporacion    TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                 -- Fecha y hora de incorporación del documento de correspondencia al expediente digital, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la trazabilidad y auditoría de las acciones realizadas sobre el documento de correspondencia dentro del expediente digital.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional de la relación entre el documento de correspondencia y el expediente digital, utilizada para proporcionar información contextual sobre la asociación entre el documento y el expediente, facilitando su identificación y análisis estadístico dentro del contexto del expediente digital.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de relación documento-expediente sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_expediente, id_correspondencia),                                                                                        -- Clave primaria compuesta basada en el identificador del expediente digital y el identificador de la correspondencia, garantizando la integridad y unicidad de cada registro en la tabla de relación documento-expediente.
    FOREIGN KEY (id_expediente)      REFERENCES tab_expediente(id_expediente),                                                       -- Clave foránea que establece la relación entre el documento de correspondencia y el expediente digital, garantizando la integridad referencial y facilitando la organización y agrupación de la información documental.
    FOREIGN KEY (id_correspondencia) REFERENCES tab_enc_correspondencia(id_correspondencia)                                          -- Clave foránea que establece la relación entre el documento de correspondencia y el expediente digital, garantizando la integridad referencial y facilitando la organización y agrupación de la información documental.
);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA PERMISOS DE ACCESO
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada permiso de acceso asignado 
-- a usuarios sobre expedientes o correspondencia, facilitando la gestión de 
-- autorizaciones y roles.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_permiso_acceso START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- PERMISOS DE ACCESO
--------------------------------------------------------------------------------------------------------
-- Tabla para gestionar los permisos de acceso que los usuarios tienen sobre los 
-- expedientes y la correspondencia, permitiendo definir niveles de autorización 
-- y control de acceso a la información documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_permiso_acceso
(
    id_permiso           DECIMAL(12,0)              NOT NULL DEFAULT nextval('seq_permiso_acceso'),                                                                                                             -- Identificador único del permiso de acceso, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de los permisos de acceso asignados a usuarios sobre expedientes o correspondencia.
    id_expediente        VARCHAR(50),                                                                                                                                                                                  -- Identificador del expediente digital al que se asigna el permiso de acceso, utilizado para establecer la relación entre el permiso de acceso y el expediente digital, facilitando la gestión de autorizaciones y roles sobre los expedientes digitales.
    id_correspondencia   VARCHAR(50),                                                                                                                                                                                  -- Identificador de la correspondencia al que se asigna el permiso de acceso, utilizado para establecer la relación entre el permiso de acceso y la correspondencia, facilitando la gestión de autorizaciones y roles sobre la correspondencia.
    id_usuario           VARCHAR(60),                                                                                                                                                                                  -- Identificador del usuario al que se asigna el permiso de acceso, utilizado para establecer la relación entre el permiso de acceso y el usuario, facilitando la gestión de autorizaciones y roles sobre los expedientes digitales y la correspondencia.
    val_permiso          VARCHAR(20)                NOT NULL CHECK (val_permiso IN ('LECTURA','ESCRITURA','APROBACION','ELIMINACION','ADMIN')),                                                                        -- Valor del permiso de acceso asignado al usuario, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del nivel de autorización y control de acceso que el usuario tiene sobre los expedientes digitales o la correspondencia a los que se le asigna el permiso de acceso.
    fec_inicio           DATE                       NOT NULL DEFAULT CURRENT_DATE,                                                                                                                                     -- Fecha de inicio de vigencia del permiso de acceso, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad del permiso de acceso asignado al usuario sobre los expedientes digitales o la correspondencia.
    fec_fin              DATE                                CHECK (fec_fin IS NULL OR fec_fin >= fec_inicio),                                                                                                         -- Fecha de fin de vigencia del permiso de acceso, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de la temporalidad del permiso de acceso asignado al usuario sobre los expedientes digitales o la correspondencia, así como su estado de vigencia.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional del permiso de acceso, utilizada para proporcionar información contextual sobre el nivel de autorización y control de acceso que el usuario tiene sobre los expedientes digitales o la correspondencia a los que se le asigna el permiso de acceso, facilitando su identificación y análisis estadístico.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de permisos de acceso sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_permiso),                                                                                                                                                                                          -- Clave primaria basada en el identificador único del permiso de acceso, garantizando la integridad y unicidad de cada registro en la tabla de permisos de acceso.
    CONSTRAINT chk_permiso_un_recurso CHECK ((CASE WHEN id_expediente IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_correspondencia IS NOT NULL THEN 1 ELSE 0 END) = 1),                                              -- Restricción para garantizar que el permiso de acceso esté asociado a un único recurso, ya sea un expediente digital o una correspondencia, evitando ambigüedades en la asignación de permisos y facilitando la gestión de autorizaciones y roles sobre los expedientes digitales y la correspondencia.
    FOREIGN KEY (id_expediente)      REFERENCES tab_expediente(id_expediente),                                                                                                                                  -- Clave foránea que establece la relación entre el permiso de acceso y el expediente digital, garantizando la integridad referencial y facilitando la gestión de autorizaciones y roles sobre los expedientes digitales.
    FOREIGN KEY (id_correspondencia) REFERENCES tab_enc_correspondencia(id_correspondencia),                                                                                                                    -- Clave foránea que establece la relación entre el permiso de acceso y la correspondencia, garantizando la integridad referencial y facilitando la gestión de autorizaciones y roles sobre la correspondencia.
    FOREIGN KEY (id_usuario)         REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                        -- Clave foránea que establece la relación entre el permiso de acceso y el usuario, garantizando la integridad referencial y facilitando la gestión de autorizaciones y roles sobre los expedientes digitales y la correspondencia.
);
-- Índices para optimizar consultas frecuentes en la tabla de permisos de acceso.
CREATE INDEX idx_permiso_usuario ON tab_permiso_acceso(id_usuario);
CREATE INDEX idx_permiso_expediente ON tab_permiso_acceso(id_expediente);
CREATE INDEX idx_permiso_correspondencia ON tab_permiso_acceso(id_correspondencia);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA WORKFLOW EXPEDIENTES
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada registro de workflow de expedientes,
-- facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes
-- digitales, incluyendo cambios de estado, acciones realizadas, usuarios involucrados y comentarios,
-- permitiendo garantizar un control efectivo sobre el ciclo de vida de los expedientes y la
-- correspondencia asociada.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_workflow_expediente START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- WORKFLOW DE EXPEDIENTES
--------------------------------------------------------------------------------------------------------
-- Tabla para gestionar el flujo de trabajo de los expedientes digitales, 
-- registrando cada acción realizada, los cambios de estado, los usuarios involucrados 
-- y los comentarios asociados, permitiendo garantizar un control efectivo sobre 
-- el ciclo de vida de los expedientes y la correspondencia asociada, así como 
-- facilitar la trazabilidad y auditoría de las acciones realizadas.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_workflow_expediente
(
    id_workflow          DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_workflow_expediente'),                                                                                                        -- Identificador único del registro de workflow de expediente, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de las acciones realizadas sobre los expedientes digitales, incluyendo cambios de estado, acciones realizadas, usuarios involucrados y comentarios, permitiendo garantizar un control efectivo sobre el ciclo de vida de los expedientes y la correspondencia asociada.
    id_expediente        VARCHAR(50),                                                                                                                                                                                  -- Identificador del expediente digital al que se asocia el registro de workflow, utilizado para establecer la relación entre el registro de workflow y el expediente digital, facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes digitales, así como el control efectivo sobre su ciclo de vida.
    id_correspondencia   VARCHAR(50),                                                                                                                                                                                  -- Identificador de la correspondencia al que se asocia el registro de workflow, utilizado para establecer la relación entre el registro de workflow y la correspondencia, facilitando la trazabilidad y auditoría de las acciones realizadas sobre la correspondencia, así como el control efectivo sobre su ciclo de vida.
    id_accion            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_accion)) > 0),                                                                                                                 -- Identificador de la acción realizada en el workflow, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de las acciones realizadas.
    id_estado_origen     DECIMAL(2,0)               NOT NULL CHECK (id_estado_origen  BETWEEN 1 AND 99),                                                                                                               -- Identificador del estado de origen del expediente digital o la correspondencia antes de la acción realizada, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de los estados de origen.
    id_estado_destino    DECIMAL(2,0)               NOT NULL CHECK (id_estado_destino BETWEEN 1 AND 99),                                                                                                               -- Identificador del estado de destino del expediente digital o la correspondencia después de la acción realizada, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de los estados de destino.
    id_usuario           VARCHAR(60)                NOT NULL,                                                                                                                                                          -- Identificador del usuario que realiza la acción en el workflow, utilizado para establecer la relación entre el registro de workflow y el usuario, facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes digitales y la correspondencia, así como el control efectivo sobre su ciclo de vida.
    any_comentario       TEXT,                                                                                                                                                                                         -- Comentarios adicionales sobre la acción realizada en el workflow, utilizados para proporcionar información contextual sobre el proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, facilitando su identificación y análisis estadístico en función de los comentarios asociados a las acciones realizadas.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de workflow de expedientes sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_workflow),                                                                                                                                                                                         -- Clave primaria basada en el identificador único del registro de workflow de expediente, garantizando la integridad y unicidad de cada registro en la tabla de workflow de expedientes.
    CONSTRAINT chk_workflow_un_recurso CHECK ((CASE WHEN id_expediente IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_correspondencia IS NOT NULL THEN 1 ELSE 0 END) = 1),                                             -- Restricción para garantizar que el registro de workflow esté asociado a un único recurso, ya sea un expediente digital o una correspondencia, evitando ambigüedades en la asignación de las acciones de workflow y facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes digitales y la correspondencia.
    FOREIGN KEY (id_expediente)      REFERENCES tab_expediente(id_expediente),                                                                                                                                  -- Clave foránea que establece la relación entre el registro de workflow y el expediente digital, garantizando la integridad referencial y facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes digitales, así como el control efectivo sobre su ciclo de vida.
    FOREIGN KEY (id_correspondencia) REFERENCES tab_enc_correspondencia(id_correspondencia),                                                                                                                    -- Clave foránea que establece la relación entre el registro de workflow y la correspondencia, garantizando la integridad referencial y facilitando la trazabilidad y auditoría de las acciones realizadas sobre la correspondencia, así como el control efectivo sobre su ciclo de vida.
    FOREIGN KEY (id_accion)          REFERENCES tab_accion_workflow_doc(id_accion),                                                                                                                             -- Clave foránea que establece la relación entre el registro de workflow y la tabla de acciones de workflow documental, garantizando la integridad referencial y facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de las acciones realizadas.
    FOREIGN KEY (id_estado_origen)   REFERENCES tab_estado_correspondencia(id_estado),                                                                                                                          -- Clave foránea que establece la relación entre el registro de workflow y la tabla de estados de correspondencia para el estado de origen, garantizando la integridad referencial y facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de los estados de origen.
    FOREIGN KEY (id_estado_destino)  REFERENCES tab_estado_correspondencia(id_estado),                                                                                                                          -- Clave foránea que establece la relación entre el registro de workflow y la tabla de estados de correspondencia para el estado de destino, garantizando la integridad referencial y facilitando la comprensión del proceso de gestión documental aplicado sobre el expediente digital o la correspondencia, así como su clasificación y análisis estadístico en función de los estados de destino.
    FOREIGN KEY (id_usuario)         REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                        -- Clave foránea que establece la relación entre el registro de workflow y el usuario que realiza la acción, garantizando la integridad referencial y facilitando la trazabilidad y auditoría de las acciones realizadas sobre los expedientes digitales y la correspondencia, así como el control efectivo sobre su ciclo de vida.
);
-- Índices para optimizar consultas frecuentes en la tabla de workflow de expedientes.
CREATE INDEX idx_wf_expediente      ON tab_workflow_expediente(id_expediente)      WHERE id_expediente IS NOT NULL;
CREATE INDEX idx_wf_correspondencia ON tab_workflow_expediente(id_correspondencia) WHERE id_correspondencia IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- TIPOS DE PQRS
--------------------------------------------------------------------------------------------------------
-- Catálogo de tipos de Peticiones, Quejas, Reclamos, Sugerencias y Felicitaciones (PQRS)
-- para clasificar y gestionar las solicitudes recibidas, facilitando su seguimiento, 
-- análisis estadístico y aplicación de políticas de atención y respuesta.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_pqrs
(
    id_tipo_pqrs         DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 99),                                         -- Identificador del tipo de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los tipos de PQRS definidos.
    nom_tipo_pqrs        VARCHAR(60)                NOT NULL CHECK (char_length(trim(nom_tipo_pqrs)) BETWEEN 1 AND 60),                     -- Nombre del tipo de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los tipos de PQRS definidos.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del tipo de PQRS, utilizada para proporcionar información contextual sobre el tipo de solicitud, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a los tipos de PQRS definidos.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador de estado para activar o desactivar el tipo de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los tipos de PQRS definidos, así como su análisis estadístico en función de su estado.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de tipos de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_tipo_pqrs)                                                                                                              -- Clave primaria basada en el identificador del tipo de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de tipos de PQRS.
);
--------------------------------------------------------------------------------------------------------
-- PARÁMETROS DE VENCIMIENTO PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para definir los parámetros de vencimiento específicos para cada tipo y 
-- subtipo de PQRS, incluyendo los días hábiles para la respuesta, la prórroga, 
-- la base legal aplicable y cualquier descripción adicional, permitiendo una 
-- gestión eficiente de los plazos y la atención oportuna de las solicitudes 
-- recibidas, así como el cumplimiento de las normativas vigentes en materia 
-- de atención al ciudadano.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_param_venc_pqrs
(
    id_tipo_pqrs            DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 99),                                      -- Identificador del tipo de PQRS al que se asocian los parámetros de vencimiento, utilizado para establecer la relación entre los parámetros de vencimiento y el tipo de PQRS, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    nom_subtipo             VARCHAR(60)                NOT NULL DEFAULT 'GENERAL',                                                          -- Nombre del subtipo de PQRS para el cual se definen los parámetros de vencimiento, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los subtipos de PQRS definidos.
    dias_habiles_base       DECIMAL(3,0)               NOT NULL CHECK (dias_habiles_base >= 1),                                             -- Número de días hábiles para la respuesta base de las solicitudes de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    dias_habiles_prorroga   DECIMAL(3,0)               NOT NULL DEFAULT 0 CHECK (dias_habiles_prorroga >= 0),                               -- Número de días hábiles adicionales para la prórroga de las solicitudes de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    ind_prorroga_permitida  BOOLEAN                    NOT NULL DEFAULT FALSE,                                                              -- Indicador para permitir o no la prórroga en las solicitudes de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    base_legal              VARCHAR(255)               NOT NULL CHECK (char_length(trim(base_legal)) BETWEEN 1 AND 255),                    -- Base legal aplicable a los parámetros de vencimiento definidos para el tipo y subtipo de PQRS, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del marco normativo aplicable a los plazos establecidos para la atención de las solicitudes recibidas, así como su análisis estadístico en función de las bases legales asociadas a los tipos y subtipos de PQRS definidos.
    any_descripcion         VARCHAR(255),                                                                                                   -- Descripción adicional de los parámetros de vencimiento para el tipo y subtipo de PQRS, utilizada para proporcionar información contextual sobre los plazos establecidos para la atención de las solicitudes recibidas, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a los tipos y subtipos de PQRS definidos.
    ind_borrado             BOOLEAN                    NOT NULL DEFAULT FALSE,                                                              -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de parámetros de vencimiento para los tipos y subtipos de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_tipo_pqrs, nom_subtipo),                                                                                                -- Clave primaria compuesta por el identificador del tipo de PQRS y el nombre del subtipo, garantizando la integridad y unicidad de cada registro en la tabla de parámetros de vencimiento para los tipos y subtipos de PQRS.
    FOREIGN KEY (id_tipo_pqrs) REFERENCES tab_tipo_pqrs(id_tipo_pqrs)                                                                -- Clave foránea que establece la relación entre los parámetros de vencimiento y el tipo de PQRS, garantizando la integridad referencial y facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
);
--------------------------------------------------------------------------------------------------------
-- CANALES DE ENTRADA PQRS
--------------------------------------------------------------------------------------------------------
-- Catálogo de canales o medios por los cuales se reciben las solicitudes de PQRS,
-- para fines de trazabilidad, análisis estadístico y mejora continua en la atención
-- al ciudadano.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_canal_pqrs
(
    id_canal             DECIMAL(2,0)               NOT NULL CHECK (id_canal BETWEEN 1 AND 99),                                             -- Identificador del canal de entrada de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los canales de entrada definidos.
    nom_canal            VARCHAR(60)                NOT NULL CHECK (char_length(trim(nom_canal)) BETWEEN 1 AND 60),                         -- Nombre del canal de entrada de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los canales de entrada definidos.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del canal de entrada de PQRS, utilizada para proporcionar información contextual sobre el canal de entrada, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a los canales de entrada definidos.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador de estado para activar o desactivar el canal de entrada de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los canales de entrada definidos, así como su análisis estadístico en función de su estado.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de canales de entrada de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_canal)                                                                                                                  -- Clave primaria basada en el identificador del canal de entrada de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de canales de entrada de PQRS.
);
--------------------------------------------------------------------------------------------------------
-- ESTADOS DE PQRS
--------------------------------------------------------------------------------------------------------
-- Catálogo de estados para la gestión del ciclo de vida de las solicitudes de PQRS,
-- facilitando su seguimiento, análisis estadístico y aplicación de políticas de atención
-- y respuesta.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_pqrs
(
    id_estado_pqrs       DECIMAL(2,0)               NOT NULL CHECK (id_estado_pqrs BETWEEN 1 AND 99),                                       -- Identificador del estado de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión del ciclo de vida de las solicitudes de PQRS, así como su análisis estadístico en función de los estados definidos.
    val_estado_pqrs      VARCHAR(60)                NOT NULL CHECK (char_length(trim(val_estado_pqrs)) BETWEEN 1 AND 60),                   -- Valor o nombre del estado de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión del ciclo de vida de las solicitudes de PQRS, así como su análisis estadístico en función de los estados definidos.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del estado de PQRS, utilizada para proporcionar información contextual sobre el estado, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a los estados definidos.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador de estado para activar o desactivar el estado de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los estados definidos, así como su análisis estadístico en función de su estado.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de estados de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_estado_pqrs)                                                                                                            -- Clave primaria basada en el identificador del estado de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de estados de PQRS.
);
--------------------------------------------------------------------------------------------------------
-- MOTIVOS / CATEGORÍAS PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para definir los motivos o categorías de las solicitudes de PQRS, permitiendo
-- establecer una estructura jerárquica de motivos (con motivo padre) y asociar cada motivo
-- a un área responsable, facilitando la clasificación, análisis estadístico y gestión
-- eficiente de las solicitudes recibidas, así como la identificación de áreas de mejora
-- en los procesos y servicios ofrecidos por la organización.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_motivo_pqrs
(
    id_motivo            VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_motivo)) BETWEEN 1 AND 20),                         -- Identificador del motivo o categoría de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los motivos o categorías definidos.
    nom_motivo           VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_motivo)) BETWEEN 1 AND 100),                       -- Nombre del motivo o categoría de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los motivos o categorías definidos.
    motivo_padre         VARCHAR(20),                                                                                                       -- Identificador del motivo padre para establecer una estructura jerárquica de motivos o categorías de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los motivos o categorías definidos y su relación jerárquica.
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                                           -- Identificador del área responsable asociada al motivo o categoría de PQRS, utilizado para establecer la relación entre el motivo o categoría y el área responsable, facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de las áreas responsables asociadas a los motivos o categorías definidos.
    any_descripcion      VARCHAR(255),                                                                                                      -- Descripción adicional del motivo o categoría de PQRS, utilizada para proporcionar información contextual sobre el motivo o categoría, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a los motivos o categorías definidos.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                  -- Indicador de estado para activar o desactivar el motivo o categoría de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los motivos o categorías definidos, así como su análisis estadístico en función de su estado.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                 -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de motivos o categorías de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_motivo),                                                                                                                -- Clave primaria basada en el identificador del motivo o categoría de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de motivos o categorías de PQRS.
    FOREIGN KEY (motivo_padre) REFERENCES tab_motivo_pqrs(id_motivo),                                                                -- Clave foránea que establece la relación jerárquica entre motivos o categorías de PQRS, permitiendo definir motivos padres y facilitar la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de los motivos o categorías definidos y su relación jerárquica.
    FOREIGN KEY (id_area)      REFERENCES public.tab_areas(id_area)                                                                         -- Clave foránea que establece la relación entre el motivo o categoría de PQRS y el área responsable, garantizando la integridad referencial y facilitando la clasificación y gestión de las solicitudes recibidas, así como su análisis estadístico en función de las áreas responsables asociadas a los motivos o categorías definidos.
);
-- Índices para optimizar consultas frecuentes en la tabla de motivos de PQRS, especialmente para gestión por área y estructura jerárquica de motivos.
CREATE INDEX idx_motivo_pqrs_area  ON tab_motivo_pqrs(id_area);
CREATE INDEX idx_motivo_pqrs_padre ON tab_motivo_pqrs(motivo_padre) WHERE motivo_padre IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- ENCABEZADO PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla principal que registra la información básica de cada solicitud de PQRS recibida,
-- incluyendo su clasificación, estado, motivo, área responsable, solicitante, asunto, descripción,
-- fechas de radicación y vencimiento, entre otros datos relevantes para su gestión, seguimiento
-- y análisis estadístico, permitiendo garantizar una atención oportuna y eficiente de las solicitudes
-- recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_pqrs
(
    id_radicado              VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_radicado)) BETWEEN 1 AND 20),                                                                                              -- Identificador único del radicado de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    id_tipo_pqrs             DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 99),                                                                                                                -- Identificador del tipo de PQRS asociado a la solicitud, utilizado para establecer la relación entre la solicitud y el tipo de PQRS, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    subtipo_vencimiento      VARCHAR(60)                NOT NULL DEFAULT 'GENERAL',                                                                                                                                    -- Nombre del subtipo de vencimiento asociado a la solicitud, utilizado para establecer la relación entre la solicitud y el subtipo de vencimiento definido en la tabla de parámetros de vencimiento para los tipos y subtipos de PQRS, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    id_canal                 DECIMAL(2,0)               NOT NULL CHECK (id_canal BETWEEN 1 AND 99),                                                                                                                    -- Identificador del canal de entrada asociado a la solicitud, utilizado para establecer la relación entre la solicitud y el canal de entrada definido en la tabla de canales de entrada de PQRS, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    id_estado_pqrs           DECIMAL(2,0)               NOT NULL CHECK (id_estado_pqrs BETWEEN 1 AND 99),                                                                                                              -- Identificador del estado de la solicitud de PQRS, utilizado para establecer la relación entre la solicitud y el estado definido en la tabla de estados de PQRS, facilitando la gestión del ciclo de vida de las solicitudes recibidas, así como su análisis estadístico en función de los estados definidos.
    id_motivo                VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_motivo)) BETWEEN 1 AND 20),                                                                                                -- Identificador del motivo o categoría asociado a la solicitud de PQRS, utilizado para establecer la relación entre la solicitud y el motivo o categoría definido en la tabla de motivos de PQRS, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    id_area                  DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                                                                                                                  -- Identificador del área responsable asociada a la solicitud de PQRS, utilizado para establecer la relación entre la solicitud y el área responsable definida en la tabla de áreas, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    id_tercero               VARCHAR(20),                                                                                                                                                                              -- Identificador del tercero solicitante asociado a la solicitud de PQRS, utilizado para establecer la relación entre la solicitud y el tercero definido en la tabla de terceros, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud es anónima o si se proporciona un nombre libre del solicitante.
    id_usuario               VARCHAR(60),                                                                                                                                                                              -- Identificador del usuario solicitante asociado a la solicitud de PQRS, utilizado para establecer la relación entre la solicitud y el usuario definido en la tabla de usuarios, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud es anónima o si se proporciona un nombre libre del solicitante.
    nom_solicitante_libre    VARCHAR(200),                                                                                                                                                                             -- Nombre libre del solicitante asociado a la solicitud de PQRS, utilizado para proporcionar información sobre el solicitante en caso de que la solicitud sea anónima o si no se proporciona un tercero o usuario definido en las tablas correspondientes, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si se proporciona un tercero o usuario definido en las tablas correspondientes.
    asunto                   VARCHAR(255)               NOT NULL CHECK (char_length(trim(asunto)) BETWEEN 1 AND 255),                                                                                                  -- Asunto o título de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    any_descripcion          TEXT                       NOT NULL CHECK (char_length(trim(any_descripcion)) > 0),                                                                                                       -- Descripción detallada de la solicitud de PQRS, utilizada para proporcionar información contextual sobre la solicitud, facilitando su identificación y análisis estadístico en función de las descripciones asociadas a las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    fec_radicado             TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                                                                                        -- Fecha y hora de radicación de la solicitud de PQRS, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    fec_vencimiento          DATE                       NOT NULL,                                                                                                                                                      -- Fecha de vencimiento para la atención de la solicitud de PQRS, utilizada para su identificación y presentación en la interfaz de usuario, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    ind_anonimo              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                        -- Indicador para identificar si la solicitud de PQRS es anónima, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Si este indicador es verdadero, los campos de tercero, usuario y nombre libre del solicitante deben ser nulos o vacíos.
    cod_seguimiento_anonimo  VARCHAR(20),                                                                                                                                                                              -- Código de seguimiento para solicitudes de PQRS anónimas, utilizado para proporcionar un mecanismo de seguimiento y gestión de las solicitudes anónimas, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo debe ser único para cada solicitud anónima y puede ser nulo si la solicitud no es anónima.
    ind_requiere_respuesta   BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                                                                                         -- Indicador para identificar si la solicitud de PQRS requiere una respuesta, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Si este indicador es falso, la solicitud puede ser gestionada sin necesidad de proporcionar una respuesta formal.
    ind_borrado              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                        -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de encabezado de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_radicado),                                                                                                                                                                                         -- Clave primaria basada en el identificador del radicado de la solicitud de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de encabezado de PQRS.
    CONSTRAINT chk_pqrs_solicitante   CHECK (ind_anonimo = TRUE OR id_tercero IS NOT NULL OR id_usuario IS NOT NULL OR (nom_solicitante_libre IS NOT NULL AND char_length(trim(nom_solicitante_libre)) > 0)),          -- Restricción para garantizar que si la solicitud de PQRS no es anónima, se debe proporcionar al menos un identificador de tercero, usuario o un nombre libre del solicitante, facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    CONSTRAINT chk_pqrs_token_anonimo CHECK (ind_anonimo = FALSE OR cod_seguimiento_anonimo IS NOT NULL),                                                                                                              -- Restricción para garantizar que si la solicitud de PQRS es anónima, se debe proporcionar un código de seguimiento único, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes anónimas recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    CONSTRAINT chk_pqrs_vencimiento   CHECK (fec_vencimiento >= fec_radicado::date),                                                                                                                                   -- Restricción para garantizar que la fecha de vencimiento de la solicitud de PQRS sea igual o posterior a la fecha de radicación, facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_tipo_pqrs, subtipo_vencimiento) REFERENCES tab_param_venc_pqrs(id_tipo_pqrs, nom_subtipo),                                                                                                  -- Clave foránea que establece la relación entre la solicitud de PQRS y los parámetros de vencimiento definidos para el tipo y subtipo de PQRS, garantizando la integridad referencial y facilitando la gestión de los plazos y la atención oportuna de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_canal)       REFERENCES tab_canal_pqrs(id_canal),                                                                                                                                           -- Clave foránea que establece la relación entre la solicitud de PQRS y el canal de entrada definido en la tabla de canales de entrada de PQRS, garantizando la integridad referencial y facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_estado_pqrs) REFERENCES tab_estado_pqrs(id_estado_pqrs),                                                                                                                                    -- Clave foránea que establece la relación entre la solicitud de PQRS y el estado definido en la tabla de estados de PQRS, garantizando la integridad referencial y facilitando la gestión del ciclo de vida de las solicitudes recibidas, así como su análisis estadístico en función de los estados definidos.
    FOREIGN KEY (id_motivo)      REFERENCES tab_motivo_pqrs(id_motivo),                                                                                                                                         -- Clave foránea que establece la relación entre la solicitud de PQRS y el motivo o categoría definido en la tabla de motivos de PQRS, garantizando la integridad referencial y facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_area)        REFERENCES public.tab_areas(id_area),                                                                                                                                                 -- Clave foránea que establece la relación entre la solicitud de PQRS y el área responsable definida en la tabla de áreas, garantizando la integridad referencial y facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_tercero)     REFERENCES public.tab_terceros(id_tercero),                                                                                                                                           -- Clave foránea que establece la relación entre la solicitud de PQRS y el tercero solicitante definido en la tabla de terceros, garantizando la integridad referencial y facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    FOREIGN KEY (id_usuario)     REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                            -- Clave foránea que establece la relación entre la solicitud de PQRS y el usuario solicitante definido en la tabla de usuarios, garantizando la integridad referencial y facilitando la clasificación, gestión, seguimiento y análisis estadístico de las solicitudes recibidas, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
);
-- Índices para optimizar consultas frecuentes en la tabla de encabezado de PQRS, especialmente para seguimiento anónimo y gestión por estado, área, tipo y fechas.
CREATE UNIQUE INDEX idx_uq_cod_seguimiento_anonimo ON tab_enc_pqrs(cod_seguimiento_anonimo) WHERE cod_seguimiento_anonimo IS NOT NULL;
CREATE INDEX idx_enc_pqrs_estado      ON tab_enc_pqrs(id_estado_pqrs);
CREATE INDEX idx_enc_pqrs_area        ON tab_enc_pqrs(id_area);
CREATE INDEX idx_enc_pqrs_tipo        ON tab_enc_pqrs(id_tipo_pqrs);
CREATE INDEX idx_enc_pqrs_radicado    ON tab_enc_pqrs(fec_radicado);
CREATE INDEX idx_enc_pqrs_vence       ON tab_enc_pqrs(fec_vencimiento);
CREATE INDEX idx_enc_pqrs_estado_vence ON tab_enc_pqrs(id_estado_pqrs, fec_vencimiento); 
--------------------------------------------------------------------------------------------------------
-- SECUENCIA DETALLE PQRS
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada registro de detalle de 
-- PQRS, facilitando la gestión de la información complementaria y el seguimiento 
-- de cada solicitud a lo largo de su ciclo de vida.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_det_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- DETALLE PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para almacenar información detallada y complementaria de cada solicitud de PQRS,
-- incluyendo la prioridad, los tiempos de respuesta, las fechas de gestión, los usuarios
-- involucrados, la calificación del solicitante, los comentarios de cierre y cualquier
-- descripción adicional, permitiendo una gestión eficiente de las solicitudes a lo largo de su
-- ciclo de vida, así como el análisis estadístico y la mejora continua en la atención al ciudadano.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_pqrs
(
    id_detalle_pqrs             DECIMAL(12,0)              NOT NULL DEFAULT nextval('seq_det_pqrs'),                                                                                                            -- Identificador único del detalle de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de la información complementaria asociada a cada solicitud a lo largo de su ciclo de vida.
    id_radicado                 VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_radicado)) BETWEEN 1 AND 20),                                                                                           -- Identificador del radicado de la solicitud de PQRS al que se asocia el detalle, utilizado para establecer la relación entre el detalle y el encabezado de la solicitud, facilitando la gestión, seguimiento y análisis estadístico de la información complementaria asociada a cada solicitud a lo largo de su ciclo de vida.        
    prioridad                   VARCHAR(20)                NOT NULL DEFAULT 'NORMAL' CHECK (prioridad IN ('BAJA','NORMAL','ALTA','URGENTE','CRITICA')),                                                                -- Nivel de prioridad asignado a la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su prioridad, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    tiempo_respuesta_real       INTEGER                    NOT NULL DEFAULT 0 CHECK (tiempo_respuesta_real >= 0),                                                                                                      -- Tiempo de respuesta real de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su tiempo de respuesta, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano.
    tiempo_respuesta_proyectado INTEGER                    CHECK (tiempo_respuesta_proyectado IS NULL OR tiempo_respuesta_proyectado >= 0),                                                                            -- Tiempo de respuesta proyectado para la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su tiempo de respuesta proyectado, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si no se ha definido un tiempo de respuesta proyectado para la solicitud.
    fec_asignacion              TIMESTAMP WITH TIME ZONE,                                                                                                                                                              -- Fecha y hora de asignación de la solicitud de PQRS a un gestor, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su fecha de asignación, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud aún no ha sido asignada a un gestor.
    fec_inicio_gestion          TIMESTAMP WITH TIME ZONE,                                                                                                                                                              -- Fecha y hora de inicio de la gestión de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su fecha de inicio de gestión, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la gestión de la solicitud aún no ha sido iniciada.
    fec_ultima_gestion          TIMESTAMP WITH TIME ZONE,                                                                                                                                                              -- Fecha y hora de la última gestión realizada sobre la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su fecha de última gestión, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si no se ha realizado ninguna gestión sobre la solicitud.
    fec_cierre_definitivo       TIMESTAMP WITH TIME ZONE,                                                                                                                                                              -- Fecha y hora de cierre definitivo de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de su fecha de cierre definitivo, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud aún no ha sido cerrada definitivamente.
    id_usuario_gestor           VARCHAR(60),                                                                                                                                                                           -- Identificador del usuario gestor asignado a la solicitud de PQRS, utilizado para establecer la relación entre el detalle y el usuario definido en la tabla de usuarios, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de los gestores asignados, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud aún no ha sido asignada a un gestor.
    id_usuario_cierre           VARCHAR(60),                                                                                                                                                                           -- Identificador del usuario que realizó el cierre definitivo de la solicitud de PQRS, utilizado para establecer la relación entre el detalle y el usuario definido en la tabla de usuarios, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de los usuarios que realizan cierres definitivos, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si la solicitud aún no ha sido cerrada definitivamente.
    calificacion_solicitante    DECIMAL(2,0)               CHECK (calificacion_solicitante BETWEEN 1 AND 5),                                                                                                           -- Calificación proporcionada por el solicitante para la atención recibida en la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de la calificación proporcionada por los solicitantes, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si el solicitante no ha proporcionado una calificación.
    comentario_cierre           TEXT,                                                                                                                                                                                  -- Comentarios adicionales proporcionados por el gestor o el usuario que realiza el cierre definitivo de la solicitud de PQRS, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la gestión, seguimiento y análisis estadístico de las solicitudes recibidas en función de los comentarios asociados a los cierres definitivos, así como el cumplimiento de las normativas vigentes en materia de atención al ciudadano. Este campo puede ser nulo si no se han proporcionado comentarios adicionales.
    any_descripcion             VARCHAR(255),                                                                                                                                                                          -- Descripción adicional del detalle de la solicitud de PQRS, utilizada para proporcionar información contextual complementaria sobre la gestión de la solicitud, facilitando su identificación y análisis estadístico a lo largo del ciclo de vida de la PQRS.
    ind_borrado                 BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                     -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de detalle de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental y manteniendo la integridad referencial en las tablas que utilizan esta información.
    PRIMARY KEY (id_detalle_pqrs),                                                                                                                                                                                     -- Clave primaria basada en el identificador único del detalle de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de detalle de PQRS.
    FOREIGN KEY (id_radicado)       REFERENCES tab_enc_pqrs(id_radicado),                                                                                                                                     -- Clave foránea que establece la relación entre el detalle y el encabezado de la solicitud de PQRS, garantizando la integridad referencial y facilitando la gestión complementaria de cada solicitud a lo largo de su ciclo de vida.
    FOREIGN KEY (id_usuario_gestor) REFERENCES public.tab_usuarios(id_usuario),                                                                                                                                       -- Clave foránea que establece la relación entre el detalle y el usuario gestor asignado, garantizando la integridad referencial y facilitando la trazabilidad de la gestión realizada sobre la solicitud.
    FOREIGN KEY (id_usuario_cierre) REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                      -- Clave foránea que establece la relación entre el detalle y el usuario que realiza el cierre definitivo, garantizando la integridad referencial y facilitando la auditoría de los cierres de solicitudes de PQRS.
);
-- Índices para optimizar consultas frecuentes en la tabla de detalle de PQRS, especialmente para gestión por radicado, prioridad, gestor y fechas clave.
CREATE INDEX idx_det_pqrs_radicado       ON tab_det_pqrs(id_radicado);
CREATE INDEX idx_det_pqrs_prioridad      ON tab_det_pqrs(prioridad);
CREATE INDEX idx_det_pqrs_gestor         ON tab_det_pqrs(id_usuario_gestor);
CREATE INDEX idx_det_pqrs_fec_asignacion ON tab_det_pqrs(fec_asignacion) WHERE fec_asignacion IS NOT NULL;
CREATE INDEX idx_det_pqrs_fec_cierre     ON tab_det_pqrs(fec_cierre_definitivo) WHERE fec_cierre_definitivo IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- SECUENCIA SEGUIMIENTO PQRS
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada registro de seguimiento de 
-- PQRS, facilitando la gestión de las acciones realizadas, los cambios de estado, los
-- usuarios involucrados y los comentarios asociados a cada solicitud a lo largo 
-- de su ciclo de vida.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_seg_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- SEGUIMIENTO PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar el seguimiento de cada solicitud de PQRS, incluyendo las 
-- acciones realizadas, los cambios de estado, los usuarios involucrados y los 
-- comentarios asociados, permitiendo garantizar un control efectivo sobre el 
-- ciclo de vida de las solicitudes y facilitar la trazabilidad y auditoría de 
-- las acciones realizadas.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_seg_pqrs
(
    id_seguimiento       DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_seg_pqrs'),                                                                                                                   -- Identificador único del registro de seguimiento de PQRS, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la trazabilidad de las acciones realizadas sobre cada solicitud.
    id_radicado          VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_radicado)) BETWEEN 1 AND 20),                                                                                                  -- Identificador del radicado de la solicitud de PQRS al que se asocia el seguimiento, utilizado para establecer la relación entre el seguimiento y el encabezado de la solicitud, facilitando el control del ciclo de vida de la PQRS.
    id_estado_origen     DECIMAL(2,0)               NOT NULL CHECK (id_estado_origen  BETWEEN 1 AND 99),                                                                                                                -- Identificador del estado de origen de la solicitud antes de la acción registrada, utilizado para documentar la transición de estados y facilitar el análisis del flujo de gestión de las PQRS.
    id_estado_destino    DECIMAL(2,0)               NOT NULL CHECK (id_estado_destino BETWEEN 1 AND 99),                                                                                                                -- Identificador del estado de destino de la solicitud después de la acción registrada, utilizado para documentar la transición de estados y facilitar el análisis del flujo de gestión de las PQRS.
    id_responsable       VARCHAR(60)                NOT NULL,                                                                                                                                                          -- Identificador del usuario responsable de la acción de seguimiento, utilizado para establecer la relación con el catálogo de usuarios y garantizar la trazabilidad y auditoría de las gestiones realizadas.
    any_comentario       TEXT,                                                                                                                                                                                         -- Comentarios adicionales sobre la acción de seguimiento realizada, utilizados para proporcionar información contextual sobre la gestión de la solicitud, facilitando su identificación y análisis estadístico.
    fec_accion           TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                                                                                            -- Fecha y hora en que se registró la acción de seguimiento, utilizada para su identificación temporal y facilitar la trazabilidad cronológica de las gestiones sobre cada solicitud de PQRS.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de seguimiento de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_seguimiento),                                                                                                                                                                                    -- Clave primaria basada en el identificador único del seguimiento de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de seguimiento de PQRS.
    FOREIGN KEY (id_radicado)       REFERENCES tab_enc_pqrs(id_radicado),                                                                                                                                     -- Clave foránea que establece la relación entre el seguimiento y el encabezado de la solicitud de PQRS, garantizando la integridad referencial y facilitando el control efectivo del ciclo de vida de las solicitudes.
    FOREIGN KEY (id_estado_origen)  REFERENCES tab_estado_pqrs(id_estado_pqrs),                                                                                                                              -- Clave foránea que establece la relación entre el estado de origen y el catálogo de estados de PQRS, garantizando la integridad referencial y facilitando el análisis de transiciones de estado.
    FOREIGN KEY (id_estado_destino) REFERENCES tab_estado_pqrs(id_estado_pqrs),                                                                                                                              -- Clave foránea que establece la relación entre el estado de destino y el catálogo de estados de PQRS, garantizando la integridad referencial y facilitando el análisis de transiciones de estado.
    FOREIGN KEY (id_responsable)    REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                       -- Clave foránea que establece la relación entre el seguimiento y el usuario responsable, garantizando la integridad referencial y facilitando la trazabilidad de las acciones realizadas sobre las solicitudes de PQRS.
);
-- Índices para optimizar consultas frecuentes en la tabla de seguimiento de PQRS, especialmente para gestión por radicado, estado y fechas de acción.
CREATE INDEX idx_seg_pqrs_radicado ON tab_seg_pqrs(id_radicado);
CREATE INDEX idx_seg_pqrs_fecha    ON tab_seg_pqrs(fec_accion);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA RESPUESTA PQRS
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada respuesta registrada 
-- en el marco de la gestión de PQRS, facilitando la organización, seguimiento y 
-- trazabilidad de las respuestas proporcionadas a los ciudadanos, así como el 
-- análisis estadístico y la mejora continua en la atención al ciudadano.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_respuesta_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- RESPUESTA PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las respuestas proporcionadas a cada solicitud de PQRS,
-- incluyendo el asunto, el contenido, el canal de respuesta, el responsable, 
-- la fecha de respuesta y si es la respuesta final, permitiendo garantizar una 
-- gestión eficiente de las respuestas, así como la trazabilidad y auditoría de 
-- las acciones realizadas en el marco de la atención al ciudadano, y facilitando 
-- el análisis estadístico y la mejora continua en la calidad de la atención brindada.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_respuesta_pqrs
(
    id_respuesta         DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_respuesta_pqrs'),                                                                                                           -- Identificador único de la respuesta registrada para una solicitud de PQRS, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la organización y trazabilidad de las respuestas al ciudadano.
    id_radicado          VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_radicado)) BETWEEN 1 AND 20),                                                                                                  -- Identificador del radicado de la solicitud de PQRS a la que corresponde la respuesta, utilizado para establecer la relación entre la respuesta y el encabezado de la solicitud, facilitando el seguimiento integral de cada PQRS.
    asunto_respuesta     VARCHAR(255)               NOT NULL CHECK (char_length(trim(asunto_respuesta)) BETWEEN 1 AND 255),                                                                                          -- Asunto o título de la respuesta proporcionada al solicitante, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido de la respuesta formal.
    contenido_respuesta  TEXT                       NOT NULL CHECK (char_length(trim(contenido_respuesta)) > 0),                                                                                                       -- Contenido detallado de la respuesta proporcionada al solicitante, utilizado para documentar la solución o respuesta formal a la solicitud de PQRS, facilitando la trazabilidad y auditoría de la atención brindada.
    canal_respuesta      DECIMAL(2,0)               NOT NULL CHECK (canal_respuesta BETWEEN 1 AND 99),                                                                                                                -- Identificador del canal por el cual se envía la respuesta al solicitante, utilizado para establecer la relación con el catálogo de canales de PQRS y facilitar el análisis estadístico de los medios de respuesta utilizados.
    ind_respuesta_final  BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador que determina si la respuesta constituye el cierre definitivo de la solicitud de PQRS, utilizado para controlar que solo exista una respuesta final por radicado y facilitar la gestión del estado de cierre de las solicitudes.
    id_responsable       VARCHAR(60)                NOT NULL,                                                                                                                                                          -- Identificador del usuario responsable de elaborar o enviar la respuesta, utilizado para establecer la relación con el catálogo de usuarios y garantizar la trazabilidad y auditoría de las respuestas emitidas.
    fec_respuesta        TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                                                                                          -- Fecha y hora en que se registró o envió la respuesta al solicitante, utilizada para su identificación temporal y facilitar el análisis de cumplimiento de plazos de atención al ciudadano.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de respuestas de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_respuesta),                                                                                                                                                                                      -- Clave primaria basada en el identificador único de la respuesta de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de respuestas de PQRS.
    FOREIGN KEY (id_radicado)     REFERENCES tab_enc_pqrs(id_radicado),                                                                                                                                       -- Clave foránea que establece la relación entre la respuesta y el encabezado de la solicitud de PQRS, garantizando la integridad referencial y facilitando el seguimiento integral de cada solicitud atendida.
    FOREIGN KEY (canal_respuesta) REFERENCES tab_canal_pqrs(id_canal),                                                                                                                                        -- Clave foránea que establece la relación entre la respuesta y el canal de envío definido en el catálogo de canales de PQRS, garantizando la integridad referencial y facilitando el análisis de medios de respuesta utilizados.
    FOREIGN KEY (id_responsable)  REFERENCES public.tab_usuarios(id_usuario)                                                                                                                                       -- Clave foránea que establece la relación entre la respuesta y el usuario responsable, garantizando la integridad referencial y facilitando la trazabilidad de las respuestas emitidas a los ciudadanos.
);
-- Índices para optimizar consultas frecuentes en la tabla de respuestas de PQRS, especialmente para gestión por radicado, canal y fechas de respuesta.
CREATE UNIQUE INDEX idx_uq_respuesta_final_pqrs ON tab_respuesta_pqrs(id_radicado) WHERE ind_respuesta_final = TRUE;
CREATE INDEX idx_respuesta_pqrs_radicado        ON tab_respuesta_pqrs(id_radicado);
--------------------------------------------------------------------------------------------------------
-- ANEXOS PQRS
--------------------------------------------------------------------------------------------------------
-- Tabla para almacenar los anexos o archivos adjuntos relacionados con las solicitudes de PQRS,
-- permitiendo asociar cada anexo a un radicado o a una respuesta específica, yendo la 
-- información sobre el nombre del archivo, su ubicación de almacenamiento, 
-- el tipo MIME, el tamaño en bytes, el hash de integridad y un indicador de 
-- borrado lógico, facilitando la gestión eficiente de los anexos y garantizando 
-- la trazabilidad y auditoría de los archivos asociados a las solicitudes de PQRS.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_anexo_pqrs
(
    id_anexo_pqrs        VARCHAR(60)                NOT NULL CHECK (char_length(trim(id_anexo_pqrs)) > 0),                                                                                                             -- Identificador único del anexo asociado a una solicitud o respuesta de PQRS, utilizado para su referencia en la aplicación y en el sistema de almacenamiento de archivos, facilitando la gestión de documentos adjuntos.
    id_radicado          VARCHAR(20),                                                                                                                                                                                  -- Identificador del radicado de la solicitud de PQRS al que se asocia el anexo, utilizado cuando el archivo adjunto pertenece a la solicitud inicial. Debe ser nulo si el anexo pertenece a una respuesta.
    id_respuesta         DECIMAL(18,0),                                                                                                                                                                                -- Identificador de la respuesta de PQRS a la que se asocia el anexo, utilizado cuando el archivo adjunto pertenece a una respuesta formal. Debe ser nulo si el anexo pertenece al radicado de la solicitud.
    nom_anexo            VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_anexo)) > 0),                                                                                                                 -- Nombre del archivo anexo, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido del documento adjunto asociado a la PQRS.
    tamano_bytes         BIGINT                     CHECK (tamano_bytes IS NULL OR tamano_bytes > 0),                                                                                                                  -- Tamaño del archivo anexo en bytes, utilizado para controlar el almacenamiento y facilitar la validación de límites de carga de archivos en el módulo de PQRS.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de anexos de PQRS sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_anexo_pqrs),                                                                                                                                                                                     -- Clave primaria basada en el identificador único del anexo de PQRS, garantizando la integridad y unicidad de cada registro en la tabla de anexos de PQRS.
    CONSTRAINT chk_anexo_pqrs_un_padre CHECK ((CASE WHEN id_radicado  IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_respuesta IS NOT NULL THEN 1 ELSE 0 END) = 1),                                                  -- Restricción para garantizar que el anexo esté asociado a un único registro padre, ya sea el radicado de la solicitud o una respuesta, evitando ambigüedades en la vinculación de archivos adjuntos.
    FOREIGN KEY (id_radicado)  REFERENCES tab_enc_pqrs(id_radicado),                                                                                                                                        -- Clave foránea que establece la relación entre el anexo y el encabezado de la solicitud de PQRS, garantizando la integridad referencial cuando el archivo pertenece a la solicitud inicial.
    FOREIGN KEY (id_respuesta) REFERENCES tab_respuesta_pqrs(id_respuesta)                                                                                                                                   -- Clave foránea que establece la relación entre el anexo y la respuesta de PQRS, garantizando la integridad referencial cuando el archivo pertenece a una respuesta formal emitida al ciudadano.
);
--------------------------------------------------------------------------------------------------------
-- TABLA RIESGOS
--------------------------------------------------------------------------------------------------------
-- Tabla para definir los riesgos asociados a los procesos documentales, permitiendo
-- establecer una clasificación de riesgos, su descripción y un indicador de borrado lógico,
-- facilitando la gestión de los riesgos y su consideración en la planificación y ejecución
-- de los procesos documentales, así como en la toma de decisiones para mitigar su impacto 
-- y garantizar la continuidad operativa.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_riesgos
(
    id_riesgo            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_riesgo)) > 0),                                                                                                                 -- Identificador único del riesgo asociado a los procesos documentales, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión y clasificación de riesgos en el módulo de calidad.
    nom_riesgo           VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_riesgo)) > 0),                                                                                                                -- Nombre descriptivo del riesgo, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del riesgo identificado en los procesos documentales.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional del riesgo, utilizada para proporcionar información contextual sobre su naturaleza, impacto potencial o medidas de mitigación asociadas, facilitando su correcta gestión en la planificación documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de riesgos sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_riesgo)                                                                                                                                                                                            -- Clave primaria basada en el identificador único del riesgo, garantizando la integridad y unicidad de cada registro en la tabla de riesgos.
);
--------------------------------------------------------------------------------------------------------
-- TABLA NORMAS DE CALIDAD
--------------------------------------------------------------------------------------------------------
-- Tabla para definir las normas de calidad aplicables a los procesos documentales, 
-- permitiendo establecer un catálogo de normas, su descripción y un indicador de 
-- borrado lógico, facilitando la gestión de las normas de calidad y su consideración 
-- en la planificación y ejecución de los procesos documentales, así como en la 
-- toma de decisiones para garantizar el cumplimiento de los estándares de calidad 
-- establecidos por la organización y las normativas vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_normas
(
    id_norma             VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_norma)) > 0),                                                                                                                  -- Identificador único de la norma de calidad aplicable a los procesos documentales, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión del catálogo de normas de calidad.
    nom_norma            VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_norma)) > 0),                                                                                                                 -- Nombre descriptivo de la norma de calidad, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de las normas aplicables a la gestión documental.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional de la norma de calidad, utilizada para proporcionar información contextual sobre su alcance, requisitos o restricciones asociadas, facilitando su correcta aplicación en los procesos documentales.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de normas de calidad sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_norma)                                                                                                                                                                                           -- Clave primaria basada en el identificador único de la norma de calidad, garantizando la integridad y unicidad de cada registro en la tabla de normas.
);
--------------------------------------------------------------------------------------------------------
-- TABLA CERTIFICACIONES
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las certificaciones obtenidas por la organización en materia 
-- de gestión documental, permitiendo asociar cada certificación a una norma de 
-- calidad específica, e incluir información sobre la fecha de emisión, fecha 
-- de vencimiento y un indicador de borrado lógico, facilitando la gestión de 
-- las certificaciones y su consideración en la planificación y ejecución de los 
-- procesos documentales, así como en la toma de decisiones para garantizar el 
-- cumplimiento de los estándares de calidad establecidos por la organización y 
-- las normativas vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_certificacion
(
    id_certificacion     DECIMAL(6,0)               NOT NULL CHECK (id_certificacion BETWEEN 1 AND 999999),                                                                                                            -- Identificador numérico único de la certificación obtenida por la organización, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión de certificaciones en materia de gestión documental.
    nom_certificacion    VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_certificacion)) > 0),                                                                                                       -- Nombre descriptivo de la certificación, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de las certificaciones vigentes o históricas de la organización.
    id_norma             VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_norma)) > 0),                                                                                                                -- Identificador de la norma de calidad asociada a la certificación, utilizado para establecer la relación entre la certificación y el catálogo de normas, facilitando el cumplimiento de estándares documentales.
    fec_emision          DATE                       NOT NULL CHECK (fec_emision <= current_date),                                                                                                                    -- Fecha de emisión de la certificación, utilizada para su identificación temporal y facilitar el control de vigencia y renovación de las certificaciones obtenidas.
    fec_vencimiento      DATE                       NOT NULL CHECK (fec_vencimiento >= fec_emision),                                                                                                                 -- Fecha de vencimiento de la certificación, utilizada para alertar sobre certificaciones próximas a vencer y facilitar la planificación de procesos de renovación o recertificación.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de certificaciones sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_certificacion),                                                                                                                                                                                  -- Clave primaria basada en el identificador numérico de la certificación, garantizando la integridad y unicidad de cada registro en la tabla de certificaciones.
    FOREIGN KEY (id_norma) REFERENCES tab_normas(id_norma)                                                                                                                                                  -- Clave foránea que establece la relación entre la certificación y la norma de calidad asociada, garantizando la integridad referencial y facilitando el cumplimiento de estándares documentales.
);
-- Índices para optimizar consultas frecuentes en la tabla de certificaciones, especialmente para gestión por norma y fechas de vencimiento.
CREATE INDEX idx_nom_certificacion ON tab_certificacion(nom_certificacion);
--------------------------------------------------------------------------------------------------------
-- TABLA ESTADOS DOCUMENTALES
--------------------------------------------------------------------------------------------------------
-- Tabla para definir los estados de los documentos gestionados en el sistema, permitiendo
-- establecer un catálogo de estados, su descripción y un indicador de borrado lógico,
-- facilitando la gestión de los documentos a lo largo de su ciclo de vida, así como la
-- trazabilidad y auditoría de los cambios de estado, y garantizando el cumplimiento de las
-- políticas de gestión documental establecidas por la organización y las normativas vigentes 
-- en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_documento
(
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 99),                                                                                                                       -- Identificador numérico del estado documental, utilizado para clasificar y organizar los documentos según su estado en el ciclo de vida, facilitando su seguimiento y trazabilidad.
    val_estado           VARCHAR(60)                NOT NULL CHECK (char_length(trim(val_estado)) > 0),                                                                                                              -- Valor descriptivo del estado documental, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de los estados definidos en el flujo de gestión documental.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional del estado documental, utilizada para proporcionar información contextual sobre su propósito, características o restricciones asociadas en el ciclo de vida del documento.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de estados documentales sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_estado)                                                                                                                                                                                            -- Clave primaria basada en el identificador numérico del estado documental, garantizando la integridad y unicidad de cada registro en la tabla de estados documentales.
);
--------------------------------------------------------------------------------------------------------
-- TABLA ACCIONES DE WORKFLOW DOCUMENTAL (CALIDAD)
--------------------------------------------------------------------------------------------------------
-- Tabla para definir las acciones disponibles en el flujo de trabajo de gestión documental,
-- permitiendo establecer un catálogo de acciones, su descripción y un indicador de borrado lógico,
-- facilitando la gestión de los procesos documentales y su consideración en la planificación y
-- ejecución de los procesos documentales, así como en la toma de decisiones para garantizar el
-- cumplimiento de los estándares de calidad establecidos por la organización y las normativas
-- vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_accion_workflow
(
    id_accion            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_accion)) > 0),                                                                                                                 -- Identificador único de la acción de workflow documental de calidad, utilizado para su referencia en la aplicación y en el registro de transiciones del flujo de trabajo documental.
    nom_accion           VARCHAR(100)               NOT NULL CHECK (char_length(trim(nom_accion)) > 0),                                                                                                                -- Nombre descriptivo de la acción de workflow documental, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de las acciones disponibles en el flujo de gestión documental de calidad.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional de la acción de workflow documental, utilizada para proporcionar información contextual sobre su propósito o restricciones en el proceso de gestión documental de calidad.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de acciones de workflow documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_accion)                                                                                                                                                                                            -- Clave primaria basada en el identificador único de la acción de workflow documental, garantizando la integridad y unicidad de cada registro en la tabla de acciones de workflow de calidad.
);
--------------------------------------------------------------------------------------------------------
-- TABLA ENCABEZADO DOCUMENTAL
--------------------------------------------------------------------------------------------------------
-- Tabla principal que registra la información básica de cada documento gestionado en el sistema,
-- incluyendo su título, tipo, estado, área responsable, resumen, fechas de publicación y revisión,
-- tercero responsable, entre otros datos relevantes para su gestión, seguimiento y análisis estadístico,
-- permitiendo garantizar una gestión eficiente de los documentos a lo largo de su ciclo de vida, así como
-- la trazabilidad y auditoría de los cambios realizados, y garantizando el cumplimiento de las políticas
-- de gestión documental establecidas por la organización y las normativas vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_documento
(
    id_documento         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_documento)) > 0),                                                                                                              -- Identificador único del documento gestionado en el módulo de calidad, utilizado para su referencia en la aplicación y en otros objetos de la base de datos, facilitando la gestión integral del ciclo de vida documental.
    nom_titulo           VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_titulo)) > 0),                                                                                                             -- Título del documento, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la búsqueda y comprensión del contenido documental gestionado.
    tipo_documento       VARCHAR(100)               NOT NULL CHECK (char_length(trim(tipo_documento)) > 0),                                                                                                         -- Clasificación textual del tipo de documento, utilizada para su categorización y aplicación de políticas de gestión y retención documental en el módulo de calidad.
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 99),                                                                                                                        -- Identificador del estado actual del documento, utilizado para establecer la relación con el catálogo de estados documentales y facilitar el seguimiento del ciclo de vida del documento.
    id_area              DECIMAL(5,0),                                                                                                                                                                                 -- Identificador del área responsable del documento, utilizado para establecer la relación con el catálogo de áreas y facilitar la clasificación y gestión documental por dependencia. Puede ser nulo si no aplica una asignación por área.
    resumen              VARCHAR(255),                                                                                                                                                                                 -- Resumen o descripción breve del documento, utilizado para proporcionar información contextual sobre su contenido o propósito, facilitando su identificación y análisis estadístico.
    ind_vigencia         BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                                                                                             -- Indicador que determina si el documento se encuentra vigente, utilizado para controlar su aplicabilidad en los procesos de calidad y facilitar la gestión de documentos obsoletos o en revisión.
    fec_publicacion      DATE                       NOT NULL CHECK (fec_publicacion <= current_date),                                                                                                                  -- Fecha de publicación del documento, utilizada para su identificación temporal y facilitar el control de versiones y vigencia de la documentación de calidad.
    fec_revision         DATE                       NOT NULL CHECK (fec_revision >= fec_publicacion),                                                                                                                  -- Fecha de la última revisión del documento, utilizada para programar revisiones periódicas y garantizar la actualización oportuna de la documentación de calidad.
    id_tercero           VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_tercero)) > 0),                                                                                                              -- Identificador del tercero responsable del documento, utilizado para establecer la relación con el catálogo de terceros y facilitar la trazabilidad de la responsabilidad documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de encabezado documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_documento),                                                                                                                                                                                        -- Clave primaria basada en el identificador único del documento, garantizando la integridad y unicidad de cada registro en la tabla de encabezado documental.
    FOREIGN KEY (id_estado)  REFERENCES tab_estado_documento(id_estado),                                                                                                                                     -- Clave foránea que establece la relación entre el documento y su estado en el catálogo de estados documentales, garantizando la integridad referencial y facilitando el seguimiento del ciclo de vida.
    FOREIGN KEY (id_area)    REFERENCES public.tab_areas(id_area),                                                                                                                                                     -- Clave foránea que establece la relación entre el documento y el área responsable, garantizando la integridad referencial y facilitando la gestión documental por dependencia.
    FOREIGN KEY (id_tercero) REFERENCES public.tab_terceros(id_tercero)                                                                                                                                              -- Clave foránea que establece la relación entre el documento y el tercero responsable, garantizando la integridad referencial y facilitando la trazabilidad de la responsabilidad documental.
);
-- Índices para optimizar consultas frecuentes en la tabla de encabezado documental, especialmente para gestión por estado, área y fechas de publicación.
CREATE INDEX idx_enc_documento_estado ON tab_enc_documento(id_estado);
CREATE INDEX idx_enc_documento_area   ON tab_enc_documento(id_area) WHERE id_area IS NOT NULL;
CREATE INDEX idx_enc_documento_fec    ON tab_enc_documento(fec_publicacion);
--------------------------------------------------------------------------------------------------------
-- TABLA DETALLE DOCUMENTAL (versiones)
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las diferentes versiones de cada documento gestionado en el sistema, 
-- permitiendo establecer un historial de versiones con su número, descripción, fecha de 
-- creación y un indicador de borrado lógico, facilitando la gestión de las versiones de 
-- los documentos a lo largo de su ciclo de vida, así como la trazabilidad y auditoría de 
-- los cambios realizados, y garantizando el cumplimiento de las políticas de gestión documental 
-- establecidas por la organización y las normativas vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_documento
(
    id_version           VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_version)) > 0),                                                                                                               -- Identificador único de la versión del documento, utilizado para su referencia en la aplicación, en el workflow documental y en la tabla de archivos asociados, facilitando el control de versiones.
    id_documento         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_documento)) > 0),                                                                                                             -- Identificador del documento al que pertenece la versión, utilizado para establecer la relación con el encabezado documental y mantener el historial de versiones de cada documento de calidad.
    num_version          INTEGER                    NOT NULL CHECK (num_version >= 1),                                                                                                                                -- Número secuencial de la versión del documento, utilizado para ordenar cronológicamente las revisiones y facilitar la identificación de la versión vigente o histórica.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción adicional de la versión del documento, utilizada para documentar los cambios realizados en cada revisión y facilitar la trazabilidad de las actualizaciones documentales.
    fec_version          TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                                                                                          -- Fecha y hora de creación de la versión del documento, utilizada para su identificación temporal y facilitar el control cronológico del historial de versiones.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de detalle documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_version),                                                                                                                                                                                          -- Clave primaria basada en el identificador único de la versión del documento, garantizando la integridad y unicidad de cada registro en la tabla de detalle documental.
    CONSTRAINT uq_doc_num_version UNIQUE (id_documento, num_version),                                                                                                                                                -- Restricción de unicidad que garantiza que cada documento tenga un único registro por número de versión, evitando duplicidad en el historial de versiones.
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento)                                                                                                                                   -- Clave foránea que establece la relación entre la versión y el encabezado documental, garantizando la integridad referencial y facilitando el control de versiones de cada documento.
);
--------------------------------------------------------------------------------------------------------
-- TABLA RELACIÓN DOCUMENTO–NORMA
--------------------------------------------------------------------------------------------------------
-- Tabla para establecer la relación entre los documentos gestionados en el sistema
-- y las normas de calidad aplicables, permitiendo asociar cada documento a una o 
-- varias normas, y viceversa, facilitando la gestión de las normas de calidad en 
-- relación con los documentos, así como la trazabilidad y auditoría de las 
-- asociaciones realizadas, y garantizando el cumplimiento de los estándares de 
-- calidad establecidos por la organización y las normativas vigentes en materia 
-- de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_norma
(
    id_documento         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_documento)) > 0),                                                                                                             -- Identificador del documento asociado a la norma de calidad, utilizado para establecer la relación entre la documentación de calidad y las normas aplicables, facilitando el cumplimiento de estándares.
    id_norma             VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_norma)) > 0),                                                                                                                 -- Identificador de la norma de calidad asociada al documento, utilizado para vincular la documentación con los requisitos normativos que debe cumplir la organización.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de relación documento-norma sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_documento, id_norma),                                                                                                                                                                              -- Clave primaria compuesta basada en el documento y la norma, garantizando la integridad y unicidad de cada asociación documento-norma en la tabla de relación.
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento),                                                                                                                                   -- Clave foránea que establece la relación entre la asociación y el encabezado documental, garantizando la integridad referencial y facilitando la trazabilidad de normas aplicables por documento.
    FOREIGN KEY (id_norma)     REFERENCES tab_normas(id_norma)                                                                                                                                                 -- Clave foránea que establece la relación entre la asociación y el catálogo de normas de calidad, garantizando la integridad referencial y facilitando el cumplimiento de estándares documentales.
);
--------------------------------------------------------------------------------------------------------
-- TABLA ARCHIVO DOCUMENTAL (calidad) 
--------------------------------------------------------------------------------------------------------
-- Tabla para almacenar los archivos asociados a cada versión de los documentos 
-- gestionados en el sistema, permitiendo registrar el nombre del archivo, su 
-- ubicación de almacenamiento, el tipo MIME, el tamaño en bytes, el hash de 
-- integridad y un indicador de borrado lógico, facilitando la gestión eficiente 
-- de los archivos asociados a los documentos, así como la trazabilidad y auditoría 
-- de los archivos relacionados con cada versión de los documentos, y garantizando
--  el cumplimiento de las políticas de gestión documental establecidas por la 
-- organización y las normativas vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_archivo
(
    id_archivo           VARCHAR(60)                NOT NULL CHECK (char_length(trim(id_archivo)) > 0),                                                                                                               -- Identificador único del archivo asociado a una versión del documento de calidad, utilizado para su referencia en la aplicación y en el sistema de almacenamiento de archivos.
    id_version           VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_version)) > 0),                                                                                                             -- Identificador de la versión del documento a la que pertenece el archivo, utilizado para establecer la relación con el detalle documental y mantener los archivos vinculados a cada versión.
    nom_archivo          VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_archivo)) > 0),                                                                                                            -- Nombre del archivo digital asociado a la versión del documento, utilizado para su identificación y presentación en la interfaz de usuario.
    storage_path         VARCHAR(500),                                                                                                                                                                                 -- Ruta de almacenamiento del archivo en el sistema de gestión documental, utilizada para su localización y recuperación controlada en el repositorio de calidad.
    tamano_bytes         BIGINT                     CHECK (tamano_bytes IS NULL OR tamano_bytes > 0),                                                                                                                  -- Tamaño del archivo en bytes, utilizado para controlar el almacenamiento y facilitar la validación de límites de carga de archivos en el módulo de calidad.
    tipo_mime            VARCHAR(100),                                                                                                                                                                                 -- Tipo MIME del archivo, utilizado para identificar el formato del documento digital y facilitar su correcta visualización o descarga en la aplicación.
    hash_integridad      VARCHAR(64),                                                                                                                                                                                  -- Hash de integridad del archivo, utilizado para garantizar la autenticidad e integridad del documento digital y facilitar la detección de alteraciones o corrupciones.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de archivos documentales sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_archivo),                                                                                                                                                                                          -- Clave primaria basada en el identificador único del archivo documental, garantizando la integridad y unicidad de cada registro en la tabla de archivos de calidad.
    FOREIGN KEY (id_version) REFERENCES tab_det_documento(id_version)                                                                                                                                       -- Clave foránea que establece la relación entre el archivo y la versión del documento, garantizando la integridad referencial y facilitando la gestión de archivos por versión.
);
--------------------------------------------------------------------------------------------------------
-- TABLA PROCESOS DE CALIDAD
--------------------------------------------------------------------------------------------------------
-- Tabla para definir los procesos de calidad asociados a la gestión documental, 
-- permitiendo establecer un catálogo de procesos, su objetivo, el área responsable, 
-- las fechas de creación y un indicador de borrado lógico, facilitando la gestión 
-- de los procesos de calidad en relación con la gestión documental, así como la 
-- trazabilidad y auditoría de los procesos definidos, y garantizando el cumplimiento 
-- de los estándares de calidad establecidos por la organización y las normativas 
-- vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_procesos
(
    id_proceso           VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_proceso)) > 0),                                                                                                               -- Identificador único del proceso de calidad, utilizado para su referencia en la aplicación, en las auditorías y en otros objetos de la base de datos del módulo de gestión documental.
    nom_proceso          VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_proceso)) > 0),                                                                                                              -- Nombre descriptivo del proceso de calidad, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión de los procesos definidos en la organización.
    objetivo             VARCHAR(255),                                                                                                                                                                                 -- Objetivo del proceso de calidad, utilizado para documentar el propósito o meta que se persigue con la ejecución del proceso en el marco de la gestión documental.
    fec_creacion         DATE                       NOT NULL CHECK (fec_creacion <= current_date),                                                                                                                   -- Fecha de creación o formalización del proceso de calidad, utilizada para su identificación temporal y facilitar el control de antigüedad de los procesos definidos.
    ind_activo           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                                                                                             -- Indicador que determina si el proceso de calidad se encuentra activo, utilizado para incluir o excluir procesos en la planificación y ejecución de actividades de calidad documental.
    ind_en_ejecucion     BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador que determina si el proceso de calidad se encuentra actualmente en ejecución, utilizado para el seguimiento operativo y la gestión de procesos concurrentes.
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                                                                                                                  -- Identificador del área responsable del proceso de calidad, utilizado para establecer la relación con el catálogo de áreas y facilitar la gestión por dependencia.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de procesos de calidad sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_proceso),                                                                                                                                                                                          -- Clave primaria basada en el identificador único del proceso de calidad, garantizando la integridad y unicidad de cada registro en la tabla de procesos.
    FOREIGN KEY (id_area) REFERENCES public.tab_areas(id_area)                                                                                                                                                       -- Clave foránea que establece la relación entre el proceso de calidad y el área responsable, garantizando la integridad referencial y facilitando la gestión por dependencia.
);
-- Índices para optimizar consultas frecuentes en la tabla de procesos de calidad, especialmente para gestión por área y estado de actividad.
CREATE INDEX idx_procesos_area   ON tab_procesos(id_area);
CREATE INDEX idx_procesos_activo ON tab_procesos(ind_activo) WHERE ind_activo = TRUE;
--------------------------------------------------------------------------------------------------------
-- TABLA AUDITORÍAS
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las auditorías realizadas en el marco de la gestión documental,
-- permitiendo asociar cada auditoría a un proceso de calidad específico, e incluir
-- información sobre el tipo de auditoría, la certificación asociada, la fecha de
-- auditoría, el resultado y un indicador de borrado lógico, facilitando la gestión
-- de las auditorías y su consideración en la planificación y ejecución de los procesos
-- documentales, así como en la toma de decisiones para garantizar el cumplimiento de los
-- estándares de calidad establecidos por la organización y las normativas vigentes en materia
-- de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_auditorias
(
    id_auditoria         DECIMAL(6,0)               NOT NULL CHECK (id_auditoria BETWEEN 1 AND 999999),                                                                                                                -- Identificador numérico único de la auditoría realizada, utilizado para su referencia en la aplicación, en los hallazgos y en otros objetos de la base de datos del módulo de calidad documental.
    nom_auditoria        VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_auditoria)) > 0),                                                                                                           -- Nombre descriptivo de la auditoría, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del alcance y propósito de cada auditoría realizada.
    id_proceso           VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_proceso)) > 0),                                                                                                              -- Identificador del proceso de calidad auditado, utilizado para establecer la relación con el catálogo de procesos y facilitar el seguimiento de auditorías por proceso documental.
    tipo_auditoria       VARCHAR(20)                NOT NULL CHECK (tipo_auditoria IN ('INTERNA','EXTERNA_CLIENTE','CERTIFICADORA')),                                                                                  -- Tipo de auditoría realizada (interna, externa por cliente o por entidad certificadora), utilizado para clasificar las auditorías y facilitar el análisis estadístico por origen de evaluación.
    id_certificacion     DECIMAL(6,0),                                                                                                                                                                                  -- Identificador de la certificación asociada a la auditoría, utilizado cuando la auditoría está vinculada a un proceso de certificación. Puede ser nulo para auditorías internas o externas sin certificación asociada.
    fec_auditoria        DATE                       NOT NULL CHECK (fec_auditoria <= current_date),                                                                                                                    -- Fecha en que se realizó la auditoría, utilizada para su identificación temporal y facilitar la planificación y seguimiento del programa de auditorías de calidad documental.
    val_resultado        BOOLEAN                    NOT NULL,                                                                                                                                                        -- Resultado de la auditoría (aprobada o no aprobada), utilizado para documentar el cumplimiento evaluado y facilitar la toma de decisiones sobre acciones correctivas o de mejora.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de auditorías sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_auditoria),                                                                                                                                                                                      -- Clave primaria basada en el identificador numérico de la auditoría, garantizando la integridad y unicidad de cada registro en la tabla de auditorías.
    FOREIGN KEY (id_proceso)       REFERENCES tab_procesos(id_proceso),                                                                                                                                       -- Clave foránea que establece la relación entre la auditoría y el proceso de calidad auditado, garantizando la integridad referencial y facilitando el seguimiento de auditorías por proceso.
    FOREIGN KEY (id_certificacion) REFERENCES tab_certificacion(id_certificacion)                                                                                                                            -- Clave foránea que establece la relación entre la auditoría y la certificación asociada, garantizando la integridad referencial cuando la auditoría está vinculada a un proceso de certificación.
);
-- Índices para optimizar consultas frecuentes en la tabla de auditorías, especialmente para gestión por proceso y certificación.
CREATE INDEX idx_auditoria_proceso ON tab_auditorias(id_proceso);
CREATE INDEX idx_auditoria_certificacion ON tab_auditorias(id_certificacion);
--------------------------------------------------------------------------------------------------------
-- TABLA HALLAZGOS DE AUDITORÍA
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar los hallazgos identificados durante las auditorías realizadas 
-- en el marco de la gestión documental, permitiendo asociar cada hallazgo a una 
-- auditoría específica, e incluir información sobre su descripción, severidad, estado 
-- y un indicador de borrado lógico, facilitando la gestión de los hallazgos y su 
-- consideración en la planificación y ejecución de los procesos documentales, 
-- así como en la toma de decisiones para garantizar el cumplimiento de los estándares 
-- de calidad establecidos por la organización y las normativas vigentes en materia 
-- de gestión documental, y permitiendo el análisis estadístico de los hallazgos para 
-- la mejora continua de los procesos documentales.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_hallazgo
(
    id_hallazgo          CHAR(6)                    NOT NULL CHECK (id_hallazgo ~ '^[A-Z0-9]{6}$'),                                                                                                                    -- Identificador alfanumérico de seis caracteres del hallazgo de auditoría, utilizado para su referencia en acciones correctivas, anexos y reportes de calidad documental.
    id_auditoria         DECIMAL(6,0)               NOT NULL CHECK (id_auditoria BETWEEN 1 AND 999999),                                                                                                                -- Identificador de la auditoría en la que se identificó el hallazgo, utilizado para establecer la relación con el registro de auditoría y facilitar el seguimiento de no conformidades por auditoría.
    any_descripcion      VARCHAR(255)               NOT NULL CHECK (char_length(trim(any_descripcion)) > 0),                                                                                                         -- Descripción detallada del hallazgo identificado durante la auditoría, utilizada para documentar la no conformidad o área de mejora detectada en el proceso documental evaluado.
    val_severidad        VARCHAR(10)                NOT NULL CHECK (val_severidad IN ('BAJA','MEDIA','ALTA','CRITICA')),                                                                                                -- Nivel de severidad del hallazgo (baja, media, alta o crítica), utilizado para priorizar las acciones correctivas y facilitar el análisis de riesgos en los procesos documentales.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                                                                                             -- Indicador que determina si el hallazgo se encuentra abierto o cerrado, utilizado para el seguimiento de la gestión de no conformidades y el cierre de hallazgos atendidos.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de hallazgos sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_hallazgo),                                                                                                                                                                                         -- Clave primaria basada en el identificador alfanumérico del hallazgo, garantizando la integridad y unicidad de cada registro en la tabla de hallazgos de auditoría.
    FOREIGN KEY (id_auditoria) REFERENCES tab_auditorias(id_auditoria)                                                                                                                                      -- Clave foránea que establece la relación entre el hallazgo y la auditoría en la que fue identificado, garantizando la integridad referencial y facilitando el seguimiento de no conformidades.
);
-- Índices para optimizar consultas frecuentes en la tabla de hallazgos de auditoría, especialmente para gestión por auditoría y estado del hallazgo.
CREATE INDEX idx_hallazgo_auditoria       ON tab_hallazgo(id_auditoria);
CREATE INDEX idx_hallazgo_auditoria_estado ON tab_hallazgo(id_auditoria, ind_estado); 
--------------------------------------------------------------------------------------------------------
-- TABLA ANEXOS DOCUMENTALES
--------------------------------------------------------------------------------------------------------
-- Tabla para almacenar los anexos o archivos adjuntos relacionados con los documentos 
-- gestionados en el sistema, permitiendo asociar cada anexo a un documento, una versión 
-- específica o un hallazgo de auditoría, yendo la información sobre el nombre del archivo, 
-- su ubicación de almacenamiento, y un indicador de borrado lógico, facilitando la gestión 
-- eficiente de los anexos y garantizando la trazabilidad y auditoría de los archivos asociados
--  a los documentos gestionados en el sistema, así como la consideración de los anexos en la 
-- planificación y ejecución de los procesos documentales, y garantizando el cumplimiento de 
-- las políticas de gestión documental establecidas por la organización y las normativas 
-- vigentes en materia de gestión documental.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_anexo
(
    id_anexo             VARCHAR(60)                NOT NULL CHECK (char_length(trim(id_anexo)) > 0),                                                                                                                 -- Identificador único del anexo documental, utilizado para su referencia en la aplicación y en el sistema de almacenamiento de archivos del módulo de calidad.
    id_documento         VARCHAR(50),                                                                                                                                                                                  -- Identificador del documento al que se asocia el anexo, utilizado cuando el archivo adjunto pertenece al encabezado documental. Debe ser nulo si el anexo pertenece a una versión o a un hallazgo.
    id_version           VARCHAR(50),                                                                                                                                                                                  -- Identificador de la versión del documento a la que se asocia el anexo, utilizado cuando el archivo adjunto pertenece a una versión específica. Debe ser nulo si el anexo pertenece al documento o a un hallazgo.
    id_hallazgo          CHAR(6)                             CHECK (id_hallazgo IS NULL OR id_hallazgo ~ '^[A-Z0-9]{6}$'),                                                                                             -- Identificador del hallazgo de auditoría al que se asocia el anexo, utilizado cuando el archivo adjunto es evidencia de un hallazgo. Debe ser nulo si el anexo pertenece a un documento o versión.
    nom_anexo            VARCHAR(255)               NOT NULL CHECK (char_length(trim(nom_anexo)) > 0),                                                                                                                 -- Nombre del archivo anexo, utilizado para su identificación y presentación en la interfaz de usuario, facilitando la comprensión del contenido del documento adjunto.
    storage_path         VARCHAR(500),                                                                                                                                                                                 -- Ruta de almacenamiento del archivo anexo en el sistema de gestión documental, utilizada para su localización y recuperación controlada en el repositorio de calidad.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de anexos documentales sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_anexo),                                                                                                                                                                                            -- Clave primaria basada en el identificador único del anexo documental, garantizando la integridad y unicidad de cada registro en la tabla de anexos.
    CONSTRAINT chk_anexo_un_solo_padre CHECK ((CASE WHEN id_documento IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_version   IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_hallazgo  IS NOT NULL THEN 1 ELSE 0 END) = 1), -- Restricción para garantizar que el anexo esté asociado a un único registro padre (documento, versión o hallazgo), evitando ambigüedades en la vinculación de archivos adjuntos.
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento),                                                                                                                                  -- Clave foránea que establece la relación entre el anexo y el encabezado documental, garantizando la integridad referencial cuando el archivo pertenece al documento.
    FOREIGN KEY (id_version)   REFERENCES tab_det_documento(id_version),                                                                                                                                      -- Clave foránea que establece la relación entre el anexo y la versión del documento, garantizando la integridad referencial cuando el archivo pertenece a una versión específica.
    FOREIGN KEY (id_hallazgo)  REFERENCES tab_hallazgo(id_hallazgo)                                                                                                                                         -- Clave foránea que establece la relación entre el anexo y el hallazgo de auditoría, garantizando la integridad referencial cuando el archivo es evidencia de un hallazgo.
);
--------------------------------------------------------------------------------------------------------
-- TABLA ACCIONES CORRECTIVAS
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las acciones correctivas implementadas en respuesta a los 
-- hallazgos identificados durante las auditorías realizadas en el marco de la gestión 
-- documental, permitiendo asociar cada acción correctiva a un hallazgo específico, e 
-- incluir información sobre su descripción, el tercero responsable, las fechas de 
-- compromiso y ejecución, el estado de la acción correctiva, la evidencia asociada y un 
-- indicador de borrado lógico, facilitando la gestión de las acciones correctivas y su 
-- consideración en la planificación y ejecución de los procesos documentales, así como en 
-- la toma de decisiones para garantizar el cumplimiento de los estándares de calidad 
-- establecidos por la organización y las normativas vigentes en materia de gestión documental, 
-- y permitiendo el análisis estadístico de las acciones correctivas para la mejora continua 
-- de los procesos documentales.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_accion_correctiva
(
    id_accion            VARCHAR(60)                NOT NULL CHECK (char_length(trim(id_accion)) > 0),                                                                                                               -- Identificador único de la acción correctiva implementada, utilizado para su referencia en la aplicación y en el seguimiento de cierre de hallazgos de auditoría.
    id_hallazgo          CHAR(6)                    NOT NULL CHECK (id_hallazgo ~ '^[A-Z0-9]{6}$'),                                                                                                                    -- Identificador del hallazgo de auditoría al que responde la acción correctiva, utilizado para establecer la relación con el registro de hallazgo y facilitar el seguimiento de no conformidades.
    any_descripcion      VARCHAR(255),                                                                                                                                                                                 -- Descripción detallada de la acción correctiva planificada o ejecutada, utilizada para documentar las medidas adoptadas para atender el hallazgo identificado en la auditoría.
    id_tercero           VARCHAR(20)                NOT NULL CHECK (char_length(trim(id_tercero)) > 0),                                                                                                              -- Identificador del tercero responsable de ejecutar la acción correctiva, utilizado para establecer la relación con el catálogo de terceros y garantizar la trazabilidad de responsabilidades.
    fec_compromiso       DATE                       NOT NULL,                                                                                                                                                          -- Fecha comprometida para la ejecución de la acción correctiva, utilizada para el seguimiento de cumplimiento de plazos y alertas de vencimiento de acciones pendientes.
    fec_ejecucion        DATE                                CHECK (fec_ejecucion IS NULL OR fec_ejecucion >= fec_compromiso),                                                                                          -- Fecha real de ejecución de la acción correctiva, utilizada para documentar el cumplimiento efectivo. Puede ser nula mientras la acción esté pendiente de ejecución.
    val_estado           VARCHAR(20)                NOT NULL CHECK (val_estado IN ('ABIERTA','EN_PROCESO','CERRADA','CANCELADA')),                                                                                    -- Estado de la acción correctiva (abierta, en proceso, cerrada o cancelada), utilizado para el seguimiento del avance y cierre de las medidas adoptadas frente a los hallazgos.
    evidencia_path       VARCHAR(500),                                                                                                                                                                                 -- Ruta o enlace a la evidencia documental de la ejecución de la acción correctiva, utilizada para sustentar el cierre del hallazgo y facilitar la auditoría de las medidas implementadas.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                            -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de acciones correctivas sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_accion),                                                                                                                                                                                           -- Clave primaria basada en el identificador único de la acción correctiva, garantizando la integridad y unicidad de cada registro en la tabla de acciones correctivas.
    FOREIGN KEY (id_hallazgo) REFERENCES tab_hallazgo(id_hallazgo),                                                                                                                                           -- Clave foránea que establece la relación entre la acción correctiva y el hallazgo de auditoría atendido, garantizando la integridad referencial y facilitando el seguimiento de no conformidades.
    FOREIGN KEY (id_tercero)  REFERENCES public.tab_terceros(id_tercero)                                                                                                                                             -- Clave foránea que establece la relación entre la acción correctiva y el tercero responsable, garantizando la integridad referencial y facilitando la trazabilidad de responsabilidades.
);
-- Índices para optimizar consultas frecuentes en la tabla de acciones correctivas, especialmente para gestión por hallazgo y estado de la acción correctiva.
CREATE INDEX idx_ac_hallazgo ON tab_accion_correctiva(id_hallazgo);
CREATE INDEX idx_ac_estado   ON tab_accion_correctiva(val_estado);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA WORKFLOW DOCUMENTAL
--------------------------------------------------------------------------------------------------------
-- Secuencia para generar identificadores únicos para cada registro de transición 
-- en el flujo de trabajo documental, facilitando la organización, seguimiento y 
-- trazabilidad de las transiciones realizadas en el marco de la gestión documental, así
-- como el análisis estadístico de las transiciones para la mejora continua de los 
-- procesos documentales.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_workflow START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA DE FLUJO DE TRABAJO DOCUMENTAL (WORKFLOW)
--------------------------------------------------------------------------------------------------------
-- Tabla para registrar las transiciones realizadas en el flujo de trabajo de gestión documental,
-- permitiendo asociar cada transición a un documento y una versión específica, e incluir
-- información sobre la acción realizada, el comentario adicional, el estado de origen y destino,
-- y un indicador de borrado lógico, facilitando la gestión de las transiciones en el marco de la
-- gestión documental, así como la trazabilidad y auditoría de las transiciones realizadas, y
-- garantizando el cumplimiento de los estándares de calidad establecidos por la organización y las
-- normativas vigentes en materia de gestión documental, y permitiendo el análisis estadístico de las
-- transiciones para la mejora continua de los procesos documentales.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_workflow
(
    id_workflow          DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_workflow'),                                                                                                                   -- Identificador único de la transición en el flujo de trabajo documental de calidad, generado automáticamente por la secuencia, utilizado para la trazabilidad de cambios de estado en los documentos.
    id_documento         VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_documento)) > 0),                                                                                                             -- Identificador del documento sobre el cual se registra la transición de workflow, utilizado para establecer la relación con el encabezado documental y facilitar el historial de gestión del documento.
    id_version           VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_version)) > 0),                                                                                                             -- Identificador de la versión del documento asociada a la transición, utilizado para vincular cada cambio de estado con la versión específica del documento de calidad gestionado.
    id_accion            VARCHAR(50)                NOT NULL CHECK (char_length(trim(id_accion)) > 0),                                                                                                                -- Identificador de la acción de workflow ejecutada, utilizado para establecer la relación con el catálogo de acciones de workflow documental de calidad y documentar la operación realizada.
    any_comentario       TEXT,                                                                                                                                                                                         -- Comentarios adicionales sobre la transición realizada en el workflow, utilizados para proporcionar información contextual sobre la gestión del documento y facilitar la auditoría de las acciones ejecutadas.
    id_estado_origen     DECIMAL(2,0)               NOT NULL CHECK (id_estado_origen  BETWEEN 1 AND 99),                                                                                                               -- Identificador del estado documental de origen antes de la transición, utilizado para documentar el cambio de estado y facilitar el análisis del flujo de gestión documental de calidad.
    id_estado_destino    DECIMAL(2,0)               NOT NULL CHECK (id_estado_destino BETWEEN 1 AND 99),                                                                                                               -- Identificador del estado documental de destino después de la transición, utilizado para documentar el nuevo estado del documento y facilitar el seguimiento del ciclo de vida documental.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                                                          -- Indicador de borrado lógico para permitir la eliminación suave de registros en la tabla de workflow documental sin perder su historial o referencias, facilitando la recuperación en caso de eliminación accidental.
    PRIMARY KEY (id_workflow),                                                                                                                                                                                       -- Clave primaria basada en el identificador único de la transición de workflow, garantizando la integridad y unicidad de cada registro en la tabla de flujo de trabajo documental.
    FOREIGN KEY (id_documento)      REFERENCES tab_enc_documento(id_documento),                                                                                                                             -- Clave foránea que establece la relación entre la transición y el encabezado documental, garantizando la integridad referencial y facilitando el historial de gestión por documento.
    FOREIGN KEY (id_version)        REFERENCES tab_det_documento(id_version),                                                                                                                                 -- Clave foránea que establece la relación entre la transición y la versión del documento, garantizando la integridad referencial y facilitando el control de versiones en el workflow.
    FOREIGN KEY (id_accion)         REFERENCES tab_accion_workflow(id_accion),                                                                                                                                -- Clave foránea que establece la relación entre la transición y la acción de workflow ejecutada, garantizando la integridad referencial y facilitando la auditoría de operaciones realizadas.
    FOREIGN KEY (id_estado_origen)  REFERENCES tab_estado_documento(id_estado),                                                                                                                               -- Clave foránea que establece la relación entre el estado de origen y el catálogo de estados documentales, garantizando la integridad referencial y facilitando el análisis de transiciones de estado.
    FOREIGN KEY (id_estado_destino) REFERENCES tab_estado_documento(id_estado)                                                                                                                              -- Clave foránea que establece la relación entre el estado de destino y el catálogo de estados documentales, garantizando la integridad referencial y facilitando el análisis de transiciones de estado.
);
-- Índices para optimizar consultas frecuentes en la tabla de flujo de trabajo documental, especialmente para gestión por documento, versión y estados de origen y destino.
CREATE INDEX idx_wf_doc_documento ON tab_workflow(id_documento);
CREATE INDEX idx_wf_doc_version   ON tab_workflow(id_version);

--------------------------
-- MÓDULO DE ANALISIS FINANCIERO
--------------------------


--************************************
--**TABLA DE PARÁMETROS FINANCIEROS **
--************************************       
CREATE TABLE IF NOT EXISTS tab_pmtros_financieros (
    id_pmtro_financiero     VARCHAR        NOT NULL           CHECK (LENGTH(TRIM(id_pmtro_financiero)) BETWEEN 1 AND 20), --Identificador del parámetro financiero
    inventario              DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (inventario >= 0),                                    --Valor total de existencias disponibles.
    efectivo                DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (efectivo >= 0),                                      --Dinero en caja y bancos.
    equiv_efectivo          DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (equiv_efectivo >= 0),                                --Inversiones de alta liquidez equivalentes al efectivo.
    activos_totales         DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (activos_totales >= 0),                               --Suma de activos corrientes y no corrientes, representa el total de recursos controlados por la empresa.
    pasivos_corrientes      DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (pasivos_corrientes >= 0),                            --Obligaciones a corto plazo de la empresa, que deben pagarse dentro del próximo año.
    pasivo_financiero       DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (pasivo_financiero >= 0),                             --Deudas financieras con terceros, incluyendo préstamos y créditos.
    pasivos_totales         DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (pasivos_totales >= 0),                               --Suma de pasivos corrientes y no corrientes, representa el total de obligaciones de la empresa.
    patrimonio              DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (patrimonio >= 0),                                    --Valor residual de los activos después de deducir los pasivos, representa el valor neto de la empresa.
    ventas                  DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (ventas >= 0),                                        --Ingresos por ventas netas, representa el total de ingresos generados por la empresa a través de sus actividades comerciales.
    costo_de_ventas         DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (costo_de_ventas >= 0),                               --Costos directos de producción de ventas, representa el costo asociado a la producción de los bienes o servicios vendidos por la empresa.
    utilidad_operativa      DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (utilidad_operativa >= 0),                            --Beneficio antes de intereses e impuestos, representa la rentabilidad operativa de la empresa.
    interes                 DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (interes >= 0),                                       --Gastos por intereses financieros, representa el costo de la deuda de la empresa.
    utilidad_neta           DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (utilidad_neta >= 0),                                 --Resultado final después de impuestos, representa la rentabilidad neta de la empresa.
    depreciacion            DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (depreciacion >= 0),                                  --Asignación sistemática del costo de los activos fijos a lo largo de su vida útil, representa la pérdida de valor de los activos debido al uso y desgaste.
    amortizacion            DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (amortizacion >= 0),                                  --Asignación sistemática del costo de los activos intangibles a lo largo de su vida útil, representa la pérdida de valor de los activos intangibles debido al paso del tiempo o al uso.
    gastos_administrativos  DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (gastos_administrativos >= 0),                        --Costos indirectos relacionados con la gestión y administración de la empresa, representa los gastos necesarios para mantener la operación del negocio.
    gastos_ventas           DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (gastos_ventas >= 0),                                 --Costos indirectos relacionados con la comercialización y distribución de los productos o servicios, representa los gastos necesarios para promover y vender los productos o servicios de la empresa.
    impuestos               DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (impuestos >= 0),                                     --Obligaciones fiscales que la empresa debe pagar al gobierno, representa el costo de los impuestos sobre las ganancias de la empresa.
    cxc_promedio            DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (cxc_promedio >= 0),                                  --Promedio de cuentas por cobrar, representa el valor promedio de las cuentas por cobrar de la empresa durante un período determinado.
    ventas_credito          DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (ventas_credito >= 0),                                --Ventas realizadas a crédito, representa el monto de ventas que no se han pagado completamente.
    inv_promedio            DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (inv_promedio >= 0),                                  --Promedio de inventario, representa el valor promedio del inventario de la empresa durante un período determinado.
    compras_credito         DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (compras_credito >= 0),                                --Compras realizadas a crédito, representa el monto de compras que no se han pagado completamente.
    cxp_promedio            DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (cxp_promedio >= 0),                                  --Promedio de cuentas por pagar, representa el valor promedio de las cuentas por pagar de la empresa durante un período determinado.
    capital_invertido       DECIMAL(18,2)  NOT NULL DEFAULT 0 CHECK (capital_invertido >= 0),                             --Capital invertido en la empresa, representa el monto total de inversión en activos y pasivos.
    ind_borrado             BOOLEAN        NOT NULL DEFAULT FALSE,                                                        --TRUE: Borrado lógico / FALSE: Activo
    --    datos_audit           audit_trail,                                                                              --Pista de auditoría para
    PRIMARY KEY (id_pmtro_financiero)
);

--*****************************
--** TABLA DE DEPARTAMENTOS  **
--*****************************

--ESTA TABLA ES TRASVERSAL

--***********************
--** TABLA DE CIUDADES **
--***********************

--ESTA TABLA ES TRASVERSAL

--*************************
--** TABLA DE INVERSORES **
--*************************

CREATE TABLE IF NOT EXISTS tab_inversores
(
    id_inversor           VARCHAR                       NOT NULL    CHECK   (LENGTH(TRIM(id_inversor)) =10),                                        --identificación del inversor     
	nom_inversor          VARCHAR                       NOT NULL    CHECK   (LENGTH(TRIM(nom_inversor)) BETWEEN 5 AND 60),                          --nombre del inversor
    tipo_inversor         BOOLEAN                       NOT NULL,   --true = Natural / false = Jurdíco                                              --tipo de inversor
    id_ciudad             VARCHAR                       NOT NULL    CHECK   (LENGTH(TRIM(id_ciudad)) =5),                                           --identificación de la ciudad
    tel_inversor          DECIMAL(10,0)                 NOT NULL    CHECK   (tel_inversor >=0),                                                     --teléfono del inversor
    email_inversor        VARCHAR                       NOT NULL    CHECK   (LENGTH(TRIM(email_inversor)) BETWEEN 5 AND 120),                       --correo electrónico del inversor
    dir_inversor          VARCHAR                       NOT NULL    CHECK   (LENGTH(TRIM(dir_inversor)) BETWEEN 1 AND 254),                         --dirección del inversor
    estado_inversor       VARCHAR                       NOT NULL    CHECK (estado_inversor IN ('ACTIVO','INACTIVO','SUSPENDIDO')),                  --estado del inversor
    ind_borrado           BOOLEAN                       NOT NULL    DEFAULT FALSE,                                                                     --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit           audit_trail,                                                                                                            --pista de auditoría
    PRIMARY KEY (id_inversor),
	FOREIGN KEY (id_ciudad) REFERENCES public.tab_ciudades(id_ciudad)
);

--**************************
--** TABLA DE PRESUPUESTO **
--**************************

CREATE TABLE IF NOT EXISTS tab_presupuesto_financi
(
    id_presupuesto          VARCHAR                       NOT NULL    CHECK  (LENGTH(TRIM(id_presupuesto)) BETWEEN 1 AND 10),                                           --identificador del presupuesto
    nom_presupuesto         VARCHAR                       NOT NULL     CHECK  (LENGTH(TRIM(nom_presupuesto)) BETWEEN 1 AND 254),                                        --nombre del presupuesto
    monto_presupuesto       DECIMAL   (18,2)              NOT NULL     CHECK  (monto_presupuesto > 0),                                                                  --monto del presupuesto
    fec_inicio              DATE                          NOT NULL     CHECK  (fec_inicio >= '2025-01-01'),                                                             --fecha de inicio del presupuesto
    fec_fin                 DATE                          NOT NULL     CHECK  (fec_fin > fec_inicio),                                                                   --fecha final del presupuesto
    descripcion             TEXT                          NOT NULL     CHECK  (LENGTH(TRIM(descripcion)) > 0),                                                          --descripción del presupuesto
    estado_presupuesto      VARCHAR                       NOT NULL     CHECK (estado_presupuesto IN ('APROBADO','EJECUTADO','CERRADO')),                                --estado del presupuesto
    porcentaje_ejecucion    DECIMAL   (5,2)               NOT NULL     DEFAULT 0 CHECK (porcentaje_ejecucion BETWEEN 0 AND 100),                                        --porcentaje de ejecución
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                                                                        --TRUE: Borrado lógico / FALSE: Activo
    --    datos_audit           audit_trail,                                                                                                                              --pista de auditoría
    PRIMARY KEY(id_presupuesto)                                                                                                                                       
);

--************************
--** TABLA DE PROYECTOS **
--************************

CREATE TABLE IF NOT EXISTS tab_proyectos
(
    id_proyecto	            VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(id_proyecto)) BETWEEN 1 AND 10),                            -- identificador del proyecto
    nom_proyecto	        VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(nom_proyecto)) BETWEEN 1 AND 254),                          --nombre del proyecto
    VALOR_PROYECTO
    ALCANCE
    COSTO
    fec_inicio              DATE                          NOT NULL      CHECK  (fec_inicio >= '2025-01-01'),                                            --fecha de inicio del proyecto
    fec_fin                 DATE                          NOT NULL      CHECK  (fec_fin > fec_inicio),                                                  --fecha de finalización del proyecto
    resp_proyecto	        VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(resp_proyecto)) BETWEEN 5 AND 60),                          --rresponsable del proyecto
    estado_proyecto         VARCHAR                       NOT NULL      CHECK (estado_proyecto IN ('ACTIVO','SUSPENDIDO','CANCELADO','COMPLETADO')),    --estado del proyecto
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                                                       --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit             audit_trail,                                                                                                              --pista de auditoría
    PRIMARY KEY (id_proyecto),
    FOREIGN KEY (id_inversor)    REFERENCES tab_inversores(id_inversor),
    FOREIGN KEY (id_presupuesto) REFERENCES tab_presupuesto_financi(id_presupuesto)
);

--**************************
--** TABLA DE INDICADORES **
--**************************

CREATE TABLE IF NOT EXISTS tab_indicadores
(
    id_ind	                VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(id_ind)) BETWEEN 1 AND 50),                             --identificador del indicador             --identificador del activo
    descripcion	            TEXT                          NOT NULL       CHECK (LENGTH(TRIM(descripcion)) > 0),                                     --descripción del activo
    tipo	                VARCHAR                       NOT NULL       CHECK (tipo IN ('Rentabilidad','Liquidez','Endeudamiento','Rotación')),    --tipo de activo
    formula	                VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(formula)) BETWEEN 1 AND 255),                           --formula para calcular el activo
    lim_alerta	            DECIMAL   (5,2)               NOT NULL       CHECK (lim_alerta BETWEEN 1 AND 90),                                       --limite de alerta del activo
    frecuencia              VARCHAR                       NOT NULL       CHECK (frecuencia IN ('DIARIO','SEMANAL','MENSUAL','ANUAL')),              --frecuencia de calculo
    ultimo_calculo          TIMESTAMP,                                                                                                              --último cálculo
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                                                   --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit             audit_trail,                                                                                                          --pista de auditoría
    PRIMARY KEY (id_ind)
);

-- ********************************************************
--** TABLA GENERAL DE CATEGORÍAS DE TERCEROS DEL SISTEMA **
--*********************************************************

--ESTA TABLA ES TRASVERSAL

--******************************************************************************
--** TABLA DE RESTRICCIONES DE LOS TERCEROS, QUE IMPIDEN SU ACCESO AL SISTEMA **
--******************************************************************************	

--ESTA TABLA ES TRASVERSAL

--***********************
--** TABLA DE TERCEROS **
--***********************

--ESTA TABLA ES TRASVERSAL

--**********************************
--** TABLA DE VALOR DEL INDICADOR **
--**********************************

CREATE TABLE IF NOT EXISTS tab_val_ind
(
    id_ind	                VARCHAR                        NOT NULL       CHECK (LENGTH(TRIM(id_ind)) BETWEEN 1 AND 50),                                           --identificador del indicador
    fec_calculo	            DATE                           NOT NULL,                                                                                               --fecha del calculo del indicador
    id_pmtro_financiero	    VARCHAR                        NOT NULL       CHECK (LENGTH(TRIM(id_pmtro_financiero)) BETWEEN 1 AND 20),                              --identificador del parámetro financiero
    val_calculado	        DECIMAL  (18,4)                NOT NULL       CHECK (val_calculado >=0),                                                               --valor calculado del indicador
    ind_borrado             BOOLEAN                        NOT NULL DEFAULT FALSE,                                                                                 --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit             audit_trail,                                                                                                                         --pista de auditoría
    PRIMARY KEY (id_val_ind),
    FOREIGN KEY (id_pmtro_financiero)     REFERENCES tab_pmtros_financieros(id_pmtro_financiero),
    FOREIGN KEY (id_ind)                  REFERENCES tab_indicadores(id_ind)
);
-- ********************************
-- **    TABLA DE INVERSIONES    **
-- ********************************

CREATE TABLE IF NOT EXISTS tab_inversiones
(
PROYECTO
INVERSION
VALOR PARETICIPA
    id_inversion            VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(id_inversion)) BETWEEN 5 AND 20),                                    --identificador de la inversión
    id_inversor             VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(id_inversor)) =10),                                                  --identificación del inversor
    id_proyecto             VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(id_proyecto)) BETWEEN 1 AND 10),                                     --identificador del proyecto
    por_participacion       DECIMAL   (4,1)               NOT NULL    CHECK   (por_participacion > 0 AND por_participacion <= 100),                   --porcentaje de participación del inversor
    tipo_inversion          VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(tipo_inversion)) BETWEEN 1 AND 80),                                  --tipo de inversión
    entidad_financiera      VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(entidad_financiera)) BETWEEN 2 AND 100),                             --entidad financiera
    monto_inversion         DECIMAL   (18,2)              NOT NULL        CHECK (monto_inversion > 0),                                                            --monto de la inversión
    tasa_interes            DECIMAL   (5,2)               NOT NULL        CHECK (tasa_interes BETWEEN 0 AND 100),                                                 --tasa de interés
    tasa_efectividad        DECIMAL   (5,2)               NOT NULL        CHECK (tasa_efectividad BETWEEN 0 AND 100),                                             --tasa efectividad
    fecha_inicio            DATE                          NOT NULL        CHECK (fecha_inicio >= '2025-01-01'),                                                   --fecha de inicio
    fecha_vencimiento       DATE                          NOT NULL        CHECK (fecha_vencimiento > fecha_inicio),                                               --fecha de vencimiento
    estado_inversion        VARCHAR                       NOT NULL        CHECK (estado_inversion IN ('VIGENTE','VENCIDA','RENOVADA','CANCELADA','LIQUIDADA')),   --estado de la inversión
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                                                                 --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit audit_trail,                                                                                                                        --pista de auditoría
    PRIMARY KEY (id_inversion),
    FOREIGN KEY (id_inversor)    REFERENCES tab_inversores(id_inversor),
    FOREIGN KEY (id_proyecto)    REFERENCES tab_proyectos(id_proyecto)
);
-- ---------------------------------------------------
-- 7. CONFIGURACIÓN DEL SEARCH_PATH (Ruta de Búsqueda)
-- Esto permite que los módulos accedan a 'public' sin prefijo.
-- Se establece el path por defecto para que las consultas busquen 
-- primero en 'public' y luego en el esquema actual de la sesión.
-- (Aunque las aplicaciones siempre deberían usar el prefijo por seguridad, 
-- esta es una configuración común).
-- ---------------------------------------------------

-- Ejemplo de configuración para un usuario específico (opcional, pero recomendado 
-- si se crean roles específicos para cada módulo).
-- ALTER USER app_user SET search_path TO "$user", public;

-- Configuración general de la base de datos (para quien no tenga un path definido)
--ALTER DATABASE db_erpadso SET search_path TO public, "$user";

-- ---------------------------------------------------------------------
-- 8. CREACIÓN DE TRIGGER DE AUDITORÍA PARA LAS TABLAS. ESTRUCTURA TYPE
------------------------------------------------------------------------

-- ---------------------------------------------------
-- 02_create_audit_trail.sql
-- Creación de la tabla de registros de auditoría 
-- y la función de trigger.
-- ---------------------------------------------------

-- ---------------------------------------------------
-- 9. CREAR LA TABLA CENTRAL DE REGISTROS DE AUDITORÍA
-- Ubicada en 'public' para un acceso sencillo desde todos los esquemas.
-- ---------------------------------------------------
CREATE TABLE public.tab_audit_trail
(
    id_registro         BIGSERIAL,
    txid                BIGINT      NOT NULL DEFAULT txid_current(),
    nom_esquema         TEXT        NOT NULL,
    nom_tabla           TEXT        NOT NULL,
    ind_operacion       CHAR(1)     NOT NULL,
    usuario_db          TEXT        NOT NULL DEFAULT CURRENT_USER,
    usuario_erp_id      INT,
    fec_registro        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    datos_viejos        JSONB,
    datos_nuevos        JSONB
); 

-- Crear índice sobre la tabla particionada
CREATE INDEX idx_auditoria_tabla_fecha ON public.tab_audit_trail(nom_tabla, fec_registro DESC);

-- ---------------------------------------------------
-- 10. FUNCIÓN DE TRIGGER DE AUDITORÍA (CORREGIDA)
-- ---------------------------------------------------
CREATE OR REPLACE FUNCTION public.fun_audit_trail() RETURNS TRIGGER AS $$
DECLARE 
    w_old_data JSONB;
    w_new_data JSONB;
    w_operacion CHAR(1);
BEGIN
    -- Determinar qué datos guardar según la operación
    IF (TG_OP = 'UPDATE') THEN
        w_old_data := to_jsonb(OLD);
        w_new_data := to_jsonb(NEW);
        
        -- Detectar si es un borrado lógico (cambio de ind_borrado a TRUE)

        IF (OLD.ind_borrado = FALSE AND NEW.ind_borrado = TRUE) THEN
            w_operacion := 'D';  -- Registrar como DELETE

        ELSIF (OLD.ind_borrado = TRUE AND NEW.ind_borrado = FALSE) THEN
            w_operacion := 'R';  -- Registrar como RESTORE

        ELSE
            w_operacion := 'U';  -- Registrar como UPDATE
        END IF;  
        
    ELSIF (TG_OP = 'INSERT') THEN
        w_old_data := NULL;
        w_new_data := to_jsonb(NEW);
        w_operacion := 'I';  -- Registrar como INSERT
    ELSE
-- No debería ocurrir
        RETURN NULL;
    END IF;
-- Insertar el registro de auditoría
    INSERT INTO public.tab_audit_trail (nom_esquema,nom_tabla,ind_operacion,usuario_erp_id,datos_viejos,datos_nuevos)
    VALUES (TG_TABLE_SCHEMA, -- Obtiene el nombre del esquema
            TG_TABLE_NAME,   -- Obtiene el nombre de la tabla
            w_operacion,
            NULL, -- !!OJO!!!, Aquí se debe integrar la lógica para obtener el ID del usuario ERP
            w_old_data,
            w_new_data);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- SECURITY DEFINER: Importante para asegurar que el trigger se ejecute 
-- con los permisos del creador (que tiene acceso a public.auditoria_registros)

-- ------------------------------------------------------------------
-- 11. EJEMPLO DE ASIGNACIÓN DEL TRIGGER A UNA TABLA MODULAR (public)
-- ------------------------------------------------------------------
-- Asumimos que esta tabla ya existe en el esquema public
-- CREATE TABLE IF NOT EXISTS public.tab_dptos; 
-- ------------------------------------------------------------------

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_dptos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_ciudades
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_cat_terceros
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_restricciones
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_terceros
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_areas
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_menus
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON public.tab_usuarios
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();



-- DATA INICIAL DE PRUEBA
ALTER TABLE tab_usuarios ALTER COLUMN pass_usuario TYPE VARCHAR(255);
INSERT INTO tab_usuarios VALUES('admin','Administrador del Sistema',CRYPT('Admin12345678!', GEN_SALT('bf')),
                                'admin@correo.edu',TRUE,TRUE)
ON CONFLICT (id_usuario) DO NOTHING;

-- CREACIÓN DE EXTENSIÓN PARA ENCRIPTACIÓN
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- ENCRIPTAR CLAVE DE ADMIN
UPDATE tab_usuarios SET pass_usuario = crypt('Admin12345678!', gen_salt('bf')) 
WHERE id_usuario = 'admin';



-- CARGA DE TABLA DE MENÚS INICIAL

SELECT fun_insert_tab_menus ('1','Configuración','0');
SELECT fun_insert_tab_menus ('11','Parámetros','1','pmtros.php');
SELECT fun_insert_tab_menus ('12','Gestión de Accesos','1');
SELECT fun_insert_tab_menus ('121','Usuarios','12','usuarios.php');
SELECT fun_insert_tab_menus ('122','Cambio de Clave','12','cambiar_clave.php');
SELECT fun_insert_tab_menus ('123','Menús','12','menus.php');
SELECT fun_insert_tab_menus ('124','Menús de Usuario','12','menu_usuarios.php');
SELECT fun_insert_tab_menus ('125','Copiar un Perfil','12','copiar_menu_usuarios.php');
SELECT fun_insert_tab_menus ('13','Tablas Maestras','1');
SELECT fun_insert_tab_menus ('131','Departamentos','13','dptos.php');
SELECT fun_insert_tab_menus ('132','Ciudades','13','ciudades.php');
SELECT fun_insert_tab_menus ('133','Cargos','13','cargos.php');
SELECT fun_insert_tab_menus ('134','Profesiones','13','profesiones.php');
SELECT fun_insert_tab_menus ('135','Áreas','13','areas.php');

-- CARGA INICIAL DE FACTURACIÓN

SELECT fun_insert_tab_menus ('2','Facturación y Cartera','0','no_aplica');
SELECT fun_insert_tab_menus ('21','Cotizaciones','2','no_aplica');
SELECT fun_insert_tab_menus ('211','Nueva Cotización','21','modules/faccar/nueva_cotizacion.php');
SELECT fun_insert_tab_menus ('212','Consultar Cotizaciones','21','faccar/consultar_cotizaciones.php');
SELECT fun_insert_tab_menus ('22','Facturación','2','no_aplica');
SELECT fun_insert_tab_menus ('221','Nueva Factura','22','faccar/nueva_factura.php');
SELECT fun_insert_tab_menus ('222','Consultar Facturas','22','faccar/consultar_facturas.php');
SELECT fun_insert_tab_menus ('23','Notas','2','no_aplica');
SELECT fun_insert_tab_menus ('231','Notas De Crédito','23','faccar/nota_credito.php');
SELECT fun_insert_tab_menus ('232','Notas De Débito','23','faccar/nota_debito.php');
SELECT fun_insert_tab_menus ('233','Consultar Notas','23','faccar/consultar_notas.php');
SELECT fun_insert_tab_menus ('24','Carteras','2','no_aplica');
SELECT fun_insert_tab_menus ('241','Gestión de Carteras','24','faccar/gestion_carteras.php');
SELECT fun_insert_tab_menus ('242','Seguimiento de Carteras','24','faccar/segimiento_carteras.php');
SELECT fun_insert_tab_menus ('243','Condición de Pago','24','faccar/condicion_pago.php');
SELECT fun_insert_tab_menus ('244','Registro de Pagos','24','faccar/registro_pagos.php');
SELECT fun_insert_tab_menus ('25','Gestión','2','no_aplica');
SELECT fun_insert_tab_menus ('251','Clientes','25','faccar/clientes.php');
SELECT fun_insert_tab_menus ('252','Credito del Cliente','25','faccar/credito_cliente.php');
SELECT fun_insert_tab_menus ('253','Vendedores','25','faccar/vendedores.php');
SELECT fun_insert_tab_menus ('254','Parametros','25','faccar/parametros.php');

-- CARGA INICIAL DE COMPRAS Y PROVEEDORES

SELECT fun_insert_tab_menus('3','Compras Y Proveedores','0','no_aplica');
SELECT fun_insert_tab_menus('31','Dashboard','3','modules/compro/dashboard.php');
SELECT fun_insert_tab_menus('32','Proveedores','3','modules/compro/proveedores.php');
SELECT fun_insert_tab_menus('33','Productos','3','modules/compro/productos.php');
SELECT fun_insert_tab_menus('34','CatxProv','3','modules/compro/catxprov.php');
SELECT fun_insert_tab_menus('35','Ordenes de compra','3','modules/compro/ordencompra.php');

-- CARGA INICIAL DE TESORERIA Y CXP

SELECT fun_insert_tab_menus('4','Tesorería y Cuentas por Pagar','0','no_aplica');
SELECT fun_insert_tab_menus('41','Parámetros de Tesorería','4','pmtrosphp');
SELECT fun_insert_tab_menus('42','Bancos por Proveedores','4','banxprov.php');
SELECT fun_insert_tab_menus('43','Facturas','4','facturastcxp.php');
SELECT fun_insert_tab_menus('44','Programación de pagos','4','progpagos.php');
SELECT fun_insert_tab_menus('45','Pagos','4','pagos.php');
SELECT fun_insert_tab_menus('46','Dispersión de Nómina','4','dispnom.php');

-- CARGA INICIAL DE MARKETING

SELECT fun_insert_tab_menus('5', 'Marketing & Comercial', '5', 'no_aplica');
SELECT fun_insert_tab_menus('51', 'Dashboard', '51', 'modules/marcom/dashboard_php');
SELECT fun_insert_tab_menus('52', 'Leads', '52', 'modules/marcom/leads.php');
SELECT fun_insert_tab_menus('53', 'Clientes', '53', 'modules/marcom/clientes.php');
SELECT fun_insert_tab_menus('54', 'Embudo de Ventas', '54', 'modules/marcom/funnel_ventas.php');
SELECT fun_insert_tab_menus('55', 'Campañas', '55', 'modules/marcom/campanas.php');
SELECT fun_insert_tab_menus('56', 'Eventos', '56', 'modules/marcom/eventos.php');
SELECT fun_insert_tab_menus('57', 'Reportes KPI', '57', 'modules/marcom/reportes_kpi.php');
SELECT fun_insert_tab_menus('58', 'Configuración', '58', 'no_aplica');
SELECT fun_insert_tab_menus('581', 'Parámetros', '581', 'modules/marcom/pmtros_php');
SELECT fun_insert_tab_menus('582', 'Funnel', '582', 'modules/marcom/parametros_funnel.php');
SELECT fun_insert_tab_menus('583', 'Canales', '583', 'modules/marcom/parametros_canales.php');
SELECT fun_insert_tab_menus('584', 'Segmentación', '584', 'modules/marcom/parametros_segmentacion.php');
SELECT fun_insert_tab_menus('585', 'Motivos Pérdida', '585', 'modules/marcom/motivos_perdida.php');
SELECT fun_insert_tab_menus('586', 'KPIs', '586', 'modules/marcom/parametros_kpi.php');
SELECT fun_insert_tab_menus('587', 'Usuarios', '587', 'modules/marcom/config_usuarios.php');

-- CARGA INICIAL DE CONTABILIDAD
-- ========== NIVEL 1: MÓDULO PRINCIPAL ==========
SELECT fun_insert_tab_menus ('6', 'Contabilidad y Presupuesto', '0', 'no_aplica');

SELECT fun_insert_tab_menus ('61', 'Plan único de cuentas', '6', 'modules/conpre/contab/puc.php');

SELECT fun_insert_tab_menus ('62', 'Activos fijos', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('621', 'Crear activos fijos', '62', 'modules/conpre/contab/activos.php');
SELECT fun_insert_tab_menus ('622', 'Categoría activos fijos', '62', 'modules/conpre/contab/cat_activos.php');
SELECT fun_insert_tab_menus ('623', 'Depreciación', '62', 'modules/conpre/contab/depreciacion.php');


SELECT fun_insert_tab_menus ('63', 'Presupuesto', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('631', 'Presupuesto por Areas', '63', 'modules/conpre/contab/presupuesto.php');
SELECT fun_insert_tab_menus ('632', 'Tipos de presupuesto', '63', 'modules/conpre/contab/tipo_presupuesto.php');
SELECT fun_insert_tab_menus ('633', 'Periodos de presupuesto', '63', 'modules/conpre/contab/periodo_presupuesto.php');
SELECT fun_insert_tab_menus ('634', 'Planeación de presupuesto', '63', 'modules/conpre/contab/planeacion_presupuesto.php');
SELECT fun_insert_tab_menus ('635', 'Detalle de presupuesto', '63', 'modules/conpre/contab/detalle_presupuesto.php');
SELECT fun_insert_tab_menus ('636', 'Ejecución de presupuesto', '63', 'modules/conpre/contab/ejecucion_presupuesto.php');

SELECT fun_insert_tab_menus ('64', 'Comprobantes contables', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('641', 'Crear comprobante Contable', '64', 'modules/conpre/contab/comprobante.php');
SELECT fun_insert_tab_menus ('642', 'Tipos de comprobantes', '64', 'modules/conpre/contab/tipo_comprobante.php');
SELECT fun_insert_tab_menus ('643', 'Registro de comprobantes', '64', 'modules/conpre/contab/registro_comprobante.php');
SELECT fun_insert_tab_menus ('644', 'Detalle de comprobantes', '64', 'modules/conpre/contab/detalle_comprobante.php');

SELECT fun_insert_tab_menus ('65', 'Notas contables', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('651', 'Crear nota', '65', 'modules/conpre/contab/nota.php');
SELECT fun_insert_tab_menus ('651', 'Tipos de nota', '65', 'modules/conpre/contab/tipos_nota.php');
SELECT fun_insert_tab_menus ('652', 'Registro de nota', '65', 'modules/conpre/contab/registro_nota.php');

SELECT fun_insert_tab_menus ('66', 'Parámetros contables', '6', 'modules/conpre/contab/parametros_contab.php');

SELECT fun_insert_tab_menus ('67', 'Caja menor', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('671', 'Crear caja menor', '67', 'modules/conpre/contab/caja.php');
SELECT fun_insert_tab_menus ('671', 'Configuración de caja menor', '67', 'modules/conpre/contab/config_caja.php');
SELECT fun_insert_tab_menus ('672', 'Movimientos de caja menor', '67', 'modules/conpre/contab/mov_caja.php');


-- CARGA INICIAL DE ANALISIS FINANCIERO

SELECT fun_insert_tab_menus('7', 'Análisis Financiero',  '0', 'no_aplica');
SELECT fun_insert_tab_menus('71', 'Dashboard Financiero',  '7', 'modules/conpre/dashboard.php');
SELECT fun_insert_tab_menus('72', 'Indicadores',  '7', 'modules/conpre/indicadores.php');
SELECT fun_insert_tab_menus('73', 'Presupuesto',  '7', 'modules/conpre/presupuesto.php');
SELECT fun_insert_tab_menus('74', 'Inversores',  '7', 'modules/conpre/inversores.php');
SELECT fun_insert_tab_menus('75', 'Proyectos',  '7', 'modules/conpre/proyectos.php');
SELECT fun_insert_tab_menus('76', 'Inversiones',  '7', 'modules/conpre/inversiones.php');
SELECT fun_insert_tab_menus('78', 'Reportes',  '7', 'modules/conpre/reportes.php');

-- CARGA INICIAL DE RECURSOS HUMANOS

SELECT fun_insert_tab_menus ('8', 'Recursos Humanos', '0', 'no_aplica');

--DASHBOARD
SELECT fun_insert_tab_menus ('81', 'Dashboard', '8', 'modules/gehnom/src/dashboard_principal.php');

--RECLUTAMIENTO
SELECT fun_insert_tab_menus ('82', 'Reclutamiento', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('821', 'Vacantes', '82', 'modules/gehnom/src/vacantes.php');
SELECT fun_insert_tab_menus ('822', 'Postulaciones', '82', 'modules/gehnom/src/postulaciones.php');
SELECT fun_insert_tab_menus ('823', 'Candidatos', '82', 'modules/gehnom/src/candidatos.php');
SELECT fun_insert_tab_menus ('824', 'Pruebas', '82', 'modules/gehnom/src/pruebas.php');

--GESTIÓN DE PERSONAL
SELECT fun_insert_tab_menus ('83', 'Gestión de personal', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('831', 'Empleados', '83', 'modules/gehnom/src/empleados.php');
SELECT fun_insert_tab_menus ('832', 'Contratos', '83', 'modules/gehnom/src/contratos.php');
SELECT fun_insert_tab_menus ('833', 'Cargos', '83', 'modules/gehnom/src/cargos.php');
SELECT fun_insert_tab_menus ('834', 'Disciplina', '83', 'modules/gehnom/src/disciplina.php');
SELECT fun_insert_tab_menus ('835', ' Evaluaciones de desempeño', '83', 'modules/gehnom/src/evaluaciones_desempeño.php');

SELECT fun_insert_tab_menus ('836', 'Dotación', '83', 'modules/gehnom/src/dotacion.php');
SELECT fun_insert_tab_menus ('8361', 'Entrega de dotación', '836', 'modules/gehnom/src/entrega_dotacion.php');
SELECT fun_insert_tab_menus ('837', 'Capacitación', '83', 'modules/gehnom/src/capacitacion.php');
SELECT fun_insert_tab_menus ('8371', 'Asistencia de capacitación', '837', 'modules/gehnom/src/asistencia_capacitacion.php');

--TIEMPOS Y NOVEDADES
SELECT fun_insert_tab_menus ('84', 'Tiempos y Novedades', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('841', 'Horas Extras', '84', 'modules/gehnom/src/horas_extras.php');
SELECT fun_insert_tab_menus ('842', 'Novedades', '84', 'modules/gehnom/src/novedades.php');

--NÓMINA
SELECT fun_insert_tab_menus ('85', 'Nómina', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('851', 'Liquidación Mensual', '85', 'modules/gehnom/src/liquidacion_mensual.php');
SELECT fun_insert_tab_menus ('852', 'Provisiones', '85', 'modules/gehnom/src/provisiones.php');
SELECT fun_insert_tab_menus ('853', 'Liquidación de Retiros', '85', 'modules/gehnom/src/liquidacion_retiros.php');
SELECT fun_insert_tab_menus ('854', 'Nómina Electrónica', '85', 'modules/gehnom/src/nomina_electronica.php');
SELECT fun_insert_tab_menus ('855', 'Conceptos de Nómina', '85', 'modules/gehnom/src/conceptos_nomina.php');
SELECT fun_insert_tab_menus ('856', 'Préstamos', '85', 'modules/gehnom/src/prestamos.php');

--CONFIGURACIÓN (solo Parámetros Legales)
SELECT fun_insert_tab_menus ('86', 'Configuración parámetros legales', '8', ' modules/gehnom/src/parametros_legales.php');

-- CARGA INICIAL DE SST

SELECT fun_insert_tab_menus  ('9','SST','0','no_aplica');
SELECT fun_insert_tab_menus  ('91','Resumen','9','modules/sesatr/dashboard.php');
SELECT fun_insert_tab_menus  ('92', 'Accidentes', '9', 'modules/sesatr/Accidentes.php');
SELECT fun_insert_tab_menus  ('93', 'Incapacidades','9', 'modules/sesatr/Incapacidades.php');
SELECT fun_insert_tab_menus  ('94', 'Capacitaciones', '9', 'modules/sesatr/Capacitaciones.php');
SELECT fun_insert_tab_menus  ('95', 'Auditoria', '9', 'modules/sesatr/Auditoria.php');
SELECT fun_insert_tab_menus  ('96', 'Empleados', '9', 'modules/sesatr/Empleados.php');
SELECT fun_insert_tab_menus  ('97', 'Brigadistas', '9', 'modules/sesatr/Brigadistas.php');
SELECT fun_insert_tab_menus  ('98', 'Examenes', '9', 'modules/sesatr/Examenes.php');
SELECT fun_insert_tab_menus  ('99', 'EPP','9', 'modules/sesatr/EPP.php');

-- CARGA INICIAL DE GESTIÓN DOCUMENTAL Y CALIDAD

SELECT fun_insert_tab_menus ('10','Gestión Documental y Calidad','0','no_aplica');
SELECT fun_insert_tab_menus ('101','Correspondencia','10','no_aplica');
SELECT fun_insert_tab_menus ('102','Expedientes','10', 'no_aplica');
SELECT fun_insert_tab_menus ('1021','Crear expediente','102','modules/gedcal/src/expedientes_crear.php');
SELECT fun_insert_tab_menus ('1022','Gestionar expedientes','102','modules/gedcal/src/expedientes_gestionar.php');
SELECT fun_insert_tab_menus ('103','PQRS','10','no_aplica');
SELECT fun_insert_tab_menus ('1031','Radicar PQRS','103','modules/gedcal/src/pqrs_radicar.php');
SELECT fun_insert_tab_menus ('1032','Bandeja PQRS','103','modules/gedcal/src/pqrs_bandeja.php');
SELECT fun_insert_tab_menus ('1033','Seguimiento y respuestas','103','modules/gedcal/src/pqrs_seguimiento.php');
SELECT fun_insert_tab_menus ('104','flujo_documental','10','no_aplica');
SELECT fun_insert_tab_menus ('1041','Control de documentos','104', 'modules/gedcal/src/calidad_documentos.php');
SELECT fun_insert_tab_menus ('1042','Workflow de aprdcobación','104','gedcal/src/calidad_workflow.php');
SELECT fun_insert_tab_menus ('105','trazabilidad','10','no_aplica');
SELECT fun_insert_tab_menus ('1051','Procesos','105','modules/gedcal/src/calidad_procesos.php');
SELECT fun_insert_tab_menus ('1052','Auditorías','105','modules/gedcal/src/calidad_auditorias.php');
SELECT fun_insert_tab_menus ('1053','Hallazgos y acciones','105','modules/gedcal/src/calidad_hallazgos.php');
SELECT fun_insert_tab_menus ('106','calidad','10','no_aplica');
SELECT fun_insert_tab_menus ('1061','Tipos de Documento', '106', 'modules/gedcal/src/tipos_documento.php');
SELECT fun_insert_tab_menus ('1062','Orígenes de Correspondencia', '106', 'modules/gedcal/src/origenes_correspondencia.php');
SELECT fun_insert_tab_menus ('1063','Niveles de Acceso','106','modules/gedcal/src/niveles_acceso.php');
SELECT fun_insert_tab_menus ('1064','Tablas de Retención (TRD)','106','modules/gedcal/src/trd.php');
SELECT fun_insert_tab_menus ('1065','Estados de Correspondencia','106','modules/gedcal/src/estados_correspondencia.php');
SELECT fun_insert_tab_menus ('1066','Acciones Workflow Doc.','106','modules/gedcal/src/acciones_workflow_doc.php');
SELECT fun_insert_tab_menus ('1067','Tipos de PQRS','106','modules/gedcal/src/tipos_pqrs.php');
SELECT fun_insert_tab_menus ('1068','Canales de PQRS','106','modules/gedcal/src/canales_pqrs.php');
SELECT fun_insert_tab_menus ('1069','Estados de PQRS','106','modules/gedcal/src/estados_pqrs.php');
SELECT fun_insert_tab_menus ('1070','Motivos de PQRS','106','modules/gedcal/src/motivos_pqrs.php');
SELECT fun_insert_tab_menus ('1071','Parámetros de Vencimiento PQRS','106','modules/gedcal/src/param_venc_pqrs.php');
SELECT fun_insert_tab_menus ('1072','Riesgos','106','modules/gedcal/src/riesgos.php');
SELECT fun_insert_tab_menus ('1073','Normas','106','modules/gedcal/src/normas.php');
SELECT fun_insert_tab_menus ('1074','Estados Documentales','106','modules/gedcal/src/estados_documento.php');
SELECT fun_insert_tab_menus ('1075','Acciones Workflow Calidad','106','modules/gedcal/src/acciones_workflow.php');