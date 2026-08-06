<?php
// ==================================================
// Módulo: Listado de Cotizaciones (ERP ADSO)
// Tabla: tab_enc_cotizaciones
// ==================================================

$pageTitle    = 'ERP ADSO — Listado de Cotizaciones';
$activeModule = 'listado_cotizaciones';
$page_title   = 'ADSOERP | Cotizaciones';
$page_description = 'Historial de cotizaciones generadas';
$page_icon    = 'bi-file-earmark-text';
$page_extra_css = ["../modules/faccar/css/listado_cotizaciones.css"];
$page_extra_js  = ["../modules/faccar/js/listado_cotizaciones.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-listadocotizaciones" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Cotizaciones</div>
            <div class="page-subtitle">Historial y estado de las cotizaciones generadas</div>
        </div>
        <button id="btn-go-nueva-cot" class="btn-nuevo">
            <i class="fas fa-plus"></i> Nueva Cotización
        </button>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-file-lines"></i></div>
            <div>
                <div class="stat-label">Total Cotizaciones</div>
                <div class="stat-value" id="stat-lc-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div>
                <div class="stat-label">Vigentes</div>
                <div class="stat-value" id="stat-lc-vigentes">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-ban"></i></div>
            <div>
                <div class="stat-label">Vencidas</div>
                <div class="stat-value" id="stat-lc-vencidas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-sack-dollar"></i></div>
            <div>
                <div class="stat-label">Valor Cotizado</div>
                <div class="stat-value" id="stat-lc-valor" style="font-size:18px;">$0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="lc-search" placeholder="Buscar por N° o cliente...">
        </div>
        <select id="lc-estado-filter" class="filter-select">
            <option value="all">Todo estado</option>
            <option value="Vigente">Vigente</option>
            <option value="Vencida">Vencida</option>
        </select>
        <button id="btn-clear-lc-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="lc-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="110">N° Cotización</th>
                    <th>Cliente</th>
                    <th>Vendedor</th>
                    <th width="100">Fecha</th>
                    <th width="100">Vence</th>
                    <th width="120">Total</th>
                    <th width="90">Estado</th>
                    <th width="100">Acciones</th>
                </tr>
            </thead>
            <tbody id="lc-tbody">
                <tr><td colspan="8">
                    <div class="empty-state">
                        <i class="fas fa-file-lines"></i>
                        <p>Sin cotizaciones registradas</p>
                        <span>Las cotizaciones que generes aparecerán aquí</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL VER DETALLE -->
<div id="modal-ver-cot" class="modal-overlay hidden">
    <div class="modal-container modal-lg">
        <div class="modal-header blue">
            <h3><i class="fas fa-file-lines"></i> Detalle de Cotización <span id="ver-cot-id"></span></h3>
            <button class="modal-close btn-close-ver-cot">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-row">
                <div><span class="cell-muted">Cliente</span><div class="cell-strong" id="ver-cot-cliente">—</div></div>
                <div><span class="cell-muted">Vendedor</span><div class="cell-strong" id="ver-cot-vendedor">—</div></div>
            </div>
            <div class="form-row" style="margin-top:14px;">
                <div><span class="cell-muted">Fecha</span><div class="cell-strong" id="ver-cot-fecha">—</div></div>
                <div><span class="cell-muted">Vencimiento</span><div class="cell-strong" id="ver-cot-vencimiento">—</div></div>
                <div><span class="cell-muted">Estado</span><div class="cell-strong" id="ver-cot-estado">—</div></div>
            </div>
            <div class="form-section-title">Productos</div>
            <div class="table-card" style="border:none;">
                <table class="data-table">
                    <thead><tr><th>Producto</th><th>Cant.</th><th>Desc.</th><th>IVA</th><th>Neto</th></tr></thead>
                    <tbody id="ver-cot-lineas"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancelar btn-close-ver-cot">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- MODAL CONFIRMACIÓN -->
<div id="modal-confirm" class="modal-overlay hidden">
    <div class="modal-container confirm-box">
        <div class="confirm-icon"><i class="fas fa-exclamation-triangle"></i></div>
        <h4 id="confirm-title"></h4>
        <p id="confirm-body"></p>
        <div class="confirm-buttons">
            <button class="btn-cancelar" id="confirm-cancel-btn">Cancelar</button>
            <button class="btn-eliminar" id="confirm-ok-btn">Confirmar</button>
        </div>
    </div>
</div>

<!-- TOAST -->
<div id="toast" class="toast hidden">
    <i class="fas fa-check-circle"></i>
    <span id="toast-message"></span>
</div>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>
