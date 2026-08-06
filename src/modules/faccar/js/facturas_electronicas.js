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
// FACTURAS ELECTRÓNICAS - CONTROL COMPLETO
// Tabla: tab_fac_electronicas
// ============================================

// En producción este arreglo se carga vía AJAX desde el backend,
// alimentado automáticamente cuando una factura se transmite a la DIAN.
let facElectronicasData = [];
let feEstadoFilter = 'all';

function actualizarStatsFe() {
    const total = facElectronicasData.length;
    const aceptadas = facElectronicasData.filter(f => f.estadoDian === 'aceptado').length;
    const pendientes = facElectronicasData.filter(f => f.estadoDian === 'pendiente' || f.estadoDian === 'enviado').length;
    const rechazadas = facElectronicasData.filter(f => f.estadoDian === 'rechazado').length;
    document.getElementById('stat-fe-total').innerText = total;
    document.getElementById('stat-fe-aceptadas').innerText = aceptadas;
    document.getElementById('stat-fe-pendientes').innerText = pendientes;
    document.getElementById('stat-fe-rechazadas').innerText = rechazadas;
}

function badgeEstadoDian(estado) {
    const map = {
        pendiente: '<span class="badge badge-warning">PENDIENTE</span>',
        enviado: '<span class="badge badge-info">ENVIADO</span>',
        aceptado: '<span class="badge badge-success">ACEPTADO</span>',
        rechazado: '<span class="badge badge-danger">RECHAZADO</span>',
    };
    return map[estado] || estado;
}

function renderizarFeTabla() {
    const tbody = document.getElementById('fe-tbody');
    const busqueda = document.getElementById('fe-search')?.value.toLowerCase().trim() || '';

    let filtrados = facElectronicasData.filter(f => {
        const matchBusqueda = f.idFactura.toLowerCase().includes(busqueda) || f.cufe.toLowerCase().includes(busqueda);
        const matchEstado = feEstadoFilter === 'all' || f.estadoDian === feEstadoFilter;
        return matchBusqueda && matchEstado;
    });

    document.getElementById('fe-count').innerText = `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`;
    const hayFiltros = busqueda !== '' || feEstadoFilter !== 'all';
    document.getElementById('btn-clear-fe-filters').style.display = hayFiltros ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state"><i class="fas fa-qrcode"></i><p>Sin facturas electrónicas registradas</p><span>Aparecerán aquí al transmitir una factura a la DIAN</span></div></td></tr>`;
        actualizarStatsFe();
        return;
    }

    tbody.innerHTML = filtrados.map(f => `
        <tr data-id="${f.idFactura}">
            <td class="cell-strong">${f.idFactura}</td>
            <td class="cell-muted" style="font-family:monospace;">${f.cufe.slice(0, 24)}…</td>
            <td>${badgeEstadoDian(f.estadoDian)}</td>
            <td>${fmtDate(f.fecEnvio)}</td>
            <td class="cell-muted">${escHtml(f.mensajeDian)}</td>
            <td>
                <div class="row-actions">
                    <div class="prod-act-btn view" data-id="${f.idFactura}" title="Ver CUFE / QR / XML"><i class="fas fa-eye"></i></div>
                    ${f.estadoDian === 'rechazado' ? `<div class="prod-act-btn edit" data-id="${f.idFactura}" title="Reenviar a la DIAN"><i class="fas fa-rotate-right"></i></div>` : ''}
                </div>
            </td>
        </tr>
    `).join('');

    document.querySelectorAll('#fe-tbody .prod-act-btn.view').forEach(btn => btn.addEventListener('click', () => verDetalleFe(btn.dataset.id)));
    document.querySelectorAll('#fe-tbody .prod-act-btn.edit').forEach(btn => btn.addEventListener('click', () => reenviarDian(btn.dataset.id)));

    actualizarStatsFe();
}

function verDetalleFe(idFactura) {
    const f = facElectronicasData.find(x => x.idFactura === idFactura);
    if (!f) return;
    document.getElementById('ver-fe-id').textContent = f.idFactura;
    document.getElementById('ver-fe-cufe').textContent = f.cufe;
    document.getElementById('ver-fe-estado').innerHTML = badgeEstadoDian(f.estadoDian);
    document.getElementById('ver-fe-fecha').textContent = fmtDate(f.fecEnvio);
    document.getElementById('ver-fe-mensaje').textContent = f.mensajeDian;
    document.getElementById('ver-fe-xml').value = f.xmlFirmado || '<?xml version="1.0"?> ... (XML firmado no disponible en este prototipo)';

    const qrContainer = document.getElementById('fe-qr-container');
    qrContainer.innerHTML = '';
    if (window.QRCode) {
        new QRCode(qrContainer, { text: f.qrCode || f.cufe, width: 150, height: 150 });
    } else {
        qrContainer.innerHTML = '<i class="fas fa-qrcode" style="font-size:48px;color:var(--dash-text-muted);"></i>';
    }

    document.getElementById('modal-ver-fe').classList.remove('hidden');
}

function reenviarDian(idFactura) {
    const idx = facElectronicasData.findIndex(f => f.idFactura === idFactura);
    if (idx === -1) return;
    facElectronicasData[idx].estadoDian = 'enviado';
    facElectronicasData[idx].mensajeDian = 'Reenviado, en espera de validación de la DIAN';
    facElectronicasData[idx].fecEnvio = new Date().toISOString().slice(0, 10);
    renderizarFeTabla();
    mostrarToast(`Factura ${idFactura} reenviada a la DIAN`);
}

function limpiarFiltrosFe() {
    document.getElementById('fe-search').value = '';
    document.getElementById('fe-estado-filter').value = 'all';
    feEstadoFilter = 'all';
    renderizarFeTabla();
}

function setupEventListenersFe() {
    document.getElementById('fe-search').addEventListener('input', renderizarFeTabla);
    document.getElementById('fe-estado-filter').addEventListener('change', (e) => { feEstadoFilter = e.target.value; renderizarFeTabla(); });
    document.getElementById('btn-clear-fe-filters').addEventListener('click', limpiarFiltrosFe);
    document.querySelectorAll('.btn-close-ver-fe').forEach(b => b.addEventListener('click', () => document.getElementById('modal-ver-fe').classList.add('hidden')));
    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal-overlay')) e.target.classList.add('hidden');
    });
}

document.addEventListener('DOMContentLoaded', () => {
    renderizarFeTabla();
    setupEventListenersFe();
});
