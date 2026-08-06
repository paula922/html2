/* =============================================================
   PROTECCION.js
   Solo redirige cuando DETECTA DevTools ABIERTAS, no al entrar
   ============================================================= */

(function() {
    'use strict';
    
    // ===== CONFIGURACIÓN =====
    const CONFIG = {
        URL_REDIRECCION: 'https://www.google.com',
        UMBRAL_TAMANO: 200,
        INTERVALO_DETECCION: 1000,
    };
    
    // ===== VARIABLES DE CONTROL =====
    let devToolsDetectadas = false;
    let redireccionEnProgreso = false;

    // ===== RATIO BASE (capturado antes de cualquier zoom) =====
    const PIXEL_RATIO_BASE = window.devicePixelRatio || 1;
    
    // ===== REDIRECCIÓN SOLO SI SE DETECTAN DEVTOOLS =====
    function redirigirSiDevTools() {
        if (devToolsDetectadas && !redireccionEnProgreso) {
            redireccionEnProgreso = true;
            console.log('DevTools detectadas - Redirigiendo a Google');
            location.replace(CONFIG.URL_REDIRECCION);
        }
    }
    
    // ===== 1. BLOQUEO DE TECLAS (CON REGISTRO, NO REDIRECCIÓN INMEDIATA) =====
    document.addEventListener('keydown', function(e) {
        const tecla = e.key;
        const codigo = e.keyCode;
        
        if (codigo === 123 || tecla === 'F12' ||
            (e.ctrlKey && e.shiftKey && (tecla === 'I' || tecla === 'J' || tecla === 'C')) ||
            (e.ctrlKey && (tecla === 'u' || tecla === 'U')) ||
            (e.metaKey && e.altKey && tecla === 'I')) {
            
            e.preventDefault();
            console.log('Intento de abrir DevTools detectado');
            setTimeout(verificarDevTools, 500);
            return false;
        }
    }, { capture: true });
    
    // ===== 2. CLICK DERECHO (SOLO BLOQUEAR, NO REDIRIGIR) =====
    document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
        return false;
    }, { capture: true });
    
    // ===== 3. DETECCIÓN POR TAMAÑO (CON CORRECCIÓN DE ZOOM) =====
    function verificarDevTools() {
        const ow = window.outerWidth;
        const iw = window.innerWidth;
        const oh = window.outerHeight;
        const ih = window.innerHeight;

        const zoomRaw = (window.devicePixelRatio || 1) / PIXEL_RATIO_BASE;
        const zoom = Math.max(zoomRaw, 1);

        const diffAnchoZoom = ow - (ow / zoom);
        const diffAltoZoom  = (oh - (oh / zoom)) + 85;

        const diffAnchoReal = ow - iw;
        const diffAltoReal  = oh - ih;

        const excesoAncho = diffAnchoReal - diffAnchoZoom;
        const excesoAlto  = diffAltoReal  - diffAltoZoom;

        if (excesoAncho > CONFIG.UMBRAL_TAMANO || excesoAlto > CONFIG.UMBRAL_TAMANO) {
            console.log('DevTools detectadas por tamaño:', { excesoAncho, excesoAlto });
            devToolsDetectadas = true;
            redirigirSiDevTools();
        }
    }
    
    setInterval(verificarDevTools, CONFIG.INTERVALO_DETECCION);

    window.addEventListener('resize', function() {
        setTimeout(verificarDevTools, 500); // 500ms para que celular estabilice teclado/rotación
    });
    
    // ===== 4. DETECCIÓN POR CONSOLA =====

    let detectorActivo = false;

function detectarConsolaUniversal() {
    if (devToolsDetectadas) return;

    let abierto = false;

    const elemento = new Image();

    Object.defineProperty(elemento, 'id', {
        get: function() {
            abierto = true;
            devToolsDetectadas = true;
            redirigirSiDevTools();
        }
    });

    console.log(elemento);

    if (abierto) {
        devToolsDetectadas = true;
        redirigirSiDevTools();
    }
}

setInterval(detectarConsolaUniversal, 1200);

    // ===== 5. DETECCIÓN DE CAMBIOS EN LA VENTANA =====
    let ultimoAncho = window.outerWidth;
    let ultimoAlto = window.outerHeight;
    
    setInterval(function() {
        if (!devToolsDetectadas) {
            if (Math.abs(window.outerWidth - ultimoAncho) > 150 || 
                Math.abs(window.outerHeight - ultimoAlto) > 150) {
                setTimeout(verificarDevTools, 500); // pausa para que se estabilice
            }
            
            ultimoAncho = window.outerWidth;
            ultimoAlto = window.outerHeight;
        }
    }, 500);
    
    // ===== 6. BLOQUEAR SELECCIÓN DE TEXTO =====
    document.addEventListener('selectstart', function(e) {
        e.preventDefault();
        return false;
    }, { capture: true });
    
    // ===== 7. CSS ANTI-SELECCIÓN =====
    const estilo = document.createElement('style');
    estilo.textContent = `
        * {
            -webkit-user-select: none !important;
            -moz-user-select: none !important;
            -ms-user-select: none !important;
            user-select: none !important;
            -webkit-touch-callout: none !important;
        }
    `;
    document.head.appendChild(estilo);
    
    // ===== 8. PROTECCIÓN CONTRA ARRASTRE =====
    document.addEventListener('dragstart', function(e) {
        e.preventDefault();
        return false;
    }, { capture: true });
    
    // ===== 9. INICIALIZACIÓN SUAVE =====
    setTimeout(function() {
        console.log('Protección activa - Modo estable');
        setTimeout(verificarDevTools, 2000);
    }, 1000);
    
})();

/* COMPATIBILIDAD CON BRAVE Y OTROS NAVEGADORES DETECCION POR DEBUGER */

setInterval(function() {

    if (devToolsDetectadas) return;

    const inicio = performance.now();

    debugger;

    const fin = performance.now();

    if (fin - inicio > 120) {
        console.log('DevTools detectadas por debugger');
        devToolsDetectadas = true;
        redirigirSiDevTools();
    }

}, 1500);