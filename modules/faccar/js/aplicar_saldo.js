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
// APLICAR SALDO - CONTROL COMPLETO
// Tabla: tab_aplicacion_nota
// ============================================

// Catálogos de referencia — inician vacíos hasta conectar el backend.
// Ejemplo para pruebas en consola:
//   notasConSaldo.push({id:'NC-0000000001', clienteNombre:'Laura Gómez', total:150000, pendiente:150000});
//   facturasCatalogo.push({id:'FE000002', clienteNombre:'Laura Gómez'});
//   carteraCatalogo.push({id:1, clienteNombre:'Laura Gómez', cuota:'Cuota 1/3', pendiente:200000});
let notasConSaldo = [];
let facturasCatalogo = [];
let carteraCatalogo = [];
let aplicacionesData = [];
let nextAplicacionId = 1;
let destinoActual = 'factura'; // 'factura' | 'cartera'

function poblarSelectsAplicarSaldo() {
    const selNota = document.getElementById('as-nota');
    const selFactura = document.getElementById('as-factura');
    const selCartera = document.getElementById('as-cartera');

    if (notasConSaldo.length) {
        selNota.innerHTML = '<option value="" disabled selected>Selecciona una nota</option>' +
            notasConSaldo.map(n => `<option value="${n.id}">${n.id} — ${escHtml(n.clienteNombre)} (saldo: ${fmtMoney(n.pendiente)})</option>`).join('');
    }
    if (facturasCatalogo.length) {
        selFactura.innerHTML = '<option value="" disabled selected>Selecciona una factura</option>' +
            facturasCatalogo.map(f => `<option value="${f.id}">${f.id} — ${escHtml(f.clienteNombre)}</option>`).join('');
    }
    if (carteraCatalogo.length) {
        selCartera.innerHTML = '<option value="" disabled selected>Selecciona una cuota</option>' +
            carteraCatalogo.map(c => `<option value="${c.id}">${escHtml(c.clienteNombre)} — ${escHtml(c.cuota)} (pendiente: ${fmtMoney(c.pendiente)})</option>`).join('');
    }
}

function alSeleccionarNota() {
    const id = document.getElementById('as-nota').value;
    const n = notasConSaldo.find(x => x.id === id);
    const preview = document.getElementById('as-saldo-preview');
    if (!n) { preview.style.display = 'none'; return; }
    document.getElementById('as-nota-cliente').textContent = n.clienteNombre;
    document.getElementById('as-nota-total').textContent = fmtMoney(n.total);
    document.getElementById('as-nota-saldo').textContent = fmtMoney(n.pendiente);
    preview.style.display = 'flex';
}

function seleccionarDestino(destino) {
    destinoActual = destino;
    document.getElementById('btn-destino-factura').classList.toggle('active', destino === 'factura');
    document.getElementById('btn-destino-cartera').classList.toggle('active', destino === 'cartera');
    document.getElementById('grupo-as-factura').style.display = destino === 'factura' ? 'block' : 'none';
    document.getElementById('grupo-as-cartera').style.display = destino === 'cartera' ? 'block' : 'none';
}

function renderizarHistorialAplicaciones() {
    const cont = document.getElementById('as-historial-list');
    if (aplicacionesData.length === 0) {
        cont.innerHTML = `<div class="empty-state" style="padding:30px 10px;"><i class="fas fa-arrow-left-right"></i><p style="font-size:13px;">Sin aplicaciones registradas</p></div>`;
        return;
    }
    cont.innerHTML = aplicacionesData.slice().reverse().map(a => `
        <div class="as-historial-item">
            <div class="top-row"><span>${a.notaId} → ${a.destinoTipo === 'factura' ? a.destinoId : 'Cartera ' + a.destinoId}</span><span>${fmtMoney(a.valorAplicado)}</span></div>
            <div class="meta-row">Saldo: ${fmtMoney(a.saldoAnterior)} → ${fmtMoney(a.saldoDespues)} · ${fmtDate(a.fecha)}</div>
        </div>
    `).join('');
}

function validarAplicacionSaldo() {
    let ok = true;
    limpiarError('err-as-nota');
    limpiarError('err-as-destino');
    limpiarError('err-as-valor');

    const notaId = document.getElementById('as-nota').value;
    const nota = notasConSaldo.find(n => n.id === notaId);
    if (!nota) { mostrarError('err-as-nota', 'Selecciona una nota con saldo disponible'); ok = false; }

    const destinoId = destinoActual === 'factura' ? document.getElementById('as-factura').value : document.getElementById('as-cartera').value;
    if (!destinoId) { mostrarError('err-as-destino', `Selecciona la ${destinoActual === 'factura' ? 'factura' : 'cuota de cartera'} destino`); ok = false; }

    const valor = parseInt(document.getElementById('as-valor').value);
    if (isNaN(valor) || valor <= 0) { mostrarError('err-as-valor', 'Valor a aplicar debe ser mayor a 0'); ok = false; }
    else if (nota && valor > nota.pendiente) { mostrarError('err-as-valor', `No puede superar el saldo disponible (${fmtMoney(nota.pendiente)})`); ok = false; }

    return ok;
}

function aplicarSaldo() {
    if (!validarAplicacionSaldo()) return;

    const notaId = document.getElementById('as-nota').value;
    const nota = notasConSaldo.find(n => n.id === notaId);
    const destinoId = destinoActual === 'factura' ? document.getElementById('as-factura').value : document.getElementById('as-cartera').value;
    const valor = parseInt(document.getElementById('as-valor').value);
    const observa = document.getElementById('as-observa').value.trim() || 'Sin observaciones';

    const saldoAnterior = nota.pendiente;
    const saldoDespues = saldoAnterior - valor;

    aplicacionesData.push({
        id: nextAplicacionId++,
        notaId,
        destinoTipo: destinoActual,
        destinoId,
        valorAplicado: valor,
        saldoAnterior,
        saldoDespues,
        fecha: new Date().toISOString().slice(0, 10),
        observacion: observa,
    });

    nota.pendiente = saldoDespues;
    if (nota.pendiente <= 0) {
        notasConSaldo = notasConSaldo.filter(n => n.id !== notaId);
    }

    poblarSelectsAplicarSaldo();
    document.getElementById('as-nota').selectedIndex = 0;
    document.getElementById('as-valor').value = '';
    document.getElementById('as-observa').value = '';
    document.getElementById('as-saldo-preview').style.display = 'none';

    renderizarHistorialAplicaciones();
    mostrarToast(`Se aplicaron ${fmtMoney(valor)} de la nota ${notaId}`);
}

function setupEventListenersAplicarSaldo() {
    document.getElementById('as-nota').addEventListener('change', alSeleccionarNota);
    document.getElementById('btn-destino-factura').addEventListener('click', () => seleccionarDestino('factura'));
    document.getElementById('btn-destino-cartera').addEventListener('click', () => seleccionarDestino('cartera'));
    document.getElementById('btn-aplicar-saldo').addEventListener('click', aplicarSaldo);
}

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('as-fecha').value = new Date().toISOString().slice(0, 10);
    poblarSelectsAplicarSaldo();
    renderizarHistorialAplicaciones();
    setupEventListenersAplicarSaldo();
});
