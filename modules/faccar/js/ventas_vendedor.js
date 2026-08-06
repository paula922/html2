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
// VENTAS POR VENDEDOR - CONTROL COMPLETO
// Tablas: tab_enc_facturas, tab_vendedores
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend
// (join de tab_enc_facturas con tab_vendedores). Inicia vacío.
// Ejemplo para pruebas en consola:
//   facturasReporte.push({idFactura:'FE000001', fecFactura:'2026-06-10', total:850000, vendedorId:'1101234567', vendedorNombre:'Carlos Ramírez', comision:5});
let facturasReporte = [];
let rvChart = null;

function filtrarPorRango() {
    const desde = document.getElementById('rv-desde').value;
    const hasta = document.getElementById('rv-hasta').value;
    return facturasReporte.filter(f => (!desde || f.fecFactura >= desde) && (!hasta || f.fecFactura <= hasta));
}

function calcularRanking(facturas) {
    const porVendedor = {};
    facturas.forEach(f => {
        if (!porVendedor[f.vendedorId]) {
            porVendedor[f.vendedorId] = { nombre: f.vendedorNombre, comision: f.comision, total: 0, facturas: 0 };
        }
        porVendedor[f.vendedorId].total += f.total;
        porVendedor[f.vendedorId].facturas += 1;
    });
    return Object.values(porVendedor).sort((a, b) => b.total - a.total);
}

function renderizarReporteVentas() {
    const facturas = filtrarPorRango();
    const ranking = calcularRanking(facturas);

    const totalVendido = facturas.reduce((s, f) => s + f.total, 0);
    const totalComisiones = ranking.reduce((s, v) => s + Math.round(v.total * v.comision / 100), 0);

    document.getElementById('stat-rv-total').innerText = fmtMoney(totalVendido);
    document.getElementById('stat-rv-facturas').innerText = facturas.length;
    document.getElementById('stat-rv-comisiones').innerText = fmtMoney(totalComisiones);
    document.getElementById('stat-rv-mejor').innerText = ranking.length ? ranking[0].nombre : '—';

    const tbody = document.getElementById('rv-tbody');
    if (ranking.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state"><i class="fas fa-user-tie"></i><p>Sin ventas registradas en el periodo</p></div></td></tr>`;
    } else {
        tbody.innerHTML = ranking.map((v, i) => `
            <tr>
                <td class="cell-strong">${i + 1}</td>
                <td>${escHtml(v.nombre)}</td>
                <td>${v.facturas}</td>
                <td class="cell-strong">${fmtMoney(v.total)}</td>
                <td>${v.comision}%</td>
                <td>${fmtMoney(Math.round(v.total * v.comision / 100))}</td>
            </tr>
        `).join('');
    }

    renderizarGraficoVentas(ranking);
}

function renderizarGraficoVentas(ranking) {
    const canvas = document.getElementById('rv-chart');
    const empty = document.getElementById('rv-chart-empty');

    if (ranking.length === 0) {
        canvas.style.display = 'none';
        empty.style.display = 'block';
        if (rvChart) { rvChart.destroy(); rvChart = null; }
        return;
    }

    canvas.style.display = 'block';
    empty.style.display = 'none';

    if (rvChart) rvChart.destroy();
    rvChart = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: ranking.map(v => v.nombre),
            datasets: [{ label: 'Total Vendido', data: ranking.map(v => v.total), backgroundColor: '#3b82f6', borderRadius: 8 }],
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { ticks: { callback: v => fmtMoney(v) } } },
        },
    });
}

function setupEventListenersVentasVendedor() {
    document.getElementById('btn-rv-aplicar').addEventListener('click', renderizarReporteVentas);
}

document.addEventListener('DOMContentLoaded', () => {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1).toISOString().slice(0, 10);
    document.getElementById('rv-desde').value = inicioMes;
    document.getElementById('rv-hasta').value = hoy.toISOString().slice(0, 10);
    renderizarReporteVentas();
    setupEventListenersVentasVendedor();
});
