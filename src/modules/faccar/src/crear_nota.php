<?php
// ==================================================
// Módulo: Crear Nota (ERP ADSO)
// Tablas: tab_enc_notas, tab_det_notas
// ==================================================

$pageTitle    = 'ERP ADSO — Crear Nota';
$activeModule = 'crear_nota';
$page_title   = 'ADSOERP | Crear Nota';
$page_description = 'Genera una nota crédito o nota débito referenciando una factura';
$page_icon    = 'bi-file-earmark-minus';
$page_extra_css = ["../modules/faccar/css/crear_nota.css"];
$page_extra_js  = ["../modules/faccar/js/crear_nota.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-crearnota" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Crear Nota</div>
            <div class="page-subtitle">Genera una nota crédito o débito referenciando una factura existente</div>
        </div>
        <span class="cot-id-pill" id="nota-id-preview">NC-0000000001</span>
    </div>

    <div class="doc-layout">
        <!-- Columna izquierda -->
        <div class="doc-main">
            <div class="doc-card">
                <div class="form-section-title">Tipo y Motivo</div>
                <div class="tipo-nota-toggle">
                    <button type="button" class="tipo-btn active" id="btn-tipo-credito" data-tipo="credito">
                        <i class="fas fa-rotate-left"></i> Nota Crédito
                    </button>
                    <button type="button" class="tipo-btn" id="btn-tipo-debito" data-tipo="debito">
                        <i class="fas fa-rotate-right"></i> Nota Débito
                    </button>
                </div>
                <div class="form-group" style="margin-top:18px;">
                    <label>Motivo <span class="required">*</span></label>
                    <select id="nota-motivo" class="form-control">
                        <option value="" disabled selected>No hay motivos registrados</option>
                    </select>
                    <span class="field-error" id="err-nota-motivo"></span>
                    <span class="field-hint">¿No aparece? Regístralo primero en Configuración → Motivos DIAN.</span>
                </div>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Factura de Referencia</div>
                <div class="form-row">
                    <div class="form-group">
                        <label>N° Factura <span class="required">*</span></label>
                        <select id="nota-factura" class="form-control">
                            <option value="" disabled selected>No hay facturas registradas</option>
                        </select>
                        <span class="field-error" id="err-nota-factura"></span>
                    </div>
                    <div class="form-group">
                        <label>Cliente</label>
                        <input type="text" id="nota-cliente-display" class="form-control" readonly disabled placeholder="Se completa al elegir la factura">
                    </div>
                </div>
                <div class="form-group">
                    <label>CUFE de la Factura <span style="font-size:0.55rem;color:#f59e0b;">🔒 Tomado de la factura</span></label>
                    <input type="text" id="nota-cufe-ref" class="form-control" readonly disabled style="font-family:monospace; font-size:11px;">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Fecha de Emisión <span class="required">*</span></label>
                        <input type="date" id="nota-fecemi" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>Fecha de Vencimiento <span class="required">*</span></label>
                        <input type="date" id="nota-fecven" class="form-control">
                        <span class="field-error" id="err-nota-fecven"></span>
                        <span class="field-hint" id="hint-fecven">En notas crédito coincide con la fecha de emisión.</span>
                    </div>
                </div>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Agregar Producto</div>
                <div class="add-line-row">
                    <div class="form-group" style="flex:2;">
                        <label>Producto</label>
                        <select id="nline-producto" class="form-control">
                            <option value="" disabled selected>No hay productos registrados</option>
                        </select>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Cantidad</label>
                        <input type="text" inputmode="numeric" id="nline-cantidad" class="form-control" value="1">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>% Descuento</label>
                        <input type="text" inputmode="numeric" id="nline-descuento" class="form-control" value="0">
                    </div>
                    <button type="button" id="btn-add-nline" class="btn-nuevo" style="height:42px; margin-top:22px;">
                        <i class="fas fa-plus"></i> Agregar
                    </button>
                </div>
                <span class="field-error" id="err-nline"></span>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Líneas de la Nota</div>
                <div class="table-card" style="border:none;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th width="70">Cant.</th>
                                <th width="100">Precio Unit.</th>
                                <th width="80">% Desc.</th>
                                <th width="100">Desc.</th>
                                <th width="90">IVA</th>
                                <th width="110">Neto</th>
                                <th width="50"></th>
                            </tr>
                        </thead>
                        <tbody id="nlineas-tbody">
                            <tr><td colspan="8">
                                <div class="empty-state">
                                    <i class="fas fa-boxes-stacked"></i>
                                    <p>Sin productos agregados</p>
                                    <span>Agrega al menos un producto para guardar la nota</span>
                                </div>
                            </td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="form-group" style="margin-top:16px;">
                    <label>Observación</label>
                    <textarea id="nota-observa" class="form-control" rows="2" maxlength="255" placeholder="Sin observaciones"></textarea>
                </div>
            </div>
        </div>

        <!-- Columna derecha: resumen -->
        <div class="doc-summary">
            <div class="doc-card summary-card">
                <div class="form-section-title">Resumen</div>
                <div class="summary-row"><span>Subtotal</span><span id="nsum-subtotal">$0</span></div>
                <div class="summary-row"><span>Descuentos</span><span id="nsum-descuento" class="neg">-$0</span></div>
                <div class="summary-row"><span>IVA</span><span id="nsum-iva">+$0</span></div>
                <div class="summary-divider"></div>
                <div class="summary-row total"><span>Total Nota</span><span id="nsum-total">$0</span></div>
                <button type="button" id="btn-borrador-nota" class="btn-secundario" style="width:100%; justify-content:center; margin-top:18px;">
                    <i class="fas fa-file-pen"></i> Guardar Borrador
                </button>
                <button type="button" id="btn-emitir-nota" class="btn-guardar" style="width:100%; justify-content:center; margin-top:10px;">
                    <i class="fas fa-paper-plane"></i> Emitir Nota
                </button>
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
