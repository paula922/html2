<?php
// ==================================================
// Módulo: Cartera por Tiempo (ERP ADSO)
// Tabla: tab_carteras (antigüedad de saldos)
// ==================================================

$pageTitle    = 'ERP ADSO — Cartera por Tiempo';
$activeModule = 'cartera_tiempo';
$page_title   = 'ADSOERP | Cartera por Tiempo';
$page_description = 'Antigüedad de saldos: cartera pendiente agrupada por rango de días de mora';
$page_icon    = 'bi-hourglass-split';
$page_extra_css = ["../modules/faccar/css/cartera_tiempo.css"];
$page_extra_js  = ["../modules/faccar/js/cartera_tiempo.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>

<div id="mod-carteratiempo" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Cartera por Tiempo</div>
            <div class="page-subtitle">Antigüedad de saldos: cartera pendiente agrupada por días de mora</div>
        </div>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-wallet"></i></div>
            <div>
                <div class="stat-label">Cartera Pendiente Total</div>
                <div class="stat-value" id="stat-ct-total" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div>
                <div class="stat-label">Al Día (0-30 días)</div>
                <div class="stat-value" id="stat-ct-aldiat" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-triangle-exclamation"></i></div>
            <div>
                <div class="stat-label">Crítica (+90 días)</div>
                <div class="stat-value" id="stat-ct-critica" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-user-clock"></i></div>
            <div>
                <div class="stat-label">Cliente con Mayor Deuda</div>
                <div class="stat-value" id="stat-ct-mayor" style="font-size:15px;">—</div>
            </div>
        </div>
    </div>

    <!-- Gráfico -->
    <div class="doc-card">
        <div class="form-section-title">Distribución por Rango de Mora</div>
        <div id="ct-chart-empty" class="empty-state">
            <i class="fas fa-chart-pie"></i>
            <p>Sin cartera pendiente registrada</p>
            <span>La distribución por antigüedad aparecerá aquí</span>
        </div>
        <canvas id="ct-chart" height="90" style="display:none;"></canvas>
    </div>

    <!-- Tabla de detalle por rango -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Cliente</th>
                    <th width="100">Factura</th>
                    <th width="110">Pendiente</th>
                    <th width="100">Días Mora</th>
                    <th width="120">Rango</th>
                </tr>
            </thead>
            <tbody id="ct-tbody">
                <tr><td colspan="5">
                    <div class="empty-state">
                        <i class="fas fa-wallet"></i>
                        <p>Sin cartera pendiente registrada</p>
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
