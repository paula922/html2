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
// VENDEDORES - CONTROL COMPLETO
// Tabla: tab_vendedores (+ datos de tab_empleados)
// ============================================

let vendedoresData = [];
let nextVendedorId = 1;
let editingVendedorId = null;
let vendedorStatusFilter = 'all';

function initVendedorData() {
    vendedoresData = [];
    nextVendedorId = 1;
}

function inicialesVendedor(nombre) {
    const partes = nombre.trim().split(/\s+/);
    return ((partes[0]?.[0] || '') + (partes[1]?.[0] || '')).toUpperCase();
}

function actualizarStatsVendedor() {
    const total = vendedoresData.length;
    const activos = vendedoresData.filter(v => v.estado).length;
    const comisionProm = total ? Math.round(vendedoresData.reduce((s, v) => s + v.comision, 0) / total) : 0;
    const acumulado = vendedoresData.reduce((s, v) => s + v.ventaAcumulada, 0);
    document.getElementById('stat-ven-total').innerText = total;
    document.getElementById('stat-ven-activos').innerText = activos;
    document.getElementById('stat-ven-comision').innerText = comisionProm + '%';
    document.getElementById('stat-ven-acumulado').innerText = fmtMoney(acumulado);
}

function renderizarVendedorGrid() {
    const grid = document.getElementById('vendedor-grid');
    const busqueda = document.getElementById('vendedor-search')?.value.toLowerCase().trim() || '';

    let filtrados = vendedoresData.filter(v => {
        const matchBusqueda = v.nombre.toLowerCase().includes(busqueda) || v.idVendedor.toLowerCase().includes(busqueda);
        const matchStatus = vendedorStatusFilter === 'all' ||
                           (vendedorStatusFilter === 'active' && v.estado) ||
                           (vendedorStatusFilter === 'inactive' && !v.estado);
        return matchBusqueda && matchStatus;
    });

    document.getElementById('vendedor-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || vendedorStatusFilter !== 'all';
    document.getElementById('btn-clear-vendedor-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        grid.innerHTML = `<div class="empty-state"><i class="fas fa-user-tie"></i><p>Sin resultados</p><span>Prueba otros filtros o agrega un vendedor</span></div>`;
        actualizarStatsVendedor();
        return;
    }

    grid.innerHTML = filtrados.map(v => `
        <div class="vendedor-card ${!v.estado ? 'inactive' : ''}" data-id="${v.id}">
            <div class="vendedor-action-btns">
                <div class="prod-act-btn edit" data-id="${v.id}"><i class="fas fa-pen"></i></div>
                <div class="prod-act-btn del" data-id="${v.id}"><i class="fas fa-trash"></i></div>
            </div>
            <div class="vendedor-card-top">
                <div class="vendedor-avatar">${inicialesVendedor(v.nombre)}</div>
                <div>
                    <div class="vendedor-nombre">${escHtml(v.nombre)}</div>
                    <div class="vendedor-id">ID: ${escHtml(v.idVendedor)}</div>
                    ${v.estado ? '<span class="badge badge-success" style="margin-top:4px;">ACTIVO</span>' : '<span class="badge badge-danger" style="margin-top:4px;">INACTIVO</span>'}
                </div>
            </div>
            <div class="vendedor-divider"></div>
            <div class="vendedor-metric-row">
                <div>
                    <div class="vendedor-metric-label">Ventas Acumuladas</div>
                    <div class="vendedor-acumulado">${fmtMoney(v.ventaAcumulada)}</div>
                </div>
                <div class="vendedor-comision-pill">${v.comision}%</div>
            </div>
        </div>
    `).join('');

    document.querySelectorAll('#vendedor-grid .prod-act-btn.edit').forEach(btn => {
        btn.addEventListener('click', () => abrirEditarVendedor(parseInt(btn.dataset.id)));
    });
    document.querySelectorAll('#vendedor-grid .prod-act-btn.del').forEach(btn => {
        btn.addEventListener('click', () => confirmarEliminarVendedor(parseInt(btn.dataset.id)));
    });

    actualizarStatsVendedor();
}

function abrirNuevoVendedor() {
    document.getElementById('new-vendedor-nombre').value = '';
    document.getElementById('new-vendedor-id').value = '';
    document.getElementById('new-vendedor-comision').value = '';
    setToggle('new-vendedor-toggle-switch', 'new-vendedor-toggle-status', true, 'VENDEDOR ACTIVO', 'VENDEDOR INACTIVO');
    clearErroresVendedor();
    document.getElementById('modal-new-vendedor').classList.remove('hidden');
}

function abrirEditarVendedor(id) {
    const v = vendedoresData.find(x => x.id === id);
    if (!v) return;
    editingVendedorId = id;
    clearErroresVendedor();
    document.getElementById('edit-vendedor-nombre').value = v.nombre;
    document.getElementById('edit-vendedor-id').value = v.idVendedor;
    document.getElementById('edit-vendedor-comision').value = v.comision;
    document.getElementById('edit-vendedor-acumulado').value = fmtMoney(v.ventaAcumulada);
    setToggle('edit-vendedor-toggle-switch', 'edit-vendedor-toggle-status', v.estado, 'VENDEDOR ACTIVO', 'VENDEDOR INACTIVO');
    document.getElementById('modal-edit-vendedor').classList.remove('hidden');
}

function clearErroresVendedor() {
    ['err-new-vendedor-nombre','err-new-vendedor-id','err-new-vendedor-comision','err-edit-vendedor-nombre','err-edit-vendedor-comision'].forEach(limpiarError);
}

function cerrarModalesVendedor() {
    document.getElementById('modal-new-vendedor').classList.add('hidden');
    document.getElementById('modal-edit-vendedor').classList.add('hidden');
    document.getElementById('modal-confirm').classList.add('hidden');
}

// Validación según CHECK de tab_vendedores: id_vendedor (len>=6, vía tab_empleados), val_porcomision 1-99
function guardarNuevoVendedor(e) {
    e.preventDefault();
    clearErroresVendedor();
    let ok = true;
    const nombre = document.getElementById('new-vendedor-nombre').value.trim();
    const idVendedor = document.getElementById('new-vendedor-id').value.trim();
    const comision = parseInt(document.getElementById('new-vendedor-comision').value);

    if (!nombre) { mostrarError('err-new-vendedor-nombre', 'Nombre requerido'); ok = false; }
    if (idVendedor.length < 6) { mostrarError('err-new-vendedor-id', 'Mínimo 6 caracteres'); ok = false; }
    else if (vendedoresData.some(v => v.idVendedor === idVendedor)) { mostrarError('err-new-vendedor-id', 'Ya existe un vendedor con esa identificación'); ok = false; }
    if (isNaN(comision) || comision < 1 || comision > 99) { mostrarError('err-new-vendedor-comision', 'Comisión entre 1 y 99'); ok = false; }

    if (!ok) return;

    vendedoresData.push({
        id: nextVendedorId++,
        nombre, idVendedor, comision,
        ventaAcumulada: 0,
        estado: document.getElementById('new-vendedor-toggle-switch').classList.contains('on'),
    });
    cerrarModalesVendedor();
    renderizarVendedorGrid();
    mostrarToast('Vendedor agregado correctamente');
}

function guardarEdicionVendedor(e) {
    e.preventDefault();
    clearErroresVendedor();
    const nombre = document.getElementById('edit-vendedor-nombre').value.trim();
    const comision = parseInt(document.getElementById('edit-vendedor-comision').value);
    let ok = true;

    if (!nombre) { mostrarError('err-edit-vendedor-nombre', 'Nombre requerido'); ok = false; }
    if (isNaN(comision) || comision < 1 || comision > 99) { mostrarError('err-edit-vendedor-comision', 'Comisión entre 1 y 99'); ok = false; }

    if (!ok) return;

    const idx = vendedoresData.findIndex(v => v.id === editingVendedorId);
    if (idx === -1) return;
    vendedoresData[idx].nombre = nombre;
    vendedoresData[idx].comision = comision;
    vendedoresData[idx].estado = document.getElementById('edit-vendedor-toggle-switch').classList.contains('on');
    cerrarModalesVendedor();
    renderizarVendedorGrid();
    mostrarToast('Vendedor actualizado correctamente');
}

function confirmarEliminarVendedor(id) {
    const v = vendedoresData.find(x => x.id === id);
    if (!v) return;
    window.pendingDeleteVendedor = id;
    document.getElementById('confirm-title').innerText = `Eliminar a "${escHtml(v.nombre)}"`;
    document.getElementById('confirm-body').innerHTML = 'Esta acción es permanente. ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, eliminar';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function eliminarVendedorConfirmado() {
    if (window.pendingDeleteVendedor !== undefined && window.pendingDeleteVendedor !== null) {
        vendedoresData = vendedoresData.filter(v => v.id !== window.pendingDeleteVendedor);
        cerrarModalesVendedor();
        renderizarVendedorGrid();
        mostrarToast('Vendedor eliminado', true);
        window.pendingDeleteVendedor = null;
    }
}

function limpiarFiltrosVendedor() {
    document.getElementById('vendedor-search').value = '';
    vendedorStatusFilter = 'all';
    const btn = document.getElementById('btn-vendedor-status-toggle');
    btn.textContent = 'Estado: Todos';
    btn.classList.remove('active');
    renderizarVendedorGrid();
}

function setupEventListenersVendedor() {
    document.getElementById('btn-add-vendedor').addEventListener('click', abrirNuevoVendedor);
    document.querySelectorAll('.btn-close-new-vendedor, .btn-cancel-new-vendedor').forEach(b => b.addEventListener('click', cerrarModalesVendedor));
    document.querySelectorAll('.btn-close-edit-vendedor, .btn-cancel-edit-vendedor').forEach(b => b.addEventListener('click', cerrarModalesVendedor));
    document.getElementById('new-vendedor-form').addEventListener('submit', guardarNuevoVendedor);
    document.getElementById('edit-vendedor-form').addEventListener('submit', guardarEdicionVendedor);

    document.getElementById('new-vendedor-toggle-switch').addEventListener('click', function () {
        const on = !this.classList.contains('on');
        setToggle('new-vendedor-toggle-switch', 'new-vendedor-toggle-status', on, 'VENDEDOR ACTIVO', 'VENDEDOR INACTIVO');
    });
    document.getElementById('edit-vendedor-toggle-switch').addEventListener('click', function () {
        const on = !this.classList.contains('on');
        setToggle('edit-vendedor-toggle-switch', 'edit-vendedor-toggle-status', on, 'VENDEDOR ACTIVO', 'VENDEDOR INACTIVO');
    });

    document.getElementById('vendedor-search').addEventListener('input', renderizarVendedorGrid);

    const statusBtn = document.getElementById('btn-vendedor-status-toggle');
    statusBtn.addEventListener('click', () => {
        if (vendedorStatusFilter === 'all') vendedorStatusFilter = 'active';
        else if (vendedorStatusFilter === 'active') vendedorStatusFilter = 'inactive';
        else vendedorStatusFilter = 'all';
        statusBtn.textContent = `Estado: ${vendedorStatusFilter === 'active' ? 'Activos' : (vendedorStatusFilter === 'inactive' ? 'Inactivos' : 'Todos')}`;
        statusBtn.classList.toggle('active', vendedorStatusFilter !== 'all');
        renderizarVendedorGrid();
    });

    document.getElementById('btn-clear-vendedor-filters').addEventListener('click', limpiarFiltrosVendedor);
    document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
        document.getElementById('modal-confirm').classList.add('hidden');
        window.pendingDeleteVendedor = null;
    });
    document.getElementById('confirm-ok-btn').addEventListener('click', eliminarVendedorConfirmado);

    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal-overlay')) cerrarModalesVendedor();
    });
}

document.addEventListener('DOMContentLoaded', () => {
    initVendedorData();
    renderizarVendedorGrid();
    setupEventListenersVendedor();
});
