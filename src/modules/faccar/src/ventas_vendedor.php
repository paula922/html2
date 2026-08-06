<?php
// ==================================================
// Módulo: Ventas por Vendedor (ERP ADSO)
// Tablas: tab_enc_facturas, tab_vendedores
// ==================================================

$pageTitle    = 'ERP ADSO — Ventas por Vendedor';
$activeModule = 'ventas_vendedor';
$page_title   = 'ADSOERP | Ventas por Vendedor';
$page_description = 'Ranking de ventas y comisiones por vendedor en un periodo';
$page_icon    = 'bi-bar-chart';
$page_extra_css = ["../modules/faccar/css/ventas_vendedor.css"];
$page_extra_js  = ["../modules/faccar/js/ventas_vendedor.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>

<div id="mod-ventasvendedor" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Ventas por Vendedor</div>
            <div class="page-subtitle">Ranking de ventas y comisiones generadas en el periodo</div>
        </div>
    </div>

    <!-- Filtro de periodo -->
    <div class="filters-bar">
        <div class="form-group" style="margin:0;">
            <label style="margin-bottom:2px;">Desde</label>
            <input type="date" id="rv-desde" class="form-control" style="border-radius:30px;">
        </div>
        <div class="form-group" style="margin:0;">
            <label style="margin-bottom:2px;">Hasta</label>
            <input type="date" id="rv-hasta" class="form-control" style="border-radius:30px;">
        </div>
        <button id="btn-rv-aplicar" class="btn-nuevo"><i class="fas fa-filter"></i> Aplicar</button>
        <span class="filter-info" id="rv-rango-label"></span>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-sack-dollar"></i></div>
            <div>
                <div class="stat-label">Total Vendido</div>
                <div class="stat-value" id="stat-rv-total" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-receipt"></i></div>
            <div>
                <div class="stat-label">Facturas Emitidas</div>
                <div class="stat-value" id="stat-rv-facturas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="fas fa-percent"></i></div>
            <div>
                <div class="stat-label">Total Comisiones</div>
                <div class="stat-value" id="stat-rv-comisiones" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-trophy"></i></div>
            <div>
                <div class="stat-label">Mejor Vendedor</div>
                <div class="stat-value" id="stat-rv-mejor" style="font-size:16px;">—</div>
            </div>
        </div>
    </div>

    <!-- Gráfico -->
    <div class="doc-card">
        <div class="form-section-title">Ventas por Vendedor</div>
        <div id="rv-chart-empty" class="empty-state">
            <i class="fas fa-chart-column"></i>
            <p>Sin datos para el periodo seleccionado</p>
            <span>Las ventas facturadas aparecerán graficadas aquí</span>
        </div>
        <canvas id="rv-chart" height="90" style="display:none;"></canvas>
    </div>

    <!-- Tabla ranking -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="50">#</th>
                    <th>Vendedor</th>
                    <th width="100">N° Facturas</th>
                    <th width="140">Total Vendido</th>
                    <th width="90">% Comisión</th>
                    <th width="140">Valor Comisión</th>
                </tr>
            </thead>
            <tbody id="rv-tbody">
                <tr><td colspan="6">
                    <div class="empty-state">
                        <i class="fas fa-user-tie"></i>
                        <p>Sin ventas registradas en el periodo</p>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>
