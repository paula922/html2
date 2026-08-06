select fun_insert_tab_menus ('2','Facturación y Cartera','0','no_aplica');
select fun_insert_tab_menus ('21','Cotizaciones','2','no_aplica');
select fun_insert_tab_menus ('211','Nueva Cotización','21','faccar/nueva_cotizacion.php');
select fun_insert_tab_menus ('212','Consultar Cotizaciones','21','faccar/consultar_cotizaciones.php');
select fun_insert_tab_menus ('22','Facturación','2','no_aplica');
select fun_insert_tab_menus ('221','Nueva Factura','22','faccar/nueva_factura.php');
select fun_insert_tab_menus ('222','Consultar Facturas','22','faccar/consultar_facturas.php');
select fun_insert_tab_menus ('23','Notas','2','no_aplica');
select fun_insert_tab_menus ('231','Notas De Crédito','23','faccar/nota_credito.php');
select fun_insert_tab_menus ('232','Notas De Débito','23','faccar/nota_debito.php');
select fun_insert_tab_menus ('233','Consultar Notas','23','faccar/consultar_notas.php');
select fun_insert_tab_menus ('24','Carteras','2','no_aplica');
select fun_insert_tab_menus ('241','Gestión de Carteras','24','faccar/gestion_carteras.php');
select fun_insert_tab_menus ('242','Seguimiento de Carteras','24','faccar/segimiento_carteras.php');
select fun_insert_tab_menus ('243','Condición de Pago','24','faccar/condicion_pago.php');
select fun_insert_tab_menus ('244','Registro de Pagos','24','faccar/registro_pagos.php');
select fun_insert_tab_menus ('25','Gestión','2','no_aplica');
select fun_insert_tab_menus ('251','Clientes','25','faccar/clientes.php');
select fun_insert_tab_menus ('252','Credito del Cliente','25','faccar/credito_cliente.php');
select fun_insert_tab_menus ('253','Vendedores','25','faccar/vendedores.php');
select fun_insert_tab_menus ('254','Parametros','25','faccar/parametros.php');

INSERT INTO tab_menu_usuarios (id_usuario, id_menu)
VALUES 
    ('admin', '2'),
    ('admin', '21'),
    ('admin', '211'),
    ('admin', '212'),
    ('admin', '22'),
    ('admin', '221'),
    ('admin', '222'),
    ('admin', '23'),
    ('admin', '231'),
    ('admin', '232'),
    ('admin', '233'),
    ('admin', '24'),
    ('admin', '241'),
    ('admin', '242'),
    ('admin', '243'),
    ('admin', '244'),
    ('admin', '25'),
    ('admin', '251'),
    ('admin', '252'),
    ('admin', '253'),
    ('admin', '254')    
ON CONFLICT (id_usuario, id_menu) DO NOTHING;