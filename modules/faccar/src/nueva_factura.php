<?php
// ==================================================
// Módulo: Nueva Factura (ERP ADSO)
// Tablas: tab_enc_facturas, tab_det_facturas
// ==================================================

$pageTitle    = 'ERP ADSO — Nueva Factura';
$activeModule = 'nueva_factura';
$page_title   = 'ADSOERP | Nueva Factura';
$page_description = 'Genera una factura de venta con sus líneas, impuestos y forma de pago';
$page_icon    = 'bi-receipt';
$page_extra_css = ["../modules/faccar/css/nueva_factura.css"];
$page_extra_js  = ["../modules/faccar/js/nueva_factura.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-nuevafactura" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Nueva Factura</div>
            <div class="page-subtitle">Registra una venta y genera la factura con sus impuestos</div>
        </div>
        <span class="cot-id-pill" id="fac-id-preview">FE-00001</span>
    </div>

    <div class="doc-layout">
        <!-- Columna izquierda -->
        <div class="doc-main">
            <div class="doc-card">
                <div class="form-section-title">Datos Generales</div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Cliente <span class="required">*</span></label>
                        <select id="fac-cliente" class="form-control">
                            <option value="" disabled selected>No hay clientes registrados</option>
                        </select>
                        <span class="field-error" id="err-fac-cliente"></span>
                        <span class="field-hint">¿No aparece? Regístralo primero en el módulo de Clientes.</span>
                    </div>
                    <div class="form-group">
                        <label>Vendedor <span class="required">*</span></label>
                        <select id="fac-vendedor" class="form-control">
                            <option value="" disabled selected>No hay vendedores registrados</option>
                        </select>
                        <span class="field-error" id="err-fac-vendedor"></span>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Ciudad <span class="required">*</span></label>
                        <select id="fac-ciudad" class="form-control">
                            <option value="11001">11001 — Bogotá D.C.</option>
                            <option value="05001">05001 — Medellín</option>
                            <option value="76001">76001 — Cali</option>
                            <option value="08001">08001 — Barranquilla</option>
                            <option value="68001" selected>68001 — Bucaramanga</option>
                            <option value="13001">13001 — Cartagena</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Fecha Factura <span class="required">*</span></label>
                        <input type="date" id="fac-fecha" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>Forma de Pago <span class="required">*</span></label>
                        <select id="fac-formapago" class="form-control">
                            <option value="" disabled selected>No hay formas de pago</option>
                        </select>
                        <span class="field-error" id="err-fac-formapago"></span>
                    </div>
                </div>
                <div class="form-group" style="max-width:220px;">
                    <label>Retención ICA a aplicar (%)</label>
                    <input type="text" inputmode="numeric" id="fac-reteica" class="form-control" value="0" placeholder="0-99">
                    <span class="field-hint">Tomado de los parámetros de facturación de la empresa.</span>
                </div>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Agregar Producto</div>
                <div class="add-line-row">
                    <div class="form-group" style="flex:2;">
                        <label>Producto</label>
                        <select id="fline-producto" class="form-control">
                            <option value="" disabled selected>No hay productos registrados</option>
                        </select>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Cantidad</label>
                        <input type="text" inputmode="numeric" id="fline-cantidad" class="form-control" value="1">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>% Descuento</label>
                        <input type="text" inputmode="numeric" id="fline-descuento" class="form-control" value="0">
                    </div>
                    <div class="form-group" style="flex:2;">
                        <label>Observación</label>
                        <input type="text" id="fline-observa" class="form-control" placeholder="Opcional">
                    </div>
                    <button type="button" id="btn-add-fline" class="btn-nuevo" style="height:42px; margin-top:22px;">
                        <i class="fas fa-plus"></i> Agregar
                    </button>
                </div>
                <span class="field-error" id="err-fline"></span>
                <span class="field-hint">¿No aparece el producto? Regístralo primero en el módulo de Productos.</span>
            </div>

            <div class="doc-card">
                <div class="form-section-title">Líneas de la Factura</div>
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
                        <tbody id="flineas-tbody">
                            <tr><td colspan="9">
                                <div class="empty-state">
                                    <i class="fas fa-boxes-stacked"></i>
                                    <p>Sin productos agregados</p>
                                    <span>Agrega al menos un producto para guardar la factura</span>
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
                <div class="summary-row"><span>Subtotal</span><span id="fsum-subtotal">$0</span></div>
                <div class="summary-row"><span>Descuentos</span><span id="fsum-descuento" class="neg">-$0</span></div>
                <div class="summary-row"><span>IVA</span><span id="fsum-iva">+$0</span></div>
                <div class="summary-row"><span>Retención ICA</span><span id="fsum-reteica" class="neg">-$0</span></div>
                <div class="summary-divider"></div>
                <div class="summary-row total"><span>Total Factura</span><span id="fsum-total">$0</span></div>
                <button type="button" id="btn-guardar-fac" class="btn-guardar" style="width:100%; justify-content:center; margin-top:18px;">
                    <i class="fas fa-save"></i> Guardar Factura
                </button>
                <button type="button" id="btn-limpiar-fac" class="btn-secundario" style="width:100%; justify-content:center; margin-top:10px;">
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
