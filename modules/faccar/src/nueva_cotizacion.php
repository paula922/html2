<?php
// ==================================================
// Módulo: Nueva Cotización (ERP ADSO)
// Tablas: tab_enc_cotizaciones, tab_det_cotizaciones
// ==================================================

$pageTitle    = 'ERP ADSO — Nueva Cotización';
$activeModule = 'nueva_cotizacion';
$page_title   = 'ADSOERP | Nueva Cotización';
$page_description = 'Construye una cotización con sus líneas de producto, descuentos e impuestos';
$page_icon    = 'bi-file-earmark-plus';
$page_extra_css = ["../modules/faccar/css/nueva_cotizacion.css"];
$page_extra_js  = ["../modules/faccar/js/nueva_cotizacion.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-nuevacotizacion" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Nueva Cotización</div>
            <div class="page-subtitle">Registra los datos del cliente y agrega los productos a cotizar</div>
        </div>
        <div style="display:flex; gap:10px;">
            <span class="cot-id-pill" id="cot-id-preview">COT-00001</span>
        </div>
    </div>

    <div class="doc-layout">
        <!-- Columna izquierda: formulario -->
        <div class="doc-main">
            <div class="doc-card">
                <div class="form-section-title">Datos Generales</div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Cliente <span class="required">*</span></label>
                        <select id="cot-cliente" class="form-control">
                            <option value="" disabled selected>No hay clientes registrados</option>
                        </select>
                        <span class="field-error" id="err-cot-cliente"></span>
                        <span class="field-hint">¿No aparece? Regístralo primero en el módulo de Clientes.</span>
                    </div>
                    <div class="form-group">
                        <label>Vendedor <span class="required">*</span></label>
                        <select id="cot-vendedor" class="form-control">
                            <option value="" disabled selected>No hay vendedores registrados</option>
                        </select>
                        <span class="field-error" id="err-cot-vendedor"></span>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Ciudad <span class="required">*</span></label>
                        <select id="cot-ciudad" class="form-control">
                            <option value="11001">11001 — Bogotá D.C.</option>
                            <option value="05001">05001 — Medellín</option>
                            <option value="76001">76001 — Cali</option>
                            <option value="08001">08001 — Barranquilla</option>
                            <option value="68001" selected>68001 — Bucaramanga</option>
                            <option value="13001">13001 — Cartagena</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Fecha Cotización <span class="required">*</span></label>
                        <input type="date" id="cot-fecha" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>Fecha Vencimiento <span class="required">*</span></label>
                        <input type="date" id="cot-vencimiento" class="form-control">
                        <span class="field-error" id="err-cot-vencimiento"></span>
                    </div>
                </div>
                <div class="form-group" style="max-width:220px;">
                    <label>Retención ICA a aplicar (%)</label>
                    <input type="text" inputmode="numeric" id="cot-reteica" class="form-control" value="0" placeholder="0-99">
                    <span class="field-hint">Tomado de los parámetros de facturación de la empresa.</span>
                </div>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Agregar Producto</div>
                <div class="add-line-row">
                    <div class="form-group" style="flex:2;">
                        <label>Producto</label>
                        <select id="line-producto" class="form-control">
                            <option value="" disabled selected>No hay productos registrados</option>
                        </select>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Cantidad</label>
                        <input type="text" inputmode="numeric" id="line-cantidad" class="form-control" value="1">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>% Descuento</label>
                        <input type="text" inputmode="numeric" id="line-descuento" class="form-control" value="0">
                    </div>
                    <div class="form-group" style="flex:2;">
                        <label>Observación</label>
                        <input type="text" id="line-observa" class="form-control" placeholder="Opcional">
                    </div>
                    <button type="button" id="btn-add-line" class="btn-nuevo" style="height:42px; margin-top:22px;">
                        <i class="fas fa-plus"></i> Agregar
                    </button>
                </div>
                <span class="field-error" id="err-line"></span>
                <span class="field-hint">¿No aparece el producto? Regístralo primero en el módulo de Productos.</span>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Líneas de la Cotización</div>
                <div class="table-card" style="border:none;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th width="70">Cant.</th>
                                <th width="100">Precio</th>
                                <th width="80">% Desc.</th>
                                <th width="100">Desc.</th>
                                <th width="90">IVA</th>
                                <th width="90">ReteICA</th>
                                <th width="110">Neto</th>
                                <th width="50"></th>
                            </tr>
                        </thead>
                        <tbody id="lineas-tbody">
                            <tr><td colspan="9">
                                <div class="empty-state">
                                    <i class="fas fa-boxes-stacked"></i>
                                    <p>Sin productos agregados</p>
                                    <span>Agrega al menos un producto para guardar la cotización</span>
                                </div>
                            </td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Columna derecha: resumen -->
        <div class="doc-summary">
            <div class="doc-card summary-card">
                <div class="form-section-title">Resumen</div>
                <div class="summary-row"><span>Subtotal</span><span id="sum-subtotal">$0</span></div>
                <div class="summary-row"><span>Descuentos</span><span id="sum-descuento" class="neg">-$0</span></div>
                <div class="summary-row"><span>IVA</span><span id="sum-iva">+$0</span></div>
                <div class="summary-row"><span>Retención ICA</span><span id="sum-reteica" class="neg">-$0</span></div>
                <div class="summary-divider"></div>
                <div class="summary-row total"><span>Total Cotización</span><span id="sum-total">$0</span></div>
                <button type="button" id="btn-guardar-cot" class="btn-guardar" style="width:100%; justify-content:center; margin-top:18px;">
                    <i class="fas fa-save"></i> Guardar Cotización
                </button>
                <button type="button" id="btn-limpiar-cot" class="btn-secundario" style="width:100%; justify-content:center; margin-top:10px;">
                    <i class="fas fa-eraser"></i> Limpiar Formulario
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
