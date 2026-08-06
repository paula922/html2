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
// LISTADO DE NOTAS - CONTROL COMPLETO
// Tablas: tab_enc_notas, tab_nota_elect
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend.
let notasData = [];
let lnTipoFilter = 'all';
let lnEstadoFilter = 'all';

function badgeEstadoNota(estado) {
    const map = {
        BORRADOR: '<span class="badge badge-neutral">BORRADOR</span>',
        EMITIDA: '<span class="badge badge-info">EMITIDA</span>',
        ENVIADA_DIAN: '<span class="badge badge-info">ENVIADA DIAN</span>',
        ACEPTADA_DIAN: '<span class="badge badge-success">ACEPTADA DIAN</span>',
        RECHAZADA_DIAN: '<span class="badge badge-danger">RECHAZADA DIAN</span>',
        ANULADA: '<span class="badge badge-danger">ANULADA</span>',
    };
    return map[estado] || estado;
}

function actualizarStatsLn() {
    const activas = notasData.filter(n => !n.borrado);
    const total = activas.length;
    const nc = activas.filter(n => !n.tipoNota).length;
    const nd = activas.filter(n => n.tipoNota).length;
    const pendiente = activas.reduce((s, n) => s + n.pendiente, 0);
    document.getElementById('stat-ln-total').innerText = total;
    document.getElementById('stat-ln-nc').innerText = nc;
    document.getElementById('stat-ln-nd').innerText = nd;
    document.getElementById('stat-ln-pendiente').innerText = fmtMoney(pendiente);
}

function renderizarLnTabla() {
    const tbody = document.getElementById('ln-tbody');
    const busqueda = document.getElementById('ln-search')?.value.toLowerCase().trim() || '';

    let filtrados = notasData.filter(n => {
        if (n.borrado) return false;
        const matchBusqueda = n.id.toLowerCase().includes(busqueda) || n.clienteNombre.toLowerCase().includes(busqueda);
        const matchTipo = lnTipoFilter === 'all' || (lnTipoFilter === 'NC' && !n.tipoNota) || (lnTipoFilter === 'ND' && n.tipoNota);
        const matchEstado = lnEstadoFilter === 'all' || n.estado === lnEstadoFilter;
        return matchBusqueda && matchTipo && matchEstado;
    });

    document.getElementById('ln-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || lnTipoFilter !== 'all' || lnEstadoFilter !== 'all';
    document.getElementById('btn-clear-ln-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state"><i class="fas fa-file-lines"></i><p>Sin notas registradas</p><span>Las notas crédito y débito que generes aparecerán aquí</span></div></td></tr>`;
        actualizarStatsLn();
        return;
    }

    tbody.innerHTML = filtrados.map(n => `
        <tr data-id="${n.id}">
            <td class="cell-strong">${n.id}</td>
            <td>${n.tipoNota ? '<span class="badge badge-purple">ND</span>' : '<span class="badge badge-info">NC</span>'}</td>
            <td>${escHtml(n.clienteNombre)}</td>
            <td class="cell-muted">${escHtml(n.motivoNombre)}</td>
            <td>${fmtDate(n.fecEmision)}</td>
            <td class="cell-strong">${fmtMoney(n.total)}</td>
            <td>${fmtMoney(n.pendiente)}</td>
            <td>${badgeEstadoNota(n.estado)}</td>
            <td>
                <div class="row-actions">
                    <div class="prod-act-btn view" data-id="${n.id}"><i class="fas fa-eye"></i></div>
                    ${n.estado !== 'ANULADA' ? `<div class="prod-act-btn del" data-id="${n.id}"><i class="fas fa-ban"></i></div>` : ''}
                </div>
            </td>
        </tr>
    `).join('');

    document.querySelectorAll('#ln-tbody .prod-act-btn.view').forEach(btn => btn.addEventListener('click', () => verDetalleNota(btn.dataset.id)));
    document.querySelectorAll('#ln-tbody .prod-act-btn.del').forEach(btn => btn.addEventListener('click', () => confirmarAnularNota(btn.dataset.id)));

    actualizarStatsLn();
}

function verDetalleNota(id) {
    const n = notasData.find(x => x.id === id);
    if (!n) return;
    document.getElementById('ver-nota-id').textContent = n.id;
    document.getElementById('ver-nota-cliente').textContent = n.clienteNombre;
    document.getElementById('ver-nota-motivo').textContent = n.motivoNombre;
    document.getElementById('ver-nota-factura').textContent = n.facturaRef;
    document.getElementById('ver-nota-estado').innerHTML = badgeEstadoNota(n.estado);
    document.getElementById('ver-nota-total').textContent = fmtMoney(n.total);
    document.getElementById('ver-nota-aplicado').textContent = fmtMoney(n.aplicado);
    document.getElementById('ver-nota-pendiente').textContent = fmtMoney(n.pendiente);

    const tbody = document.getElementById('ver-nota-lineas');
    tbody.innerHTML = (n.lineas || []).map(l => `
        <tr><td>${escHtml(l.nombre)}</td><td>${l.cantidad}</td><td>${fmtMoney(l.descuento)}</td><td>${fmtMoney(l.iva)}</td><td class="cell-strong">${fmtMoney(l.neto)}</td></tr>
    `).join('') || '<tr><td colspan="5" class="cell-muted">Sin líneas registradas</td></tr>';

    const qrContainer = document.getElementById('nota-qr-container');
    qrContainer.innerHTML = '';
    if (window.QRCode && n.cude) {
        new QRCode(qrContainer, { text: n.cude, width: 140, height: 140 });
    } else {
        qrContainer.innerHTML = '<i class="fas fa-qrcode" style="font-size:40px;color:var(--dash-text-muted);"></i>';
    }

    document.getElementById('modal-ver-nota').classList.remove('hidden');
}

function confirmarAnularNota(id) {
    window.pendingAnularNota = id;
    document.getElementById('confirm-title').innerText = `Anular nota ${id}`;
    document.getElementById('confirm-body').innerHTML = 'La nota pasará a estado ANULADA. ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, anular';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function anularNotaConfirmada() {
    if (window.pendingAnularNota) {
        const idx = notasData.findIndex(n => n.id === window.pendingAnularNota);
        if (idx !== -1) notasData[idx].estado = 'ANULADA';
        document.getElementById('modal-confirm').classList.add('hidden');
        renderizarLnTabla();
        mostrarToast('Nota anulada', true);
        window.pendingAnularNota = null;
    }
}

function limpiarFiltrosLn() {
    document.getElementById('ln-search').value = '';
    document.getElementById('ln-tipo-filter').value = 'all';
    document.getElementById('ln-estado-filter').value = 'all';
    lnTipoFilter = 'all';
    lnEstadoFilter = 'all';
    renderizarLnTabla();
}

function setupEventListenersLn() {
    document.getElementById('btn-go-crear-nota').addEventListener('click', () => { window.location.href = 'crear_nota.php'; });
    document.getElementById('ln-search').addEventListener('input', renderizarLnTabla);
    document.getElementById('ln-tipo-filter').addEventListener('change', (e) => { lnTipoFilter = e.target.value; renderizarLnTabla(); });
    document.getElementById('ln-estado-filter').addEventListener('change', (e) => { lnEstadoFilter = e.target.value; renderizarLnTabla(); });
    document.getElementById('btn-clear-ln-filters').addEventListener('click', limpiarFiltrosLn);
    document.querySelectorAll('.btn-close-ver-nota').forEach(b => b.addEventListener('click', () => document.getElementById('modal-ver-nota').classList.add('hidden')));
    document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
        document.getElementById('modal-confirm').classList.add('hidden');
        window.pendingAnularNota = null;
    });
    document.getElementById('confirm-ok-btn').addEventListener('click', anularNotaConfirmada);
    window.addEventListener('click', (e) => { if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden'); });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarLnTabla();
    setupEventListenersLn();
});
