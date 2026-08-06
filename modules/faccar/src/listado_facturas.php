<?php
// ==================================================
// Módulo: Listado de Facturas (ERP ADSO)
// Tabla: tab_enc_facturas
// ==================================================

$pageTitle    = 'ERP ADSO — Listado de Facturas';
$activeModule = 'listado_facturas';
$page_title   = 'ADSOERP | Facturas';
$page_description = 'Historial de facturas de venta generadas';
$page_icon    = 'bi-receipt';
$page_extra_css = ["../modules/faccar/css/listado_facturas.css"];
$page_extra_js  = ["../modules/faccar/js/listado_facturas.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-listadofacturas" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Facturas</div>
            <div class="page-subtitle">Historial y estado de las facturas de venta</div>
        </div>
        <button id="btn-go-nueva-fac" class="btn-nuevo">
            <i class="fas fa-plus"></i> Nueva Factura
        </button>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-receipt"></i></div>
            <div>
                <div class="stat-label">Total Facturas</div>
                <div class="stat-value" id="stat-lf-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-sack-dollar"></i></div>
            <div>
                <div class="stat-label">Total Facturado</div>
                <div class="stat-value" id="stat-lf-valor" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="fas fa-lock"></i></div>
            <div>
                <div class="stat-label">Cerradas / Impresas</div>
                <div class="stat-value" id="stat-lf-cerradas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-lock-open"></i></div>
            <div>
                <div class="stat-label">Abiertas</div>
                <div class="stat-value" id="stat-lf-abiertas">0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="lf-search" placeholder="Buscar por N° o cliente...">
        </div>
        <select id="lf-estado-filter" class="filter-select">
            <option value="all">Todo estado</option>
            <option value="Activa">Activa</option>
            <option value="Vencida">Vencida</option>
        </select>
        <button id="btn-lf-cerrada-toggle" class="filter-toggle">Impresión: Todas</button>
        <button id="btn-clear-lf-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="lf-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="110">N° Factura</th>
                    <th>Cliente</th>
                    <th>Vendedor</th>
                    <th width="100">Fecha</th>
                    <th width="120">Forma Pago</th>
                    <th width="120">Total</th>
                    <th width="90">Estado</th>
                    <th width="120">Acciones</th>
                </tr>
            </thead>
            <tbody id="lf-tbody">
                <tr><td colspan="8">
                    <div class="empty-state">
                        <i class="fas fa-receipt"></i>
                        <p>Sin facturas registradas</p>
                        <span>Las facturas que generes aparecerán aquí</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL VER DETALLE -->
<div id="modal-ver-fac" class="modal-overlay hidden">
    <div class="modal-container modal-lg">
        <div class="modal-header blue">
            <h3><i class="fas fa-receipt"></i> Detalle de Factura <span id="ver-fac-id"></span></h3>
            <button class="modal-close btn-close-ver-fac">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-row">
                <div><span class="cell-muted">Cliente</span><div class="cell-strong" id="ver-fac-cliente">—</div></div>
                <div><span class="cell-muted">Vendedor</span><div class="cell-strong" id="ver-fac-vendedor">—</div></div>
            </div>
            <div class="form-row" style="margin-top:14px;">
                <div><span class="cell-muted">Fecha</span><div class="cell-strong" id="ver-fac-fecha">—</div></div>
                <div><span class="cell-muted">Forma de Pago</span><div class="cell-strong" id="ver-fac-formapago">—</div></div>
                <div><span class="cell-muted">Estado</span><div class="cell-strong" id="ver-fac-estado">—</div></div>
            </div>
            <div class="form-section-title">Productos</div>
            <div class="table-card" style="border:none;">
                <table class="data-table">
                    <thead><tr><th>Producto</th><th>Cant.</th><th>Desc.</th><th>IVA</th><th>Neto</th></tr></thead>
                    <tbody id="ver-fac-lineas"></tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancelar btn-close-ver-fac">Cerrar</button>
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
