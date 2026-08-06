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
-- 2. BORRADO DE LOS ESQUEMAS DE MÓDULOS DEL ERP
-- Módulos Transaccionales
-- ----------------------------------------------

DROP SCHEMA IF EXISTS FACCAR;  -- Facturación y Cartera
DROP SCHEMA IF EXISTS COMPRO;  -- Compras y Proveedores
DROP SCHEMA IF EXISTS TESCXP;  -- Tesorería y Cuentas por Pagar
DROP SCHEMA IF EXISTS MARCOM;  -- Marketing y Comercial
DROP SCHEMA IF EXISTS CONPRE;  -- Contabilidad y Presupuesto
DROP SCHEMA IF EXISTS GEHNOM;  -- Gestión Humana y Nómina
DROP SCHEMA IF EXISTS GEDCAL;  -- Gestión Documental y Calidad
DROP SCHEMA IF EXISTS SESATR;  -- Seguridad y Salud en el Trabajo
DROP SCHEMA IF EXISTS SECURE;  -- Seguridad

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
DROP TYPE IF EXISTS DATOS_UBICACION;
-- AGREGAR BANCOS
-- 
-- ------------------------------------------------------------
-- 4. CREACIÓN DE TABLAS TRANSVERSALES (Esquema 'public')
-- Estas tablas son esenciales y usadas por todos los módulos.
-- Se colocan en 'public' para un acceso más sencillo.
-- ------------------------------------------------------------

--ESTRUCTURA DE DATOS DE UBICACIÓN DE LOS TERCEROS DEL SISTEMA (Se usa en la tabla de terceros y en la tabla de parámetros generales para la empresa)
CREATE TYPE DATOS_UBICACION AS
(
	nom_corto			VARCHAR,                                --nombre corto del lugar (ej: Barrio, Vereda, etc.)
    direccion           VARCHAR,                                --direcion del tercero
    tel_fijo            DECIMAL(10,0),                          --telefono del tercero
    tel_movil           DECIMAL(10,0),                          --celular del tercero
    email               VARCHAR(255)
);

-- MANEJO DE ERRORES TRANSVERSAL (Tabla de códigos de error SQLSTATE y mensajes asociados)
CREATE TABLE tab_cat_errores (
    cod_sqlstate VARCHAR(10) NOT NULL,  -- Codigo SQLSTATE del error
    mensaje      VARCHAR     NOT NULL, -- Mensaje descriptivo del error    
    PRIMARY KEY(cod_sqlstate)
);

-- 1. SEGURIDAD Y ACCESOS (Usuarios creados en Bases de Datos)
CREATE TABLE tab_usuarios
(
    id_usuario          VARCHAR PRIMARY KEY CHECK(LENGTH(id_usuario) >= 5),
    nom_usuario         VARCHAR         NOT NULL CHECK(LENGTH(nom_usuario) >= 8),
    pass_usuario        VARCHAR         NOT NULL CHECK(LENGTH(pass_usuario) >= 12),
    mail_usuario        VARCHAR         NOT NULL CHECK(mail_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    ind_usuario         BOOLEAN         NOT NULL DEFAULT FALSE, -- TRUE= Si es administrador / FALSE= Es un usuario normal.
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,  -- Si está inhabilitado o modificado
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
);

-- 2. TABLA PARA CUMPLIMIENTO DE SESIÓN ÚNICA (Requerimientos)
CREATE TABLE tab_sesiones
(
    id_usuario          VARCHAR PRIMARY KEY REFERENCES tab_usuarios(id_usuario) ON DELETE CASCADE,
    token_sesion        VARCHAR         NOT NULL,
    fec_inicio          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ult_actividad       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLAS DE MENUS (Menus que se crean para asignar a los usuarios y evitar usar roles)

CREATE TABLE tab_menus
(
    id_menu             VARCHAR PRIMARY KEY,
    nom_menu            VARCHAR         NOT NULL CHECK(LENGTH(nom_menu) >= 3 AND LENGTH(nom_menu) <= 50),
    ind_id_padre        VARCHAR         NOT NULL,
    nom_programa        VARCHAR         NOT NULL DEFAULT 'no_aplica',
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
);
-- 4. TABLAS DE MENUS POR USUARIO (para asignar menus sin necesidad de que todos los usuarios tengan los mismos)

CREATE TABLE tab_menu_usuarios
(
    id_usuario          VARCHAR REFERENCES tab_usuarios(id_usuario),
    id_menu             VARCHAR REFERENCES tab_menus(id_menu),
    PRIMARY KEY(id_usuario, id_menu)
);

-- 5. TABLA DE ÁREAS DE LA EMPRESA (Áreas creadas y asignadas a un responsable por su id de usuario del sistema)

CREATE TABLE IF NOT EXISTS public.tab_areas
(
    id_area             DECIMAL(5,0)    NOT NULL CHECK (id_area > 0),
    id_responsable      VARCHAR         DEFAULT NULL,                                                                   -- Usuario responsable del área
    nom_area            VARCHAR         NOT NULL CHECK (LENGTH(nom_area) >= 3),                                         -- Nombre del área (ej: Finanzas, Recursos Humanos, etc.)
    descrip_area        TEXT,                                                                                           -- Descripción detallada del área y sus funciones
    mail_area           VARCHAR         DEFAULT NULL,                                                                   -- Email corporativo del área
    tel_oficina         DECIMAL(10,0)   DEFAULT NULL,                                                                   -- Teléfono de la oficina del área
    ubi_oficina         VARCHAR         DEFAULT NULL,                                                                   -- Edificio, piso, oficina
    horario_atencion    VARCHAR         DEFAULT NULL,                                                                   -- Lunes a Viernes 8am-5pm
    ind_estado          BOOLEAN         NOT NULL DEFAULT TRUE,                                                          -- Activo/Inactivo
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	    --indicador de borrado lógico
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

-- 7. TABLA DEPARTAMENTOS DE COLOMBIA 

CREATE TABLE IF NOT EXISTS tab_dptos
(
    id_dpto	            VARCHAR         NOT NULL CHECK(LENGTH(id_dpto) = 2),                                                    --identificador del departamento
    nom_dpto	        VARCHAR	        NOT NULL CHECK(LENGTH(nom_dpto) >= 4 AND LENGTH(nom_dpto) <= 20),                       --nombre del departamento
    ind_borrado         BOOLEAN             NOT NULL DEFAULT FALSE, -- --TRUE: Borrado lógico (Inactivo) / FALSE: Activo        --indicador de borrado lógico
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
	id_cat_tercero 		DECIMAL(2,0)	NOT NULL,					--identificador de la categoria 
	nom_cat_tercero		VARCHAR			NOT NULL,					--Nombre de la categoria tercero
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
	id_restriccion		DECIMAL(2,0)	NOT NULL,				--identificador de la restrinción	
	nom_restriccion		VARCHAR			NOT NULL,				--Nombre de la restrinción
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
	id_tercero			VARCHAR     	NOT NULL CHECK(),		                                                --identificador de terceros
    	
	ind_tipo_tercero	BOOLEAN			NOT NULL, --TRUE:Jurídica / FALSE:Natural								--tipo de tercero si es persona natural o jurídica
	id_cat_tercero		DECIMAL(2,0)	NOT NULL,																--identifiador de la categoria 
	nom_tercero			VARCHAR			NOT NULL,																--nombre del tercero
	dir_tercero			DATOS_UBICACION,																		--Estructura de   datos de ubicación de terceros
	id_ciudad			VARCHAR			NOT NULL,																--identificador de ciudad
	id_restriccion		DECIMAL(2,0)	NOT NULL, -- Validado contra tabla de restricciones						--identificador de las restrincion
	ind_estado			BOOLEAN			NOT NULL, --TRUE:Activo ( FALSE:Inactivo)								--indicador de estado del tercero
    ind_borrado         BOOLEAN         NOT NULL DEFAULT FALSE, --TRUE: Borrado lógico (Inactivo) / FALSE: Activo	--indicador de borrado lógico
	PRIMARY KEY(id_tercero),			
	FOREIGN KEY(id_ciudad)			REFERENCES tab_ciudades(id_ciudad),			
	FOREIGN KEY(id_cat_tercero)		REFERENCES tab_cat_terceros(id_cat_tercero),			
	FOREIGN KEY(id_restriccion)		REFERENCES tab_restricciones(id_restriccion)
);

-- ----------------------------------------------------------------
-- 6. CREACIÓN DE LOS ESQUEMAS MODULARES
-- Cada esquema encapsula la lógica y las tablas de un módulo.
-- Esto facilita la gestión de permisos y la organización lógica.
-- ----------------------------------------------------------------

-- Módulos Transaccionales
CREATE SCHEMA FACCAR;  -- Facturación y Cartera
CREATE SCHEMA COMPRO;  -- Compras y Proveedores
CREATE SCHEMA TESCXP;  -- Tesorería y Cuentas por Pagar
CREATE SCHEMA MARCOM;  -- Marketing y Comercial
CREATE SCHEMA CONPRE;  -- Contabilidad y Presupuesto
CREATE SCHEMA GEHNOM;  -- Gestión Humana y Nómina
CREATE SCHEMA GEDCAL;  -- Gestión Documental y Calidad
CREATE SCHEMA SESATR;  -- Seguridad y Salud en el Trabajo
CREATE SCHEMA SECURE;  -- Seguridad

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
ALTER DATABASE db_erpadso SET search_path TO public, "$user";

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
) PARTITION BY RANGE (fec_registro);  -- ¡PARTICIONADA POR FECHA!

-- Crear índice sobre la tabla particionada
CREATE INDEX idx_auditoria_tabla_fecha ON public.tab_audit_trail(nom_tabla, fec_registro DESC);

-- ---------------------------------------------------
-- 9.1 FUNCIÓN PARA CREAR PARTICIONES AUTOMÁTICAS
-- ---------------------------------------------------

CREATE OR REPLACE FUNCTION public.fun_particion_auto()
RETURNS TEXT AS $$
DECLARE
    wproximo_mes   DATE;
    wnom_particion TEXT;
    wfec_inicio    DATE;
    wfec_final     DATE;

BEGIN
    wproximo_mes := date_trunc('month', CURRENT_DATE + INTERVAL '1 month')::DATE;
    wfec_inicio := wproximo_mes;
    wfec_final := wproximo_mes + INTERVAL '1 month';

    wnom_particion := 'audit_' || to_char(wfec_inicio, 'YYYY_MM');
        EXECUTE format('
        CREATE TABLE IF NOT EXISTS public.%I PARTITION OF public.tab_audit_trail
        FOR VALUES FROM (%L) TO (%L)',
        wnom_particion, wfec_inicio, wfec_final
    );

    RETURN format('La Partición %s creada para el rango [%s, %s)', 
                  wnom_particion, wfec_inicio, wfec_final);
    
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------
-- 9.2 CREAR PARTICIONES INICIALES (próximos 3 meses)
-- ---------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_2026_06 PARTITION OF public.tab_audit_trail
FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

SELECT public.fun_particion_auto();
SELECT public.fun_particion_auto();
SELECT public.fun_particion_auto();

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
        ELSE
            w_operacion := 'U';  -- Registrar como UPDATE
        END IF;  
    ELSIF (TG_OP = 'INSERT') THEN
        w_old_data := NULL;
        w_new_data := to_jsonb(NEW);
        w_operacion := 'I';
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
SELECT fun_insert_tab_menus('31','Dashboard','3','dashboard.php');
SELECT fun_insert_tab_menus('32','Proveedores','3','proveedores.php');
SELECT fun_insert_tab_menus('33','Productos','3','productos.php');
SELECT fun_insert_tab_menus('34','CatxProv','3','catxprov.php');
SELECT fun_insert_tab_menus('35','Ordenes de compra','3','ordenescompra.php');

-- CARGA INICIAL DE TESORERIA Y CXP

SELECT fun_insert_tab_menus('4','Tesorería y Cuentas por Pagar','0','no_aplica');
SELECT fun_insert_tab_menus('41','Parámetros de Tesorería','4','pmtrostescxp.php');
SELECT fun_insert_tab_menus('42','Bancos por Proveedores','4','banxprov.php');
SELECT fun_insert_tab_menus('43','Facturas','4','facturastcxp.php');
SELECT fun_insert_tab_menus('44','Programación de pagos','4','progpagos.php');
SELECT fun_insert_tab_menus('45','Pagos','4','pagos.php');
SELECT fun_insert_tab_menus('46','Dispersión de Nómina','4','dispnom.php');

-- CARGA INICIAL DE MARKETING


-- CARGA INICIAL DE CONTABILIDAD


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


-- CARGA INICIAL DE SST

SELECT fun_insert_tab_menus  ('9','SST','0','no_aplica');
SELECT fun_insert_tab_menus  ('91','Resumen','9','dashboard.php');
SELECT fun_insert_tab_menus  ('92', 'Accidentes', '9', 'Accidentes.php');
SELECT fun_insert_tab_menus  ('93', 'Incapacidades','9', 'Incapacidades.php');
SELECT fun_insert_tab_menus  ('94', 'Capacitaciones', '9', 'Capacitaciones.php');
SELECT fun_insert_tab_menus  ('95', 'Auditoria', '9', 'Auditoria.php');
SELECT fun_insert_tab_menus  ('96', 'Empleados', '9', 'Empleados.php');
SELECT fun_insert_tab_menus  ('97', 'Brigadistas', '9', 'Brigadistas.php');
SELECT fun_insert_tab_menus  ('98', 'Examenes', '9', 'Examenes.php');
SELECT fun_insert_tab_menus  ('99', 'EPP','9', 'EPP.php');

-- CARGA INICIAL DE GESTIÓN DOCUMENTAL Y CALIDAD

SELECT fun_insert_tab_menus ('10','Gestión Documental y Calidad','0','no_aplica');
SELECT fun_insert_tab_menus ('101','Correspondencia','10','no_aplica');
SELECT fun_insert_tab_menus ('102','Expedientes','10', 'no_aplica');
SELECT fun_insert_tab_menus ('103','PQRS','10', 'no_aplica');
SELECT fun_insert_tab_menus ('104','Documentos de Calidad','10','no_aplica');

SELECT fun_insert_tab_menus ('105','Procesos y Auditorías','10','no_aplica');
SELECT fun_insert_tab_menus ('106','Catálogos del Módulo','10','no_aplica');
SELECT fun_insert_tab_menus ('1011','Radicar correspondencia','101','gedcal/correspondencia_radicar.php');
SELECT fun_insert_tab_menus ('1012','Bandeja de correspondencia','101','gedcal/correspondencia_bandeja.php');
SELECT fun_insert_tab_menus ('1021','Crear expediente','102','gedcal/expedientes_crear.php');
SELECT fun_insert_tab_menus ('1022','Gestionar expedientes','102','gedcal/expedientes_gestionar.php');
SELECT fun_insert_tab_menus ('1031','Radicar PQRS','103','gedcal/pqrs_radicar.php');
SELECT fun_insert_tab_menus ('1032','Bandeja PQRS','103','gedcal/pqrs_bandeja.php');
SELECT fun_insert_tab_menus ('1033','Seguimiento y respuestas','103','gedcal/pqrs_seguimiento.php');
SELECT fun_insert_tab_menus ('1041','Control de documentos','104', 'gedcal/calidad_documentos.php');
SELECT fun_insert_tab_menus ('1042','Workflow de aprobación','104','gedcal/calidad_workflow.php');
SELECT fun_insert_tab_menus ('1051','Procesos','105','gedcal/calidad_procesos.php');
SELECT fun_insert_tab_menus ('1052','Auditorías','105','gedcal/calidad_auditorias.php');
SELECT fun_insert_tab_menus ('1053','Hallazgos y acciones','105','gedcal/calidad_hallazgos.php');
SELECT fun_insert_tab_menus ('1061','Tipos de Documento', '106', 'gedcal/tipos_documento.php');
SELECT fun_insert_tab_menus ('1062','Orígenes de Correspondencia', '106', 'gedcal/origenes_correspondencia.php');
SELECT fun_insert_tab_menus ('1063','Niveles de Acceso','106','gedcal/niveles_acceso.php');
SELECT fun_insert_tab_menus ('1064','Tablas de Retención (TRD)','106','gedcal/trd.php');
SELECT fun_insert_tab_menus ('1065','Estados de Correspondencia','106','gedcal/estados_correspondencia.php');
SELECT fun_insert_tab_menus ('1066','Acciones Workflow Doc.','106','gedcal/acciones_workflow_doc.php');
SELECT fun_insert_tab_menus ('1067','Tipos de PQRS','106','gedcal/tipos_pqrs.php');
SELECT fun_insert_tab_menus ('1068','Canales de PQRS','106','gedcal/canales_pqrs.php');
SELECT fun_insert_tab_menus ('1069','Estados de PQRS','106','gedcal/estados_pqrs.php');
SELECT fun_insert_tab_menus ('1070','Motivos de PQRS','106','gedcal/motivos_pqrs.php');
SELECT fun_insert_tab_menus ('1071','Parámetros de Vencimiento PQRS','106','gedcal/param_venc_pqrs.php');
SELECT fun_insert_tab_menus ('1072','Riesgos','106','gedcal/riesgos.php');
SELECT fun_insert_tab_menus ('1073','Normas','106','gedcal/normas.php');
SELECT fun_insert_tab_menus ('1074','Estados Documentales','106','gedcal/estados_documento.php');
SELECT fun_insert_tab_menus ('1075','Acciones Workflow Calidad','106','gedcal/acciones_workflow.php');

            if ($stmt_check_usuarios->fetchColumn() > 0) {
                throw new Exception("❌ No se puede eliminar: está asignado a usuarios.");
            }