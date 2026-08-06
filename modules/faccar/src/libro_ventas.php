<?php
// ==================================================
// Módulo: Libro de Ventas (ERP ADSO)
// Tabla: tab_enc_facturas (libro fiscal de ventas)
// ==================================================

$pageTitle    = 'ERP ADSO — Libro de Ventas';
$activeModule = 'libro_ventas';
$page_title   = 'ADSOERP | Libro de Ventas';
$page_description = 'Detalle cronológico de facturas para reporte fiscal';
$page_icon    = 'bi-journal-text';
$page_extra_css = ["../modules/faccar/css/libro_ventas.css"];
$page_extra_js  = ["../modules/faccar/js/libro_ventas.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-libroventas" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Libro de Ventas</div>
            <div class="page-subtitle">Detalle cronológico de facturas emitidas para reporte fiscal</div>
        </div>
        <button id="btn-lv-imprimir" class="btn-secundario">
            <i class="fas fa-print"></i> Imprimir
        </button>
    </div>

    <!-- Filtro de periodo -->
    <div class="filters-bar">
        <div class="form-group" style="margin:0;">
            <label style="margin-bottom:2px;">Desde</label>
            <input type="date" id="lv-desde" class="form-control" style="border-radius:30px;">
        </div>
        <div class="form-group" style="margin:0;">
            <label style="margin-bottom:2px;">Hasta</label>
            <input type="date" id="lv-hasta" class="form-control" style="border-radius:30px;">
        </div>
        <div class="search-wrapper" style="flex:1; min-width:160px;">
            <i class="fas fa-search"></i>
            <input type="text" id="lv-search" placeholder="Buscar cliente o N° factura...">
        </div>
        <button id="btn-lv-aplicar" class="btn-nuevo"><i class="fas fa-filter"></i> Aplicar</button>
    </div>

    <!-- Tabla -->
    <div class="table-card" id="lv-printable">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="100">Fecha</th>
                    <th width="100">N° Factura</th>
                    <th>Cliente</th>
                    <th width="110">Base Gravable</th>
                    <th width="100">Descuento</th>
                    <th width="90">IVA</th>
                    <th width="110">Total</th>
                </tr>
            </thead>
            <tbody id="lv-tbody">
                <tr><td colspan="7">
                    <div class="empty-state">
                        <i class="fas fa-journal-text"></i>
                        <p>Sin facturas en el periodo seleccionado</p>
                    </div>
                </td></tr>
            </tbody>
            <tfoot>
                <tr class="lv-totales-row">
                    <td colspan="3">TOTALES DEL PERIODO</td>
                    <td id="lv-tot-base">$0</td>
                    <td id="lv-tot-desc">$0</td>
                    <td id="lv-tot-iva">$0</td>
                    <td id="lv-tot-total">$0</td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>
