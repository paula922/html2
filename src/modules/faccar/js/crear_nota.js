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
// CREAR NOTA - CONTROL COMPLETO
// Tablas: tab_enc_notas, tab_det_notas
// ============================================

// Catálogos de referencia — inician vacíos hasta conectar el backend.
// Ejemplo para pruebas en consola:
//   motivosCatalogo.push({id:1, tipoNota:false, nombre:'Devolución total por incumplimiento de pago'});
//   facturasCatalogo.push({id:'FE000001', clienteNombre:'Laura Gómez', cufe:'a1b2c3...'});
//   productosCatalogo.push({id:1, nombre:'Monitor 27 4K', precio:750000, iva:19});
let motivosCatalogo = [];
let facturasCatalogo = [];
let productosCatalogo = [];

let tipoNotaActual = false; // false = Crédito, true = Débito
let lineasNota = [];
let nextNlineaId = 1;
let notaCounter = 1;

function generarIdNota() {
    const prefijo = tipoNotaActual ? 'ND' : 'NC';
    return prefijo + '-' + String(notaCounter).padStart(10, '0');
}

function actualizarNotaIdPreview() {
    document.getElementById('nota-id-preview').textContent = generarIdNota();
}

function poblarSelectsNota() {
    const selFactura = document.getElementById('nota-factura');
    const selProducto = document.getElementById('nline-producto');

    if (facturasCatalogo.length) {
        selFactura.innerHTML = '<option value="" disabled selected>Selecciona una factura</option>' +
            facturasCatalogo.map(f => `<option value="${f.id}">${f.id} — ${escHtml(f.clienteNombre)}</option>`).join('');
    }
    if (productosCatalogo.length) {
        selProducto.innerHTML = '<option value="" disabled selected>Selecciona un producto</option>' +
            productosCatalogo.map(p => `<option value="${p.id}">${escHtml(p.nombre)} — ${fmtMoney(p.precio)}</option>`).join('');
    }
    poblarSelectMotivos();
}

// El motivo se filtra según el tipo de nota seleccionado (Crédito/Débito)
function poblarSelectMotivos() {
    const selMotivo = document.getElementById('nota-motivo');
    const disponibles = motivosCatalogo.filter(m => m.tipoNota === tipoNotaActual && m.estado !== false);
    if (disponibles.length) {
        selMotivo.innerHTML = '<option value="" disabled selected>Selecciona un motivo</option>' +
            disponibles.map(m => `<option value="${m.id}">${escHtml(m.nombre)}</option>`).join('');
    } else {
        selMotivo.innerHTML = `<option value="" disabled selected>No hay motivos de ${tipoNotaActual ? 'débito' : 'crédito'} registrados</option>`;
    }
}

function calcularLineaNota(producto, cantidad, pordesc) {
    const bruto = producto.precio * cantidad;
    const descuento = Math.round(bruto * (pordesc / 100));
    const baseGravable = bruto - descuento;
    const iva = Math.round(baseGravable * (producto.iva / 100));
    const neto = baseGravable + iva;
    return { bruto, descuento, iva, neto };
}

function renderizarLineasNota() {
    const tbody = document.getElementById('nlineas-tbody');
    if (lineasNota.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8"><div class="empty-state"><i class="fas fa-boxes-stacked"></i><p>Sin productos agregados</p><span>Agrega al menos un producto para guardar la nota</span></div></td></tr>`;
    } else {
        tbody.innerHTML = lineasNota.map(l => `
            <tr data-lid="${l.lid}">
                <td class="cell-strong">${escHtml(l.producto.nombre)}</td>
                <td>${l.cantidad}</td>
                <td>${fmtMoney(l.producto.precio)}</td>
                <td>${l.pordesc}%</td>
                <td>${fmtMoney(l.descuento)}</td>
                <td>${fmtMoney(l.iva)}</td>
                <td class="cell-strong">${fmtMoney(l.neto)}</td>
                <td><div class="prod-act-btn del" data-lid="${l.lid}"><i class="fas fa-trash"></i></div></td>
            </tr>
        `).join('');
        document.querySelectorAll('#nlineas-tbody .prod-act-btn.del').forEach(btn => {
            btn.addEventListener('click', () => eliminarLineaNota(parseInt(btn.dataset.lid)));
        });
    }
    actualizarResumenNota();
}

function actualizarResumenNota() {
    const subtotal = lineasNota.reduce((s, l) => s + l.bruto, 0);
    const descuento = lineasNota.reduce((s, l) => s + l.descuento, 0);
    const iva = lineasNota.reduce((s, l) => s + l.iva, 0);
    const total = lineasNota.reduce((s, l) => s + l.neto, 0);
    document.getElementById('nsum-subtotal').textContent = fmtMoney(subtotal);
    document.getElementById('nsum-descuento').textContent = '-' + fmtMoney(descuento);
    document.getElementById('nsum-iva').textContent = '+' + fmtMoney(iva);
    document.getElementById('nsum-total').textContent = fmtMoney(total);
}

function agregarLineaNota() {
    limpiarError('err-nline');
    const prodId = document.getElementById('nline-producto').value;
    const cantidad = parseInt(document.getElementById('nline-cantidad').value);
    const pordesc = parseInt(document.getElementById('nline-descuento').value);

    if (!prodId) { mostrarError('err-nline', 'Selecciona un producto'); return; }
    if (isNaN(cantidad) || cantidad <= 0 || cantidad > 9999) { mostrarError('err-nline', 'Cantidad entre 1 y 9999'); return; }
    if (isNaN(pordesc) || pordesc < 0 || pordesc > 100) { mostrarError('err-nline', '% Descuento entre 0 y 100'); return; }

    const producto = productosCatalogo.find(p => String(p.id) === String(prodId));
    if (!producto) { mostrarError('err-nline', 'Producto no encontrado'); return; }

    const calc = calcularLineaNota(producto, cantidad, pordesc);
    lineasNota.push({ lid: nextNlineaId++, producto, cantidad, pordesc, ...calc });

    document.getElementById('nline-cantidad').value = '1';
    document.getElementById('nline-descuento').value = '0';
    document.getElementById('nline-producto').selectedIndex = 0;
    renderizarLineasNota();
}

function eliminarLineaNota(lid) {
    lineasNota = lineasNota.filter(l => l.lid !== lid);
    renderizarLineasNota();
}

function seleccionarTipoNota(tipo) {
    tipoNotaActual = tipo === 'debito';
    document.getElementById('btn-tipo-credito').classList.toggle('active', !tipoNotaActual);
    document.getElementById('btn-tipo-debito').classList.toggle('active', tipoNotaActual);
    poblarSelectMotivos();
    actualizarNotaIdPreview();

    const fecVenInput = document.getElementById('nota-fecven');
    const hint = document.getElementById('hint-fecven');
    if (tipoNotaActual) {
        fecVenInput.disabled = false;
        hint.textContent = 'En notas débito puede ser posterior a la fecha de emisión.';
    } else {
        fecVenInput.disabled = true;
        fecVenInput.value = document.getElementById('nota-fecemi').value;
        hint.textContent = 'En notas crédito coincide con la fecha de emisión.';
    }
}

function alSeleccionarFactura() {
    const facId = document.getElementById('nota-factura').value;
    const f = facturasCatalogo.find(x => x.id === facId);
    document.getElementById('nota-cliente-display').value = f ? f.clienteNombre : '';
    document.getElementById('nota-cufe-ref').value = f ? f.cufe : '';
}

function validarEncabezadoNota() {
    let ok = true;
    limpiarError('err-nota-motivo');
    limpiarError('err-nota-factura');
    limpiarError('err-nota-fecven');

    if (!document.getElementById('nota-motivo').value) { mostrarError('err-nota-motivo', 'Selecciona un motivo'); ok = false; }
    if (!document.getElementById('nota-factura').value) { mostrarError('err-nota-factura', 'Selecciona la factura de referencia'); ok = false; }

    const fecEmi = document.getElementById('nota-fecemi').value;
    const fecVen = document.getElementById('nota-fecven').value;
    if (!fecVen || fecVen < fecEmi) { mostrarError('err-nota-fecven', 'Debe ser igual o posterior a la emisión'); ok = false; }

    if (lineasNota.length === 0) { mostrarError('err-nline', 'Agrega al menos un producto a la nota'); ok = false; }

    return ok;
}

function guardarNota(estado) {
    if (!validarEncabezadoNota()) return;
    const idNota = generarIdNota();
    // Aquí se construiría el payload para tab_enc_notas + tab_det_notas
    // con ind_estado = '<estado>' y se enviaría al backend.
    notaCounter++;
    mostrarToast(`Nota ${idNota} guardada como ${estado === 'BORRADOR' ? 'borrador' : 'emitida'}`);
    limpiarFormularioNota();
}

function limpiarFormularioNota() {
    lineasNota = [];
    document.getElementById('nota-factura').selectedIndex = 0;
    document.getElementById('nota-cliente-display').value = '';
    document.getElementById('nota-cufe-ref').value = '';
    document.getElementById('nota-observa').value = '';
    const hoy = new Date().toISOString().slice(0, 10);
    document.getElementById('nota-fecemi').value = hoy;
    document.getElementById('nota-fecven').value = hoy;
    seleccionarTipoNota('credito');
    actualizarNotaIdPreview();
    renderizarLineasNota();
}

function setupEventListenersNota() {
    document.getElementById('btn-tipo-credito').addEventListener('click', () => seleccionarTipoNota('credito'));
    document.getElementById('btn-tipo-debito').addEventListener('click', () => seleccionarTipoNota('debito'));
    document.getElementById('nota-factura').addEventListener('change', alSeleccionarFactura);
    document.getElementById('nota-fecemi').addEventListener('change', function () {
        if (!tipoNotaActual) document.getElementById('nota-fecven').value = this.value;
        document.getElementById('nota-fecven').min = this.value;
    });
    document.getElementById('btn-add-nline').addEventListener('click', agregarLineaNota);
    document.getElementById('btn-borrador-nota').addEventListener('click', () => guardarNota('BORRADOR'));
    document.getElementById('btn-emitir-nota').addEventListener('click', () => guardarNota('EMITIDA'));
}

document.addEventListener('DOMContentLoaded', () => {
    poblarSelectsNota();
    const hoy = new Date().toISOString().slice(0, 10);
    document.getElementById('nota-fecemi').value = hoy;
    document.getElementById('nota-fecemi').max = hoy;
    document.getElementById('nota-fecven').value = hoy;
    document.getElementById('nota-fecven').disabled = true;
    actualizarNotaIdPreview();
    renderizarLineasNota();
    setupEventListenersNota();
});
