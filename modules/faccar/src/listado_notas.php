<?php
// ==================================================
// Módulo: Listado de Notas (ERP ADSO)
// Tablas: tab_enc_notas, tab_nota_elect
// ==================================================

$pageTitle    = 'ERP ADSO — Listado de Notas';
$activeModule = 'listado_notas';
$page_title   = 'ADSOERP | Notas';
$page_description = 'Historial de notas crédito y débito emitidas';
$page_icon    = 'bi-file-earmark-minus';
$page_extra_css = ["../modules/faccar/css/listado_notas.css"];
$page_extra_js  = ["../modules/faccar/js/listado_notas.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<div id="mod-listadonotas" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Notas Crédito y Débito</div>
            <div class="page-subtitle">Historial, estado DIAN y saldo pendiente por aplicar</div>
        </div>
        <button id="btn-go-crear-nota" class="btn-nuevo">
            <i class="fas fa-plus"></i> Crear Nota
        </button>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-file-lines"></i></div>
            <div>
                <div class="stat-label">Total Notas</div>
                <div class="stat-value" id="stat-ln-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-rotate-left"></i></div>
            <div>
                <div class="stat-label">Notas Crédito</div>
                <div class="stat-value" id="stat-ln-nc">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="fas fa-rotate-right"></i></div>
            <div>
                <div class="stat-label">Notas Débito</div>
                <div class="stat-value" id="stat-ln-nd">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-sack-dollar"></i></div>
            <div>
                <div class="stat-label">Saldo Pendiente</div>
                <div class="stat-value" id="stat-ln-pendiente" style="font-size:18px;">$0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="ln-search" placeholder="Buscar por N° o cliente...">
        </div>
        <select id="ln-tipo-filter" class="filter-select">
            <option value="all">Todo tipo</option>
            <option value="NC">Nota Crédito</option>
            <option value="ND">Nota Débito</option>
        </select>
        <select id="ln-estado-filter" class="filter-select">
            <option value="all">Todo estado</option>
            <option value="BORRADOR">Borrador</option>
            <option value="EMITIDA">Emitida</option>
            <option value="ENVIADA_DIAN">Enviada DIAN</option>
            <option value="ACEPTADA_DIAN">Aceptada DIAN</option>
            <option value="RECHAZADA_DIAN">Rechazada DIAN</option>
            <option value="ANULADA">Anulada</option>
        </select>
        <button id="btn-clear-ln-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="ln-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="130">N° Nota</th>
                    <th width="60">Tipo</th>
                    <th>Cliente</th>
                    <th>Motivo</th>
                    <th width="100">Fecha</th>
                    <th width="110">Total</th>
                    <th width="110">Pendiente</th>
                    <th width="110">Estado</th>
                    <th width="100">Acciones</th>
                </tr>
            </thead>
            <tbody id="ln-tbody">
                <tr><td colspan="9">
                    <div class="empty-state">
                        <i class="fas fa-file-lines"></i>
                        <p>Sin notas registradas</p>
                        <span>Las notas crédito y débito que generes aparecerán aquí</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL VER DETALLE -->
<div id="modal-ver-nota" class="modal-overlay hidden">
    <div class="modal-container modal-lg">
        <div class="modal-header blue">
            <h3><i class="fas fa-file-lines"></i> Detalle de Nota <span id="ver-nota-id"></span></h3>
            <button class="modal-close btn-close-ver-nota">&times;</button>
        </div>
        <div class="modal-body">
            <div class="fe-detail-layout">
                <div id="nota-qr-container" class="fe-qr-box"></div>
                <div class="fe-detail-info">
                    <div class="form-group"><label>Cliente</label><div class="cell-strong" id="ver-nota-cliente">—</div></div>
                    <div class="form-group"><label>Motivo</label><div class="cell-strong" id="ver-nota-motivo">—</div></div>
                    <div class="form-group"><label>Factura Referenciada</label><div class="cell-strong" id="ver-nota-factura">—</div></div>
                    <div class="form-group"><label>Estado</label><div id="ver-nota-estado">—</div></div>
                </div>
            </div>
            <div class="form-section-title">Productos</div>
            <div class="table-card" style="border:none;">
                <table class="data-table">
                    <thead><tr><th>Producto</th><th>Cant.</th><th>Desc.</th><th>IVA</th><th>Neto</th></tr></thead>
                    <tbody id="ver-nota-lineas"></tbody>
                </table>
            </div>
            <div class="form-row" style="margin-top:14px;">
                <div><span class="cell-muted">Total Nota</span><div class="cell-strong" id="ver-nota-total">—</div></div>
                <div><span class="cell-muted">Aplicado</span><div class="cell-strong" id="ver-nota-aplicado">—</div></div>
                <div><span class="cell-muted">Pendiente</span><div class="cell-strong" id="ver-nota-pendiente">—</div></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancelar btn-close-ver-nota">Cerrar</button>
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
