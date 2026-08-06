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
// CARTERA POR TIEMPO - CONTROL COMPLETO
// Tabla: tab_carteras
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend
// (join de tab_carteras con tab_enc_facturas / tab_clientes). Inicia vacío.
// Ejemplo para pruebas en consola:
//   carteraReporte.push({clienteNombre:'Laura Gómez', idFactura:'FE000001', pendiente:300000, fecProxPago:'2026-04-01'});
let carteraReporte = [];
let ctChart = null;

const RANGOS = [
    { label: '0-30 días', min: 0, max: 30, color: '#10b981' },
    { label: '31-60 días', min: 31, max: 60, color: '#f59e0b' },
    { label: '61-90 días', min: 61, max: 90, color: '#fb923c' },
    { label: '91-120 días', min: 91, max: 120, color: '#ef4444' },
    { label: '+120 días', min: 121, max: Infinity, color: '#991b1b' },
];

function diasMoraReporte(fecProxPago) {
    const hoy = new Date(); hoy.setHours(0,0,0,0);
    const f = new Date(fecProxPago + 'T00:00:00');
    const dias = Math.round((hoy - f) / 86400000);
    return Math.max(dias, 0);
}

function rangoDe(dias) {
    return RANGOS.find(r => dias >= r.min && dias <= r.max) || RANGOS[0];
}

function renderizarReporteCartera() {
    const datos = carteraReporte.map(c => ({ ...c, dias: diasMoraReporte(c.fecProxPago), rango: rangoDe(diasMoraReporte(c.fecProxPago)) }));
    const total = datos.reduce((s, c) => s + c.pendiente, 0);
    const aldia = datos.filter(c => c.dias <= 30).reduce((s, c) => s + c.pendiente, 0);
    const critica = datos.filter(c => c.dias > 90).reduce((s, c) => s + c.pendiente, 0);

    const porCliente = {};
    datos.forEach(c => { porCliente[c.clienteNombre] = (porCliente[c.clienteNombre] || 0) + c.pendiente; });
    const mayorDeuda = Object.entries(porCliente).sort((a, b) => b[1] - a[1])[0];

    document.getElementById('stat-ct-total').innerText = fmtMoney(total);
    document.getElementById('stat-ct-aldiat').innerText = fmtMoney(aldia);
    document.getElementById('stat-ct-critica').innerText = fmtMoney(critica);
    document.getElementById('stat-ct-mayor').innerText = mayorDeuda ? `${mayorDeuda[0]} (${fmtMoney(mayorDeuda[1])})` : '—';

    const tbody = document.getElementById('ct-tbody');
    if (datos.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5"><div class="empty-state"><i class="fas fa-wallet"></i><p>Sin cartera pendiente registrada</p></div></td></tr>`;
    } else {
        tbody.innerHTML = datos.sort((a, b) => b.dias - a.dias).map(c => `
            <tr>
                <td class="cell-strong">${escHtml(c.clienteNombre)}</td>
                <td>${escHtml(c.idFactura)}</td>
                <td class="cell-strong">${fmtMoney(c.pendiente)}</td>
                <td>${c.dias}d</td>
                <td><span class="badge" style="background:${c.rango.color}22; color:${c.rango.color};">${c.rango.label}</span></td>
            </tr>
        `).join('');
    }

    renderizarGraficoCartera(datos);
}

function renderizarGraficoCartera(datos) {
    const canvas = document.getElementById('ct-chart');
    const empty = document.getElementById('ct-chart-empty');

    if (datos.length === 0) {
        canvas.style.display = 'none';
        empty.style.display = 'block';
        if (ctChart) { ctChart.destroy(); ctChart = null; }
        return;
    }

    canvas.style.display = 'block';
    empty.style.display = 'none';

    const valores = RANGOS.map(r => datos.filter(c => c.rango.label === r.label).reduce((s, c) => s + c.pendiente, 0));

    if (ctChart) ctChart.destroy();
    ctChart = new Chart(canvas, {
        type: 'doughnut',
        data: {
            labels: RANGOS.map(r => r.label),
            datasets: [{ data: valores, backgroundColor: RANGOS.map(r => r.color) }],
        },
        options: { responsive: true, plugins: { legend: { position: 'right' } } },
    });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarReporteCartera();
});
