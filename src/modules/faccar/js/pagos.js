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
// PAGOS - CONTROL COMPLETO
// Tabla: tab_pagos
// ============================================

let pagosData = [];
let nextPagoId = 1;
let editingPagoId = null;
let paEstadoFilter = 'all';

// Catálogo de referencia — inicia vacío hasta conectar el backend.
// Ejemplo para pruebas en consola:
//   facturasCatalogo.push({id:'FE000001', clienteNombre:'Laura Gómez'});
let facturasCatalogo = [];

function poblarSelectFacturaPago() {
    const sel = document.getElementById('new-pago-factura');
    if (facturasCatalogo.length) {
        sel.innerHTML = '<option value="" disabled selected>Selecciona una factura</option>' +
            facturasCatalogo.map(f => `<option value="${f.id}">${f.id} — ${escHtml(f.clienteNombre)}</option>`).join('');
    }
}

function badgeEstadoPago(estado) {
    const map = {
        APROBADO: '<span class="badge badge-success">APROBADO</span>',
        PENDIENTE: '<span class="badge badge-warning">PENDIENTE</span>',
        RECHAZADO: '<span class="badge badge-danger">RECHAZADO</span>',
    };
    return map[estado] || estado;
}

function actualizarStatsPagos() {
    const activos = pagosData.filter(p => !p.borrado);
    document.getElementById('stat-pa-total').innerText = activos.length;
    document.getElementById('stat-pa-aprobado').innerText = fmtMoney(activos.filter(p => p.estado === 'APROBADO').reduce((s, p) => s + p.valor, 0));
    document.getElementById('stat-pa-pendientes').innerText = activos.filter(p => p.estado === 'PENDIENTE').length;
    document.getElementById('stat-pa-rechazados').innerText = activos.filter(p => p.estado === 'RECHAZADO').length;
}

function renderizarPagosTabla() {
    const tbody = document.getElementById('pa-tbody');
    const busqueda = document.getElementById('pa-search')?.value.toLowerCase().trim() || '';

    let filtrados = pagosData.filter(p => {
        if (p.borrado) return false;
        const matchBusqueda = p.idFactura.toLowerCase().includes(busqueda) || p.referencia.toLowerCase().includes(busqueda);
        const matchEstado = paEstadoFilter === 'all' || p.estado === paEstadoFilter;
        return matchBusqueda && matchEstado;
    });

    document.getElementById('pa-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || paEstadoFilter !== 'all';
    document.getElementById('btn-clear-pa-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7"><div class="empty-state"><i class="fas fa-cash-register"></i><p>Sin pagos registrados</p><span>Registra el primer pago del sistema</span></div></td></tr>`;
        actualizarStatsPagos();
        return;
    }

    tbody.innerHTML = filtrados.map(p => `
        <tr data-id="${p.id}">
            <td class="cell-strong">${p.id}</td>
            <td>${escHtml(p.idFactura)}</td>
            <td>${fmtDate(p.fecPago)}</td>
            <td class="cell-strong">${fmtMoney(p.valor)}</td>
            <td class="cell-muted">${escHtml(p.referencia)}</td>
            <td>${badgeEstadoPago(p.estado)}</td>
            <td>
                <div class="row-actions">
                    <div class="prod-act-btn edit" data-id="${p.id}"><i class="fas fa-pen"></i></div>
                    <div class="prod-act-btn del" data-id="${p.id}"><i class="fas fa-trash"></i></div>
                </div>
            </td>
        </tr>
    `).join('');

    document.querySelectorAll('#pa-tbody .prod-act-btn.edit').forEach(btn => btn.addEventListener('click', () => abrirEditarPago(parseInt(btn.dataset.id))));
    document.querySelectorAll('#pa-tbody .prod-act-btn.del').forEach(btn => btn.addEventListener('click', () => confirmarEliminarPago(parseInt(btn.dataset.id))));

    actualizarStatsPagos();
}

function abrirNuevoPago() {
    document.getElementById('new-pago-factura').selectedIndex = 0;
    document.getElementById('new-pago-fecha').value = new Date().toISOString().slice(0, 10);
    document.getElementById('new-pago-valor').value = '';
    document.getElementById('new-pago-referencia').value = '';
    document.getElementById('new-pago-estado').value = 'PENDIENTE';
    document.getElementById('new-pago-observa').value = '';
    clearErroresPago();
    document.getElementById('modal-new-pago').classList.remove('hidden');
}

function abrirEditarPago(id) {
    const p = pagosData.find(x => x.id === id);
    if (!p) return;
    editingPagoId = id;
    document.getElementById('edit-pago-factura').value = p.idFactura;
    document.getElementById('edit-pago-valor').value = fmtMoney(p.valor);
    document.getElementById('edit-pago-estado').value = p.estado;
    document.getElementById('edit-pago-observa').value = p.observacion;
    document.getElementById('modal-edit-pago').classList.remove('hidden');
}

function clearErroresPago() {
    ['err-new-pago-factura','err-new-pago-valor','err-new-pago-referencia'].forEach(limpiarError);
}

function cerrarModalesPago() {
    document.getElementById('modal-new-pago').classList.add('hidden');
    document.getElementById('modal-edit-pago').classList.add('hidden');
    document.getElementById('modal-confirm').classList.add('hidden');
}

// Validación según CHECK de tab_pagos
function guardarNuevoPago(e) {
    e.preventDefault();
    clearErroresPago();
    let ok = true;

    const idFactura = document.getElementById('new-pago-factura').value;
    const fecha = document.getElementById('new-pago-fecha').value;
    const valor = parseInt(document.getElementById('new-pago-valor').value);
    const referencia = document.getElementById('new-pago-referencia').value.trim();

    if (!idFactura) { mostrarError('err-new-pago-factura', 'Selecciona una factura'); ok = false; }
    if (isNaN(valor) || valor < 0 || valor > 999999999999) { mostrarError('err-new-pago-valor', 'Valor entre 0 y 999.999.999.999'); ok = false; }
    if (!referencia || referencia.length > 100) { mostrarError('err-new-pago-referencia', 'Referencia requerida (máx. 100 caracteres)'); ok = false; }

    if (!ok) return;

    pagosData.push({
        id: nextPagoId++, idFactura, fecPago: fecha, valor, referencia,
        estado: document.getElementById('new-pago-estado').value,
        observacion: document.getElementById('new-pago-observa').value.trim() || 'Sin observaciones',
        borrado: false,
    });

    cerrarModalesPago();
    renderizarPagosTabla();
    mostrarToast('Pago registrado correctamente');
}

function guardarEdicionPago(e) {
    e.preventDefault();
    const idx = pagosData.findIndex(p => p.id === editingPagoId);
    if (idx === -1) return;
    pagosData[idx].estado = document.getElementById('edit-pago-estado').value;
    pagosData[idx].observacion = document.getElementById('edit-pago-observa').value.trim() || 'Sin observaciones';
    cerrarModalesPago();
    renderizarPagosTabla();
    mostrarToast('Pago actualizado correctamente');
}

function confirmarEliminarPago(id) {
    const p = pagosData.find(x => x.id === id);
    if (!p) return;
    window.pendingDeletePago = id;
    document.getElementById('confirm-title').innerText = `Eliminar pago N° ${id}`;
    document.getElementById('confirm-body').innerHTML = 'El pago se marcará como eliminado (borrado lógico). ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, eliminar';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function eliminarPagoConfirmado() {
    if (window.pendingDeletePago !== undefined && window.pendingDeletePago !== null) {
        const idx = pagosData.findIndex(p => p.id === window.pendingDeletePago);
        if (idx !== -1) pagosData[idx].borrado = true;
        cerrarModalesPago();
        renderizarPagosTabla();
        mostrarToast('Pago eliminado', true);
        window.pendingDeletePago = null;
    }
}

function limpiarFiltrosPago() {
    document.getElementById('pa-search').value = '';
    document.getElementById('pa-estado-filter').value = 'all';
    paEstadoFilter = 'all';
    renderizarPagosTabla();
}

function setupEventListenersPagos() {
    document.getElementById('btn-add-pago').addEventListener('click', abrirNuevoPago);
    document.querySelectorAll('.btn-close-new-pago, .btn-cancel-new-pago').forEach(b => b.addEventListener('click', cerrarModalesPago));
    document.querySelectorAll('.btn-close-edit-pago, .btn-cancel-edit-pago').forEach(b => b.addEventListener('click', cerrarModalesPago));
    document.getElementById('new-pago-form').addEventListener('submit', guardarNuevoPago);
    document.getElementById('edit-pago-form').addEventListener('submit', guardarEdicionPago);

    document.getElementById('pa-search').addEventListener('input', renderizarPagosTabla);
    document.getElementById('pa-estado-filter').addEventListener('change', (e) => { paEstadoFilter = e.target.value; renderizarPagosTabla(); });
    document.getElementById('btn-clear-pa-filters').addEventListener('click', limpiarFiltrosPago);

    document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
        document.getElementById('modal-confirm').classList.add('hidden');
        window.pendingDeletePago = null;
    });
    document.getElementById('confirm-ok-btn').addEventListener('click', eliminarPagoConfirmado);
    window.addEventListener('click', (e) => { if (e.target.classList.contains('modal-overlay')) cerrarModalesPago(); });
}

document.addEventListener('DOMContentLoaded', () => {
    const hoy = new Date().toISOString().slice(0, 10);
    document.getElementById('new-pago-fecha').max = hoy;
    poblarSelectFacturaPago();
    renderizarPagosTabla();
    setupEventListenersPagos();
});
