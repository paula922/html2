<?php
// ==================================================
// Módulo: Gestión de Cartera (ERP ADSO)
// Tabla: tab_carteras
// ==================================================

$pageTitle    = 'ERP ADSO — Gestión de Cartera';
$activeModule = 'gestion_cartera';
$page_title   = 'ADSOERP | Cartera';
$page_description = 'Seguimiento de cuotas de crédito, pagos y mora';
$page_icon    = 'bi-wallet2';
$page_extra_css = ["../modules/faccar/css/gestion.css"];
$page_extra_js  = ["../modules/faccar/js/gestion.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-gestioncartera" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Gestión de Cartera</div>
            <div class="page-subtitle">Cuotas de crédito por factura, pagos y mora</div>
        </div>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-wallet"></i></div>
            <div>
                <div class="stat-label">Cuotas Totales</div>
                <div class="stat-value" id="stat-ca-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div>
                <div class="stat-label">Pagadas</div>
                <div class="stat-value" id="stat-ca-pagadas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-hourglass-half"></i></div>
            <div>
                <div class="stat-label">Pendientes</div>
                <div class="stat-value" id="stat-ca-pendientes">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-triangle-exclamation"></i></div>
            <div>
                <div class="stat-label">Vencidas</div>
                <div class="stat-value" id="stat-ca-vencidas">0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="ca-search" placeholder="Buscar por factura o cliente...">
        </div>
        <select id="ca-estado-filter" class="filter-select">
            <option value="all">Todo estado</option>
            <option value="pendiente">Pendiente</option>
            <option value="vencida">Vencida</option>
            <option value="Pagada">Pagada</option>
            <option value="perdida">Perdida</option>
        </select>
        <button id="btn-clear-ca-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="ca-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="60">N°</th>
                    <th width="100">Factura</th>
                    <th>Cliente</th>
                    <th width="100">Monto Cuota</th>
                    <th width="100">Pendiente</th>
                    <th width="100">Próx. Pago</th>
                    <th width="80">Mora</th>
                    <th width="100">Estado</th>
                    <th width="100">Acciones</th>
                </tr>
            </thead>
            <tbody id="ca-tbody">
                <tr><td colspan="9">
                    <div class="empty-state">
                        <i class="fas fa-wallet"></i>
                        <p>Sin cuotas de cartera registradas</p>
                        <span>Se generan automáticamente al facturar a crédito</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL REGISTRAR PAGO -->
<div id="modal-pago-cartera" class="modal-overlay hidden">
    <div class="modal-container">
        <div class="modal-header green">
            <h3><i class="fas fa-hand-holding-dollar"></i> Registrar Pago de Cuota</h3>
            <button class="modal-close btn-close-pago-cartera">&times;</button>
        </div>
        <div class="modal-body">
            <div class="saldo-preview">
                <div><span class="cell-muted">Cliente</span><div class="cell-strong" id="pc-cliente">—</div></div>
                <div><span class="cell-muted">Pendiente</span><div class="cell-strong" id="pc-pendiente" style="color:var(--dash-red);">—</div></div>
            </div>
            <form id="pago-cartera-form" novalidate style="margin-top:18px;">
                <input type="hidden" id="pc-id-cartera" value="">
                <div class="form-group">
                    <label>Valor a Pagar <span class="required">*</span></label>
                    <input type="text" inputmode="numeric" id="pc-valor" class="form-control" placeholder="$0">
                    <span class="field-error" id="err-pc-valor"></span>
                </div>
                <div class="form-group">
                    <label>Referencia de Pago <span class="required">*</span></label>
                    <input type="text" id="pc-referencia" class="form-control" placeholder="Ej: Transferencia Bancolombia #4521">
                    <span class="field-error" id="err-pc-referencia"></span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancelar btn-cancel-pago-cartera">Cancelar</button>
                    <button type="submit" class="btn-guardar"><i class="fas fa-save"></i> Registrar Pago</button>
                </div>
            </form>
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
