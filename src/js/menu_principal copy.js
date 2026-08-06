// js/menu_principal.js

// Toggle para mostrar/ocultar nietos en el menú lateral
document.querySelectorAll('[data-toggle-nietos]').forEach(function(link) {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        var parentLi = this.closest('li.has-nietos');
        var nietosMenu = parentLi.querySelector('.nietos-menu');
        if (nietosMenu) {
            nietosMenu.classList.toggle('show');
            parentLi.classList.toggle('open');
        }
    });
});

// Funciones globales útiles para todos los módulos
window.ADSOERP = {
    showAlert: function(message, type = 'success') {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            <i class="bi ${type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill'} me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        const container = document.querySelector('.content-card');
        if (container) {
            container.insertBefore(alertDiv, container.firstChild);
            setTimeout(() => alertDiv.remove(), 5000);
        }
    },
    
    loading: function(show = true) {
        let loader = document.getElementById('global-loader');
        if (show && !loader) {
            loader = document.createElement('div');
            loader.id = 'global-loader';
            loader.style.cssText = `
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 9999;
            `;
            loader.innerHTML = '<div class="spinner-border text-primary" role="status"><span class="visually-hidden">Cargando...</span></div>';
            document.body.appendChild(loader);
        } else if (!show && loader) {
            loader.remove();
        }
    },
    
    fetchAPI: async function(url, options = {}) {
        this.loading(true);
        try {
            const response = await fetch(url, options);
            const data = await response.json();
            this.loading(false);
            return data;
        } catch (error) {
            this.loading(false);
            this.showAlert('Error en la petición: ' + error.message, 'danger');
            throw error;
        }
    }
};