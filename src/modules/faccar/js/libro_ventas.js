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
// LIBRO DE VENTAS - CONTROL COMPLETO
// Tabla: tab_enc_facturas
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend. Inicia vacío.
// Ejemplo para pruebas en consola:
//   libroVentasData.push({fecFactura:'2026-06-10', idFactura:'FE000001', clienteNombre:'Laura Gómez', baseGravable:700000, descuento:0, iva:133000, total:833000});
let libroVentasData = [];

function renderizarLibroVentas() {
    const desde = document.getElementById('lv-desde').value;
    const hasta = document.getElementById('lv-hasta').value;
    const busqueda = document.getElementById('lv-search')?.value.toLowerCase().trim() || '';

    const filtrados = libroVentasData.filter(f => {
        const enRango = (!desde || f.fecFactura >= desde) && (!hasta || f.fecFactura <= hasta);
        const matchBusqueda = f.clienteNombre.toLowerCase().includes(busqueda) || f.idFactura.toLowerCase().includes(busqueda);
        return enRango && matchBusqueda;
    }).sort((a, b) => a.fecFactura.localeCompare(b.fecFactura));

    const tbody = document.getElementById('lv-tbody');
    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7"><div class="empty-state"><i class="fas fa-journal-text"></i><p>Sin facturas en el periodo seleccionado</p></div></td></tr>`;
    } else {
        tbody.innerHTML = filtrados.map(f => `
            <tr>
                <td>${fmtDate(f.fecFactura)}</td>
                <td class="cell-strong">${escHtml(f.idFactura)}</td>
                <td>${escHtml(f.clienteNombre)}</td>
                <td>${fmtMoney(f.baseGravable)}</td>
                <td>${fmtMoney(f.descuento)}</td>
                <td>${fmtMoney(f.iva)}</td>
                <td class="cell-strong">${fmtMoney(f.total)}</td>
            </tr>
        `).join('');
    }

    document.getElementById('lv-tot-base').textContent = fmtMoney(filtrados.reduce((s, f) => s + f.baseGravable, 0));
    document.getElementById('lv-tot-desc').textContent = fmtMoney(filtrados.reduce((s, f) => s + f.descuento, 0));
    document.getElementById('lv-tot-iva').textContent = fmtMoney(filtrados.reduce((s, f) => s + f.iva, 0));
    document.getElementById('lv-tot-total').textContent = fmtMoney(filtrados.reduce((s, f) => s + f.total, 0));
}

function setupEventListenersLibroVentas() {
    document.getElementById('btn-lv-aplicar').addEventListener('click', renderizarLibroVentas);
    document.getElementById('lv-search').addEventListener('input', renderizarLibroVentas);
    document.getElementById('btn-lv-imprimir').addEventListener('click', () => window.print());
}

document.addEventListener('DOMContentLoaded', () => {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1).toISOString().slice(0, 10);
    document.getElementById('lv-desde').value = inicioMes;
    document.getElementById('lv-hasta').value = hoy.toISOString().slice(0, 10);
    renderizarLibroVentas();
    setupEventListenersLibroVentas();
});
