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
// GESTIÓN DE CARTERA - CONTROL COMPLETO
// Tabla: tab_carteras
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend,
// alimentado automáticamente al facturar a crédito.
let carteraData = [];
let caEstadoFilter = 'all';
let nextPagoId = 1;

function diasMora(fecProxPago) {
    const hoy = new Date(); hoy.setHours(0,0,0,0);
    const f = new Date(fecProxPago + 'T00:00:00');
    const dias = Math.round((hoy - f) / 86400000);
    return dias > 0 ? dias : 0;
}

function estadoVisual(c) {
    if (c.estado === 'Pagada' || c.estado === 'perdida') return c.estado;
    return diasMora(c.fecProxPago) > 0 ? 'vencida' : 'pendiente';
}

function badgeEstadoCartera(estado) {
    const map = {
        Pagada: '<span class="badge badge-success">PAGADA</span>',
        pendiente: '<span class="badge badge-warning">PENDIENTE</span>',
        vencida: '<span class="badge badge-danger">VENCIDA</span>',
        perdida: '<span class="badge badge-neutral">PERDIDA</span>',
    };
    return map[estado] || estado;
}

function actualizarStatsCartera() {
    const activas = carteraData.filter(c => !c.borrado);
    const total = activas.length;
    const pagadas = activas.filter(c => estadoVisual(c) === 'Pagada').length;
    const pendientes = activas.filter(c => estadoVisual(c) === 'pendiente').length;
    const vencidas = activas.filter(c => estadoVisual(c) === 'vencida').length;
    document.getElementById('stat-ca-total').innerText = total;
    document.getElementById('stat-ca-pagadas').innerText = pagadas;
    document.getElementById('stat-ca-pendientes').innerText = pendientes;
    document.getElementById('stat-ca-vencidas').innerText = vencidas;
}

function renderizarCarteraTabla() {
    const tbody = document.getElementById('ca-tbody');
    const busqueda = document.getElementById('ca-search')?.value.toLowerCase().trim() || '';

    let filtrados = carteraData.filter(c => {
        if (c.borrado) return false;
        const matchBusqueda = c.idFactura.toLowerCase().includes(busqueda) || c.clienteNombre.toLowerCase().includes(busqueda);
        const matchEstado = caEstadoFilter === 'all' || estadoVisual(c) === caEstadoFilter;
        return matchBusqueda && matchEstado;
    });

    document.getElementById('ca-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || caEstadoFilter !== 'all';
    document.getElementById('btn-clear-ca-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state"><i class="fas fa-wallet"></i><p>Sin cuotas de cartera registradas</p><span>Se generan automáticamente al facturar a crédito</span></div></td></tr>`;
        actualizarStatsCartera();
        return;
    }

    tbody.innerHTML = filtrados.map(c => {
        const est = estadoVisual(c);
        const mora = diasMora(c.fecProxPago);
        return `
        <tr data-id="${c.id}">
            <td class="cell-strong">${c.id}</td>
            <td>${escHtml(c.idFactura)}</td>
            <td>${escHtml(c.clienteNombre)}</td>
            <td>${fmtMoney(c.monto)}</td>
            <td class="cell-strong">${fmtMoney(c.pendiente)}</td>
            <td>${fmtDate(c.fecProxPago)}</td>
            <td>${mora > 0 ? `<span class="badge badge-danger">${mora}d</span>` : '<span class="cell-muted">—</span>'}</td>
            <td>${badgeEstadoCartera(est)}</td>
            <td>
                <div class="row-actions">
                    ${est !== 'Pagada' && est !== 'perdida' ? `<div class="prod-act-btn money" data-id="${c.id}" title="Registrar pago"><i class="fas fa-hand-holding-dollar"></i></div>` : ''}
                </div>
            </td>
        </tr>`;
    }).join('');

    document.querySelectorAll('#ca-tbody .prod-act-btn.money').forEach(btn => {
        btn.addEventListener('click', () => abrirPagoCartera(parseInt(btn.dataset.id)));
    });

    actualizarStatsCartera();
}

function abrirPagoCartera(id) {
    const c = carteraData.find(x => x.id === id);
    if (!c) return;
    document.getElementById('pc-id-cartera').value = id;
    document.getElementById('pc-cliente').textContent = c.clienteNombre;
    document.getElementById('pc-pendiente').textContent = fmtMoney(c.pendiente);
    document.getElementById('pc-valor').value = '';
    document.getElementById('pc-referencia').value = '';
    limpiarError('err-pc-valor');
    limpiarError('err-pc-referencia');
    document.getElementById('modal-pago-cartera').classList.remove('hidden');
}

function cerrarModalPagoCartera() {
    document.getElementById('modal-pago-cartera').classList.add('hidden');
}

// Validación según CHECK de tab_pagos / tab_carteras
function guardarPagoCartera(e) {
    e.preventDefault();
    limpiarError('err-pc-valor');
    limpiarError('err-pc-referencia');
    let ok = true;

    const id = parseInt(document.getElementById('pc-id-cartera').value);
    const c = carteraData.find(x => x.id === id);
    const valor = parseInt(document.getElementById('pc-valor').value);
    const referencia = document.getElementById('pc-referencia').value.trim();

    if (isNaN(valor) || valor <= 0) { mostrarError('err-pc-valor', 'Valor debe ser mayor a 0'); ok = false; }
    else if (c && valor > c.pendiente) { mostrarError('err-pc-valor', `No puede superar el pendiente (${fmtMoney(c.pendiente)})`); ok = false; }
    if (!referencia || referencia.length > 100) { mostrarError('err-pc-referencia', 'Referencia requerida (máx. 100 caracteres)'); ok = false; }

    if (!ok || !c) return;

    c.pendiente -= valor;
    c.idPago = nextPagoId++;
    if (c.pendiente <= 0) {
        c.pendiente = 0;
        c.estado = 'Pagada';
    }

    cerrarModalPagoCartera();
    renderizarCarteraTabla();
    mostrarToast(`Pago de ${fmtMoney(valor)} registrado correctamente`);
}

function limpiarFiltrosCartera() {
    document.getElementById('ca-search').value = '';
    document.getElementById('ca-estado-filter').value = 'all';
    caEstadoFilter = 'all';
    renderizarCarteraTabla();
}

function setupEventListenersCartera() {
    document.getElementById('ca-search').addEventListener('input', renderizarCarteraTabla);
    document.getElementById('ca-estado-filter').addEventListener('change', (e) => { caEstadoFilter = e.target.value; renderizarCarteraTabla(); });
    document.getElementById('btn-clear-ca-filters').addEventListener('click', limpiarFiltrosCartera);
    document.querySelectorAll('.btn-close-pago-cartera, .btn-cancel-pago-cartera').forEach(b => b.addEventListener('click', cerrarModalPagoCartera));
    document.getElementById('pago-cartera-form').addEventListener('submit', guardarPagoCartera);
    window.addEventListener('click', (e) => { if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden'); });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarCarteraTabla();
    setupEventListenersCartera();
});
