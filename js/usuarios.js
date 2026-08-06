/* ================================================================
   JAVASCRIPT — Gestión de Usuarios
   ADSOERP | Sistema de gestión
   ================================================================ */

'use strict';

// ──────────────────────────────────────────────
// CONSTANTES
// ──────────────────────────────────────────────
const USUARIOS_POR_PAGINA = 2;  // ← Cambiado a 8 usuarios por página

// ──────────────────────────────────────────────
// ESTADO GLOBAL DEL MÓDULO
// ──────────────────────────────────────────────
let hasChanges = false;
let paginaActual = 1;
let filasFiltradas = [];

// ================================================================
// MODAL: ABRIR / CERRAR
// ================================================================

function abrirModal() {
    limpiarFormulario();
    document.getElementById('modal_titulo').innerHTML =
        '<i class="bi bi-person-plus-fill"></i> Nuevo Usuario';
    document.getElementById('modalOverlay').classList.add('activo');
    document.body.style.overflow = 'hidden';
}

function abrirModalEdicion(id, nom, mail, adm, est) {
    qbe(id, nom, mail, adm, est);
    document.getElementById('modal_titulo').innerHTML =
        '<i class="bi bi-pencil-square"></i> Editar Usuario';
    document.getElementById('modalOverlay').classList.add('activo');
    document.body.style.overflow = 'hidden';
}

function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('activo');
    document.body.style.overflow = '';
}

function cerrarModalSiOverlay(event) {
    if (event.target === document.getElementById('modalOverlay')) {
        cerrarModal();
    }
}

// ================================================================
// TOGGLE CONTRASEÑA
// ================================================================

function togglePass() {
    const input = document.getElementById('f_pass');
    const icon = document.getElementById('icon_pass');
    if (!input || !icon) return;

    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'bi bi-eye';
    }
}

// ================================================================
// FILTROS + PAGINACIÓN (8 usuarios por página)
// ================================================================

function filtrarTabla() {
    const texto = document.getElementById('filtro_texto').value.toLowerCase().trim();
    const rol = document.getElementById('filtro_rol').value;
    const estado = document.getElementById('filtro_estado').value;

    const todasLasFilas = Array.from(
        document.querySelectorAll('#tablaUsuarios tbody tr:not(.no-results-row)')
    );

    // Aplicar filtros
    filasFiltradas = todasLasFilas.filter(function (fila) {
        const fUsuario = fila.dataset.usuario || '';
        const fNombre = fila.dataset.nombre || '';
        const fMail = fila.dataset.mail || '';
        const fRol = fila.dataset.rol || '';
        const fEstado = fila.dataset.estado || '';

        const ok = (!texto || fUsuario.includes(texto) || fNombre.includes(texto) || fMail.includes(texto))
            && (!rol || fRol === rol)
            && (!estado || fEstado === estado);

        fila.style.display = ok ? '' : 'none';
        return ok;
    });

    // Actualizar contador
    const totalVisibles = filasFiltradas.length;
    const countEl = document.getElementById('filtro_count');
    if (countEl) {
        const total = document.querySelectorAll('#tablaUsuarios tbody tr[data-usuario]').length;
        countEl.textContent = totalVisibles + ' de ' + total + ' usuarios';
    }

    // Eliminar fila sin resultados si existe
    document.querySelectorAll('.no-results-row').forEach(r => r.remove());

    if (totalVisibles === 0) {
        const tbody = document.querySelector('#tablaUsuarios tbody');
        const tr = document.createElement('tr');
        tr.className = 'no-results-row';
        tr.innerHTML = '<td colspan="4"><i class="bi bi-search" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;"></i>No se encontraron usuarios con esos filtros</td>';
        tbody.appendChild(tr);
    }

    // Reiniciar paginación
    paginaActual = 1;
    aplicarPaginacion();
}

function aplicarPaginacion() {
    const totalFiltradas = filasFiltradas.length;
    const totalPaginas = Math.max(1, Math.ceil(totalFiltradas / USUARIOS_POR_PAGINA));

    // Limitar página actual
    if (paginaActual > totalPaginas) paginaActual = totalPaginas;

    const inicio = (paginaActual - 1) * USUARIOS_POR_PAGINA;
    const fin = inicio + USUARIOS_POR_PAGINA;

    // Mostrar/ocultar filas según página
    filasFiltradas.forEach(function (fila, idx) {
        fila.style.display = (idx >= inicio && idx < fin) ? '' : 'none';
    });

    // Actualizar info de paginación
    const infoEl = document.getElementById('pag_info');
    if (infoEl) {
        if (totalFiltradas > 0) {
            infoEl.textContent = 'Mostrando ' + (inicio + 1) + '–' + Math.min(fin, totalFiltradas)
                + ' de ' + totalFiltradas + ' usuario' + (totalFiltradas !== 1 ? 's' : '');
        } else {
            infoEl.textContent = '';
        }
    }

    renderBotonesPaginacion(totalPaginas);
}

function renderBotonesPaginacion(totalPaginas) {
    const contenedor = document.getElementById('pag_btns');
    if (!contenedor) return;
    contenedor.innerHTML = '';

    // Botón Anterior
    const btnPrev = crearBtnPag('‹', paginaActual === 1, function () {
        if (paginaActual > 1) {
            paginaActual--;
            aplicarPaginacion();
        }
    });
    contenedor.appendChild(btnPrev);

    // Números de página (máximo 5 visibles)
    const rango = calcularRangoPaginas(paginaActual, totalPaginas, 5);
    rango.forEach(function (num) {
        if (num === '...') {
            const span = document.createElement('span');
            span.textContent = '...';
            span.style.cssText = 'color:#94a3b8;padding:0 4px;';
            contenedor.appendChild(span);
        } else {
            const btn = crearBtnPag(num, false, function () {
                paginaActual = num;
                aplicarPaginacion();
            });
            if (num === paginaActual) btn.classList.add('activa');
            contenedor.appendChild(btn);
        }
    });

    // Botón Siguiente
    const btnNext = crearBtnPag('›', paginaActual === totalPaginas, function () {
        if (paginaActual < totalPaginas) {
            paginaActual++;
            aplicarPaginacion();
        }
    });
    contenedor.appendChild(btnNext);
}

function crearBtnPag(label, disabled, onClick) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn-pag';
    btn.textContent = label;
    btn.disabled = disabled;
    if (!disabled) btn.addEventListener('click', onClick);
    return btn;
}

function calcularRangoPaginas(actual, total, maxVisible) {
    if (total <= maxVisible) {
        return Array.from({ length: total }, (_, i) => i + 1);
    }
    const mitad = Math.floor(maxVisible / 2);
    let inicio = Math.max(1, actual - mitad);
    let fin = inicio + maxVisible - 1;
    if (fin > total) {
        fin = total;
        inicio = Math.max(1, fin - maxVisible + 1);
    }

    const rango = [];
    if (inicio > 1) {
        rango.push(1);
        if (inicio > 2) rango.push('...');
    }
    for (let i = inicio; i <= fin; i++) rango.push(i);
    if (fin < total) {
        if (fin < total - 1) rango.push('...');
        rango.push(total);
    }
    return rango;
}

// ================================================================
// QBE Y LIMPIAR FORMULARIO
// ================================================================

function qbe(id, nom, mail, adm, est) {
    const alerta = document.querySelector('.alert');
    if (alerta) alerta.remove();

    document.getElementById('f_id').value = id;
    document.getElementById('f_id').readOnly = true;
    document.getElementById('f_nom').value = nom;
    document.getElementById('f_mail').value = mail;
    document.getElementById('f_adm').checked = adm;
    document.getElementById('f_est').checked = est;
    document.getElementById('f_pass').value = '';
    document.getElementById('f_pass').type = 'password';

    const icon = document.getElementById('icon_pass');
    if (icon) icon.className = 'bi bi-eye';

    limpiarValidaciones();
    hasChanges = false;
}

function limpiarFormulario() {
    const alerta = document.querySelector('.alert');
    if (alerta) alerta.remove();

    document.getElementById('f_id').value = '';
    document.getElementById('f_id').readOnly = false;
    document.getElementById('f_nom').value = '';
    document.getElementById('f_mail').value = '';
    document.getElementById('f_adm').checked = false;
    document.getElementById('f_est').checked = true;
    document.getElementById('f_pass').value = '';
    document.getElementById('f_pass').type = 'password';

    const icon = document.getElementById('icon_pass');
    if (icon) icon.className = 'bi bi-eye';

    limpiarValidaciones();
    hasChanges = false;
}

function limpiarValidaciones() {
    ['f_id', 'f_nom', 'f_mail', 'f_pass'].forEach(function (id) {
        const el = document.getElementById(id);
        if (el) el.classList.remove('input-ok', 'input-err');
    });
    ['val_id', 'val_nom', 'val_mail', 'val_pass'].forEach(function (id) {
        const box = document.getElementById(id);
        if (box) {
            box.classList.remove('visible');
            box.innerHTML = '';
        }
    });
}

// ================================================================
// VALIDACIÓN EN TIEMPO REAL
// ================================================================

function setInputState(input, isOk) {
    input.classList.toggle('input-ok', isOk);
    input.classList.toggle('input-err', !isOk);
}

function renderFeedback(containerId, reglas) {
    const box = document.getElementById(containerId);
    if (!box) return false;

    if (!reglas.length || reglas.every(r => r.texto === '')) {
        box.classList.remove('visible');
        box.innerHTML = '';
        return false;
    }

    const allOk = reglas.every(r => r.ok);
    box.innerHTML = reglas.map(r => `
        <div class="val-item ${r.ok ? 'ok' : 'err'}">
            <i class="bi ${r.ok ? 'bi-check-circle-fill' : 'bi-x-circle-fill'} vi"></i>
            <span>${r.texto}</span>
        </div>
    `).join('');
    box.classList.add('visible');
    return allOk;
}

function clearField(input, feedbackId) {
    input.classList.remove('input-ok', 'input-err');
    const box = document.getElementById(feedbackId);
    if (box) {
        box.classList.remove('visible');
        box.innerHTML = '';
    }
}

// ================================================================
// EVENTOS DE VALIDACIÓN
// ================================================================

document.addEventListener('DOMContentLoaded', function () {
    // Cerrar modal con ESC
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') cerrarModal();
    });

    // Detectar cambios sin guardar
    document.addEventListener('input', function (e) {
        if (['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) {
            hasChanges = true;
        }
    });

    document.addEventListener('submit', function () {
        hasChanges = false;
    });

    // Auto-cerrar alerta después de 5 segundos
    const alerta = document.querySelector('.alert');
    if (alerta) {
        setTimeout(function () {
            alerta.classList.remove('show');
            alerta.classList.add('fade');
            setTimeout(() => alerta.remove(), 300);
        }, 5000);
    }

    // Inicializar filtro y paginación
    filtrarTabla();

    // Validación: ID USUARIO
    const fId = document.getElementById('f_id');
    if (fId) {
        fId.addEventListener('input', function () {
            if (this.readOnly) return;
            const v = this.value;
            if (v === '') {
                clearField(this, 'val_id');
                return;
            }
            const reglas = [
                { texto: 'No debe estar vacío', ok: v.trim() !== '' },
                { texto: 'Sin espacios', ok: !/\s/.test(v) },
                { texto: 'Sin caracteres * o "', ok: !/[*"]/.test(v) },
            ];
            setInputState(this, renderFeedback('val_id', reglas));
        });
    }

    // Validación: NOMBRE
    const fNom = document.getElementById('f_nom');
    if (fNom) {
        fNom.addEventListener('input', function () {
            const v = this.value;
            if (v === '') {
                clearField(this, 'val_nom');
                return;
            }
            const reglas = [
                { texto: 'No debe estar vacío', ok: v.trim() !== '' },
                { texto: 'Sin caracteres * o "', ok: !/[*"]/.test(v) },
            ];
            setInputState(this, renderFeedback('val_nom', reglas));
        });
    }

    // Validación: CORREO
    const fMail = document.getElementById('f_mail');
    if (fMail) {
        fMail.addEventListener('input', function () {
            const v = this.value;
            if (v === '') {
                clearField(this, 'val_mail');
                return;
            }
            const emailReg = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/;
            const tieneArroba = v.includes('@');
            const tieneDominio = tieneArroba && v.split('@')[1]?.includes('.');
            const formatoOk = emailReg.test(v);
            const reglas = [
                { texto: 'Debe contener @', ok: tieneArroba },
                { texto: 'Debe tener dominio (ej: .com)', ok: tieneDominio },
                { texto: 'Formato válido (usuario@dominio.com)', ok: formatoOk },
            ];
            setInputState(this, renderFeedback('val_mail', reglas));
        });
    }

    // Validación: CONTRASEÑA
    const fPass = document.getElementById('f_pass');
    if (fPass) {
        fPass.addEventListener('input', function () {
            const v = this.value;
            if (v === '') {
                clearField(this, 'val_pass');
                return;
            }
            const simbolos = /[!@#$%^&*()\-_=+\[\]{}|;:,.<>?\/\\~`'"]/;
            const reglas = [
                { texto: 'Mínimo 12 caracteres', ok: v.length >= 12 },
                { texto: 'Sin espacios', ok: !/\s/.test(v) },
                { texto: 'Al menos una mayúscula (A-Z)', ok: /[A-Z]/.test(v) },
                { texto: 'Al menos una minúscula (a-z)', ok: /[a-z]/.test(v) },
                { texto: 'Al menos un número (0-9)', ok: /[0-9]/.test(v) },
                { texto: 'Al menos un símbolo (!@#$...)', ok: simbolos.test(v) },
            ];
            setInputState(this, renderFeedback('val_pass', reglas));
        });
    }
});

// Alerta de cambios sin guardar
window.addEventListener('beforeunload', function (e) {
    if (hasChanges) {
        e.preventDefault();
        e.returnValue = '';
    }
});