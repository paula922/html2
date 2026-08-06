'use strict';

// ============================================================
// UTILIDADES
// ============================================================
function val(id)           { return document.getElementById(id)?.value ?? ''; }
function setVal(id, value) { const el = document.getElementById(id); if (el) el.value = value ?? ''; }
function setText(id, text) { const el = document.getElementById(id); if (el) el.textContent = text ?? ''; }
function show(id)          { document.getElementById(id)?.classList.remove('hidden'); }
function hide(id)          { document.getElementById(id)?.classList.add('hidden'); }

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

function fmtDate(d) {
    if (!d) return '—';
    const partes = d.split('-');
    return `${partes[2]}/${partes[1]}/${partes[0]}`;
}

function diasHasta(fecha) {
    const hoy = new Date();
    hoy.setHours(0,0,0,0);
    const f = new Date(fecha + 'T00:00:00');
    return Math.round((f - hoy) / 86400000);
}

function estadoResolucion(fecVenc) {
    const dias = diasHasta(fecVenc);
    if (dias < 0) return 'Vencida';
    if (dias <= 30) return 'Por Vencer';
    return 'Vigente';
}

// ============================================================
// TOAST
// ============================================================
function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    const span  = document.getElementById('toast-message');
    if (!toast || !span) return;
    const text = message && message.trim() ? message : (type === 'success' ? 'Operación exitosa' : 'Ocurrió un error');
    span.textContent = text;
    toast.className = `toast-message ${type}`;
    toast.classList.remove('hidden');
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => toast.classList.add('hidden'), 3500);
}

// ============================================================
// VALIDACIONES EN TIEMPO REAL
// ============================================================
function showFeedback(element, message, isValid) {
    if (!element) return;
    element.textContent = message;
    element.style.display = message ? 'block' : 'none';
    element.style.color = isValid ? '#22c55e' : '#ef4444';
}

function validarIdEmpresa() {
    const input = document.getElementById('param-id-empresa');
    const feedback = document.getElementById('err-id-empresa');
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = 'El ID de empresa es obligatorio';
        isValid = false;
    } else if (valor.length > 10) {
        message = '⚠️ Máximo 10 caracteres';
        isValid = false;
    } else {
        message = '✓ ID válido';
        isValid = true;
    }

    showFeedback(feedback, message, isValid);
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');
    return isValid;
}

function validarResolucion() {
    const input = document.getElementById('param-res-aut');
    const feedback = document.getElementById('err-res-aut');
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = 'El número de resolución es obligatorio';
        isValid = false;
    } else if (!/^\d{13}$/.test(valor)) {
        message = '⚠️ Debe tener exactamente 13 dígitos';
        isValid = false;
    } else {
        message = '✓ Resolución válida';
        isValid = true;
    }

    showFeedback(feedback, message, isValid);
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');
    return isValid;
}

function validarFecha(id, feedbackId, label) {
    const input = document.getElementById(id);
    const feedback = document.getElementById(feedbackId);
    if (!input || !feedback) return false;

    const valor = input.value;
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = `La ${label} es obligatoria`;
        isValid = false;
    } else {
        message = `✓ ${label} válida`;
        isValid = true;
    }

    showFeedback(feedback, message, isValid);
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');
    return isValid;
}

function validarPrefijo(id, feedbackId, label) {
    const input = document.getElementById(id);
    const feedback = document.getElementById(feedbackId);
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = `El prefijo de ${label} es obligatorio`;
        isValid = false;
    } else if (valor.length > 4) {
        message = '⚠️ Máximo 4 caracteres';
        isValid = false;
    } else {
        message = '✓ Prefijo válido';
        isValid = true;
    }

    showFeedback(feedback, message, isValid);
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');
    return isValid;
}

function validarNumero(id, feedbackId, label, min = 1, max = Infinity) {
    const input = document.getElementById(id);
    const feedback = document.getElementById(feedbackId);
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = `El ${label} es obligatorio`;
        isValid = false;
    } else {
        const num = parseFloat(valor);
        if (isNaN(num) || num < min) {
            message = `⚠️ Debe ser mayor o igual a ${min}`;
            isValid = false;
        } else if (num > max) {
            message = `⚠️ Debe ser menor o igual a ${max}`;
            isValid = false;
        } else {
            message = `✓ ${label} válido`;
            isValid = true;
        }
    }

    showFeedback(feedback, message, isValid);
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');
    return isValid;
}

function validarRangoNumerico(idIni, idFin, feedbackIdIni, feedbackIdFin, label) {
    const ini = document.getElementById(idIni);
    const fin = document.getElementById(idFin);
    const fbIni = document.getElementById(feedbackIdIni);
    const fbFin = document.getElementById(feedbackIdFin);
    if (!ini || !fin || !fbIni || !fbFin) return false;

    const valIni = parseFloat(ini.value.trim());
    const valFin = parseFloat(fin.value.trim());

    let isValid = true;
    if (!isNaN(valIni) && !isNaN(valFin) && valFin <= valIni) {
        fbFin.textContent = `⚠️ El ${label} final debe ser mayor al inicial`;
        fbFin.style.display = 'block';
        fbFin.style.color = '#ef4444';
        fin.style.borderColor = '#ef4444';
        isValid = false;
    } else {
        fbFin.textContent = '';
        fbFin.style.display = 'none';
        fin.style.borderColor = '#e2e8f0';
        if (valFin > valIni) {
            fin.style.borderColor = '#22c55e';
        }
    }
    return isValid;
}

function limpiarValidaciones() {
    const feedbacks = document.querySelectorAll('.validation-feedback');
    feedbacks.forEach(el => {
        el.style.display = 'none';
        el.textContent = '';
    });
    const inputs = document.querySelectorAll('.form-control-sm');
    inputs.forEach(inp => inp.style.borderColor = '#e2e8f0');
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
    const total = data.length;
    let vigentes = 0, porVencer = 0, vencidas = 0;
    data.forEach(p => {
        const est = estadoResolucion(p.fec_venc);
        if (est === 'Vigente') vigentes++;
        else if (est === 'Por Vencer') porVencer++;
        else vencidas++;
    });
    setText('stat-total', total);
    setText('stat-vigentes', vigentes);
    setText('stat-porvencer', porVencer);
    setText('stat-vencidas', vencidas);
}

// ============================================================
// FILTRADO
// ============================================================
function aplicarFiltros() {
    const query = sanitizeText(document.getElementById('param-search')?.value ?? '').toLowerCase();
    const filter = document.getElementById('filter-estado')?.value || 'all';
    const filas = document.querySelectorAll('#param-tbody tr:not(.empty-row)');
    let visible = 0;
    filas.forEach(fila => {
        const id = fila.dataset.id?.toLowerCase() ?? '';
        const texto = fila.textContent.toLowerCase();
        const estado = fila.dataset.estado || '';
        const pasaTexto = !query || id.includes(query) || texto.includes(query);
        const pasaEstado = filter === 'all' || estado === filter;
        const mostrar = pasaTexto && pasaEstado;
        fila.style.display = mostrar ? '' : 'none';
        if (mostrar) visible++;
    });

    setText('param-count', `${visible} resultado${visible !== 1 ? 's' : ''}`);
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = (query || filter !== 'all') ? 'flex' : 'none';

    const noResultRow = document.querySelector('#param-tbody tr.no-results');
    if (noResultRow) noResultRow.remove();
    if (visible === 0 && filas.length > 0) {
        const tbody = document.getElementById('param-tbody');
        const tr = document.createElement('tr');
        tr.className = 'no-results';
        tr.innerHTML = '<td colspan="7" class="text-center py-4"><i class="fas fa-search" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;"></i>No se encontraron resoluciones con esos filtros</td>';
        tbody.appendChild(tr);
    }

    updateStats(parametrosData);
}

function limpiarFiltros() {
    document.getElementById('param-search').value = '';
    document.getElementById('filter-estado').value = 'all';
    aplicarFiltros();
}

// ============================================================
// MODALES
// ============================================================
function abrirNuevoParam() {
    editingId = null;
    document.getElementById('param-form').reset();
    limpiarValidaciones();
    document.getElementById('modal_titulo').innerHTML = '<i class="fas fa-plus-circle"></i> Nueva Resolución';
    document.getElementById('hid-btn-nuevo').value = '1';
    document.getElementById('hid-btn-editar').value = '';
    document.getElementById('hid-id-empresa').value = '';
    document.getElementById('param-id-empresa').disabled = false;
    document.getElementById('param-facactual').disabled = false;
    document.getElementById('param-cotactual').disabled = false;
    mostrarOverlay('modalOverlay');
    document.getElementById('param-id-empresa').focus();
}

function abrirEditarParam(id) {
    const p = parametrosData.find(item => item.id_empresa === id);
    if (!p) {
        showToast('No se encontraron datos de la resolución', 'error');
        return;
    }
    editingId = id;
    limpiarValidaciones();

    setVal('hid-id-empresa', id);
    setVal('param-id-empresa', id);
    document.getElementById('param-id-empresa').disabled = true;
    setVal('param-res-aut', p.val_res_aut);
    setVal('param-fec-res', p.fec_res_aut);
    setVal('param-fec-venc', p.fec_venc);
    setVal('param-prefijofac', p.val_prefijofac);
    setVal('param-facini', p.val_facini);
    setVal('param-facfin', p.val_facfin);
    setVal('param-facactual', p.val_facactual);
    setVal('param-prefijocot', p.val_prefijocot);
    setVal('param-cotini', p.val_cotini);
    setVal('param-cotactual', p.val_cotactual);
    setVal('param-reteica', p.val_porreteica);
    setVal('param-intcorriente', p.val_intcorriente);
    setVal('param-interesmora', p.val_interesmora);
    setVal('param-diascartera', p.val_diascartera);
    setVal('param-pesospuntos', p.val_pesosXpuntos);

    document.getElementById('modal_titulo').innerHTML = '<i class="fas fa-edit"></i> Editar Resolución';
    document.getElementById('hid-btn-nuevo').value = '';
    document.getElementById('hid-btn-editar').value = '1';
    mostrarOverlay('modalOverlay');
    document.getElementById('param-res-aut').focus();
}

function mostrarOverlay(id) {
    const overlay = document.getElementById(id);
    overlay.classList.add('show');
    document.body.style.overflow = 'hidden';
    const modalCard = overlay.querySelector('.modal-card');
    if (modalCard) modalCard.style.animation = 'modalSlideIn 0.3s ease forwards';
}

function cerrarModal() {
    const overlay = document.getElementById('modalOverlay');
    const modalCard = overlay.querySelector('.modal-card');
    if (modalCard) modalCard.style.animation = 'modalSlideOut 0.2s ease forwards';
    setTimeout(() => {
        overlay.classList.remove('show');
        document.body.style.overflow = '';
        if (modalCard) modalCard.style.animation = '';
        limpiarValidaciones();
    }, 200);
}

function cerrarModalSiOverlay(event) {
    if (event.target === document.getElementById('modalOverlay')) {
        cerrarModal();
    }
}

function limpiarFormulario() {
    document.getElementById('param-form').reset();
    limpiarValidaciones();
    showToast('Formulario limpiado', 'info');
}

// ============================================================
// CONFIRMACIÓN DE ELIMINACIÓN
// ============================================================
function confirmarEliminarParam(id, empresa) {
    pendingDeleteId = id;
    document.getElementById('confirm-body').textContent = `¿Estás seguro de eliminar la resolución de "${empresa}"?`;
    const overlay = document.getElementById('modalConfirm');
    overlay.classList.add('show');
    document.body.style.overflow = 'hidden';
    const modalCard = overlay.querySelector('.modal-card');
    if (modalCard) modalCard.style.animation = 'modalSlideIn 0.3s ease forwards';
}

function cerrarConfirm() {
    const overlay = document.getElementById('modalConfirm');
    const modalCard = overlay.querySelector('.modal-card');
    if (modalCard) modalCard.style.animation = 'modalSlideOut 0.2s ease forwards';
    setTimeout(() => {
        overlay.classList.remove('show');
        document.body.style.overflow = '';
        if (modalCard) modalCard.style.animation = '';
        pendingDeleteId = null;
    }, 200);
}

function cerrarConfirmSiOverlay(event) {
    if (event.target === document.getElementById('modalConfirm')) {
        cerrarConfirm();
    }
}

async function eliminarConfirmado() {
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
            cerrarConfirm();
            location.reload();
        } else {
            showToast(result.message || 'Error al eliminar', 'error');
            cerrarConfirm();
        }
    } catch (error) {
        showToast('Error de conexión', 'error');
        cerrarConfirm();
    }
}

// ============================================================
// GUARDAR (Nuevo / Editar)
// ============================================================
async function guardarParam(e) {
    e.preventDefault();

    const isEdit = document.getElementById('hid-btn-editar').value === '1';

    const idOk = validarIdEmpresa();
    const resOk = validarResolucion();
    const fecResOk = validarFecha('param-fec-res', 'err-fec-res', 'fecha de resolución');
    const fecVencOk = validarFecha('param-fec-venc', 'err-fec-venc', 'fecha de vencimiento');
    const prefijoFacOk = validarPrefijo('param-prefijofac', 'err-prefijofac', 'factura');
    const facIniOk = validarNumero('param-facini', 'err-facini', 'número inicial', 1);
    const facFinOk = validarNumero('param-facfin', 'err-facfin', 'número final', 1);
    const prefijoCotOk = validarPrefijo('param-prefijocot', 'err-prefijocot', 'cotización');
    const cotIniOk = validarNumero('param-cotini', 'err-cotini', 'número inicial', 1);
    const reteicaOk = validarNumero('param-reteica', 'err-reteica', 'retención ICA', 0, 99);
    const intCorrienteOk = validarNumero('param-intcorriente', 'err-intcorriente', 'interés corriente', 0, 99);
    const interesMoraOk = validarNumero('param-interesmora', 'err-interesmora', 'interés por mora', 0, 100);
    const diasCarteraOk = validarNumero('param-diascartera', 'err-diascartera', 'días de cartera', 0, 180);
    const puntosOk = validarNumero('param-pesospuntos', 'err-pesospuntos', 'pesos por punto', 1);
    const rangoFacOk = validarRangoNumerico('param-facini', 'param-facfin', 'err-facini', 'err-facfin', 'número');

    if (isEdit) {
        const facActualOk = validarNumero('param-facactual', 'err-facactual', 'número actual', 1);
        const cotActualOk = validarNumero('param-cotactual', 'err-cotactual', 'número actual', 1);
        const ini = parseFloat(document.getElementById('param-facini').value.trim());
        const fin = parseFloat(document.getElementById('param-facfin').value.trim());
        const act = parseFloat(document.getElementById('param-facactual').value.trim());
        if (!isNaN(ini) && !isNaN(fin) && !isNaN(act) && (act < ini || act > fin)) {
            showFeedback(document.getElementById('err-facactual'), '⚠️ N° actual debe estar entre inicial y final', false);
            showToast('Corrija el número actual de factura', 'error');
            return;
        }
        const cotIni = parseFloat(document.getElementById('param-cotini').value.trim());
        const cotAct = parseFloat(document.getElementById('param-cotactual').value.trim());
        if (!isNaN(cotIni) && !isNaN(cotAct) && cotAct < cotIni) {
            showFeedback(document.getElementById('err-cotactual'), '⚠️ N° actual debe ser mayor o igual al inicial', false);
            showToast('Corrija el número actual de cotización', 'error');
            return;
        }
        if (!facActualOk || !cotActualOk) {
            showToast('Corrija los números actuales', 'error');
            return;
        }
    }

    if (!idOk || !resOk || !fecResOk || !fecVencOk || !prefijoFacOk || !facIniOk || !facFinOk || !rangoFacOk ||
        !prefijoCotOk || !cotIniOk || !reteicaOk || !intCorrienteOk || !interesMoraOk || !diasCarteraOk || !puntosOk) {
        showToast('Corrija los errores antes de guardar', 'error');
        return;
    }

    const form = document.getElementById('param-form');
    const formData = new FormData(form);
    const btn = form.querySelector('.btn-guardar');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';

    try {
        const response = await fetch(window.location.href, {
            method: 'POST',
            body: formData
        });
        const text = await response.text();
        let result;
        try { result = JSON.parse(text); } catch (e) {
            showToast('Respuesta inválida del servidor', 'error');
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save me-1"></i> GUARDAR RESOLUCIÓN';
            return;
        }
        if (result.success) {
            showToast(result.message, 'success');
            cerrarModal();
            location.reload();
        } else {
            if (result.errors) {
                for (const [fieldId, msg] of Object.entries(result.errors)) {
                    const feedback = document.getElementById(fieldId);
                    if (feedback) {
                        showFeedback(feedback, msg, false);
                        const input = feedback.previousElementSibling;
                        if (input && input.tagName === 'INPUT') input.style.borderColor = '#ef4444';
                    }
                }
            } else {
                showToast(result.message || 'Error al guardar', 'error');
            }
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save me-1"></i> GUARDAR RESOLUCIÓN';
        }
    } catch (error) {
        console.error('Error fetch:', error);
        showToast('Error de conexión o servidor', 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save me-1"></i> GUARDAR RESOLUCIÓN';
    }
}

// ============================================================
// INICIALIZACIÓN
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    // Validaciones en tiempo real
    const campos = [
        { id: 'param-id-empresa', fn: validarIdEmpresa },
        { id: 'param-res-aut', fn: validarResolucion },
        { id: 'param-fec-res', fn: function() { validarFecha('param-fec-res', 'err-fec-res', 'fecha de resolución'); } },
        { id: 'param-fec-venc', fn: function() { validarFecha('param-fec-venc', 'err-fec-venc', 'fecha de vencimiento'); } },
        { id: 'param-prefijofac', fn: function() { validarPrefijo('param-prefijofac', 'err-prefijofac', 'factura'); } },
        { id: 'param-prefijocot', fn: function() { validarPrefijo('param-prefijocot', 'err-prefijocot', 'cotización'); } },
        { id: 'param-facini', fn: function() { 
            validarNumero('param-facini', 'err-facini', 'número inicial', 1);
            validarRangoNumerico('param-facini', 'param-facfin', 'err-facini', 'err-facfin', 'número');
        } },
        { id: 'param-facfin', fn: function() { 
            validarNumero('param-facfin', 'err-facfin', 'número final', 1);
            validarRangoNumerico('param-facini', 'param-facfin', 'err-facini', 'err-facfin', 'número');
        } },
        { id: 'param-cotini', fn: function() { validarNumero('param-cotini', 'err-cotini', 'número inicial', 1); } },
        { id: 'param-reteica', fn: function() { validarNumero('param-reteica', 'err-reteica', 'retención ICA', 0, 99); } },
        { id: 'param-intcorriente', fn: function() { validarNumero('param-intcorriente', 'err-intcorriente', 'interés corriente', 0, 99); } },
        { id: 'param-interesmora', fn: function() { validarNumero('param-interesmora', 'err-interesmora', 'interés por mora', 0, 100); } },
        { id: 'param-diascartera', fn: function() { validarNumero('param-diascartera', 'err-diascartera', 'días de cartera', 0, 180); } },
        { id: 'param-pesospuntos', fn: function() { validarNumero('param-pesospuntos', 'err-pesospuntos', 'pesos por punto', 1); } }
    ];

    campos.forEach(campo => {
        const el = document.getElementById(campo.id);
        if (el) {
            el.addEventListener('input', campo.fn);
            el.addEventListener('blur', campo.fn);
        }
    });

    // Botón Nuevo
    document.getElementById('btn-add-param').addEventListener('click', abrirNuevoParam);

    // Delegación de eventos para la tabla (editar/eliminar)
    document.getElementById('param-tbody').addEventListener('click', function(e) {
        const target = e.target.closest('button');
        if (!target) return;
        const id = target.dataset.id;
        if (!id) return;

        if (target.classList.contains('edit')) {
            abrirEditarParam(id);
        } else if (target.classList.contains('delete')) {
            const empresa = target.closest('tr')?.cells[0]?.textContent.trim() || '';
            confirmarEliminarParam(id, empresa);
        }
    });

    // Cerrar modales con ESC
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            if (document.getElementById('modalConfirm').classList.contains('show')) cerrarConfirm();
            else cerrarModal();
        }
    });

    // Confirmar eliminación
    document.getElementById('confirm-ok-btn').addEventListener('click', eliminarConfirmado);

    // Envío del formulario
    document.getElementById('param-form').addEventListener('submit', guardarParam);

    // Inicializar filtros
    aplicarFiltros();
});