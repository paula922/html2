'use strict';

// ============================================================
// 1. ESTADO GLOBAL
// ============================================================
let editingCodigo = null;
let pendingDeleteCodigo = null;
let currentFilter = 'all';

// ============================================================
// 2. FUNCIONES DE UTILIDAD
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
        .replace(/[\x00]/g,    '')
        .replace(/'/g,         '')
        .replace(/"/g,         '')
        .replace(/;/g,         '')
        .replace(/--/g,        '')
        .replace(/\/\*/g,      '')
        .replace(/\*\//g,      '')
        .replace(/xp_/gi,      '')
        .replace(/DROP\s/gi,   '')
        .replace(/DELETE\s/gi, '')
        .replace(/INSERT\s/gi, '')
        .replace(/UPDATE\s/gi, '')
        .replace(/EXEC\s/gi,   '')
        .replace(/UNION\s/gi,  '')
        .replace(/SELECT\s/gi, '')
        .replace(/</g,  '&lt;')
        .replace(/>/g,  '&gt;')
        .trim();
}

// ============================================================
// 3. VALIDACIONES EN TIEMPO REAL (como PUC)
// ============================================================

function validarCodigo(idInput, idFeedback, maxLength = 1) {
    const input = document.getElementById(idInput);
    const feedback = document.getElementById(idFeedback);
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = 'El código es obligatorio';
        isValid = false;
    } else if (!/^\d+$/.test(valor)) {
        message = '⚠️ Solo números permitidos';
        isValid = false;
    } else if (valor.length !== maxLength) {
        message = `⚠️ El código debe tener ${maxLength} dígito(s)`;
        isValid = false;
    } else {
        message = '✓ Código válido';
        isValid = true;
    }

    feedback.textContent = message;
    feedback.style.display = 'block';
    feedback.style.color = isValid ? '#22c55e' : '#ef4444';
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');

    return isValid;
}

function validarNombre(idInput, idFeedback, minLen = 3, maxLen = 100) {
    const input = document.getElementById(idInput);
    const feedback = document.getElementById(idFeedback);
    if (!input || !feedback) return false;

    const valor = input.value.trim();
    let isValid = true;
    let message = '';

    if (valor === '') {
        message = 'El nombre es obligatorio';
        isValid = false;
    } else if (valor.length < minLen) {
        message = `⚠️ Mínimo ${minLen} caracteres`;
        isValid = false;
    } else if (valor.length > maxLen) {
        message = `⚠️ No puede exceder ${maxLen} caracteres`;
        isValid = false;
    } else {
        message = '✓ Nombre válido';
        isValid = true;
    }

    feedback.textContent = message;
    feedback.style.display = 'block';
    feedback.style.color = isValid ? '#22c55e' : '#ef4444';
    input.style.borderColor = isValid ? '#22c55e' : (valor === '' ? '#e2e8f0' : '#ef4444');

    return isValid;
}

function limpiarValidaciones(modalId) {
    const container = document.getElementById(modalId);
    if (!container) return;
    const feedbacks = container.querySelectorAll('.field-error');
    feedbacks.forEach(el => {
        el.style.display = 'none';
        el.textContent = '';
    });
    const inputs = container.querySelectorAll('.form-input');
    inputs.forEach(inp => inp.style.borderColor = '#e2e8f0');
}

// ============================================================
// 4. ACTUALIZAR ESTADÍSTICAS Y FILTROS
// ============================================================
function updateStats(data) {
    const total     = data.length;
    const activas   = data.filter(f => f.ind_borrado === 'f' || f.ind_borrado === false).length;
    const eliminadas = total - activas;
    setText('stat-total', total);
    setText('stat-activas', activas);
    setText('stat-eliminadas', eliminadas);
}

function applyFilters() {
    const query        = sanitizeText(document.getElementById('fp-search')?.value ?? '').toLowerCase();
    const activeToggle = document.querySelector('.filter-toggle.active')?.dataset.filter ?? 'all';
    const filas = document.querySelectorAll('#fp-tbody tr:not(.empty-row)');
    let visible = 0;
    filas.forEach(fila => {
        const codigo = fila.cells[0]?.textContent.toLowerCase() ?? '';
        const nombre = fila.cells[1]?.textContent.toLowerCase() ?? '';
        const estado = fila.cells[2]?.textContent.trim().toLowerCase() ?? '';
        const pasaTexto  = !query || codigo.includes(query) || nombre.includes(query);
        const pasaEstado = activeToggle === 'all'
            || (activeToggle === 'active'   && estado.includes('activa') && !estado.includes('eliminada'))
            || (activeToggle === 'inactive' && estado.includes('eliminada'));
        const mostrar = pasaTexto && pasaEstado;
        fila.style.display = mostrar ? '' : 'none';
        if (mostrar) visible++;
    });
    setText('fp-count', `${visible} resultado${visible !== 1 ? 's' : ''}`);
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = (query || activeToggle !== 'all') ? 'flex' : 'none';
}

function clearFilters() {
    const input = document.getElementById('fp-search');
    if (input) input.value = '';
    document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
    document.querySelector('.filter-toggle[data-filter="all"]')?.classList.add('active');
    document.querySelectorAll('#fp-tbody tr:not(.empty-row)')
        .forEach(fila => fila.style.display = '');
    const btnClear = document.getElementById('btn-clear-filters');
    if (btnClear) btnClear.style.display = 'none';
    setText('fp-count', `${formasPagoData.length} resultado${formasPagoData.length !== 1 ? 's' : ''}`);
}

// ============================================================
// 5. MODALES NUEVO / EDITAR / ELIMINAR
// ============================================================

function openNewModal() {
    document.getElementById('new-fp-form')?.reset();
    limpiarValidaciones('modal-new-fp');
    show('modal-new-fp');
    document.getElementById('new-fp-codigo')?.focus();
}

function closeNewModal() {
    hide('modal-new-fp');
}

function openEditModal(codigo) {
    const f = formasPagoData.find(f => f.id_formapago === codigo);
    if (!f) {
        showToast('No se encontraron los datos de la forma de pago', 'error');
        return;
    }
    limpiarValidaciones('modal-edit-fp');
    setVal('edit-fp-hid-codigo', f.id_formapago);
    setVal('edit-fp-codigo', f.id_formapago);
    setVal('edit-fp-nombre', f.nom_formapago);
    show('modal-edit-fp');
    document.getElementById('edit-fp-nombre')?.focus();
}

function closeEditModal() {
    hide('modal-edit-fp');
}

// ============================================================
// 6. ELIMINAR (borrado lógico)
// ============================================================
function confirmarEliminar(codigo, nombre) {
    pendingDeleteCodigo = codigo;
    document.getElementById('confirm-title').textContent = `Eliminar "${escapeHtml(nombre)}"`;
    document.getElementById('confirm-body').textContent = 'Se marcará como eliminada (borrado lógico). ¿Deseas continuar?';
    show('modal-confirm');
}

function closeConfirmModal() {
    hide('modal-confirm');
    pendingDeleteCodigo = null;
}

function eliminarConfirmado() {
    if (pendingDeleteCodigo === null) return;
    const formData = new FormData();
    formData.append('btn_eliminar', '1');
    formData.append('hid_del_id', pendingDeleteCodigo);

    fetch(window.location.href, {
        method: 'POST',
        body: formData
    })
    .then(res => res.text())
    .then(text => {
        console.log('Respuesta eliminar:', text);
        let result;
        try { result = JSON.parse(text); } catch (e) { result = { success: false, message: 'Respuesta inválida' }; }
        if (result.success) {
            showToast(result.message, 'success');
            closeConfirmModal();
            location.reload();
        } else {
            showToast(result.message || 'Error al eliminar', 'error');
            closeConfirmModal();
        }
    })
    .catch(() => {
        showToast('Error de conexión', 'error');
        closeConfirmModal();
    });
}

// ============================================================
// 7. RESTAURAR
// ============================================================
function restaurarFp(codigo) {
    if (!confirm('¿Restaurar esta forma de pago? Volverá a estar activa.')) return;
    const formData = new FormData();
    formData.append('btn_restaurar', '1');
    formData.append('hid_restore_id', codigo);
    fetch(window.location.href, {
        method: 'POST',
        body: formData
    })
    .then(res => res.text())
    .then(text => {
        console.log('Respuesta restaurar:', text);
        let result;
        try { result = JSON.parse(text); } catch (e) { result = { success: false, message: 'Respuesta inválida' }; }
        if (result.success) {
            showToast(result.message, 'success');
            location.reload();
        } else {
            showToast(result.message || 'Error al restaurar', 'error');
        }
    })
    .catch(() => showToast('Error de conexión', 'error'));
}

// ============================================================
// 8. ENVÍO DE FORMULARIOS VÍA FETCH (AJAX) CON VALIDACIÓN PREVIA
// ============================================================
document.addEventListener('DOMContentLoaded', function() {

    // --- Nuevo ---
    const newForm = document.getElementById('new-fp-form');
    if (newForm) {
        // Validaciones en tiempo real
        const codigoInput = document.getElementById('new-fp-codigo');
        if (codigoInput) {
            codigoInput.addEventListener('input', function() {
                validarCodigo('new-fp-codigo', 'err-codigo-cliente', 1);
            });
            codigoInput.addEventListener('blur', function() {
                validarCodigo('new-fp-codigo', 'err-codigo-cliente', 1);
            });
        }
        const nombreInput = document.getElementById('new-fp-nombre');
        if (nombreInput) {
            nombreInput.addEventListener('input', function() {
                validarNombre('new-fp-nombre', 'err-nombre-cliente', 3, 100);
            });
            nombreInput.addEventListener('blur', function() {
                validarNombre('new-fp-nombre', 'err-nombre-cliente', 3, 100);
            });
        }

        newForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            // Validar antes de enviar
            const codigoOk = validarCodigo('new-fp-codigo', 'err-codigo-cliente', 1);
            const nombreOk = validarNombre('new-fp-nombre', 'err-nombre-cliente', 3, 100);
            if (!codigoOk || !nombreOk) {
                showToast('Corrija los errores antes de guardar', 'error');
                return;
            }

            const formData = new FormData(this);
            const btn = document.querySelector('#modal-new-fp .btn-success');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';

            try {
                const response = await fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                console.log('Respuesta nuevo:', text);

                let result;
                try { result = JSON.parse(text); } catch (e) { result = { success: false, message: 'Respuesta inválida' }; }

                if (result.success) {
                    showToast(result.message, 'success');
                    closeNewModal();
                    location.reload();
                } else {
                    if (result.errors && Object.keys(result.errors).length > 0) {
                        for (const [fieldId, msg] of Object.entries(result.errors)) {
                            showFieldError(fieldId, msg);
                        }
                    } else {
                        showToast(result.message || 'Error al guardar', 'error');
                    }
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
                }
            } catch (error) {
                console.error('Error en fetch:', error);
                showToast('Error de conexión o servidor.', 'error');
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> Guardar';
            }
        });
    }

    // --- Editar ---
    const editForm = document.getElementById('edit-fp-form');
    if (editForm) {
        const editNombreInput = document.getElementById('edit-fp-nombre');
        if (editNombreInput) {
            editNombreInput.addEventListener('input', function() {
                validarNombre('edit-fp-nombre', 'err-edit-nombre', 3, 100);
            });
            editNombreInput.addEventListener('blur', function() {
                validarNombre('edit-fp-nombre', 'err-edit-nombre', 3, 100);
            });
        }

        editForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const nombreOk = validarNombre('edit-fp-nombre', 'err-edit-nombre', 3, 100);
            if (!nombreOk) {
                showToast('Corrija el nombre antes de guardar', 'error');
                return;
            }

            const formData = new FormData(this);
            const btn = document.querySelector('#modal-edit-fp .btn-primary');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Actualizando...';

            try {
                const response = await fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                console.log('Respuesta editar:', text);

                let result;
                try { result = JSON.parse(text); } catch (e) { result = { success: false, message: 'Respuesta inválida' }; }

                if (result.success) {
                    showToast(result.message, 'success');
                    closeEditModal();
                    location.reload();
                } else {
                    if (result.errors && Object.keys(result.errors).length > 0) {
                        for (const [fieldId, msg] of Object.entries(result.errors)) {
                            showFieldError(fieldId, msg);
                        }
                    } else {
                        showToast(result.message || 'Error al actualizar', 'error');
                    }
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-save"></i> Guardar Cambios';
                }
            } catch (error) {
                console.error('Error en fetch:', error);
                showToast('Error de conexión o servidor.', 'error');
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> Guardar Cambios';
            }
        });
    }

    // ============================================================
    // 9. EVENTOS DE FILTROS, CIERRE DE MODALES, ETC.
    // ============================================================

    // Botón nuevo
    document.getElementById('btn-add-fp')?.addEventListener('click', openNewModal);

    // Filtros
    document.getElementById('fp-search')?.addEventListener('input', applyFilters);
    document.querySelectorAll('.filter-toggle').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            applyFilters();
        });
    });
    document.getElementById('btn-clear-filters')?.addEventListener('click', clearFilters);

    // Cerrar modales
    document.querySelectorAll('.btn-close-modal').forEach(btn => btn.addEventListener('click', function() {
        hide('modal-new-fp');
        hide('modal-edit-fp');
        hide('modal-confirm');
        pendingDeleteCodigo = null;
    }));

    // Confirmación eliminar
    document.getElementById('confirm-cancel-btn')?.addEventListener('click', closeConfirmModal);
    document.getElementById('confirm-ok-btn')?.addEventListener('click', eliminarConfirmado);

    // Cerrar modal al hacer clic fuera
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                hide('modal-new-fp');
                hide('modal-edit-fp');
                hide('modal-confirm');
                pendingDeleteCodigo = null;
            }
        });
    });

    // Botones de acción en la tabla (usando delegación de eventos)
    document.querySelector('#fp-tbody')?.addEventListener('click', function(e) {
        const target = e.target.closest('button');
        if (!target) return;
        const codigo = target.dataset.codigo;
        if (!codigo) return;

        // Editar
        if (target.classList.contains('edit')) {
            openEditModal(codigo);
        }
        // Eliminar
        else if (target.classList.contains('reject')) {
            const nombre = target.closest('tr')?.cells[1]?.textContent.trim() || '';
            confirmarEliminar(codigo, nombre);
        }
        // Restaurar
        else if (target.classList.contains('toggle')) {
            restaurarFp(codigo);
        }
    });

    // Actualizar estadísticas al inicio
    updateStats(formasPagoData);
    setText('fp-count', `${formasPagoData.length} resultado${formasPagoData.length !== 1 ? 's' : ''}`);
});