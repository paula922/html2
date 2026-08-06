<?php
// ==================================================
// Módulo: Aplicar Saldo (ERP ADSO)
// Tabla: tab_aplicacion_nota
// ==================================================

$pageTitle    = 'ERP ADSO — Aplicar Saldo';
$activeModule = 'aplicar_saldo';
$page_title   = 'ADSOERP | Aplicar Saldo';
$page_description = 'Aplica el saldo de una nota a una factura o a la cartera del cliente';
$page_icon    = 'bi-arrow-left-right';
$page_extra_css = ["../modules/faccar/css/aplicar_saldo.css"];
$page_extra_js  = ["../modules/faccar/js/aplicar_saldo.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-aplicarsaldo" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Aplicar Saldo de Nota</div>
            <div class="page-subtitle">Distribuye el saldo pendiente de una nota a una factura o a la cartera del cliente</div>
        </div>
    </div>

    <div class="doc-layout">
        <!-- Columna izquierda: formulario de aplicación -->
        <div class="doc-main">
            <div class="doc-card">
                <div class="form-section-title">Seleccionar Nota</div>
                <div class="form-group">
                    <label>Nota con Saldo Pendiente <span class="required">*</span></label>
                    <select id="as-nota" class="form-control">
                        <option value="" disabled selected>No hay notas con saldo pendiente</option>
                    </select>
                    <span class="field-error" id="err-as-nota"></span>
                </div>
                <div class="saldo-preview" id="as-saldo-preview" style="display:none;">
                    <div><span class="cell-muted">Cliente</span><div class="cell-strong" id="as-nota-cliente">—</div></div>
                    <div><span class="cell-muted">Total Nota</span><div class="cell-strong" id="as-nota-total">—</div></div>
                    <div><span class="cell-muted">Saldo Disponible</span><div class="cell-strong" id="as-nota-saldo" style="color:var(--dash-green-dark);">—</div></div>
                </div>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Aplicar a</div>
                <div class="tipo-nota-toggle">
                    <button type="button" class="tipo-btn active" id="btn-destino-factura" data-destino="factura">
                        <i class="fas fa-receipt"></i> Factura
                    </button>
                    <button type="button" class="tipo-btn" id="btn-destino-cartera" data-destino="cartera">
                        <i class="fas fa-wallet"></i> Cartera
                    </button>
                </div>

                <div class="form-group" style="margin-top:18px;" id="grupo-as-factura">
                    <label>Factura Destino <span class="required">*</span></label>
                    <select id="as-factura" class="form-control">
                        <option value="" disabled selected>No hay facturas registradas</option>
                    </select>
                </div>
                <div class="form-group" style="display:none;" id="grupo-as-cartera">
                    <label>Cuota de Cartera Destino <span class="required">*</span></label>
                    <select id="as-cartera" class="form-control">
                        <option value="" disabled selected>No hay cuotas de cartera registradas</option>
                    </select>
                </div>
                <span class="field-error" id="err-as-destino"></span>

                <div class="form-row">
                    <div class="form-group">
                        <label>Valor a Aplicar <span class="required">*</span></label>
                        <input type="text" inputmode="numeric" id="as-valor" class="form-control" placeholder="$0">
                        <span class="field-error" id="err-as-valor"></span>
                    </div>
                    <div class="form-group">
                        <label>Fecha de Aplicación</label>
                        <input type="date" id="as-fecha" class="form-control" readonly disabled>
                    </div>
                </div>
                <div class="form-group">
                    <label>Observación</label>
                    <input type="text" id="as-observa" class="form-control" maxlength="250" placeholder="Sin observaciones">
                </div>

                <button type="button" id="btn-aplicar-saldo" class="btn-guardar" style="width:100%; justify-content:center;">
                    <i class="fas fa-check"></i> Aplicar Saldo
                </button>
            </div>
        </div>

        <!-- Columna derecha: historial -->
        <div class="doc-summary">
            <div class="doc-card">
                <div class="form-section-title">Historial de Aplicaciones</div>
                <div id="as-historial-list">
                    <div class="empty-state" style="padding:30px 10px;">
                        <i class="fas fa-arrow-left-right"></i>
                        <p style="font-size:13px;">Sin aplicaciones registradas</p>
                    </div>
                </div>
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
