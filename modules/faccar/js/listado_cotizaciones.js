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
// LISTADO DE COTIZACIONES - CONTROL COMPLETO
// Tabla: tab_enc_cotizaciones
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend
// (SELECT sobre tab_enc_cotizaciones). Inicia vacío porque aún no
// hay integración con la base de datos.
let cotizacionesData = [];
let lcEstadoFilter = 'all';

function estadoCotizacion(fecVenc) {
    const hoy = new Date(); hoy.setHours(0,0,0,0);
    const f = new Date(fecVenc + 'T00:00:00');
    return f < hoy ? 'Vencida' : 'Vigente';
}

function actualizarStatsLc() {
    const activas = cotizacionesData.filter(c => !c.borrado);
    const total = activas.length;
    const vigentes = activas.filter(c => estadoCotizacion(c.fecVencimiento) === 'Vigente').length;
    const vencidas = total - vigentes;
    const valor = activas.reduce((s, c) => s + c.total, 0);
    document.getElementById('stat-lc-total').innerText = total;
    document.getElementById('stat-lc-vigentes').innerText = vigentes;
    document.getElementById('stat-lc-vencidas').innerText = vencidas;
    document.getElementById('stat-lc-valor').innerText = fmtMoney(valor);
}

function renderizarLcTabla() {
    const tbody = document.getElementById('lc-tbody');
    const busqueda = document.getElementById('lc-search')?.value.toLowerCase().trim() || '';

    let filtrados = cotizacionesData.filter(c => {
        if (c.borrado) return false;
        const matchBusqueda = c.id.toLowerCase().includes(busqueda) || c.clienteNombre.toLowerCase().includes(busqueda);
        const est = estadoCotizacion(c.fecVencimiento);
        const matchEstado = lcEstadoFilter === 'all' || est === lcEstadoFilter;
        return matchBusqueda && matchEstado;
    });

    document.getElementById('lc-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || lcEstadoFilter !== 'all';
    document.getElementById('btn-clear-lc-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8"><div class="empty-state"><i class="fas fa-file-lines"></i><p>Sin cotizaciones registradas</p><span>Las cotizaciones que generes aparecerán aquí</span></div></td></tr>`;
        actualizarStatsLc();
        return;
    }

    tbody.innerHTML = filtrados.map(c => {
        const est = estadoCotizacion(c.fecVencimiento);
        const badge = est === 'Vigente' ? '<span class="badge badge-success">VIGENTE</span>' : '<span class="badge badge-danger">VENCIDA</span>';
        return `
        <tr data-id="${c.id}">
            <td class="cell-strong">${c.id}</td>
            <td>${escHtml(c.clienteNombre)}</td>
            <td>${escHtml(c.vendedorNombre)}</td>
            <td>${fmtDate(c.fecCotizacion)}</td>
            <td>${fmtDate(c.fecVencimiento)}</td>
            <td class="cell-strong">${fmtMoney(c.total)}</td>
            <td>${badge}</td>
            <td>
                <div class="row-actions">
                    <div class="prod-act-btn view" data-id="${c.id}"><i class="fas fa-eye"></i></div>
                    <div class="prod-act-btn del" data-id="${c.id}"><i class="fas fa-ban"></i></div>
                </div>
            </td>
        </tr>`;
    }).join('');

    document.querySelectorAll('#lc-tbody .prod-act-btn.view').forEach(btn => {
        btn.addEventListener('click', () => verDetalleCotizacion(btn.dataset.id));
    });
    document.querySelectorAll('#lc-tbody .prod-act-btn.del').forEach(btn => {
        btn.addEventListener('click', () => confirmarAnularCotizacion(btn.dataset.id));
    });

    actualizarStatsLc();
}

function verDetalleCotizacion(id) {
    const c = cotizacionesData.find(x => x.id === id);
    if (!c) return;
    document.getElementById('ver-cot-id').textContent = c.id;
    document.getElementById('ver-cot-cliente').textContent = c.clienteNombre;
    document.getElementById('ver-cot-vendedor').textContent = c.vendedorNombre;
    document.getElementById('ver-cot-fecha').textContent = fmtDate(c.fecCotizacion);
    document.getElementById('ver-cot-vencimiento').textContent = fmtDate(c.fecVencimiento);
    document.getElementById('ver-cot-estado').textContent = estadoCotizacion(c.fecVencimiento);
    const tbody = document.getElementById('ver-cot-lineas');
    tbody.innerHTML = (c.lineas || []).map(l => `
        <tr><td>${escHtml(l.nombre)}</td><td>${l.cantidad}</td><td>${fmtMoney(l.descuento)}</td><td>${fmtMoney(l.iva)}</td><td class="cell-strong">${fmtMoney(l.neto)}</td></tr>
    `).join('') || '<tr><td colspan="5" class="cell-muted">Sin líneas registradas</td></tr>';
    document.getElementById('modal-ver-cot').classList.remove('hidden');
}

function confirmarAnularCotizacion(id) {
    window.pendingAnularCot = id;
    document.getElementById('confirm-title').innerText = `Anular cotización ${id}`;
    document.getElementById('confirm-body').innerHTML = 'La cotización se marcará como anulada (borrado lógico). ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, anular';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function anularCotizacionConfirmada() {
    if (window.pendingAnularCot) {
        const idx = cotizacionesData.findIndex(c => c.id === window.pendingAnularCot);
        if (idx !== -1) cotizacionesData[idx].borrado = true;
        document.getElementById('modal-confirm').classList.add('hidden');
        renderizarLcTabla();
        mostrarToast('Cotización anulada', true);
        window.pendingAnularCot = null;
    }
}

function limpiarFiltrosLc() {
    document.getElementById('lc-search').value = '';
    document.getElementById('lc-estado-filter').value = 'all';
    lcEstadoFilter = 'all';
    renderizarLcTabla();
}

function setupEventListenersLc() {
    document.getElementById('btn-go-nueva-cot').addEventListener('click', () => {
        // Ajusta esta navegación a la función de tu menú (ej. cargarModulo('nueva_cotizacion'))
        window.location.href = 'modules/faccar/src/listado_cotizaciones.php';
    });
    document.getElementById('lc-search').addEventListener('input', renderizarLcTabla);
    document.getElementById('lc-estado-filter').addEventListener('change', (e) => { lcEstadoFilter = e.target.value; renderizarLcTabla(); });
    document.getElementById('btn-clear-lc-filters').addEventListener('click', limpiarFiltrosLc);
    document.querySelectorAll('.btn-close-ver-cot').forEach(b => b.addEventListener('click', () => document.getElementById('modal-ver-cot').classList.add('hidden')));
    document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
        document.getElementById('modal-confirm').classList.add('hidden');
        window.pendingAnularCot = null;
    });
    document.getElementById('confirm-ok-btn').addEventListener('click', anularCotizacionConfirmada);
    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden');
    });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarLcTabla();
    setupEventListenersLc();
});
