/* ============================================================
   sidebar.js – Control del sidebar para móvil y desktop
   ADSOERP – Compatible con sidebar-left
   ============================================================ */

'use strict';

document.addEventListener('DOMContentLoaded', function() {
    
    const sidebar = document.querySelector('.sidebar-left');
    const topNav = document.querySelector('.top-nav');
    
    if (!sidebar) return;
    
    // ============================================
    // CREAR BOTÓN HAMBURGUESA
    // ============================================
    let menuBtn = document.querySelector('.menu-toggle-btn');
    
    if (!menuBtn && topNav) {
        menuBtn = document.createElement('button');
        menuBtn.className = 'menu-toggle-btn';
        menuBtn.innerHTML = '<i class="bi bi-list"></i>';
        menuBtn.setAttribute('aria-label', 'Abrir menú');
        
        // Insertar antes del logo
        const logo = topNav.querySelector('.top-nav-logo');
        if (logo) {
            topNav.insertBefore(menuBtn, logo);
        } else {
            topNav.insertBefore(menuBtn, topNav.firstChild);
        }
    }
    
    // ============================================
    // CREAR OVERLAY
    // ============================================
    let overlay = document.querySelector('.mobile-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'mobile-overlay';
        document.body.appendChild(overlay);
    }
    
    // ============================================
    // FUNCIONES
    // ============================================
    function isMobile() {
        return window.innerWidth <= 768;
    }
    
    function openSidebar() {
        if (!sidebar) return;
        sidebar.classList.add('mobile-open');
        overlay.classList.add('active');
        document.body.classList.add('sidebar-open');
        
        // Cambiar ícono a X
        if (menuBtn) {
            menuBtn.innerHTML = '<i class="bi bi-x-lg"></i>';
        }
    }
    
    function closeSidebar() {
        if (!sidebar) return;
        sidebar.classList.remove('mobile-open');
        overlay.classList.remove('active');
        document.body.classList.remove('sidebar-open');
        
        // Restaurar ícono hamburguesa
        if (menuBtn) {
            menuBtn.innerHTML = '<i class="bi bi-list"></i>';
        }
    }
    
    function toggleSidebar() {
        if (!sidebar) return;
        
        if (isMobile()) {
            if (sidebar.classList.contains('mobile-open')) {
                closeSidebar();
            } else {
                openSidebar();
            }
        }
    }
    
    // ============================================
    // EVENTOS
    // ============================================
    
    // Botón hamburguesa
    if (menuBtn) {
        menuBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            toggleSidebar();
        });
    }
    
    // Clic en overlay para cerrar
    overlay.addEventListener('click', function() {
        closeSidebar();
    });
    
    // Cerrar al hacer clic en un enlace del sidebar (móvil)
    const navLinks = sidebar.querySelectorAll('.sidebar-menu a, .sidebar-header a');
    navLinks.forEach(function(link) {
        link.addEventListener('click', function() {
            if (isMobile()) {
                closeSidebar();
            }
        });
    });
    
    // Cerrar con tecla ESC
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isMobile() && sidebar.classList.contains('mobile-open')) {
            closeSidebar();
        }
    });
    
    // Al redimensionar, si pasa a desktop y estaba abierto, cerrar
    window.addEventListener('resize', function() {
        if (!isMobile() && sidebar.classList.contains('mobile-open')) {
            closeSidebar();
        }
    });
    
    console.log('✓ sidebar.js cargado correctamente');
});