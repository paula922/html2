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
// CASTIGAR CARTERA - CONTROL COMPLETO
// Tabla: tab_carteras
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend (misma
// fuente que el módulo de Gestión de Cartera).
let carteraCastigoData = [];
let seleccionCastigo = new Set();

function diasMoraCas(fecProxPago) {
    const hoy = new Date(); hoy.setHours(0,0,0,0);
    const f = new Date(fecProxPago + 'T00:00:00');
    const dias = Math.round((hoy - f) / 86400000);
    return dias > 0 ? dias : 0;
}

function getUmbral() {
    const v = parseInt(document.getElementById('umbral-dias').value);
    return isNaN(v) ? 180 : v;
}

function actualizarStatsCastigo(candidatas) {
    const yaCastigadas = carteraCastigoData.filter(c => c.estado === 'perdida').length;
    const valorRiesgo = candidatas.reduce((s, c) => s + c.pendiente, 0);
    document.getElementById('stat-cas-candidatas').innerText = candidatas.length;
    document.getElementById('stat-cas-valor').innerText = fmtMoney(valorRiesgo);
    document.getElementById('stat-cas-castigadas').innerText = yaCastigadas;
}

function renderizarCastigoTabla() {
    const tbody = document.getElementById('cas-tbody');
    const busqueda = document.getElementById('cas-search')?.value.toLowerCase().trim() || '';
    const umbral = getUmbral();

    const candidatas = carteraCastigoData.filter(c =>
        !c.borrado && c.estado !== 'Pagada' && c.estado !== 'perdida' && diasMoraCas(c.fecProxPago) > umbral
    );

    let filtrados = candidatas.filter(c =>
        c.idFactura.toLowerCase().includes(busqueda) || c.clienteNombre.toLowerCase().includes(busqueda)
    );

    document.getElementById('cas-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7"><div class="empty-state"><i class="fas fa-circle-check"></i><p>Sin cuentas candidatas a castigo</p><span>No hay cuotas vencidas por encima del límite configurado</span></div></td></tr>`;
        actualizarStatsCastigo(candidatas);
        actualizarBotonCastigo();
        return;
    }

    tbody.innerHTML = filtrados.map(c => `
        <tr data-id="${c.id}">
            <td><input type="checkbox" class="cas-check" data-id="${c.id}" ${seleccionCastigo.has(c.id) ? 'checked' : ''}></td>
            <td class="cell-strong">${escHtml(c.idFactura)}</td>
            <td>${escHtml(c.clienteNombre)}</td>
            <td class="cell-strong">${fmtMoney(c.pendiente)}</td>
            <td>${fmtDate(c.fecProxPago)}</td>
            <td><span class="badge badge-danger">${diasMoraCas(c.fecProxPago)}d</span></td>
            <td><span class="badge badge-warning">VENCIDA</span></td>
        </tr>
    `).join('');

    document.querySelectorAll('.cas-check').forEach(chk => {
        chk.addEventListener('change', () => {
            const id = parseInt(chk.dataset.id);
            if (chk.checked) seleccionCastigo.add(id); else seleccionCastigo.delete(id);
            actualizarBotonCastigo();
        });
    });

    actualizarStatsCastigo(candidatas);
    actualizarBotonCastigo();
}

function actualizarBotonCastigo() {
    const btn = document.getElementById('btn-castigar-sel');
    document.getElementById('cas-sel-count').textContent = seleccionCastigo.size;
    btn.disabled = seleccionCastigo.size === 0;
}

function confirmarCastigoMasivo() {
    if (seleccionCastigo.size === 0) return;
    document.getElementById('confirm-title').innerText = `Castigar ${seleccionCastigo.size} cuenta(s)`;
    document.getElementById('confirm-body').innerHTML = 'Las cuentas seleccionadas pasarán a estado <strong>perdida</strong> y dejarán de aparecer en la cartera activa. Esta acción no se puede deshacer fácilmente. ¿Deseas continuar?';
    document.getElementById('confirm-ok-btn').innerText = 'Sí, castigar';
    document.getElementById('modal-confirm').classList.remove('hidden');
}

function ejecutarCastigoMasivo() {
    carteraCastigoData.forEach(c => {
        if (seleccionCastigo.has(c.id)) c.estado = 'perdida';
    });
    const n = seleccionCastigo.size;
    seleccionCastigo.clear();
    document.getElementById('modal-confirm').classList.add('hidden');
    document.getElementById('cas-check-all').checked = false;
    renderizarCastigoTabla();
    mostrarToast(`${n} cuenta(s) castigada(s) correctamente`, true);
}

function setupEventListenersCastigo() {
    document.getElementById('umbral-dias').addEventListener('input', renderizarCastigoTabla);
    document.getElementById('cas-search').addEventListener('input', renderizarCastigoTabla);
    document.getElementById('cas-check-all').addEventListener('change', function () {
        document.querySelectorAll('.cas-check').forEach(chk => {
            chk.checked = this.checked;
            const id = parseInt(chk.dataset.id);
            if (this.checked) seleccionCastigo.add(id); else seleccionCastigo.delete(id);
        });
        actualizarBotonCastigo();
    });
    document.getElementById('btn-castigar-sel').addEventListener('click', confirmarCastigoMasivo);
    document.getElementById('confirm-cancel-btn').addEventListener('click', () => document.getElementById('modal-confirm').classList.add('hidden'));
    document.getElementById('confirm-ok-btn').addEventListener('click', ejecutarCastigoMasivo);
    window.addEventListener('click', (e) => { if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden'); });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarCastigoTabla();
    setupEventListenersCastigo();
});
