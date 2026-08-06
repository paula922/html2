-- ===================================================================
-- SCRIPT COMPLETO DE INSTALACIÓN - ERP ADSO
-- BASE DE DATOS: PostgreSQL
-- INCLUYE: TABLAS, TIPOS, FUNCIONES, TRIGGERS Y DATOS INICIALES
-- ===================================================================

-- ===================================================================
-- 1. CONFIGURACIÓN INICIAL
-- ===================================================================
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- ===================================================================
-- 2. EXTENSIONES NECESARIAS
-- ===================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ===================================================================
-- 3. BORRADO DE ESQUEMAS MODULARES (SI EXISTEN)
-- ===================================================================
DROP SCHEMA IF EXISTS FACCAR CASCADE;
DROP SCHEMA IF EXISTS COMPRO CASCADE;
DROP SCHEMA IF EXISTS TESCXP CASCADE;
DROP SCHEMA IF EXISTS MARCOM CASCADE;
DROP SCHEMA IF EXISTS CONPRE CASCADE;
DROP SCHEMA IF EXISTS GEHNOM CASCADE;
DROP SCHEMA IF EXISTS GEDCAL CASCADE;
DROP SCHEMA IF EXISTS SESATR CASCADE;
DROP SCHEMA IF EXISTS SECURE CASCADE;

-- ===================================================================
-- 4. BORRADO DE TABLAS EXISTENTES (ORDEN CORRECTO POR DEPENDENCIAS)
-- ===================================================================
DROP TABLE IF EXISTS tab_audit_trail CASCADE;
DROP TABLE IF EXISTS tab_sesiones CASCADE;
DROP TABLE IF EXISTS tab_menu_usuarios CASCADE;
DROP TABLE IF EXISTS tab_menus CASCADE;
DROP TABLE IF EXISTS tab_areas CASCADE;
DROP TABLE IF EXISTS tab_terceros CASCADE;
DROP TABLE IF EXISTS tab_ciudades CASCADE;
DROP TABLE IF EXISTS tab_dptos CASCADE;
DROP TABLE IF EXISTS tab_cat_terceros CASCADE;
DROP TABLE IF EXISTS tab_restricciones CASCADE;
DROP TABLE IF EXISTS tab_usuarios CASCADE;
DROP TABLE IF EXISTS tab_pmtros_grales CASCADE;
DROP TABLE IF EXISTS tab_cat_errores CASCADE;
DROP TYPE IF EXISTS DATOS_UBICACION CASCADE;

-- ===================================================================
-- 5. CREACIÓN DEL TYPE DATOS_UBICACION
-- ===================================================================
CREATE TYPE DATOS_UBICACION AS (
    nom_corto   VARCHAR,
    direccion   VARCHAR,
    tel_fijo    DECIMAL(10,0),
    tel_movil   DECIMAL(10,0),
    email       VARCHAR
);

-- ===================================================================
-- 6. CREACIÓN DE TABLAS
-- ===================================================================

-- -------------------------------------------------------------------
-- 6.1 TABLA DE ERRORES
-- -------------------------------------------------------------------
CREATE TABLE tab_cat_errores (
    cod_sqlstate    VARCHAR(5)   NOT NULL,
    mensaje         VARCHAR(255) NOT NULL CHECK(LENGTH(mensaje) >= 4),
    PRIMARY KEY(cod_sqlstate)
);

-- -------------------------------------------------------------------
-- 6.2 TABLA DE USUARIOS
-- -------------------------------------------------------------------
CREATE TABLE tab_usuarios (
    id_usuario      VARCHAR(50)   NOT NULL CHECK(LENGTH(id_usuario) >= 5),
    nom_usuario     VARCHAR(100)  NOT NULL CHECK(LENGTH(nom_usuario) >= 8),
    pass_usuario    VARCHAR(255)  NOT NULL CHECK(LENGTH(pass_usuario) >= 12),
    mail_usuario    VARCHAR(100)  NOT NULL 
        CHECK(mail_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    ind_usuario     BOOLEAN       NOT NULL DEFAULT FALSE,
    ind_estado      BOOLEAN       NOT NULL DEFAULT TRUE,
    ind_borrado     BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_usuario)
);

-- -------------------------------------------------------------------
-- 6.3 TABLA DE SESIONES
-- -------------------------------------------------------------------
CREATE TABLE tab_sesiones (
    id_usuario      VARCHAR(50)   NOT NULL,
    token_sesion    VARCHAR(255)  NOT NULL CHECK(LENGTH(token_sesion) >= 10),
    fec_inicio      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    ult_actividad   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id_usuario),
    FOREIGN KEY(id_usuario) REFERENCES tab_usuarios(id_usuario) ON DELETE CASCADE
);

-- -------------------------------------------------------------------
-- 6.4 TABLA DE MENÚS
-- -------------------------------------------------------------------
CREATE TABLE tab_menus (
    id_menu         VARCHAR(10)   NOT NULL,
    nom_menu        VARCHAR(100)  NOT NULL CHECK(LENGTH(nom_menu) <= 100),
    ind_id_padre    VARCHAR(10)   NOT NULL DEFAULT '0',
    nom_programa    VARCHAR(255)  NOT NULL DEFAULT 'no_aplica',
    ind_borrado     BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_menu)
);

-- -------------------------------------------------------------------
-- 6.5 TABLA DE MENÚS POR USUARIO
-- -------------------------------------------------------------------
CREATE TABLE tab_menu_usuarios (
    id_usuario      VARCHAR(50)   NOT NULL,
    id_menu         VARCHAR(10)   NOT NULL,
    PRIMARY KEY(id_usuario, id_menu),
    FOREIGN KEY(id_usuario) REFERENCES tab_usuarios(id_usuario),
    FOREIGN KEY(id_menu)    REFERENCES tab_menus(id_menu)
);

-- -------------------------------------------------------------------
-- 6.6 TABLA DE ÁREAS
-- -------------------------------------------------------------------
CREATE TABLE tab_areas (
    id_area             DECIMAL(5,0)   NOT NULL CHECK(id_area > 0),
    id_responsable      VARCHAR(50)    DEFAULT NULL,
    nom_area            VARCHAR(100)   NOT NULL CHECK(LENGTH(nom_area) >= 3),
    descrip_area        TEXT,
    mail_area           VARCHAR(100)   NOT NULL 
        CHECK(mail_area ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    tel_oficina         DECIMAL(10,0)  NOT NULL CHECK(tel_oficina >= 0),
    ubi_oficina         VARCHAR(200)   NOT NULL CHECK(LENGTH(ubi_oficina) >= 3),
    horario_atencion    VARCHAR(100)   NOT NULL CHECK(LENGTH(horario_atencion) >= 3),
    ind_estado          BOOLEAN        NOT NULL DEFAULT TRUE,
    ind_borrado         BOOLEAN        NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_area),
    FOREIGN KEY(id_responsable) REFERENCES tab_usuarios(id_usuario)
);

-- -------------------------------------------------------------------
-- 6.7 TABLA DE DEPARTAMENTOS
-- -------------------------------------------------------------------
CREATE TABLE tab_dptos (
    id_dpto         VARCHAR(2)    NOT NULL,
    nom_dpto        VARCHAR(20)   NOT NULL CHECK(LENGTH(nom_dpto) >= 4),
    ind_borrado     BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_dpto)
);

-- -------------------------------------------------------------------
-- 6.8 TABLA DE CIUDADES
-- -------------------------------------------------------------------
CREATE TABLE tab_ciudades (
    id_ciudad       VARCHAR(5)            NOT NULL,
    nom_ciudad      VARCHAR(30)           NOT NULL CHECK(LENGTH(nom_ciudad) >= 3),
    id_dpto         VARCHAR(2)            NOT NULL,
    ind_capital     BOOLEAN               NOT NULL,
    cod_postal      VARCHAR(6)            NOT NULL,
    val_latitud     DECIMAL(18,16)        NOT NULL CHECK(val_latitud >= -4 AND val_latitud <= 80),
    val_longitud    DECIMAL(18,16)        NOT NULL CHECK(val_longitud >= -80 AND val_longitud <= -50),
    ind_borrado     BOOLEAN               NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_ciudad),
    FOREIGN KEY(id_dpto) REFERENCES tab_dptos(id_dpto)
);

-- -------------------------------------------------------------------
-- 6.9 TABLA CATEGORÍAS DE TERCEROS
-- -------------------------------------------------------------------
CREATE TABLE tab_cat_terceros (
    id_cat_tercero  DECIMAL(2,0)  NOT NULL CHECK(id_cat_tercero > 0 AND id_cat_tercero <= 99),
    nom_cat_tercero VARCHAR(50)   NOT NULL CHECK(LENGTH(nom_cat_tercero) >= 4),
    PRIMARY KEY(id_cat_tercero)
);

-- -------------------------------------------------------------------
-- 6.10 TABLA DE RESTRICCIONES
-- -------------------------------------------------------------------
CREATE TABLE tab_restricciones (
    id_restriccion  DECIMAL(2,0)  NOT NULL CHECK(id_restriccion > 0 AND id_restriccion <= 99),
    nom_restriccion VARCHAR(50)   NOT NULL CHECK(LENGTH(nom_restriccion) >= 4),
    PRIMARY KEY(id_restriccion)
);

-- -------------------------------------------------------------------
-- 6.11 TABLA DE TERCEROS
-- -------------------------------------------------------------------
CREATE TABLE tab_terceros (
    id_tercero        VARCHAR(20)   NOT NULL,
    ind_tipo_tercero  BOOLEAN       NOT NULL,
    id_cat_tercero    DECIMAL(2,0)  NOT NULL,
    nom_tercero       VARCHAR(50)   NOT NULL CHECK(LENGTH(nom_tercero) >= 4),
    dir_tercero       DATOS_UBICACION,
    id_ciudad         VARCHAR(5)    NOT NULL,
    id_restriccion    DECIMAL(2,0)  NOT NULL,
    ind_estado        BOOLEAN       NOT NULL,
    ind_borrado       BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_tercero),
    FOREIGN KEY(id_ciudad)       REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_cat_tercero)  REFERENCES tab_cat_terceros(id_cat_tercero),
    FOREIGN KEY(id_restriccion)  REFERENCES tab_restricciones(id_restriccion)
);

-- -------------------------------------------------------------------
-- 6.12 TABLA PARÁMETROS GENERALES
-- -------------------------------------------------------------------
CREATE TABLE tab_pmtros_grales (
    id_empresa        DECIMAL(10,0)    NOT NULL CHECK(id_empresa >= 10000000 AND id_empresa <= 9999999999),
    nom_empresa       VARCHAR(60)      NOT NULL CHECK(LENGTH(nom_empresa) >= 5),
    datos_residencia  DATOS_UBICACION,
    nom_replegal      VARCHAR(60)      NOT NULL CHECK(LENGTH(nom_replegal) >= 5),
    val_poriva        DECIMAL(2,0)     NOT NULL DEFAULT 0 CHECK(val_poriva >= 0 AND val_poriva < 100),
    val_pordesc       DECIMAL(2,0)     NOT NULL DEFAULT 0 CHECK(val_pordesc >= 0 AND val_pordesc < 100),
    val_porrete       DECIMAL(2,0)     NOT NULL DEFAULT 0 CHECK(val_porrete >= 0 AND val_porrete < 100),
    val_reteica       DECIMAL(2,0)     NOT NULL DEFAULT 0 CHECK(val_reteica >= 0 AND val_reteica < 100),
    val_porutil       DECIMAL(3,0)     NOT NULL DEFAULT 0 CHECK(val_porutil >= 0 AND val_porutil <= 100),
    val_latitud       DECIMAL(18,16)   NOT NULL CHECK(val_latitud >= -4 AND val_latitud <= 80),
    val_longitud      DECIMAL(18,16)   NOT NULL CHECK(val_longitud >= -80 AND val_longitud <= -50),
    color_letra       VARCHAR(7)       NOT NULL,
    color_logo        VARCHAR(7)       NOT NULL,
    color_fondo       VARCHAR(7)       NOT NULL,
    anio_fiscal       DECIMAL(4,0)     NOT NULL,
    mes_fiscal        DECIMAL(2,0)     NOT NULL,
    ind_autorete      BOOLEAN          NOT NULL,
    ind_borrado       BOOLEAN          NOT NULL DEFAULT FALSE,
    PRIMARY KEY(id_empresa),
    CONSTRAINT verificar_anio CHECK(anio_fiscal = EXTRACT(YEAR FROM CURRENT_DATE)),
    CONSTRAINT verificar_mes  CHECK(mes_fiscal = EXTRACT(MONTH FROM CURRENT_DATE))
);

-- -------------------------------------------------------------------
-- 6.13 TABLA DE AUDITORÍA (PARTICIONADA)
-- -------------------------------------------------------------------
CREATE TABLE tab_audit_trail (
    id_registro     BIGSERIAL,
    txid            BIGINT        NOT NULL DEFAULT txid_current(),
    nom_esquema     TEXT          NOT NULL,
    nom_tabla       TEXT          NOT NULL,
    ind_operacion   CHAR(1)       NOT NULL,
    usuario_db      TEXT          NOT NULL DEFAULT CURRENT_USER,
    usuario_erp_id  VARCHAR(50),
    fec_registro    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    datos_viejos    JSONB,
    datos_nuevos    JSONB
) PARTITION BY RANGE (fec_registro);

-- ===================================================================
-- 7. DATOS INICIALES (CATÁLOGOS)
-- ===================================================================

-- -------------------------------------------------------------------
-- 7.1 Categorías de Terceros
-- -------------------------------------------------------------------
INSERT INTO tab_cat_terceros VALUES (1, 'CLIENTE')   ON CONFLICT DO NOTHING;
INSERT INTO tab_cat_terceros VALUES (2, 'VENDEDOR')  ON CONFLICT DO NOTHING;
INSERT INTO tab_cat_terceros VALUES (3, 'EMPLEADO')  ON CONFLICT DO NOTHING;
INSERT INTO tab_cat_terceros VALUES (4, 'LEAD')      ON CONFLICT DO NOTHING;
INSERT INTO tab_cat_terceros VALUES (5, 'PROVEEDOR') ON CONFLICT DO NOTHING;

-- -------------------------------------------------------------------
-- 7.2 Restricciones
-- -------------------------------------------------------------------
INSERT INTO tab_restricciones VALUES (1, 'Finalización Contrato Mutuo Acuerdo') ON CONFLICT DO NOTHING;
INSERT INTO tab_restricciones VALUES (2, 'Vacaciones Colectivas')               ON CONFLICT DO NOTHING;
INSERT INTO tab_restricciones VALUES (3, 'Inhabilidad Legal')                   ON CONFLICT DO NOTHING;
INSERT INTO tab_restricciones VALUES (4, 'Restricción Día Festivo')             ON CONFLICT DO NOTHING;

-- -------------------------------------------------------------------
-- 7.3 Códigos de Error
-- -------------------------------------------------------------------
INSERT INTO tab_cat_errores (cod_sqlstate, mensaje) VALUES
    ('00000', 'Operación realizada correctamente'),
    ('01000', 'Advertencia general'),
    ('02000', 'No se encontraron datos'),
    ('23505', 'El registro ya existe (duplicado)'),
    ('23503', 'El valor no existe o está relacionado con otros datos'),
    ('23502', 'Un campo obligatorio está vacío'),
    ('23514', 'El valor no cumple las reglas permitidas'),
    ('22001', 'El texto es demasiado largo'),
    ('22003', 'El número está fuera de rango'),
    ('22004', 'No se permite valor nulo'),
    ('22007', 'Formato de fecha incorrecto'),
    ('22012', 'No se puede dividir entre cero'),
    ('22P02', 'Formato de dato inválido'),
    ('42P01', 'La tabla no existe'),
    ('42703', 'La columna no existe'),
    ('42601', 'Error de sintaxis en la consulta'),
    ('42804', 'Tipo de dato incorrecto'),
    ('42883', 'La función no existe'),
    ('40001', 'Conflicto de transacción, intente nuevamente'),
    ('40P01', 'Se detectó un bloqueo entre procesos'),
    ('42501', 'No tiene permisos para realizar esta acción'),
    ('08003', 'La conexión no está activa'),
    ('08006', 'Error en la conexión a la base de datos'),
    ('53000', 'Recursos insuficientes'),
    ('53100', 'No hay espacio en disco'),
    ('53200', 'Memoria insuficiente'),
    ('25000', 'Estado de transacción inválido'),
    ('25P02', 'La transacción falló previamente'),
    ('P0001', 'Error generado manualmente'),
    ('P0002', 'No se encontraron resultados'),
    ('P0003', 'Se encontraron demasiados resultados'),
    ('21000', 'Error: se esperaban menos resultados'),
    ('2200F', 'Texto vacío no permitido'),
    ('2200L', 'Documento XML inválido'),
    ('22032', 'JSON inválido')
ON CONFLICT DO NOTHING;

-- ===================================================================
-- 8. FUNCIÓN DE MENSAJES DE ERROR
-- ===================================================================
CREATE OR REPLACE FUNCTION public.fun_mensaje_error(
    p_sqlstate TEXT,
    p_sqlerrm  TEXT
)
RETURNS TEXT AS
$$
DECLARE
    v_mensaje TEXT;
BEGIN
    -- Caso especial: error manual (nuestras validaciones)
    IF p_sqlstate = 'P0001' THEN
        RETURN COALESCE(p_sqlerrm, 'Ocurrió un error inesperado.');
    END IF;

    -- Para errores del sistema: buscar mensaje amigable en tabla
    SELECT mensaje INTO v_mensaje 
    FROM tab_cat_errores
    WHERE cod_sqlstate = p_sqlstate;

    -- Si existe en tabla, usarlo; si no, genérico
    RETURN COALESCE(v_mensaje, 'Ocurrió un error inesperado.');
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 9. FUNCIONES DE DEPARTAMENTOS
-- ===================================================================

-- -------------------------------------------------------------------
-- 9.1 INSERTAR DEPARTAMENTO
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_dptos(
    wid_dpto  public.tab_dptos.id_dpto%TYPE,
    wnom_dpto public.tab_dptos.nom_dpto%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    IF wnom_dpto IS NULL THEN
        RAISE EXCEPTION 'El nombre del departamento no puede ser nulo';
    END IF;

    -- Validar duplicado
    IF EXISTS (SELECT 1 FROM public.tab_dptos WHERE id_dpto = wid_dpto) THEN
        RAISE EXCEPTION 'El departamento con id % ya existe', wid_dpto;
    END IF;

    -- Validar formato ID (2 dígitos numéricos)
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
    END IF;

    -- Validar longitud del nombre
    IF LENGTH(wnom_dpto) < 4 OR LENGTH(wnom_dpto) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    -- Validar que el nombre solo tenga letras y espacios
    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios.';
    END IF;
    
    -- Insertar con ind_borrado = FALSE
    INSERT INTO public.tab_dptos VALUES (wid_dpto, wnom_dpto, FALSE);

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 9.2 ACTUALIZAR DEPARTAMENTO
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_update_dptos(
    wid_dpto  public.tab_dptos.id_dpto%TYPE,
    wnom_dpto public.tab_dptos.nom_dpto%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    IF wnom_dpto IS NULL THEN
        RAISE EXCEPTION 'El nombre del departamento no puede ser nulo';
    END IF;

    -- Validar existencia y estado activo
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_dptos 
                   WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con id % no existe o no esta activo', wid_dpto;
    END IF;

    -- Validar formato ID
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
    END IF;

    -- Validar longitud del nombre
    IF LENGTH(wnom_dpto) < 4 OR LENGTH(wnom_dpto) > 20 THEN
        RAISE EXCEPTION 'El nombre del departamento debe tener entre 4 y 20 caracteres';
    END IF;

    -- Validar caracteres del nombre
    IF wnom_dpto !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre del departamento solo debe contener letras y espacios.';
    END IF;

    -- Actualizar
    UPDATE public.tab_dptos 
    SET nom_dpto = wnom_dpto
    WHERE id_dpto = wid_dpto;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 9.3 ELIMINAR DEPARTAMENTO (Borrado Lógico)
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_dptos(
    wid_dpto public.tab_dptos.id_dpto%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    -- Validar formato ID
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
    END IF;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_dptos 
                   WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con id % no existe o ya fue eliminado', wid_dpto;
    END IF;

    -- Validar que no tenga ciudades asociadas activas
    IF EXISTS (SELECT 1 
               FROM public.tab_ciudades 
               WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'No se puede eliminar el departamento % porque tiene ciudades asociadas activas', wid_dpto;
    END IF;
    
    -- Borrado lógico
    UPDATE public.tab_dptos 
    SET ind_borrado = TRUE 
    WHERE id_dpto = wid_dpto;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 9.4 RESTAURAR DEPARTAMENTO
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_restore_dptos(
    wid_dpto public.tab_dptos.id_dpto%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    -- Validar formato ID
    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
    END IF;

    -- Validar existencia y estado eliminado
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_dptos 
                   WHERE id_dpto = wid_dpto AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'El departamento con id % no existe o no está eliminado', wid_dpto;
    END IF;
    
    -- Restaurar (borrado lógico a FALSE)
    UPDATE public.tab_dptos 
    SET ind_borrado = FALSE 
    WHERE id_dpto = wid_dpto AND ind_borrado = TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 10. FUNCIONES DE CIUDADES
-- ===================================================================

-- -------------------------------------------------------------------
-- 10.1 INSERTAR CIUDAD
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_ciudades(
    wid_ciudad     public.tab_ciudades.id_ciudad%TYPE,
    wnom_ciudad    public.tab_ciudades.nom_ciudad%TYPE,
    wid_dpto       public.tab_ciudades.id_dpto%TYPE,
    wind_capital   public.tab_ciudades.ind_capital%TYPE,
    wcod_postal    public.tab_ciudades.cod_postal%TYPE,
    wval_latitud   public.tab_ciudades.val_latitud%TYPE,
    wval_longitud  public.tab_ciudades.val_longitud%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validaciones de nulo
    IF wid_ciudad IS NULL THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede ser nula';
    END IF;

    IF wnom_ciudad IS NULL THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede ser nulo';
    END IF;

    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL THEN
        RAISE EXCEPTION 'El código postal no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'El valor de la latitud no puede ser nulo';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'El valor de la longitud no puede ser nulo';
    END IF;

    -- Validar duplicado
    IF EXISTS (SELECT 1 FROM public.tab_ciudades WHERE id_ciudad = wid_ciudad) THEN
        RAISE EXCEPTION 'La ciudad con id % ya existe', wid_ciudad;
    END IF;

    -- Validar existencia del departamento
    IF NOT EXISTS (SELECT 1 
                   FROM tab_dptos 
                   WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento % no existe o no está activo', wid_dpto;
    END IF;

    -- Validar formatos y longitudes
    IF LENGTH(wid_ciudad) <> 5 THEN
        RAISE EXCEPTION 'El id_ciudad debe tener exactamente 5 caracteres';
    END IF;

    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF LENGTH(wid_dpto) <> 2 THEN
        RAISE EXCEPTION 'El id_dpto debe tener exactamente 2 caracteres';
    END IF;

    IF LENGTH(wcod_postal) <> 6 THEN
        RAISE EXCEPTION 'El código postal debe tener exactamente 6 caracteres';
    END IF;

    -- Validar rangos de latitud y longitud
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'Latitud fuera de rango permitido (-4 a 80)';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'Longitud fuera de rango permitido (-80 a -50)';
    END IF;

    -- Validar que ind_capital sea booleano
    IF wind_capital NOT IN (TRUE, FALSE) THEN
        RAISE EXCEPTION 'El indicador de capital debe ser TRUE o FALSE';
    END IF;
    
    -- Insertar con ind_borrado = FALSE
    INSERT INTO public.tab_ciudades VALUES (
        wid_ciudad, wnom_ciudad, wid_dpto, 
        wind_capital, wcod_postal, 
        wval_latitud, wval_longitud, FALSE
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 10.2 ACTUALIZAR CIUDAD
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_update_ciudades(
    wid_ciudad     public.tab_ciudades.id_ciudad%TYPE,
    wnom_ciudad    public.tab_ciudades.nom_ciudad%TYPE,
    wid_dpto       public.tab_ciudades.id_dpto%TYPE,
    wind_capital   public.tab_ciudades.ind_capital%TYPE,
    wcod_postal    public.tab_ciudades.cod_postal%TYPE,
    wval_latitud   public.tab_ciudades.val_latitud%TYPE,
    wval_longitud  public.tab_ciudades.val_longitud%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validaciones de nulo
    IF wid_ciudad IS NULL THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede ser nula';
    END IF;

    IF wnom_ciudad IS NULL THEN
        RAISE EXCEPTION 'El nombre de la ciudad no puede ser nulo';
    END IF;

    IF wid_dpto IS NULL THEN
        RAISE EXCEPTION 'El ID del departamento no puede ser nulo';
    END IF;

    IF wind_capital IS NULL THEN
        RAISE EXCEPTION 'El indicador de capital no puede ser nulo';
    END IF;

    IF wcod_postal IS NULL THEN
        RAISE EXCEPTION 'El código postal no puede ser nulo';
    END IF;

    IF wval_latitud IS NULL THEN
        RAISE EXCEPTION 'El valor de la latitud no puede ser nulo';
    END IF;

    IF wval_longitud IS NULL THEN
        RAISE EXCEPTION 'El valor de la longitud no puede ser nulo';
    END IF;

    -- Validar formatos numéricos
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de 5 dígitos.';
    END IF;

    IF wid_dpto !~ '^[0-9]{2}$' THEN
        RAISE EXCEPTION 'El ID del departamento debe ser numérico de 2 dígitos.';
    END IF;

    IF wcod_postal !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'El código postal debe ser numérico de 6 dígitos.';
    END IF;

    -- Validar caracteres del nombre
    IF wnom_ciudad !~ '^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$' THEN
        RAISE EXCEPTION 'El nombre de la ciudad solo debe contener letras y espacios.';
    END IF;

    -- Validar existencia de la ciudad activa
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_ciudades 
                   WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con id % no existe o no esta activa', wid_ciudad;
    END IF;

    -- Validar existencia del departamento activo
    IF NOT EXISTS (SELECT 1 
                   FROM tab_dptos 
                   WHERE id_dpto = wid_dpto AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'El departamento con id % no existe o no esta activo', wid_dpto;
    END IF;

    -- Validar longitudes
    IF LENGTH(wid_ciudad) <> 5 THEN
        RAISE EXCEPTION 'El id_ciudad debe tener exactamente 5 caracteres';
    END IF;

    IF LENGTH(wnom_ciudad) < 3 OR LENGTH(wnom_ciudad) > 30 THEN
        RAISE EXCEPTION 'El nombre de la ciudad debe tener entre 3 y 30 caracteres';
    END IF;

    IF LENGTH(wid_dpto) <> 2 THEN
        RAISE EXCEPTION 'El id_dpto debe tener exactamente 2 caracteres';
    END IF;

    IF LENGTH(wcod_postal) <> 6 THEN
        RAISE EXCEPTION 'El código postal debe tener exactamente 6 caracteres';
    END IF;

    -- Validar rangos
    IF wval_latitud < -4 OR wval_latitud > 80 THEN
        RAISE EXCEPTION 'Latitud fuera de rango permitido (-4 a 80)';
    END IF;

    IF wval_longitud < -80 OR wval_longitud > -50 THEN
        RAISE EXCEPTION 'Longitud fuera de rango permitido (-80 a -50)';
    END IF;
    
    -- Actualizar
    UPDATE public.tab_ciudades SET 
        nom_ciudad   = wnom_ciudad,
        id_dpto      = wid_dpto,
        ind_capital  = wind_capital,
        cod_postal   = wcod_postal,
        val_latitud  = wval_latitud,
        val_longitud = wval_longitud 
    WHERE id_ciudad = wid_ciudad;
        
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 10.3 ELIMINAR CIUDAD (Borrado Lógico)
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_ciudades(
    wid_ciudad public.tab_ciudades.id_ciudad%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_ciudad IS NULL THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede ser nula';
    END IF;

    -- Validar formato numérico
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de 5 dígitos.';
    END IF;

    -- Validar existencia y estado activo
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_ciudades 
                   WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La ciudad con id % no existe o ya fue eliminada', wid_ciudad;
    END IF;

    -- Validar que no esté referenciada en terceros
    IF EXISTS (SELECT 1 
               FROM public.tab_terceros 
               WHERE id_ciudad = wid_ciudad AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'No se puede eliminar la ciudad porque está presente en terceros';
    END IF;
    
    -- Borrado lógico
    UPDATE public.tab_ciudades 
    SET ind_borrado = TRUE 
    WHERE id_ciudad = wid_ciudad;
        
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- -------------------------------------------------------------------
-- 10.4 RESTAURAR CIUDAD
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_restore_ciudades(
    wid_ciudad public.tab_ciudades.id_ciudad%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_ciudad IS NULL THEN
        RAISE EXCEPTION 'El ID de la ciudad no puede ser nulo';
    END IF;

    -- Validar formato numérico
    IF wid_ciudad !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'El ID de la ciudad debe ser numérico de 5 dígitos.';
    END IF;

    -- Validar existencia y estado eliminado
    IF NOT EXISTS (SELECT 1 
                   FROM public.tab_ciudades 
                   WHERE id_ciudad = wid_ciudad AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'La ciudad con id % no existe o no está eliminada', wid_ciudad;
    END IF;
    
    -- Restaurar lógico
    UPDATE public.tab_ciudades 
    SET ind_borrado = FALSE 
    WHERE id_ciudad = wid_ciudad;
        
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE PLPGSQL;

-- ===================================================================
-- 11. FUNCIONES DE PARÁMETROS GENERALES
-- ===================================================================

-- -------------------------------------------------------------------
-- 11.1 INSERTAR PARÁMETROS GENERALES
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_pmtros_grales(
    wid_empresa        public.tab_pmtros_grales.id_empresa%TYPE,
    wnom_empresa       public.tab_pmtros_grales.nom_empresa%TYPE,
    wdatos_residencia  public.tab_pmtros_grales.datos_residencia%TYPE,
    wnom_replegal      public.tab_pmtros_grales.nom_replegal%TYPE,
    wval_poriva        public.tab_pmtros_grales.val_poriva%TYPE,
    wval_pordesc       public.tab_pmtros_grales.val_pordesc%TYPE,
    wval_porrete       public.tab_pmtros_grales.val_porrete%TYPE,
    wval_reteica       public.tab_pmtros_grales.val_reteica%TYPE,
    wval_porutil       public.tab_pmtros_grales.val_porutil%TYPE,
    wval_latitud       public.tab_pmtros_grales.val_latitud%TYPE,
    wval_longitud      public.tab_pmtros_grales.val_longitud%TYPE,
    wval_color_letra   public.tab_pmtros_grales.color_letra%TYPE,
    wval_color_logo    public.tab_pmtros_grales.color_logo%TYPE,
    wval_color_fondo   public.tab_pmtros_grales.color_fondo%TYPE,
    wind_autorete      public.tab_pmtros_grales.ind_autorete%TYPE
)
RETURNS VOID AS
$$
DECLARE
    wanio_fiscal DECIMAL(4,0);
    wmes_fiscal  DECIMAL(2,0);
BEGIN
    -- Validaciones de nulo
    IF wid_empresa IS NULL THEN
        RAISE EXCEPTION 'El ID de la empresa no puede ser nulo';
    END IF;

    IF wnom_empresa IS NULL THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede ser nulo';
    END IF;

    IF wnom_replegal IS NULL THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede ser nulo';
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

    IF wval_color_letra IS NULL THEN
        RAISE EXCEPTION 'El color de la letra no puede ser nulo';
    END IF;

    IF wval_color_logo IS NULL THEN
        RAISE EXCEPTION 'El color del logo no puede ser nulo';
    END IF;

    IF wval_color_fondo IS NULL THEN
        RAISE EXCEPTION 'El color del fondo no puede ser nulo';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    -- Validaciones de formato y rango
    IF wid_empresa < 10000000 OR wid_empresa > 9999999999 THEN
        RAISE EXCEPTION 'El ID de la empresa debe estar entre 8 y 10 digitos';
    END IF;

    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
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

    -- Colores (formato #XXXXXX)
    IF LENGTH(wval_color_letra) != 7 THEN
        RAISE EXCEPTION 'El color de la letra debe tener 7 caracteres (incluyendo #).';
    END IF;

    IF LENGTH(wval_color_logo) != 7 THEN
        RAISE EXCEPTION 'El color del logo debe tener 7 caracteres (incluyendo #).';
    END IF;

    IF LENGTH(wval_color_fondo) != 7 THEN
        RAISE EXCEPTION 'El color del fondo debe tener 7 caracteres (incluyendo #).';
    END IF;

    -- Validar duplicado
    IF EXISTS (SELECT 1 FROM tab_pmtros_grales WHERE id_empresa = wid_empresa) THEN
        RAISE EXCEPTION 'Ya existe un registro para la empresa con ID %', wid_empresa;
    END IF;

    -- Asignar año y mes fiscal
    wanio_fiscal := EXTRACT(YEAR FROM CURRENT_DATE);
    wmes_fiscal  := EXTRACT(MONTH FROM CURRENT_DATE);

    -- Insertar
    INSERT INTO tab_pmtros_grales (
        id_empresa, nom_empresa, datos_residencia, nom_replegal,
        val_poriva, val_pordesc, val_porrete, val_reteica, val_porutil,
        val_latitud, val_longitud, color_letra, color_logo, color_fondo,
        anio_fiscal, mes_fiscal, ind_autorete, ind_borrado
    ) VALUES (
        wid_empresa, wnom_empresa, wdatos_residencia, wnom_replegal,
        wval_poriva, wval_pordesc, wval_porrete, wval_reteica, wval_porutil,
        wval_latitud, wval_longitud, wval_color_letra, wval_color_logo, wval_color_fondo,
        wanio_fiscal, wmes_fiscal, wind_autorete, FALSE
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 11.2 ACTUALIZAR PARÁMETROS GENERALES
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_update_pmtros_grales(
    wid_empresa        public.tab_pmtros_grales.id_empresa%TYPE,
    wnom_empresa       public.tab_pmtros_grales.nom_empresa%TYPE,
    wdatos_residencia  public.tab_pmtros_grales.datos_residencia%TYPE,
    wnom_replegal      public.tab_pmtros_grales.nom_replegal%TYPE,
    wval_poriva        public.tab_pmtros_grales.val_poriva%TYPE,
    wval_pordesc       public.tab_pmtros_grales.val_pordesc%TYPE,
    wval_porrete       public.tab_pmtros_grales.val_porrete%TYPE,
    wval_reteica       public.tab_pmtros_grales.val_reteica%TYPE,
    wval_porutil       public.tab_pmtros_grales.val_porutil%TYPE,
    wval_latitud       public.tab_pmtros_grales.val_latitud%TYPE,
    wval_longitud      public.tab_pmtros_grales.val_longitud%TYPE,
    wcolor_letra       public.tab_pmtros_grales.color_letra%TYPE,
    wcolor_logo        public.tab_pmtros_grales.color_logo%TYPE,
    wcolor_fondo       public.tab_pmtros_grales.color_fondo%TYPE,
    wind_autorete      public.tab_pmtros_grales.ind_autorete%TYPE
)
RETURNS VOID AS
$$
BEGIN
    -- Validaciones de nulo
    IF wid_empresa IS NULL THEN
        RAISE EXCEPTION 'El ID de la empresa no puede ser nulo';
    END IF;

    IF wnom_empresa IS NULL THEN
        RAISE EXCEPTION 'El nombre de la empresa no puede ser nulo';
    END IF;

    IF wnom_replegal IS NULL THEN
        RAISE EXCEPTION 'El nombre del representante legal no puede ser nulo';
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

    IF wcolor_letra IS NULL THEN
        RAISE EXCEPTION 'El color de la letra no puede ser nulo';
    END IF;

    IF wcolor_logo IS NULL THEN
        RAISE EXCEPTION 'El color del logo no puede ser nulo';
    END IF;

    IF wcolor_fondo IS NULL THEN
        RAISE EXCEPTION 'El color del fondo no puede ser nulo';
    END IF;

    IF wind_autorete IS NULL THEN
        RAISE EXCEPTION 'El indicador de autoretención no puede ser nulo';
    END IF;

    -- Validaciones de formato y rango
    IF wid_empresa < 10000000 OR wid_empresa > 9999999999 THEN
        RAISE EXCEPTION 'El ID de la empresa debe estar entre 8 y 10 digitos';
    END IF;

    IF LENGTH(wnom_empresa) < 5 OR LENGTH(wnom_empresa) > 60 THEN
        RAISE EXCEPTION 'El nombre de la empresa debe tener entre 5 y 60 caracteres';
    END IF;

    IF LENGTH(wnom_replegal) < 5 OR LENGTH(wnom_replegal) > 60 THEN
        RAISE EXCEPTION 'El nombre del representante legal debe tener entre 5 y 60 caracteres';
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

    IF LENGTH(wcolor_letra) != 7 THEN
        RAISE EXCEPTION 'El color de la letra debe tener 7 caracteres (incluyendo #).';
    END IF;

    IF LENGTH(wcolor_logo) != 7 THEN
        RAISE EXCEPTION 'El color del logo debe tener 7 caracteres (incluyendo #).';
    END IF;

    IF LENGTH(wcolor_fondo) != 7 THEN
        RAISE EXCEPTION 'El color del fondo debe tener 7 caracteres (incluyendo #).';
    END IF;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 
                   FROM tab_pmtros_grales 
                   WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con id % no existe o no esta activa', wid_empresa;
    END IF;

    -- Actualizar (anio_fiscal y mes_fiscal NO se modifican)
    UPDATE tab_pmtros_grales SET 
        nom_empresa      = wnom_empresa,
        datos_residencia = wdatos_residencia,
        nom_replegal     = wnom_replegal,
        val_poriva       = wval_poriva,
        val_pordesc      = wval_pordesc,
        val_porrete      = wval_porrete,
        val_reteica      = wval_reteica,
        val_porutil      = wval_porutil,
        val_latitud      = wval_latitud,
        val_longitud     = wval_longitud,
        color_letra      = wcolor_letra,
        color_logo       = wcolor_logo,
        color_fondo      = wcolor_fondo,
        ind_autorete     = wind_autorete
    WHERE id_empresa = wid_empresa;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 11.3 ELIMINAR PARÁMETROS GENERALES
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_pmtros_grales(
    wid_empresa public.tab_pmtros_grales.id_empresa%TYPE
)
RETURNS VOID AS
$$
BEGIN
    -- Validación de nulo
    IF wid_empresa IS NULL THEN
        RAISE EXCEPTION 'El ID de la empresa no puede ser nulo';
    END IF;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 
                   FROM tab_pmtros_grales 
                   WHERE id_empresa = wid_empresa AND ind_borrado = FALSE) THEN
        RAISE EXCEPTION 'La empresa con id % no existe o ya fue eliminada', wid_empresa;
    END IF;

    -- Borrado lógico
    UPDATE tab_pmtros_grales 
    SET ind_borrado = TRUE 
    WHERE id_empresa = wid_empresa;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 11.4 RESTAURAR PARÁMETROS GENERALES
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_restore_pmtros_grales(
    wid_empresa public.tab_pmtros_grales.id_empresa%TYPE
)
RETURNS VOID AS 
$$
BEGIN
    -- Validación de nulo
    IF wid_empresa IS NULL THEN
        RAISE EXCEPTION 'El ID de la empresa no puede ser nulo';
    END IF;

    -- Validar existencia y estado eliminado
    IF NOT EXISTS (SELECT 1 
                   FROM tab_pmtros_grales 
                   WHERE id_empresa = wid_empresa AND ind_borrado = TRUE) THEN
        RAISE EXCEPTION 'La empresa con id % no existe o no está eliminada', wid_empresa;
    END IF;

    -- Restaurar
    UPDATE tab_pmtros_grales 
    SET ind_borrado = FALSE 
    WHERE id_empresa = wid_empresa;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', public.fun_mensaje_error(SQLSTATE, SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 12. FUNCIONES DE USUARIOS
-- ===================================================================

-- -------------------------------------------------------------------
-- 12.1 INSERTAR USUARIO
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_tab_usuarios(
    wid_usuario   tab_usuarios.id_usuario%TYPE,
    wnom_usuario  tab_usuarios.nom_usuario%TYPE,
    wpass_usuario tab_usuarios.pass_usuario%TYPE,
    wmail_usuario tab_usuarios.mail_usuario%TYPE,
    wind_usuario  tab_usuarios.ind_usuario%TYPE,
    wind_estado   tab_usuarios.ind_estado%TYPE
)
RETURNS TEXT AS $$
BEGIN
    -- Validación: nombre de usuario
    IF wnom_usuario IS NULL OR TRIM(wnom_usuario) = '' THEN
        RETURN 'ERROR: El nombre de usuario no puede estar vacío.';
    END IF;

    -- Validación: sin espacios
    IF wid_usuario ~ '\s' THEN
        RETURN 'ERROR: El usuario no puede contener espacios.';
    END IF;

    -- Validación: caracteres no permitidos
    IF wid_usuario ~ '[*"]' THEN
        RETURN 'ERROR: El nombre de usuario contiene caracteres no permitidos (* o ").';
    END IF;

    -- Validación: correo electrónico
    IF wmail_usuario IS NULL OR TRIM(wmail_usuario) = '' THEN
        RETURN 'ERROR: El correo electrónico no puede estar vacío.';
    END IF;

    IF wmail_usuario !~ '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' THEN
        RETURN 'ERROR: El correo electrónico no tiene un formato válido.';
    END IF;

    -- Validaciones de contraseña
    IF wpass_usuario IS NULL OR TRIM(wpass_usuario) = '' THEN
        RETURN 'ERROR: La contraseña no puede estar vacía.';
    END IF;

    IF LENGTH(wpass_usuario) < 12 THEN
        RETURN 'ERROR: La contraseña debe tener mínimo 12 caracteres.';
    END IF;

    IF wpass_usuario ~ '\s' THEN
        RETURN 'ERROR: La contraseña no puede contener espacios.';
    END IF;

    IF wpass_usuario !~ '[A-Z]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos una letra mayúscula.';
    END IF;

    IF wpass_usuario !~ '[a-z]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos una letra minúscula.';
    END IF;

    IF wpass_usuario !~ '[0-9]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos un número.';
    END IF;

    IF wpass_usuario !~ '[!@#$%^&*()\-_=+\[\]{}|;:,.<>?/\\~`''""]' THEN
        RETURN 'ERROR: La contraseña debe contener al menos un símbolo especial.';
    END IF;

    -- Insertar con ind_borrado = FALSE
    INSERT INTO tab_usuarios VALUES (
        wid_usuario, wnom_usuario, wpass_usuario, 
        wmail_usuario, wind_usuario, wind_estado, FALSE
    );

    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 12.2 ACTUALIZAR CONTRASEÑA (CON ENCRIPTACIÓN)
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_actualizar_password(
    wid_usuario TEXT,
    wpass_nuevo TEXT
)
RETURNS TEXT AS $$
BEGIN
    UPDATE tab_usuarios 
    SET pass_usuario = crypt(wpass_nuevo, gen_salt('bf'))
    WHERE id_usuario = wid_usuario;

    IF FOUND THEN
        RETURN 'OK';
    ELSE
        RETURN 'ERROR: Usuario no encontrado';
    END IF;

EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 12.3 ELIMINAR PERFIL DE USUARIO (ASIGNACIONES DE MENÚ)
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_perfil_usuario(
    wid_usuario tab_usuarios.id_usuario%TYPE
)
RETURNS VOID AS
$$
BEGIN
    DELETE FROM tab_menu_usuarios 
    WHERE id_usuario = wid_usuario;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 13. FUNCIONES DE MENÚS
-- ===================================================================

-- -------------------------------------------------------------------
-- 13.1 INSERTAR MENÚ
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_tab_menus(
    p_id_menu       tab_menus.id_menu%TYPE,
    p_nom_menu      tab_menus.nom_menu%TYPE,
    p_id_padre      tab_menus.ind_id_padre%TYPE,
    p_nom_programa  tab_menus.nom_programa%TYPE
)
RETURNS TEXT AS
$$
DECLARE
    v_exists        INTEGER;
    v_nom_len       INTEGER;
    v_padre_exists  INTEGER;
BEGIN
    -- Validación: ID único
    SELECT COUNT(*) INTO v_exists 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;

    IF v_exists > 0 THEN
        RETURN 'ERR: ID Menú ' || p_id_menu || ' ya existe';
    END IF;

    -- Validación: longitud del nombre
    v_nom_len := LENGTH(p_nom_menu);
    IF v_nom_len < 3 OR v_nom_len > 50 THEN
        RETURN 'ERR: Nombre de menú debe tener entre 3 y 50 caracteres (actual: ' || v_nom_len || ')';
    END IF;

    -- Validación: ID padre no nulo
    IF p_id_padre IS NULL THEN
        RETURN 'ERR: ID Padre no puede ser nulo';
    END IF;

    -- Validación: si padre no es '0', verificar que existe
    IF p_id_padre != '0' THEN
        SELECT COUNT(*) INTO v_padre_exists 
        FROM tab_menus 
        WHERE id_menu = p_id_padre;

        IF v_padre_exists = 0 THEN
            RETURN 'ERR: Menú padre ID ' || p_id_padre || ' no existe';
        END IF;
    END IF;

    -- Inserción con ind_borrado = FALSE
    INSERT INTO tab_menus VALUES (
        p_id_menu, 
        p_nom_menu, 
        p_id_padre, 
        COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica'), 
        FALSE
    );

    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 13.2 ACTUALIZAR MENÚ
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_update_tab_menus(
    p_id_menu       tab_menus.id_menu%TYPE,
    p_nom_menu      tab_menus.nom_menu%TYPE,
    p_id_padre      tab_menus.ind_id_padre%TYPE,
    p_nom_programa  tab_menus.nom_programa%TYPE
)
RETURNS TEXT AS
$$
DECLARE
    v_exists        INTEGER;
    v_nom_len       INTEGER;
    v_padre_exists  INTEGER;
BEGIN
    -- Validación: menú a actualizar existe
    SELECT COUNT(*) INTO v_exists 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;

    IF v_exists = 0 THEN
        RETURN 'ERR: Menú ID ' || p_id_menu || ' no existe';
    END IF;

    -- Validación: longitud del nombre
    v_nom_len := LENGTH(p_nom_menu);
    IF v_nom_len < 3 OR v_nom_len > 50 THEN
        RETURN 'ERR: Nombre de menú debe tener entre 3 y 50 caracteres (actual: ' || v_nom_len || ')';
    END IF;

    -- Validación: ID padre no nulo
    IF p_id_padre IS NULL THEN
        RETURN 'ERR: ID Padre no puede ser nulo';
    END IF;

    -- Validación: si padre no es '0', verificar que existe
    IF p_id_padre != '0' THEN
        SELECT COUNT(*) INTO v_padre_exists 
        FROM tab_menus 
        WHERE id_menu = p_id_padre;

        IF v_padre_exists = 0 THEN
            RETURN 'ERR: Menú padre ID ' || p_id_padre || ' no existe';
        END IF;
    END IF;

    -- Actualización
    UPDATE tab_menus SET 
        nom_menu     = p_nom_menu, 
        ind_id_padre = p_id_padre,
        nom_programa = COALESCE(NULLIF(TRIM(p_nom_programa), ''), 'no_aplica')
    WHERE id_menu = p_id_menu;
    
    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 13.3 ELIMINAR MENÚ
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_tab_menus(
    p_id_menu tab_menus.id_menu%TYPE
)
RETURNS TEXT AS
$$
DECLARE
    v_exists        INTEGER;
    v_tiene_hijos   INTEGER;
    v_tiene_usuarios INTEGER;
BEGIN
    -- Validación: menú existe
    SELECT COUNT(*) INTO v_exists 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;

    IF v_exists = 0 THEN
        RETURN 'ERR: Menú ID ' || p_id_menu || ' no existe';
    END IF;

    -- Validación: no tiene menús hijos
    SELECT COUNT(*) INTO v_tiene_hijos 
    FROM tab_menus 
    WHERE ind_id_padre = p_id_menu;

    IF v_tiene_hijos > 0 THEN
        RETURN 'ERR_CON_HIJOS: Menú ID ' || p_id_menu || ' tiene ' || v_tiene_hijos || ' submenús. Elimine primero los hijos.';
    END IF;

    -- Validación: no tiene usuarios asignados
    SELECT COUNT(*) INTO v_tiene_usuarios 
    FROM tab_menu_usuarios 
    WHERE id_menu = p_id_menu;

    IF v_tiene_usuarios > 0 THEN
        RETURN 'ERR_CON_USUARIOS: Menú ID ' || p_id_menu || ' está asignado a ' || v_tiene_usuarios || ' usuario(s). Remueva accesos primero.';
    END IF;

    -- Eliminación
    DELETE FROM tab_menus 
    WHERE id_menu = p_id_menu;

    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        RETURN 'ERR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 14. FUNCIONES DE MENÚS DE USUARIOS
-- ===================================================================

-- -------------------------------------------------------------------
-- 14.1 INSERTAR MENÚ DE USUARIO
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_insert_menu_usuarios(
    p_id_usuario tab_usuarios.id_usuario%TYPE,
    p_id_menu    tab_menus.id_menu%TYPE
)
RETURNS VOID AS
$$
BEGIN
    -- Validar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM tab_usuarios WHERE id_usuario = p_id_usuario) THEN
        RAISE EXCEPTION 'El usuario % no existe en tab_usuarios', p_id_usuario;
    END IF;

    -- Validar que el menú existe
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = p_id_menu) THEN
        RAISE EXCEPTION 'El menú % no existe en tab_menus', p_id_menu;
    END IF;

    -- Insertar la relación
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
    VALUES (p_id_usuario, p_id_menu);

EXCEPTION
    WHEN unique_violation THEN
        -- El usuario ya tiene ese menú asignado, ignorar silenciosamente
        NULL;
    WHEN FOREIGN_KEY_VIOLATION THEN
        RAISE EXCEPTION 'Error de integridad referencial: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------
-- 14.2 ELIMINAR MENÚ DE USUARIO POR MENÚ
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_delete_menu_usuarios_por_menu(
    wid_menu tab_menus.id_menu%TYPE
)
RETURNS VOID AS
$$
BEGIN
    -- Validar que el menú existe
    IF NOT EXISTS (SELECT 1 FROM tab_menus WHERE id_menu = wid_menu) THEN
        RAISE EXCEPTION 'El menú % no existe en tab_menus', wid_menu;
    END IF;

    -- Eliminar todos los accesos de usuarios asociados al menú
    DELETE FROM tab_menu_usuarios WHERE id_menu = wid_menu;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 15. FUNCIONES DE SESIÓN
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_registrar_sesion(
    p_user  TEXT, 
    p_token TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_state TEXT;
    v_msg   TEXT;
BEGIN
    INSERT INTO tab_sesiones (id_usuario, token_sesion, fec_inicio, ult_actividad)
    VALUES (p_user, p_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (id_usuario) 
    DO UPDATE SET 
        token_sesion   = EXCLUDED.token_sesion,
        ult_actividad  = CURRENT_TIMESTAMP;

    RETURN 'OK';

EXCEPTION 
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_state = RETURNED_SQLSTATE, v_msg = MESSAGE_TEXT;
        RAISE EXCEPTION 'SQLSTATE: %, MENSAJE: %', v_state, v_msg;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 16. TRIGGERS
-- ===================================================================

-- -------------------------------------------------------------------
-- 16.1 TRIGGER PARA DESASIGNAR MENÚ AL ELIMINAR
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_trigger_desasignar_menu() 
RETURNS TRIGGER AS
$$
BEGIN
    PERFORM fun_delete_menu_usuarios_por_menu(OLD.id_menu);
    RETURN OLD;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en trigger para menú %: %', OLD.id_menu, SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS tg_desasignar_menu ON tab_menus;

CREATE TRIGGER tg_desasignar_menu
    BEFORE DELETE ON tab_menus 
    FOR EACH ROW
    EXECUTE FUNCTION fun_trigger_desasignar_menu();

-- -------------------------------------------------------------------
-- 16.2 TRIGGER PARA ASIGNAR MENÚ 99 A NUEVOS USUARIOS
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_trigger_menu() 
RETURNS TRIGGER AS
$$
DECLARE 
    wid_menu tab_menus.id_menu%TYPE;
BEGIN
    SELECT id_menu INTO wid_menu 
    FROM tab_menus 
    WHERE id_menu = '99';

    IF FOUND THEN
        INSERT INTO tab_menu_usuarios (id_usuario, id_menu) 
        VALUES (NEW.id_usuario, wid_menu);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_menu_usuarios ON tab_usuarios;

CREATE TRIGGER tg_menu_usuarios
    AFTER INSERT ON tab_usuarios 
    FOR EACH ROW
    EXECUTE FUNCTION fun_trigger_menu();

-- -------------------------------------------------------------------
-- 16.3 TRIGGER PARA ASIGNAR NUEVOS MENÚS AL ADMIN
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_trigger_menu_admin() 
RETURNS TRIGGER AS
$$
DECLARE 
    wid_usuario tab_usuarios.id_usuario%TYPE;
BEGIN
    SELECT id_usuario INTO wid_usuario 
    FROM tab_usuarios 
    WHERE id_usuario = 'admin';

    IF FOUND THEN
        INSERT INTO tab_menu_usuarios (id_usuario, id_menu) 
        VALUES (wid_usuario, NEW.id_menu);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_menu_admin ON tab_menus;

CREATE TRIGGER tg_menu_admin
    AFTER INSERT ON tab_menus 
    FOR EACH ROW
    EXECUTE FUNCTION fun_trigger_menu_admin();

-- -------------------------------------------------------------------
-- 16.4 TRIGGER DE AUDITORÍA
-- -------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fun_audit_trail() 
RETURNS TRIGGER AS $$
DECLARE 
    w_old_data   JSONB;
    w_new_data   JSONB;
    w_operacion  CHAR(1);
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        w_old_data := to_jsonb(OLD);
        w_new_data := to_jsonb(NEW);
        
        -- Detectar borrado/restauración lógica
        IF (OLD.ind_borrado = FALSE AND NEW.ind_borrado = TRUE) THEN
            w_operacion := 'D';  -- DELETE lógico
        ELSIF (OLD.ind_borrado = TRUE AND NEW.ind_borrado = FALSE) THEN
            w_operacion := 'R';  -- RESTORE
        ELSE
            w_operacion := 'U';  -- UPDATE normal
        END IF;  
        
    ELSIF (TG_OP = 'INSERT') THEN
        w_old_data  := NULL;
        w_new_data  := to_jsonb(NEW);
        w_operacion := 'I';  -- INSERT
    ELSE
        RETURN NULL;
    END IF;

    -- Insertar registro de auditoría
    INSERT INTO tab_audit_trail (
        nom_esquema, nom_tabla, ind_operacion, 
        usuario_erp_id, fec_registro, datos_viejos, datos_nuevos
    ) VALUES (
        TG_TABLE_SCHEMA, TG_TABLE_NAME, w_operacion,
        NULL, CURRENT_TIMESTAMP, w_old_data, w_new_data
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===================================================================
-- 17. DATOS INICIALES DE PRUEBA
-- ===================================================================

-- -------------------------------------------------------------------
-- 17.1 Usuario Administrador (contraseña encriptada: Admin12345678!)
-- -------------------------------------------------------------------
INSERT INTO tab_usuarios (
    id_usuario, nom_usuario, pass_usuario, mail_usuario, 
    ind_usuario, ind_estado, ind_borrado
) VALUES (
    'admin', 
    'Administrador del Sistema', 
    crypt('Admin12345678!', gen_salt('bf')),
    'admin@correo.edu', 
    TRUE, 
    TRUE, 
    FALSE
) ON CONFLICT (id_usuario) DO NOTHING;

-- -------------------------------------------------------------------
-- 17.2 Menú 99 por defecto para usuarios nuevos (opción de salida)
-- -------------------------------------------------------------------
INSERT INTO tab_menus (
    id_menu, nom_menu, ind_id_padre, nom_programa, ind_borrado
) VALUES (
    '99', 'Exit', '0', 'logout.php', FALSE
) ON CONFLICT (id_menu) DO NOTHING;

-- ===================================================================
-- 18. PARTICIONES DE AUDITORÍA (CREAR PRIMERA PARTICIÓN)
-- ===================================================================
DO $$
DECLARE
    wfecha  TEXT;
    wnombre TEXT;
BEGIN
    wfecha  := to_char(CURRENT_DATE, 'YYYY_MM');
    wnombre := 'audit_' || wfecha;
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF tab_audit_trail 
         FOR VALUES FROM (%L) TO (%L)',
        wnombre, 
        date_trunc('month', CURRENT_DATE), 
        date_trunc('month', CURRENT_DATE) + interval '1 month'
    );
END $$;

-- ===================================================================
-- 19. ASIGNAR TRIGGERS DE AUDITORÍA A TABLAS PRINCIPALES
-- ===================================================================

-- Tabla de departamentos
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_dptos;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_dptos 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- Tabla de ciudades
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_ciudades;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_ciudades 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- Tabla de usuarios
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_usuarios;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_usuarios 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- Tabla de menús
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_menus;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_menus 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- Tabla de terceros
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_terceros;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_terceros 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- Tabla de áreas
DROP TRIGGER IF EXISTS tri_audit_trail ON tab_areas;
CREATE TRIGGER tri_audit_trail 
    AFTER INSERT OR UPDATE ON tab_areas 
    FOR EACH ROW 
    EXECUTE FUNCTION fun_audit_trail();

-- ===================================================================
-- FIN DEL SCRIPT DE INSTALACIÓN COMPLETO
-- ===================================================================