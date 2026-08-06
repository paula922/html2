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
// LISTADO DE FACTURAS - CONTROL COMPLETO
// Tabla: tab_enc_facturas
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend.
let facturasData = [];
let lfEstadoFilter = 'all';
let lfCerradaFilter = 'all'; // 'all', 'cerrada', 'abierta'

function actualizarStatsLf() {
    const activas = facturasData.filter(f => !f.borrado);
    const total = activas.length;
    const valor = activas.reduce((s, f) => s + f.total, 0);
    const cerradas = activas.filter(f => f.cerrada).length;
    const abiertas = total - cerradas;
    document.getElementById('stat-lf-total').innerText = total;
    document.getElementById('stat-lf-valor').innerText = fmtMoney(valor);
    document.getElementById('stat-lf-cerradas').innerText = cerradas;
    document.getElementById('stat-lf-abiertas').innerText = abiertas;
}

function renderizarLfTabla() {
    const tbody = document.getElementById('lf-tbody');
    const busqueda = document.getElementById('lf-search')?.value.toLowerCase().trim() || '';

    let filtrados = facturasData.filter(f => {
        if (f.borrado) return false;
        const matchBusqueda = f.id.toLowerCase().includes(busqueda) || f.clienteNombre.toLowerCase().includes(busqueda);
        const matchEstado = lfEstadoFilter === 'all' || f.estado === lfEstadoFilter;
        const matchCerrada = lfCerradaFilter === 'all' ||
                             (lfCerradaFilter === 'cerrada' && f.cerrada) ||
                             (lfCerradaFilter === 'abierta' && !f.cerrada);
        return matchBusqueda && matchEstado && matchCerrada;
    });

    document.getElementById('lf-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || lfEstadoFilter !== 'all' || lfCerradaFilter !== 'all';
    document.getElementById('btn-clear-lf-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8"><div class="empty-state"><i class="fas fa-receipt"></i><p>Sin facturas registradas</p><span>Las facturas que generes aparecerán aquí</span></div></td></tr>`;
        actualizarStatsLf();
        return;
    }

    tbody.innerHTML = filtrados.map(f => {
        const badgeEstado = f.estado === 'Activa' ? '<span class="badge badge-success">ACTIVA</span>' : '<span class="badge badge-danger">VENCIDA</span>';
        const badgeCerrada = f.cerrada ? '<span class="badge badge-purple"><i class="fas fa-lock"></i> Impresa</span>' : '<span class="badge badge-neutral">Abierta</span>';
        return `
        <tr data-id="${f.id}">
            <td class="cell-strong">${f.id}</td>
            <td>${escHtml(f.clienteNombre)}</td>
            <td>${escHtml(f.vendedorNombre)}</td>
            <td>${fmtDate(f.fecFactura)}</td>
            <td>${escHtml(f.formaPagoNombre)}</td>
            <td class="cell-strong">${fmtMoney(f.total)}</td>
            <td>${badgeEstado}<div style="margin-top:4px;">${badgeCerrada}</div></td>
            <td>
                <div class="row-actions">
                    <div class="prod-act-btn view" data-id="${f.id}" title="Ver detalle"><i class="fas fa-eye"></i></div>
                    ${!f.cerrada ? `<div class="prod-act-btn money" data-id="${f.id}" title="Cerrar / imprimir"><i class="fas fa-print"></i></div>` : ''}
                    <div class="prod-act-btn del" data-id="${f.id}" title="Anular"><i class="fas fa-ban"></i></div>
                </div>
            </td>
        </tr>`;
    }).join('');

    document.querySelectorAll('#lf-tbody .prod-act-btn.view').forEach(btn => btn.addEventListener('click', () => verDetalleFactura(btn.dataset.id)));
    document.querySelectorAll('#lf-tbody .prod-act-btn.money').forEach(btn => btn.addEventListener('click', () => cerrarFactura(btn.dataset.id)));
    document.querySelectorAll('#lf-tbody .prod-act-btn.del').forEach(btn => btn.addEventListener('click', () => confirmarAnularFactura(btn.dataset.id)));

    actualizarStatsLf();
}

function verDetalleFactura(id) {
    const f = facturasData.find(x => x.id === id);
    if (!f) return;
    document.getElementById('ver-fac-id').textContent = f.id;
    document.getElementById('ver-fac-cliente').textContent = f.clienteNombre;
    document.getElementById('ver-fac-vendedor').textContent = f.vendedorNombre;
    document.getElementById('ver-fac-fecha').textContent = fmtDate(f.fecFactura);
    document.getElementById('ver-fac-formapago').textContent = f.formaPagoNombre;
    document.getElementById('ver-fac-estado').textContent = f.estado + (f.cerrada ? ' · Impresa' : ' · Abierta');
    const tbody = document.getElementById('ver-fac-lineas');
    tbody.innerHTML = (f.lineas || []).map(l => `
        <tr><td>${escHtml(l.nombre)}</td><td>${l.cantidad}</td><td>${fmtMoney(l.descuento)}</td><td>${fmtMoney(l.iva)}</td><td class="cell-strong">${fmtMoney(l.neto)}</td></tr>
    `).join('') || '<tr><td colspan="5" class="cell-muted">Sin líneas registradas</td></tr>';
    document.getElementById('modal-ver-fac').classList.remove('hidden');
}

function cerrarFactura(id) {
    const idx = facturasData.findIndex(f => f.id === id);
    if (idx === -1) return;
    facturasData[idx].cerrada = true;
    renderizarLfTabla();
    mostrarToast(`Factura ${id} cerrada e impresa`);
}

function confirmarAnularFactura(id) {
    window.pendingAnularFac = id;
    document.getElementById('confirm-title').innerText = `Anular factura ${id}`;
    document.getElementById('confirm-body').innerHTML = 'La factura se marcará como anulada (borrado lógico). ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, anular';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function anularFacturaConfirmada() {
    if (window.pendingAnularFac) {
        const idx = facturasData.findIndex(f => f.id === window.pendingAnularFac);
        if (idx !== -1) facturasData[idx].borrado = true;
        document.getElementById('modal-confirm').classList.add('hidden');
        renderizarLfTabla();
        mostrarToast('Factura anulada', true);
        window.pendingAnularFac = null;
    }
}

function limpiarFiltrosLf() {
    document.getElementById('lf-search').value = '';
    document.getElementById('lf-estado-filter').value = 'all';
    lfEstadoFilter = 'all';
    lfCerradaFilter = 'all';
    const btn = document.getElementById('btn-lf-cerrada-toggle');
    btn.textContent = 'Impresión: Todas';
    btn.classList.remove('active');
    renderizarLfTabla();
}

function setupEventListenersLf() {
    document.getElementById('btn-go-nueva-fac').addEventListener('click', () => {
        window.location.href = 'nueva_factura.php';
    });
    document.getElementById('lf-search').addEventListener('input', renderizarLfTabla);
    document.getElementById('lf-estado-filter').addEventListener('change', (e) => { lfEstadoFilter = e.target.value; renderizarLfTabla(); });

    const cerradaBtn = document.getElementById('btn-lf-cerrada-toggle');
    cerradaBtn.addEventListener('click', () => {
        if (lfCerradaFilter === 'all') lfCerradaFilter = 'abierta';
        else if (lfCerradaFilter === 'abierta') lfCerradaFilter = 'cerrada';
        else lfCerradaFilter = 'all';
        cerradaBtn.textContent = `Impresión: ${lfCerradaFilter === 'abierta' ? 'Abiertas' : (lfCerradaFilter === 'cerrada' ? 'Impresas' : 'Todas')}`;
        cerradaBtn.classList.toggle('active', lfCerradaFilter !== 'all');
        renderizarLfTabla();
    });

    document.getElementById('btn-clear-lf-filters').addEventListener('click', limpiarFiltrosLf);
    document.querySelectorAll('.btn-close-ver-fac').forEach(b => b.addEventListener('click', () => document.getElementById('modal-ver-fac').classList.add('hidden')));
    document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
        document.getElementById('modal-confirm').classList.add('hidden');
        window.pendingAnularFac = null;
    });
    document.getElementById('confirm-ok-btn').addEventListener('click', anularFacturaConfirmada);
    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden');
    });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarLfTabla();
    setupEventListenersLf();
});
