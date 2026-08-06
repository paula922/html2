<?php
// ==================================================
// Módulo: Pagos (ERP ADSO)
// Tabla: tab_pagos
// ==================================================

$pageTitle    = 'ERP ADSO — Pagos';
$activeModule = 'pagos';
$page_title   = 'ADSOERP | Pagos';
$page_description = 'Registro y control de pagos recibidos sobre facturas';
$page_icon    = 'bi-cash-coin';
$page_extra_css = ["../modules/faccar/css/pagos.css"];
$page_extra_js  = ["../modules/faccar/js/pagos.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-pagos" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Pagos</div>
            <div class="page-subtitle">Registro de pagos recibidos sobre facturas</div>
        </div>
        <button id="btn-add-pago" class="btn-nuevo">
            <i class="fas fa-plus"></i> Nuevo Pago
        </button>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-cash-register"></i></div>
            <div>
                <div class="stat-label">Total Pagos</div>
                <div class="stat-value" id="stat-pa-total">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-circle-check"></i></div>
            <div>
                <div class="stat-label">Valor Aprobado</div>
                <div class="stat-value" id="stat-pa-aprobado" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-hourglass-half"></i></div>
            <div>
                <div class="stat-label">Pendientes</div>
                <div class="stat-value" id="stat-pa-pendientes">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-circle-xmark"></i></div>
            <div>
                <div class="stat-label">Rechazados</div>
                <div class="stat-value" id="stat-pa-rechazados">0</div>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="pa-search" placeholder="Buscar por factura o referencia...">
        </div>
        <select id="pa-estado-filter" class="filter-select">
            <option value="all">Todo estado</option>
            <option value="APROBADO">Aprobado</option>
            <option value="PENDIENTE">Pendiente</option>
            <option value="RECHAZADO">Rechazado</option>
        </select>
        <button id="btn-clear-pa-filters" class="btn-clear-filter" style="display: none;">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="filter-info" id="pa-count">0 resultados</span>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="60">N°</th>
                    <th width="100">Factura</th>
                    <th width="100">Fecha</th>
                    <th width="110">Valor</th>
                    <th>Referencia</th>
                    <th width="100">Estado</th>
                    <th width="100">Acciones</th>
                </tr>
            </thead>
            <tbody id="pa-tbody">
                <tr><td colspan="7">
                    <div class="empty-state">
                        <i class="fas fa-cash-register"></i>
                        <p>Sin pagos registrados</p>
                        <span>Registra el primer pago del sistema</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL NUEVO PAGO -->
<div id="modal-new-pago" class="modal-overlay hidden">
    <div class="modal-container">
        <div class="modal-header green">
            <h3><i class="fas fa-plus-circle"></i> Nuevo Pago</h3>
            <button class="modal-close btn-close-new-pago">&times;</button>
        </div>
        <div class="modal-body">
            <form id="new-pago-form" novalidate>
                <div class="form-group">
                    <label>Factura <span class="required">*</span></label>
                    <select id="new-pago-factura" class="form-control">
                        <option value="" disabled selected>No hay facturas registradas</option>
                    </select>
                    <span class="field-error" id="err-new-pago-factura"></span>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Fecha de Pago <span class="required">*</span></label>
                        <input type="date" id="new-pago-fecha" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>Valor a Pagar <span class="required">*</span></label>
                        <input type="text" inputmode="numeric" id="new-pago-valor" class="form-control" placeholder="$0">
                        <span class="field-error" id="err-new-pago-valor"></span>
                    </div>
                </div>
                <div class="form-group">
                    <label>Referencia de Pago <span class="required">*</span></label>
                    <input type="text" id="new-pago-referencia" class="form-control" maxlength="100" placeholder="Ej: Transferencia Bancolombia #4521">
                    <span class="field-error" id="err-new-pago-referencia"></span>
                </div>
                <div class="form-group">
                    <label>Estado</label>
                    <select id="new-pago-estado" class="form-control">
                        <option value="PENDIENTE">Pendiente</option>
                        <option value="APROBADO">Aprobado</option>
                        <option value="RECHAZADO">Rechazado</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Observación</label>
                    <textarea id="new-pago-observa" class="form-control" rows="2" placeholder="Sin observaciones"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancelar btn-cancel-new-pago">Cancelar</button>
                    <button type="submit" class="btn-guardar"><i class="fas fa-save"></i> Registrar Pago</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL EDITAR PAGO -->
<div id="modal-edit-pago" class="modal-overlay hidden">
    <div class="modal-container">
        <div class="modal-header blue">
            <h3><i class="fas fa-edit"></i> Actualizar Estado del Pago</h3>
            <button class="modal-close btn-close-edit-pago">&times;</button>
        </div>
        <div class="modal-body">
            <form id="edit-pago-form" novalidate>
                <div class="form-group">
                    <label>Factura <span style="font-size:0.55rem;color:#f59e0b;">🔒 No editable</span></label>
                    <input type="text" id="edit-pago-factura" class="form-control" readonly disabled>
                </div>
                <div class="form-group">
                    <label>Valor <span style="font-size:0.55rem;color:#f59e0b;">🔒 No editable</span></label>
                    <input type="text" id="edit-pago-valor" class="form-control" readonly disabled>
                </div>
                <div class="form-group">
                    <label>Estado <span class="required">*</span></label>
                    <select id="edit-pago-estado" class="form-control">
                        <option value="PENDIENTE">Pendiente</option>
                        <option value="APROBADO">Aprobado</option>
                        <option value="RECHAZADO">Rechazado</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Observación</label>
                    <textarea id="edit-pago-observa" class="form-control" rows="2"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancelar btn-cancel-edit-pago">Cancelar</button>
                    <button type="submit" class="btn-guardar"><i class="fas fa-save"></i> Guardar Cambios</button>
                </div>
            </form>
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
