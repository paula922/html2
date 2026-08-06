-- --------------------------------------------------------|
-- SCRIPT ADSO ERP                                         |
-- Script de creacion de tablas del sistema automatizado   |
-- Autor: Carlos Eduardo Perez & equipo de ADSO 3171727    |
-- Versión: 1.7 - Junio de 2026                            |
-- --------------------------------------------------------|

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
-- 3.1 BORRADO DE TABLAS PARA FINANCIERA
-- ----------------------------------------------

DROP TABLE IF EXISTS tab_inversiones;
DROP TABLE IF EXISTS tab_val_ind;
DROP TABLE IF EXISTS tab_indicadores;
DROP TABLE IF EXISTS tab_proyectos;
DROP TABLE IF EXISTS tab_inversores;
DROP TABLE IF EXISTS tab_pmtros_financieros;


--TABLAS EN LA LINEA 3830--

--------------------------------------------------------------------------------------------------------
-- 3.2 ELIMINACIoN DE TABLAS Y SECUENCIAS DE GESTION DOCUMENTAL Y CALIDAD
--------------------------------------------------------------------------------------------------------
-- La eliminacion se realiza en orden inverso a la creacion para respetar
-- las dependencias entre tablas (primero las tablas que tienen FK hacia otras,
-- luego las tablas referenciadas).
--------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS tab_workflow;
DROP SEQUENCE IF EXISTS seq_workflow;
DROP TABLE IF EXISTS tab_doc_anexo;
DROP TABLE IF EXISTS tab_accion_correctiva;
DROP TABLE IF EXISTS tab_hallazgo;
DROP TABLE IF EXISTS tab_auditorias;
DROP TABLE IF EXISTS tab_procesos;
DROP TABLE IF EXISTS tab_doc_archivo;
DROP TABLE IF EXISTS tab_doc_norma;
DROP TABLE IF EXISTS tab_det_documento;
DROP TABLE IF EXISTS tab_enc_documento;
DROP TABLE IF EXISTS tab_accion_workflow;
DROP TABLE IF EXISTS tab_estado_documento;
DROP TABLE IF EXISTS tab_certificacion;
DROP TABLE IF EXISTS tab_normas;
DROP TABLE IF EXISTS tab_anexo_pqrs;
DROP TABLE IF EXISTS tab_respuesta_pqrs;
DROP SEQUENCE IF EXISTS seq_respuesta_pqrs;
DROP TABLE IF EXISTS tab_seg_pqrs;
DROP SEQUENCE IF EXISTS seq_seg_pqrs;
DROP TABLE IF EXISTS tab_det_pqrs;
DROP SEQUENCE IF EXISTS seq_det_pqrs;
DROP TABLE IF EXISTS tab_enc_pqrs;
DROP TABLE IF EXISTS tab_motivo_pqrs;
DROP TABLE IF EXISTS tab_estado_pqrs;
DROP TABLE IF EXISTS tab_param_venc_pqrs;
DROP TABLE IF EXISTS tab_tipo_pqrs;
DROP SEQUENCE IF EXISTS seq_workflow_expediente;
DROP SEQUENCE IF EXISTS seq_permiso_acceso;
DROP TABLE IF EXISTS tab_notificaciones;
DROP SEQUENCE IF EXISTS seq_notificacion;
DROP TABLE IF EXISTS tab_doc_expediente;
DROP TABLE IF EXISTS tab_expediente;
DROP SEQUENCE IF EXISTS seq_archivo_digital;
DROP TABLE IF EXISTS tab_indexacion;
DROP SEQUENCE IF EXISTS seq_indexacion;
DROP TABLE IF EXISTS tab_correspondencia;
DROP TABLE IF EXISTS tab_accion_workflow;
DROP TABLE IF EXISTS tab_estado_correspondencia;
DROP TABLE IF EXISTS tab_tabla_retencion;
DROP TABLE IF EXISTS tab_tipo_documento;

-- ----------------------------------------------
-- 3.3 BORRADO DE TABLAS PARA TESORERIA
-- ----------------------------------------------

DROP TABLE IF EXISTS tab_det_archivo_plano;
DROP TABLE IF EXISTS tab_enc_archivo_plano;
DROP TABLE IF EXISTS tab_det_cronopagos;
DROP TABLE IF EXISTS tab_enc_cronopagos;
DROP TABLE IF EXISTS tab_cuotasxfactura;
DROP TABLE IF EXISTS tab_cuentasxpagar;
DROP TABLE IF EXISTS tab_bancoxprov;
DROP TABLE IF EXISTS tab_ctas_empresa;
DROP TABLE IF EXISTS tab_pmtros_tescxp;
DROP TABLE IF EXISTS tab_det_caja_menor;
DROP TABLE IF EXISTS tab_enc_caja_menor;
DROP TABLE IF EXISTS tab_festivos;

-- ----------------------------------------------
-- 3.4 BORRADO DE TABLAS PARA FACTURACIÓN
-- ----------------------------------------------

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

-- ----------------------------------------------
-- 3.5 BORRADO DE TABLAS PARA MARKETING
-- ----------------------------------------------
DROP TABLE IF EXISTS tab_envios;
DROP TABLE IF EXISTS tab_proximas_acciones;
DROP TABLE IF EXISTS tab_medicion_kpi;
DROP TABLE IF EXISTS tab_prod_camp;
DROP TABLE IF EXISTS tab_even_lead;
DROP TABLE IF EXISTS tab_contactos_adicionales;
DROP TABLE IF EXISTS tab_interacciones;
DROP TABLE IF EXISTS tab_lead_camp;
DROP TABLE IF EXISTS tab_cliente_camp;
DROP TABLE IF EXISTS tab_segmentacion_lead;
DROP TABLE IF EXISTS tab_segmentacion_cliente;
DROP TABLE IF EXISTS tab_presupuesto_campana;
DROP TABLE IF EXISTS tab_presupuesto_evento;
DROP TABLE IF EXISTS tab_campana_canal;
DROP TABLE IF EXISTS tab_plantillas_correo;
DROP TABLE IF EXISTS tab_condiciones_regla_marcom;
DROP TABLE IF EXISTS tab_operadores_marcom;
DROP TABLE IF EXISTS tab_reglas_segmentacion;
DROP TABLE IF EXISTS tab_leads;
DROP TABLE IF EXISTS tab_evento;
DROP TABLE IF EXISTS tab_campanas;
DROP TABLE IF EXISTS tab_campos_segmentacion_marcom;
DROP TABLE IF EXISTS tab_atributos_marcom;
DROP TABLE IF EXISTS tab_tablas_marcom;
DROP TABLE IF EXISTS tab_valores_segmentacion;
DROP TABLE IF EXISTS tab_tipo_campana;
DROP TABLE IF EXISTS tab_criterios_segmentacion;
DROP TABLE IF EXISTS tab_motivos_perdida;
DROP TABLE IF EXISTS tab_kpis_marcom;
DROP TABLE IF EXISTS tab_tipos_interaccion_marcom;
DROP TABLE IF EXISTS tab_etapas_funnel;
DROP TABLE IF EXISTS tab_canales;
DROP TABLE IF EXISTS tab_pmtros_marcom;

-- ----------------------------------------------
-- 3.6 BORRADO DE TABLAS PARA SST
-- ----------------------------------------------

DROP TABLE IF EXISTS tab_accidentes;
DROP TABLE IF EXISTS tab_auditorias_sst;
DROP TABLE IF EXISTS tab_inspeccion; 
DROP TABLE IF EXISTS tab_asist_copasst; 
DROP TABLE IF EXISTS tab_reu_copasst;
DROP TABLE IF EXISTS tab_miem_copasst; 
DROP TABLE IF EXISTS tab_copasst; 
DROP TABLE IF EXISTS tab_emergencia; 
DROP TABLE IF EXISTS tab_brigadistas; 
DROP TABLE IF EXISTS tab_brigada;
DROP TABLE IF EXISTS tab_asis_cap;
DROP TABLE IF EXISTS tab_capacitaciones;
DROP TABLE IF EXISTS tab_docentes;
DROP TABLE IF EXISTS tab_temas_cap;
DROP TABLE IF EXISTS tab_incapacidades;
DROP TABLE IF EXISTS tab_tipo_incapacidad;
DROP TABLE IF EXISTS tab_det_ex_ingreso;
DROP TABLE IF EXISTS tab_enc_ex_ingreso;
DROP TABLE IF EXISTS tab_examenes;
DROP TABLE IF EXISTS tab_epp_inspeccion;
DROP TABLE IF EXISTS tab_epp_asignacion;
DROP TABLE IF EXISTS tab_epp; 
DROP TABLE IF EXISTS tab_tipo_acc;

-- ----------------------------------------------
-- 3.7 BORRADO DE TABLAS PARA GESTIÓN HUMANA
-- ----------------------------------------------

DROP TABLE IF EXISTS tab_nomina_electronica;
DROP TABLE IF EXISTS tab_nomina;                    
DROP TABLE IF EXISTS tab_procesos_disciplinarios;   
DROP TABLE IF EXISTS tab_novedades;     
DROP TABLE IF EXISTS tab_conceptos;
DROP TABLE IF EXISTS tab_prestamos;     
DROP TABLE IF EXISTS tab_empleados;
DROP TABLE IF EXISTS tab_candidatos;
DROP TABLE IF EXISTS tab_entidades;         
DROP TABLE IF EXISTS tab_cargos;
DROP TABLE IF EXISTS tab_profesiones;
DROP TABLE IF EXISTS tab_escolaridad;
DROP TABLE IF EXISTS tab_pmtros_legales;

-- ----------------------------------------------
-- 3.8 BORRADO DE TABLAS PARA COMPRAS
-- ----------------------------------------------

DROP VIEW  IF EXISTS vw_semaforo_ordcomp;
DROP TABLE IF EXISTS tab_det_seg_ordcomp;
DROP TABLE IF EXISTS tab_seg_ordcomp;
DROP TABLE IF EXISTS tab_det_ordcomp;
DROP TABLE IF EXISTS tab_enc_ordcomp;
DROP TABLE IF EXISTS tab_det_solcomp;
DROP TABLE IF EXISTS tab_enc_solcomp;
DROP TABLE IF EXISTS tab_prodxprov;
DROP TABLE IF EXISTS tab_productos;
DROP TABLE IF EXISTS tab_eval_prov;
DROP TABLE IF EXISTS tab_proveedores;
DROP TABLE IF EXISTS tab_pmtros_compras;

-- ----------------------------------------------
-- 3.9 BORRADO DE TABLAS PARA CONTABILIDAD
-- ----------------------------------------------
DROP TABLE IF EXISTS tab_det_comprobantes;       
DROP TABLE IF EXISTS tab_ejecucion_presupuesto;  
DROP TABLE IF EXISTS tab_det_presupuesto;        
DROP TABLE IF EXISTS tab_enc_comprobantes;    
DROP TABLE IF EXISTS tab_planeacion_presupuesto; 
DROP TABLE IF EXISTS tab_enc_presupuesto;            
DROP TABLE IF EXISTS tab_depreciacion;           
DROP TABLE IF EXISTS tab_act_fijos;              
DROP TABLE IF EXISTS tab_parametros_contab;      
DROP TABLE IF EXISTS tab_periodos_contables;     
DROP TABLE IF EXISTS tab_tip_comprobantes;       
DROP TABLE IF EXISTS tab_tip_notas;              
DROP TABLE IF EXISTS tab_tipo_presupuesto;       
DROP TABLE IF EXISTS tab_period_presupuesto;     
DROP TABLE IF EXISTS tab_cat_activos;            
DROP TABLE IF EXISTS tab_puc;        

-- ----------------------------------------------
-- 3.10 BORRADO DE TABLAS GENERAL
-- ----------------------------------------------

DROP TABLE IF EXISTS tab_riesgos;
DROP TABLE IF EXISTS tab_areas;
DROP TABLE IF EXISTS tab_sesiones;
DROP TABLE IF EXISTS tab_menu_usuarios;
DROP TABLE IF EXISTS tab_menus;
DROP TABLE IF EXISTS tab_usuarios;
DROP TABLE IF EXISTS tab_bancos;
DROP TABLE IF EXISTS tab_terceros;
DROP TABLE IF EXISTS tab_tel_prefijo;
DROP TABLE IF EXISTS tab_tipo_identidad;
DROP TABLE IF EXISTS tab_cat_terceros;
DROP TABLE IF EXISTS tab_restricciones;
DROP TABLE IF EXISTS tab_ciudades;
DROP TABLE IF EXISTS tab_dptos;
DROP TABLE IF EXISTS tab_menu_palettes;
DROP TABLE IF EXISTS tab_pmtros_grales;
DROP TABLE IF EXISTS tab_audit_trail;
DROP TABLE IF EXISTS tab_cat_errores;
DROP TYPE  IF EXISTS DATOS_UBICACION;

-- ------------------------------------------------------------
-- 4. CREACIÓN DE TABLAS MAS USADAS
-- Estas tablas son esenciales y usadas por todos los módulos.
-- ------------------------------------------------------------

--ESTRUCTURA DE DATOS DE UBICACIÓN DE LOS TERCEROS DEL SISTEMA (Se usa en la tabla de terceros y en la tabla de parámetros generales para la empresa).

CREATE TYPE DATOS_UBICACION AS
(
	nom_corto           VARCHAR,             --nombre corto del lugar (ej: Barrio, Vereda, etc.)
    direccion           VARCHAR,             --direcion del tercero
    tel_fijo            DECIMAL,             --telefono fijo del tercero (7 a 10 dígitos dependiendo de la ciudad)
    id_prefijo_movil    DECIMAL,             --prefijo del celular del tercero
    tel_movil           DECIMAL,             --celular del tercero
    email               VARCHAR              --email del tercero
);

-- MANEJO DE ERRORES TRANSVERSAL (Tabla de códigos de error SQLSTATE y mensajes asociados).

CREATE TABLE tab_cat_errores (
    cod_sqlstate    VARCHAR     NOT NULL CHECK(LENGTH(cod_sqlstate) = 5),                        -- Codigo SQLSTATE del error
    mensaje         VARCHAR     NOT NULL CHECK(LENGTH(mensaje) >= 4 AND LENGTH(mensaje) <= 255), -- Mensaje descriptivo del error    
    PRIMARY KEY(cod_sqlstate)
);

-- 1. SEGURIDAD Y ACCESOS (Usuarios creados en Bases de Datos).

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

-- 2. TABLA PARA CUMPLIMIENTO DE SESIÓN ÚNICA (Requerimientos).

CREATE TABLE tab_sesiones
(
    id_usuario          VARCHAR NOT NULL CHECK(LENGTH(id_usuario) >= 5),    -- ID del usuario que inició sesión (FK a tab_usuarios)
    token_sesion        VARCHAR NOT NULL check(LENGTH(token_sesion) >= 10),                   -- Token de sesión para validar sesión única
    fec_inicio          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ult_actividad       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id_usuario),
    FOREIGN KEY(id_usuario) REFERENCES tab_usuarios(id_usuario) ON DELETE CASCADE
);

-- 3. TABLAS DE MENUS (Menus que se crean para asignar a los usuarios y evitar usar roles).

CREATE TABLE tab_menus
(
    id_menu             VARCHAR   NOT NULL,                                 -- Identificador único del menú (ej: 1, 11, 111, etc. para reflejar la jerarquía)
    nom_menu            VARCHAR   NOT NULL CHECK(LENGTH(nom_menu) <= 100),  -- Nombre del menú para mostrar en la interfaz (ej: Configuración, Parámetros, etc.)
    ind_id_padre        VARCHAR   NOT NULL,                                 -- Identificador del menú padre (ej: 0 para menús principales, 1 para submenús de Configuración, etc.)
    nom_programa        VARCHAR   NOT NULL DEFAULT 'no_aplica',             -- Nombre del programa o ruta que se ejecuta al hacer clic en el menú (ej: 'modules/compro/productos.php')
    PRIMARY KEY(id_menu)
);

-- 4. TABLAS DE MENUS POR USUARIO (para asignar menus sin necesidad de que todos los usuarios tengan los mismos).

CREATE TABLE tab_menu_usuarios
(
    id_usuario          VARCHAR NOT NULL CHECK(LENGTH(id_usuario) >= 5) REFERENCES tab_usuarios(id_usuario),    -- ID del usuario al que se le asigna el menú (FK a tab_usuarios)
    id_menu             VARCHAR NOT NULL REFERENCES tab_menus(id_menu),                                         -- ID del menú asignado al usuario (FK a tab_menus)
    PRIMARY KEY(id_usuario, id_menu)
);

-- 5. TABLA DE ÁREAS DE LA EMPRESA (Áreas creadas y asignadas a un responsable por su id de usuario del sistema).

CREATE TABLE IF NOT EXISTS tab_areas
(
    id_area             DECIMAL(5,0)    NOT NULL CHECK (id_area > 0),                                                       -- ID del área
    id_responsable      VARCHAR         NOT NULL CHECK(LENGTH(id_responsable) >= 5),                                        -- Usuario responsable del área
    nom_area            VARCHAR         NOT NULL CHECK (LENGTH(nom_area) >= 3),                                             -- Nombre del área (ej: Finanzas, Recursos Humanos, etc.)
    descrip_area        TEXT            NOT NULL DEFAULT 'Sin descripción de área',                                         -- Descripción detallada del área y sus funciones
    mail_area           VARCHAR         NOT NULL CHECK(mail_area ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),    -- Email corporativo del área
    tel_oficina         DECIMAL(10,0)   NOT NULL CHECK(tel_oficina >= 0 AND tel_oficina < 9999999999),                      -- Teléfono de la oficina del área
    ubi_oficina         VARCHAR         NOT NULL CHECK(LENGTH(ubi_oficina) >= 3),                                           -- Edificio, piso, oficina
    horario_atencion    VARCHAR         NOT NULL CHECK(LENGTH(horario_atencion) >= 3),                                      -- Lunes a Viernes 8am-5pm
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                              -- Activo/Inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	       
    PRIMARY KEY (id_area),
    FOREIGN KEY (id_responsable) REFERENCES tab_usuarios(id_usuario)
);

-- 6. TABLA PARAMETROS GENERALES

CREATE TABLE IF NOT EXISTS tab_pmtros_grales
(
    id_empresa	        VARCHAR(10)		NOT NULL,													                    --identificador de la empresa
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
    anio_fiscal         DECIMAL(4,0)    NOT NULL,                                                                       --Año fiscal en el estamos actualmente
    mes_fiscal          DECIMAL(2,0)    NOT NULL,                                                                       --mes fiscal en el que estamos actualmente
    ind_autorete        BOOLEAN	        NOT NULL, --TRUE = autorete / FALSE = no autorete                               --indicador autoretenedor
    riesgo_arl          CHAR(1)         NOT NULL UNIQUE CHECK(LENGTH(riesgo_arl) >=1 AND LENGTH(riesgo_arl) <= 5),        -- 1 = 0.522%, 2 = 1.044%, 3 = 2.436%, 4 = 4.350%, 5 = 6.960% PORCENTAJE QUE DEBE PAGAR LA ARL POR EL RIESGO
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico

    PRIMARY KEY(id_empresa),
    CONSTRAINT verificar_anio CHECK(anio_fiscal = EXTRACT (YEAR FROM CURRENT_DATE)), 
    CONSTRAINT verificar_mes  CHECK(mes_fiscal  = EXTRACT (MONTH FROM CURRENT_DATE)) 
);


CREATE TABLE IF NOT EXISTS tab_menu_palettes
(
    id_palette          VARCHAR(30)     NOT NULL,                                           -- Identificador único de la paleta (ej: 'blue_pro')
    nom_palette         VARCHAR(50)     NOT NULL,                                           -- Nombre descriptivo (ej: 'Azul Profesional')
    des_palette         TEXT            NOT NULL DEFAULT 'Sin descripción de la paleta',    -- Descripción de la paleta
    val_primary_color   VARCHAR(7)      NOT NULL DEFAULT '#1a1a2e',                       -- Color principal del menú (gradiente inicio)
    val_secondary_color VARCHAR(7)      NOT NULL DEFAULT '#16213e',                       -- Color secundario del menú (gradiente fin)
    val_accent_color    VARCHAR(7)      NOT NULL DEFAULT '#00d9ff',                       -- Color de acento (hover, active, iconos)
    val_text_color      VARCHAR(7)      NOT NULL DEFAULT '#ffffff',                       -- Color del texto en el menú superior
    val_hover_color     VARCHAR(7)      NOT NULL DEFAULT '#00d9ff',                       -- Color al pasar el mouse
    val_sidebar_bg      VARCHAR(7)      NOT NULL DEFAULT '#ffffff',                       -- Fondo del sidebar
    val_sidebar_text    VARCHAR(7)      NOT NULL DEFAULT '#555555',                       -- Color del texto en sidebar
    val_sidebar_hover   VARCHAR(7)      NOT NULL DEFAULT '#f4f7ff',                       -- Fondo al pasar el mouse
    val_active_bg       VARCHAR(7)      NOT NULL DEFAULT '#00aaff',                       -- Color del item activo
    num_orden           INTEGER         NOT NULL DEFAULT 0,                                 -- Orden de visualización
    ind_active          BOOLEAN         NOT NULL DEFAULT FALSE,                             -- Si es la paleta por defecto
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                             -- TRUE: Borrado lógico / FALSE: Activo
    PRIMARY KEY (id_palette)
);

-- 7. TABLA DEPARTAMENTOS DE COLOMBIA 

CREATE TABLE IF NOT EXISTS tab_dptos
(
    id_dpto	            VARCHAR         NOT NULL CHECK(LENGTH(id_dpto) = 2),                                            --identificador del departamento
    nom_dpto	        VARCHAR	        NOT NULL CHECK(LENGTH(nom_dpto) >= 4 AND LENGTH(nom_dpto) <= 20),               --nombre del departamento
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo       --indicador de borrado lógico
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

-----------------------------------------------------------------------------------
-- TABLA DE CATEGORIAS DE TERCEROS                                      	     --
-----------------------------------------------------------------------------------		

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
-- TABLA DE RESTRICCIONES DE LOS TERCEROS, QUE IMPIDEN SU ACCESO AL SISTEMA	     --
-----------------------------------------------------------------------------------			
CREATE TABLE IF NOT EXISTS tab_restricciones			
(			
	id_restriccion		DECIMAL(2,0)	NOT NULL CHECK(id_restriccion > 0 AND id_restriccion <= 99),				        --identificador de la restrinción	
	nom_restriccion		VARCHAR			NOT NULL CHECK(LENGTH(nom_restriccion) >= 4 AND LENGTH(nom_restriccion) <= 50),	    --Nombre de la restrinción
	PRIMARY KEY(id_restriccion)			
);	
INSERT INTO tab_restricciones VALUES(99,'No aplica.');			
INSERT INTO tab_restricciones VALUES(1,'Finalización Contrato Mutuo Acuerdo');			
INSERT INTO tab_restricciones VALUES(2,'Vacaciones Colectivas');			
INSERT INTO tab_restricciones VALUES(3,'Inhabilidad Legal');			
INSERT INTO tab_restricciones VALUES(4,'Restricción Día Festivo');			

CREATE TABLE tab_tipo_identidad 
(
    id_tipo    	VARCHAR(5)   NOT NULL CHECK(id_tipo ~ '^[A-Z]{2,5}$'),                           --  tipo de documento
    nom_tipo    VARCHAR      NOT NULL check(LENGTH(nom_tipo) >= 5 AND LENGTH(nom_tipo) <= 50),    -- Nombre del tipo de documnento
    PRIMARY KEY(id_tipo)
);

CREATE TABLE tab_tel_prefijo
(
    id_prefijo  DECIMAL(4,0)    NOT NULL CHECK(id_prefijo > 0 AND id_prefijo <= 9999),
    nom_pais    VARCHAR(50)     NOT NULL CHECK(LENGTH(nom_pais) >= 4 AND LENGTH(nom_pais) <= 50),
    PRIMARY KEY(id_prefijo)
);

-------------------------
-- TABLA DE TERCEROS.  --
------------------------- 
--ES TRANSVERSAL. TODA PERSONA DEBE ESTAR REGISTRADA EN ESTA TABLA.			
-- TIENE EXTENSIONES COMO CLIENTES, VENDEDORES, EMPLEADO, ETC. Y CADA EXTENSIÓN TIENE LOS DATOS PARTICULARES			
CREATE TABLE IF NOT EXISTS tab_terceros			
(			
    id_tipo        		VARCHAR(5)      NOT NULL CHECK(id_tipo ~ '^[A-Z]{2,5}$'),                                   --  tipo de documento
    id_tercero          VARCHAR(10)     NOT NULL CHECK(id_tercero ~ '^[A-Z0-9]{7,10}$'),		                    --  identificador de terceros
	ind_tipo_tercero	BOOLEAN			NOT NULL, --TRUE:Jurídica / FALSE:Natural								    --  tipo de tercero si es persona natural o jurídica
	id_cat_tercero		DECIMAL(2,0)	NOT NULL CHECK(id_cat_tercero > 0 AND id_cat_tercero <= 99),			    --  identifiador de la categoria 
	nom_tercero			VARCHAR			NOT NULL CHECK(LENGTH(nom_tercero) >= 4 AND LENGTH(nom_tercero) <= 50),	    --  nombre del tercero
	dir_tercero			DATOS_UBICACION,																		    --  Estructura de   datos de ubicación de terceros
	id_ciudad			VARCHAR			NOT NULL ,																    --  identificador de ciudad
	id_restriccion		DECIMAL(2,0)	NOT NULL CHECK(id_restriccion > 0 AND id_restriccion <= 99),			    --  identificador de las restrincion
	ind_estado			BOOLEAN			NOT NULL, --TRUE:Activo ( FALSE:Inactivo)								    --  indicador de estado del tercero
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo   --  indicador de borrado lógico
	PRIMARY KEY(id_tercero),			
	FOREIGN KEY(id_ciudad)			REFERENCES tab_ciudades(id_ciudad),			
	FOREIGN KEY(id_cat_tercero)		REFERENCES tab_cat_terceros(id_cat_tercero),			
	FOREIGN KEY(id_restriccion)		REFERENCES tab_restricciones(id_restriccion),
    FOREIGN KEY(id_tipo)            REFERENCES tab_tipo_identidad(id_tipo)
);

-------------------------
-- TABLA DE BANCOS.    --
------------------------- 
CREATE TABLE IF NOT EXISTS tab_bancos
(
    id_banco			VARCHAR     	NOT NULL CHECK(LENGTH(id_banco) >= 6 AND (LENGTH(id_banco) <= 10)),														        --identificador del banco
    nom_banco			VARCHAR			NOT NULL CHECK(LENGTH(nom_banco) >= 4 AND LENGTH(nom_banco) <= 50),	        --nombre del banco
    ind_estado			BOOLEAN			NOT NULL, --TRUE:Activo ( FALSE:Inactivo)								    --indicador de estado del banco
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo   --indicador de borrado lógico
    PRIMARY KEY(id_banco)
);

-----------------------------------------
--MÓDULO DE CONTABILIDAD Y PRESUPUESTO --
-----------------------------------------


-------------------------------------------------------------------
--
--      PLAN UNICO DE CUENTAS (PUC)
--
--------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_puc
(
    id_nivel            DECIMAL(1,0)    NOT NULL CHECK(id_nivel >=  1 AND id_nivel <= 9),        -- Nivel jerárquico (1-9)
    id_cod_puc          VARCHAR(20)     NOT NULL, -- CHECK(id_cod_puc > 0),                      -- Código de la cuenta (ej: 110505)
    nom_cuenta          VARCHAR(60)     NOT NULL CHECK(LENGTH(nom_cuenta) >= 3),                 -- Nombre de la cuenta
    ind_natura          BOOLEAN         NOT NULL,                                                -- TRUE=Débito, FALSE=Crédito
    descrip_puc         VARCHAR(200)    DEFAULT 'N/A',                                           -- Descripción opcional
    cod_superior        VARCHAR(20)     NOT NULL,                                                -- Código del padre (0 si nivel 1)
    ind_req_tercero     BOOLEAN         NOT NULL DEFAULT FALSE,                                  -- Requiere tercero (cliente/proveedor)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                   -- TRUE=activo, FALSE=inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                  -- Borrado lógico
    PRIMARY KEY(id_nivel, id_cod_puc),                                                           -- Llave primaria compuesta
    CONSTRAINT chk_puc_codigo   CHECK(id_cod_puc ~ '^[0-9]+$'),                                  -- Solo números en el código  -- REVISAR CON PEREZ  --
    CONSTRAINT chk_puc_superior
    CHECK(                                                                                       -- Regla jerárquica
        (id_nivel = 1 AND cod_superior = '0') OR                                                 -- Nivel 1: superior = 0
        (id_nivel > 1 AND cod_superior != '0' AND LENGTH(cod_superior) < LENGTH(id_cod_puc))     -- Niveles >1: superior existe y es más corto
    )
);


-------------------------------------------------------------------
--
--      ACTIVOS FIJOS Y DEPRECIACIÓN
--
--------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tab_cat_activos
(
    id_categoria_act    DECIMAL(2,0)    NOT NULL CHECK(id_categoria_act BETWEEN 1 AND 99),                  -- ID de categoría (1-99)
    nom_categoria       VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_categoria) >= 3),                         -- Nombre (ej: Equipo de Cómputo)
    vida_util_meses     DECIMAL(3,0)    NOT NULL DEFAULT 60,                                                -- Vida útil en meses
    metodo_depreciacion CHAR(1)         NOT NULL DEFAULT 'L' CHECK(metodo_depreciacion IN ('L', 'S')),      -- L=Linea Recta, S=Saldo Decreciente
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                              -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                             -- Borrado lógico
    PRIMARY KEY(id_categoria_act)                                                                           -- Llave primaria simple
);


CREATE TABLE IF NOT EXISTS tab_act_fijos
(
    id_activo           DECIMAL(10,0)   NOT NULL CHECK(id_activo > 0),                                     -- ID del activo
    id_categoria_act    DECIMAL(2,0)    NOT NULL,                                                          -- Categoría (FK)
    num_placa           VARCHAR(20)     NOT NULL UNIQUE,                                                   -- Código único del activo
    nom_activo          VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_activo) >= 3),                           -- Nombre
    fecha_compra        DATE            NOT NULL CHECK(fecha_compra <= CURRENT_DATE),                      -- Fecha de compra
    val_compra          DECIMAL(15,0)   NOT NULL CHECK(val_compra > 0),                                    -- Valor de compra
    val_residual        DECIMAL(15,0)   NOT NULL DEFAULT 0,                                                -- Valor residual
    depre_acumulada     DECIMAL(15,0) NOT NULL DEFAULT 0,                                                  -- Depreciación acumulada
    ind_estado_activo   CHAR(1)         NOT NULL DEFAULT 'A' CHECK(ind_estado_activo IN ('A', 'B', 'D')),  -- A=Activo, B=Baja, D=Depreciado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                            -- Borrado lógico
    PRIMARY KEY(id_activo),                                                                                -- Llave primaria
    FOREIGN KEY(id_categoria_act) REFERENCES tab_cat_activos(id_categoria_act),                            -- FK a categoría
    CONSTRAINT chk_activo_residual CHECK (val_residual < val_compra),                                      -- Residual debe ser menor a compra
    CONSTRAINT chk_activo_depreciacion CHECK (depre_acumulada <= (val_compra - val_residual))              -- No depreciar más de lo debido
);


CREATE TABLE IF NOT EXISTS tab_depreciacion
(
    id_depreciacion     DECIMAL(10,0)   NOT NULL CHECK(id_depreciacion > 0),                                     -- ID de depreciación
    id_activo           DECIMAL(10,0)   NOT NULL,                                                                -- Activo
    fec_mes             DECIMAL(10,0)   NOT NULL,                                                                -- Fecha del mes de depreciación (YYYYMM)
    val_depreciacion    DECIMAL(15,0)   NOT NULL CHECK(val_depreciacion > 0),                                    -- Valor depreciado este período
    depreciacion_acumulada_antes DECIMAL(15,0) NOT NULL,                                                         -- Acumulado ANTES de esta depreciación
    depreciacion_acumulada_despues DECIMAL(15,0) NOT NULL,                                                       -- Acumulado DESPUÉS de esta depreciación
    id_comprobante      DECIMAL(10,0),                                                                           -- Comprobante contable asociado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                  -- Borrado lógico
    PRIMARY KEY(id_depreciacion),                                                                                -- Llave primaria
    FOREIGN KEY(id_activo) REFERENCES tab_act_fijos(id_activo),                                                  -- FK a activo
    CONSTRAINT chk_depreciacion_aumenta CHECK (depreciacion_acumulada_despues > depreciacion_acumulada_antes)    -- La depreciación siempre aumenta
);

-------------------------------------------------------------------
--
--      PRESUPUESTO
--
--------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tab_period_presupuesto
(
    id_periodo          DECIMAL(10,0)   NOT NULL CHECK(id_periodo > 0),                         -- ID del período
    anio_periodo        DECIMAL(4,0)    NOT NULL CHECK(anio_periodo BETWEEN 2000 AND 2100),     -- Año (2000-2100)
    mes_periodo         DECIMAL(2,0)    NOT NULL CHECK(mes_periodo BETWEEN 1 AND 12),           -- Mes (1-12)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- Borrado lógico
    PRIMARY KEY(id_periodo)                                                                     -- Llave primaria
);

CREATE TABLE IF NOT EXISTS tab_tipo_presupuesto
(
    id_tipo_presupuesto DECIMAL(10,0)   NOT NULL CHECK(id_tipo_presupuesto > 0),                -- ID del tipo
    nom_tipo            VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipo) >= 3),                  -- Nombre del tipo
    descrip_tipo        VARCHAR(200)    DEFAULT '',                                             -- Descripción
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- Borrado lógico
    PRIMARY KEY(id_tipo_presupuesto)                                                            -- Llave primaria
);

CREATE TABLE IF NOT EXISTS tab_enc_presupuesto
(
    id_presupuesto          DECIMAL(10,0)   NOT NULL CHECK(id_presupuesto > 0),                 -- ID del presupuesto
    id_area                 DECIMAL(10,0)   NOT NULL,                                           -- Área (FK)
    id_periodo              DECIMAL(10,0)   NOT NULL,                                           -- Período contable (FK)
    id_tipo_presupuesto     DECIMAL(10,0)   NOT NULL,                                           -- Tipo de presupuesto (FK)
    descrip_presupuesto     VARCHAR(200)    DEFAULT '',                                         -- Descripción
    fecha_aprobacion        DATE,                                                               -- Fecha de aprobación
    total_presupuesto       DECIMAL(15,0)   NOT NULL DEFAULT 0,                                 -- TOTAL PRESUPUESTO (SUMATORIA DE LOS ITEMS DEL MES)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                             -- Borrado lógico
    PRIMARY KEY(id_presupuesto),                                                                -- Llave primaria
    FOREIGN KEY(id_area)        REFERENCES tab_areas(id_area),                                  -- FK a área
    FOREIGN KEY(id_periodo)     REFERENCES tab_period_presupuesto(id_periodo),                  -- FK a período
    FOREIGN KEY(id_tipo_presupuesto)  REFERENCES tab_tipo_presupuesto(id_tipo_presupuesto)      -- FK a tipo
);

CREATE TABLE IF NOT EXISTS tab_planeacion_presupuesto
(
    id_plan                 DECIMAL(10,0)   NOT NULL CHECK(id_plan > 0),                        -- ID del plan
    id_area                 DECIMAL(10,0)   NOT NULL,                                           -- Área (FK)
    id_periodo              DECIMAL(10,0)   NOT NULL,                                           -- Período contable (FK)
    id_nivel                DECIMAL(1,0)    NOT NULL CHECK(id_nivel >=  1 AND id_nivel <= 9),        -- Nivel jerárquico (1-9)
    id_cod_puc              VARCHAR(20)     NOT NULL,                                           --
    val_planeado            DECIMAL(15,0)   NOT NULL CHECK(val_planeado >= 0),                  --
    val_ejecutado           DECIMAL(15,0)   NOT NULL DEFAULT 0,                                 --
    ind_mes_cerrado         BOOLEAN         NOT NULL DEFAULT FALSE,                             -- TRUE=mes cerrado, no se permiten cambios
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                             -- Borrado lógico
    PRIMARY KEY(id_plan),                                                                       -- Llave primaria
    FOREIGN KEY(id_area) REFERENCES tab_areas(id_area),                                         -- FK a área
    FOREIGN KEY(id_periodo) REFERENCES tab_period_presupuesto(id_periodo),                      -- FK a período
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc)                  -- FK a PUC
);

CREATE TABLE IF NOT EXISTS tab_det_presupuesto
(
    id_det_presupuesto      DECIMAL(10,0)   NOT NULL,                                                   -- ID del detalle
    id_presupuesto          DECIMAL(10,0)   NOT NULL,                                                   -- Presupuesto (FK)
    id_plan                 DECIMAL(10,0)   NOT NULL,                                                   -- Plan (FK)
    monto_aprobado          DECIMAL(15,0)   NOT NULL CHECK(monto_aprobado >= 0),                        -- Monto aprobado
    monto_comprometido      DECIMAL(15,0)   NOT NULL DEFAULT 0,                                         -- Monto comprometido (pedidos)
    monto_ejecutado         DECIMAL(15,0)   NOT NULL DEFAULT 0,                                         -- Monto ejecutado (real)
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                                     -- Borrado lógico
    PRIMARY KEY(id_det_presupuesto),                                                                    -- Llave primaria
    FOREIGN KEY(id_presupuesto) REFERENCES tab_enc_presupuesto(id_presupuesto),                         -- FK a presupuesto
    FOREIGN KEY(id_plan)        REFERENCES tab_planeacion_presupuesto(id_plan),                         -- FK a plan
    CONSTRAINT chk_det_presupuesto_comprometido CHECK (monto_comprometido <= monto_aprobado),           -- No comprometer más de lo aprobado
    CONSTRAINT chk_det_presupuesto_ejecutado    CHECK (monto_ejecutado <= monto_aprobado)               -- No ejecutar más de lo aprobado
);

-------------------------------------------------------------------
--
--      COMPROBANTES CONTABLES
--
--------------------------------------------------------------------


CREATE TABLE IF NOT EXISTS tab_tip_comprobantes
(
    id_tipcomprobante   SMALLINT   NOT NULL CHECK(id_tipcomprobante > 0),                       -- ID del tipo
    nom_tipcomprobante  VARCHAR(30)     NOT NULL CHECK(LENGTH(nom_tipcomprobante) >= 3),        -- Nombre
    num_inicial         DECIMAL(10,0)   NOT NULL DEFAULT 0,                                     -- Número inicial
    num_final           DECIMAL(10,0)   NOT NULL DEFAULT 0,                                     -- Número final
    num_actual          DECIMAL(10,0)   NOT NULL DEFAULT 0,                                     -- Número actual
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                  -- TRUE=activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                 -- Borrado lógico
    PRIMARY KEY(id_tipcomprobante)                                                              -- Llave primaria
);

CREATE TABLE IF NOT EXISTS tab_enc_comprobantes
(
    num_comprobante         DECIMAL(10,0)   NOT NULL,                                               -- Número del comprobante
    id_tipcomprobante       SMALLINT        NOT NULL,                                               -- Tipo (FK)
    fecha_comprobante       DATE            NOT NULL CHECK(fecha_comprobante <= CURRENT_DATE),      -- Fecha
    concepto                VARCHAR(200)    NOT NULL,                                               -- Concepto/descripción
    total_debe              DECIMAL(15,0)   NOT NULL DEFAULT 0,                                     -- Total débitos
    total_haber             DECIMAL(15,0)   NOT NULL DEFAULT 0,                                     -- Total créditos
    estado                  CHAR(1)         NOT NULL DEFAULT 'B' CHECK(estado IN ('B', 'C', 'A')),  -- B=Borrador, C=Contabilizado, A=Anulado
    usuario_creacion        VARCHAR(50)     DEFAULT CURRENT_USER,                                   -- Usuario que creó
    fecha_creacion          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,                              -- Fecha de creación
    usuario_contabilizacion VARCHAR(50),                                                            -- Usuario que contabilizó
    fecha_contabilizacion   TIMESTAMP,                                                              -- Fecha de contabilización
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                     -- Borrado lógico
    PRIMARY KEY(num_comprobante,id_tipcomprobante),                                                 -- Llave primaria
    FOREIGN KEY(id_tipcomprobante) REFERENCES tab_tip_comprobantes(id_tipcomprobante),              -- FK a tipo
    CONSTRAINT chk_comprobante_cuadrado CHECK (estado != 'C' OR total_debe = total_haber)           -- Si está contabilizado, debe estar cuadrado
);

CREATE TABLE IF NOT EXISTS tab_det_comprobantes
(
    num_comprobante     DECIMAL(10,0)   NOT NULL,                                                       --
    id_tipcomprobante   SMALLINT        NOT NULL,                                                       -- Tipo (FK)
    num_linea SMALLINT NOT NULL,                                                                        -- Agregar esta columna
    id_nivel            DECIMAL(1,0)    NOT NULL CHECK(id_nivel >=  1 AND id_nivel <= 9),               -- Nivel jerárquico (1-9)
    id_cod_puc          VARCHAR(20)     NOT NULL,                                                       -- Cuenta PUC (FK)
    descrip_det_comp    VARCHAR(200)    DEFAULT '',                                                     -- Descripción de la línea
    valor_debito        DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_debito >= 0),                    -- Valor débito
    valor_credito       DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_credito >= 0),                   -- Valor crédito
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                         -- Borrado lógico
    PRIMARY KEY(num_comprobante, id_tipcomprobante, num_linea),                                         -- Llave primaria
    FOREIGN KEY(num_comprobante, id_tipcomprobante) REFERENCES tab_enc_comprobantes(num_comprobante, id_tipcomprobante) ON DELETE CASCADE,
    FOREIGN KEY(id_nivel, id_cod_puc) REFERENCES tab_puc(id_nivel, id_cod_puc),                         -- FK a PUC
    CONSTRAINT chk_det_comprobante_xor CHECK (                                                          -- Una línea NO puede tener débito y crédito a la vez
    (valor_debito > 0 AND valor_credito = 0) OR (valor_debito = 0 AND valor_credito > 0))
);

CREATE TABLE IF NOT EXISTS tab_ejecucion_presupuesto
(
    id_ejecucion            DECIMAL(10,0)   NOT NULL,                                             -- ID de ejecución
    id_plan                 DECIMAL(10,0)   NOT NULL,                                             -- Plan (FK)
    num_comprobante         DECIMAL(10,0)   NOT NULL,                                             -- Comprobante (FK)
    id_tipcomprobante       SMALLINT        NOT NULL,                                             -- Tipo de comprobante (FK)
    id_det_presupuesto      DECIMAL(10,0)   NOT NULL,                                             -- Detalle (FK)
    valor_real              DECIMAL(15,0)   NOT NULL DEFAULT 0 CHECK(valor_real >= 0),            -- Valor real ejecutado
    fecha_registro          DATE            NOT NULL DEFAULT CURRENT_DATE,                        -- Fecha de registro
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                               -- Borrado lógico
    PRIMARY KEY(id_ejecucion),                                                                    -- Llave primaria
    FOREIGN KEY(id_plan) REFERENCES tab_planeacion_presupuesto(id_plan),                          -- FK a plan
    FOREIGN KEY(num_comprobante, id_tipcomprobante) REFERENCES tab_enc_comprobantes(num_comprobante, id_tipcomprobante),
    FOREIGN KEY(id_det_presupuesto) REFERENCES tab_det_presupuesto(id_det_presupuesto)   -- FK a detalle
);


CREATE TABLE IF NOT EXISTS tab_parametros_contab
(
    id_empresa          VARCHAR(10)   NOT NULL,															         -- Empresa
    anio_contable       DECIMAL(4,0)    NOT NULL CHECK(anio_contable >= 2000),                                     -- Año contable actual
    mes_contable        DECIMAL(2,0)    NOT NULL CHECK(mes_contable BETWEEN 1 AND 12),                             -- Mes contable actual
    ind_estado_period   BOOLEAN         NOT NULL DEFAULT TRUE,                                                     -- TRUE=período activo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                    -- Borrado lógico
    PRIMARY KEY(id_empresa),                                                                                       -- Llave primaria
    FOREIGN KEY(id_empresa) REFERENCES tab_pmtros_grales(id_empresa)                                               -- FK a empresa
);

---------------------------------------------
--FIN MÓDULO DE CONTABILIDAD Y PRESUPUESTO --
---------------------------------------------

------------------------------
-- TABLA TIPO DE RIESGOS    --
------------------------------

CREATE TABLE IF NOT EXISTS 	tab_riesgos
(
	id_riesgo				DECIMAL(2,0)		NOT NULL          CHECK(id_riesgo >= 1 AND id_riesgo <= 99),                  -- IDENTIFICADOR DE LOS RIESGOS (SST, GESTIÓN DOCUMENTAL)
    nom_riesgo              VARCHAR         	NOT NULL          CHECK(LENGTH(nom_riesgo) >= 5 AND LENGTH(nom_riesgo)<=100),   -- NOMBRE ASIGNADO AL RIESGO DEPENDIENDO SU CLASIFICACIÓN
	nivel_riesgo			DECIMAL(1,0)    	NOT NULL          CHECK(nivel_riesgo >=1 AND nivel_riesgo<=5),                   -- CLASE I = OFICINISTAS, CLASE II : (como la confección de tejidos y textiles) y ciertas labores agrícolas, CLASE III :  Aplica a procesos de manufactura más complejos, como la fabricación de alimentos, licores, tabaco y productos de cuero o plástico. CLASE IV:   Agrupa procesos industriales pesados y actividades de transporte, CLASE V:  Corresponde a las actividades de mayor peligro e impacto, como la construcción, explotación minera y petrolera, canteras, areneras y manejo de explosivos
	categoria_riesgo		DECIMAL(1,0)		NOT NULL          CHECK(categoria_riesgo >=1 AND categoria_riesgo <= 6),        -- 1 para Físicos, 2 para Químicos, 3 para Biológicos, 4 para Ergonómicos o biomecánicos, 5 para Psicosociales, 6 para Psicosociales.
    riesgo_arl             CHAR(1)         	    NOT NULL,      -- 1 = 0.522%, 2 = 1.044%, 3 = 2.436%, 4 = 4.350%, 5 = 6.960% PORCENTAJE QUE DEBE PAGAR LA ARL POR EL RIESGO
	ind_borrado				BOOLEAN				NOT NULL 	                                                                    DEFAULT FALSE,	
	PRIMARY KEY(id_riesgo)
);

-------------------------------------
-- MODULO DE COMPRAS Y PROVEEDORES --
-------------------------------------

-- TABLA DE PAREÁMETROS DE COMPRAS
CREATE TABLE tab_pmtros_compras 
(
    id_empresa           VARCHAR(10)     NOT NULL CHECK(id_empresa ~ '^[1-9][0-9]{7,9}$'),                                         -- Identificador de la empresa (ID empresa)
    val_puntaje_sel_prov SMALLINT        NOT NULL CHECK(val_puntaje_sel_prov >= 0 AND val_puntaje_sel_prov <= 100) DEFAULT 80,     -- Puntaje de selección de proveedor (0-100)
    PRIMARY KEY(id_empresa),
    FOREIGN KEY(id_empresa) REFERENCES tab_pmtros_grales(id_empresa)
);

-----------------------
-- TABLA PROVEEDORES --
-----------------------
CREATE TABLE IF NOT EXISTS tab_proveedores
(
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[A-Z0-9]{7,10}$'),                                                                               -- Identificador del proveedor (ID empresa)
    val_sigla           VARCHAR         NOT NULL CHECK(LENGTH(val_sigla) >= 2 AND LENGTH(val_sigla) <= 10),                                                              -- Sigla del proveedor (ej. "PROV1")
    val_latitud         DECIMAL(18,16)  NOT NULL CHECK(val_latitud >= -4 AND val_latitud <= 80),                                                                         -- Latitud geográfica del proveedor
    val_longitud        DECIMAL(18,16)  NOT NULL CHECK(val_longitud >= -80 AND val_longitud <= -50),                                                                     -- Longitud geográfica del proveedor
    nom_contacto        VARCHAR         NOT NULL CHECK(LENGTH(nom_contacto) >= 5 AND LENGTH(nom_contacto) <= 60) DEFAULT 'Sin nombre del contacto',                      -- Nombre del contacto
    tel_contacto        DECIMAL(10,0)   NOT NULL CHECK(tel_contacto >= 0) DEFAULT 0,                                                                                     -- Teléfono del contacto
    nom_cont_contab     VARCHAR         NOT NULL CHECK(LENGTH(nom_cont_contab) >= 5 AND LENGTH(nom_cont_contab) <= 60) DEFAULT 'Sin nombre del contacto contabilidad',   -- Nombre del contacto contable
    tel_cont_contab     DECIMAL(10,0)   NOT NULL CHECK(tel_cont_contab >= 0) DEFAULT 0,                                                                                  -- Teléfono del contacto contable
    ind_dias_pago       DECIMAL(3,0)    NOT NULL CHECK(ind_dias_pago <= 90) DEFAULT 0,                                                                                   -- Días de pago acordados con el proveedor
    val_saldo_deuda     DECIMAL(11,0)   NOT NULL CHECK(val_saldo_deuda >= 0 AND val_saldo_deuda <= 99999999999) DEFAULT 0,                                               -- Saldo de deuda actual con el proveedor
    val_tiempo_entrega  DECIMAL(3,0)    NOT NULL CHECK(val_tiempo_entrega >= 0 AND val_tiempo_entrega <= 365) DEFAULT 0,                                                 -- Días de entrega del proveedor
    fec_registro        DATE            NOT NULL DEFAULT CURRENT_DATE,                                                                                                   -- Fecha de registro del proveedor
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                                                                          -- TRUE = Borrado / FALSE = Activo 
    PRIMARY KEY(id_proveedor),
    FOREIGN KEY(id_proveedor) REFERENCES tab_terceros(id_tercero)
);

-------------------------------------
-- TABLA EVALUACIÓN DE PROVEEDORES --
-------------------------------------
CREATE TABLE IF NOT EXISTS tab_eval_prov
(
    id_eva_prov         DECIMAL(3,0)    NOT NULL CHECK(id_eva_prov > 0 AND id_eva_prov <= 999),                            -- Identificador de la evaluación
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[A-Z0-9]{7,10}$'),                                 -- Identificador del proveedor
    fec_evaluacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Fecha de la evaluación
    val_punt_calidad    DECIMAL(3,0)    NOT NULL CHECK(val_punt_calidad >= 0 AND val_punt_calidad <= 100) DEFAULT 0,       -- Puntaje de calidad (0-100)
    val_punt_puntual    DECIMAL(3,0)    NOT NULL CHECK(val_punt_puntual >= 0 AND val_punt_puntual <= 100) DEFAULT 0,       -- Puntaje de puntualidad (0-100)
    val_puntaje_total   DECIMAL(4,2)    NOT NULL CHECK(val_puntaje_total >= 0 AND val_puntaje_total <= 100) DEFAULT 0,     -- Puntaje total (calculado por trigger)
    val_coments         TEXT            NOT NULL CHECK(LENGTH(TRIM(val_coments)) > 0)DEFAULT 'Sin comentarios',            -- Comentarios de la evaluación
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
    ind_tip_producto    BOOLEAN         NOT NULL,                                                                          -- TRUE = comercial / FALSE = interno
    ind_tipo_bien       BOOLEAN         NOT NULL,                                                                          -- TRUE = Bien  / FALSE = Servicio
    id_area             DECIMAL(5,0)    NOT NULL CHECK(id_area > 0) DEFAULT 1,                                             -- Área a la que pertenece el producto interno (1 = "Compras comerciales)"
    nom_producto        VARCHAR(60)     NOT NULL CHECK(LENGTH(nom_producto) >= 4 AND LENGTH(nom_producto) <= 60),          -- Nombre del producto
    val_poriva          DECIMAL(2,0)    NOT NULL CHECK(val_poriva >= 0 AND val_poriva < 100) DEFAULT 0,                    -- % IVA del producto
    val_exist           DECIMAL(3,0)    NOT NULL CHECK(val_exist >= 0 AND val_exist <= 999) DEFAULT 0,                     -- Existencias del producto
    val_venta           DECIMAL(11,0)   NOT NULL CHECK(val_venta >= 0 AND val_venta <= 99999999999) DEFAULT 0,             -- Valor de venta
    ind_disponible      BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Disponible para venta / FALSE = No disponible para venta
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Activo / FALSE = Inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- TRUE = Borrado / FALSE = Activo
    PRIMARY KEY(id_producto)
);

-----------------------------------
-- TABLA PRODUCTOS POR PROVEEDOR --
-----------------------------------
CREATE TABLE IF NOT EXISTS tab_prodxprov
(
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[A-Z0-9]{7,10}$'),                                 -- Identificador del proveedor
    id_producto         DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),                            -- Identificador del producto
    val_costo           DECIMAL(11,0)   NOT NULL CHECK(val_costo >= 0 AND val_costo <= 99999999999) DEFAULT 0,             -- Costo del producto
    val_pordesc         DECIMAL(2,0)    NOT NULL CHECK(val_pordesc >= 0 AND val_pordesc < 100) DEFAULT 0,                  -- % Descuento del proveedor
    ind_disponible      BOOLEAN         NOT NULL DEFAULT TRUE,                                                             -- TRUE = Disponible para compra / FALSE = No disponible para compra
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
    val_justificacion   TEXT            NOT NULL CHECK(LENGTH(TRIM(val_justificacion)) > 0) DEFAULT 'Sin junstificación',  -- Justificación de la solicitud
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado >= 1 AND ind_estado <= 3) DEFAULT 2,                     -- 1=Aprobado, 2=Pendiente, 3=Anulado
    PRIMARY KEY(id_solcompra),
    FOREIGN KEY(id_area) REFERENCES tab_areas(id_area),
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
    id_proveedor        VARCHAR(10)     NOT NULL CHECK(id_proveedor ~ '^[A-Z0-9]{7,10}$'),                                 -- Identificador del proveedor
    id_solcompra        DECIMAL(6,0)    NOT NULL DEFAULT 0,                                                                -- ID de solicitud de compra asociada (0 si no viene de una solicitud) 
    fec_emision         DATE            NOT NULL DEFAULT CURRENT_DATE,                                                     -- Fecha de emisión
    id_ciudad           VARCHAR         NOT NULL CHECK(LENGTH(id_ciudad) = 5),                                             -- Identificador de la ciudad
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado >= 1 AND ind_estado <= 3) DEFAULT 2,                     -- 1=Aprobado, 2=Pendiente, 3=Anulado
    val_total           DECIMAL(11,0)   NOT NULL CHECK(val_total >= 0 AND val_total <= 99999999999) DEFAULT 0,             -- Valor total de la orden
    met_pago            BOOLEAN         NOT NULL DEFAULT FALSE,                                                            -- true = crédito, false = contado
    PRIMARY KEY(id_ordencompra),
    FOREIGN KEY(id_proveedor) REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY(id_ciudad)    REFERENCES tab_ciudades(id_ciudad),
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
    val_observacion     TEXT            NOT NULL  CHECK(LENGTH(TRIM(val_observacion)) > 0)DEFAULT 'Sin observaciones',                   -- Detalles si hubo problema
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


-------------------------------------------------------------------------------
--
-- FUNCIONA HASTA ACA
--
-------------------------------------------------------------------------------

--------------------------------------------
-- MÓDULO DE GESTIÓN HUMANA Y NÓMINA --
--------------------------------------------

/*******************************************************************************
 * Descripción: Creación de tablas para gestión de Talento Humano y Nómina.
 *******************************************************************************/

-- 1. TABLA DE PARAMETROS LEGALES 
CREATE TABLE IF NOT EXISTS tab_pmtros_legales
(
    id_empresa              VARCHAR(10)           NOT NULL DEFAULT '0000000000',          -- Número de identificación de la empresa
    ano                     INTEGER               NOT NULL DEFAULT '2026',         -- Año de vigencia
    val_smlv                DECIMAL(10,0)         NOT NULL DEFAULT 1750905,               -- Valor salario miniomo legal vigente
    val_aux_transp          DECIMAL(10,0)         NOT NULL DEFAULT 249095,                -- Valor auxilio de transporte
    val_tope_rete           DECIMAL(10,0)         NOT NULL DEFAULT 4975530,               -- Valor tope para retención (la retención por salarios solo aplica si la base gravable supera las 95 UVT (aprox.  $4.975.530).)
    pct_calculo_ibc         DECIMAL(5,2)          NOT NULL DEFAULT 40.00,                 -- Porcentaje calculo IBC (40%)
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
        -- Prestaciones sociales
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
    ind_borrado             BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_empresa,ano),    

    CONSTRAINT chk_pct_salud_emplea CHECK (pct_salud_emplea BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_pension_empld CHECK (pct_pension_empld BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_solidaridad CHECK (pct_solidaridad BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_salud_emplr CHECK (pct_salud_emplr BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_pension_emplr CHECK (pct_pension_emplr BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_arl CHECK (pct_arl BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_sena CHECK (pct_sena BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_icbf CHECK (pct_icbf BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_ccf CHECK (pct_ccf BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_prima CHECK (pct_prima BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_cesantias CHECK (pct_cesantias BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_intereses_ces CHECK (pct_intereses_ces BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_rec_nocturno CHECK (pct_rec_nocturno BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_rec_dominical CHECK (pct_rec_dominical BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_rec_dom_noct CHECK (pct_rec_dom_noct BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_extra_diurna CHECK (pct_extra_diurna BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_extra_nocturna CHECK (pct_extra_nocturna BETWEEN 0 AND 100),
    CONSTRAINT chk_pct_extra_dominical CHECK (pct_extra_dominical BETWEEN 0 AND 100),
    CONSTRAINT chk_dias_vacaciones CHECK (dias_vacaciones > 0),
    CONSTRAINT chk_jornada_max_horas CHECK (jornada_max_horas > 0)                                                      
);



--2. TABLA DE NIVEL DE ESCOLARIDAD
CREATE TABLE IF NOT EXISTS tab_escolaridad
(
    id_escolar          VARCHAR(5)    NOT NULL DEFAULT 'ESC00',                           -- Código único (ej: 'ESC01' A ESC99)
    nom_escolar         VARCHAR(20)   NOT NULL DEFAULT 'SIN ESCOLARIDAD',                  -- Nombre del nivel educativo (ej:    
    ind_borrado         BOOLEAN       NOT NULL DEFAULT FALSE,    
    PRIMARY KEY(id_escolar),

     CONSTRAINT chk_escolaridad_nom CHECK (nom_escolar IN ('BACHILLER','AUXILIAR','TECNICO','TECNOLOGO','PROFESIONAL','ESPECIALISTA','MAGISTER','DOCTORADO','SIN ESCOLARIDAD'))
);


--3. TABLA DE PROFESIONES
CREATE TABLE IF NOT EXISTS tab_profesiones
(
    id_profesion            VARCHAR(8)              NOT NULL DEFAULT 'PROF000',                -- Código único (ej: 'PROF001 A PROF999)')
    nom_profesion           VARCHAR(100)            NOT NULL DEFAULT 'SIN PROFESIÓN',          -- Nombre oficial de la carrera o título
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_profesion)
);




--4. TABLA DE CARGOS
CREATE TABLE IF NOT EXISTS tab_cargos
(
    id_cargo                VARCHAR(5)             NOT NULL DEFAULT 'CAR00',                          -- Número de identificación del cargo
    nom_cargo               VARCHAR(50)            NOT NULL DEFAULT 'SIN CARGO',                    -- Nombre del cargo
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_cargo)                                                          
);
CREATE INDEX idx_nom_cargo ON tab_cargos(nom_cargo);                                                                      -- Búsqueda por nombre de cargo


--5. TABLA DE ENTIDADES
CREATE TABLE tab_entidades
(
    id_entidad       VARCHAR(10)                     NOT NULL DEFAULT '0000000000',
    nom_entidad      VARCHAR(60)                     NOT NULL DEFAULT 'SIN NOMBRE DE ENTIDAD',
    ind_eps          BOOLEAN                         NOT NULL DEFAULT FALSE,
    ind_ccf          BOOLEAN                         NOT NULL DEFAULT FALSE,
    ind_arl          BOOLEAN                         NOT NULL DEFAULT FALSE,
    ind_afp          BOOLEAN                         NOT NULL DEFAULT FALSE,
    ind_sena         BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_entidad)
);




--8. TABLA DE CANDIDATOS
CREATE TABLE IF NOT EXISTS tab_candidatos
(
    id_candidato            VARCHAR(10)             NOT NULL DEFAULT '0000000000',                               -- Número de identificación del candidato
    nom_candidato           VARCHAR(100)            NOT NULL DEFAULT 'SIN NOMBRE DE CANDIDATO',                  -- Nombres del candidato
    ape_candidato           VARCHAR(100)            NOT NULL DEFAULT 'SIN APELLIDO DE CANDIDATO',                -- Apellidos del candidato
    id_tipo                 VARCHAR(5)              NOT NULL DEFAULT 'SIN TIPO DE DOCUMENTO DE CANDIDATO' CHECK(id_tipo IN ('C.C','T.I','C.E','P.T','P.E','P.A')),   -- Tipo de documento del candidato (C.C, C.E, PTT, etc)  PENDIEMTE MIRAR TABLA NUEVA DE TIPO DE DOCUMENTO                  
    dir_empleado            DATOS_UBICACION,                                                                     -- TYPE PARA DIRECCION TELEFONO Y MAIL
    id_ciudad               VARCHAR(5)              NOT NULL DEFAULT '00000',                                    -- CIUDAD DE RESIDENCIA DEL CANDIDATO
    fec_nacimiento          DATE                    NOT NULL DEFAULT '0001-01-01',                               -- FECHA NACIMIENTO DEL CANDIDATO
    ind_genero              BOOLEAN                 NOT NULL DEFAULT TRUE,                                       -- GENERO BIOLOGICO DEL CANDIDATO (TRUE=MASCULINO O FALSE=FEMENINO)
    nom_vacante             VARCHAR(20)             NOT NULL DEFAULT 'SIN NOMBRE DE VACANTE',
    prueba_1                DECIMAL(4,2)            NOT NULL DEFAULT 00.00 CHECK (prueba_1 BETWEEN 0 AND 100),   -- Resultado prueba técnica
    prueba_2                DECIMAL(4,2)            NOT NULL DEFAULT 00.00 CHECK (prueba_2 BETWEEN 0 AND 100),   -- Pruebas Psicotécnicas (Personalidad y Aptitud)
    prueba_3                DECIMAL(4,2)            NOT NULL DEFAULT 00.00 CHECK (prueba_3 BETWEEN 0 AND 100),   -- Resultado prueba de habilidades blandas
    ind_estado              BOOLEAN                 NOT NULL DEFAULT TRUE,                                       --TRUE = activo, FALSE = inactivo
    ind_borrado             BOOLEAN                 NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_candidato),
    FOREIGN KEY(id_ciudad) REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_tipo)   REFERENCES tab_tipo_identidad(id_tipo),           

    CONSTRAINT chk_candidato_fec_nac CHECK (fec_nacimiento <= CURRENT_DATE),
    CONSTRAINT chk_candidato_prueba1 CHECK (prueba_1 BETWEEN 0 AND 100),
    CONSTRAINT chk_candidato_prueba2 CHECK (prueba_2 BETWEEN 0 AND 100),
    CONSTRAINT chk_candidato_prueba3 CHECK (prueba_3 BETWEEN 0 AND 100)                     
);
CREATE INDEX idx_nom_candidato ON tab_candidatos(nom_candidato);                                                         -- Búsqueda rápida por persona
CREATE INDEX idx_nom_vacante ON tab_candidatos(nom_vacante);                                                             -- Búsqueda rápida por vacante






--9. TABLA DE EMPLEADOS
CREATE TABLE IF NOT EXISTS tab_empleados
(
    id_empleado             VARCHAR(10)            NOT NULL DEFAULT '0000000000',                                -- Número de identificación del empleado
    -- DATOS PERSONALES
    nom_empleado            VARCHAR(100)           NOT NULL DEFAULT 'SIN NOMBRE DE EMPLEADO',                    -- Nombres del empleado
    ape_empleado            VARCHAR(100)           NOT NULL DEFAULT 'SIN APELLIDO DE EMPLEADO',           -- Apellidos del empleado
    id_tipo                 VARCHAR(5)             NOT NULL DEFAULT 'SIN TIPO DE DOCUMENTO DE EMPLEADO',       -- Tipo de documento del empleado (C.C, C.E, PTT, etc)
    tipo_sangre             VARCHAR(5)             NOT NULL DEFAULT 'SIN TIPO DE SANGRE DE EMPLEADO',           -- Tipo de samgre del empleado
    fec_nacimiento          DATE                   NOT NULL DEFAULT '0001-01-01',          -- Fecha de nacimiento del empleado
    ind_genero              BOOLEAN                NOT NULL DEFAULT TRUE,                  -- Genero del empleado (true= masculino, false= femenino)
    estado_civil            VARCHAR(15)            NOT NULL DEFAULT 'SIN ESTADO CIVIL DE EMPLEADO',             -- Estado civil del empleado (Soltero, casado, etc)
    --DATOS GEOGRÁFICOS
    dir_empleado            DATOS_UBICACION        NOT NULL,                               -- Datos de contacto del empleado
    -- DATOS FAMILIARES
    nom_conyuge             VARCHAR(100)           NOT NULL DEFAULT 'SIN NOMBRE CÓNYUGE EMPLEADO',           -- Nombre conyuge del empleado
    num_hijos               DECIMAL(2,0)           NOT NULL DEFAULT 00,                    -- Número de hijos del empleado
    nom_contac_emer         VARCHAR(100)           NOT NULL DEFAULT 'SIN NOMBRE CONTACTO EMERGENCIA EMPLEADO',           -- Nombre del contacto de emergencia del empleado
    datos_contac_emer       DATOS_UBICACION        NOT NULL,                               -- Datos contacto de emergencia del empleado
    -- DATOS LABORALES
    id_cargo                VARCHAR(5)             NOT NULL DEFAULT 'CAR00',                 -- Número de identificación del cargo            
    id_area                 DECIMAL(5,0)           NOT NULL,                               -- Número de identificación del área
    id_profesion            VARCHAR(8)             NOT NULL DEFAULT 'PROF000',             -- Número de identificación de la profesión
    id_entidad_eps          VARCHAR(10)            NOT NULL DEFAULT '0000000000',           -- nombre de la eps del empleado
    id_entidad_ccf          VARCHAR(10)            NOT NULL DEFAULT '0000000000',           -- nombre caja de compensasión del empleado
    id_entidad_afp          VARCHAR(10)            NOT NULL DEFAULT '0000000000',           -- nombre del fondo de pension del empleado  
    id_entidad_arl          VARCHAR(10)            NOT NULL DEFAULT '0000000000',           -- nombre ARL del empleado
    fec_ingreso             DATE                   NOT NULL DEFAULT '1900-01-01',          -- fecha en la que ingreso a la empresa
    fec_retiro              DATE                   NOT NULL DEFAULT '2050-01-01',          -- fecha hasta la que trabajo
    val_salario             DECIMAL(12,0)          NOT NULL DEFAULT 1750905,             -- salario del empleado
    mail_corporativo        VARCHAR(30)            NOT NULL DEFAULT 'SIN CORREO CORPORATIVO DE EMPLEADO',           -- correo corporativo del empleado
    ult_vacaciones          DATE                   NOT NULL DEFAULT '1900-01-01',          -- ULTIMO PERIODO DE VACACIONES                  
    id_riesgo               DECIMAL(1,0)           NOT NULL DEFAULT 0,                               -- nivel de riesgo laboral
    id_banco                VARCHAR                NOT NULL,                               --nombre de banco para pago
    num_cuenta              VARCHAR(20)            NOT NULL,                               -- numero de cuenta bancaria para pagos
    ind_auditor             BOOLEAN                NOT NULL DEFAULT FALSE,                 -- ¿Es perfil auditor?
    ind_estado              BOOLEAN                NOT NULL DEFAULT TRUE,                  -- TRUE = ACTIVO FALSE = INACTIVO ¿Activo o Inactivo?
    ind_contratista         BOOLEAN                NOT NULL DEFAULT FALSE,                 -- TRUE=CONTRATISTA ¿Es de planta o contratista?
    ind_borrado             BOOLEAN                NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_empleado),                                                              -- PK                                      
    FOREIGN KEY (id_area)               REFERENCES tab_areas(id_area),                                 --Relación área
    FOREIGN KEY(id_tipo)                REFERENCES tab_tipo_identidad(id_tipo),
    FOREIGN KEY(id_profesion)           REFERENCES tab_profesiones(id_profesion),
    FOREIGN KEY(id_cargo)               REFERENCES tab_cargos(id_cargo),
    FOREIGN KEY(id_entidad_eps)         REFERENCES tab_entidades(id_entidad),
    FOREIGN KEY(id_entidad_afp)         REFERENCES tab_entidades(id_entidad),
    FOREIGN KEY(id_entidad_arl)         REFERENCES tab_entidades(id_entidad),
    FOREIGN KEY(id_entidad_ccf)         REFERENCES tab_entidades(id_entidad),
    FOREIGN KEY(id_banco)               REFERENCES tab_bancos(id_banco),                                -- Relación banco
    FOREIGN KEY(id_riesgo)              REFERENCES tab_riesgos(id_riesgo),                      -- Relación tabla de riesgos de SST

    CONSTRAINT chk_empleado_fec_nac CHECK (fec_nacimiento <= CURRENT_DATE),
    CONSTRAINT chk_empleado_fec_ingreso CHECK (fec_ingreso >= '1900-01-01'),
    CONSTRAINT chk_empleado_fec_retiro CHECK (fec_retiro >= fec_ingreso),
    CONSTRAINT chk_empleado_ult_vacaciones CHECK (ult_vacaciones >= fec_ingreso),
    CONSTRAINT chk_empleado_salario CHECK (val_salario > 0),
    CONSTRAINT chk_empleado_hijos CHECK (num_hijos >= 0)
);




--10. TABLA DE PRESTAMOS
CREATE TABLE IF NOT EXISTS tab_prestamos
(
    id_prestamo             VARCHAR(10)                   NOT NULL DEFAULT 'PRES000000',                             -- ID préstamo
    id_empleado             VARCHAR(10)                   NOT NULL DEFAULT '0000000000',                             -- Empleado deudor
    val_prestamo            DECIMAL(12,2)                 NOT NULL CHECK(val_prestamo > 0),                             -- Monto prestado
    num_cuotas              INTEGER                       NOT NULL CHECK(num_cuotas > 0),       -- Plazo en meses
    tasa_intereses          DECIMAL(5,2)                  NOT NULL,                             -- Interés cobrado
    fecha_inicio            DATE                          NOT NULL DEFAULT CURRENT_DATE,                             -- Fecha entrega
    fecha_fin               DATE                          NOT NULL DEFAULT '2050-01-01',                             -- Fecha fin pago
    ind_estado              BOOLEAN                       NOT NULL DEFAULT FALSE,                             -- ¿Deuda vigente?
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                        
    PRIMARY KEY(id_prestamo),
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),                                   -- Relación empleado

    CONSTRAINT chk_prestamo_valor CHECK (val_prestamo > 0),
    CONSTRAINT chk_prestamo_cuotas CHECK (num_cuotas > 0),
    CONSTRAINT chk_prestamo_tasa CHECK (tasa_intereses >= 0),
    CONSTRAINT chk_prestamo_fechas CHECK (fecha_fin >= fecha_inicio)
);


--11. TABLA DE CONCEPTO DE NOMINA
CREATE TABLE IF NOT EXISTS tab_conceptos
(
    id_concepto             VARCHAR(10)                     NOT NULL DEFAULT 'CONC000000',                       -- ID concepto (ej: 001)
    nom_concepto            VARCHAR(50)                     NOT NULL DEFAULT 'SIN NOMBRE DE CONCEPTO',                       --Salario, Hora Extra, Recargo Nocturno, Incapacidad, Prima, o Deducción.
    ind_obligatorio         BOOLEAN                         NOT NULL DEFAULT TRUE,          --TRUE = SI APLICA  FALSE = NO APLICA
    ind_devengado           BOOLEAN                         NOT NULL DEFAULT FALSE,         --TRUE = DEVENGADO FALSE = DEDUCIDO
    val_concepto            INTEGER                         NOT NULL,
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_concepto),                                                      

    CONSTRAINT chk_concepto_valor CHECK (val_concepto > 0)                                                
);
CREATE INDEX idx_nom_concepto ON tab_conceptos(nom_concepto); -- Búsqueda por nombre concepto




--12. TABLA DE NOVEDADES
CREATE TABLE IF NOT EXISTS tab_novedades
(
    ano_nomina              DECIMAL(4,0)                    NOT NULL,
    mes_nomina              DECIMAL(2,0)                    NOT NULL,
    val_periodo             DECIMAL(1,0)                    NOT NULL,
    id_empleado             VARCHAR(10)                     NOT NULL,                                                 -- Empleado afectado
    id_concepto             VARCHAR(10)                     NOT NULL,                                                 -- Tipo de novedad
    num_dias_trab           DECIMAL(2,0)                    NOT NULL DEFAULT 0,
    val_novedad             DECIMAL(9,0)                    NOT NULL,
    fec_novedad             DATE                            NOT NULL,
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(ano_nomina, mes_nomina, val_periodo, id_empleado, id_concepto,fec_novedad),                                           -- Relación concepto

    CONSTRAINT chk_novedades_mes CHECK (mes_nomina BETWEEN 1 AND 12),
    CONSTRAINT chk_novedades_periodo CHECK (val_periodo IN (1,2)),
    CONSTRAINT chk_novedades_dias CHECK (num_dias_trab >= 0),
    CONSTRAINT chk_novedades_fecha CHECK (fec_novedad <= CURRENT_DATE)
);


--13. TABLA DE PROCESOS DISCIPLINARIOS
CREATE TABLE IF NOT EXISTS tab_procesos_disciplinarios (
    id_proceso              VARCHAR(20)                     NOT NULL,
    id_empleado             VARCHAR(10)                     NOT NULL,
    fec_proceso             DATE                            NOT NULL,
    motivo                  TEXT                            NOT NULL,
    ind_estado_proceso      BOOLEAN                         NOT NULL,                                                                            -- 'En descargos', 'Cerrado', 'Anulado'
    sancion_final           VARCHAR(100),                                                                           -- 'Llamado de atención', 'Suspension X días'
    ind_borrado             BOOLEAN                             NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_proceso),
    FOREIGN KEY(id_empleado) REFERENCES tab_empleados(id_empleado),

    CONSTRAINT chk_proceso_fecha CHECK (fec_proceso <= CURRENT_DATE)

);


--14. TABLA DE NÓMINA
CREATE TABLE IF NOT EXISTS tab_nomina
(
    ano_nomina          DECIMAL(4,0)    NOT NULL,
    mes_nomina          DECIMAL(2,0)    NOT NULL,
    val_periodo         DECIMAL(1,0)    NOT NULL,
    id_empleado         VARCHAR(10)     NOT NULL REFERENCES tab_empleados(id_empleado),
    tot_devengado       DECIMAL(10,0)   DEFAULT 0,
    tot_deducido        DECIMAL(10,0)   DEFAULT 0,
    val_neto            DECIMAL(10,0)   NOT NULL CHECK(val_neto >= 0),                          -- valor neto a pagar al empleado
    ind_cerrado         BOOLEAN         NOT NULL,                --true: cerrada, false: abierta
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(ano_nomina, mes_nomina, val_periodo, id_empleado),                                                     -- PK

    CONSTRAINT chk_nomina_mes CHECK (mes_nomina BETWEEN 1 AND 12),
    CONSTRAINT chk_nomina_periodo CHECK (val_periodo IN (1,2)),
    CONSTRAINT chk_nomina_neto CHECK (val_neto >= 0),
    CONSTRAINT chk_nomina_devengado CHECK (tot_devengado >= 0),
    CONSTRAINT chk_nomina_deducido CHECK (tot_deducido >= 0)
);






--15. TABLA DE NÓMINA ELECTRÓNICA (DIAN)
CREATE TABLE IF NOT EXISTS tab_nomina_electronica
(
    id_nomina_electronica   VARCHAR(10)                     NOT NULL,
    periodo_mes             INTEGER                         NOT NULL,
    periodo_ano             INTEGER                         NOT NULL,
    archivo_xml             TEXT,                                                      -- XML generado
    track_id                VARCHAR(100),                                              -- ID de envío a DIAN
    estado_envio            VARCHAR(30)                     DEFAULT 'PENDIENTE',  -- PENDIENTE, ENVIADO, ACEPTADO, RECHAZADO
    fecha_envio             DATE,
    respuesta_dian          TEXT,
    ind_borrado             BOOLEAN                         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_nomina_electronica),

    CONSTRAINT chk_periodo_mes CHECK (periodo_mes BETWEEN 1 AND 12),
    CONSTRAINT chk_periodo_ano CHECK (periodo_ano >= 2000)
);


----------------------------------------------
-- MÓDULO DE SEGURIDAD Y SALUD EN EL TRABAJO -
----------------------------------------------

----------------------------------------------
-- MÓDULO DE SEGURIDAD Y SALUD EN EL TRABAJO -
----------------------------------------------

------------------------------
-- TABLA TIPO DE ACCIDENTES --
------------------------------

CREATE TABLE IF NOT EXISTS  tab_tipo_acc
(
    id_tipo_acc         	DECIMAL(4,0)		NOT NULL      	CHECK(id_tipo_acc >= 0 AND id_tipo_acc <= 9999),                        --IDENTIFICADOR PARA EL TIPO DE ACCIDENTE
    nom_acc              	VARCHAR     		NOT NULL      	CHECK(LENGTH(nom_acc) >= 0 AND LENGTH(nom_acc) <= 60),                  --NOMBRE DEL ACCIDENTE
    ind_clase_acc        	CHAR(3)     		NOT NULL      	CHECK(ind_clase_acc='L' OR ind_clase_acc='G'OR ind_clase_acc='M'),      --INDICADOR CLASE DE ACCIDENTE (L) LEVE (G) GRAVE (M) MORTAL
    obser_tipo_acc         	TEXT                NOT NULL        DEFAULT 'No hay observaciones',                                         --OBSERVACIONES DEL ACCIDENTE
    ind_borrado				BOOLEAN				NOT NULL 		DEFAULT FALSE, 						  
	PRIMARY KEY (id_tipo_acc)
);

----------------------
-- TABLA TIPO DE EPP--
----------------------
CREATE TABLE IF NOT EXISTS tab_epp
(
    id_epp             			DECIMAL(2,0)    NOT NULL        CHECK   (id_epp >= 1 AND id_epp <= 99),
    nom_epp            		 	VARCHAR(100)    NOT NULL        CHECK   (LENGTH(nom_epp) >= 5 AND LENGTH(nom_epp) <= 100),                  -- NOMBRE DESCRIPTIVO DEL TIPO DE EPP (EJ: 'CASCO DIELÉCTRICO CLASE E', 'ARNÉS DE CUERPO COMPLETO')
    nom_categoria	  		    CHAR(1) 	    NOT NULL        CHECK   (LENGTH(nom_categoria) >= 0 AND LENGTH(nom_categoria) <= 60),       -- CATEGORÍA DEL EPP (REFERENCIA A LA TABLA DE CATEGORÍA DE EPP)
	valor_riesgo				DECIMAL(1,0)	NOT NULL        CHECK   (valor_riesgo >= 0 AND valor_riesgo <= 4),                          -- NOMBRE DE LA CATEGORÍA DEL EPP (ej: 1_Cabeza, 2_Ojos, 3_Manos, 4_Vías respiratorias, 5_Caídas, 6_Auditiva, 7_No aplica)
    desc_epp             	    TEXT            NOT NULL        DEFAULT 'Sin descripción del EPP.', 									                            -- DESCRIPCIÓN DETALLADA DEL EPP: MATERIALES, ESPECIFICACIONES TÉCNICAS, USOS RECOMENDADOS
    vida_util_m             	DECIMAL(3,0)    NOT NULL        CHECK   (vida_util_m > 0), 				                                    -- VIDA ÚTIL DEL EPP EN MESES (EJ: 12 = 1 AÑO, 36 = 3 AÑOS)
	requiere_certi         		BOOLEAN         NOT NULL 		DEFAULT FALSE, 						                                        -- INDICA SI EL EPP REQUIERE CERTIFICACIÓN INDIVIDUAL (EJ: ARNESES, EQUIPOS RESPIRATORIOS), TRUE = REQUIERE CERTIFICACIÓN POR ORGANISMO EXTERNO, FALSE = NO REQUIERE
	cant_epp					DECIMAL(2,0)	NOT NULL 		CHECK   (cant_epp >= 0 AND cant_epp <= 99) DEFAULT 0,                       -- CANTIDAD DEL EPP DISPONIBLE PARA PODER ASIGNAR.
    ind_activo              	BOOLEAN         NOT NULL 		DEFAULT TRUE,   						                                    -- ESTADO DEL REGISTRO: TRUE = ACTIVO PARA NUEVAS ASIGNACIONES, FALSE = DESCONTINUADO
    ind_borrado					BOOLEAN			NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_epp)
);

-----------------------------
-- TABLA ASIGNACIÓN DE EPP --
-----------------------------
CREATE TABLE IF NOT EXISTS tab_epp_asignacion
(
    id_asignacion       DECIMAL(4,0)    NOT NULL        CHECK (id_asignacion >= 1 AND id_asignacion <= 9999),               -- Identificador de la asignación del epp para cada empleado.
    id_epp         		DECIMAL(4,0)    NOT NULL        CHECK (id_epp >= 1 AND id_epp <= 99),                                -- Referencia al tipo de EPP asignado (ej: Casco, Gafas, Arnés)
    id_empleado         VARCHAR(10)     NOT NULL        CHECK (LENGTH(id_empleado) >= 6 AND LENGTH(id_empleado) <= 10 ),    -- Empleado que recibe el EPP (puede ser NULL si se asigna a contratista)
    fecha_asignacion    DATE            NOT NULL        CHECK (fecha_asignacion <= CURRENT_DATE),                           -- Fecha en que se entregó físicamente el EPP al trabajador,  Debe ser menor o igual a la fecha actual (no se puede asignar en futuro)
    fecha_venci         DATE            NOT NULL        CHECK (fecha_venci > fecha_asignacion),                             -- Fecha hasta la cual el EPP es válido (basado en vida_util_meses + fecha_asignacion)
    ind_estado          CHAR(1)         NOT NULL        CHECK (ind_estado IN ('A', 'D', 'V', 'B')),                         -- ind para saber el estado del epp asignado. Asignado, devuelto, vencido, dado de baja
    obser_epp_asig      TEXT, 						                                                                        -- Observaciones generales: condición al entregar, instrucciones especiales, etc.
    ind_borrado			BOOLEAN		    NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_asignacion),
    FOREIGN KEY (id_epp) 			REFERENCES tab_epp(id_epp),
    FOREIGN KEY (id_empleado) 		REFERENCES tab_empleados(id_empleado)
);

-----------------------------
-- TABLA INSPECCIÓN DE EPP  --
-----------------------------

CREATE TABLE IF NOT EXISTS tab_epp_inspeccion
(
    id_inspeccion_epp   DECIMAL(10,0)   NOT NULL                        CHECK (id_inspeccion_epp >= 1 AND id_asignacion <= 9999),                        -- Identificador único de cada inspección realizada
    id_asignacion       DECIMAL(10,0)   NOT NULL                        CHECK (id_asignacion >= 1 AND id_asignacion <= 9999) ,                           -- Referencia a la asignación específica que se está inspeccionando, Permite saber qué trabajador tiene el EPP y desde cuándo
    fecha_inspeccion    DATE            NOT NULL                        CHECK (fecha_inspeccion <= CURRENT_DATE OR fecha_inspeccion >= CURRENT_DATE),    -- Fecha en que se realizó la inspección física del EPP, No puede ser futura (solo inspecciones pasadas o actuales)
    resultado           CHAR(1)         NOT NULL                        CHECK (resultado IN ('A', 'N', 'R')),                                            -- A = APROBADO, N = NO APROBADO, R = REQUIERE MANTENIMIENTO.
    proxima_inspeccion  DATE            NOT NULL  DEFAULT CURRENT_DATE  CHECK (proxima_inspeccion > CURRENT_DATE),                                       -- Fecha sugerida para la próxima inspección (ej: 3 meses, 6 meses según riesgo)
    obser_inspeccion    TEXT, 					                                                                                                         -- Detalles específicos de la inspección: qué se revisó, qué se encontró, Ej: 'Grietas en la suela del casco', 'Arnés con costuras desgastadas'
    id_empleado         VARCHAR(10)     NOT NULL,                                                                                                        -- Nombre de la persona que realizó la inspección (SST, supervisor, brigadista),Permite trazabilidad y rendición de cuentas
    ind_borrado		    BOOLEAN		    NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_inspeccion_epp),
    FOREIGN KEY (id_asignacion) REFERENCES tab_epp_asignacion(id_asignacion),
    FOREIGN KEY (id_empleado)   REFERENCES tab_empleados(id_empleado)
);

---------------------
--TABLA DE EXAMENES--
---------------------

CREATE TABLE IF NOT EXISTS tab_examenes 
(
  id_examen             DECIMAL(4,0)                                NOT NULL        CHECK (id_examen >= 1 and id_examen <= 9999),				    -- Indicador del examen
  nom_examen            VARCHAR                                     NOT NULL        CHECK (LENGTH(nom_examen) >= 5 AND LENGTH(nom_examen) <= 100),  -- Nombre del examen a realizar
  obser_examen          TEXT,                                                                                                                       -- Observaciones del examen (qué incluye, requisitos, etc.)
  ind_borrado		    BOOLEAN				                        NOT NULL 		DEFAULT FALSE,	                                                -- Indicador de borrado lógico
  PRIMARY KEY(id_examen)
);

-----------------------------------------
--TABLA DE ENCABEZADO EXAMEN DE INGRESO--
-----------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_ex_ingreso
(
  id_empleado         VARCHAR(10)                                  NOT NULL         CHECK (LENGTH(id_empleado) >= 6 AND LENGTH(id_empleado) <= 10 ),	    -- Indicador del empleado.
  fec_examen          TIMESTAMP WITHOUT TIME ZONE                  NOT NULL         CHECK (fec_examen <= CURRENT_TIMESTAMP),                                -- Fecha en que se realizó el examen.
  ind_tipo_examen     CHAR(3)                                      NOT NULL         CHECK (ind_tipo_examen IN ('ING', 'PER', 'RET', 'POS')),                -- INGRESO, PERIODICO, RETIRO, POST-INCAPACIDAD.
  ind_aptitud         CHAR(1)                                      NOT NULL         CHECK (ind_aptitud IN ('A', 'N', 'R')),                                 -- APTO, NO APTO, APTO CON RESTRICCIONES.
  aclaraciones        VARCHAR(300)                                 NOT NULL         ,                                                                       -- Aclaraciones adicionales sobre la aptitud del empleado, especialmente si es "APTO CON RESTRICCIONES". Aquí se detallan las limitaciones específicas o recomendaciones médicas para el empleado.
  ruta_emision        VARCHAR                                      NOT NULL         ,                                                                       -- Ruta o enlace al documento digital del examen médico, como un PDF escaneado o un enlace a un sistema de gestión de salud ocupacional.
  tipo_novedad        DECIMAL(1,0)                                 NOT NULL         CHECK (tipo_novedad >= 1 AND tipo_novedad <= 9),                        -- Tipo de novedad médica asociada al examen, si aplica. Esto puede referirse a categorías predefinidas de condiciones médicas o riesgos identificados durante el examen.
  ind_restri_lab      BOOLEAN                                      NOT NULL         ,                                                                       -- Indicador de restricciones laborales
  medico_examen       TEXT                                         NOT NULL         ,                                                                       -- Nombre del médico o profesional de la salud que realizó el examen, así como su especialidad o número de licencia, si es relevante.                                                                                                                                                                                                                                                                                                                                                                               
  res_examen          VARCHAR                                      NOT NULL         ,                                                                       -- Resolucion del examen
  ind_borrado		  BOOLEAN									   NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_empleado,fec_examen),
  FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);


-----------------------------------------
--TABLA DE DETALLE EXAMEN DE INGRESO   --
-----------------------------------------

CREATE TABLE IF NOT EXISTS tab_det_ex_ingreso
(
 id_empleado        VARCHAR(10)                                   NOT NULL      CHECK (LENGTH(id_empleado) >= 6 AND LENGTH(id_empleado) <= 10 ),    -- Identificador del empleado al que se le realizó el examen de ingreso.                                                                                                                                                                             
 id_examen          DECIMAL(4,0)                                  NOT NULL      CHECK (id_examen >= 1 and id_examen <= 9999),                       -- Identificador del examen.           
 val_resultado      VARCHAR                                       NOT NULL      CHECK (LENGTH(val_resultado) >= 1),                                 -- Resultado del examen
 ruta_resultado     VARCHAR                                       NOT NULL,                                                                         -- Ruta o enlace al documento digital del resultado específico de este examen.                 
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
 id_tipo_inca           DECIMAL(4,0)                               NOT NULL     CHECK (id_tipo_inca >=1 AND id_tipo_inca <= 9999),         	    -- Identificador del tipo de incapacidad.
 nom_tipo_inca          VARCHAR                                    NOT NULL,                                                            		-- Nombre descriptivo del tipo de incapacidad                                                                                        -- Descripción detallada del tipo de incapacidad, incluyendo criterios de clasificación, duración típica, y ejemplos de condiciones que podrían clasificarse bajo este tipo.
 clasi_tipo_incapacidad CHAR(3)                                    NOT NULL     CHECK (clasi_tipo_incapacidad IN ('IT', 'IPP', 'IPT')),         -- INCAPACIDAD TEMPORAL, INCAPACIDAD PERMAMENTE PARCIAL , INCAPACIDAD PERMANENTE TOTAL, clasificaciones de INCAPACIDADES
 ind_borrado	        BOOLEAN									   NOT NULL     DEFAULT FALSE,	
 PRIMARY KEY(id_tipo_inca)
);


---------------------------
-- TABLA DE INCAPACIDADES--
---------------------------

CREATE TABLE IF NOT EXISTS tab_incapacidades
(
 id_incapacidad   DECIMAL(4,0)                                   NOT NULL       CHECK (id_incapacidad >= 1 AND id_incapacidad <= 9999),         -- Identificador de la incapacidad.
 id_empleado      VARCHAR(10)                                    NOT NULL       CHECK (LENGTH(id_empleado)>=6 AND LENGTH(id_empleado)<=10),     -- Identificador del empleado.
 id_tipo_inca     DECIMAL(4,0)                                   NOT NULL       CHECK (id_tipo_inca >=1 AND id_tipo_inca <= 9999),              -- Identificador del tipo de incapacidad.
 id_empresa       VARCHAR(10)                                    NOT NULL       CHECK (id_empresa ~ '^[1-9][0-9]{7,9}$'),                       -- Identificador de la empresa (de donde viene la incapacidad, centro de salud).
 fecha_inicio     DATE                                           NOT NULL       CHECK (fecha_inicio <= CURRENT_DATE),                           -- Fecha de inicio de la incapacidad.
 fecha_fin        DATE                                           NOT NULL       CHECK (fecha_fin >= fecha_inicio),                              -- Fecha final de la incapacidad.
 ind_borrado	  BOOLEAN										 NOT NULL       DEFAULT FALSE,	                        
PRIMARY KEY(id_incapacidad),
FOREIGN KEY (id_empleado)   REFERENCES tab_empleados(id_empleado),
FOREIGN KEY (id_tipo_inca)  REFERENCES tab_tipo_incapacidad(id_tipo_inca),
FOREIGN KEY (id_empresa)    REFERENCES tab_pmtros_grales(id_empresa)
);

-------------------------------
--TABLA TEMAS DE CAPACITACIÓN--
-------------------------------
CREATE TABLE IF NOT EXISTS tab_temas_cap
(
    id_tema_cap             DECIMAL(4,0)                          NOT NULL         CHECK(id_tema_cap >= 0),                                        -- Identificar del tema de la capacitación.
    nom_tema                VARCHAR                               NOT NULL         CHECK(LENGTH(nom_tema) >= 0 AND LENGTH(nom_tema) <= 120      ),        -- Nombre de la capacitación o programa de salud que realizarán.
    ind_borrado				BOOLEAN								  NOT NULL 		   DEFAULT FALSE,	
    PRIMARY KEY (id_tema_cap)
);

---------------------
--TABLA DE DOCENTES--
---------------------

CREATE TABLE IF NOT EXISTS tab_docentes
(
  id_docente                VARCHAR(10)                           NOT NULL        CHECK (LENGTH(id_docente)>=6 AND LENGTH(id_docente)<=10),                             -- Identificador del docente que realiza la capacitación.
  id_empresa                VARCHAR(10)                           NOT NULL        CHECK(id_empresa ~ '^[1-9][0-9]{7,9}$'),                                              -- Identificador de la empresa de donde viene el docente.
  nom_docente               VARCHAR                               NOT NULL        CHECK (LENGTH(nom_docente) >= 2 AND LENGTH(nom_docente) <= 50),                       -- Nombres del docente.
  ape_docente               VARCHAR                               NOT NULL        CHECK (LENGTH(ape_docente) >= 2 AND LENGTH(ape_docente) <= 50),                       -- Apellidos del docente.
  correo_docente            VARCHAR                               NOT NULL        CHECK (correo_docente ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),         -- Correo electrónico del docente.
  tel_docente               VARCHAR(15)                           NOT NULL        CHECK (LENGTH(tel_docente) >= 7 AND LENGTH(tel_docente) <= 15),                       -- Teléfono de contacto del docente.                      
  ind_borrado				BOOLEAN								  NOT NULL        DEFAULT FALSE,	
  PRIMARY KEY (id_docente),
  FOREIGN KEY (id_empresa) REFERENCES tab_pmtros_grales(id_empresa)
);


---------------------------
--TABLA DE CAPACITACIONES--
---------------------------

CREATE TABLE IF NOT EXISTS tab_capacitaciones
(
 id_capacitacion          DECIMAL(4,0)                          NOT NULL    CHECK (id_capacitacion >=1 AND id_capacitacion <= 9999),    -- Identificador de la capacitación
 id_docente               VARCHAR(10)                           NOT NULL    CHECK (LENGTH(id_docente)>=6 AND LENGTH(id_docente)<=10),   -- Identificador del docente que imparte la capacitación.
 id_tema_cap              DECIMAL(4,0)                          NOT NULL    CHECK (id_tema_cap >= 1 AND id_tema_cap <= 9999),           -- Identificador del tema de capacitación.
 fec_capacita             TIMESTAMP WITHOUT TIME ZONE           NOT NULL    CHECK (fec_capacita >=  CURRENT_TIMESTAMP),                 -- Fecha en la que se realizará la capacitación.
 val_durac_capaci         DECIMAL(3,0)                          NOT NULL    CHECK (val_durac_capaci > 0),                               -- Valor de la duración de la capacitación en horas (ej: 2, 4, 8).
 mod_capaci               CHAR(1)                               NOT NULL    CHECK (mod_capaci IN ('P', 'V', 'M')),                      -- PRESENCIAL, VIRTUAL, MIXTA
 ind_programa_salud       BOOLEAN                               NOT NULL,                                                               -- Indica si la capacitación es perteneciente a un programa de salud.
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
    id_capacitacion         DECIMAL(4,0)                          NOT NULL      CHECK (id_capacitacion >=1 AND id_capacitacion <= 9999),    -- IDENTIFICADOR DE LA ASISTENCIA A LA CAPACITACIÓN
    id_empleado             VARCHAR(10)                           NOT NULL      CHECK (LENGTH(id_empleado)>=6 AND LENGTH(id_empleado)<=10), -- IDENTIFICADOR DEL EMPLEADO
    fec_asis                DATE                                  NOT NULL      CHECK (fec_asis <= CURRENT_DATE),                           -- FECHA DE ASISTENCIA A LA CAPACITACIÓN
    ind_asistio             BOOLEAN                               NOT NULL,                                                                 -- Indicador de la asistencia (programas de salud y capacitaciones): TRUE = ASISTIÓ, FALSE = NO ASISTIÓ
    ind_borrado				BOOLEAN								  NOT NULL 		DEFAULT FALSE,	
    PRIMARY KEY (id_capacitacion, id_empleado),
    FOREIGN KEY (id_capacitacion)   REFERENCES tab_capacitaciones(id_capacitacion),
    FOREIGN KEY (id_empleado)       REFERENCES tab_empleados(id_empleado)
);

---------------------
--TABLA  DE BRIGADA--
---------------------
CREATE TABLE IF NOT EXISTS tab_brigada
(
  id_brigada               DECIMAL(4,0)                          NOT NULL       CHECK (id_brigada >=1 AND id_brigada <= 9999),      -- Identificador de la brigada. 
  nom_brigada              VARCHAR                               NOT NULL       CHECK (LENGTH(nom_brigada) >= 5),                   -- Nombre de la brigada de emergencia.
  ind_borrado			   BOOLEAN								 NOT NULL 		DEFAULT FALSE,	                                    -- Indicador de borrado lógico para la brigada
  PRIMARY KEY(id_brigada)
);

-------------------------
--TABLA  DE BRIGADISTAS--
-------------------------
CREATE TABLE IF NOT EXISTS tab_brigadistas
(
  id_brigadista             VARCHAR(10)                          NOT NULL         CHECK (LENGTH(id_brigadista) >= 6 AND LENGTH(id_brigadista) <= 10 ),      -- Identificador de los brigadistas (miembros)
  id_brigada                DECIMAL(4,0)                         NOT NULL          CHECK (id_brigada >=1 AND id_brigada <= 9999),                           -- Identificador de la brigada    
  id_empleado               VARCHAR(10)                          NOT NULL         CHECK (id_empleado ~ '^[1-9][0-9]{7,9}$'),                                -- Identificador del empleado que hace parte de los brigadistas.      
  rol_brigadista            CHAR(1)                              NOT NULL         CHECK (rol_brigadista IN ('L','E')),                                      -- LIDERAZGO Y OPERACIÓN, EQUIPOS OPERATIVOS ESPECIALIZADOS.
  ind_borrado			    BOOLEAN							     NOT NULL 		  DEFAULT FALSE,	
  PRIMARY KEY (id_brigadista),
  FOREIGN KEY (id_brigada)      REFERENCES tab_brigada(id_brigada),
  FOREIGN KEY (id_empleado)     REFERENCES tab_empleados(id_empleado)
);
                           
------------------------
--TABLA  DE EMERGENCIA--
------------------------                        
CREATE TABLE IF NOT EXISTS tab_emergencia
(
  id_emergencia        DECIMAL(4,0)                          NOT NULL       CHECK (id_emergencia >=1 AND id_emergencia <=9999),      -- Identificador de la emergencia.
  fecha_emer           TIMESTAMP WITHOUT TIME ZONE           NOT NULL       CHECK (fecha_emer <= CURRENT_TIMESTAMP),                 -- Fecha y hora en que ocurrió la emergencia.
  tipo_emer            CHAR(1)                               NOT NULL       CHECK (tipo_emer IN ('I', 'S', 'M', 'O')),               -- INCENDIO, SISMO, MÉDICA, OTRO
  desc_emer            TEXT                                  NOT NULL       DEFAULT 'Sin descripción de emergencia.',                -- Descripción detallada de la emergencia, incluyendo qué ocurrió, cómo se manejó la situación, y cualquier lección aprendida o medida correctiva implementada posteriormente.  
  ind_borrado		   BOOLEAN								 NOT NULL 		DEFAULT FALSE,	        
  PRIMARY KEY(id_emergencia)
);

-----------------
--TABLA COPASST--
-----------------

CREATE TABLE IF NOT EXISTS tab_copasst
(
    id_copasst             DECIMAL(4,0)             NOT NULL                        CHECK(id_copasst >= 0),                     -- IDENTIFICADOR DEL COPASST
    periodo_inicio         DATE                                                     CHECK(periodo_inicio <= CURRENT_DATE),      -- FECHA DE INICIO DEL COPASST
    periodo_fin            DATE                                                     CHECK(periodo_fin <= CURRENT_DATE),         -- FECHA DE FIN DEL COPASST
    num_act_consti         DECIMAL(4,0)                                             CHECK(num_act_consti >= 0),                 -- NUMERO ACTA DE CONSTITUCION DEL COPASST
    ind_borrado			   BOOLEAN					NOT NULL 						DEFAULT FALSE,	
    PRIMARY KEY (id_copasst)
);

-------------------------
--TABLA MIEMBRO COPASST--
-------------------------

CREATE TABLE IF NOT EXISTS tab_miem_copasst
(
    id_copasst              DECIMAL(4,0)            NOT NULL                         CHECK(id_copasst >= 0),                    -- IDENTIFICADOR DEL COPASST
    id_empleado             VARCHAR(10)             NOT NULL                         CHECK(id_empleado ~ '^[1-9][0-9]{7,9}$'),  -- Identificador del empleado que es miembro del COPASST
    ind_rol                 BOOLEAN                 NOT NULL,                                                                   -- INDICADOR DE ROL EN EL COPASST: TRUE = PRESIDENTE, FALSE = VOCAL O SECRETARIO                      
    ind_borrado				BOOLEAN				    NOT NULL 						 DEFAULT FALSE,	
    PRIMARY KEY (id_copasst,id_empleado),               
    FOREIGN KEY (id_copasst) REFERENCES tab_copasst(id_copasst),
    FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado)
);

-------------------------
--TABLA REUNIÓN COPASST--
-------------------------
CREATE TABLE IF NOT EXISTS tab_reu_copasst
(
    id_reunion              DECIMAL(4,0)                        NOT NULL                           CHECK(id_reunion >= 0),          -- IDENTIFICADOR DE LA REUNIÓN DEL COPASST
    id_copasst              DECIMAL(4,0)                        NOT NULL                           CHECK(id_copasst >= 0),          -- IDENTIFICADOR DEL COPASST AL QUE PERTENECE LA REUNIÓN
    fec_reu                 TIMESTAMP WITHOUT TIME ZONE         NOT NULL                           CHECK(fec_reu <= CURRENT_DATE),  -- FECHA DE LA REUNIÓN DEL COPASST
    temas_reu               TEXT                                NOT NULL,                                                           -- TEMAS TRATADOS EN LA REUNIÓN DEL COPASST: DESCRIPCIÓN DETALLADA DE LOS PUNTOS ABORDADOS, DECISIONES TOMADAS, Y ACCIONES A SEGUIR. ESTO PERMITE LLEVAR UN REGISTRO CLARO DE LO DISCUTIDO EN CADA REUNIÓN Y FACILITA EL SEGUIMIENTO DE LAS TAREAS ASIGNADAS.
    acuer_reu_copasst       TEXT                                NOT NULL,                                                           -- ACUERDOS TOMADOS EN LA REUNIÓN DEL COPASST: DESCRIPCIÓN DE LOS ACUERDOS ESPECÍFICOS A LOS QUE SE LLEGÓ DURANTE LA REUNIÓN, INCLUYENDO QUIÉN ES RESPONSABLE DE CADA ACUERDO Y LOS PLAZOS PARA SU CUMPLIMIENTO. ESTO AYUDA A GARANTIZAR QUE LOS ACUERDOS SEAN CLAROS Y SE PUEDAN SEGUIR EFECTIVAMENTE.
    num_act_reu             DECIMAL(4,0)                        NOT NULL,                                                           -- NÚMERO DE ACTA DE LA REUNIÓN DEL COPASST, PARA REFERENCIA Y ARCHIVO.
    ind_borrado				BOOLEAN								NOT NULL 		                    DEFAULT FALSE,	
    PRIMARY KEY (id_reunion),
    FOREIGN KEY (id_copasst) REFERENCES tab_copasst(id_copasst)
);

----------------------------
--TABLA ASISTENCIA COPASST--
----------------------------
CREATE TABLE IF NOT EXISTS tab_asist_copasst
(
  id_asistencia           DECIMAL(5,0)                          NOT NULL        CHECK (id_asistencia >=1 AND id_asistencia <= 99999),       -- Identificador único de la asistencia al copasst
  id_reunion              DECIMAL(4,0)                          NOT NULL        CHECK (id_reunion >= 1 AND id_reunion <= 9999),             -- Identificador de la reunión del copasst a la que se asistió 
  id_copasst              DECIMAL(4,0)                          NOT NULL        CHECK(id_copasst >= 0),          							-- IDENTIFICADOR DEL COPASST AL QUE PERTENECE LA REUNIÓN	
  id_empleado             VARCHAR(10)                           NOT NULL        CHECK (id_empleado ~ '^[1-9][0-9]{7,9}$'),   				-- Identificador del miembro del copasst que asistió a la reunión, Referencia a la tabla de miembros del copasst para saber quién asistió a cada reunión.
  ind_asistio             BOOLEAN                               NOT NULL,                                                                   -- Indicador de asistencia a la reunión del copasst: TRUE = ASISTIÓ, FALSE = NO ASISTIÓ
  ind_borrado			  BOOLEAN								NOT NULL 		DEFAULT FALSE,	
  PRIMARY KEY(id_asistencia),
  FOREIGN KEY (id_reunion) REFERENCES tab_reu_copasst(id_reunion),
  FOREIGN KEY (id_copasst,id_empleado) REFERENCES tab_miem_copasst(id_copasst,id_empleado)
);

-----------------------
--TABLA DE INSPECCION--
-----------------------
CREATE TABLE IF NOT EXISTS tab_inspeccion
(
  id_inspeccion          DECIMAL(4,0)                         NOT NULL          CHECK (id_inspeccion >=1 AND id_inspeccion <= 9999),            -- Identificador de la inspección realizada.
  id_empleado            VARCHAR(10)                          NOT NULL          CHECK (LENGTH(id_empleado)>=6 AND LENGTH(id_empleado)<=10),     -- Identificador del empleado que realiza la inspección
  fec_inspeccion         TIMESTAMP WITHOUT TIME ZONE          NOT NULL          CHECK (fec_inspeccion = CURRENT_DATE),                          -- Fecha en que se realizó la inspección
  val_resultado          BOOLEAN                              NOT NULL,                                                                         -- Resultado de la inspección: TRUE = CONFORME, FALSE = NO CONFORME
  plan_accion            TEXT                                 NOT NULL          DEFAULT 'Sin plan de acción.',                                  -- Plan de acción para corregir las no conformidades encontradas
  ind_borrado			 BOOLEAN							  NOT NULL 		    DEFAULT FALSE,	
  PRIMARY KEY(id_inspeccion)
);

---------------------------
--TABLA DE AUDITORIAS SST--
---------------------------
CREATE TABLE IF NOT EXISTS tab_auditorias_sst
( 
  id_auditorias         DECIMAL(4,0)                          NOT NULL          CHECK (id_auditorias >=1 AND id_auditorias <= 9999),            -- Identificador de la auditoría de SST realizada.
  id_empleado           VARCHAR(10)                           NOT NULL          CHECK (LENGTH(id_empleado)>=6 AND LENGTH(id_empleado)<=10),     -- Identificador del empleado que realiza la auditoría de SST, Referencia a la tabla de empleados para saber quién realizó cada auditoría.
  id_area               DECIMAL(15,0)                         NOT NULL          ,                                                               -- Identificador del área a la que pertenece la auditoría de SST.
  fecha_audi            TIMESTAMP WITHOUT TIME ZONE           NOT NULL          ,                                                               -- Fecha en que se realizó la auditoría de SST.
  val_hallazgos         BOOLEAN                               NOT NULL          ,                                                               -- Hallazgos encontrados durante la auditoría de SST TRUE = HAY FALSE = NO HAY.
  acciones_correc       TEXT                                  NOT NULL          ,                                                               -- Acciones correctivas implementadas tras la auditoría de SST.
  ind_conformidad       BOOLEAN                               NOT NULL          ,                                                               -- Indicador de conformidad en la auditoría de SST: TRUE = CONFORME, FALSE = NO CONFORME.
  ind_borrado			BOOLEAN								  NOT NULL 		    DEFAULT FALSE,	
  PRIMARY KEY(id_auditorias),
  FOREIGN KEY (id_empleado) 	REFERENCES tab_empleados(id_empleado),
  FOREIGN KEY (id_area) 		REFERENCES tab_areas(id_area)
);

--------------------
--TABLA ACCIDENTES--
--------------------
CREATE TABLE IF NOT EXISTS tab_accidentes
(
	 id_accidente     	DECIMAL(4,0)                           NOT NULL         CHECK (id_accidente >=1 AND id_accidente <=9999),              -- Identificador único del accidente.
	 id_empleado      	VARCHAR(10)                            NOT NULL         CHECK (LENGTH(id_empleado)>=6 AND LENGTH(id_empleado)<=10),    -- Identificador del empleado involucrado en el accidente.
	 id_tipo_acc      	DECIMAL(4,0)                           NOT NULL         CHECK (id_tipo_acc >=1 AND id_tipo_acc <=9999),                -- Identificador del tipo de accidente.                                                              -- Identificador del contratista al que pertenece el empleado.
	 causa_acc        	VARCHAR                                NOT NULL         DEFAULT 'SIN CAUSAS',                                          -- Causa del accidente.
	 obser_acc        	TEXT                                   NOT NULL         DEFAULT 'SIN OBSERVACIONES',                                   -- OBSERVACIONES DEL ACCIDENTE
	 fec_acc          	TIMESTAMP WITHOUT TIME ZONE            NOT NULL         CHECK (fec_acc <= CURRENT_DATE),                               -- FECHA EN QUE OCURRIÓ EL ACCIDENTE
	 ind_borrado	  	BOOLEAN								   NOT NULL 		DEFAULT FALSE,                                       
	 
 PRIMARY KEY(id_accidente),
 FOREIGN KEY (id_empleado) REFERENCES tab_empleados(id_empleado),
 FOREIGN KEY (id_tipo_acc) REFERENCES tab_tipo_acc(id_tipo_acc)
);

-----------------------------------
--MÓDULO DE MARKETING Y COMERCIAL--
-----------------------------------
-- ===============================================================
-- TABLA DE PARÁMETROS DEL MÓDULO MARKETING Y COMERCIAL
-- ===============================================================

-- ===============================================================
-- TAB PARAMETROS MARCOM
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_pmtros_marcom
(
    id_empresa                  VARCHAR(10)   	 NOT NULL,
    val_dias_sin_interaccion    DECIMAL(3,0)    NOT NULL CHECK(val_dias_sin_interaccion >= 1 AND val_dias_sin_interaccion <= 365)          DEFAULT 15,      --Valor de dias sin interactuar el lead
    val_dias_expiracion_lead    DECIMAL(3,0)    NOT NULL CHECK(val_dias_expiracion_lead >= 1 AND val_dias_expiracion_lead <= 365)          DEFAULT 90,     --Valor de dias a los cuales expira un lead
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
    FOREIGN KEY(id_empresa) REFERENCES tab_pmtros_grales(id_empresa),
    CONSTRAINT chk_score_coherente CHECK(val_score_min_caliente > val_score_min_tibio), -- Temperatura coherente
    CONSTRAINT chk_techos_score CHECK(val_max_pts_segmentacion + val_max_pts_interacciones + val_max_pts_aperturas + val_max_pts_clics + val_max_pts_compra = 100));-- Techos suman exactamente 100

-- ===============================================================
-- TABLA DE ETAPAS DEL FUNNEL DE VENTAS
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_etapas_funnel

(
    id_etapa                DECIMAL(2,0)    NOT NULL CHECK(id_etapa > 0 AND id_etapa <= 99),                 --identificador de la tabla etapas funnel
    nom_etapa               VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_etapa)) >= 3),                    -- Ampliado: 30 era justo para etapas personalizadas
    ind_etapa_final         BOOLEAN         NOT NULL,                                                        --
    ind_estado              BOOLEAN         NOT NULL DEFAULT TRUE,                                           -- Indicador de estado que 
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,                                          --
    ind_es_perdido          BOOLEAN         NOT NULL DEFAULT FALSE,                                          --ind
    PRIMARY KEY(id_etapa)
);

-- ind_etapa_final: TRUE = el lead no avanza más desde aquí
-- ind_es_perdido:  TRUE = etapa de cierre negativo
INSERT INTO tab_etapas_funnel (id_etapa, nom_etapa, ind_etapa_final, ind_estado, ind_borrado, ind_es_perdido) VALUES
(1, 'Prospecto',     FALSE, TRUE, FALSE, FALSE),
(2, 'Contactado',    FALSE, TRUE, FALSE, FALSE),
(3, 'Calificado',    FALSE, TRUE, FALSE, FALSE),
(4, 'Propuesta',     FALSE, TRUE, FALSE, FALSE),
(5, 'Negociación',   FALSE, TRUE, FALSE, FALSE),
(6, 'Ganado',        TRUE,  TRUE, FALSE, FALSE),
(7, 'Perdido',       TRUE,  TRUE, FALSE, TRUE),
(8, 'Sin interés',   TRUE,  TRUE, FALSE, TRUE);

-- ===============================================================
-- TABLA DE CANALES DE DIFUSIÓN DE CAMPAÑAS
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_canales

(
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),                    -- Identificador unico de canal
    nom_canal           VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_canal)) >= 3),                       -- Nombre de canal 
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                              -- Indicador de estado de canales para saber si esta activo o inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                             -- Indicador de borrado
    PRIMARY KEY(id_canal)
);

INSERT INTO tab_canales (id_canal, nom_canal, ind_estado, ind_borrado) VALUES
(1,  'Email',          TRUE, FALSE),
(2,  'LinkedIn',       TRUE, FALSE),
(3,  'Instagram',      TRUE, FALSE),
(4,  'Facebook',       TRUE, FALSE),
(5,  'WhatsApp',       TRUE, FALSE),
(6,  'Llamada',        TRUE, FALSE),
(7,  'Reunión',        TRUE, FALSE),
(8,  'Sitio web',      TRUE, FALSE),
(9,  'Referido',       TRUE, FALSE),
(10, 'Feria/Evento',   TRUE, FALSE);

-- ===============================================================
-- TABLA DE CRITERIOS DE SEGMENTACIÓN
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_criterios_segmentacion --hacer crud
(
    id_criterio         DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),           -- Identificador unico de criterio
    nom_criterio        VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_criterio)) >= 3),                 -- Nombre de criterio (minimo 3 digitos)
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                           -- Indicador de estados de los criterios de segmentacion
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                          -- Indicador de borrado
    PRIMARY KEY(id_criterio)
);

INSERT INTO tab_criterios_segmentacion (id_criterio, nom_criterio, ind_estado, ind_borrado) VALUES
(1, 'Origen',           TRUE, FALSE),
(2, 'Temperatura',      TRUE, FALSE),
(3, 'Tamaño empresa',   TRUE, FALSE),
(4, 'Sector',           TRUE, FALSE),
(5, 'Otro',             TRUE, FALSE);

-- ===============================================================
-- TABLA DE VALORES DE SEGMENTACIÓN
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_valores_segmentacion -- hacer crud
(
    id_criterio         DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),             -- Identificador de criterio pk,fk
    id_valor            DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),                   -- Identificador de valor pk
    nom_valor           VARCHAR(60)     NOT NULL CHECK(LENGTH(TRIM(nom_valor)) >= 3),                      -- Nombre del valor de segmentacion
    des_valor           VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_valor)) >= 10),                     -- Descripcion del valor de segmentacion      
    val_peso            DECIMAL(4,2)    NOT NULL CHECK(val_peso >= 0.00 AND val_peso <= 10.00),            -- valor peso de criterio
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                             -- Indicador de estado para valores de segmentacion
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, 
    PRIMARY KEY(id_criterio, id_valor),
    FOREIGN KEY(id_criterio) REFERENCES tab_criterios_segmentacion(id_criterio),
    UNIQUE(id_criterio, nom_valor)
);

INSERT INTO tab_valores_segmentacion (id_criterio, id_valor, nom_valor, des_valor, val_peso, ind_estado, ind_borrado) VALUES
-- Origen (1)
(1, 1, 'Redes Sociales',    'Lead captado a través de LinkedIn, Instagram o Facebook.',                        2.00, TRUE, FALSE),
(1, 2, 'Referido',          'Lead recomendado directamente por un cliente o contacto existente.',              3.00, TRUE, FALSE),
(1, 3, 'Búsqueda orgánica', 'Lead que llegó a través de búsqueda en internet sin pauta paga.',                 1.00, TRUE, FALSE),
(1, 4, 'Email',             'Lead captado mediante campaña de email marketing.',                               2.00, TRUE, FALSE),
(1, 5, 'Feria o evento',    'Lead contactado en un evento presencial o feria comercial.',                      2.50, TRUE, FALSE),
-- Temperatura (2)
(2, 1, 'Frío',              'Lead sin interés claro aún, en etapa inicial de conocimiento.',                   1.00, TRUE, FALSE),
(2, 2, 'Tibio',             'Lead que mostró algún interés pero aún no toma decisión de compra.',              2.00, TRUE, FALSE),
(2, 3, 'Caliente',          'Lead listo para tomar una decisión de compra en el corto plazo.',                 3.00, TRUE, FALSE),
-- Tamaño empresa (3)
(3, 1, 'Pequeña',           'Empresa con menos de 50 empleados.',                                             1.00, TRUE, FALSE),
(3, 2, 'Mediana',           'Empresa con entre 50 y 200 empleados.',                                          2.00, TRUE, FALSE),
(3, 3, 'Grande',            'Empresa con más de 200 empleados.',                                              3.00, TRUE, FALSE),
-- Sector (4)
(4, 1, 'Tecnología',        'Empresa perteneciente al sector de tecnología, software o servicios digitales.',  2.00, TRUE, FALSE),
(4, 2, 'Manufactura',       'Empresa del sector industrial o de producción manufacturera.',                    2.00, TRUE, FALSE),
(4, 3, 'Servicios',         'Empresa prestadora de servicios profesionales o comerciales.',                    2.00, TRUE, FALSE),
(4, 4, 'Comercio',          'Empresa dedicada a la compra y venta de productos al por mayor o menor.',         1.50, TRUE, FALSE),
(4, 5, 'Otro',              'Sector económico no clasificado en las categorías anteriores.',                   1.00, TRUE, FALSE),
-- Otro (5)
(5, 1, 'Por definir',       'Criterio adicional configurable según las necesidades del negocio.',              1.00, TRUE, FALSE);

-- ===============================================================
-- TABLA DE CAMPOS DE SEGMENTACIÓN
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_tablas_marcom
(
    id_tabla            DECIMAL(2,0)    NOT NULL CHECK(id_tabla > 0 AND id_tabla <= 99),                --
    nom_tabla           VARCHAR(80)     NOT NULL CHECK(LENGTH(TRIM(nom_tabla)) >= 3),                   --
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                          --
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                         --
    PRIMARY KEY(id_tabla),
    UNIQUE(nom_tabla)
);

INSERT INTO tab_tablas_marcom (id_tabla, nom_tabla, ind_estado, ind_borrado) VALUES
(1, 'tab_leads',     TRUE, FALSE),
(2, 'tab_terceros',  TRUE, FALSE);

-- ===============================================================
-- TABLA DE ATRIBUTOS POR TABLA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_atributos_marcom
(
    id_tabla            DECIMAL(2,0)    NOT NULL CHECK(id_tabla > 0 AND id_tabla <= 99),                --
    id_atributo         DECIMAL(3,0)    NOT NULL CHECK(id_atributo > 0 AND id_atributo <= 999),         --
    nom_atributo        VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_atributo)) >= 3),                --
    tipo_dato           VARCHAR(10)     NOT NULL CHECK(tipo_dato IN ('NUMERICO', 'TEXTO', 'FECHA')),    --
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                          --
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                         --
    PRIMARY KEY(id_tabla, id_atributo),
    FOREIGN KEY(id_tabla) REFERENCES tab_tablas_marcom(id_tabla),
    UNIQUE(id_tabla, nom_atributo)
);

INSERT INTO tab_atributos_marcom (id_tabla, id_atributo, nom_atributo, tipo_dato, ind_estado, ind_borrado) VALUES
-- Atributos de tab_leads (id_tabla=1)
(1, 1, 'id_canal',          'NUMERICO', TRUE, FALSE),
(1, 2, 'id_etapa',          'NUMERICO', TRUE, FALSE),
(1, 3, 'val_score',         'NUMERICO', TRUE, FALSE),
(1, 4, 'fec_registro',      'FECHA',    TRUE, FALSE),
-- Atributos de tab_terceros (id_tabla=2)
(2, 1, 'ind_tipo_tercero',  'NUMERICO', TRUE, FALSE),
(2, 2, 'id_cat_tercero',    'NUMERICO', TRUE, FALSE);

-- ===============================================================
-- TABLA DE CAMPOS DE SEGMENTACIÓN
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_campos_segmentacion_marcom
(
    id_campo            DECIMAL(3,0)    NOT NULL CHECK(id_campo > 0 AND id_campo <= 999),               --
    id_tabla            DECIMAL(2,0)    NOT NULL CHECK(id_tabla > 0 AND id_tabla <= 99),                --
    id_atributo         DECIMAL(3,0)    NOT NULL CHECK(id_atributo > 0 AND id_atributo <= 999),         --
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                          --
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                         --
    PRIMARY KEY(id_campo),
    FOREIGN KEY(id_tabla, id_atributo) REFERENCES tab_atributos_marcom(id_tabla, id_atributo),
    UNIQUE(id_tabla, id_atributo)  -- un atributo no puede registrarse dos veces como campo
);

INSERT INTO tab_campos_segmentacion_marcom (id_campo, id_tabla, id_atributo, ind_estado, ind_borrado) VALUES
(1, 1, 1, TRUE, FALSE),  -- tab_leads.id_canal
(2, 1, 2, TRUE, FALSE),  -- tab_leads.id_etapa
(3, 1, 3, TRUE, FALSE),  -- tab_leads.val_score
(4, 2, 1, TRUE, FALSE),  -- tab_terceros.ind_tipo_tercero
(5, 2, 2, TRUE, FALSE);  -- tab_terceros.id_cat_tercero

-- ===============================================================
-- TABLA DE REGLAS DE SEGMENTACIÓN AUTOMÁTICA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_reglas_segmentacion --crud
(
    id_regla        DECIMAL(3,0)    NOT NULL CHECK(id_regla > 0 AND id_regla <= 999),
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),  
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),        
    tipo_logica     VARCHAR(3)      NOT NULL DEFAULT 'AND' CHECK(tipo_logica IN ('AND', 'OR')),
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,                                   -- Añadido NOT NULL
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(id_regla),
    FOREIGN KEY(id_criterio, id_valor) REFERENCES tab_valores_segmentacion(id_criterio, id_valor)              
);

-- Reglas: cada una asigna un criterio+valor si sus condiciones se cumplen
INSERT INTO tab_reglas_segmentacion (id_regla, id_criterio, id_valor, tipo_logica, ind_estado, ind_borrado) VALUES
(1, 1, 1, 'OR',  TRUE, FALSE),  -- Si canal=Redes Sociales → Origen=Redes Sociales
(2, 1, 4, 'AND', TRUE, FALSE),  -- Si canal=Email          → Origen=Email
(3, 2, 3, 'AND', TRUE, FALSE),  -- Si score>=70            → Temperatura=Caliente
(4, 2, 2, 'AND', TRUE, FALSE),  -- Si score>=40 Y score<70 → Temperatura=Tibio
(5, 2, 1, 'AND', TRUE, FALSE);  -- Si score<40             → Temperatura=Frío

-- ===============================================================
-- TABLA DE OPERADORES
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_operadores_marcom
(
    id_operador     SMALLINT    	 GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 99),
    nom_operador    VARCHAR(3)      NOT NULL UNIQUE CHECK (LENGTH(TRIM(nom_operador)) >= 1),
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_operador)
);

INSERT INTO tab_operadores_marcom (nom_operador, ind_estado, ind_borrado) VALUES
('=',    TRUE, FALSE),
('<>',   TRUE, FALSE),
('>',    TRUE, FALSE),
('>=',   TRUE, FALSE),
('<',    TRUE, FALSE),
('<=',   TRUE, FALSE);

-- ===============================================================
-- TABLA DE CONDICIONES DE REGLA (actualizada)
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_condiciones_regla_marcom
(
    id_regla        DECIMAL(3,0)    NOT NULL CHECK(id_regla > 0 AND id_regla <= 999),
    id_condicion    DECIMAL(3,0)    NOT NULL CHECK(id_condicion > 0 AND id_condicion <= 999),
    id_campo        DECIMAL(3,0)    NOT NULL CHECK(id_campo > 0 AND id_campo <= 999),
    id_operador     SMALLINT	     NOT NULL CHECK(id_operador > 0 AND id_operador <= 99),
    val_condicion   TEXT            NOT NULL CHECK(LENGTH(TRIM(val_condicion)) > 0),
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,

    PRIMARY KEY(id_regla, id_condicion),
    FOREIGN KEY(id_regla)    REFERENCES tab_reglas_segmentacion(id_regla),
    FOREIGN KEY(id_campo)    REFERENCES tab_campos_segmentacion_marcom(id_campo),
    FOREIGN KEY(id_operador) REFERENCES tab_operadores_marcom(id_operador)
);

-- Condiciones de la regla 1 (OR): canal LinkedIn, Instagram o Facebook
INSERT INTO tab_condiciones_regla_marcom (id_regla, id_condicion, id_campo, id_operador, val_condicion, ind_borrado) VALUES
(1, 1, 1, 1, '2', FALSE),   -- id_canal = 2 (LinkedIn)
(1, 2, 1, 1, '3', FALSE),   -- id_canal = 3 (Instagram)
(1, 3, 1, 1, '4', FALSE);   -- id_canal = 4 (Facebook)

-- Condiciones de la regla 2 (AND): canal Email
INSERT INTO tab_condiciones_regla_marcom (id_regla, id_condicion, id_campo, id_operador, val_condicion, ind_borrado) VALUES
(2, 1, 1, 1, '1', FALSE);   -- id_canal = 1 (Email)

-- Condiciones de la regla 3 (AND): score >= 70
INSERT INTO tab_condiciones_regla_marcom (id_regla, id_condicion, id_campo, id_operador, val_condicion, ind_borrado) VALUES
(3, 1, 3, 4, '70', FALSE);  -- val_score >= 70

-- Condiciones de la regla 4 (AND): score >= 40 Y score < 70
INSERT INTO tab_condiciones_regla_marcom (id_regla, id_condicion, id_campo, id_operador, val_condicion, ind_borrado) VALUES
(4, 1, 3, 4, '40', FALSE),  -- val_score >= 40
(4, 2, 3, 5, '70', FALSE);  -- val_score < 70

-- Condiciones de la regla 5 (AND): score < 40
INSERT INTO tab_condiciones_regla_marcom (id_regla, id_condicion, id_campo, id_operador, val_condicion, ind_borrado) VALUES
(5, 1, 3, 5, '40', FALSE);  -- val_score < 40



 
-- ===============================================================
-- TABLA DE SEGMENTACIÓN DE TERCEROS
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_segmentacion_cliente
(
    id_tercero      VARCHAR(10)   NOT NULL CHECK(id_tercero ~ '^[1-9][0-9]{7,9}$'),					      --
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),                  -- Añadido: necesario para FK compuesta y garantizar un valor por criterio
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),                        -- Corregido: DECIMAL(3,0) → DECIMAL(2,0) consistente con PK compuesta
    fec_asignacion  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,                                     -- Añadido NOT NULL
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(id_tercero, id_criterio),                                                   
    FOREIGN KEY(id_tercero)             REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_criterio, id_valor)  REFERENCES tab_valores_segmentacion(id_criterio, id_valor) -- Corregido: FK simple → FK compuesta
);

-- ===============================================================
-- TABLA DE TIPOS DE CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_tipo_campana
(
    id_tipo_campana     DECIMAL(2,0)    NOT NULL CHECK(id_tipo_campana > 0 AND id_tipo_campana <= 99),      --
    nom_tipo_campana    VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_tipo_campana)) >= 3),                -- Ampliado: 40 → 50. Añadido CHECK faltante
    des_tipo_campana    VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_tipo_campana)) >= 10),               -- Tipado: TEXT → VARCHAR(250). Añadido CHECK faltante
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                              -- Añadido NOT NULL y DEFAULT TRUE
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,                                             -- Añadido NOT NULL
    
    PRIMARY KEY(id_tipo_campana)
);

INSERT INTO tab_tipo_campana (id_tipo_campana, nom_tipo_campana, des_tipo_campana, ind_estado, ind_borrado) VALUES
(1, 'Email marketing',   'Campañas enviadas por correo electrónico a segmentos de leads o clientes.',              TRUE, FALSE),
(2, 'Redes sociales',    'Campañas publicadas en plataformas sociales como LinkedIn, Instagram o Facebook.',       TRUE, FALSE),
(3, 'Evento presencial', 'Campañas orientadas a la convocatoria y seguimiento de eventos físicos.',                TRUE, FALSE),
(4, 'Webinar',           'Campañas orientadas a eventos virtuales con registro y seguimiento de asistencia.',      TRUE, FALSE),
(5, 'Mixta',             'Campañas que combinan múltiples canales y formatos en una misma estrategia.',            TRUE, FALSE);

-- ===============================================================
-- TABLA DE CAMPAÑAS
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_campanas
(
    id_campana      BIGINT     GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 999999),
    id_tipo_campana DECIMAL(2,0)    NOT NULL CHECK(id_tipo_campana > 0 AND id_tipo_campana <= 99),
    nom_campana     VARCHAR(120)    NOT NULL CHECK(LENGTH(TRIM(nom_campana)) >= 3),
    fec_inicio      DATE            NOT NULL,
    fec_fin         DATE            NOT NULL,
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,

    PRIMARY KEY(id_campana),
    FOREIGN KEY(id_tipo_campana) REFERENCES tab_tipo_campana(id_tipo_campana),
    CONSTRAINT chk_fechas_campana CHECK(fec_fin > fec_inicio)  -- Corregido: >= → > mínimo 1 día de duración
);

-- ===============================================================
-- TABLA CAMPAÑA CANAL
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_campana_canal
(
    id_campana      BIGINT    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_canal        DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    
    PRIMARY KEY(id_campana, id_canal),
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_canal)   REFERENCES tab_canales(id_canal)
);

-- ===============================================================
-- TABLA DE MOTIVOS DE PÉRDIDA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_motivos_perdida
(
    id_motivo_perdida   SMALLINT    	 GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 99), -- Corregido: >= 0 para permitir el registro especial
    nom_motivo          VARCHAR(60)     NOT NULL CHECK(LENGTH(TRIM(nom_motivo)) >= 3),
    des_motivo          VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_motivo)) >= 10),
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(id_motivo_perdida)
);

INSERT INTO tab_motivos_perdida (nom_motivo, des_motivo, ind_estado, ind_borrado) VALUES
('Precio alto',        'El lead consideró que el precio del producto o servicio superaba su presupuesto disponible.',         TRUE, FALSE),
('Sin presupuesto',    'El lead no contaba con presupuesto aprobado para realizar la compra en este momento.',                TRUE, FALSE),
('Eligió competencia', 'El lead decidió adquirir una solución similar con un competidor.',                                    TRUE, FALSE),
('Sin necesidad',      'El lead determinó que no requería el producto o servicio ofrecido.',                                  TRUE, FALSE),
('Sin respuesta',      'El lead dejó de responder los intentos de contacto sin dar una razón explícita.',                     TRUE, FALSE),
('Mala calificación',  'El lead no cumplió con los criterios mínimos de calificación definidos por el equipo comercial.',     TRUE, FALSE),
('Proyecto cancelado', 'El proyecto interno del lead que motivaba la compra fue cancelado o postergado indefinidamente.',     TRUE, FALSE),
('Otro',               'Motivo de pérdida no clasificado en las categorías anteriores. Requiere nota manual del vendedor.',   TRUE, FALSE);
 
-- ===============================================================
-- 1. tab_leads — ID propio del sistema, sin NULL (centinela 'NOESCLIENT')
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_leads
(
    id_lead             BIGINT          GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999),
    id_tercero          VARCHAR(10)     NOT NULL DEFAULT 'NOESCLIENT' CHECK(id_tercero = 'NOESCLIENT' OR id_tercero ~ '^[A-Z0-9]{7,10}$'),
    nom_lead            VARCHAR(100)    NOT NULL CHECK(LENGTH(TRIM(nom_lead)) >= 3),
    tel_lead            DECIMAL(10,0)   NOT NULL CHECK(tel_lead >= 1000000000),
    email_lead          VARCHAR(120)    NOT NULL CHECK(email_lead ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    id_ciudad           VARCHAR(5)      NOT NULL,
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    fec_registro        DATE            NOT NULL DEFAULT CURRENT_DATE,
    val_score           DECIMAL(3,0)    NOT NULL CHECK(val_score >= 0 AND val_score <= 100) DEFAULT 0,
    id_etapa            DECIMAL(2,0)    NOT NULL CHECK(id_etapa > 0 AND id_etapa <= 99) DEFAULT 1,
    id_motivo_perdida   SMALLINT        NOT NULL CHECK(id_motivo_perdida >= 0 AND id_motivo_perdida <= 99) DEFAULT 0,
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_lead),
    FOREIGN KEY(id_tercero)        REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_ciudad)         REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_canal)          REFERENCES tab_canales(id_canal),
    FOREIGN KEY(id_etapa)          REFERENCES tab_etapas_funnel(id_etapa),
    FOREIGN KEY(id_motivo_perdida) REFERENCES tab_motivos_perdida(id_motivo_perdida),
 
    -- Solo puede tener id_tercero real si ya está en etapa 6 (Ganado)
    CONSTRAINT chk_lead_solo_convertido_tiene_tercero CHECK(
        (id_tercero = 'NOESCLIENT') OR (id_tercero <> 'NOESCLIENT' AND id_etapa = 6)
    )
);

-- ===============================================================
-- TABLA DE SEGMENTACION DE LEAD
-- ===============================================================
CREATE TABLE IF NOT EXISTS tab_segmentacion_lead
(
    id_lead         BIGINT          NOT NULL,
    id_criterio     DECIMAL(2,0)    NOT NULL CHECK(id_criterio > 0 AND id_criterio <= 99),
    id_valor        DECIMAL(2,0)    NOT NULL CHECK(id_valor > 0 AND id_valor <= 99),
    fec_asignacion  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,
 
    PRIMARY KEY(id_lead, id_criterio),
    FOREIGN KEY(id_lead)                REFERENCES tab_leads(id_lead),
    FOREIGN KEY(id_criterio, id_valor)  REFERENCES tab_valores_segmentacion(id_criterio, id_valor)
);

-- ===============================================================
-- TABLA LEAD CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_lead_camp
(
    id_lead             BIGINT  	    NOT NULL,
    id_campana          SMALLINT        NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    fec_asignacion      DATE            NOT NULL DEFAULT CURRENT_DATE,                              -- Añadido NOT NULL
    id_etapa_entrada    DECIMAL(2,0)    NOT NULL CHECK(id_etapa_entrada > 0 AND id_etapa_entrada <= 99), -- Renombrado: id_etapa → id_etapa_entrada, valor histórico que nunca cambia
    ind_origen          DECIMAL(1,0)    NOT NULL CHECK(ind_origen IN (1, 2, 3)),                    -- Corregido: CHECK >= 1 AND <= 3 → IN (1,2,3) más explícito -- 1=Manual / 2=Automático / 3=Importado
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                      -- Añadido NOT NULL y DEFAULT TRUE
    
    PRIMARY KEY(id_lead, id_campana),
    FOREIGN KEY(id_lead)            REFERENCES tab_leads(id_lead),
    FOREIGN KEY(id_campana)         REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_etapa_entrada)   REFERENCES tab_etapas_funnel(id_etapa)                  -- FK hacia etapas para integridad referencial
);

-- ===============================================================
-- TABLA CLIENTE CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_cliente_camp
(
    id_tercero          VARCHAR(10)     NOT NULL,
    id_campana          BIGINT          NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    fec_asignacion      DATE            NOT NULL DEFAULT CURRENT_DATE,
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,
 
    PRIMARY KEY(id_tercero, id_campana),
    FOREIGN KEY(id_tercero)  REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_campana)  REFERENCES tab_campanas(id_campana)
);

-- ===============================================================
-- TABLA DE TIPOS DE INTERACCIÓN
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_tipos_interaccion_marcom
(
    id_tip_interaccion 	    BIGINT        GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999),
    nom_tipo_interaccion    VARCHAR(50)     NOT NULL CHECK(LENGTH(TRIM(nom_tipo_interaccion)) >= 3),
    ind_estado              BOOLEAN         NOT NULL DEFAULT TRUE,
    ind_borrado             BOOLEAN         NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_tip_interaccion)
);

INSERT INTO tab_tipos_interaccion_marcom (nom_tipo_interaccion, ind_estado, ind_borrado) VALUES
('Llamada telefónica',   TRUE, FALSE),
('Email enviado',        TRUE, FALSE),
('Reunión presencial',   TRUE, FALSE),
('Reunión virtual',      TRUE, FALSE),
('Mensaje WhatsApp',     TRUE, FALSE),
('Visita comercial',     TRUE, FALSE),
('Demo del producto',    TRUE, FALSE),
('Envío de propuesta',   TRUE, FALSE);

-- ===============================================================
-- TABLA DE INTERACCIONES UNIFICADA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_interacciones
(
    id_interaccion      DECIMAL(10,0)   NOT NULL CHECK(id_interaccion > 0 AND id_interaccion <= 9999999999),
    id_lead             BIGINT          NOT NULL DEFAULT 0,          -- 0 = no viene de un lead
    id_tercero          VARCHAR(10)     NOT NULL DEFAULT 'NOESLEAD', -- 'NOESLEAD' = no viene de un cliente
    ind_es_lead         BOOLEAN         NOT NULL,
    id_vendedor         VARCHAR(10)     NOT NULL,
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    fec_interaccion     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_tipo_interaccion DECIMAL(2,0)    NOT NULL CHECK(id_tipo_interaccion > 0 AND id_tipo_interaccion <= 99),
    des_resultado       VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_resultado)) >= 3),
 
    PRIMARY KEY(id_interaccion),
    FOREIGN KEY(id_lead)     REFERENCES tab_leads(id_lead),
    FOREIGN KEY(id_tercero)  REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_vendedor) REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY(id_canal)    REFERENCES tab_canales(id_canal),
 
    -- Exactamente un dueño: o es de un lead, o es de un cliente, nunca los dos ni ninguno
    CONSTRAINT chk_interaccion_un_solo_dueno CHECK(
        (ind_es_lead = TRUE  AND id_lead <> 0 AND id_tercero = 'NOESLEAD') OR
        (ind_es_lead = FALSE AND id_tercero <> 'NOESLEAD' AND id_lead = 0)
    )
);

-- ===============================================================
--TABLA PROXIMAS ACCIONES
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_proximas_acciones
(
    id_accion       BIGINT          GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999),
    id_interaccion  DECIMAL(10,0)   NOT NULL CHECK(id_interaccion > 0 AND id_interaccion <= 9999999999),
    fec_accion      DATE            NOT NULL,                                                            -- Validación de fecha futura en PHP: no en BD para no romper datos históricos
    des_accion      VARCHAR(250)    NOT NULL CHECK(LENGTH(TRIM(des_accion)) >= 10),
    ind_completada  BOOLEAN         NOT NULL DEFAULT FALSE,
    fec_completada  DATE            NOT NULL DEFAULT '2999-12-31', -- 9999-12-31 = acción pendiente, fecha real = acción completada
    
    PRIMARY KEY(id_accion),
    FOREIGN KEY(id_interaccion) REFERENCES tab_interacciones(id_interaccion),
    CONSTRAINT chk_fec_completada CHECK(
        (ind_completada = FALSE AND fec_completada = '9999-12-31'  ) OR  -- pendiente → sin fecha real
        (ind_completada = TRUE  AND fec_completada < '9999-12-31'  )     -- completada → con fecha real
    )
);

-- ===============================================================
-- TABLA DE EVENTOS
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_evento
(
    id_evento       DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    id_campana      BIGINT          NULL     CHECK(id_campana > 0 AND id_campana <= 999999), -- NULL justificado: evento puede existir sin campaña
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
    FOREIGN KEY(id_responsable) REFERENCES tab_terceros(id_tercero),
    CONSTRAINT chk_fechas_evento CHECK(fec_fin > fec_inicio)                                 -- Garantiza mínimo un instante de duración
);

-- ===============================================================
-- TABLA EVENTO LEAD
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_even_lead
(
    id_evento           DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    id_lead             BIGINT          NOT NULL,                                                          -- Corregido: DECIMAL(10,0) → VARCHAR(10)
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

-- ===============================================================
-- TABLA PRODUCTO CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_prod_camp
(
    id_campana      BIGINT    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_producto     DECIMAL(3,0)    NOT NULL CHECK(id_producto > 0 AND id_producto <= 999),
    fec_asignacion  DATE            NOT NULL DEFAULT CURRENT_DATE,  -- Añadido: trazabilidad de cuándo se asignó el producto
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,          -- Añadido: desactivar producto sin eliminar registro
    ind_borrado     BOOLEAN         NOT NULL DEFAULT FALSE,         -- Añadido: borrado lógico consistente con el esquema
    PRIMARY KEY(id_campana, id_producto),
    FOREIGN KEY(id_campana)  REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);

-- ===============================================================
-- TABLA DE PRESUPUESTO DE CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_presupuesto_campana
(
    id_presupuesto      DECIMAL(6,0)    NOT NULL CHECK(id_presupuesto > 0 AND id_presupuesto <= 999999),
    id_campana          BIGINT    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    val_aprobado        DECIMAL(12,0)   NOT NULL CHECK(val_aprobado >= 0),
    val_ejecutado       DECIMAL(12,0)   NOT NULL CHECK(val_ejecutado >= 0)                      DEFAULT 0,      -- DEFAULT 0: sin gastos al inicio
    fec_presupuesto     DATE            NOT NULL DEFAULT CURRENT_DATE,
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado IN (1, 2, 3))                 DEFAULT 1,      -- 1=Pendiente / 2=Aprobado / 3=Rechazado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(id_presupuesto),
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    CONSTRAINT chk_ejecutado_campana CHECK(val_ejecutado <= val_aprobado)                                       -- No puede ejecutarse más de lo aprobado
);

-- ===============================================================
-- TABLA DE PRESUPUESTO DE EVENTO
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_presupuesto_evento
(
    id_presupuesto      DECIMAL(6,0)    NOT NULL CHECK(id_presupuesto > 0 AND id_presupuesto <= 999999),
    id_evento           DECIMAL(6,0)    NOT NULL CHECK(id_evento > 0 AND id_evento <= 999999),
    val_aprobado        DECIMAL(12,0)   NOT NULL CHECK(val_aprobado >= 0),
    val_ejecutado       DECIMAL(12,0)   NOT NULL CHECK(val_ejecutado >= 0)                      DEFAULT 0,      -- DEFAULT 0: sin gastos al inicio
    fec_presupuesto     DATE            NOT NULL DEFAULT CURRENT_DATE,
    ind_estado          DECIMAL(1,0)    NOT NULL CHECK(ind_estado IN (1, 2, 3))                 DEFAULT 1,      -- 1=Pendiente / 2=Aprobado / 3=Rechazado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(id_presupuesto),
    FOREIGN KEY(id_evento) REFERENCES tab_evento(id_evento),
    CONSTRAINT chk_ejecutado_evento CHECK(val_ejecutado <= val_aprobado)                                        -- No puede ejecutarse más de lo aprobado
);

-- ===============================================================
-- TABLA DE KPIs DE CAMPAÑA
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_kpis_marcom
(
    id_kpi              DECIMAL(2,0)    NOT NULL CHECK(id_kpi > 0 AND id_kpi <= 99),
    nom_kpi             VARCHAR(60)     NOT NULL CHECK(LENGTH(nom_kpi) >= 3),
    des_kpi             TEXT            NOT NULL,
    ind_estado          BOOLEAN         NOT NULL, -- TRUE = activo / FALSE = inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, -- TRUE = KPI eliminado (solo para referencia histórica, no aparece en opciones activas)
    
    PRIMARY KEY(id_kpi)
);

INSERT INTO tab_kpis_marcom (id_kpi, nom_kpi, des_kpi, ind_estado, ind_borrado) VALUES
(1,  'Leads generados',        'Número total de leads nuevos captados en el período de la campaña.',                          TRUE, FALSE),
(2,  'Tasa de conversión',     'Porcentaje de leads que avanzaron a la etapa de cliente.',                                    TRUE, FALSE),
(3,  'Costo por lead',         'Presupuesto ejecutado dividido entre el número de leads generados.',                          TRUE, FALSE),
(4,  'Tasa de apertura email', 'Porcentaje de emails enviados que fueron abiertos por el destinatario.',                      TRUE, FALSE),
(5,  'Tasa de clic email',     'Porcentaje de emails abiertos en los que el destinatario hizo clic en algún enlace.',         TRUE, FALSE),
(6,  'Leads calificados',      'Número de leads que cumplieron los criterios mínimos de calificación comercial.',             TRUE, FALSE),
(7,  'Asistencia a eventos',   'Porcentaje de leads invitados a un evento que confirmaron asistencia y asistieron.',          TRUE, FALSE),
(8,  'ROI de campaña',         'Retorno sobre la inversión: ingresos generados menos costo de campaña sobre costo.',          TRUE, FALSE),
(9,  'Score promedio leads',   'Promedio del val_score de todos los leads activos asociados a la campaña.',                   TRUE, FALSE),
(10, 'Tiempo medio conversión','Número de días promedio entre el registro del lead y su conversión a cliente.',               TRUE, FALSE);

-- ============================================================
-- TABLA DE MEDICIÓN DE KPIs
-- ============================================================

CREATE TABLE IF NOT EXISTS tab_medicion_kpi
(
    id_campana                  BIGINT    NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),        --VALIDA LA MEDICION DE UN KPI POR PERIODO, EN ESTE CASO MENSUAL
    id_kpi                      DECIMAL(2,0)    NOT NULL CHECK(id_kpi > 0 AND id_kpi <= 99),
    fec_periodo                 DATE            NOT NULL,                                                    -- Corregido: num_anio + num_mes → DATE truncado al primer día del mes
    val_medicion                DECIMAL(12,2)   NOT NULL,                                                   -- Corregido: CHECK >= 0 eliminado, permite ROI negativo. Validación en PHP
    fec_ultima_actualizacion    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,                         -- Añadido: saber cuándo fue la última actualización
    
    PRIMARY KEY(id_campana, id_kpi, fec_periodo),                                                           -- Corregido: num_anio + num_mes → fec_periodo
    FOREIGN KEY(id_campana) REFERENCES tab_campanas(id_campana),
    FOREIGN KEY(id_kpi)     REFERENCES tab_kpis_marcom(id_kpi),
    CONSTRAINT chk_periodo_primer_dia CHECK(EXTRACT(DAY FROM fec_periodo) = 1)                               -- Garantiza que fec_periodo siempre sea el primer día del mes
    
);

-- ===============================================================
-- TABLA DE PLANTILLAS DE CORREO
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_plantillas_correo
(
    id_plantilla        SMALLINT    GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999),
    id_canal            DECIMAL(2,0)    NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),
    nom_plantilla       VARCHAR(120)    NOT NULL CHECK(LENGTH(nom_plantilla) >= 3),
    des_contenido       TEXT            NOT NULL,
    ind_generada_ia     BOOLEAN         NOT NULL DEFAULT FALSE, -- TRUE si la generó la IA
    ind_estado          BOOLEAN         NOT NULL, -- TRUE = activa / FALSE = inactiva
    
    PRIMARY KEY(id_plantilla),
    FOREIGN KEY(id_canal) REFERENCES tab_canales(id_canal)
);

-- ===============================================================
-- TABLA DE CONTACTOS ADICIONALES
-- ===============================================================

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
    FOREIGN KEY(id_tercero) REFERENCES tab_terceros(id_tercero)
    -- PHP valida que id_tercero sea jurídico (ind_tipo_tercero = TRUE)
    -- antes de insertar — no es posible validarlo en BD sin trigger
);

-- ===============================================================
-- TABLA DE ENVÍOS INDIVIDUALES
-- ===============================================================

CREATE TABLE IF NOT EXISTS tab_envios
(
    id_envio        DECIMAL(10,0)   NOT NULL CHECK(id_envio > 0 AND id_envio <= 9999999999),
    id_campana      BIGINT    		 NOT NULL CHECK(id_campana > 0 AND id_campana <= 999999),
    id_plantilla    SMALLINT 	     NOT NULL CHECK(id_plantilla > 0 AND id_plantilla <= 9999),
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
    FOREIGN KEY(id_tercero)   REFERENCES tab_terceros(id_tercero),
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
    PRIMARY KEY(id_empresa)
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
    cod_dian            DECIMAL(1,0)    NOT NULL UNIQUE CHECK(cod_dian >= 1 AND cod_dian <= 6),        -- NC: códigos 1-6 | ND: códigos 1-3 (Res. 000042)
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
    UNIQUE(prefijo_nota, num_nota)
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
-- PASO 5 – TRANSMISIÓN ELECTRÓNICA DIAN (CUDE, XML, QR)
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
-- PASO 6 – APLICACIÓN DE NOTAS A FACTURAS O CARTERA
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
----------------------------------------------
-- MÓDULO DE TESORERIA
-------------------------------------------
-----------------------
-- TABLA DE FESTIVOS --
-----------------------
-- TABLA 1: Días festivos
CREATE TABLE tab_festivos
(
    id_festivo         DECIMAL(4,0)         NOT NULL CHECK((id_festivo >= 1 AND id_festivo <= 9999)),                            -- Identificador del día festivo
    fecha              DATE                 NOT NULL DEFAULT CURRENT_DATE,                                                       -- Fecha de el día festivo
    nom_festivo        VARCHAR(40)          NOT NULL CHECK((LENGTH(nom_festivo) >= 3) AND (LENGTH(nom_festivo) <= 40)),          -- Nombre descriptivo
    ind_borrado        BOOLEAN              NOT NULL DEFAULT FALSE,                                                              -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo
     
    PRIMARY KEY (id_festivo)
);

-------------------------
-- TABLA DE CAJA MENOR --
-------------------------
-- TABLA 2: Cajas Menores (fondos fijos asignados)
CREATE TABLE tab_enc_caja_menor
(
    id_caja_menor 		DECIMAL(10,0)		NOT NULL CHECK (id_caja_menor >= 0 AND id_caja_menor <= 9999999999),				 -- ID de caja (hasta 9,999,999,999)
    nom_caja_menor 		VARCHAR(30) 		NOT NULL CHECK (LENGTH(nom_caja_menor) >= 3 AND LENGTH(nom_caja_menor) <= 30),		 -- Nombre descriptivo
    monto_asignado 		DECIMAL(8,0) 		NOT NULL CHECK (monto_asignado >= 0 AND monto_asignado <= 99999999),				 -- Fondo fijo asignado
    monto_disponible 	DECIMAL(8,0) 		NOT NULL CHECK (monto_disponible >= 0 AND monto_disponible <= 99999999),			 -- Saldo disponible
    fecha_apertura 		DATE 				NOT NULL DEFAULT CURRENT_DATE,														 -- Fecha de creación
    fecha_cierre 		DATE,																									 -- Fecha de cierre (NULL si está activa)
    ind_estado_caja_m 	BOOLEAN 			NOT NULL DEFAULT TRUE,																 -- TRUE = Activa / FALSE = Cerrada
	
    PRIMARY KEY         (id_caja_menor),
	
    CONSTRAINT chk_caja_fechas              CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura),
    CONSTRAINT chk_caja_disponible          CHECK (monto_disponible <= monto_asignado)
);

----------------------------------------
-- TABLA DE MOVIMIENTOS DE CAJA MENOR --
----------------------------------------
-- TABLA 3: Movimientos de Caja Menor (ingresos y egresos)
CREATE TABLE tab_det_caja_menor
(
    id_caja_menor 		DECIMAL(10,0) 		NOT NULL CHECK (id_caja_menor >= 0 AND id_caja_menor <= 9999999999),                 -- ID de caja (hasta 9,999,999,999)
    id_movimiento 		DECIMAL(10,0) 		NOT NULL CHECK (id_movimiento > 0 AND id_movimiento <= 9999999999),                  -- ID del movimiento hecho en la caja
    concepto 			VARCHAR(200) 		NOT NULL CHECK (LENGTH(concepto) > 0 AND LENGTH(concepto) <= 200),                   -- Descripción del movimiento
    val_movimiento 		DECIMAL(8,0) 		NOT NULL CHECK (val_movimiento > 0 AND val_movimiento <= 99999999),                  -- Valor del movimiento
    fecha_movimiento 	DATE 				NOT NULL DEFAULT CURRENT_DATE,                                                       -- Fecha del movimiento
    ind_estado 			DECIMAL(1,0) 		NOT NULL DEFAULT 1 CHECK((ind_estado >= 1) AND (ind_estado <= 3)),                   -- 1 = Pendiente, 2 = Aprobado, 3 = Reembolsado

    PRIMARY KEY         (id_caja_menor, id_movimiento),
    FOREIGN KEY         (id_caja_menor)     REFERENCES tab_enc_caja_menor(id_caja_menor)
);
-- Consultas tipo: "fecha es la que se realizó un movimiento en la caja menor"
CREATE INDEX IF NOT EXISTS idx_mov_caja_fecha ON tab_det_caja_menor(fecha_movimiento);

-- Consultas tipo: "movimientos que se hayan realizado en una caja menor en específico"
CREATE INDEX IF NOT EXISTS idx_mov_caja_caja ON tab_det_caja_menor(id_caja_menor);

--------------------------------------------
-- TABLA DE PARÁMETROS DE TESORERÍA Y CXP --
--------------------------------------------
-- TABLA 4: Parámetros de Tesorería
CREATE TABLE tab_pmtros_tescxp
(
    id_empresa          VARCHAR             NOT NULL CHECK(LENGTH(id_empresa) >= 6 AND (LENGTH(id_empresa)) <= 10),              -- Identificador (NIT) de la empresa
    fec_diapago1        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago1) >= 1 AND (fec_diapago1) <= 6),                         -- Día #1 en el que la empresa decide pagar
    fec_diapago2        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago2) >= 1 AND (fec_diapago2) <= 6),                         -- Día #2 en el que la empresa decide pagar
    fec_diapago3        DECIMAL(1,0)        NOT NULL CHECK((fec_diapago3) >= 1 AND (fec_diapago3) <= 6),                         -- Día #3 en el que la empresa decide pagar
    val_min_reembolso   DECIMAL(8,0)        NOT NULL CHECK((val_min_reembolso >= 0) AND (val_min_reembolso <= 99999999)),        -- Valor mínimo de reembolso para crear otra caja menor
    ind_borrado         BOOLEAN             NOT NULL DEFAULT FALSE,                                                              -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo

    PRIMARY KEY         (id_empresa),
    FOREIGN KEY         (id_empresa)        REFERENCES tab_pmtros_grales(id_empresa)                                                                                                   
);

------------------------------------
-- TABLA DE CUENTAS DE LA EMPRESA --
------------------------------------
-- TABLA 5: Cuentas de la empresa
CREATE TABLE tab_ctas_empresa
(
    id_empresa          VARCHAR             NOT NULL CHECK(LENGTH(id_empresa) >= 6 AND (LENGTH(id_empresa)) <= 10),              -- Identificador (NIT) de la empresa
    cta_empresa         VARCHAR             NOT NULL CHECK(LENGTH(cta_empresa) >= 10 AND LENGTH(cta_empresa) <= 16),             -- Número de cuenta bancaria de la empresa
    id_banco            VARCHAR             NOT NULL CHECK(LENGTH(id_banco) >= 6 AND (LENGTH(id_banco) <= 10)),                  -- Identificador (NIT) del banco
    ind_tipocuenta      BOOLEAN             NOT NULL DEFAULT FALSE,                                                              -- TRUE = Corriente / FALSE = Ahorros
    ind_borrado         BOOLEAN             NOT NULL DEFAULT FALSE,                                                              -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo

    PRIMARY KEY         (id_empresa,cta_empresa),         
    FOREIGN KEY         (id_empresa)        REFERENCES tab_pmtros_tescxp(id_empresa),         
    FOREIGN KEY         (id_banco)          REFERENCES tab_bancos(id_banco)                                                                             
);

--------------------------------------------------
--        TABLA DE BANCOS POR PROVEEDORES       --
--------------------------------------------------
-- TABLA 6: Tabla de bancos por proveedores
CREATE TABLE IF NOT EXISTS tab_bancoxprov
(
    id_proveedor	    VARCHAR             NOT NULL CHECK(LENGTH(id_proveedor) >= 6  AND LENGTH(id_proveedor) <= 10), 	         -- Identificador (NIT) del proveedor
    cta_proveedor       VARCHAR             NOT NULL CHECK(LENGTH(cta_proveedor) >= 10  AND LENGTH(cta_proveedor) <= 16),        -- Número de cuenta bancaria del proveedor
    id_banco            VARCHAR             NOT NULL CHECK(LENGTH(id_banco) >= 6  AND LENGTH(id_banco) <= 10),                   -- Identificador (NIT) del banco  
    ind_tipocuenta      BOOLEAN             NOT NULL DEFAULT FALSE,                                                              -- TRUE = Corriente / FALSE = Ahorros
    ind_borrado         BOOLEAN             NOT NULL DEFAULT FALSE,                                                              -- TRUE: Borrado lógico (Inactivo) / FALSE: Activo

    PRIMARY KEY         (id_proveedor,cta_proveedor),                                                                                 
    FOREIGN KEY         (id_proveedor)      REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY         (id_banco)          REFERENCES tab_bancos(id_banco)
);

--------------------------------
-- TABLA DE CUENTAS POR PAGAR --
--------------------------------
-- TABLA 7: Tabla de Cuentas por pagar
CREATE TABLE tab_cuentasxpagar
(
    id_factura          DECIMAL(8,0)        NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                     -- Identificador de la factura
    id_proveedor        VARCHAR   			NOT NULL CHECK(LENGTH(id_proveedor) >= 6 AND (LENGTH(id_proveedor) <= 10)),         -- Identificador (NIT) del proveedor
    fec_emision         DATE                NOT NULL DEFAULT CURRENT_DATE,                                                      -- Fecha de emisión de la factura
    fec_vencimiento     DATE                NOT NULL,                                                                           -- FECHA DE PAGO FACTURA (FECHA EMISIÓN + DIAS DE PAGO)
    val_factura         DECIMAL(10,0)       NOT NULL CHECK((val_factura) >= 0 AND (val_factura) <= 9999999999),                 -- Monto total de la factura
    val_saldo           DECIMAL(10,0)                CHECK((val_saldo >= 0) AND (val_saldo <= 9999999999)),                     -- Valor restante para terminar de pagar la factura
    num_cuotas          DECIMAL(2,0)        NOT NULL CHECK((num_cuotas) >= 1 AND (num_cuotas) <= 99),                           -- Número de cuotas totales en las que se acordó la factura
    ind_estado          BOOLEAN             NOT NULL DEFAULT FALSE,                                                             -- TRUE = Pagado O FALSE = En deuda

    PRIMARY KEY         (id_factura),                                                                                           
    FOREIGN KEY         (id_proveedor)      REFERENCES tab_proveedores(id_proveedor)    
);
-- Consultas tipo: "facturas pendientes de un proveedor"
CREATE INDEX idx_facturas_proveedor         ON tab_cuentasxpagar(id_proveedor);

-- Consultas tipo: "facturas vencidas hoy"
CREATE INDEX idx_facturas_vencimiento       ON tab_cuentasxpagar(fec_vencimiento);

-- Consultas tipo: "todas las facturas pendientes"
CREATE INDEX idx_facturas_estado            ON tab_cuentasxpagar(ind_estado);

------------------------------
-- TABLA DE CUOTAS FACTURAS --
------------------------------
-- TABLA 8: Tabla de cuotas por facturas
CREATE TABLE tab_cuotasxfactura
(
    id_factura          DECIMAL(8,0)        NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                     -- Identificador de la factura
    id_cuota            DECIMAL(2,0)        NOT NULL CHECK((id_cuota) >= 1 AND (id_cuota) <= 99),                               -- Número de cuota de la factura
    fec_vencimiento     DATE 				NOT NULL,                                                                           -- Fecha en la que vence cada cuota
    val_cuota           DECIMAL(10,0)       NOT NULL CHECK((val_cuota) >= 0 AND (val_cuota) <= 9999999999),                     -- Monto total de la factura
    ind_pagada          BOOLEAN             NOT NULL DEFAULT FALSE,                                                             -- TRUE = Pagado / FALSE = Pendiente

    PRIMARY KEY(id_factura,id_cuota),
    FOREIGN KEY(id_factura)                 REFERENCES tab_cuentasxpagar(id_factura)  
);
-- Consultas tipo: "cuotas pendientes de esta factura"
CREATE INDEX idx_cuotas_pagada ON tab_cuotasxfactura(ind_pagada);

-- Consultas tipo: "cuotas que vencen esta semana"
CREATE INDEX idx_cuotas_vencimiento ON tab_cuotasxfactura(fec_vencimiento);

------------------------------------------------
-- TABLA DE ENCABEZADO DE CRONOGRAMA DE PAGOS --
------------------------------------------------
-- TABLA 9: Tabla de encabezado cronograma de pagos
CREATE TABLE tab_enc_cronopagos
(
    id_cronograma       DECIMAL(10,0) 		NOT NULL CHECK((id_cronograma) >= 0 AND (id_cronograma) <= 9999999999),             -- Identificador del cronograma
    fec_programacion    DATE                NOT NULL,                                                                           -- Fecha para la cual se planificó pagar dicho cronograma
    total_a_pagar       DECIMAL(10,0)       NOT NULL CHECK((total_a_pagar) >= 0 AND (total_a_pagar) <= 9999999999),             -- Monto total a pagar por ese cronograma
    ind_estado          BOOLEAN             NOT NULL DEFAULT FALSE,                                                             -- TRUE = Pagado / FALSE = Pendiente

    PRIMARY KEY(id_cronograma)
);
-- Consultas tipo: "fecha en las que se va a realizar un cronograma"
CREATE INDEX idx_crono_fec_prog ON tab_enc_cronopagos(fec_programacion);

-- Consultas tipo: "cronogramas pendientes o pagados"
CREATE INDEX idx_crono_estado   ON tab_enc_cronopagos(ind_estado);

---------------------------------------------
-- TABLA DE DETALLE DE CRONOGRAMA DE PAGOS --
---------------------------------------------
-- TABLA 10: Tabla de detalle de cronograma de pagos
CREATE TABLE tab_det_cronopagos
(
    id_cronograma       DECIMAL(10,0) 		NOT NULL CHECK((id_cronograma) >= 0 AND (id_cronograma) <= 9999999999),             -- Identificador del cronograma
    id_factura          DECIMAL(8,0)        NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                     -- Identificador de la factura
    id_cuota            DECIMAL(2,0)        NOT NULL CHECK((id_cuota) >= 1 AND (id_cuota) <= 99),                               -- Número de cuota que se va a pagar en el cronograma
    val_a_pagar         DECIMAL(10,0)       NOT NULL CHECK((val_a_pagar) >= 0 AND (val_a_pagar) <= 9999999999),                 -- Monto a pagar por cada cuota factura

    PRIMARY KEY(id_cronograma,id_factura,id_cuota),

    FOREIGN KEY(id_cronograma)              REFERENCES tab_enc_cronopagos(id_cronograma),
    FOREIGN KEY(id_factura,id_cuota)        REFERENCES tab_cuotasxfactura(id_factura,id_cuota)
);

------------------------------------------
-- TABLA DE ENCABEZADO DE ARCHIVO PLANO --
------------------------------------------
-- TABLA 11: Tabla de encabezado de archivo plano
CREATE TABLE tab_enc_archivo_plano
(
    id_archivo_plano    DECIMAL(10,0) 		NOT NULL CHECK((id_archivo_plano) >= 0 AND (id_archivo_plano) <= 9999999999),       -- Identificador del archivo plano
    id_cronograma       DECIMAL(10,0) 		NOT NULL CHECK((id_cronograma) >= 0 AND (id_cronograma) <= 9999999999),             -- Identificador del cronograma
    id_banco            VARCHAR             NOT NULL CHECK(LENGTH(id_banco) >= 6 AND (LENGTH(id_banco) <= 10)),                 -- NIT del banco al cuál se va a generar el archivo plano, esto sirve para generar en distinto formato dependiendo el banco
    nom_archivo         VARCHAR(30)         NOT NULL CHECK(LENGTH(nom_archivo) >= 3 AND (LENGTH(nom_archivo) <= 30)),           -- Nombre del archivo plano
    fec_generacion      DATE,                                                                                                   -- Fecha de generación del archivo(NULL Si no se ha creado)
    ind_generado        BOOLEAN             NOT NULL DEFAULT FALSE,                                                             -- Indicador de generado del archivo

    PRIMARY KEY(id_archivo_plano),
    FOREIGN KEY(id_banco)                   REFERENCES tab_bancos(id_banco),
    FOREIGN KEY(id_cronograma)              REFERENCES tab_enc_cronopagos(id_cronograma)
);
-- Consultas tipo: "archivos planos que se hayan generado o no"
CREATE INDEX idx_archplano_generado ON tab_enc_archivo_plano(ind_generado);

------------------------------------
-- TABLA DE DETALLE ARCHIVO PLANO --
------------------------------------
-- TABLA 12: Tabla de detalle de archivo plano
CREATE TABLE tab_det_archivo_plano
(
    id_archivo_plano    DECIMAL(10,0) 		NOT NULL CHECK((id_archivo_plano) >= 0 AND (id_archivo_plano) <= 9999999999),       -- Identificador del archivo plano
    id_empresa          VARCHAR             NOT NULL CHECK(LENGTH(id_empresa) >= 6 AND (LENGTH(id_empresa)) <= 10),             -- Identificador (NIT) de la empresa
    cta_empresa         VARCHAR             NOT NULL CHECK(LENGTH(cta_empresa) >= 10 AND LENGTH(cta_empresa) <= 16),            -- Número de cuenta bancaria de la empresa de la cuál va a salir el dinero
    id_proveedor        VARCHAR   			NOT NULL CHECK(LENGTH(id_proveedor) >= 6 AND (LENGTH(id_proveedor) <= 10)),         -- Identificador (NIT) del proveedor al que se le va a pagar
    cta_proveedor       VARCHAR             NOT NULL CHECK(LENGTH(cta_proveedor) >= 10  AND LENGTH(cta_proveedor) <= 16),       -- Número de cuenta de destino para pagar, no se referencia de tab_bancoxprov para tener una trazabilidad y la cuenta no cambie en el archivo plano cuando el proveedor cambie su cuenta
    ind_tipocuenta      BOOLEAN             NOT NULL DEFAULT FALSE,                                                             -- TRUE = Corriente / FALSE = Ahorros
    id_factura          DECIMAL(8,0)        NOT NULL CHECK((id_factura) >= 1 AND (id_factura) <= 99999999),                     -- Identificador de la factura 
    id_cuota            DECIMAL(2,0)        NOT NULL CHECK((id_cuota) >= 1 AND (id_cuota) <= 99),                               -- Número de cuota que se va a pagar en el cronograma
    
    val_a_pagar         DECIMAL(10,0)       NOT NULL CHECK((val_a_pagar) >= 0 AND (val_a_pagar) <= 9999999999),                 -- Monto a pagar por cada cuota factura

    PRIMARY KEY(id_archivo_plano,id_factura,id_cuota),

    FOREIGN KEY(id_archivo_plano)           REFERENCES tab_enc_archivo_plano(id_archivo_plano),
    FOREIGN KEY(id_factura,id_cuota)        REFERENCES tab_cuotasxfactura(id_factura,id_cuota),
    FOREIGN KEY(id_proveedor,cta_proveedor) REFERENCES tab_bancoxprov(id_proveedor,cta_proveedor),
    FOREIGN KEY(id_empresa,cta_empresa)     REFERENCES tab_ctas_empresa(id_empresa,cta_empresa)
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
CREATE INDEX IF NOT EXISTS idx_pmtros_categoria ON tab_pmtros(categoria);
CREATE INDEX IF NOT EXISTS idx_pmtros_estado    ON tab_pmtros(ind_estado);
-- --------------------------------------------------------
-- script_gr_docume_V7.2
-- Script DDL para la creacion de la estructura del modulo
-- de gestion documental y calidad.
-- Autores: Celso Andres Martinez & Jonathan David Marquez
-- Version: 7.0 --- Ultima actualizacion: 04-06-2026
-- --------------------------------------------------------
-- TOTAL DE TABLAS: 36 (Maestras: 8, Transaccionales: 26)
-- TOTAL DE SECUENCIAS: 8
-- TOTAL DE iNDICES: 48
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_tipo_documento
-- Clasifica los documentos segun su naturaleza juridica o administrativa.
-- Permite aplicar politicas de retencion documental especificas por tipo de documento
-- y define los plazos de respuesta estandar segun la normativa legal (Ley 594 de 2000).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_documento
(
    id_tipo              DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 100),                        -- Identificador numerico unico (1 a 100). Clave primaria.
    nom_tipo             VARCHAR(20)                NOT NULL CHECK (char_length(trim(nom_tipo)) BETWEEN 3 AND 20),     -- Nombre: FACTURA, CONTRATO, CERTIFICADO, ACTA, OFICIO.
    cod_tipo             VARCHAR(10)                NOT NULL CHECK (cod_tipo ~ '^[A-Z0-9]{2,10}$'),                    -- Codigo alfanumerico corto (solo mayusculas y numeros). Ej: FAC01, CON02.
    dias_respuesta       DECIMAL(2,0)               NOT NULL CHECK (dias_respuesta BETWEEN 1 AND 99) DEFAULT 15,       -- Dias estandar de respuesta (1-99). Por defecto 15.
    id_festivo           DECIMAL(4,0)               NOT NULL CHECK (id_festivo >= 0 AND id_festivo <= 99) DEFAULT 0,   -- FK al calendario de festivos. Define si se cuentan dias naturales o habiles.
    ind_publico          BOOlEAN                    NOT NULL DEFAULT TRUE,                                             -- Indicador para saber si el archivo es visible para todos o no.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                            -- Borrado logico: TRUE = eliminado, FALSE = activo.
    PRIMARY KEY (id_tipo),
    FOREIGN KEY (id_festivo) REFERENCES tab_festivos(id_festivo)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_tabla_retencion
-- Define las politicas de conservacion, archivo y disposicion final de los documentos
-- segun la Ley General de Archivos (Ley 594 de 2000).
-- Establece cuantos años debe permanecer un documento en el archivo de gestion (oficina),
-- cuantos en el archivo central (bodega) y que hacer al final del ciclo
-- (conservar para siempre, eliminar o seleccionar).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tabla_retencion
(
    id_retencion          DECIMAL(5,0)              NOT NULL CHECK (id_retencion BETWEEN 1 AND 9999),                                              -- Identificador unico de la politica (1 a 9,999). Clave primaria.
    id_tipo               DECIMAL(3,0)              NOT NULL CHECK (id_tipo BETWEEN 1 AND 100),                                                    -- FK al tipo de documento asociado.
    nom_serie             VARCHAR                   NOT NULL CHECK (char_length(trim(nom_serie)) BETWEEN 3 AND 150),                               -- Serie documental. Ej: "Gestion de Personal".
    nom_subserie          VARCHAR                   NOT NULL CHECK (char_length(trim(nom_subserie)) BETWEEN 1 AND 150) DEFAULT 'SIN_SUBSERIE',     -- Subserie. Ej: "Hojas de Vida".
    anos_archivo_gestion  DECIMAL(3,0)              NOT NULL CHECK (anos_archivo_gestion BETWEEN 1 AND 10) DEFAULT 2,                              -- Años en archivo de gestion (1-10). Por defecto 2.
    anos_archivo_central  DECIMAL(3,0)              NOT NULL CHECK (anos_archivo_central BETWEEN 1 AND 30) DEFAULT 8,                              -- Años en archivo central (1-30). Por defecto 8.
    disposicion_final     VARCHAR(20)               NOT NULL CHECK (disposicion_final IN ('CONSERVACION_TOTAL','ELIMINACION','SELECCION')),        -- Accion final: conservar, eliminar o seleccionar.
    soporte_fisico        BOOLEAN                   NOT NULL DEFAULT FALSE,                                                                        -- ¿Se conserva en formato fisico Por defecto FALSE.
    soporte_electronico   BOOLEAN                   NOT NULL DEFAULT TRUE,                                                                         -- ¿Se conserva en formato digital Por defecto TRUE.
    ind_borrado           BOOLEAN                   NOT NULL DEFAULT FALSE,                                                                        -- Borrado logico.
    PRIMARY KEY (id_retencion),
    CONSTRAINT chk_soporte_valido CHECK ((soporte_fisico = TRUE AND soporte_electronico = FALSE) OR (soporte_fisico = FALSE AND soporte_electronico = TRUE)),
    FOREIGN KEY (id_tipo) REFERENCES tab_tipo_documento(id_tipo)
);
-- Indices para optimizar consultas por tipo de documento.
CREATE INDEX idx_trd_tipo ON tab_tabla_retencion(id_tipo);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_estado_correspondencia
-- Define las etapas del ciclo de vida por las que pasa una comunicacion.
-- Permite el seguimiento y control de las comunicaciones, sabiendo en todo momento
-- si estan radicadas, asignadas, en proceso, respondidas, cerradas, anuladas o vencidas.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_correspondencia
(
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 20),                           -- Identificador unico (1 a 20). Clave primaria.
    val_estado           VARCHAR(15)                NOT NULL CHECK (char_length(trim(val_estado)) BETWEEN 3 AND 15),       -- Estado: RADICADO, ASIGNADO, EN_PROCESO, RESPONDIDO, CERRADO, ANULADO, VENCIDO.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                -- Borrado logico.
    PRIMARY KEY (id_estado)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_accion_workflow
-- 
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_accion_workflow
(
    id_accion            DECIMAL(2,0)               NOT NULL CHECK (id_accion BETWEEN 1 AND 99),                         -- Identificador unico de la accion (1 a 99). Clave primaria.
    nom_accion           VARCHAR(15)                NOT NULL CHECK (char_length(trim(nom_accion)) BETWEEN 3 AND 15),    
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                 
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                              -- Borrado logico.
    PRIMARY KEY (id_accion),
    FOREIGN KEY (id_area) REFERENCES tab_areas(id_area)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_correspondencia
-- Es la tabla principal que registra cada comunicacion recibida por la organizacion.
-- Almacena la informacion basica de cada correspondencia: numero de radicado (unico),
-- remitente, asunto, fechas, estado, tipo de documento, origen, nivel de acceso,
-- politica de retencion, area destino y tercero asociado.
-- Sigue el Acuerdo 001 de 2024 del AGN para el formato del numero de radicado (14 digitos).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_correspondencia
(
    id_correspondencia      VARCHAR(14)                NOT NULL CHECK (id_correspondencia ~ '^[0-9]{14}$'),                                           -- Identificador unico interno. 14 digitos numericos. Clave primaria.
    num_radicado            VARCHAR(14)                NOT NULL CHECK (num_radicado ~ '^[0-9]{14}$'),                                                 -- Numero de radicado oficial. 14 digitos. unico.
    id_tipo                 DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 100),                                                    -- FK al tipo de documento. Define la naturaleza del documento.
    id_canal                DECIMAL(2,0)               NOT NULL CHECK(id_canal > 0 AND id_canal <= 99),                                               -- Identificador unico de canal
    id_estado               DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 20),                                                   -- FK al estado actual. Define la etapa del ciclo de vida.
    ind_publico          	BOOlEAN                    NOT NULL DEFAULT TRUE,                                             							  -- Indicador para saber si el archivo es visible para todos o no.
    id_retencion            DECIMAL(5,0)               NOT NULL CHECK (id_retencion BETWEEN 1 AND 9999),                                              -- FK a politica de retencion. Define su ciclo de vida.
    nom_remitente           VARCHAR                    NOT NULL CHECK (char_length(trim(nom_remitente)) BETWEEN 3 AND 255),                           -- Nombre del remitente.
    ent_remitente           VARCHAR                    NOT NULL CHECK (char_length(trim(ent_remitente)) BETWEEN 1 AND 255) DEFAULT 'NO_APLICA',       -- Entidad del remitente.
    asunto                  TEXT                       NOT NULL CHECK (char_length(trim(asunto)) BETWEEN 5 AND 500) DEFAULT 'SIN_ASUNTO',             -- Asunto o descripcion breve.
    fec_documento           DATE                       NOT NULL CHECK (fec_documento <= CURRENT_DATE),                                                -- Fecha del documento original. No puede ser futura.
    fec_recepcion           TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                        -- Fecha y hora de recepcion. Por defecto now().
    id_festivo              DECIMAL(4,0)               NOT NULL CHECK (id_festivo >= 0 AND id_festivo <= 99) DEFAULT 0,                               -- FK al calendario de festivos. Define si se cuentan dias naturales o habiles.
    ind_fisico              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                        -- Existe version fisica Por defecto FALSE.
    id_area_destino         DECIMAL(5,0)               NOT NULL CHECK (id_area_destino > 0),                                                                  -- FK al area destino. Define a quien se dirige.
    id_tercero              VARCHAR(10)                NOT NULL,
    ind_borrado             BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                        -- Borrado logico.
    PRIMARY KEY (id_correspondencia),
    CONSTRAINT uq_enc_corr_radicado UNIQUE (num_radicado),
    FOREIGN KEY (id_tipo)          REFERENCES tab_tipo_documento(id_tipo),
    FOREIGN KEY (id_canal)         REFERENCES tab_canales(id_canal),
    FOREIGN KEY (id_estado)        REFERENCES tab_estado_correspondencia(id_estado),
    FOREIGN KEY (id_retencion)     REFERENCES tab_tabla_retencion(id_retencion),
    FOREIGN KEY (id_festivo)       REFERENCES tab_festivos(id_festivo),
    FOREIGN KEY (id_area_destino)  REFERENCES tab_areas(id_area),
    FOREIGN KEY (id_tercero)       REFERENCES tab_terceros(id_tercero)
);
-- Indices para optimizar consultas por estado, area, fecha de recepcion y numero de radicado.
CREATE INDEX idx_enc_corr_estado           ON tab_correspondencia(id_estado);
CREATE INDEX idx_enc_corr_area             ON tab_correspondencia(id_area_destino);
CREATE INDEX idx_enc_corr_recepcion        ON tab_correspondencia(fec_recepcion);
CREATE INDEX idx_enc_corr_radicado         ON tab_correspondencia(num_radicado);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_indexacion
-- Proposito: Genera identificadores unicos para cada registro de indexacion.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_indexacion START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_indexacion
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_indexacion
(
    id_indexacion        DECIMAL(10,0)              NOT NULL DEFAULT nextval('seq_indexacion'),                   -- Identificador unico. Secuencia seq_indexacion. Clave primaria.
    id_correspondencia   VARCHAR(14)                NOT NULL CHECK (id_correspondencia ~ '^[0-9]{14}$'),          -- FK a la correspondencia padre.
    palabras_clave       VARCHAR                    NOT NULL DEFAULT 'SIN_PALABRAS_CLAVES',                       -- Palabras clave para busqueda. Ej: "contrato,2024".
    id_tipo              DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 100),                             -- FK al tipo de documento principal.
    fec_indexacion       TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                       -- Fecha y hora de indexacion. Por defecto now().
    id_indexador		 VARCHAR(10)     			NOT NULL,
	ind_publico			 BOOLEAN 					NOT NULL DEFAULT TRUE,
	ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                       -- Borrado logico.
    PRIMARY KEY (id_indexacion),
    FOREIGN KEY (id_correspondencia) REFERENCES tab_correspondencia(id_correspondencia),
    FOREIGN KEY (id_tipo)            REFERENCES tab_tipo_documento(id_tipo),
    FOREIGN KEY (id_indexador)       REFERENCES tab_terceros(id_tercero)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_expediente
-- Agrupa y organiza la correspondencia y los documentos relacionados en expedientes digitales.
-- Permite crear carpetas virtuales que reunen todas las comunicaciones relacionadas
-- con un mismo proceso, caso, cliente o proyecto. Sigue el Acuerdo 001 de 2024 del AGN.
-- Utiliza dos identificadores: id_expediente (interno) y cod_expediente (legible para usuarios).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_expediente
(
	id_expediente        VARCHAR(16)                NOT NULL CHECK (char_length(trim(id_expediente)) BETWEEN 1 AND 17),          		 		-- FK al expediente (si aplica).
    nom_expediente       VARCHAR                    NOT NULL CHECK (char_length(trim(nom_expediente)) > 0),                 -- Nombre descriptivo del expediente.
    cod_expediente       VARCHAR(30)                NOT NULL CHECK (cod_expediente ~ '^[A-Z0-9-]{3,30}$'),                  -- Codigo legible para usuarios. Ej: "EXP-CON-2024-001". unico.
    id_tipo              DECIMAL(3,0)               NOT NULL CHECK (id_tipo BETWEEN 1 AND 100),                             -- FK al tipo de documento principal.
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                           -- FK al area responsable.
	ind_publico          BOOlEAN                    NOT NULL DEFAULT TRUE,                                                  -- Indicador para saber si el archivo es visible para todos o no.
	id_retencion         DECIMAL(5,0)               NOT NULL CHECK (id_retencion BETWEEN 1 AND 9999),                       -- FK a politica de retencion.
    fec_apertura         DATE                       NOT NULL CHECK (fec_apertura <= CURRENT_DATE),                          -- Fecha de apertura. No puede ser futura.
    fec_cierre           DATE                       NOT NULL CHECK (fec_cierre >= fec_apertura),                            -- Fecha de cierre. Debe ser >= fec_apertura.
    fec_disposicion      DATE                       NOT NULL CHECK (fec_disposicion >= fec_apertura),                       -- Fecha de disposicion final.
    ind_activo           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                  -- ¿Expediente activo TRUE = puede recibir documentos.
    resumen              TEXT                       NOT NULL DEFAULT 'SIN_RESUMEN' CHECK (char_length(trim(resumen)) >= 1), -- Resumen del contenido.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                 -- Borrado logico.
    PRIMARY KEY (id_expediente),
    CONSTRAINT uq_expediente_cod UNIQUE (cod_expediente),
    CONSTRAINT chk_fechas_expediente CHECK (fec_cierre >= fec_apertura AND fec_disposicion >= fec_apertura),
    FOREIGN KEY (id_tipo)         REFERENCES tab_tipo_documento(id_tipo),
    FOREIGN KEY (id_retencion)    REFERENCES tab_tabla_retencion(id_retencion)
);
-- Indices para optimizar consultas por area, estado y codigo.
CREATE INDEX idx_expediente_area   ON tab_expediente(id_area);
CREATE INDEX idx_expediente_activo ON tab_expediente(ind_activo);
CREATE INDEX idx_expediente_cod    ON tab_expediente(cod_expediente);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_doc_expediente
-- Establece la relacion entre los documentos de correspondencia y los expedientes digitales.
-- Actua como tabla intermedia (puente) que permite una relacion muchos a muchos:
-- una correspondencia puede estar en multiples expedientes y un expediente puede
-- contener multiples correspondencias.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_expediente
(
	id_expediente        VARCHAR(16)                NOT NULL CHECK (char_length(trim(id_expediente)) BETWEEN 1 AND 17),      -- FK al expediente (si aplica).
    id_correspondencia   VARCHAR(14)                NOT NULL CHECK (id_correspondencia ~ '^[0-9]{14}$'),  -- FK a la correspondencia. Parte de PK compuesta.
    fec_incorporacion    TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                               -- Fecha y hora de incorporacion al expediente.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                               -- Borrado logico.
    PRIMARY KEY (id_expediente, id_correspondencia),
    FOREIGN KEY (id_expediente)      REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_correspondencia) REFERENCES tab_correspondencia(id_correspondencia)
);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_notificacion
-- Proposito: Genera identificadores unicos para cada notificación.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_notificacion START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_notificaciones
-- 
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_notificaciones 
(
    id_notificacion         DECIMAL(8,0)             NOT NULL DEFAULT nextval('seq_notificacion'),
    id_correspondencia      VARCHAR(14)              NOT NULL CHECK (id_correspondencia ~ '^[0-9]{14}$'),
    id_expediente           VARCHAR(16)              NOT NULL CHECK (char_length(trim(id_expediente)) BETWEEN 1 AND 17),
    id_usuario_destino      VARCHAR(10)              NOT NULL,
    id_usuario_origen       VARCHAR(10)              NOT NULL,
    tipo_notificacion       VARCHAR(30)              NOT NULL CHECK (tipo_notificacion IN ('REGISTRO_CORRESPONDENCIA', 'ASIGNACION_DOCUMENTO', 'CAMBIO_ESTADO', 'VENCIMIENTO_PLAZO', 'RESPUESTA_RECIBIDA', 'EXPEDIENTE_CERRADO')),
    mensaje                 TEXT                     NOT NULL DEFAULT 'SIN_MENSAJE',
    leido                   BOOLEAN                  NOT NULL DEFAULT FALSE,
    fec_creacion            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_lectura             TIMESTAMP WITH TIME ZONE,
    ind_borrado             BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id_notificacion),
    FOREIGN KEY (id_correspondencia)  REFERENCES tab_correspondencia(id_correspondencia),
    FOREIGN KEY (id_expediente)  REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_usuario_destino)  REFERENCES tab_terceros(id_tercero),
	FOREIGN KEY (id_usuario_origen)  REFERENCES tab_terceros(id_tercero)
);
-- Índices para búsquedas rápidas
CREATE INDEX idx_notificaciones_usuario ON tab_notificaciones(id_usuario_destino);
CREATE INDEX idx_notificaciones_leido ON tab_notificaciones(leido);
CREATE INDEX idx_notificaciones_fec_creacion ON tab_notificaciones(fec_creacion);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_tipo_pqrs
-- Clasifica los tipos de Peticiones, Quejas, Reclamos, Sugerencias y Felicitaciones.
-- Permite categorizar la naturaleza de la solicitud del ciudadano para aplicar
-- los plazos de respuesta correspondientes segun la ley (Ley 1755 de 2015).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_tipo_pqrs
(
    id_tipo_pqrs         DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 10), -- Identificador unico (1 a 10). Clave primaria.
    nom_pqr              VARCHAR(15)                NOT NULL CHECK (char_length(trim(nom_pqr)) BETWEEN 1 AND 15),
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                          -- ¿Tipo activo Por defecto TRUE.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                         -- Borrado logico.
    PRIMARY KEY (id_tipo_pqrs)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_param_venc_pqrs
-- Define los parametros de vencimiento para cada tipo y subtipo de PQRS segun la normativa legal.
-- Establece los dias habiles base para responder, la posibilidad de prorroga y su duracion,
-- y el fundamento legal aplicable. Sigue la Ley 1755 de 2015 y el CPACA.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_param_venc_pqrs
(
    id_tipo_pqrs            DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 10),                      -- FK al tipo de PQRS. Parte de PK compuesta.
    nom_subtipo             VARCHAR(60)                NOT NULL CHECK (char_length(trim(nom_subtipo)) BETWEEN 1 AND 60),    -- Subtipo: GENERAL, DERECHO_PETICION, etc.
    dias_habiles_base       DECIMAL(3,0)               NOT NULL CHECK (dias_habiles_base BETWEEN 1 AND 60),                 -- Dias habiles base para respuesta.
    dias_habiles_prorroga   DECIMAL(3,0)               NOT NULL CHECK (dias_habiles_prorroga BETWEEN 0 AND 30) DEFAULT 0,   -- Dias de prorroga permitidos.
    ind_prorroga_permitida  BOOLEAN                    NOT NULL DEFAULT FALSE,                                              -- Se permite prorroga
    base_legal              VARCHAR                    NOT NULL CHECK (char_length(trim(base_legal)) BETWEEN 5 AND 255),    -- Fundamento legal. Ej: "Ley 1755 de 2015, Articulo 14".
    ind_borrado             BOOLEAN                    NOT NULL DEFAULT FALSE,                                              -- Borrado logico.
    PRIMARY KEY (id_tipo_pqrs, nom_subtipo),
    CONSTRAINT chk_dias_prorroga CHECK (dias_habiles_prorroga = 0 OR ind_prorroga_permitida = TRUE),
    FOREIGN KEY (id_tipo_pqrs) REFERENCES tab_tipo_pqrs(id_tipo_pqrs)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_estado_pqrs
-- Define las etapas del ciclo de vida por las que pasa una solicitud de PQRS.
-- Permite el seguimiento y control de las PQRS, sabiendo en todo momento si estan
-- recibidas, asignadas, en estudio, respondidas, cerradas, rechazadas o anuladas.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_pqrs
(
    id_estado_pqrs       DECIMAL(2,0)               NOT NULL CHECK (id_estado_pqrs BETWEEN 1 AND 15),                                                                      -- Identificador unico (1 a 15). Clave primaria.
    val_estado_pqrs      VARCHAR(60)                NOT NULL CHECK (val_estado_pqrs IN ('RECIBIDA','ASIGNADA','EN_ESTUDIO','RESPONDIDA','CERRADA','RECHAZADA','ANULADA')), -- Estado de la PQRS.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                                                 -- ¿Estado activo Por defecto TRUE.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                                                -- Borrado logico.
    PRIMARY KEY (id_estado_pqrs)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_motivo_pqrs
-- Define una jerarquia de motivos o categorias para clasificar detalladamente las PQRS.
-- Permite una estructura jerarquica padre-hijo (arbol de motivos) para clasificar
-- adecuadamente las Peticiones, Quejas, Reclamos, Sugerencias y Felicitaciones.
-- Facilita la asignacion automatica a areas responsables.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_motivo_pqrs
(
    id_motivo            VARCHAR(20)                NOT NULL CHECK (id_motivo ~ '^[A-Z0-9_]{3,20}$'),                   -- Identificador unico. Clave primaria. Ej: 'SERVICIOS'.
    nom_motivo           VARCHAR(20)                NOT NULL CHECK (char_length(trim(nom_motivo)) BETWEEN 3 AND 100),   -- Nombre descriptivo. Ej: "Problemas con facturacion".
    ind_motivo_padre     BOOLEAN                    NOT NULL DEFAULT FALSE,                                             -- Puede tener sub-motivos TRUE = puede tener hijos.
    motivo_padre         VARCHAR(15)                         CHECK (motivo_padre IS NULL OR motivo_padre ~ '^[A-Z0-9_]{3,20}$'), -- FK al motivo padre. NULL para motivos raiz.
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0 ),                                      -- FK al area responsable del motivo.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                              -- Motivo activo
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                             -- Borrado logico.
    nivel_hierarquia     INTEGER                    NOT NULL DEFAULT 1 CHECK (nivel_hierarquia BETWEEN 1 AND 10),       -- Nivel en el arbol. 1 = raiz.
    PRIMARY KEY (id_motivo),
    CONSTRAINT chk_motivo_padre_valido CHECK ((ind_motivo_padre = FALSE AND motivo_padre IS NOT NULL) OR (ind_motivo_padre = TRUE AND motivo_padre IS NULL)),
    FOREIGN KEY (motivo_padre) REFERENCES tab_motivo_pqrs(id_motivo) ON DELETE RESTRICT,
    FOREIGN KEY (id_area)      REFERENCES tab_areas(id_area)
);
-- Indices para optimizar consultas por jerarquia, area y estado.
CREATE INDEX idx_motivo_pqrs_jerarquia ON tab_motivo_pqrs(motivo_padre, ind_motivo_padre) WHERE ind_motivo_padre = TRUE;
CREATE INDEX idx_motivo_pqrs_area_estado ON tab_motivo_pqrs(id_area, ind_estado) WHERE ind_estado = TRUE;
CREATE INDEX idx_motivo_pqrs_area  ON tab_motivo_pqrs(id_area);
CREATE INDEX idx_motivo_pqrs_padre ON tab_motivo_pqrs(motivo_padre) WHERE motivo_padre IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_enc_pqrs
-- Es la tabla principal que registra la informacion basica de cada solicitud de PQRS.
-- Almacena el radicado, tipo, canal, estado, motivo, area responsable, solicitante,
-- asunto, fechas de radicacion y vencimiento, y si es anonima o requiere respuesta.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_pqrs
(
    id_radicado              VARCHAR(20)                NOT NULL CHECK (id_radicado ~ '^PQRS-[0-9]{4}-[0-9]{6}$'),                                  -- Radicado unico. Formato: PQRS-AAAA-XXXXXX. Clave primaria.
    id_tipo_pqrs             DECIMAL(2,0)               NOT NULL CHECK (id_tipo_pqrs BETWEEN 1 AND 10),                                             -- FK al tipo de PQRS.
    subtipo_vencimiento      VARCHAR(60)                NOT NULL CHECK (char_length(trim(subtipo_vencimiento)) BETWEEN 1 AND 60) DEFAULT 'GENERAL', -- Subtipo para calcular vencimiento.
    id_canal                 DECIMAL(2,0)               NOT NULL CHECK (id_canal > 0 AND id_canal <= 99),                                           -- FK al canal de entrada. (FK a tabla que debe existir)
    id_estado_pqrs           DECIMAL(2,0)               NOT NULL CHECK (id_estado_pqrs BETWEEN 1 AND 15),                                           -- FK al estado actual.
    id_motivo                VARCHAR(20)                NOT NULL CHECK (id_motivo ~ '^[A-Z0-9_]{3,20}$'),                                           -- FK al motivo.
    id_area                  DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                                               -- FK al area responsable.
    id_tercero               VARCHAR(10)                NOT NULL,
    id_usuario               VARCHAR                    NOT NULL CHECK(LENGTH(id_usuario) >= 5),                                                    -- Identificador único del usuario (ej: admin, jdoe, etc.)
    asunto                   TEXT                       NOT NULL CHECK (char_length(trim(asunto)) BETWEEN 5 AND 255),                               -- Asunto de la solicitud.
    fec_radicado             TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                                                     -- Fecha y hora de radicacion.
    fec_vencimiento          DATE                       NOT NULL CHECK (fec_vencimiento >= CURRENT_DATE),                                           -- Fecha limite de respuesta.
    ind_anonimo              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                     -- ¿Solicitud anonima Si es TRUE, no requiere identificacion.
    ind_requiere_respuesta   BOOLEAN                    NOT NULL DEFAULT TRUE,                                                                      -- ¿Requiere respuesta formal
    ind_borrado              BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                     -- Borrado logico.
    PRIMARY KEY (id_radicado),
    CONSTRAINT chk_pqrs_vencimiento CHECK (fec_vencimiento >= fec_radicado::date),
    FOREIGN KEY (id_tipo_pqrs, subtipo_vencimiento) REFERENCES tab_param_venc_pqrs(id_tipo_pqrs, nom_subtipo),
    FOREIGN KEY (id_canal)       REFERENCES tab_canales(id_canal),
    FOREIGN KEY (id_estado_pqrs) REFERENCES tab_estado_pqrs(id_estado_pqrs),
    FOREIGN KEY (id_motivo)      REFERENCES tab_motivo_pqrs(id_motivo),
    FOREIGN KEY (id_area)        REFERENCES tab_areas(id_area),
    FOREIGN KEY (id_tercero)     REFERENCES tab_terceros(id_tercero),
    FOREIGN KEY (id_usuario)     REFERENCES tab_usuarios(id_usuario)
);
-- Indices para optimizar consultas por estado, area, tipo, fechas y anonimos.
CREATE INDEX idx_enc_pqrs_estado       ON tab_enc_pqrs(id_estado_pqrs);
CREATE INDEX idx_enc_pqrs_area         ON tab_enc_pqrs(id_area);
CREATE INDEX idx_enc_pqrs_tipo         ON tab_enc_pqrs(id_tipo_pqrs);
CREATE INDEX idx_enc_pqrs_radicado     ON tab_enc_pqrs(fec_radicado);
CREATE INDEX idx_enc_pqrs_vence        ON tab_enc_pqrs(fec_vencimiento);
CREATE INDEX idx_enc_pqrs_estado_vence ON tab_enc_pqrs(id_estado_pqrs, fec_vencimiento);
CREATE INDEX idx_enc_pqrs_anonimo      ON tab_enc_pqrs(ind_anonimo) WHERE ind_anonimo = TRUE;
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_det_pqrs
-- Proposito: Genera identificadores unicos para cada registro de detalle de PQRS.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_det_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_det_pqrs
-- Almacena informacion detallada y complementaria de cada solicitud de PQRS.
-- Registra la prioridad, tiempos de respuesta (real y proyectado), fechas de asignacion,
-- inicio de gestion, ultima gestion y cierre definitivo, asi como el gestor responsable,
-- el usuario que cerro, la calificacion del solicitante y comentarios de cierre.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_pqrs
(
    id_detalle_pqrs             DECIMAL(12,0)              NOT NULL DEFAULT nextval('seq_det_pqrs'),                                                        -- Identificador unico. Clave primaria.
    id_radicado                 VARCHAR(20)                NOT NULL CHECK (id_radicado ~ '^PQRS-[0-9]{4}-[0-9]{6}$'),                                       -- FK al radicado.
    val_prioridad               VARCHAR(20)                NOT NULL DEFAULT 'NORMAL' CHECK (val_prioridad IN ('BAJA','NORMAL','ALTA','URGENTE','CRITICA')), -- Nivel de prioridad.
    tiempo_respuesta_real       INTEGER                    NOT NULL DEFAULT 0 CHECK (tiempo_respuesta_real BETWEEN 0 AND 365),                              -- Dias reales que tomo responder.
    tiempo_respuesta_proyectado INTEGER                             CHECK (tiempo_respuesta_proyectado BETWEEN 0 AND 365) DEFAULT 0,                        -- Dias proyectados para respuesta.
    fec_asignacion              TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT CURRENT_TIMESTAMP,                                                              -- Fecha y hora de asignacion a un gestor.
    fec_inicio_gestion          TIMESTAMP WITH TIME ZONE   NOT NULL CHECK (fec_inicio_gestion >= fec_asignacion),                                           -- Fecha de inicio real de gestion.
    fec_ultima_gestion          TIMESTAMP WITH TIME ZONE   NOT NULL CHECK (fec_ultima_gestion >= fec_inicio_gestion),                                       -- Fecha de ultima actividad.
    fec_cierre_definitivo       TIMESTAMP WITH TIME ZONE   NOT NULL,                                                                                        -- Fecha de cierre definitivo.
    id_usuario_gestor           VARCHAR                    NOT NULL CHECK(LENGTH(id_usuario_gestor) >= 5),                                                         -- FK al usuario gestor.
    id_usuario_cierre           VARCHAR                    NOT NULL CHECK(LENGTH(id_usuario_cierre) >= 5),                                                         -- FK al usuario que cerro.
    calificacion_solicitante    DECIMAL(2,0)                        CHECK (calificacion_solicitante BETWEEN 1 AND 5),                                       -- Calificacion 1-5 estrellas.
    comentario_cierre           TEXT                       NOT NULL DEFAULT 'SIN_COMENTARIO',                                                               -- Comentario de cierre.
    ind_borrado                 BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                          -- Borrado logico.
    PRIMARY KEY (id_detalle_pqrs),
    CONSTRAINT chk_fechas_gestion CHECK ((fec_inicio_gestion IS NULL OR fec_inicio_gestion >= fec_asignacion) AND (fec_cierre_definitivo IS NULL OR fec_cierre_definitivo >= fec_inicio_gestion)),
    FOREIGN KEY (id_radicado)       REFERENCES tab_enc_pqrs(id_radicado),
    FOREIGN KEY (id_usuario_gestor) REFERENCES tab_usuarios(id_usuario),
    FOREIGN KEY (id_usuario_cierre) REFERENCES tab_usuarios(id_usuario)
);
-- Indices para optimizar consultas por radicado, prioridad, gestor y fechas clave.
CREATE INDEX idx_det_pqrs_radicado       ON tab_det_pqrs(id_radicado);
CREATE INDEX idx_det_pqrs_prioridad      ON tab_det_pqrs(val_prioridad);
CREATE INDEX idx_det_pqrs_gestor         ON tab_det_pqrs(id_usuario_gestor);
CREATE INDEX idx_det_pqrs_fec_asignacion ON tab_det_pqrs(fec_asignacion) WHERE fec_asignacion IS NOT NULL;
CREATE INDEX idx_det_pqrs_fec_cierre     ON tab_det_pqrs(fec_cierre_definitivo) WHERE fec_cierre_definitivo IS NOT NULL;
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_seg_pqrs
-- Proposito: Genera identificadores unicos para cada registro de seguimiento de PQRS.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_seg_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_seg_pqrs
-- Registra el seguimiento historico de cada solicitud de PQRS (transiciones de estado).
-- Permite la trazabilidad completa de los cambios de estado de una PQRS.
-- Registra que estado tenia antes, a que estado cambio, quien fue el responsable
-- del cambio y cuando ocurrio.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_seg_pqrs
(
    id_seguimiento       DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_seg_pqrs'),                  -- Identificador unico. Clave primaria.
    id_radicado          VARCHAR(20)                NOT NULL CHECK (id_radicado ~ '^PQRS-[0-9]{4}-[0-9]{6}$'), -- FK al radicado.
    id_estado_origen     DECIMAL(2,0)               NOT NULL CHECK (id_estado_origen BETWEEN 1 AND 15),        -- Estado antes del cambio.
    id_estado_destino    DECIMAL(2,0)               NOT NULL CHECK (id_estado_destino BETWEEN 1 AND 15),       -- Estado despues del cambio.
    fec_accion           TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                    -- Fecha y hora del cambio.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                    -- Borrado logico.
    PRIMARY KEY (id_seguimiento),
    FOREIGN KEY (id_radicado)       REFERENCES tab_enc_pqrs(id_radicado),
    FOREIGN KEY (id_estado_origen)  REFERENCES tab_estado_pqrs(id_estado_pqrs),
    FOREIGN KEY (id_estado_destino) REFERENCES tab_estado_pqrs(id_estado_pqrs)
);
-- Indices para optimizar consultas por radicado y por fecha de accion.
CREATE INDEX idx_seg_pqrs_radicado ON tab_seg_pqrs(id_radicado);
CREATE INDEX idx_seg_pqrs_fecha    ON tab_seg_pqrs(fec_accion);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_respuesta_pqrs
-- Proposito: Genera identificadores unicos para cada respuesta registrada en PQRS.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_respuesta_pqrs START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_respuesta_pqrs
-- Registra las respuestas proporcionadas a cada solicitud de PQRS.
-- Almacena la respuesta enviada al solicitante, el canal de respuesta,
-- si es la respuesta final, quien la genero y cuando.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_respuesta_pqrs
(
    id_respuesta         DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_respuesta_pqrs'),            -- Identificador unico. Clave primaria.
    id_radicado          VARCHAR(20)                NOT NULL CHECK (id_radicado ~ '^PQRS-[0-9]{4}-[0-9]{6}$'), -- FK al radicado.
    canal_respuesta      DECIMAL(2,0)               NOT NULL CHECK (canal_respuesta BETWEEN 1 AND 20),         -- Canal de respuesta (FK a tabla de canales).
    ind_respuesta_final  BOOLEAN                    NOT NULL DEFAULT FALSE,                                    -- Es la respuesta final Solo una puede ser TRUE por radicado.
    fec_respuesta        TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                    -- Fecha y hora de la respuesta.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                    -- Borrado logico.
    PRIMARY KEY (id_respuesta),
    FOREIGN KEY (id_radicado) REFERENCES tab_enc_pqrs(id_radicado)
);
-- Indices para optimizar consultas por radicado y para garantizar que solo haya una respuesta final por PQRS.
CREATE UNIQUE INDEX idx_uq_respuesta_final_pqrs ON tab_respuesta_pqrs(id_radicado) WHERE ind_respuesta_final = TRUE;
CREATE INDEX idx_respuesta_pqrs_radicado        ON tab_respuesta_pqrs(id_radicado);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_anexo_pqrs
-- Almacena los anexos o archivos adjuntos relacionados con las solicitudes de PQRS o sus respuestas.
-- Permite adjuntar archivos (PDF, JPG, PNG) a una PQRS o a una respuesta especifica.
-- Cada anexo debe pertenecer a un solo padre (radicado o respuesta).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_anexo_pqrs
(
    id_anexo_pqrs        VARCHAR(10)                NOT NULL CHECK (id_anexo_pqrs ~ '^ANX-[A-Z0-9]{5,10}$'),                            -- Identificador unico. Formato: ANX-XXXXX. Clave primaria.
    id_radicado          VARCHAR(20)                         CHECK (id_radicado IS NULL OR id_radicado ~ '^PQRS-[0-9]{4}-[0-9]{6}$'),   -- FK al radicado (si el anexo pertenece al radicado).
    id_respuesta         DECIMAL(18,0)                       CHECK (id_respuesta IS NULL OR id_respuesta >= 1),                         -- FK a la respuesta (si el anexo pertenece a la respuesta).
    nom_anexo            VARCHAR                    NOT NULL CHECK (nom_anexo ~ '^[A-Za-z0-9._-]{1,255}$'),                             -- Nombre del archivo.
    tamano_bytes         BIGINT                     NOT NULL CHECK (tamano_bytes BETWEEN 1 AND 52428800),                               -- Tamaño en bytes (maximo 50MB).
    val_formato          VARCHAR(10)                NOT NULL CHECK (val_formato IN ('PDF','JPG','PNG')),                                -- Formato del archivo.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                             -- Borrado logico.
    PRIMARY KEY (id_anexo_pqrs),
    CONSTRAINT chk_anexo_pqrs_un_padre CHECK ((CASE WHEN id_radicado IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_respuesta IS NOT NULL THEN 1 ELSE 0 END) = 1),
    FOREIGN KEY (id_radicado)  REFERENCES tab_enc_pqrs(id_radicado),
    FOREIGN KEY (id_respuesta) REFERENCES tab_respuesta_pqrs(id_respuesta)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_normas
-- Define las normas de calidad aplicables a los procesos documentales.
-- Catalogo de normas (ISO 9001, ISO 14001, NTC, etc.) que sirve como base
-- para las certificaciones y para asociar documentos de calidad con los estandares que cumplen.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_normas
(
    id_norma             VARCHAR(50)                NOT NULL CHECK (id_norma ~ '^[A-Z]{2,5}-[0-9]{4,6}$'),            -- Identificador unico. Formato: ISO-9001. Clave primaria.
    nom_norma            VARCHAR                    NOT NULL CHECK (char_length(trim(nom_norma)) BETWEEN 5 AND 255),  -- norma iso 9001 regla internacional para la gestion de calidad
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                           -- Borrado logico.
    PRIMARY KEY (id_norma)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_certificacion
-- Registra las certificaciones obtenidas por la organizacion bajo una norma especifica.
-- Permite gestionar el portafolio de certificaciones, incluyendo fechas de emision
-- y vencimiento para planificar renovaciones y auditorias de seguimiento.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_certificacion
(
    id_certificacion     DECIMAL(6,0)               NOT NULL CHECK (id_certificacion BETWEEN 1 AND 999999),                  -- Identificador unico. Clave primaria.
    nom_certificacion    VARCHAR                    NOT NULL CHECK (char_length(trim(nom_certificacion)) BETWEEN 5 AND 255), -- Nombre descriptivo.
    id_norma             VARCHAR(50)                NOT NULL CHECK (id_norma ~ '^[A-Z]{2,5}-[0-9]{4,6}$'),                   -- FK a la norma asociada.
    fec_emision          DATE                       NOT NULL CHECK (fec_emision <= CURRENT_DATE),                            -- Fecha de emision. No puede ser futura.
    fec_vencimiento      DATE                       NOT NULL CHECK (fec_vencimiento > fec_emision),                          -- Fecha de vencimiento. Debe ser posterior a emision.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                  -- Borrado logico.
    PRIMARY KEY (id_certificacion),
    CONSTRAINT chk_certificacion_vigencia CHECK (fec_vencimiento > fec_emision),
    FOREIGN KEY (id_norma) REFERENCES tab_normas(id_norma)
);
-- Indices para optimizar consultas por norma y por nombre de certificacion.
CREATE INDEX idx_certificacion_norma ON tab_certificacion(id_norma);
CREATE INDEX idx_nom_certificacion ON tab_certificacion(nom_certificacion);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_estado_documento
-- Define los estados de los documentos gestionados en el sistema de calidad.
-- Permite el control del ciclo de vida de los documentos de calidad (manuales, procedimientos,
-- instructivos, formatos, politicas, registros).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_estado_documento
(
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 20),                     -- Identificador unico (1 a 20). Clave primaria.
    val_estado           VARCHAR(15)                NOT NULL CHECK (char_length(trim(val_estado)) BETWEEN 3 AND 15), -- Estado: BORRADOR, EN_REVISION, EN_APROBACION, APROBADO, RECHAZADO, PUBLICADO, OBSOLETO, ARCHIVADO.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                          -- Borrado logico.
    PRIMARY KEY (id_estado)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_enc_documento
-- Es la tabla principal que registra la informacion basica de cada documento gestionado en el sistema de calidad.
-- Almacena el titulo, tipo de documento, estado actual, area responsable, resumen,
-- vigencia, fechas de publicacion y revision, y el tercero responsable.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_enc_documento
(
    id_documento         VARCHAR(15)                NOT NULL CHECK (id_documento ~ '^DOC-[A-Z0-9]{5,15}$'), -- 
    nom_titulo           VARCHAR                    NOT NULL CHECK (char_length(trim(nom_titulo)) BETWEEN 5 AND 255), -- Titulo del documento.
    id_estado            DECIMAL(2,0)               NOT NULL CHECK (id_estado BETWEEN 1 AND 20),    -- FK al estado actual.
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0 ),                  -- FK al area responsable.
    resumen              VARCHAR                    NOT NULL CHECK (char_length(trim(resumen)) >= 5) DEFAULT 'Sin Resumen', -- Resumen del documento.
    ind_vigencia         BOOLEAN                    NOT NULL DEFAULT TRUE,                          -- ¿Documento vigente
    fec_publicacion      DATE                       NOT NULL CHECK (fec_publicacion <= CURRENT_DATE), -- Fecha de publicacion.
    fec_revision         DATE                       NOT NULL CHECK (fec_revision >= fec_publicacion), -- Fecha de proxima revision.
    id_tercero           VARCHAR(10)                NOT NULL,
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                         -- Borrado logico.
    PRIMARY KEY (id_documento),
    CONSTRAINT chk_fechas_documento CHECK (fec_revision >= fec_publicacion),
    FOREIGN KEY (id_estado)  REFERENCES tab_estado_documento(id_estado),
    FOREIGN KEY (id_area)    REFERENCES tab_areas(id_area),
    FOREIGN KEY (id_tercero) REFERENCES tab_terceros(id_tercero)
);
-- Indices para optimizar consultas frecuentes por estado, area y fechas.
CREATE INDEX idx_enc_documento_estado ON tab_enc_documento(id_estado);
CREATE INDEX idx_enc_documento_area   ON tab_enc_documento(id_area) WHERE id_area IS NOT NULL;
CREATE INDEX idx_enc_documento_fec    ON tab_enc_documento(fec_publicacion);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_det_documento
-- Registra las diferentes versiones de cada documento gestionado en el sistema de calidad.
-- Permite el control de versiones de los documentos. Cada vez que un documento se modifica,
-- se crea una nueva version con su propio identificador, numero de version y fecha.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_det_documento
(
    id_version           VARCHAR(50)                NOT NULL CHECK (id_version ~ '^VER-[0-9]{8}-[0-9]{3}$'),  --Identificador unico. Formato VER-AAAAMMDD-XXX. Clave primaria.
    id_documento         VARCHAR(50)                NOT NULL CHECK (id_documento ~ '^DOC-[A-Z0-9]{5,50}$'),   --  FK al documento.
    num_version          INTEGER                    NOT NULL CHECK (num_version BETWEEN 1 AND 999) DEFAULT 1, -- Numero de version.
    fec_version          TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                   -- Fecha y hora de creacion de la version.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                   -- Borrado logico.
    PRIMARY KEY (id_version),
    CONSTRAINT uq_doc_num_version UNIQUE (id_documento, num_version),
    CONSTRAINT chk_version_unica CHECK (num_version = CAST(substring(id_version from '[0-9]{3}$') AS INTEGER)),
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_doc_norma
-- Establece la relacion entre los documentos de calidad y las normas aplicables.
-- Permite una relacion muchos a muchos: un documento puede estar asociado a multiples normas
-- y una norma puede estar asociada a multiples documentos.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_norma
(
    id_documento         VARCHAR(50)                NOT NULL CHECK (id_documento ~ '^DOC-[A-Z0-9]{5,50}$'), -- FK al documento. Parte de PK.
    id_norma             VARCHAR(50)                NOT NULL CHECK (id_norma ~ '^[A-Z]{2,5}-[0-9]{4,6}$'),  -- FK a la norma. Parte de PK.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                 -- Borrado logico.
    PRIMARY KEY (id_documento, id_norma),
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento),
    FOREIGN KEY (id_norma)     REFERENCES tab_normas(id_norma)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_doc_archivo
-- Almacena los archivos asociados a cada version de los documentos de calidad.
-- Permite subir y gestionar los archivos digitales (PDF, JPG, PNG) que contienen
-- el contenido real de cada version de un documento.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_archivo
(
    id_archivo           VARCHAR(60)                NOT NULL CHECK (id_archivo ~ '^FILE-[A-Z0-9]{15,60}$'),     -- Identificador unico. Formato: FILE-XXXXX. Clave primaria.
    id_version           VARCHAR(50)                NOT NULL CHECK (id_version ~ '^VER-[0-9]{8}-[0-9]{3}$'),    -- FK a la version del documento.
    nom_archivo          VARCHAR                    NOT NULL CHECK (nom_archivo ~ '^[A-Za-z0-9._-]{1,255}$'),   -- Nombre del archivo.
    tamano_bytes         BIGINT                     NOT NULL CHECK (tamano_bytes BETWEEN 1 AND 52428800),       -- Tamaño en bytes (maximo 50MB).
    val_formato          VARCHAR(10)                NOT NULL CHECK (val_formato IN ('PDF','JPG','PNG')),        -- Formato del archivo.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                     -- Borrado logico.
    PRIMARY KEY (id_archivo),
    FOREIGN KEY (id_version) REFERENCES tab_det_documento(id_version)
);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_procesos
-- Define los procesos de calidad asociados a la gestion documental.
-- Registra el mapa de procesos de la organizacion (estrategicos, misionales, apoyo).
-- Cada proceso tiene un objetivo, fecha de creacion, indicadores de actividad y ejecucion,
-- y un area responsable. Los procesos pueden ser auditados.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_procesos
(
    id_proceso           VARCHAR(50)                NOT NULL CHECK (id_proceso ~ '^PROC-[A-Z0-9]{5,50}$'),                     -- Identificador unico. Formato: PROC-XXXXX. Clave primaria.
    nom_proceso          VARCHAR                    NOT NULL CHECK (char_length(trim(nom_proceso)) BETWEEN 5 AND 255),         -- Nombre del proceso.
    objetivo             VARCHAR                    NOT NULL DEFAULT 'Sin Objetivo' CHECK (char_length(trim(objetivo)) >= 10), -- Objetivo del proceso.
    fec_creacion         DATE                       NOT NULL CHECK (fec_creacion <= CURRENT_DATE),                             -- Fecha de creacion.
    ind_activo           BOOLEAN                    NOT NULL DEFAULT TRUE,                                                     -- ¿Proceso activo
    ind_en_ejecucion     BOOLEAN                    NOT NULL DEFAULT FALSE,                                                    -- ¿En ejecucion actualmente
    id_area              DECIMAL(5,0)               NOT NULL CHECK (id_area > 0),                                              -- FK al area responsable.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                    -- Borrado logico.
    PRIMARY KEY (id_proceso),
    FOREIGN KEY (id_area) REFERENCES tab_areas(id_area)
);
-- Indices para optimizar consultas por area responsable y estado del proceso.
CREATE INDEX idx_procesos_area   ON tab_procesos(id_area);
CREATE INDEX idx_procesos_activo ON tab_procesos(ind_activo) WHERE ind_activo = TRUE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_auditorias
-- Registra las auditorias realizadas en el marco de la gestion documental y de calidad.
-- Permite planificar y ejecutar auditorias internas, externas o de certificacion
-- sobre los procesos de calidad.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_auditorias
(
    id_auditoria         DECIMAL(6,0)               NOT NULL CHECK (id_auditoria BETWEEN 1 AND 999999),                       -- Identificador unico. Clave primaria.
    nom_auditoria        VARCHAR                    NOT NULL CHECK (char_length(trim(nom_auditoria)) BETWEEN 5 AND 255),      -- Nombre de la auditoria.
    id_proceso           VARCHAR(50)                NOT NULL CHECK (id_proceso ~ '^PROC-[A-Z0-9]{5,50}$'),                    -- FK al proceso auditado.
    tipo_auditoria       VARCHAR(15)                NOT NULL CHECK (tipo_auditoria IN ('INTERNA','EXTERNA','CERTIFICACION')), -- Tipo de auditoria.
    id_certificacion     DECIMAL(6,0)               NOT NULL CHECK (id_certificacion BETWEEN 1 AND 999999),                   -- FK a la certificacion asociada.
    fec_auditoria        DATE                       NOT NULL CHECK (fec_auditoria <= CURRENT_DATE),                           -- Fecha de la auditoria.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                   -- Borrado logico.
    PRIMARY KEY (id_auditoria),
    FOREIGN KEY (id_proceso)       REFERENCES tab_procesos(id_proceso),
    FOREIGN KEY (id_certificacion) REFERENCES tab_certificacion(id_certificacion)
);
-- Indices para optimizar consultas por proceso, certificacion y tipo de auditoria.
CREATE INDEX idx_auditoria_proceso ON tab_auditorias(id_proceso);
CREATE INDEX idx_auditoria_certificacion ON tab_auditorias(id_certificacion);
CREATE INDEX idx_auditoria_tipo ON tab_auditorias(tipo_auditoria);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_hallazgo
-- Registra los hallazgos identificados durante las auditorias
-- (no conformidades, observaciones, oportunidades de mejora).
-- Permite documentar los problemas o desviaciones encontradas en una auditoria,
-- clasificarlos por severidad y darles seguimiento hasta su cierre.
-- Basado en la Ley 594 de 2000 (Ley General de Archivos).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_hallazgo
(
    id_hallazgo          VARCHAR(6)                 NOT NULL CHECK (id_hallazgo ~ '^[A-Z0-9]{6}$'),                      -- Identificador unico. 6 caracteres alfanumericos. Clave primaria.
    id_auditoria         DECIMAL(6,0)               NOT NULL CHECK (id_auditoria BETWEEN 1 AND 999999),                  -- FK a la auditoria.
    val_severidad        VARCHAR(10)                NOT NULL CHECK (val_severidad IN ('BAJA','MEDIA','ALTA','CRITICA')), -- Severidad del hallazgo.
    ind_estado           BOOLEAN                    NOT NULL DEFAULT TRUE,                                               -- TRUE = Abierto, FALSE = Cerrado.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                              -- Borrado logico.
    PRIMARY KEY (id_hallazgo),
    FOREIGN KEY (id_auditoria) REFERENCES tab_auditorias(id_auditoria)
);
-- Indices para optimizar consultas por auditoria y estado del hallazgo.
CREATE INDEX idx_hallazgo_auditoria       ON tab_hallazgo(id_auditoria);
CREATE INDEX idx_hallazgo_auditoria_estado ON tab_hallazgo(id_auditoria, ind_estado);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_accion_correctiva
-- Registra las acciones correctivas implementadas en respuesta a los hallazgos de auditoria.
-- Permite definir un plan de accion para resolver cada hallazgo. Incluye el responsable,
-- la fecha compromiso de ejecucion, la fecha real de ejecucion y el estado de la accion.
-- Basado en ISO 9001:2015 (numeral 10.2 - Mejora Continua).
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_accion_correctiva
(
    id_accion            VARCHAR(12)                NOT NULL CHECK (id_accion ~ '^AC-[A-Z0-9]{10,60}$'),                                             -- Identificador unico. Formato: AC-XXXXX. Clave primaria.
    id_hallazgo          VARCHAR(6)                 NOT NULL CHECK (id_hallazgo ~ '^[A-Z0-9]{6}$'),                                                  -- FK al hallazgo.
    id_tercero           VARCHAR(10)                NOT NULL,
    fec_compromiso       DATE                       NOT NULL CHECK (fec_compromiso >= CURRENT_DATE),                                                 -- Fecha compromiso. No puede ser menor a hoy.
    fec_ejecucion        DATE                                CHECK (fec_ejecucion IS NULL OR fec_ejecucion >= fec_compromiso),                                -- Fecha real de ejecucion.
    val_estado           VARCHAR(15)                NOT NULL CHECK (val_estado IN ('ABIERTA','EN_PROCESO','CERRADA','CANCELADA')) DEFAULT 'ABIERTA', -- Estado de la accion.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                                          -- Borrado logico.
    PRIMARY KEY (id_accion),
    CONSTRAINT chk_accion_estado_fecha CHECK (CASE WHEN val_estado IN ('CERRADA', 'CANCELADA') THEN fec_ejecucion IS NOT NULL ELSE fec_ejecucion IS NULL END),
    FOREIGN KEY (id_hallazgo) REFERENCES tab_hallazgo(id_hallazgo),
    FOREIGN KEY (id_tercero)  REFERENCES tab_terceros(id_tercero)
);
-- Indices para optimizar consultas por hallazgo y estado de la accion.
CREATE INDEX idx_ac_hallazgo ON tab_accion_correctiva(id_hallazgo);
CREATE INDEX idx_ac_estado   ON tab_accion_correctiva(val_estado);
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_doc_anexo
-- Almacena los anexos relacionados con documentos, versiones o hallazgos del sistema de calidad.
-- Permite adjuntar archivos complementarios a documentos de calidad,
-- versiones especificas o hallazgos de auditoria.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_doc_anexo
(
    id_anexo             VARCHAR(10)                NOT NULL CHECK (id_anexo ~ '^ANX-[A-Z0-9]{5,10}$'),                    -- Identificador unico. Formato: ANX-XXXXX. Clave primaria.
    id_documento         VARCHAR(50)                         CHECK (id_documento IS NULL OR id_documento ~ '^DOC-[A-Z0-9]{5,50}$'), -- FK al documento (opcional).
    id_version           VARCHAR(50)                         CHECK (id_version IS NULL OR id_version ~ '^VER-[0-9]{8}-[0-9]{3}$'),  -- FK a la version (opcional).
    id_hallazgo          VARCHAR(6)                          CHECK (id_hallazgo IS NULL OR id_hallazgo ~ '^[A-Z0-9]{6}$'),          -- FK al hallazgo (opcional).
    nom_anexo            VARCHAR                    NOT NULL CHECK (nom_anexo ~ '^[A-Za-z0-9._-]{1,255}$'),                -- Nombre del anexo.
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                                -- Borrado logico.
    PRIMARY KEY (id_anexo),
    CONSTRAINT chk_anexo_un_solo_padre CHECK ((CASE WHEN id_documento IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_version IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN id_hallazgo IS NOT NULL THEN 1 ELSE 0 END) = 1),
    FOREIGN KEY (id_documento) REFERENCES tab_enc_documento(id_documento),
    FOREIGN KEY (id_version)   REFERENCES tab_det_documento(id_version),
    FOREIGN KEY (id_hallazgo)  REFERENCES tab_hallazgo(id_hallazgo)
);
--------------------------------------------------------------------------------------------------------
-- SECUENCIA: seq_workflow
-- Proposito: Genera identificadores unicos para cada registro de transicion en el workflow de calidad.
--------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_workflow START WITH 1 INCREMENT BY 1 NO CYCLE;
--------------------------------------------------------------------------------------------------------
-- TABLA: tab_workflow
-- Registra las transiciones realizadas en el flujo de trabajo de gestion documental de calidad.
-- Permite la trazabilidad completa del ciclo de vida de los documentos de calidad.
-- Registra cada cambio de estado, que accion lo provoco, desde que estado, hacia que estado,
-- quien lo hizo y cuando.
--------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tab_workflow
(
    id_workflow          DECIMAL(18,0)              NOT NULL DEFAULT nextval('seq_workflow'),                      -- Identificador unico. Clave primaria.
    id_documento         VARCHAR(50)                NOT NULL CHECK (id_documento ~ '^DOC-[A-Z0-9]{5,50}$'),        -- FK al documento.
    id_version           VARCHAR(50)                NOT NULL CHECK (id_version ~ '^VER-[0-9]{8}-[0-9]{3}$'),       -- FK a la version.
    id_accion            DECIMAL(2,0)               NOT NULL CHECK (id_accion BETWEEN 1 AND 99),                                                               -- Identificador unico (1 a 99). Clave primaria.
    id_estado_origen     DECIMAL(2,0)               NOT NULL CHECK (id_estado_origen BETWEEN 1 AND 20),            -- Estado antes de la accion.
    id_estado_destino    DECIMAL(2,0)               NOT NULL CHECK (id_estado_destino BETWEEN 1 AND 20),           -- Estado despues de la accion.
    fec_transicion       TIMESTAMP WITH TIME ZONE   NOT NULL DEFAULT now(),                                        -- Fecha y hora de la transicion.
	-- rev_worflow				                  
    ind_borrado          BOOLEAN                    NOT NULL DEFAULT FALSE,                                        -- Borrado logico.
    PRIMARY KEY (id_workflow),
    CONSTRAINT chk_wf_estados_diferentes CHECK (id_estado_origen != id_estado_destino),
    FOREIGN KEY (id_documento)      REFERENCES tab_enc_documento(id_documento),
    FOREIGN KEY (id_version)        REFERENCES tab_det_documento(id_version),
    FOREIGN KEY (id_accion)         REFERENCES tab_accion_workflow(id_accion),
    FOREIGN KEY (id_estado_origen)  REFERENCES tab_estado_documento(id_estado),
    FOREIGN KEY (id_estado_destino) REFERENCES tab_estado_documento(id_estado)
);
-- Indices para optimizar consultas por documento, version y accion.
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

--*************************
--** TABLA DE INVERSORES **
--*************************

CREATE TABLE IF NOT EXISTS tab_inversores
(
    id_inversor           VARCHAR(10)                   NOT NULL    CHECK   (LENGTH(TRIM(id_inversor)) =10),                                        --identificación del inversor     
	nom_inversor          VARCHAR(60)                   NOT NULL    CHECK   (LENGTH(TRIM(nom_inversor)) BETWEEN 5 AND 60),                          --nombre del inversor
    tipo_inversor         BOOLEAN                       NOT NULL,   --true = Natural / false = Jurdíco                                              --tipo de inversor
    id_ciudad             VARCHAR(5)                    NOT NULL    CHECK   (LENGTH(TRIM(id_ciudad)) =5),                                           --identificación de la ciudad
    tel_inversor          DECIMAL(10,0)                 NOT NULL    CHECK   (tel_inversor >=0),                                                     --teléfono del inversor
    email_inversor        VARCHAR(120)                  NOT NULL    CHECK   (LENGTH(TRIM(email_inversor)) BETWEEN 5 AND 120),                       --correo electrónico del inversor
    estado_inversor       VARCHAR(20)                   NOT NULL    CHECK (estado_inversor IN ('ACTIVO','INACTIVO','SUSPENDIDO')),                  --estado del inversor
    dir_inversor          VARCHAR(254)                  NOT NULL    CHECK   (LENGTH(TRIM(dir_inversor)) BETWEEN 1 AND 254),                         --dirección del inversor
    ind_borrado           BOOLEAN                       NOT NULL    DEFAULT FALSE,                                                                     --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit           audit_trail,                                                                                                            --pista de auditoría
    PRIMARY KEY (id_inversor),
	FOREIGN KEY (id_ciudad) REFERENCES tab_ciudades(id_ciudad)
);

--************************
--** TABLA DE PROYECTOS **
--************************

CREATE TABLE IF NOT EXISTS tab_proyectos
(
    id_proyecto	            VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(id_proyecto)) BETWEEN 1 AND 10),                            -- identificador del proyecto
    nom_proyecto	        VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(nom_proyecto)) BETWEEN 1 AND 254),                          --nombre del proyecto
    val_proyecto            DECIMAL   (18,2)              NOT NULL      CHECK  (val_proyecto > 0),                                                            --valor del proyecto
    alcance_proyecto        TEXT                          NOT NULL      CHECK  (LENGTH(TRIM(alcance_proyecto)) > 0),                                              --alcance del proyecto
    costo_proyecto          DECIMAL   (18,2)              NOT NULL      CHECK  (costo_proyecto > 0),                                                            --costo del proyecto
    fec_inicio              DATE                          NOT NULL      CHECK  (fec_inicio >= '2025-01-01'),                                            --fecha de inicio del proyecto
    fec_fin                 DATE                          NOT NULL      CHECK  (fec_fin > fec_inicio),                                                  --fecha de finalización del proyecto
    resp_proyecto	        VARCHAR                       NOT NULL      CHECK  (LENGTH(TRIM(resp_proyecto)) BETWEEN 5 AND 60),                          --rresponsable del proyecto
    estado_proyecto         VARCHAR                       NOT NULL      CHECK (estado_proyecto IN ('ACTIVO','SUSPENDIDO','CANCELADO','COMPLETADO')),    --estado del proyecto
    ind_borrado             BOOLEAN                       NOT NULL      DEFAULT FALSE,                                                                       --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit             audit_trail,                                                                                                              --pista de auditoría
    PRIMARY KEY (id_proyecto)
);

--**************************
--** TABLA DE INDICADORES **
--**************************

CREATE TABLE IF NOT EXISTS tab_indicadores
(
    id_ind	                VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(id_ind)) BETWEEN 1 AND 50),                             --identificador del indicador             
    nom_ind	                TEXT                          NOT NULL       CHECK (LENGTH(TRIM(nom_ind)) > 0),                                         --nombre del indicador
    tip_ind	                VARCHAR                       NOT NULL       CHECK (tip_ind IN ('Rentabilidad','Liquidez','Endeudamiento','Rotación')),    --tipo de activo
    uni_medicion	        VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(uni_medicion)) BETWEEN 1 AND 20),                       --unidad de medición del indicador
    fuente_ind              VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(fuente_ind)) BETWEEN 1 AND 255),                        --fuente de información para el cálculo del indicador
    variable_ind            VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(variable_ind)) BETWEEN 1 AND 255),                      --variable del indicador
    formula	                VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(formula)) BETWEEN 1 AND 255),                           --formula para calcular el activo
    semaforo_ind            VARCHAR                       NOT NULL,                                                                                 --semaforo del indicador        
    frecu_ind               VARCHAR                       NOT NULL       CHECK (frecu_ind IN ('DIARIO','SEMANAL','MENSUAL','ANUAL')),              --frecuencia de calculo
    tole_ind                DECIMAL(18,4)                 NOT NULL       CHECK (tole_ind >= 0),                                                   --tolerancia para el semáforo
    ultimo_calculo          TIMESTAMP,                                                                                                              --último cálculo
    responsable_calculo     VARCHAR                       NOT NULL       CHECK (LENGTH(TRIM(responsable_calculo)) BETWEEN 5 AND 60),                --responsable del cálculo del indicador
    ind_borrado             BOOLEAN                       NOT NULL DEFAULT FALSE,                                                                   --TRUE: Borrado lógico / FALSE: Activo
--    datos_audit             audit_trail,                                                                                                          --pista de auditoría
    PRIMARY KEY (id_ind)
);


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
    PRIMARY KEY (id_ind, fec_calculo),
    FOREIGN KEY (id_pmtro_financiero)     REFERENCES tab_pmtros_financieros(id_pmtro_financiero),
    FOREIGN KEY (id_ind)                  REFERENCES tab_indicadores(id_ind)
);
-- ********************************
-- **    TABLA DE INVERSIONES    **
-- ********************************

CREATE TABLE IF NOT EXISTS tab_inversiones 
(
    id_proyecto             VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(id_proyecto)) BETWEEN 1 AND 10),                                     --identificador del proyectoPROYECTO
    id_inversor             VARCHAR(10)                   NOT NULL        CHECK (LENGTH(TRIM(id_inversor)) =10),                                                  --identificación del inversor                               
    val_participacion       DECIMAL   (4,1)               NOT NULL        CHECK (val_participacion > 0 AND val_participacion <= 100),                   --porcentaje de participación del inversor
    tipo_inversion          VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(tipo_inversion)) BETWEEN 1 AND 80),                                  --tipo de inversión
    entidad_financiera      VARCHAR                       NOT NULL        CHECK (LENGTH(TRIM(entidad_financiera)) BETWEEN 2 AND 100),                             --entidad financiera
    monto_inversion         DECIMAL   (18,2)              NOT NULL        CHECK (monto_inversion > 0),                                                            --monto de la inversión
    tasa_interes            DECIMAL   (5,2)               NOT NULL        CHECK (tasa_interes BETWEEN 0 AND 100),                                                 --tasa de interés
    tasa_efectividad        DECIMAL   (5,2)               NOT NULL        CHECK (tasa_efectividad BETWEEN 0 AND 100),                                             --tasa efectividad
    fecha_inicio            DATE                          NOT NULL        CHECK (fecha_inicio >= '2025-01-01'),                                                   --fecha de inicio
    fecha_vencimiento       DATE                          NOT NULL        CHECK (fecha_vencimiento > fecha_inicio),                                               --fecha de vencimiento
    estado_inversion        VARCHAR                       NOT NULL        CHECK (estado_inversion IN ('VIGENTE','VENCIDA','RENOVADA','CANCELADA','LIQUIDADA')),   --estado de la inversión
    ind_borrado             BOOLEAN                       NOT NULL        DEFAULT FALSE,                                                                                 --TRUE: Borrado lógico / FALSE: Activo
    --    datos_audit audit_trail,                                                                                                                        --pista de auditoría
    PRIMARY KEY (id_proyecto, id_inversor),
    FOREIGN KEY (id_proyecto)        REFERENCES tab_proyectos(id_proyecto),
	FOREIGN KEY (id_inversor)    REFERENCES tab_inversores(id_inversor)
);

---------
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
CREATE INDEX IF NOT EXISTS idx_auditoria_tabla_fecha ON public.tab_audit_trail(nom_tabla, fec_registro DESC);


-- ----------------------------------
-- FUNCIÓN DE TRIGGER DE AUDITORÍA --
-- ----------------------------------
CREATE OR REPLACE FUNCTION fun_audit_trail() RETURNS TRIGGER AS $$
DECLARE 
    w_old_data JSONB;
    w_new_data JSONB;
    w_operacion CHAR(1);
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        w_old_data := to_jsonb(OLD);
        w_new_data := to_jsonb(NEW);
        
        -- Bloque para intentar acceder a las columnas directamente
        BEGIN
            IF (OLD.ind_borrado = FALSE AND NEW.ind_borrado = TRUE) THEN
                w_operacion := 'D';  -- Borrado lógico

            ELSIF (OLD.ind_borrado = TRUE AND NEW.ind_borrado = FALSE) THEN
                w_operacion := 'R';  -- Restauración

            ELSE
                w_operacion := 'U';  -- Update normal
            END IF;
            
        EXCEPTION WHEN undefined_column THEN
            -- Si la tabla NO tiene la columna 'ind_borrado', cae aquí
            w_operacion := 'U';
        END;
        
    ELSIF (TG_OP = 'INSERT') THEN
        w_old_data := NULL;
        w_new_data := to_jsonb(NEW);
        w_operacion := 'I';
        
    ELSIF (TG_OP = 'DELETE') THEN
        w_old_data := to_jsonb(OLD);
        w_new_data := NULL;
        w_operacion := 'D';
        
    ELSE
        RETURN NULL;
    END IF;

    -- Insertar el registro de auditoría
    INSERT INTO tab_audit_trail (nom_esquema, nom_tabla, ind_operacion, usuario_erp_id, datos_viejos, datos_nuevos)
    VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, w_operacion, NULL, w_old_data, w_new_data);

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SECURITY DEFINER: Importante para asegurar que el trigger se ejecute 
-- con los permisos del creador (que tiene acceso a public.auditoria_registros)

----------------------------------------------------------------
-- 10.1 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS GENERALES --
----------------------------------------------------------------

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_dptos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_ciudades
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_cat_terceros
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_restricciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_terceros
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_areas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_menus
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_usuarios
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_bancos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

-------------------------------------------------------------------
-- 10.3 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS CONTABILIDAD --
-------------------------------------------------------------------


CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_ejecucion_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_planeacion_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_period_presupuesto
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tip_comprobantes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_comprobantes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_comprobantes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_act_fijos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_depreciacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_cat_activos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_parametros_contab
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_puc
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();


--------------------------------------------------------------
-- 10.3 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS COMPRAS --
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_pmtros_compras
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_proveedores
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_eval_prov
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_productos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_prodxprov
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_solcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_solcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_ordcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_ordcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_seg_ordcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_seg_ordcomp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

------------------------------------------------------------------------------
-- 10.4 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS GESTIÓN HUMANA Y NÓMINA --  PENDIENTE
------------------------------------------------------------------------------

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_pmtros_legales
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_escolaridad
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_profesiones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_cargos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_candidatos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_empleados
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_prestamos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_conceptos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_novedades
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_nomina
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_procesos_disciplinarios
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_nomina_electronica
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

----------------------------------------------------------
-- 10.5 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS SST --
----------------------------------------------------------
CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_accidentes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_asis_cap
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_asist_copasst
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_auditorias_sst
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_brigada
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_brigadistas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_capacitaciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_copasst
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_ex_ingreso
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_docentes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_emergencia
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_ex_ingreso
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_epp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_epp_asignacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_epp_inspeccion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_examenes
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_incapacidades
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_inspeccion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_miem_copasst
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_reu_copasst
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_riesgos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_temas_cap
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_acc
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_incapacidad
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

-----------------------------------------------------------------------------
-- 10.6 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS MARKETING Y COMERICIAL -- 
-----------------------------------------------------------------------------

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_pmtros_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_etapas_funnel
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_canales
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_motivos_perdida
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_kpis_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_campana
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipos_interaccion_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_criterios_segmentacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_valores_segmentacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tablas_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_atributos_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_campos_segmentacion_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_reglas_segmentacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_condiciones_regla_marcom
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_campanas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_leads
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_evento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_plantillas_correo
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_campana_canal
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_lead_camp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_prod_camp
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_even_lead
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_segmentacion_cliente
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_contactos_adicionales
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_presupuesto_campana
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_presupuesto_evento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_proximas_acciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_medicion_kpi
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE  OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_envios
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

----------------------------------------------------------------------------
-- 10.7 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS FACTURACIÓN Y CARTERA --
----------------------------------------------------------------------------
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

--------------------------------------------------------------------
-- 10.8 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS TESORIA Y CXP --
--------------------------------------------------------------------
CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_archivo_plano
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_archivo_plano
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_cronopagos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_cronopagos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_cuotasxfactura
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_cuentasxpagar
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_bancoxprov
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_ctas_empresa
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_pmtros_tescxp
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_caja_menor
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_caja_menor
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_festivos
FOR EACH ROW EXECUTE FUNCTION public.fun_audit_trail();

-----------------------------------------------------------------------------------
-- 10.9 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS GESTIÓN DOCUMENTAL Y CALIDAD --
-----------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_documento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tabla_retencion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_estado_correspondencia
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_accion_workflow
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_correspondencia
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_indexacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_expediente
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_doc_expediente
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_notificaciones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_tipo_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_param_venc_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_estado_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_motivo_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_seg_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_respuesta_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_anexo_pqrs
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_normas
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_certificacion
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_estado_documento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_accion_workflow
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_enc_documento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_det_documento
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_doc_norma
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_doc_archivo
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_procesos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_auditorias
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_hallazgo
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_doc_anexo
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_accion_correctiva
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE ON tab_workflow
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

------------------------------------------------------------------
-- 10.10 CREACION DE TRIGGERS PARA AUDITORIAS TABLAS FINANCIERA --
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_pmtros_financieros
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_inversores
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_proyectos
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_indicadores
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_val_ind
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

CREATE OR REPLACE TRIGGER tri_audit_trail AFTER INSERT OR UPDATE OR DELETE ON tab_inversiones
FOR EACH ROW EXECUTE FUNCTION fun_audit_trail();

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


-- V.1.3 CORRECCIÓN: Función trigger actualizada
-- Ahora inserta solo (id_usuario, id_menu) - nom_programa está en tab_menus
CREATE OR REPLACE FUNCTION fun_trigger_menu() RETURNS TRIGGER AS
$$
 DECLARE wid_menu tab_menus.id_menu%TYPE;
	BEGIN
        SELECT a.id_menu INTO wid_menu FROM tab_menus a
        WHERE a.id_menu = '99';
        IF NOT FOUND THEN
            RETURN NULL;
        END IF;
        -- V.1.3: INSERT solo con 2 valores (id_usuario, id_menu)
        -- El programa 'Exit' está en tab_menus.nom_programa
        INSERT INTO tab_menu_usuarios VALUES(NEW.id_usuario,wid_menu);
        IF FOUND THEN
            RETURN NULL;
        END IF;
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_menu_usuarios
AFTER INSERT ON tab_usuarios FOR EACH ROW
EXECUTE FUNCTION fun_trigger_menu();

-- V.1.3 CORRECCIÓN: Función trigger para adicionar una opción nueva del menú al admin.
-- Ahora inserta en el menu en la tabla tab_menu_usuarios pero spolo para el admin.
CREATE OR REPLACE FUNCTION fun_trigger_menu_admin() RETURNS TRIGGER AS
$$
 DECLARE wid_usuario tab_usuarios.id_usuario%TYPE;
	BEGIN
        SELECT a.id_usuario INTO wid_usuario FROM tab_usuarios a
        WHERE a.id_usuario = 'admin';
        IF NOT FOUND THEN
            RETURN NULL;
        END IF;
        INSERT INTO tab_menu_usuarios VALUES(wid_usuario,NEW.id_menu);
        IF FOUND THEN
            RETURN NULL;
        END IF;
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_menu_dmin
AFTER INSERT ON tab_menus FOR EACH ROW
EXECUTE FUNCTION fun_trigger_menu_admin();

-- ===================================================================
-- Función: fun_delete_menu_usuarios_por_menu
-- Descripción: Elimina todos los registros de tab_menu_usuarios asociados a un menú.
-- Parámetro:
--   wid_menu: ID del menú (VARCHAR)
-- Retorna: VOID
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_delete_menu_usuarios_por_menu(wid_menu tab_menus.id_menu%TYPE) RETURNS VOID AS
$$
DECLARE
    v_exists INTEGER;
    v_deleted INTEGER;
BEGIN
    -- Validar que el menú exista (ref. integridad referencial)
    SELECT COUNT(*) INTO v_exists FROM tab_menus WHERE id_menu = wid_menu;
    IF v_exists = 0 THEN
        RAISE EXCEPTION 'El menú % no existe en tab_menus', wid_menu;
    END IF;

    -- Eliminar los accesos de usuarios asociados al menú
    DELETE FROM tab_menu_usuarios
    WHERE id_menu = wid_menu;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    -- Opcional: RAISE NOTICE 'Se eliminaron % registros de tab_menu_usuarios para el menú %', v_deleted, wid_menu;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error eliminando accesos para menú %: %', wid_menu, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- Trigger: tg_desasignar_menu
-- Descripción: Invocado antes de borrar un menú para limpiar accesos de usuarios.
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_trigger_desasignar_menu() RETURNS TRIGGER AS
$$
BEGIN
    PERFORM fun_delete_menu_usuarios_por_menu(OLD.id_menu);
    RETURN OLD;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en trigger tg_desasignar_menu para menú %: %', OLD.id_menu, SQLERRM;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tg_desasignar_menu
BEFORE DELETE ON tab_menus FOR EACH ROW
EXECUTE FUNCTION fun_trigger_desasignar_menu();

-- =============================================
-- Función: fun_insert_areas
-- Descripción: Inserta un nuevo registro en la tabla tab_areas con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================

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

-- =============================================
-- Función: fun_insert_bancos
-- Descripción: Inserta un nuevo registro en la tabla tab_bancos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
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

-- =============================================
-- Función: fun_insert_cat_terceros
-- Descripción: Inserta un nuevo registro en la tabla tab_cat_terceros con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
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

-- =============================================
-- Función: fun_insert_ciudades
-- Descripción: Inserta un nuevo registro en la tabla tab_ciudades con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_ciudades(wid_ciudad      tab_ciudades.id_ciudad%TYPE,
                                               wnom_ciudad     tab_ciudades.nom_ciudad%TYPE,
                                               wid_dpto        tab_ciudades.id_dpto%TYPE,
                                               wind_capital    tab_ciudades.ind_capital%TYPE,
                                               wcod_postal     tab_ciudades.cod_postal%TYPE,
                                               wval_latitud    tab_ciudades.val_latitud%TYPE,
                                               wval_longitud   tab_ciudades.val_longitud%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wnom_ciudad IS NULL OR TRIM(wnom_ciudad) = '' THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede estar vacío';
    END IF;

    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL OR TRIM(wcod_postal) = '' THEN
        RAISE EXCEPTION 'El código postal no puede estar vacío';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID ciudad: exactamente 5 dígitos numéricos
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- Nombre ciudad: entre 3 y 30 caracteres, solo letras y espacios
    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios';
    END IF;

    -- ID departamento: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Código postal: exactamente 6 dígitos numéricos
    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de exactamente 6 dígitos (ej: 050001)';
    END IF;

    -- Latitud: entre -4 y 80
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    -- Longitud: entre -80 y -50
    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO Y EXISTENCIA FK
    -- =============================================

    -- Verificar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- Verificar duplicado de ciudad
    IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad) THEN
        RAISE EXCEPTION 'Ya existe una ciudad con el ID %', wid_ciudad;
    END IF;

    -- Solo puede haber una capital por departamento
    IF wind_capital = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_dpto = wid_dpto AND ind_capital = TRUE AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'El departamento % ya tiene una ciudad capital registrada', wid_dpto;
        END IF;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_ciudades (id_ciudad,nom_ciudad,id_dpto,ind_capital,cod_postal,val_latitud,val_longitud,ind_borrado) 
    VALUES (wid_ciudad,wnom_ciudad,wid_dpto,wind_capital,wcod_postal,wval_latitud,wval_longitud,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_dptos
-- Descripción: Inserta un nuevo registro en la tabla tab_dptos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_dptos(wid_dpto   tab_dptos.id_dpto%TYPE,
                                            wnom_dpto  tab_dptos.nom_dpto%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wnom_dpto IS NULL OR TRIM(wnom_dpto) = '' THEN
        RAISE EXCEPTION 'El nombre del departamento no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: exactamente 2 dígitos numéricos
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    -- Nombre: entre 4 y 20 caracteres
    IF LENGTH(TRIM(wnom_dpto)) < 4 OR LENGTH(TRIM(wnom_dpto)) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    -- Nombre: solo letras y espacios
    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto) THEN
        RAISE EXCEPTION 'Ya existe un departamento con el ID %', wid_dpto;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_dptos (id_dpto,nom_dpto) 
    VALUES (wid_dpto,wnom_dpto);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menu_palettes
-- Descripción: Inserta un nuevo registro en la tabla tab_menu_palettes con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_menu_palettes(wid_palette             tab_menu_palettes.id_palette%TYPE,
                                                    wnom_palette            tab_menu_palettes.nom_palette%TYPE,
                                                    wdes_palette            tab_menu_palettes.des_palette%TYPE,
                                                    wval_primary_color      tab_menu_palettes.val_primary_color%TYPE,
                                                    wval_secondary_color    tab_menu_palettes.val_secondary_color%TYPE,
                                                    wval_accent_color       tab_menu_palettes.val_accent_color%TYPE,
                                                    wval_text_color         tab_menu_palettes.val_text_color%TYPE,
                                                    wval_hover_color        tab_menu_palettes.val_hover_color%TYPE,
                                                    wval_sidebar_bg         tab_menu_palettes.val_sidebar_bg%TYPE,
                                                    wval_sidebar_text       tab_menu_palettes.val_sidebar_text%TYPE,
                                                    wval_sidebar_hover      tab_menu_palettes.val_sidebar_hover%TYPE,
                                                    wval_active_bg          tab_menu_palettes.val_active_bg%TYPE,
                                                    wnum_orden              tab_menu_palettes.num_orden%TYPE,
                                                    wind_active             tab_menu_palettes.ind_active%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;
    IF wnom_palette IS NULL OR TRIM(wnom_palette) = '' THEN
        RAISE EXCEPTION 'El nombre de la paleta no puede estar vacío';
    END IF;
    IF wval_primary_color IS NULL OR TRIM(wval_primary_color) = '' THEN
        RAISE EXCEPTION 'El color primario no puede estar vacío';
    END IF;
    IF wval_secondary_color IS NULL OR TRIM(wval_secondary_color) = '' THEN
        RAISE EXCEPTION 'El color secundario no puede estar vacío';
    END IF;
    IF wval_accent_color IS NULL OR TRIM(wval_accent_color) = '' THEN
        RAISE EXCEPTION 'El color de acento no puede estar vacío';
    END IF;
    IF wval_text_color IS NULL OR TRIM(wval_text_color) = '' THEN
        RAISE EXCEPTION 'El color del texto no puede estar vacío';
    END IF;
    IF wval_hover_color IS NULL OR TRIM(wval_hover_color) = '' THEN
        RAISE EXCEPTION 'El color hover no puede estar vacío';
    END IF;
    IF wval_sidebar_bg IS NULL OR TRIM(wval_sidebar_bg) = '' THEN
        RAISE EXCEPTION 'El fondo del sidebar no puede estar vacío';
    END IF;
    IF wval_sidebar_text IS NULL OR TRIM(wval_sidebar_text) = '' THEN
        RAISE EXCEPTION 'El color del texto del sidebar no puede estar vacío';
    END IF;
    IF wval_sidebar_hover IS NULL OR TRIM(wval_sidebar_hover) = '' THEN
        RAISE EXCEPTION 'El color hover del sidebar no puede estar vacío';
    END IF;
    IF wval_active_bg IS NULL OR TRIM(wval_active_bg) = '' THEN
        RAISE EXCEPTION 'El color del item activo no puede estar vacío';
    END IF;
    IF wnum_orden IS NULL THEN
        RAISE EXCEPTION 'El número de orden no puede ser nulo';
    END IF;
    IF wind_active IS NULL THEN
        RAISE EXCEPTION 'El indicador de paleta activa no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID paleta: entre 1 y 30 caracteres, alfanumérico y guion bajo
    IF LENGTH(wid_palette) < 1 OR LENGTH(wid_palette) > 30 THEN
        RAISE EXCEPTION 'El ID de la paleta debe tener entre 1 y 30 caracteres';
    END IF;
    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    -- Nombre paleta: entre 1 y 50 caracteres
    IF LENGTH(wnom_palette) < 1 OR LENGTH(wnom_palette) > 50 THEN
        RAISE EXCEPTION 'El nombre de la paleta debe tener entre 1 y 50 caracteres';
    END IF;

    -- Orden: mayor o igual a 0
    IF wnum_orden < 0 THEN
        RAISE EXCEPTION 'El número de orden no puede ser negativo';
    END IF;

    -- Colores: formato hexadecimal #RRGGBB exactamente 7 caracteres
    IF wval_primary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color primario debe tener formato hexadecimal válido (ej: #1a1a2e)';
    END IF;
    IF wval_secondary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color secundario debe tener formato hexadecimal válido (ej: #16213e)';
    END IF;
    IF wval_accent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color de acento debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;
    IF wval_text_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;
    IF wval_hover_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;
    IF wval_sidebar_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El fondo del sidebar debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;
    IF wval_sidebar_text !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto del sidebar debe tener formato hexadecimal válido (ej: #555555)';
    END IF;
    IF wval_sidebar_hover !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover del sidebar debe tener formato hexadecimal válido (ej: #f4f7ff)';
    END IF;
    IF wval_active_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del item activo debe tener formato hexadecimal válido (ej: #00aaff)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette) THEN
        RAISE EXCEPTION 'Ya existe una paleta con el ID %', wid_palette;
    END IF;

    -- Solo puede haber una paleta activa a la vez
    IF wind_active = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE ind_active = TRUE AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'Ya existe una paleta activa, desactívela antes de activar otra';
        END IF;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_menu_palettes (id_palette, nom_palette, des_palette,val_primary_color, val_secondary_color, val_accent_color,
                                   val_text_color, val_hover_color, val_sidebar_bg,val_sidebar_text, val_sidebar_hover, val_active_bg,
                                   num_orden, ind_active, ind_borrado) 
    VALUES (wid_palette, wnom_palette,COALESCE(NULLIF(TRIM(wdes_palette), ''), 'Sin descripción de la paleta'),wval_primary_color, 
            wval_secondary_color, wval_accent_color,wval_text_color, wval_hover_color, wval_sidebar_bg,wval_sidebar_text, wval_sidebar_hover, 
            wval_active_bg,wnum_orden, wind_active, FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menu_usuarios
-- Descripción: Inserta un nuevo registro en la tabla tab_menu_usuarios con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_menu_usuarios(p_id_usuario    tab_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_usuario IS NULL OR TRIM(p_id_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_id_usuario AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_id_usuario;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu   = p_id_menu AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El menú % no existe o está inactivo', p_id_menu;
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú % ya está asignado al usuario %', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
    VALUES (p_id_usuario, p_id_menu);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_menus
-- Descripción: Inserta un nuevo registro en la tabla tab_menus con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_tab_menus(p_id_menu       tab_menus.id_menu%TYPE,
                                                p_nom_menu      tab_menus.nom_menu%TYPE,
                                                p_id_padre      tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa  tab_menus.nom_programa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;
    IF p_nom_menu IS NULL OR TRIM(p_nom_menu) = '' THEN
        RAISE EXCEPTION 'El nombre del menú no puede estar vacío';
    END IF;
    IF p_id_padre IS NULL THEN
        RAISE EXCEPTION 'El ID del padre no puede ser nulo';
    END IF;

    IF LENGTH(p_nom_menu) < 3 OR LENGTH(p_nom_menu) > 100 THEN
        RAISE EXCEPTION 'El nombre del menú debe tener entre 3 y 100 caracteres (actual: %)', LENGTH(p_nom_menu);
    END IF;

    IF p_id_padre != '0' THEN
        IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_padre) THEN
            RAISE EXCEPTION 'El menú padre con ID % no existe o está inactivo', p_id_padre;
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'Ya existe un menú con el ID %', p_id_menu;
    END IF;

    INSERT INTO tab_menus (id_menu, nom_menu, ind_id_padre, nom_programa)
    VALUES (p_id_menu,p_nom_menu,p_id_padre,COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica'));

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_pmtos_grales
-- Descripción: Inserta un nuevo registro en la tabla tab_pmtos_grales con validaciones de campos obligatorios, formato, rango y duplicados.    
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_pmtros_grales(wid_empresa         tab_pmtros_grales.id_empresa%TYPE,
                                                    wnom_empresa        tab_pmtros_grales.nom_empresa%TYPE,
                                                    wnom_corto          VARCHAR,
                                                    wdireccion          VARCHAR,
                                                    wtel_fijo           DECIMAL,
                                                    wid_prefijo_movil   DECIMAL,
                                                    wtel_movil          DECIMAL,
                                                    wemail              VARCHAR,
                                                    wnom_replegal       tab_pmtros_grales.nom_replegal%TYPE,
                                                    wval_poriva         tab_pmtros_grales.val_poriva%TYPE,
                                                    wval_pordesc        tab_pmtros_grales.val_pordesc%TYPE,
                                                    wval_porrete        tab_pmtros_grales.val_porrete%TYPE,
                                                    wval_reteica        tab_pmtros_grales.val_reteica%TYPE,
                                                    wval_porutil        tab_pmtros_grales.val_porutil%TYPE,
                                                    wval_latitud        tab_pmtros_grales.val_latitud%TYPE,
                                                    wval_longitud       tab_pmtros_grales.val_longitud%TYPE,
                                                    wind_autorete       tab_pmtros_grales.ind_autorete%TYPE,
                                                    wriesgo_arl         tab_pmtros_grales.riesgo_arl%TYPE) RETURNS BOOLEAN AS
$$
DECLARE
    wanio_fiscal tab_pmtros_grales.anio_fiscal%TYPE;
    wmes_fiscal  tab_pmtros_grales.mes_fiscal%TYPE;
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    IF wnom_empresa IS NULL OR TRIM(wnom_empresa) = '' THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wnom_replegal IS NULL OR TRIM(wnom_replegal) = '' THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede estar vacío';
    END IF;

    IF wval_poriva IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de IVA no puede ser nulo';
    END IF;

    IF wval_pordesc IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de descuento no puede ser nulo';
    END IF;

    IF wval_porrete IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de retención no puede ser nulo';
    END IF;

    IF wval_reteica IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de reteica no puede ser nulo';
    END IF;

    IF wval_porutil IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de utilidad no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    IF wriesgo_arl IS NULL OR TRIM(wriesgo_arl) = '' THEN
        RAISE EXCEPTION 'El riesgo ARL no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID empresa: numérico de 8 a 10 dígitos
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    -- Nombre empresa: entre 5 y 60 caracteres
    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    -- Nombre representante legal: entre 5 y 60 caracteres, solo letras y espacios
    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
    END IF;

    IF wnom_replegal !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del representante legal solo debe contener letras y espacios';
    END IF;

    -- Porcentajes
    IF wval_poriva < 0 OR wval_poriva >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de IVA debe estar entre 0 y 99';
    END IF;

    IF wval_pordesc < 0 OR wval_pordesc >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de descuento debe estar entre 0 y 99';
    END IF;

    IF wval_porrete < 0 OR wval_porrete >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de retención debe estar entre 0 y 99';
    END IF;

    IF wval_reteica < 0 OR wval_reteica >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de reteica debe estar entre 0 y 99';
    END IF;

    IF wval_porutil < 0 OR wval_porutil > 100 THEN
        RAISE EXCEPTION 'El porcentaje de utilidad debe estar entre 0 y 100';
    END IF;

    -- Latitud y longitud
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- Riesgo ARL
    IF wriesgo_arl NOT IN ('1', '2', '3', '4', '5') THEN
        RAISE EXCEPTION 'El riesgo ARL debe ser 1 (0.522%%), 2 (1.044%%), 3 (2.436%%), 4 (4.350%%) o 5 (6.960%%)';
    END IF;

    -- Teléfono fijo (opcional)
    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Prefijo móvil y teléfono móvil: ambos obligatorios si se ingresa uno
    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Email
    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existe un registro para la empresa con ID %', wid_empresa;
    END IF;

    -- =============================================
    -- ASIGNACIÓN AUTOMÁTICA AÑO Y MES FISCAL
    -- =============================================
    wanio_fiscal := EXTRACT(YEAR  FROM CURRENT_DATE);
    wmes_fiscal  := EXTRACT(MONTH FROM CURRENT_DATE);

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_pmtros_grales (id_empresa,nom_empresa,datos_residencia,nom_replegal,val_poriva,val_pordesc,val_porrete,val_reteica,val_porutil,
                                    val_latitud,val_longitud,anio_fiscal,mes_fiscal,ind_autorete,riesgo_arl,ind_borrado) 
    VALUES (wid_empresa,wnom_empresa,ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,wnom_replegal,
            wval_poriva,wval_pordesc,wval_porrete,wval_reteica,wval_porutil,wval_latitud,wval_longitud,wanio_fiscal,wmes_fiscal,wind_autorete,wriesgo_arl,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_restricciones
-- Descripción: Inserta un nuevo registro en la tabla tab_restricciones con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_restricciones(wid_restriccion     tab_restricciones.id_restriccion%TYPE,
                                                    wnom_restriccion    tab_restricciones.nom_restriccion%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wnom_restriccion IS NULL OR TRIM(wnom_restriccion) = '' THEN
        RAISE EXCEPTION 'El nombre de la restricción no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 1 y 99
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres, solo letras y espacios
    IF LENGTH(wnom_restriccion) < 4 OR LENGTH(wnom_restriccion) > 50 THEN
        RAISE EXCEPTION 'El nombre de la restricción debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_restriccion !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la restricción solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'Ya existe una restricción con el ID %', wid_restriccion;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_restricciones (id_restriccion,nom_restriccion) 
    VALUES (wid_restriccion,wnom_restriccion);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_tel_prefijos
-- Descripción: Inserta un nuevo registro en la tabla tab_tel_prefijos con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
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

-- =============================================
-- Función: fun_insert_terceros
-- Descripción: Inserta un nuevo registro en la tabla tab_terceros con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_terceros(wid_tipo            tab_terceros.id_tipo%TYPE,
                                               wid_tercero         tab_terceros.id_tercero%TYPE,
                                               wind_tipo_tercero   tab_terceros.ind_tipo_tercero%TYPE,
                                               wid_cat_tercero     tab_terceros.id_cat_tercero%TYPE,
                                               wnom_tercero        tab_terceros.nom_tercero%TYPE,
                                               wnom_corto          VARCHAR,
                                               wdireccion          VARCHAR,
                                               wtel_fijo           DECIMAL,
                                               wid_prefijo_movil   DECIMAL,
                                               wtel_movil          DECIMAL,
                                               wemail              VARCHAR,
                                               wid_ciudad          tab_terceros.id_ciudad%TYPE,
                                               wid_restriccion     tab_terceros.id_restriccion%TYPE,
                                               wind_estado         tab_terceros.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El tipo de documento no puede estar vacío';
    END IF;

    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    IF wind_tipo_tercero IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de tercero no puede ser nulo';
    END IF;

    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_tercero IS NULL OR TRIM(wnom_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre del tercero no puede estar vacío';
    END IF;

    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- DATOS_UBICACION: solo email y dirección son obligatorios
    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- Tipo documento
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El tipo de documento debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    -- ID tercero: entre 7 y 10 caracteres alfanuméricos mayúsculas
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    -- Categoría: entre 1 y 99
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    -- Nombre: entre 4 y 50 caracteres
    IF LENGTH(wnom_tercero) < 4 OR LENGTH(wnom_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre del tercero debe tener entre 4 y 50 caracteres';
    END IF;

    -- Restricción: entre 1 y 99
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    -- Teléfono fijo: entre 7 y 10 dígitos (opcional)
    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Prefijo móvil y teléfono móvil: ambos obligatorios si se ingresa uno
    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    -- Email: formato básico
    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO Y EXISTENCIA FK
    -- =============================================

    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de documento % no existe', wid_tipo;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo_movil) THEN
        RAISE EXCEPTION 'El prefijo móvil % no existe', wid_prefijo_movil;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero) THEN
        RAISE EXCEPTION 'Ya existe un tercero con el ID %', wid_tercero;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_terceros (id_tipo,id_tercero,ind_tipo_tercero,id_cat_tercero,nom_tercero,dir_tercero,id_ciudad,id_restriccion,ind_estado,ind_borrado) 
    VALUES (wid_tipo,wid_tercero,wind_tipo_tercero,wid_cat_tercero,wnom_tercero,ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
            wid_ciudad,wid_restriccion,wind_estado,FALSE);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_usuarios 
-- Descripción: Inserta un nuevo registro en la tabla tab_usuarios con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================    
CREATE OR REPLACE FUNCTION fun_insert_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                               wnom_usuario    tab_usuarios.nom_usuario%TYPE,
                                               wpass_usuario   tab_usuarios.pass_usuario%TYPE,
                                               wmail_usuario   tab_usuarios.mail_usuario%TYPE,
                                               wind_usuario    tab_usuarios.ind_usuario%TYPE,
                                               wind_estado     tab_usuarios.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF wnom_usuario IS NULL OR TRIM(wnom_usuario) = '' THEN
        RAISE EXCEPTION 'El nombre de usuario no puede estar vacío';
    END IF;
    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RAISE EXCEPTION 'La contraseña no puede estar vacía';
    END IF;
    IF wmail_usuario IS NULL OR TRIM(wmail_usuario) = '' THEN
        RAISE EXCEPTION 'El correo electrónico no puede estar vacío';
    END IF;
    IF wind_usuario IS NULL THEN
        RAISE EXCEPTION 'El indicador de administrador no puede ser nulo';
    END IF;
    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================

    -- ID usuario: mínimo 5 caracteres, sin espacios ni caracteres especiales
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;
    IF wid_usuario ~ '\s' THEN
        RAISE EXCEPTION 'El ID de usuario no puede contener espacios';
    END IF;
    IF wid_usuario ~ '[*"]' THEN
        RAISE EXCEPTION 'El ID de usuario contiene caracteres no permitidos (* o ")';
    END IF;

    -- Nombre completo: mínimo 8 caracteres
    IF LENGTH(wnom_usuario) < 8 THEN
        RAISE EXCEPTION 'El nombre completo debe tener mínimo 8 caracteres';
    END IF;

    -- Correo electrónico
    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico no tiene un formato válido';
    END IF;

    -- Contraseña: mínimo 12 caracteres, sin espacios,
    -- al menos 1 mayúscula, 1 minúscula, 1 número y 1 símbolo
    IF LENGTH(wpass_usuario) < 12 THEN
        RAISE EXCEPTION 'La contraseña debe tener mínimo 12 caracteres';
    END IF;
    IF wpass_usuario ~ '\s' THEN
        RAISE EXCEPTION 'La contraseña no puede contener espacios';
    END IF;
    IF wpass_usuario !~ '[A-Z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra mayúscula';
    END IF;
    IF wpass_usuario !~ '[a-z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra minúscula';
    END IF;
    IF wpass_usuario !~ '[0-9]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un número';
    END IF;
    IF wpass_usuario !~ '[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/\\~`''""]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un símbolo especial (!@#$%% etc.)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario) THEN
        RAISE EXCEPTION 'Ya existe un usuario con el ID %', wid_usuario;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE mail_usuario = wmail_usuario) THEN
        RAISE EXCEPTION 'Ya existe un usuario registrado con el correo %', wmail_usuario;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_usuarios (id_usuario, nom_usuario, pass_usuario, mail_usuario, ind_usuario, ind_estado, ind_borrado) 
    VALUES (wid_usuario, wnom_usuario, wpass_usuario, wmail_usuario, wind_usuario, wind_estado, FALSE);
    
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_registrar_sesion
-- Descripción: Inserta un nuevo registro en la tabla tab_registrar_sesion con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_registrar_sesion(p_user  tab_sesiones.id_usuario%TYPE,
                                                p_token tab_sesiones.token_sesion%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_user IS NULL OR TRIM(p_user) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;
    IF p_token IS NULL OR TRIM(p_token) = '' THEN
        RAISE EXCEPTION 'El token de sesión no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(p_user) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;
    IF LENGTH(p_token) < 10 THEN
        RAISE EXCEPTION 'El token de sesión debe tener mínimo 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDAR QUE EL USUARIO EXISTE Y ESTÁ ACTIVO
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_user AND ind_estado  = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario % no existe o está inactivo', p_user;
    END IF;

    -- =============================================
    -- INSERT / UPDATE (lógica original intacta)
    -- =============================================
    INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio, ult_actividad)
    VALUES (p_user, p_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario)
    DO UPDATE SET
        token_sesion  = EXCLUDED.token_sesion,
        ult_actividad = CURRENT_TIMESTAMP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

-- =============================================
-- Función: fun_insert_tipo_identidad
-- Descripción: Inserta un nuevo registro en la tabla tab_tipo_identidad con validaciones de campos obligatorios, formato, rango y duplicados.
-- =============================================
CREATE OR REPLACE FUNCTION fun_insert_tipo_identidad(wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
                                                     wnom_tipo   tab_tipo_identidad.nom_tipo%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad no puede estar vacío';
    END IF;

    IF wnom_tipo IS NULL OR TRIM(wnom_tipo) = '' THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================

    -- ID: entre 2 y 5 letras mayúsculas
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    -- Nombre: entre 5 y 50 caracteres
    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE DUPLICADO
    -- =============================================
    IF EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'Ya existe un tipo de identidad con el ID %', wid_tipo;
    END IF;

    -- =============================================
    -- INSERCIÓN
    -- =============================================
    INSERT INTO tab_tipo_identidad (id_tipo,nom_tipo
    ) VALUES (wid_tipo,wnom_tipo);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_delete_areas(wid_area    tab_areas.id_area%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_area IS NULL THEN
        RAISE EXCEPTION 'El ID del área no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El área con ID % no existe o ya fue eliminada', wid_area;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_areas SET ind_borrado = TRUE
    WHERE id_area = wid_area;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_bancos(wid_banco   tab_bancos.id_banco%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_banco IS NULL OR TRIM(wid_banco) = '' THEN
        RAISE EXCEPTION 'El ID del banco no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o ya fue eliminado', wid_banco;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_bancos SET ind_borrado = TRUE
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_delete_ciudades(wid_ciudad  tab_ciudades.id_ciudad%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o ya fue eliminada', wid_ciudad;
    END IF;

    -- Verificar que no esté referenciada en terceros
    IF EXISTS (SELECT 1 FROM tab_terceros WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'No se puede eliminar la ciudad % porque está referenciada en terceros activos', wid_ciudad;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_ciudades SET ind_borrado = TRUE
    WHERE id_ciudad = wid_ciudad;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_menu_palettes(wid_palette     tab_menu_palettes.id_palette%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe o ya fue eliminada', wid_palette;
    END IF;

    -- No se puede eliminar la paleta activa
    IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_active = TRUE) THEN
        RAISE EXCEPTION 'No se puede eliminar la paleta % porque está activa, desactívela primero', wid_palette;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_menu_palettes SET ind_borrado = TRUE
    WHERE id_palette = wid_palette;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_menu_usuarios(p_id_usuario    tab_menu_usuarios.id_usuario%TYPE,
                                                    p_id_menu       tab_menu_usuarios.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_usuario IS NULL OR TRIM(p_id_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_usuario = p_id_usuario AND id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'La asignación del menú % al usuario % no existe', p_id_menu, p_id_usuario;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menu_usuarios
    WHERE id_usuario = p_id_usuario AND id_menu    = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_delete_pmtros_grales(wid_empresa     tab_pmtros_grales.id_empresa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con ID % no existe o ya fue eliminada', wid_empresa;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_pmtros_grales SET ind_borrado = TRUE
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_tab_menus(p_id_menu   tab_menus.id_menu%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú con ID % no existe', p_id_menu;
    END IF;

    -- Verificar que no tenga submenús activos
    IF EXISTS (SELECT 1 FROM tab_menus WHERE ind_id_padre = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque tiene submenús asociados', p_id_menu;
    END IF;

    -- Verificar que no esté asignado a usuarios
    IF EXISTS (SELECT 1 FROM tab_menu_usuarios WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'No se puede eliminar el menú % porque está asignado a uno o más usuarios', p_id_menu;
    END IF;

    -- =============================================
    -- DELETE FÍSICO
    -- =============================================
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_terceros(wid_tercero     tab_terceros.id_tercero%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El tercero con ID % no existe o ya fue eliminado', wid_tercero;
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_terceros SET ind_borrado = TRUE
    WHERE id_tercero = wid_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fun_delete_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o ya fue eliminado', wid_usuario;
    END IF;

    -- Verificar que no sea el único administrador activo
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE ind_usuario = TRUE AND ind_borrado  = FALSE AND id_usuario  <> wid_usuario) THEN
        RAISE EXCEPTION 'No se puede eliminar el único administrador activo del sistema';
    END IF;

    -- =============================================
    -- BORRADO LÓGICO
    -- =============================================
    UPDATE tab_usuarios SET ind_borrado = TRUE,
                            ind_estado  = FALSE
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_areas(wid_area            tab_areas.id_area%TYPE,
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
    IF wid_area <= 0 THEN
        RAISE EXCEPTION 'El ID del área debe ser mayor a 0';
    END IF;

    IF LENGTH(wid_responsable) < 5 THEN
        RAISE EXCEPTION 'El ID del responsable debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wnom_area) < 3 THEN
        RAISE EXCEPTION 'El nombre del área debe tener mínimo 3 caracteres';
    END IF;

    IF wmail_area !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$' THEN
        RAISE EXCEPTION 'El email del área no tiene un formato válido';
    END IF;

    IF wtel_oficina < 0 OR wtel_oficina >= 9999999999 THEN
        RAISE EXCEPTION 'El teléfono debe estar entre 0 y 9999999999';
    END IF;

    IF LENGTH(wubi_oficina) < 3 THEN
        RAISE EXCEPTION 'La ubicación de la oficina debe tener mínimo 3 caracteres';
    END IF;

    IF LENGTH(whorario_atencion) < 3 THEN
        RAISE EXCEPTION 'El horario de atención debe tener mínimo 3 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_areas WHERE id_area = wid_area AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El área con ID % no existe o está inactiva', wid_area;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_responsable AND ind_estado = TRUE AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El responsable % no existe o está inactivo', wid_responsable;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_areas SET id_responsable   = wid_responsable,
                         nom_area         = wnom_area,
                         descrip_area     = COALESCE(NULLIF(TRIM(wdescrip_area), ''), 'Sin descripción de área'),
                         mail_area        = wmail_area,
                         tel_oficina      = wtel_oficina,
                         ubi_oficina      = wubi_oficina,
                         horario_atencion = whorario_atencion,
                         ind_estado       = wind_estado
    WHERE id_area = wid_area;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_bancos(wid_banco       tab_bancos.id_banco%TYPE,
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
    IF LENGTH(wid_banco) < 6 OR LENGTH(wid_banco) > 10 THEN
        RAISE EXCEPTION 'El ID del banco debe tener entre 6 y 10 caracteres';
    END IF;

    IF LENGTH(wnom_banco) < 4 OR LENGTH(wnom_banco) > 50 THEN
        RAISE EXCEPTION 'El nombre del banco debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_bancos WHERE id_banco = wid_banco AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El banco con ID % no existe o está inactivo', wid_banco;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_bancos SET nom_banco  = wnom_banco,
                          ind_estado = wind_estado
    WHERE id_banco = wid_banco;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_cat_terceros(wid_cat_tercero     tab_cat_terceros.id_cat_tercero%TYPE,
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
    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_cat_tercero) < 4 OR LENGTH(wnom_cat_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre de la categoría debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_cat_tercero !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la categoría solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_cat_terceros SET nom_cat_tercero = wnom_cat_tercero
    WHERE id_cat_tercero = wid_cat_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_ciudades(wid_ciudad      tab_ciudades.id_ciudad%TYPE,
                                               wnom_ciudad     tab_ciudades.nom_ciudad%TYPE,
                                               wid_dpto        tab_ciudades.id_dpto%TYPE,
                                               wind_capital    tab_ciudades.ind_capital%TYPE,
                                               wcod_postal     tab_ciudades.cod_postal%TYPE,
                                               wval_latitud    tab_ciudades.val_latitud%TYPE,
                                               wval_longitud   tab_ciudades.val_longitud%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wnom_ciudad IS NULL OR TRIM(wnom_ciudad) = '' THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede estar vacío';
    END IF;

    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL OR TRIM(wcod_postal) = '' THEN
        RAISE EXCEPTION 'El código postal no puede estar vacío';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de exactamente 5 dígitos (ej: 05001)';
    END IF;

    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios';
    END IF;

    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de exactamente 6 dígitos (ej: 050001)';
    END IF;

    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- Solo puede haber una capital por departamento (excluyendo la ciudad actual)
    IF wind_capital = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_ciudades WHERE id_dpto = wid_dpto AND ind_capital = TRUE AND ind_borrado = FALSE AND id_ciudad <> wid_ciudad) THEN
            RAISE EXCEPTION 'El departamento % ya tiene una ciudad capital registrada', wid_dpto;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_ciudades SET nom_ciudad  = wnom_ciudad,
                            id_dpto     = wid_dpto,
                            ind_capital = wind_capital,
                            cod_postal  = wcod_postal,
                            val_latitud = wval_latitud,
                            val_longitud = wval_longitud
    WHERE id_ciudad = wid_ciudad;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_dptos(wid_dpto    tab_dptos.id_dpto%TYPE,
                                            wnom_dpto   tab_dptos.nom_dpto%TYPE) RETURNS BOOLEAN AS
$$
BEGIN
    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_dpto IS NULL OR TRIM(wid_dpto) = '' THEN
        RAISE EXCEPTION 'El ID del departamento no puede estar vacío';
    END IF;

    IF wnom_dpto IS NULL OR TRIM(wnom_dpto) = '' THEN
        RAISE EXCEPTION 'El nombre del departamento no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de exactamente 2 dígitos (ej: 05)';
    END IF;

    IF LENGTH(wnom_dpto) < 4 OR LENGTH(wnom_dpto) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_dptos WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe o está inactivo', wid_dpto;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_dptos SET nom_dpto = wnom_dpto
    WHERE id_dpto = wid_dpto;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_menu_palettes(wid_palette             tab_menu_palettes.id_palette%TYPE,
                                                    wnom_palette            tab_menu_palettes.nom_palette%TYPE,
                                                    wdes_palette            tab_menu_palettes.des_palette%TYPE,
                                                    wval_primary_color      tab_menu_palettes.val_primary_color%TYPE,
                                                    wval_secondary_color    tab_menu_palettes.val_secondary_color%TYPE,
                                                    wval_accent_color       tab_menu_palettes.val_accent_color%TYPE,
                                                    wval_text_color         tab_menu_palettes.val_text_color%TYPE,
                                                    wval_hover_color        tab_menu_palettes.val_hover_color%TYPE,
                                                    wval_sidebar_bg         tab_menu_palettes.val_sidebar_bg%TYPE,
                                                    wval_sidebar_text       tab_menu_palettes.val_sidebar_text%TYPE,
                                                    wval_sidebar_hover      tab_menu_palettes.val_sidebar_hover%TYPE,
                                                    wval_active_bg          tab_menu_palettes.val_active_bg%TYPE,
                                                    wnum_orden              tab_menu_palettes.num_orden%TYPE,
                                                    wind_active             tab_menu_palettes.ind_active%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_palette IS NULL OR TRIM(wid_palette) = '' THEN
        RAISE EXCEPTION 'El ID de la paleta no puede estar vacío';
    END IF;

    IF wnom_palette IS NULL OR TRIM(wnom_palette) = '' THEN
        RAISE EXCEPTION 'El nombre de la paleta no puede estar vacío';
    END IF;

    IF wval_primary_color IS NULL OR TRIM(wval_primary_color) = '' THEN
        RAISE EXCEPTION 'El color primario no puede estar vacío';
    END IF;

    IF wval_secondary_color IS NULL OR TRIM(wval_secondary_color) = '' THEN
        RAISE EXCEPTION 'El color secundario no puede estar vacío';
    END IF;

    IF wval_accent_color IS NULL OR TRIM(wval_accent_color) = '' THEN
        RAISE EXCEPTION 'El color de acento no puede estar vacío';
    END IF;

    IF wval_text_color IS NULL OR TRIM(wval_text_color) = '' THEN
        RAISE EXCEPTION 'El color del texto no puede estar vacío';
    END IF;

    IF wval_hover_color IS NULL OR TRIM(wval_hover_color) = '' THEN
        RAISE EXCEPTION 'El color hover no puede estar vacío';
    END IF;

    IF wval_sidebar_bg IS NULL OR TRIM(wval_sidebar_bg) = '' THEN
        RAISE EXCEPTION 'El fondo del sidebar no puede estar vacío';
    END IF;

    IF wval_sidebar_text IS NULL OR TRIM(wval_sidebar_text) = '' THEN
        RAISE EXCEPTION 'El color del texto del sidebar no puede estar vacío';
    END IF;

    IF wval_sidebar_hover IS NULL OR TRIM(wval_sidebar_hover) = '' THEN
        RAISE EXCEPTION 'El color hover del sidebar no puede estar vacío';
    END IF;

    IF wval_active_bg IS NULL OR TRIM(wval_active_bg) = '' THEN
        RAISE EXCEPTION 'El color del item activo no puede estar vacío';
    END IF;

    IF wnum_orden IS NULL THEN
        RAISE EXCEPTION 'El número de orden no puede ser nulo';
    END IF;

    IF wind_active IS NULL THEN
        RAISE EXCEPTION 'El indicador de paleta activa no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_palette) < 1 OR LENGTH(wid_palette) > 30 THEN
        RAISE EXCEPTION 'El ID de la paleta debe tener entre 1 y 30 caracteres';
    END IF;

    IF wid_palette !~ '^[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'El ID de la paleta solo puede contener letras minúsculas, números y guion bajo (ej: blue_pro)';
    END IF;

    IF LENGTH(wnom_palette) < 1 OR LENGTH(wnom_palette) > 50 THEN
        RAISE EXCEPTION 'El nombre de la paleta debe tener entre 1 y 50 caracteres';
    END IF;

    IF wnum_orden < 0 THEN
        RAISE EXCEPTION 'El número de orden no puede ser negativo';
    END IF;

    IF wval_primary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color primario debe tener formato hexadecimal válido (ej: #1a1a2e)';
    END IF;

    IF wval_secondary_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color secundario debe tener formato hexadecimal válido (ej: #16213e)';
    END IF;

    IF wval_accent_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color de acento debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;

    IF wval_text_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;

    IF wval_hover_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover debe tener formato hexadecimal válido (ej: #00d9ff)';
    END IF;

    IF wval_sidebar_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El fondo del sidebar debe tener formato hexadecimal válido (ej: #ffffff)';
    END IF;

    IF wval_sidebar_text !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del texto del sidebar debe tener formato hexadecimal válido (ej: #555555)';
    END IF;

    IF wval_sidebar_hover !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color hover del sidebar debe tener formato hexadecimal válido (ej: #f4f7ff)';
    END IF;

    IF wval_active_bg !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION 'El color del item activo debe tener formato hexadecimal válido (ej: #00aaff)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menu_palettes WHERE id_palette = wid_palette AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La paleta con ID % no existe o está inactiva', wid_palette;
    END IF;

    -- Solo puede haber una paleta activa a la vez (excluyendo la actual)
    IF wind_active = TRUE THEN
        IF EXISTS (SELECT 1 FROM tab_menu_palettes WHERE ind_active = TRUE AND ind_borrado = FALSE AND id_palette <> wid_palette) THEN
            RAISE EXCEPTION 'Ya existe una paleta activa, desactívela antes de activar otra';
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_menu_palettes SET nom_palette         = wnom_palette,
                                 des_palette         = COALESCE(NULLIF(TRIM(wdes_palette), ''), 'Sin descripción de la paleta'),
                                 val_primary_color   = wval_primary_color,
                                 val_secondary_color = wval_secondary_color,
                                 val_accent_color    = wval_accent_color,
                                 val_text_color      = wval_text_color,
                                 val_hover_color     = wval_hover_color,
                                 val_sidebar_bg      = wval_sidebar_bg,
                                 val_sidebar_text    = wval_sidebar_text,
                                 val_sidebar_hover   = wval_sidebar_hover,
                                 val_active_bg       = wval_active_bg,
                                 num_orden           = wnum_orden,
                                 ind_active          = wind_active
    WHERE id_palette = wid_palette;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_password(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                               wpass_usuario   tab_usuarios.pass_usuario%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RAISE EXCEPTION 'La contraseña no puede estar vacía';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wpass_usuario) < 12 THEN
        RAISE EXCEPTION 'La contraseña debe tener mínimo 12 caracteres';
    END IF;

    IF wpass_usuario ~ '\s' THEN
        RAISE EXCEPTION 'La contraseña no puede contener espacios';
    END IF;

    IF wpass_usuario !~ '[A-Z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra mayúscula';
    END IF;

    IF wpass_usuario !~ '[a-z]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos una letra minúscula';
    END IF;

    IF wpass_usuario !~ '[0-9]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un número';
    END IF;

    IF wpass_usuario !~ '[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/\\~`''""]' THEN
        RAISE EXCEPTION 'La contraseña debe contener al menos un símbolo especial (!@#$%% etc.)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o está inactivo', wid_usuario;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_usuarios SET pass_usuario = wpass_usuario
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_pmtros_grales(wid_empresa         tab_pmtros_grales.id_empresa%TYPE,
                                                    wnom_empresa        tab_pmtros_grales.nom_empresa%TYPE,
                                                    wnom_corto          VARCHAR,
                                                    wdireccion          VARCHAR,
                                                    wtel_fijo           DECIMAL,
                                                    wid_prefijo_movil   DECIMAL,
                                                    wtel_movil          DECIMAL,
                                                    wemail              VARCHAR,
                                                    wnom_replegal       tab_pmtros_grales.nom_replegal%TYPE,
                                                    wval_poriva         tab_pmtros_grales.val_poriva%TYPE,
                                                    wval_pordesc        tab_pmtros_grales.val_pordesc%TYPE,
                                                    wval_porrete        tab_pmtros_grales.val_porrete%TYPE,
                                                    wval_reteica        tab_pmtros_grales.val_reteica%TYPE,
                                                    wval_porutil        tab_pmtros_grales.val_porutil%TYPE,
                                                    wval_latitud        tab_pmtros_grales.val_latitud%TYPE,
                                                    wval_longitud       tab_pmtros_grales.val_longitud%TYPE,
                                                    wind_autorete       tab_pmtros_grales.ind_autorete%TYPE,
                                                    wriesgo_arl         tab_pmtros_grales.riesgo_arl%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_empresa IS NULL OR TRIM(wid_empresa) = '' THEN
        RAISE EXCEPTION 'El ID de la empresa no puede estar vacío';
    END IF;

    IF wnom_empresa IS NULL OR TRIM(wnom_empresa) = '' THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wnom_replegal IS NULL OR TRIM(wnom_replegal) = '' THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede estar vacío';
    END IF;

    IF wval_poriva IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de IVA no puede ser nulo';
    END IF;

    IF wval_pordesc IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de descuento no puede ser nulo';
    END IF;

    IF wval_porrete IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de retención no puede ser nulo';
    END IF;

    IF wval_reteica IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de reteica no puede ser nulo';
    END IF;

    IF wval_porutil IS NULL THEN
        RAISE EXCEPTION 'El porcentaje de utilidad no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'La latitud no puede ser nula';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'La longitud no puede ser nula';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    IF wriesgo_arl IS NULL OR TRIM(wriesgo_arl) = '' THEN
        RAISE EXCEPTION 'El riesgo ARL no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_empresa !~ '^[1-9][0-9]{7,9}$' THEN
        RAISE EXCEPTION 'El ID de la empresa debe ser numérico entre 8 y 10 dígitos';
    END IF;

    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
    END IF;

    IF wnom_replegal !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del representante legal solo debe contener letras y espacios';
    END IF;

    IF wval_poriva < 0 OR wval_poriva >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de IVA debe estar entre 0 y 99';
    END IF;

    IF wval_pordesc < 0 OR wval_pordesc >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de descuento debe estar entre 0 y 99';
    END IF;

    IF wval_porrete < 0 OR wval_porrete >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de retención debe estar entre 0 y 99';
    END IF;

    IF wval_reteica < 0 OR wval_reteica >= 100 THEN
        RAISE EXCEPTION 'El porcentaje de reteica debe estar entre 0 y 99';
    END IF;

    IF wval_porutil < 0 OR wval_porutil > 100 THEN
        RAISE EXCEPTION 'El porcentaje de utilidad debe estar entre 0 y 100';
    END IF;

    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'La latitud debe estar entre -4 y 80';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'La longitud debe estar entre -80 y -50';
    END IF;

    IF wriesgo_arl NOT IN ('1', '2', '3', '4', '5') THEN
        RAISE EXCEPTION 'El riesgo ARL debe ser 1 (0.522%%), 2 (1.044%%), 3 (2.436%%), 4 (4.350%%) o 5 (6.960%%)';
    END IF;

    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con ID % no existe o está inactiva', wid_empresa;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN (anio_fiscal y mes_fiscal no se tocan)
    -- =============================================
    UPDATE tab_pmtros_grales SET nom_empresa      = wnom_empresa,
                                 datos_residencia = ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
                                 nom_replegal     = wnom_replegal,
                                 val_poriva       = wval_poriva,
                                 val_pordesc      = wval_pordesc,
                                 val_porrete      = wval_porrete,
                                 val_reteica      = wval_reteica,
                                 val_porutil      = wval_porutil,
                                 val_latitud      = wval_latitud,
                                 val_longitud     = wval_longitud,
                                 ind_autorete     = wind_autorete,
                                 riesgo_arl       = wriesgo_arl
    WHERE id_empresa = wid_empresa;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_restricciones(
    wid_restriccion     tab_restricciones.id_restriccion%TYPE,
    wnom_restriccion    tab_restricciones.nom_restriccion%TYPE
) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wnom_restriccion IS NULL OR TRIM(wnom_restriccion) = '' THEN
        RAISE EXCEPTION 'El nombre de la restricción no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_restriccion) < 4 OR LENGTH(wnom_restriccion) > 50 THEN
        RAISE EXCEPTION 'El nombre de la restricción debe tener entre 4 y 50 caracteres';
    END IF;

    IF wnom_restriccion !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la restricción solo debe contener letras y espacios';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_restricciones SET nom_restriccion = wnom_restriccion
    WHERE id_restriccion = wid_restriccion;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tab_menus(p_id_menu       tab_menus.id_menu%TYPE,
                                                p_nom_menu      tab_menus.nom_menu%TYPE,
                                                p_id_padre      tab_menus.ind_id_padre%TYPE,
                                                p_nom_programa  tab_menus.nom_programa%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF p_id_menu IS NULL OR TRIM(p_id_menu) = '' THEN
        RAISE EXCEPTION 'El ID del menú no puede estar vacío';
    END IF;

    IF p_nom_menu IS NULL OR TRIM(p_nom_menu) = '' THEN
        RAISE EXCEPTION 'El nombre del menú no puede estar vacío';
    END IF;

    IF p_id_padre IS NULL THEN
        RAISE EXCEPTION 'El ID del padre no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(p_nom_menu) < 3 OR LENGTH(p_nom_menu) > 100 THEN
        RAISE EXCEPTION 'El nombre del menú debe tener entre 3 y 100 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El menú con ID % no existe o está inactivo', p_id_menu;
    END IF;

    IF p_id_padre <> '0' THEN
        IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_padre AND ind_borrado = FALSE) THEN
            RAISE EXCEPTION 'El menú padre con ID % no existe o está inactivo', p_id_padre;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_menus SET nom_menu     = p_nom_menu,
                         ind_id_padre = p_id_padre,
                         nom_programa = COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica')
    WHERE id_menu = p_id_menu;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tel_prefijo(wid_prefijo     tab_tel_prefijo.id_prefijo%TYPE,
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
    IF wid_prefijo <= 0 OR wid_prefijo > 9999 THEN
        RAISE EXCEPTION 'El ID del prefijo debe estar entre 1 y 9999';
    END IF;

    IF LENGTH(wnom_pais) < 4 OR LENGTH(wnom_pais) > 50 THEN
        RAISE EXCEPTION 'El nombre del país debe tener entre 4 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo) THEN
        RAISE EXCEPTION 'El prefijo con ID % no existe', wid_prefijo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tel_prefijo SET nom_pais = wnom_pais
    WHERE id_prefijo = wid_prefijo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_terceros(wid_tercero         tab_terceros.id_tercero%TYPE,
                                               wind_tipo_tercero   tab_terceros.ind_tipo_tercero%TYPE,
                                               wid_cat_tercero     tab_terceros.id_cat_tercero%TYPE,
                                               wnom_tercero        tab_terceros.nom_tercero%TYPE,
                                               wnom_corto          VARCHAR,
                                               wdireccion          VARCHAR,
                                               wtel_fijo           DECIMAL,
                                               wid_prefijo_movil   DECIMAL,
                                               wtel_movil          DECIMAL,
                                               wemail              VARCHAR,
                                               wid_ciudad          tab_terceros.id_ciudad%TYPE,
                                               wid_restriccion     tab_terceros.id_restriccion%TYPE,
                                               wind_estado         tab_terceros.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tercero IS NULL OR TRIM(wid_tercero) = '' THEN
        RAISE EXCEPTION 'El ID del tercero no puede estar vacío';
    END IF;

    IF wind_tipo_tercero IS NULL THEN
        RAISE EXCEPTION 'El indicador de tipo de tercero no puede ser nulo';
    END IF;

    IF wid_cat_tercero IS NULL THEN
        RAISE EXCEPTION 'El ID de la categoría no puede ser nulo';
    END IF;

    IF wnom_tercero IS NULL OR TRIM(wnom_tercero) = '' THEN
        RAISE EXCEPTION 'El nombre del tercero no puede estar vacío';
    END IF;

    IF wdireccion IS NULL OR TRIM(wdireccion) = '' THEN
        RAISE EXCEPTION 'La dirección no puede estar vacía';
    END IF;

    IF wemail IS NULL OR TRIM(wemail) = '' THEN
        RAISE EXCEPTION 'El email no puede estar vacío';
    END IF;

    IF wid_ciudad IS NULL OR TRIM(wid_ciudad) = '' THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede estar vacío';
    END IF;

    IF wid_restriccion IS NULL THEN
        RAISE EXCEPTION 'El ID de la restricción no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tercero !~ '^[A-Z0-9]{7,10}$' THEN
        RAISE EXCEPTION 'El ID del tercero debe tener entre 7 y 10 caracteres';
    END IF;

    IF wid_cat_tercero <= 0 OR wid_cat_tercero > 99 THEN
        RAISE EXCEPTION 'El ID de la categoría debe estar entre 1 y 99';
    END IF;

    IF LENGTH(wnom_tercero) < 4 OR LENGTH(wnom_tercero) > 50 THEN
        RAISE EXCEPTION 'El nombre del tercero debe tener entre 4 y 50 caracteres';
    END IF;

    IF wid_restriccion <= 0 OR wid_restriccion > 99 THEN
        RAISE EXCEPTION 'El ID de la restricción debe estar entre 1 y 99';
    END IF;

    IF wtel_fijo IS NOT NULL THEN
        IF wtel_fijo <= 0 OR LENGTH(wtel_fijo::TEXT) < 7 OR LENGTH(wtel_fijo::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono fijo debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wid_prefijo_movil IS NOT NULL AND wtel_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el prefijo móvil debe ingresar también el teléfono móvil';
    END IF;

    IF wtel_movil IS NOT NULL AND wid_prefijo_movil IS NULL THEN
        RAISE EXCEPTION 'Si ingresa el teléfono móvil debe ingresar también el prefijo móvil';
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF wid_prefijo_movil <= 0 OR wid_prefijo_movil > 9999 THEN
            RAISE EXCEPTION 'El prefijo móvil debe estar entre 1 y 9999';
        END IF;
    END IF;

    IF wtel_movil IS NOT NULL THEN
        IF LENGTH(wtel_movil::TEXT) < 7 OR LENGTH(wtel_movil::TEXT) > 10 THEN
            RAISE EXCEPTION 'El teléfono móvil debe tener entre 7 y 10 dígitos';
        END IF;
    END IF;

    IF wemail !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El email no tiene un formato válido (ej: usuario@dominio.com)';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_terceros WHERE id_tercero = wid_tercero AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El tercero con ID % no existe o está inactivo', wid_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_cat_terceros WHERE id_cat_tercero = wid_cat_tercero) THEN
        RAISE EXCEPTION 'La categoría con ID % no existe', wid_cat_tercero;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_ciudades WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con ID % no existe o está inactiva', wid_ciudad;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tab_restricciones WHERE id_restriccion = wid_restriccion) THEN
        RAISE EXCEPTION 'La restricción con ID % no existe', wid_restriccion;
    END IF;

    IF wid_prefijo_movil IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tab_tel_prefijo WHERE id_prefijo = wid_prefijo_movil) THEN
            RAISE EXCEPTION 'El prefijo móvil % no existe', wid_prefijo_movil;
        END IF;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_terceros SET ind_tipo_tercero = wind_tipo_tercero,
                            id_cat_tercero   = wid_cat_tercero,
                            nom_tercero      = wnom_tercero,
                            dir_tercero      = ROW(wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail)::DATOS_UBICACION,
                            id_ciudad        = wid_ciudad,
                            id_restriccion   = wid_restriccion,
                            ind_estado       = wind_estado
    WHERE id_tercero = wid_tercero;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_tipo_identidad(wid_tipo    tab_tipo_identidad.id_tipo%TYPE,
                                                     wnom_tipo   tab_tipo_identidad.nom_tipo%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_tipo IS NULL OR TRIM(wid_tipo) = '' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad no puede estar vacío';
    END IF;

    IF wnom_tipo IS NULL OR TRIM(wnom_tipo) = '' THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad no puede estar vacío';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF wid_tipo !~ '^[A-Z]{2,5}$' THEN
        RAISE EXCEPTION 'El ID del tipo de identidad debe contener entre 2 y 5 letras mayúsculas (ej: CC, NIT, PASS)';
    END IF;

    IF LENGTH(wnom_tipo) < 5 OR LENGTH(wnom_tipo) > 50 THEN
        RAISE EXCEPTION 'El nombre del tipo de identidad debe tener entre 5 y 50 caracteres';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_tipo_identidad WHERE id_tipo = wid_tipo) THEN
        RAISE EXCEPTION 'El tipo de identidad con ID % no existe', wid_tipo;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_tipo_identidad SET nom_tipo = wnom_tipo
    WHERE id_tipo = wid_tipo;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_update_usuarios(wid_usuario     tab_usuarios.id_usuario%TYPE,
                                                wnom_usuario    tab_usuarios.nom_usuario%TYPE,
                                                wmail_usuario   tab_usuarios.mail_usuario%TYPE,
                                                wind_usuario    tab_usuarios.ind_usuario%TYPE,
                                                wind_estado     tab_usuarios.ind_estado%TYPE) RETURNS BOOLEAN AS
$$
BEGIN

    -- =============================================
    -- VALIDACIONES DE NULO / VACÍO
    -- =============================================
    IF wid_usuario IS NULL OR TRIM(wid_usuario) = '' THEN
        RAISE EXCEPTION 'El ID de usuario no puede estar vacío';
    END IF;

    IF wnom_usuario IS NULL OR TRIM(wnom_usuario) = '' THEN
        RAISE EXCEPTION 'El nombre de usuario no puede estar vacío';
    END IF;

    IF wmail_usuario IS NULL OR TRIM(wmail_usuario) = '' THEN
        RAISE EXCEPTION 'El correo electrónico no puede estar vacío';
    END IF;

    IF wind_usuario IS NULL THEN
        RAISE EXCEPTION 'El indicador de administrador no puede ser nulo';
    END IF;

    IF wind_estado IS NULL THEN
        RAISE EXCEPTION 'El indicador de estado no puede ser nulo';
    END IF;

    -- =============================================
    -- VALIDACIONES DE FORMATO Y RANGO
    -- =============================================
    IF LENGTH(wid_usuario) < 5 THEN
        RAISE EXCEPTION 'El ID de usuario debe tener mínimo 5 caracteres';
    END IF;

    IF LENGTH(wnom_usuario) < 8 THEN
        RAISE EXCEPTION 'El nombre completo debe tener mínimo 8 caracteres';
    END IF;

    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico no tiene un formato válido';
    END IF;

    -- =============================================
    -- VALIDACIÓN DE EXISTENCIA
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = wid_usuario AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe o está inactivo', wid_usuario;
    END IF;

    IF EXISTS (SELECT 1 FROM tab_usuarios WHERE mail_usuario = wmail_usuario AND id_usuario <> wid_usuario) THEN
        RAISE EXCEPTION 'El correo % ya está registrado en otro usuario', wmail_usuario;
    END IF;

    -- =============================================
    -- ACTUALIZACIÓN
    -- =============================================
    UPDATE tab_usuarios SET nom_usuario  = wnom_usuario,
                            mail_usuario = wmail_usuario,
                            ind_usuario  = wind_usuario,
                            ind_estado   = wind_estado
    WHERE id_usuario = wid_usuario;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_mensaje_error(p_sqlstate TEXT, p_sqlerrm TEXT)
RETURNS TEXT AS
$$
DECLARE
    v_mensaje TEXT;
BEGIN
    -- Caso especial: error manual (nuestras validaciones con RAISE EXCEPTION)
    IF p_sqlstate = 'P0001' THEN
        RETURN COALESCE(p_sqlerrm, 'Ocurrió un error inesperado.');
    END IF;

    -- Intentamos buscar el mensaje amigable
    BEGIN
        SELECT mensaje INTO v_mensaje FROM tab_cat_errores
        WHERE cod_sqlstate = p_sqlstate;
    EXCEPTION WHEN OTHERS THEN
        -- Si la tabla de errores falla, no rompemos todo. Devolvemos el error técnico original.
        RETURN 'Error del sistema al buscar mensaje. Detalle técnico: ' || COALESCE(p_sqlerrm, 'Error desconocido');
    END;

    -- Si existe en tabla, usarlo; si no, genérico con el código para ayudar a depurar
    RETURN COALESCE(v_mensaje, 'Ocurrió un error inesperado. (Código: ' || p_sqlstate || ')');
END;
$$ LANGUAGE plpgsql;

INSERT INTO tab_cat_errores (cod_sqlstate, mensaje) VALUES

-- ✅ Éxito / advertencias
('00000', 'Operación realizada correctamente'),
('01000', 'Advertencia general'),
('02000', 'No se encontraron datos'),

-- 🔐 Integridad (LOS MÁS IMPORTANTES)
('23505', 'El registro ya existe (duplicado)'),
('23503', 'El valor no existe o está relacionado con otros datos'),
('23502', 'Un campo obligatorio está vacío'),
('23514', 'El valor no cumple las reglas permitidas'),

-- 📊 Datos inválidos
('22001', 'El texto es demasiado largo'),
('22003', 'El número está fuera de rango'),
('22004', 'No se permite valor nulo'),
('22007', 'Formato de fecha incorrecto'),
('22012', 'No se puede dividir entre cero'),
('22P02', 'Formato de dato inválido'),

-- 🧠 Lógica / consultas
('42P01', 'La tabla no existe'),
('42703', 'La columna no existe'),
('42601', 'Error de sintaxis en la consulta'),
('42804', 'Tipo de dato incorrecto'),
('42883', 'La función no existe'),

-- 🔁 Transacciones
('40001', 'Conflicto de transacción, intente nuevamente'),
('40P01', 'Se detectó un bloqueo entre procesos'),

-- 🔒 Permisos
('42501', 'No tiene permisos para realizar esta acción'),

-- 🌐 Conexión
('08003', 'La conexión no está activa'),
('08006', 'Error en la conexión a la base de datos'),

-- ⚙️ Sistema / recursos
('53000', 'Recursos insuficientes'),
('53100', 'No hay espacio en disco'),
('53200', 'Memoria insuficiente'),

-- ⚠️ Estado / ejecución
('25000', 'Estado de transacción inválido'),
('25P02', 'La transacción falló previamente'),

-- 🧩 PL/pgSQL
('P0001', 'Error generado manualmente'),
('P0002', 'No se encontraron resultados'),
('P0003', 'Se encontraron demasiados resultados'),

-- 🧨 Otros útiles
('21000', 'Error: se esperaban menos resultados'),
('2200F', 'Texto vacío no permitido'),
('2200L', 'Documento XML inválido'),
('22032', 'JSON inválido');

-- DELETE FROM tab_cat_errores
-- Select * from tab_cat_errores

-- CARGA DE TABLA DE MENÚS INICIAL

SELECT fun_insert_tab_menus ('1','Configuración','0','no_aplica');
SELECT fun_insert_tab_menus ('11','Parámetros','1','pmtros.php');
SELECT fun_insert_tab_menus ('12','Gestión de Accesos','1','no_aplica');
SELECT fun_insert_tab_menus ('121','Usuarios','12','usuarios.php');
SELECT fun_insert_tab_menus ('122','Cambio de Clave','12','cambiar_clave.php');
SELECT fun_insert_tab_menus ('123','Menús','12','menus.php');
SELECT fun_insert_tab_menus ('124','Menús de Usuario','12','menu_usuarios.php');
SELECT fun_insert_tab_menus ('125','Copiar un Perfil','12','copiar_menu_usuarios.php');
SELECT fun_insert_tab_menus ('13','Tablas Maestras','1','no_aplica');
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

SELECT fun_insert_tab_menus('5', 'Marketing & Comercial', '0', 'no_aplica');
SELECT fun_insert_tab_menus('51', 'Dashboard', '5', 'modules/marcom/dashboard_php');
SELECT fun_insert_tab_menus('52', 'Leads', '5', 'modules/marcom/leads.php');
SELECT fun_insert_tab_menus('53', 'Clientes', '5', 'modules/marcom/clientes.php');
SELECT fun_insert_tab_menus('54', 'Embudo de Ventas', '5', 'modules/marcom/funnel_ventas.php');
SELECT fun_insert_tab_menus('55', 'Campañas', '5', 'modules/marcom/campanas.php');
SELECT fun_insert_tab_menus('56', 'Eventos', '5', 'modules/marcom/eventos.php');
SELECT fun_insert_tab_menus('57', 'Reportes KPI', '5', 'modules/marcom/reportes_kpi.php');
SELECT fun_insert_tab_menus('58', 'Configuración', '5', 'no_aplica');
SELECT fun_insert_tab_menus('581', 'Parámetros', '58', 'modules/marcom/pmtros_php');
SELECT fun_insert_tab_menus('582', 'Funnel', '58', 'modules/marcom/parametros_funnel.php');
SELECT fun_insert_tab_menus('583', 'Canales', '58', 'modules/marcom/parametros_canales.php');
SELECT fun_insert_tab_menus('584', 'Segmentación', '58', 'modules/marcom/parametros_segmentacion.php');
SELECT fun_insert_tab_menus('585', 'Motivos Pérdida', '58', 'modules/marcom/motivos_perdida.php');
SELECT fun_insert_tab_menus('586', 'KPIs', '58', 'modules/marcom/parametros_kpi.php');
SELECT fun_insert_tab_menus('587', 'Usuarios', '58', 'modules/marcom/config_usuarios.php');

-- CARGA INICIAL DE CONTABILIDAD
-- ========== NIVEL 1: MÓDULO PRINCIPAL ==========
SELECT fun_insert_tab_menus ('6', 'Contabilidad y Presupuesto', '0', 'no_aplica');

SELECT fun_insert_tab_menus ('61', 'Plan único de cuentas', '6', 'modules/conpre/puc.php');

SELECT fun_insert_tab_menus ('62', 'Activos fijos', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('621', 'Crear activos fijos', '62', 'modules/conpre/activos.php');
SELECT fun_insert_tab_menus ('622', 'Categoría activos fijos', '62', 'modules/conpre/cat_activos.php');
SELECT fun_insert_tab_menus ('623', 'Depreciación', '62', 'modules/conpre/depreciacion.php');


SELECT fun_insert_tab_menus ('63', 'Presupuesto', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('631', 'Presupuesto por Areas', '63', 'modules/conpre/presupuesto.php');
SELECT fun_insert_tab_menus ('632', 'Tipos de presupuesto', '63', 'modules/conpre/tipo_presupuesto.php');
SELECT fun_insert_tab_menus ('633', 'Periodos de presupuesto', '63', 'modules/conpre/periodo_presupuesto.php');
SELECT fun_insert_tab_menus ('634', 'Planeación de presupuesto', '63', 'modules/conpre/planeacion_presupuesto.php');
SELECT fun_insert_tab_menus ('635', 'Detalle de presupuesto', '63', 'modules/conpre/detalle_presupuesto.php');
SELECT fun_insert_tab_menus ('636', 'Ejecución de presupuesto', '63', 'modules/conpre/ejecucion_presupuesto.php');

SELECT fun_insert_tab_menus ('64', 'Comprobantes contables', '6', 'no_aplica');
SELECT fun_insert_tab_menus ('641', 'Crear comprobante Contable', '64', 'modules/conpre/comprobante.php');
SELECT fun_insert_tab_menus ('642', 'Tipos de comprobantes', '64', 'modules/conpre/tipo_comprobante.php');
SELECT fun_insert_tab_menus ('643', 'Registro de comprobantes', '64', 'modules/conpre/registro_comprobante.php');
SELECT fun_insert_tab_menus ('644', 'Detalle de comprobantes', '64', 'modules/conpre/detalle_comprobante.php');

SELECT fun_insert_tab_menus ('65', 'Parámetros contables', '6', 'modules/conpre/parametros_contab.php');

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

-- INICIO
SELECT fun_insert_tab_menus ('81', 'Dashboard', '8', 'modules/gehnom/src/dashboard.php');

-- PERSONAL
SELECT fun_insert_tab_menus ('82', 'Personal', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('821', 'Candidatos', '82', 'modules/gehnom/src/candidatos.php');
SELECT fun_insert_tab_menus ('822', 'Empleados', '82', 'modules/gehnom/src/empleados.php');
SELECT fun_insert_tab_menus ('823', 'Cargos', '82', 'modules/gehnom/src/cargos.php');
SELECT fun_insert_tab_menus ('824', 'Prestamos', '82', 'modules/gehnom/src/prestamos.php');
SELECT fun_insert_tab_menus ('825', 'Procesos Disciplinarios', '82', 'modules/gehnom/src/procesos_disciplinarios.php');

-- FORMACIÓN
SELECT fun_insert_tab_menus ('83', 'Formacion', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('831', 'Escolaridad', '83', 'modules/gehnom/src/escolaridad.php');
SELECT fun_insert_tab_menus ('832', 'Profesiones', '83', 'modules/gehnom/src/profesiones.php');

-- ENTIDADES
SELECT fun_insert_tab_menus ('84', 'Entidades', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('841', 'Entidades', '84', 'modules/gehnom/src/entidades.php');

-- NÓMINA
SELECT fun_insert_tab_menus ('85', 'Nomina', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('851', 'Conceptos', '85', 'modules/gehnom/src/conceptos.php');
SELECT fun_insert_tab_menus ('852', 'Novedades', '85', 'modules/gehnom/src/novedades.php');
SELECT fun_insert_tab_menus ('853', 'Liquidar Nomina', '85', 'modules/gehnom/src/liquidar_nomina.php');
SELECT fun_insert_tab_menus ('854', 'Nomina Electronica', '85', 'modules/gehnom/src/nomina_electronica.php');

-- CONFIGURACIÓN
SELECT fun_insert_tab_menus ('86', 'Configuracion', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('861', 'Parametros Legales', '86', 'modules/gehnom/src/pmtros_legales.php');

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

