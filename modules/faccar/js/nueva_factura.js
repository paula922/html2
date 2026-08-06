// ---- Utilidades comunes ----
function escHtml(s) {
    if (s === null || s === undefined) return '';
    return String(s).replace(/[&<>]/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[m]));
}

function fmtMoney(n) {
    return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', minimumFractionDigits: 0 }).format(n || 0);
}

function fmtDate(d) {
    if (!d) return '—';
    const [y, m, day] = d.split('-');
    return `${day}/${m}/${y}`;
}

function diasEntre(fechaA, fechaB) {
    const a = new Date(fechaA + 'T00:00:00');
    const b = new Date(fechaB + 'T00:00:00');
    return Math.round((b - a) / 86400000);
}

function diasHastaHoy(fecha) {
    const hoy = new Date();
    hoy.setHours(0,0,0,0);
    const f = new Date(fecha + 'T00:00:00');
    return Math.round((f - hoy) / 86400000);
}

function mostrarToast(msg, isError = false) {
    const toast = document.getElementById('toast');
    if (!toast) return;
    const icon = toast.querySelector('i');
    const span = document.getElementById('toast-message');
    span.textContent = msg;
    if (isError) {
        icon.className = 'fas fa-exclamation-triangle';
        toast.style.background = '#ef4444';
    } else {
        icon.className = 'fas fa-check-circle';
        toast.style.background = '#0f172a';
    }
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 3500);
}

function mostrarError(id, msg) {
    const el = document.getElementById(id);
    if (el) {
        el.textContent = msg;
        el.classList.add('visible');
    }
}

function limpiarError(id) {
    const el = document.getElementById(id);
    if (el) {
        el.textContent = '';
        el.classList.remove('visible');
    }
}

function setToggle(switchId, statusId, on, onText, offText) {
    const sw = document.getElementById(switchId);
    const st = document.getElementById(statusId);
    if (sw) sw.classList.toggle('on', on);
    if (st) {
        st.textContent = on ? (onText || 'ACTIVO') : (offText || 'INACTIVO');
        st.className = 'toggle-status ' + (on ? 'active' : 'inactive');
    }
}

// ============================================
// NUEVA FACTURA - CONTROL COMPLETO
// Tablas: tab_enc_facturas, tab_det_facturas
// ============================================

// Catálogos de referencia — inician vacíos hasta conectar el backend.
// Ejemplo para pruebas en consola:
//   clientesCatalogo.push({id:'1001234567', nombre:'Laura Gómez'});
//   vendedoresCatalogo.push({id:'1101234567', nombre:'Carlos Ramírez'});
//   formaPagoCatalogo.push({id:1, nombre:'Efectivo'});
//   productosCatalogo.push({id:1, nombre:'Monitor 27 4K', precio:750000, iva:19});
let clientesCatalogo = [];
let vendedoresCatalogo = [];
let formaPagoCatalogo = [];
let productosCatalogo = [];

let lineasFactura = [];
let nextFlineaId = 1;
let facCounter = 1; // simula val_facactual de tab_pmtros_facturacion

function generarIdFactura() {
    return 'FE' + String(facCounter).padStart(6, '0');
}

function poblarSelectsFactura() {
    const selCliente = document.getElementById('fac-cliente');
    const selVendedor = document.getElementById('fac-vendedor');
    const selFormaPago = document.getElementById('fac-formapago');
    const selProducto = document.getElementById('fline-producto');

    if (clientesCatalogo.length) {
        selCliente.innerHTML = '<option value="" disabled selected>Selecciona un cliente</option>' +
            clientesCatalogo.map(c => `<option value="${c.id}">${escHtml(c.nombre)} (${c.id})</option>`).join('');
    }
    if (vendedoresCatalogo.length) {
        selVendedor.innerHTML = '<option value="" disabled selected>Selecciona un vendedor</option>' +
            vendedoresCatalogo.map(v => `<option value="${v.id}">${escHtml(v.nombre)} (${v.id})</option>`).join('');
    }
    if (formaPagoCatalogo.length) {
        selFormaPago.innerHTML = '<option value="" disabled selected>Selecciona forma de pago</option>' +
            formaPagoCatalogo.map(f => `<option value="${f.id}">${escHtml(f.nombre)}</option>`).join('');
    }
    if (productosCatalogo.length) {
        selProducto.innerHTML = '<option value="" disabled selected>Selecciona un producto</option>' +
            productosCatalogo.map(p => `<option value="${p.id}">${escHtml(p.nombre)} — ${fmtMoney(p.precio)}</option>`).join('');
    }
}

function actualizarFacIdPreview() {
    document.getElementById('fac-id-preview').textContent = generarIdFactura();
}

// Cálculo de línea según tab_det_facturas (val_bruto, val_descuento, val_iva, val_reica, val_neto)
function calcularLineaFactura(producto, cantidad, pordesc) {
    const bruto = producto.precio * cantidad;
    const descuento = Math.round(bruto * (pordesc / 100));
    const baseGravable = bruto - descuento;
    const iva = Math.round(baseGravable * (producto.iva / 100));
    const reteicaPct = parseInt(document.getElementById('fac-reteica').value) || 0;
    const reica = Math.round(baseGravable * (reteicaPct / 100));
    const neto = baseGravable + iva - reica;
    return { bruto, descuento, iva, reica, neto };
}

function renderizarLineasFactura() {
    const tbody = document.getElementById('flineas-tbody');
    if (lineasFactura.length === 0) {
        tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state"><i class="fas fa-boxes-stacked"></i><p>Sin productos agregados</p><span>Agrega al menos un producto para guardar la factura</span></div></td></tr>`;
    } else {
        tbody.innerHTML = lineasFactura.map(l => `
            <tr data-lid="${l.lid}">
                <td>
                    <div class="cell-strong">${escHtml(l.producto.nombre)}</div>
                    ${l.observa ? `<div class="cell-muted">${escHtml(l.observa)}</div>` : ''}
                </td>
                <td>${l.cantidad}</td>
                <td>${fmtMoney(l.producto.precio)}</td>
                <td>${l.pordesc}%</td>
                <td>${fmtMoney(l.descuento)}</td>
                <td>${fmtMoney(l.iva)}</td>
                <td>${fmtMoney(l.reica)}</td>
                <td class="cell-strong">${fmtMoney(l.neto)}</td>
                <td><div class="prod-act-btn del" data-lid="${l.lid}"><i class="fas fa-trash"></i></div></td>
            </tr>
        `).join('');
        document.querySelectorAll('#flineas-tbody .prod-act-btn.del').forEach(btn => {
            btn.addEventListener('click', () => eliminarLineaFactura(parseInt(btn.dataset.lid)));
        });
    }
    actualizarResumenFactura();
}

function actualizarResumenFactura() {
    const subtotal = lineasFactura.reduce((s, l) => s + l.bruto, 0);
    const descuento = lineasFactura.reduce((s, l) => s + l.descuento, 0);
    const iva = lineasFactura.reduce((s, l) => s + l.iva, 0);
    const reica = lineasFactura.reduce((s, l) => s + l.reica, 0);
    const total = lineasFactura.reduce((s, l) => s + l.neto, 0);

    document.getElementById('fsum-subtotal').textContent = fmtMoney(subtotal);
    document.getElementById('fsum-descuento').textContent = '-' + fmtMoney(descuento);
    document.getElementById('fsum-iva').textContent = '+' + fmtMoney(iva);
    document.getElementById('fsum-reteica').textContent = '-' + fmtMoney(reica);
    document.getElementById('fsum-total').textContent = fmtMoney(total);
}

function agregarLineaFactura() {
    limpiarError('err-fline');
    const prodId = document.getElementById('fline-producto').value;
    const cantidad = parseInt(document.getElementById('fline-cantidad').value);
    const pordesc = parseInt(document.getElementById('fline-descuento').value);
    const observa = document.getElementById('fline-observa').value.trim();

    if (!prodId) { mostrarError('err-fline', 'Selecciona un producto'); return; }
    if (isNaN(cantidad) || cantidad <= 0 || cantidad > 9999) { mostrarError('err-fline', 'Cantidad entre 1 y 9999'); return; }
    if (isNaN(pordesc) || pordesc < 0 || pordesc > 100) { mostrarError('err-fline', '% Descuento entre 0 y 100'); return; }

    const producto = productosCatalogo.find(p => String(p.id) === String(prodId));
    if (!producto) { mostrarError('err-fline', 'Producto no encontrado'); return; }

    const calc = calcularLineaFactura(producto, cantidad, pordesc);
    lineasFactura.push({ lid: nextFlineaId++, producto, cantidad, pordesc, observa, ...calc });

    document.getElementById('fline-cantidad').value = '1';
    document.getElementById('fline-descuento').value = '0';
    document.getElementById('fline-observa').value = '';
    document.getElementById('fline-producto').selectedIndex = 0;

    renderizarLineasFactura();
}

function eliminarLineaFactura(lid) {
    lineasFactura = lineasFactura.filter(l => l.lid !== lid);
    renderizarLineasFactura();
}

function recalcularLineasFactura() {
    lineasFactura = lineasFactura.map(l => ({ ...l, ...calcularLineaFactura(l.producto, l.cantidad, l.pordesc) }));
    renderizarLineasFactura();
}

function validarEncabezadoFactura() {
    let ok = true;
    limpiarError('err-fac-cliente');
    limpiarError('err-fac-vendedor');
    limpiarError('err-fac-formapago');

    if (!document.getElementById('fac-cliente').value) { mostrarError('err-fac-cliente', 'Selecciona un cliente'); ok = false; }
    if (!document.getElementById('fac-vendedor').value) { mostrarError('err-fac-vendedor', 'Selecciona un vendedor'); ok = false; }
    if (!document.getElementById('fac-formapago').value) { mostrarError('err-fac-formapago', 'Selecciona una forma de pago'); ok = false; }
    if (lineasFactura.length === 0) { mostrarError('err-fline', 'Agrega al menos un producto a la factura'); ok = false; }

    return ok;
}

function guardarFactura() {
    if (!validarEncabezadoFactura()) return;
    const idFactura = generarIdFactura();
    // Aquí se construiría el payload para tab_enc_facturas + tab_det_facturas
    // (y opcionalmente tab_fac_electronicas) y se enviaría al backend.
    facCounter++;
    mostrarToast(`Factura ${idFactura} guardada correctamente`);
    limpiarFormularioFactura();
}

function limpiarFormularioFactura() {
    lineasFactura = [];
    document.getElementById('fac-cliente').selectedIndex = 0;
    document.getElementById('fac-vendedor').selectedIndex = 0;
    document.getElementById('fac-formapago').selectedIndex = 0;
    document.getElementById('fac-fecha').value = new Date().toISOString().slice(0, 10);
    document.getElementById('fac-reteica').value = '0';
    actualizarFacIdPreview();
    renderizarLineasFactura();
}

function setupEventListenersFactura() {
    document.getElementById('btn-add-fline').addEventListener('click', agregarLineaFactura);
    document.getElementById('btn-guardar-fac').addEventListener('click', guardarFactura);
    document.getElementById('btn-limpiar-fac').addEventListener('click', limpiarFormularioFactura);
    document.getElementById('fac-reteica').addEventListener('input', recalcularLineasFactura);
}

document.addEventListener('DOMContentLoaded', () => {
    poblarSelectsFactura();
    const hoy = new Date().toISOString().slice(0, 10);
    document.getElementById('fac-fecha').value = hoy;
    document.getElementById('fac-fecha').max = hoy;
    actualizarFacIdPreview();
    renderizarLineasFactura();
    setupEventListenersFactura();
});
