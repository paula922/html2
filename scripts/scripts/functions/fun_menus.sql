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
SELECT fun_insert_tab_menus ('21','Configuración','2','no_aplica');
SELECT fun_insert_tab_menus ('211','Parámetros','21','modules/faccar/src/pmtros_factura.php');
SELECT fun_insert_tab_menus ('212','Tablas Maestras','21','no_aplica');
SELECT fun_insert_tab_menus ('2121','Clientes','212','modules/faccar/src/clientes.php');
SELECT fun_insert_tab_menus ('2122','Vendedores','212','modules/faccar/src/vendedores.php');
SELECT fun_insert_tab_menus ('2123','Forma de Pago','212','modules/faccar/src/forma_pago.php');
SELECT fun_insert_tab_menus ('2124','Motivos Nota','212','modules/faccar/src/motivo_nota.php');
SELECT fun_insert_tab_menus ('213','Copia de Seguridad','21','no_aplica');
SELECT fun_insert_tab_menus ('22','Procesos','2','no_aplica');
SELECT fun_insert_tab_menus ('221','Cotizaciones','22','no_aplica');
SELECT fun_insert_tab_menus ('2211','Nueva Cotización','221','modules/faccar/src/nueva_cotizacion.php');
SELECT fun_insert_tab_menus ('2212','Listado de Cotizaciones','221','modules/src/faccar/listado_cotizaciones.php');
SELECT fun_insert_tab_menus ('222','Facturación','22','no_aplica');
SELECT fun_insert_tab_menus ('2221','Nueva Factura','222','modules/faccar/src/nueva_factura.php');
SELECT fun_insert_tab_menus ('2222','Listado de Facturas','222','modules/faccar/src/listado_facturas.php');
SELECT fun_insert_tab_menus ('2223','Facturas Electrónicas','222','modules/faccar/src/facturas_electronicas.php');
SELECT fun_insert_tab_menus ('223','Notas','22','no_aplica');
SELECT fun_insert_tab_menus ('2231','Crear Nota','223','modules/faccar/src/crear_nota.php');
SELECT fun_insert_tab_menus ('2232','Listado de Notas','223','modules/faccar/src/listado_notas.php');
SELECT fun_insert_tab_menus ('2233','Aplicar Saldo','223','modules/faccar/src/aplicar_saldo.php');
SELECT fun_insert_tab_menus ('224','Cartera','22','no_aplica');
SELECT fun_insert_tab_menus ('2241','Gestión','224','modules/faccar/src/gestion.php');
SELECT fun_insert_tab_menus ('2242','Castigar','224','modules/faccar/src/castigar.php');
SELECT fun_insert_tab_menus ('225','Pagos','22','modules/faccar/src/pagos.php');
SELECT fun_insert_tab_menus ('23','Analitica','2','no_aplica');
SELECT fun_insert_tab_menus ('231','Consultas','23','no_aplica');
SELECT fun_insert_tab_menus ('2311','Ventas por Vendedor','28','modules/faccar/src/ventas_vendedor.php');
SELECT fun_insert_tab_menus ('2312','Cartera por Tiempo','28','modules/faccar/src/cartera_tiempo.php');
SELECT fun_insert_tab_menus ('2313','Libro de Ventas','28','modules/faccar/src/libro_ventas.php');
v>
-- CARGA INICIAL DE COMPRAS Y PROVEEDORES

SELECT fun_insert_tab_menus('3','Compras Y Proveedores','0','no_aplica');
SELECT fun_insert_tab_menus('31','Dashboard','3','modules/compro/src/dashboard.php');
SELECT fun_insert_tab_menus('32','Proveedores','3','modules/compro/src/proveedores.php');
SELECT fun_insert_tab_menus('33','Productos','3','modules/compro/src/productos.php');
SELECT fun_insert_tab_menus('34','CatxProv','3','modules/compro/src/catxprov.php');
SELECT fun_insert_tab_menus('35','Solicitudes Compras','3','modules/src/compro/solicitudes_compra.php');
SELECT fun_insert_tab_menus('36','Ordenes de compra','3','modules/src/compro/ordencompra.php');
SELECT fun_insert_tab_menus('37','Seguimiento Orden Compra','3','modules/src/compro/seguimiento.php');

-- CARGA INICIAL DE TESORERIA Y CXP

SELECT fun_insert_tab_menus('4','Tesorería y Cuentas por Pagar','0','no_aplica');
SELECT fun_insert_tab_menus('41','Dashboard de Tesorería','4','modules/tescxp/dashboard.php');
SELECT fun_insert_tab_menus('42','Parámetros de Tesorería','4','modules/tescxp/pmtros_tescxp.php');
SELECT fun_insert_tab_menus('43','Días Festivos','4','modules/tescxp/festivos.php');
SELECT fun_insert_tab_menus('44','Caja Menor','4','modules/tescxp/caja_menor.php');
SELECT fun_insert_tab_menus('45','Cuentas por Empresa','4','modules/tescxp/ctas_empresa.php');
SELECT fun_insert_tab_menus('46','Cuentas por Proveedores','4','modules/tescxp/ctas_proveedores.php');
SELECT fun_insert_tab_menus('47','Cuentas por Pagar','4','modules/tescxp/cuentas_por_pagar.php');
SELECT fun_insert_tab_menus('48','Cronograma de Pagos','4','modules/tescxp/cronograma_pagos.php');
SELECT fun_insert_tab_menus('49','Archivo Plano','4','modules/tescxp/archivo_plano.php');

-- CARGA INICIAL DE MARKETING

SELECT fun_insert_tab_menus('5', 'Marketing & Comercial', '0', 'no_aplica');
SELECT fun_insert_tab_menus('51', 'Dashboard', '5', 'modules/marcom/dashboard.php');
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
SELECT fun_insert_tab_menus('586', 'KPIs', '58', 'modules/marcom/kpis.php');
SELECT fun_insert_tab_menus('587', 'Usuarios', '58', 'modules/marcom/config_usuarios.php');

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


SELECT fun_insert_tab_menus ('66', 'Parámetros contables', '6', 'modules/conpre/contab/parametros_contab.php');


-- CARGA INICIAL DE ANALISIS FINANCIERO

SELECT fun_insert_tab_menus('7', 'Análisis Financiero',  '0', 'no_aplica');
SELECT fun_insert_tab_menus('71', 'Dashboard Financiero',  '7', 'modules/conpre/financi/dashboard.php');
SELECT fun_insert_tab_menus('72', 'Indicadores',  '7', 'modules/conpre/financi/indicadores.php');
SELECT fun_insert_tab_menus('73', 'Inversores',  '7', 'modules/conpre/financi/inversores.php');
SELECT fun_insert_tab_menus('74', 'Proyectos',  '7', 'modules/conpre/financi/proyectos.php');
SELECT fun_insert_tab_menus('75', 'Inversiones',  '7', 'modules/conpre/financi/inversiones.php');
SELECT fun_insert_tab_menus('76', 'Reportes',  '7', 'modules/conpre/financi/reportes.php');

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

-- NÓMINA
SELECT fun_insert_tab_menus ('85', 'Nomina', '8', 'no_aplica');
SELECT fun_insert_tab_menus ('851', 'Conceptos', '85', 'modules/gehnom/src/conceptos.php');
SELECT fun_insert_tab_menus ('852', 'Novedades', '85', 'modules/gehnom/src/novedades.php');
SELECT fun_insert_tab_menus ('853', 'Liquidar Nomina', '85', 'modules/gehnom/src/liquidar_nomina.php');
SELECT fun_insert_tab_menus ('854', 'Nomina Electronica', '85', 'modules/gehnom/src/nomina_electronica.php');

-- CONFIGURACIÓN
SELECT fun_insert_tab_menus ('86', 'Configuracion', '8', 'no_aplica');

-- CARGA INICIAL DE SST

SELECT fun_insert_tab_menus  ('9','SST','0','no_aplica');
SELECT fun_insert_tab_menus  ('91','Resumen','9','modules/sesatr/src/dashboard.php');
SELECT fun_insert_tab_menus  ('92', 'Accidentes', '9', 'modules/sesatr/src/Accidentes.php');
SELECT fun_insert_tab_menus  ('93', 'Incapacidades','9', 'modules/sesatr/src/Incapacidades.php');
SELECT fun_insert_tab_menus  ('94', 'Capacitaciones', '9', 'modules/sesatr/src/Capacitaciones.php');
SELECT fun_insert_tab_menus  ('95', 'Auditoria', '9', 'modules/sesatr/src/Auditoria.php');
SELECT fun_insert_tab_menus  ('96', 'Empleados', '9', 'modules/sesatr/src/Copasst.php');
SELECT fun_insert_tab_menus  ('97', 'Brigadistas', '9', 'modules/sesatr/src/Brigadistas.php');
SELECT fun_insert_tab_menus  ('98', 'Examenes', '9', 'modules/sesatr/src/Examenes.php');
SELECT fun_insert_tab_menus  ('99', 'EPP','9', 'modules/sesatr/src/EPP.php');

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


--DELETE FROM tab_menus;
