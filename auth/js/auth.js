/* ===============================================================
   AUTH.JS — Validaciones de login y envío AJAX (versión corregida)
   =============================================================== */

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. REGLAS DE VALIDACIÓN FRONTEND (solo para feedback visual)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const RULES = {
  user: {
    regex: /^[a-zA-Z0-9@]+$/,
    noSpace: /\s/,
    minLen: 3,
    msgs: {
      empty: 'El usuario es obligatorio.',
      space: 'El usuario no puede contener espacios.',
      invalid: 'Solo letras, números y @.',
    },
    ok: 'Usuario válido ✓',
  },
  pw: {
    minLen: 6,
    msgs: {
      empty: 'La contraseña es obligatoria.',
      min: 'Mínimo 6 caracteres.',
    },
    ok: 'Contraseña válida ✓',
  },
};

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. FUNCIONES DE MENSAJES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function setMsg(id, text, type) {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = text;
  el.className = 'field-msg' + (type ? ' ' + type : '');
}

function setInputState(id, ok) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.toggle('input-ok', ok === true);
  el.classList.toggle('input-error', ok === false);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. VALIDACIONES INDIVIDUALES (feedback visual)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function validateUser(val) {
  const r = RULES.user;
  if (!val) {
    setMsg('user-msg', r.msgs.empty, 'msg-err');
    setInputState('user-input', false);
    return false;
  }
  if (r.noSpace.test(val)) {
    setMsg('user-msg', r.msgs.space, 'msg-err');
    setInputState('user-input', false);
    return false;
  }
  if (!r.regex.test(val)) {
    setMsg('user-msg', r.msgs.invalid, 'msg-err');
    setInputState('user-input', false);
    return false;
  }
  if (val.length < r.minLen) {
    setMsg('user-msg', `Mínimo ${r.minLen} caracteres.`, 'msg-err');
    setInputState('user-input', false);
    return false;
  }
  setMsg('user-msg', r.ok, 'msg-ok');
  setInputState('user-input', true);
  return true;
}

function validatePw(val) {
  const r = RULES.pw;
  if (!val) {
    setMsg('pw-msg', r.msgs.empty, 'msg-err');
    setInputState('pw-input', false);
    return false;
  }
  if (val.length < r.minLen) {
    setMsg('pw-msg', r.msgs.min, 'msg-err');
    setInputState('pw-input', false);
    return false;
  }
  setMsg('pw-msg', r.ok, 'msg-ok');
  setInputState('pw-input', true);
  return true;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. EVENTOS EN TIEMPO REAL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

document.addEventListener('DOMContentLoaded', () => {
  const userInput = document.getElementById('user-input');
  const pwInput = document.getElementById('pw-input');
  if (!userInput || !pwInput) return;

  userInput.addEventListener('input', () => validateUser(userInput.value));
  userInput.addEventListener('blur', () => {
    if (userInput.value) validateUser(userInput.value);
  });
  pwInput.addEventListener('input', () => validatePw(pwInput.value));
  pwInput.addEventListener('blur', () => {
    if (pwInput.value) validatePw(pwInput.value);
  });
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. ENVÍO DEL FORMULARIO (AJAX) — VERSIÓN ROBUSTA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async function doLogin(e) {
  if (e) e.preventDefault();

  // Obtener elementos con validación
  const userInput = document.getElementById('user-input');
  const pwInput = document.getElementById('pw-input');
  const submitBtn = document.querySelector('.btn-primary');

  if (!userInput || !pwInput || !submitBtn) {
    mostrarError('Error: Elementos del formulario no encontrados.');
    return false;
  }

  const username = userInput.value.trim();
  const password = pwInput.value;
  const csrfToken = document.querySelector('input[name="csrf_token"]')?.value || '';

  // Validar campos (feedback visual)
  const userOk = validateUser(username);
  const pwOk = validatePw(password);
  if (!userOk || !pwOk) {
    // No enviar si el frontend detecta error
    return false;
  }

  if (!csrfToken) {
    mostrarError('Error de seguridad: Token CSRF no encontrado.');
    return false;
  }

  // Deshabilitar botón y mostrar estado de carga
  const originalText = submitBtn.innerHTML;
  submitBtn.innerHTML = 'Procesando...';
  submitBtn.disabled = true;

  try {
    const formData = new FormData();
    formData.append('txt_usuario', username);
    formData.append('txt_clave', password);
    formData.append('csrf_token', csrfToken);

    const response = await fetch(window.location.href, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: formData
    });

    // Intentar parsear JSON
    let result;
    try {
      result = await response.json();
    } catch (parseError) {
      console.error('Error al parsear JSON:', parseError);
      throw new Error('Respuesta inválida del servidor.');
    }

    if (result.success && result.redirect) {
      // Redirección exitosa
      window.location.replace(result.redirect);
    } else {
      // Mostrar mensaje de error
      mostrarError(result.message || 'Error al iniciar sesión.');
      pwInput.value = '';
      validatePw('');
      submitBtn.innerHTML = originalText;
      submitBtn.disabled = false;
    }

  } catch (error) {
    console.error('Error en login:', error);
    mostrarError('Error de conexión. Intente nuevamente.');
    pwInput.value = '';
    validatePw('');
    submitBtn.innerHTML = originalText;
    submitBtn.disabled = false;
  }

  return false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. MOSTRAR/OCULTAR CONTRASEÑA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function togglePw() {
  const input = document.getElementById('pw-input');
  const eye = document.getElementById('pw-eye');
  if (!input || !eye) return;
  if (input.type === 'password') {
    input.type = 'text';
    eye.innerHTML =
      '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8' +
      'a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8' +
      'a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>' +
      '<line x1="1" y1="1" x2="23" y2="23"/>';
  } else {
    input.type = 'password';
    eye.innerHTML =
      '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
      '<circle cx="12" cy="12" r="3"/>';
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. FUNCIÓN PARA MOSTRAR ERRORES EN LA INTERFAZ
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function mostrarError(mensaje) {
  // Eliminar alerta anterior
  const oldAlert = document.querySelector('.login-alert');
  if (oldAlert) oldAlert.remove();

  const alertDiv = document.createElement('div');
  alertDiv.className = 'login-alert';
  alertDiv.style.cssText = `
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.3);
    color: #dc2626;
    padding: 12px 16px;
    border-radius: 12px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 500;
    font-size: 14px;
    animation: slideDown 0.3s ease;
  `;
  alertDiv.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
      <circle cx="12" cy="12" r="10"/>
      <line x1="12" y1="8" x2="12" y2="12"/>
      <line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>
    <span style="flex:1;">${mensaje}</span>
    <button onclick="this.parentElement.remove()" style="background:none; border:none; cursor:pointer; color:#dc2626; font-size:18px; padding:0 5px;">×</button>
  `;

  const authCard = document.querySelector('.auth-card');
  if (authCard) {
    authCard.insertBefore(alertDiv, authCard.firstChild);
    // Auto ocultar después de 5 segundos
    setTimeout(() => {
      if (alertDiv.parentElement) alertDiv.remove();
    }, 5000);
  }
}