'use strict';

// ============================================================
// UTILIDADES COMUNES
// ============================================================
function val(id)           { return document.getElementById(id)?.value ?? ''; }
function setVal(id, value) { const el = document.getElementById(id); if (el) el.value = value ?? ''; }
function setText(id, text) { const el = document.getElementById(id); if (el) el.textContent = text ?? ''; }
function show(id)          { document.getElementById(id)?.classList.remove('hidden'); }
function hide(id)          { document.getElementById(id)?.classList.add('hidden'); }
function setSelectVal(id, value) {
    const el = document.getElementById(id);
    if (el) el.value = value ?? '';
}

function showFieldError(spanId, mensaje, autoHideMs = 4000) {
    const el = document.getElementById(spanId);
    if (!el) return;
    el.textContent = mensaje;
    el.classList.add('visible');
    clearTimeout(el._hideTimer);
    el._hideTimer = setTimeout(() => {
        el.classList.remove('visible');
        setTimeout(() => { el.textContent = ''; }, 300);
    }, autoHideMs);
}

function clearFieldError(spanId) {
    const el = document.getElementById(spanId);
    if (!el) return;
    clearTimeout(el._hideTimer);
    el.classList.remove('visible');
    el.textContent = '';
}

function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    const span  = document.getElementById('toast-message');
    if (!toast || !span) return;
    const text = message && message.trim() ? message : (type === 'success' ? 'Operación exitosa' : 'Ocurrió un error');
    span.textContent = text;
    toast.style.background = type === 'error' ? '#ef4444' : '#0f172a';
    toast.classList.remove('hidden');
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => toast.classList.add('hidden'), 3500);
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
}

function sanitizeText(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/[\x00]/g, '')
        .replace(/'/g, '')
        .replace(/"/g, '')
        .replace(/;/g, '')
        .replace(/--/g, '')
        .replace(/\/\*/g, '')
        .replace(/\*\//g, '')
        .replace(/xp_/gi, '')
        .replace(/DROP\s/gi, '')
        .replace(/DELETE\s/gi, '')
        .replace(/INSERT\s/gi, '')
        .replace(/UPDATE\s/gi, '')
        .replace(/EXEC\s/gi, '')
        .replace(/UNION\s/gi, '')
        .replace(/SELECT\s/gi, '')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .trim();
}

// ============================================================
// ESTADO GLOBAL
// ============================================================
let editingId = null;
let pendingDeleteId = null;
let currentFilter = 'all';

// ============================================================
// ACTUALIZAR ESTADÍSTICAS
// ============================================================
function updateStats(data) {
    const total   = data.length;
    const nc      = data.filter(m => m.ind_tipo_nota === 'f' || m.ind_tipo_nota === false).length;
    const nd      = total - nc;
    const activos = data.filter(m => m.ind_estado === 't' || m.ind_estado === true).length;
    setText('stat-total', total);
    setText('stat-nc', nc);
    setText('stat-nd', nd);
    setText('stat-activos', activos);
}

// ============================================================
// RENDERIZAR TABLA
// ============================================================
function renderizarTabla(data) {
    const tbody = document.getElementById('motivo-tbody');
    const query = sanitizeText(document.getElementById('motivo-search')?.value ?? '').toLowerCase();
    const filter = currentFilter;

    let filtrados = data.filter(m => {
        const matchTexto = m.nom_motivo.toLowerCase().includes(query) ||
                           String(m.cod_dian).includes(query);
        let matchTipo = true;
        if (filter === 'nc') matchTipo = (m.ind_tipo_nota === 'f' || m.ind_tipo_nota === false);
        else if (filter === 'nd') matchTipo = (m.ind_tipo_nota === 't' || m.ind_tipo_nota === true);
        else if (filter === 'active') matchTipo = (m.ind_estado === 't' || m.ind_estado === true);
        else if (filter === 'inactive') matchTipo = (m.ind_estado === 'f' || m.ind_estado === false);
        return matchTexto && matchTipo;
    });

    setText('motivos-count', `${filtrados.length} resultado${filtrados.length !== 1 ? 's' : ''}`);
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = (query || filter !== 'all') ? 'flex' : 'none';

    if (filtrados.length === 0) {
        tbody.innerHTML = `<tr class="empty-row"><td colspan="6"><div class="empty-state"><i class="fas fa-file-circle-question"></i><p>Sin resultados</p><span>Prueba otros filtros o agrega un motivo</span></div></td></tr>`;
        updateStats(data);
        return;
    }

    tbody.innerHTML = filtrados.map(m => {
        const es_activo = (m.ind_estado === 't' || m.ind_estado === true);
        const tipo_label = (m.ind_tipo_nota === 't' || m.ind_tipo_nota === true) ? 'ND' : 'NC';
        const badgeClass = tipo_label === 'ND' ? 'badge-purple' : 'badge-info';
        const estadoBadge = es_activo
            ? '<span class="badge badge-active">Activo</span>'
            : '<span class="badge badge-inactive">Inactivo</span>';
        const afecta = [];
        if (m.afecta_inventario === 't' || m.afecta_inventario === true) afecta.push('Inventario');
        if (m.afecta_cliente    === 't' || m.afecta_cliente    === true) afecta.push('Cliente');
        if (m.afecta_cartera    === 't' || m.afecta_cartera    === true) afecta.push('Cartera');
        if (m.afecta_comision   === 't' || m.afecta_comision   === true) afecta.push('Comisión');
        const afectaStr = afecta.length ? afecta.join(', ') : '—';

        return `
        <tr data-id="${m.id_motivo_nota}">
            <td><strong>${escapeHtml(String(m.cod_dian))}</strong></td>
            <td>${escapeHtml(m.nom_motivo)}</td>
            <td><span class="badge ${badgeClass}">${tipo_label}</span></td>
            <td>${escapeHtml(afectaStr)}</td>
            <td>${estadoBadge}</td>
            <td>
                <div class="row-actions">
                    <button class="btn-icon-sm edit" data-id="${m.id_motivo_nota}"><i class="fas fa-edit"></i></button>
                    <button class="btn-icon-sm toggle" data-id="${m.id_motivo_nota}">
                        <i class="fas ${es_activo ? 'fa-toggle-on' : 'fa-toggle-off'}"></i>
                    </button>
                    <button class="btn-icon-sm reject" data-id="${m.id_motivo_nota}"><i class="fas fa-trash"></i></button>
                </div>
            </td>
        </tr>`;
    }).join('');

    // Asignar eventos a los botones de la tabla
    tbody.querySelectorAll('.btn-icon-sm.edit').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const id = parseInt(btn.dataset.id);
            abrirEditarMotivo(id);
        });
    });
    tbody.querySelectorAll('.btn-icon-sm.toggle').forEach(btn => {
        btn.addEventListener('click', async (e) => {
            e.stopPropagation();
            const id = parseInt(btn.dataset.id);
            await toggleEstadoMotivo(id);
        });
    });
    tbody.querySelectorAll('.btn-icon-sm.reject').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const id = parseInt(btn.dataset.id);
            const nombre = btn.closest('tr').querySelector('td:nth-child(2)').textContent.trim();
            confirmarEliminarMotivo(id, nombre);
        });
    });

    updateStats(data);
}

// ============================================================
// ABRIR MODAL NUEVO
// ============================================================
function abrirNuevoMotivo() {
    editingId = null;
    document.getElementById('motivo-form').reset();
    document.querySelectorAll('#modal-motivo .field-error').forEach(el => clearFieldError(el.id));
    setSelectVal('motivo-tipo', 'false');
    document.getElementById('motivo-afecta-cliente').checked = true;
    document.getElementById('motivo-afecta-cartera').checked = true;
    document.getElementById('motivo-afecta-inventario').checked = false;
    document.getElementById('motivo-afecta-comision').checked = false;
    setToggleEstado(true);
    document.getElementById('motivo-modal-title').textContent = 'Nuevo Motivo';
    document.getElementById('motivo-modal-subtitle').textContent = 'Complete la información del motivo DIAN';
    document.getElementById('hid-btn-nuevo').value = '1';
    document.getElementById('hid-btn-editar').value = '';
    document.getElementById('hid-id-motivo').value = '';
    show('modal-motivo');
    document.getElementById('motivo-cod-dian').focus();
}

// ============================================================
// ABRIR MODAL EDITAR
// ============================================================
function abrirEditarMotivo(id) {
    const m = motivosData.find(item => item.id_motivo_nota === id);
    if (!m) {
        showToast('No se encontraron datos del motivo', 'error');
        return;
    }
    editingId = id;
    document.querySelectorAll('#modal-motivo .field-error').forEach(el => clearFieldError(el.id));
    setVal('motivo-cod-dian', m.cod_dian);
    setSelectVal('motivo-tipo', m.ind_tipo_nota === 't' || m.ind_tipo_nota === true ? 'true' : 'false');
    setVal('motivo-nombre', m.nom_motivo);
    document.getElementById('motivo-afecta-inventario').checked = (m.afecta_inventario === 't' || m.afecta_inventario === true);
    document.getElementById('motivo-afecta-cliente').checked    = (m.afecta_cliente === 't' || m.afecta_cliente === true);
    document.getElementById('motivo-afecta-cartera').checked    = (m.afecta_cartera === 't' || m.afecta_cartera === true);
    document.getElementById('motivo-afecta-comision').checked   = (m.afecta_comision === 't' || m.afecta_comision === true);
    setToggleEstado(m.ind_estado === 't' || m.ind_estado === true);
    document.getElementById('motivo-modal-title').textContent = 'Editar Motivo';
    document.getElementById('motivo-modal-subtitle').textContent = 'Modifique la información del motivo';
    document.getElementById('hid-btn-nuevo').value = '';
    document.getElementById('hid-btn-editar').value = '1';
    document.getElementById('hid-id-motivo').value = id;
    show('modal-motivo');
    document.getElementById('motivo-cod-dian').focus();
}

// ============================================================
// TOGGLE DE ESTADO (switch visual)
// ============================================================
function setToggleEstado(active) {
    const sw = document.getElementById('motivo-toggle-switch');
    const st = document.getElementById('motivo-toggle-status');
    if (active) {
        sw.classList.add('on');
        st.textContent = 'ACTIVO';
        st.className = 'toggle-status active';
    } else {
        sw.classList.remove('on');
        st.textContent = 'INACTIVO';
        st.className = 'toggle-status inactive';
    }
}

// ============================================================
// CERRAR MODALES
// ============================================================
function cerrarModalMotivo() {
    hide('modal-motivo');
}

function cerrarModalConfirm() {
    hide('modal-confirm');
    pendingDeleteId = null;
}

// ============================================================
// GUARDAR MOTIVO (Nuevo o Editar) vía fetch
// ============================================================
async function guardarMotivo(e) {
    e.preventDefault();
    const form = document.getElementById('motivo-form');
    const formData = new FormData(form);
    const btn = document.getElementById('btn-guardar-motivo');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';

    try {
        const response = await fetch(window.location.href, {
            method: 'POST',
            body: formData
        });
        const text = await response.text();
        console.log('Respuesta guardar:', text);
        let result;
        try {
            result = JSON.parse(text);
        } catch (e) {
            showToast('Respuesta inválida del servidor', 'error');
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> Guardar Motivo';
            return;
        }
        if (result.success) {
            showToast(result.message, 'success');
            cerrarModalMotivo();
            // Recargar la página para actualizar datos
            location.reload();
        } else {
            if (result.errors) {
                for (const [fieldId, msg] of Object.entries(result.errors)) {
                    showFieldError(fieldId, msg);
                }
            } else {
                showToast(result.message || 'Error al guardar', 'error');
            }
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> Guardar Motivo';
        }
    } catch (error) {
        console.error('Error fetch:', error);
        showToast('Error de conexión o servidor', 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save"></i> Guardar Motivo';
    }
}

// ============================================================
// ELIMINAR MOTIVO (borrado lógico)
// ============================================================
function confirmarEliminarMotivo(id, nombre) {
    pendingDeleteId = id;
    document.getElementById('confirm-title').textContent = `Eliminar "${escapeHtml(nombre)}"`;
    document.getElementById('confirm-body').textContent = 'Esta acción es irreversible. ¿Deseas continuar?';
    show('modal-confirm');
}

async function eliminarMotivoConfirmado() {
    if (!pendingDeleteId) return;
    const id = pendingDeleteId;
    const formData = new FormData();
    formData.append('btn_eliminar', '1');
    formData.append('hid_del_id', id);

    try {
        const response = await fetch(window.location.href, {
            method: 'POST',
            body: formData
        });
        const result = await response.json();
        if (result.success) {
            showToast(result.message, 'success');
            cerrarModalConfirm();
            location.reload();
        } else {
            showToast(result.message || 'Error al eliminar', 'error');
            cerrarModalConfirm();
        }
    } catch (error) {
        showToast('Error de conexión', 'error');
        cerrarModalConfirm();
    }
}

// ============================================================
// TOGGLE ESTADO (activar/inactivar)
// ============================================================
async function toggleEstadoMotivo(id) {
    const formData = new FormData();
    formData.append('btn_toggle', '1');
    formData.append('hid_toggle_id', id);
    try {
        const response = await fetch(window.location.href, {
            method: 'POST',
            body: formData
        });
        const result = await response.json();
        if (result.success) {
            showToast(result.message, 'success');
            location.reload();
        } else {
            showToast(result.message || 'Error al cambiar estado', 'error');
        }
    } catch (error) {
        showToast('Error de conexión', 'error');
    }
}

// ============================================================
// FILTROS
// ============================================================
function aplicarFiltros() {
    const query = sanitizeText(document.getElementById('motivo-search')?.value ?? '').toLowerCase();
    const btnClear = document.getElementById('btn-clear-filters');
    const hasFilter = query || currentFilter !== 'all';
    if (btnClear) btnClear.style.display = hasFilter ? 'flex' : 'none';
    renderizarTabla(motivosData);
}

function limpiarFiltros() {
    document.getElementById('motivo-search').value = '';
    currentFilter = 'all';
    document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
    document.querySelector('.filter-toggle[data-filter="all"]')?.classList.add('active');
    aplicarFiltros();
}

// ============================================================
// INICIALIZACIÓN
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    // Eventos de la tabla (delegación)
    document.getElementById('motivo-tbody').addEventListener('click', function(e) {
        const target = e.target.closest('button');
        if (!target) return;
        // Los eventos ya están asignados directamente en renderizarTabla,
        // pero por si acaso delegamos también
    });

    // Botón Nuevo
    document.getElementById('btn-add-motivo').addEventListener('click', abrirNuevoMotivo);

    // Cerrar modales
    document.querySelectorAll('.btn-close-modal, .btn-cancel-modal').forEach(btn => {
        btn.addEventListener('click', cerrarModalMotivo);
    });
    document.getElementById('confirm-cancel-btn').addEventListener('click', cerrarModalConfirm);
    document.getElementById('confirm-ok-btn').addEventListener('click', eliminarMotivoConfirmado);

    // Submit del formulario
    document.getElementById('motivo-form').addEventListener('submit', guardarMotivo);

    // Toggle de estado (switch visual)
    document.getElementById('motivo-toggle-switch').addEventListener('click', function() {
        const isOn = this.classList.contains('on');
        setToggleEstado(!isOn);
    });

    // Filtros
    document.getElementById('motivo-search').addEventListener('input', aplicarFiltros);
    document.querySelectorAll('.filter-toggle').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.dataset.filter;
            aplicarFiltros();
        });
    });
    document.getElementById('btn-clear-filters').addEventListener('click', limpiarFiltros);

    // Cerrar modales haciendo clic fuera
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                if (this.id === 'modal-motivo') cerrarModalMotivo();
                else if (this.id === 'modal-confirm') cerrarModalConfirm();
            }
        });
    });

    // Renderizar tabla inicial
    renderizarTabla(motivosData);
});