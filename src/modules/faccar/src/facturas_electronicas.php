<?php
// ==================================================
// Módulo: Facturas Electrónicas (ERP ADSO)
// Tabla: tab_fac_electronicas
// ==================================================

$pageTitle    = 'ERP ADSO — Facturas Electrónicas';
$activeModule = 'facturas_electronicas';
$page_title   = 'ADSOERP | Facturas Electrónicas';
$page_description = 'Seguimiento del estado de transmisión electrónica ante la DIAN';
$page_icon    = 'bi-qr-code';
$page_extra_css = ["../modules/faccar/css/facturas_electronicas.css"];
$page_extra_js  = ["../modules/faccar/js/facturas_electronicas.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<div id="mod-facturaselectronicas" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Facturas Electrónicas</div>
            <div class="page-subtitle">Estado de transmisión ante la DIAN: CUFE, XML firmado y código QR</div>
        </div>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-paper-plane"></i></div>
            <div>
                <div class="stat-label">Total Enviadas</div>
                <div class="stat-value" id="stat-fe-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div>
                <div class="stat-label">Aceptadas</div>
                <div class="stat-value" id="stat-fe-aceptadas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-hourglass-half"></i></div>
            <div>
                <div class="stat-label">Pendientes</div>
                <div class="stat-value" id="stat-fe-pendientes">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-circle-xmark"></i></div>
            <div>
                <div class="stat-label">Rechazadas</div>
                <div class="stat-value" id="stat-fe-rechazadas">0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="fe-search" placeholder="Buscar por N° factura o CUFE...">
        </div>
        <select id="fe-estado-filter" class="filter-select">
            <option value="all">Todo estado DIAN</option>
            <option value="pendiente">Pendiente</option>
            <option value="enviado">Enviado</option>
            <option value="aceptado">Aceptado</option>
            <option value="rechazado">Rechazado</option>
        </select>
        <button id="btn-clear-fe-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="fe-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="110">N° Factura</th>
                    <th>CUFE</th>
                    <th width="110">Estado DIAN</th>
                    <th width="100">Fecha Envío</th>
                    <th>Mensaje DIAN</th>
                    <th width="120">Acciones</th>
                </tr>
            </thead>
            <tbody id="fe-tbody">
                <tr><td colspan="6">
                    <div class="empty-state">
                        <i class="fas fa-qrcode"></i>
                        <p>Sin facturas electrónicas registradas</p>
                        <span>Aparecerán aquí al transmitir una factura a la DIAN</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL VER CUFE / QR / XML -->
<div id="modal-ver-fe" class="modal-overlay hidden">
    <div class="modal-container modal-lg">
        <div class="modal-header blue">
            <h3><i class="fas fa-qrcode"></i> Factura Electrónica <span id="ver-fe-id"></span></h3>
            <button class="modal-close btn-close-ver-fe">&times;</button>
        </div>
        <div class="modal-body">
            <div class="fe-detail-layout">
                <div id="fe-qr-container" class="fe-qr-box"></div>
                <div class="fe-detail-info">
                    <div class="form-group">
                        <label>CUFE</label>
                        <div class="fe-code-box" id="ver-fe-cufe">—</div>
                    </div>
                    <div class="form-group">
                        <label>Estado DIAN</label>
                        <div id="ver-fe-estado">—</div>
                    </div>
                    <div class="form-group">
                        <label>Fecha de Envío</label>
                        <div class="cell-strong" id="ver-fe-fecha">—</div>
                    </div>
                    <div class="form-group">
                        <label>Mensaje DIAN</label>
                        <div class="cell-strong" id="ver-fe-mensaje">—</div>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>XML Firmado (extracto)</label>
                <textarea class="form-control" id="ver-fe-xml" rows="5" readonly disabled style="border-radius:16px; font-family:monospace; font-size:11px;"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancelar btn-close-ver-fe">Cerrar</button>
            </div>
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
