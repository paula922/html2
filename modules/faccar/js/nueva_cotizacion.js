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
// NUEVA COTIZACIÓN - CONTROL COMPLETO
// Tablas: tab_enc_cotizaciones, tab_det_cotizaciones
// ============================================

// --- Catálogos de referencia ---
// En producción estos arreglos se cargan vía AJAX desde sus respectivos módulos
// (Clientes, Vendedores, Productos). Mientras no estén conectados al backend,
// inician vacíos para reflejar el estado real de la base de datos.
// Ejemplo de uso en consola para pruebas:
//   clientesCatalogo.push({id:'1001234567', nombre:'Laura Gómez'});
//   vendedoresCatalogo.push({id:'1101234567', nombre:'Carlos Ramírez'});
//   productosCatalogo.push({id:1, nombre:'Monitor 27 4K', precio:750000, iva:19});
let clientesCatalogo = [];
let vendedoresCatalogo = [];
let productosCatalogo = [];

let lineasCotizacion = [];
let nextLineaId = 1;
let cotCounter = 1; // simula val_cotactual de tab_pmtros_facturacion

function generarIdCotizacion() {
    return 'COT' + String(cotCounter).padStart(5, '0');
}

function poblarSelectsCotizacion() {
    const selCliente = document.getElementById('cot-cliente');
    const selVendedor = document.getElementById('cot-vendedor');
    const selProducto = document.getElementById('line-producto');

    if (clientesCatalogo.length) {
        selCliente.innerHTML = '<option value="" disabled selected>Selecciona un cliente</option>' +
            clientesCatalogo.map(c => `<option value="${c.id}">${escHtml(c.nombre)} (${c.id})</option>`).join('');
    }
    if (vendedoresCatalogo.length) {
        selVendedor.innerHTML = '<option value="" disabled selected>Selecciona un vendedor</option>' +
            vendedoresCatalogo.map(v => `<option value="${v.id}">${escHtml(v.nombre)} (${v.id})</option>`).join('');
    }
    if (productosCatalogo.length) {
        selProducto.innerHTML = '<option value="" disabled selected>Selecciona un producto</option>' +
            productosCatalogo.map(p => `<option value="${p.id}">${escHtml(p.nombre)} — ${fmtMoney(p.precio)}</option>`).join('');
    }
}

function actualizarIdPreview() {
    document.getElementById('cot-id-preview').textContent = generarIdCotizacion();
}

// Cálculo de una línea según los campos de tab_det_cotizaciones
function calcularLinea(producto, cantidad, pordesc) {
    const bruto = producto.precio * cantidad;
    const descuento = Math.round(bruto * (pordesc / 100));
    const baseGravable = bruto - descuento;
    const iva = Math.round(baseGravable * (producto.iva / 100));
    const reteicaPct = parseInt(document.getElementById('cot-reteica').value) || 0;
    const reteica = Math.round(baseGravable * (reteicaPct / 100));
    const neto = baseGravable + iva - reteica;
    return { bruto, descuento, iva, reteica, neto };
}

function renderizarLineas() {
    const tbody = document.getElementById('lineas-tbody');
    if (lineasCotizacion.length === 0) {
        tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state"><i class="fas fa-boxes-stacked"></i><p>Sin productos agregados</p><span>Agrega al menos un producto para guardar la cotización</span></div></td></tr>`;
    } else {
        tbody.innerHTML = lineasCotizacion.map(l => `
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
                <td>${fmtMoney(l.reteica)}</td>
                <td class="cell-strong">${fmtMoney(l.neto)}</td>
                <td><div class="prod-act-btn del" data-lid="${l.lid}"><i class="fas fa-trash"></i></div></td>
            </tr>
        `).join('');
        document.querySelectorAll('#lineas-tbody .prod-act-btn.del').forEach(btn => {
            btn.addEventListener('click', () => eliminarLinea(parseInt(btn.dataset.lid)));
        });
    }
    actualizarResumen();
}

function actualizarResumen() {
    const subtotal = lineasCotizacion.reduce((s, l) => s + l.bruto, 0);
    const descuento = lineasCotizacion.reduce((s, l) => s + l.descuento, 0);
    const iva = lineasCotizacion.reduce((s, l) => s + l.iva, 0);
    const reteica = lineasCotizacion.reduce((s, l) => s + l.reteica, 0);
    const total = lineasCotizacion.reduce((s, l) => s + l.neto, 0);

    document.getElementById('sum-subtotal').textContent = fmtMoney(subtotal);
    document.getElementById('sum-descuento').textContent = '-' + fmtMoney(descuento);
    document.getElementById('sum-iva').textContent = '+' + fmtMoney(iva);
    document.getElementById('sum-reteica').textContent = '-' + fmtMoney(reteica);
    document.getElementById('sum-total').textContent = fmtMoney(total);
}

function agregarLinea() {
    limpiarError('err-line');
    const prodId = document.getElementById('line-producto').value;
    const cantidad = parseInt(document.getElementById('line-cantidad').value);
    const pordesc = parseInt(document.getElementById('line-descuento').value);
    const observa = document.getElementById('line-observa').value.trim();

    if (!prodId) { mostrarError('err-line', 'Selecciona un producto'); return; }
    if (isNaN(cantidad) || cantidad <= 0 || cantidad > 9999) { mostrarError('err-line', 'Cantidad entre 1 y 9999'); return; }
    if (isNaN(pordesc) || pordesc < 0 || pordesc > 100) { mostrarError('err-line', '% Descuento entre 0 y 100'); return; }

    const producto = productosCatalogo.find(p => String(p.id) === String(prodId));
    if (!producto) { mostrarError('err-line', 'Producto no encontrado'); return; }

    const calc = calcularLinea(producto, cantidad, pordesc);
    lineasCotizacion.push({ lid: nextLineaId++, producto, cantidad, pordesc, observa, ...calc });

    document.getElementById('line-cantidad').value = '1';
    document.getElementById('line-descuento').value = '0';
    document.getElementById('line-observa').value = '';
    document.getElementById('line-producto').selectedIndex = 0;

    renderizarLineas();
}

function eliminarLinea(lid) {
    lineasCotizacion = lineasCotizacion.filter(l => l.lid !== lid);
    renderizarLineas();
}

// Recalcula las líneas existentes si cambia el % de retención ICA
function recalcularLineas() {
    lineasCotizacion = lineasCotizacion.map(l => ({ ...l, ...calcularLinea(l.producto, l.cantidad, l.pordesc) }));
    renderizarLineas();
}

function validarEncabezadoCotizacion() {
    let ok = true;
    limpiarError('err-cot-cliente');
    limpiarError('err-cot-vendedor');
    limpiarError('err-cot-vencimiento');

    const cliente = document.getElementById('cot-cliente').value;
    const vendedor = document.getElementById('cot-vendedor').value;
    const fecha = document.getElementById('cot-fecha').value;
    const vencimiento = document.getElementById('cot-vencimiento').value;

    if (!cliente) { mostrarError('err-cot-cliente', 'Selecciona un cliente'); ok = false; }
    if (!vendedor) { mostrarError('err-cot-vendedor', 'Selecciona un vendedor'); ok = false; }
    if (!vencimiento || vencimiento < fecha) { mostrarError('err-cot-vencimiento', 'Debe ser igual o posterior a la fecha de cotización'); ok = false; }
    if (lineasCotizacion.length === 0) { mostrarError('err-line', 'Agrega al menos un producto a la cotización'); ok = false; }

    return ok;
}

function guardarCotizacion() {
    if (!validarEncabezadoCotizacion()) return;

    const idCotizacion = generarIdCotizacion();
    // Aquí se construiría el payload para tab_enc_cotizaciones + tab_det_cotizaciones
    // y se enviaría al backend (fetch/AJAX). Por ahora se simula localmente.
    cotCounter++;
    mostrarToast(`Cotización ${idCotizacion} guardada correctamente`);
    limpiarFormularioCotizacion();
}

function limpiarFormularioCotizacion() {
    lineasCotizacion = [];
    document.getElementById('cot-cliente').selectedIndex = 0;
    document.getElementById('cot-vendedor').selectedIndex = 0;
    document.getElementById('cot-fecha').value = new Date().toISOString().slice(0, 10);
    document.getElementById('cot-vencimiento').value = '';
    document.getElementById('cot-reteica').value = '0';
    actualizarIdPreview();
    renderizarLineas();
}

function setupEventListenersCotizacion() {
    document.getElementById('btn-add-line').addEventListener('click', agregarLinea);
    document.getElementById('btn-guardar-cot').addEventListener('click', guardarCotizacion);
    document.getElementById('btn-limpiar-cot').addEventListener('click', limpiarFormularioCotizacion);
    document.getElementById('cot-reteica').addEventListener('input', recalcularLineas);
    document.getElementById('cot-fecha').addEventListener('change', function () {
        document.getElementById('cot-vencimiento').min = this.value;
    });
}

document.addEventListener('DOMContentLoaded', () => {
    poblarSelectsCotizacion();
    const hoy = new Date().toISOString().slice(0, 10);
    document.getElementById('cot-fecha').value = hoy;
    document.getElementById('cot-fecha').max = hoy;
    document.getElementById('cot-vencimiento').min = hoy;
    actualizarIdPreview();
    renderizarLineas();
    setupEventListenersCotizacion();
});
