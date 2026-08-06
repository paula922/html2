'use strict';

/**
 * ============================================================================
 * MÓDULO CLIENTES - JavaScript profesional
 * ============================================================================
 * - Manejo robusto de eventos
 * - AJAX con validación completa
 * - Modales con ciclo de vida claro
 * - Seguridad XSS y CSRF
 * - Error handling comprehensivo
 */

// ============================================================================
// 1. CONFIGURACIÓN Y ESTADO GLOBAL
// ============================================================================
const ClienteManager = {
    state: {
        currentEditId: null,
        pendingDeleteId: null,
        isSubmitting: false,
        modals: {
            new: 'modal-new-cliente',
            edit: 'modal-edit-cliente',
            detail: 'modal-detail',
            confirm: 'modal-confirm'
        }
    },

    rules: [
        // ---------- Formulario NUEVO ----------
        {
            id: 'new-cliente-nombre',
            event: 'input',
            fn: () => ClienteManager.validation.validarNombre('new')
        },
        {
            id: 'new-id-tipo',
            event: 'change',
            fn: () => ClienteManager.validation.validarTipoDocumento('new')
        },
        {
            id: 'new-tipo-tercero',
            event: 'change',
            fn: () => ClienteManager.validation.validarTipoCliente('new')
        },
        {
            id: 'new-cat-tercero',
            event: 'change',
            fn: () => ClienteManager.validation.validarCategoria('new')
        },
        {
            id: 'new-cliente-fec-nac',
            event: 'change',
            fn: () => ClienteManager.validation.validarFechaNacimiento('new')
        },
        {
            id: 'new-cliente-genero',
            event: 'change',
            fn: () => ClienteManager.validation.validarGenero('new')
        },
        {
            id: 'new-prefijo-movil',
            event: 'change',
            fn: () => ClienteManager.validation.validarPrefijo('new')
        },
        {
            id: 'new-cliente-tel-movil',
            event: 'input',
            fn: () => ClienteManager.validation.validarCelular('new')
        },
        {
            id: 'new-cliente-tel-fijo',
            event: 'input',
            fn: () => ClienteManager.validation.validarTelefono('new')
        },
        {
            id: 'new-cliente-email',
            event: 'input',
            fn: () => ClienteManager.validation.validarEmail('new')
        },
        {
            id: 'new-cliente-direccion',
            event: 'input',
            fn: () => ClienteManager.validation.validarDireccion('new')
        },
        {
            id: 'new-cliente-ciudad',
            event: 'change',
            fn: () => ClienteManager.validation.validarCiudad('new')
        },
        {
            id: 'new-cliente-restriccion',
            event: 'change',
            fn: () => ClienteManager.validation.validarRestriccion('new')
        },
        {
            id: 'new-cliente-puntos',
            event: 'input',
            fn: () => ClienteManager.validation.validarPuntos('new')
        },
        {
            id: 'new-cliente-estado',
            event: 'change',
            fn: () => ClienteManager.validation.validarEstado('new')
        },
        {
            id: 'new-cliente-cupo',
            event: 'input',
            fn: () => ClienteManager.validation.validarCupo('new')
        },
        {
            id: 'new-cliente-diascartera',
            event: 'input',
            fn: () => ClienteManager.validation.validarDiasCartera('new')
        },

        // ---------- Formulario EDITAR ----------
        {
            id: 'edit-id-tipo',
            event: 'change',
            fn: () => ClienteManager.validation.validarTipoDocumento()
        },
        {
            id: 'edit-tipo-tercero',
            event: 'change',
            fn: () => ClienteManager.validation.validarTipoCliente()
        },
        {
            id: 'edit-cat-tercero',
            event: 'change',
            fn: () => ClienteManager.validation.validarCategoria()
        },
        {
            id: 'edit-cliente-nombre',
            event: 'input',
            fn: () => ClienteManager.validation.validarNombre()
        },
        {
            id: 'edit-cliente-fec-nac',
            event: 'change',
            fn: () => ClienteManager.validation.validarFechaNacimiento()
        },
        {
            id: 'edit-cliente-genero',
            event: 'change',
            fn: () => ClienteManager.validation.validarGenero()
        },
        {
            id: 'edit-prefijo-movil',
            event: 'change',
            fn: () => ClienteManager.validation.validarPrefijo()
        },
        {
            id: 'edit-cliente-tel-movil',
            event: 'input',
            fn: () => ClienteManager.validation.validarCelular()
        },
        {
            id: 'edit-cliente-tel-fijo',
            event: 'input',
            fn: () => ClienteManager.validation.validarTelefono()
        },
        {
            id: 'edit-cliente-email',
            event: 'input',
            fn: () => ClienteManager.validation.validarEmail()
        },
        {
            id: 'edit-cliente-direccion',
            event: 'input',
            fn: () => ClienteManager.validation.validarDireccion()
        },
        {
            id: 'edit-cliente-ciudad',
            event: 'change',
            fn: () => ClienteManager.validation.validarCiudad()
        },
        {
            id: 'edit-cliente-restriccion',
            event: 'change',
            fn: () => ClienteManager.validation.validarRestriccion()
        },
        {
            id: 'edit-cliente-puntos',
            event: 'input',
            fn: () => ClienteManager.validation.validarPuntos()
        },
        {
            id: 'edit-cliente-estado',
            event: 'change',
            fn: () => ClienteManager.validation.validarEstado()
        },
        {
            id: 'edit-cliente-cupo',
            event: 'input',
            fn: () => ClienteManager.validation.validarCupo()
        },
        {
            id: 'edit-cliente-diascartera',
            event: 'input',
            fn: () => ClienteManager.validation.validarDiasCartera()
        }
    ],

    // ========================================================================
    // 2. UTILIDADES DOM
    // ========================================================================
    dom: {
        val(id) {
            const el = document.getElementById(id);
            return el ? (el.value ?? '') : '';
        },
        setVal(id, value) {
            const el = document.getElementById(id);
            if (el) el.value = value ?? '';
        },
        getText(id) {
            const el = document.getElementById(id);
            return el ? el.textContent : '';
        },
        setText(id, text) {
            const el = document.getElementById(id);
            if (el) el.textContent = text ?? '';
        },
        show(id) {
            const el = document.getElementById(id);
            if (el) el.classList.remove('hidden');
        },
        hide(id) {
            const el = document.getElementById(id);
            if (el) el.classList.add('hidden');
        },
        setSelectVal(id, value) {
            const el = document.getElementById(id);
            if (el) el.value = value ?? '';
        },
        isVisible(id) {
            const el = document.getElementById(id);
            return el && !el.classList.contains('hidden');
        }
    },

    // ========================================================================
    // 3. VALIDACIÓN Y SANITIZACIÓN
    // ========================================================================
    security: {
        escapeHtml(str) {
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#x27;'
            };
            return String(str).replace(/[&<>"']/g, c => map[c]);
        },

        sanitizeText(str) {
            if (str === null || str === undefined) return '';
            return String(str)
                .replace(/[\x00]/g, '')
                .replace(/--/g, ' ')
                .replace(/\/\*/g, '')
                .replace(/\*\//g, '')
                .replace(/xp_/gi, '')
                .replace(/(DROP|DELETE|INSERT|UPDATE|EXEC|UNION|SELECT)\s/gi, '')
                .trim();
        },
        normalize(str) {
            return String(str)
                .normalize("NFD")
                .replace(/[\u0300-\u036f]/g, "")
                .toLowerCase()
                .trim();
        }
    },

    // ========================================================================
    // 4. NOTIFICACIONES (Toast + Field Errors)
    // ========================================================================
    notify: {
    showFieldError(field, message) {
        const container = field.closest('.form-field');
        if (!container) return;
        const error = container.querySelector('.field-error');
        if (!error) return;
        if (error.textContent === message) return;
        field.classList.add('input-error');
        error.textContent = message;
        error.classList.add('visible');
    },
    clearFieldError(field) {
        const container = field.closest('.form-field');
        if (!container) return;
        const error = container.querySelector('.field-error');
        if (!error) return;
        field.classList.remove('input-error');
        error.textContent = '';
        error.classList.remove('visible');
    },
    clearAllErrors(modalId){
        document
            .querySelectorAll(`#${modalId} .field-error`)
            .forEach(error=>{
                error.textContent='';
                error.classList.remove('visible');
            });
        document
            .querySelectorAll(`#${modalId} .input-error`)
            .forEach(input=>{
                input.classList.remove('input-error');
            });
    },
    showToast(message, type = 'success') {

        const toast = document.createElement('div');

        toast.className = `toast toast-${type}`;

        toast.textContent = message;

        document.body.appendChild(toast);

        setTimeout(() => {
            toast.classList.add('show');
        }, 10);

        setTimeout(() => {
            toast.remove();
        }, 3000);

    }


    },

    // ========================================================================
    //  validacion de los input -
    // ========================================================================
    validation:{
    // ---------- Métodos auxiliares genéricos ----------
    required(field, message) {
        if (field.value.trim() === '') {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    requiredSelect(field, message) {
        if (field.value === '' || field.value === '0' || field.selectedIndex === 0) {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    minLength(field, length, message) {
        if (field.value.trim().length < length) {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    maxLength(field, length, message) {
        if (field.value.trim().length > length) {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    email(field) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (field.value.trim() === '') {
            ClienteManager.notify.showFieldError(field, 'Ingrese el correo electrónico.');
            return false;
        }
        if (!regex.test(field.value.trim())) {
            ClienteManager.notify.showFieldError(field, 'Ingrese un correo válido.');
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    numeric(field, message) {
        if (!/^\d+$/.test(field.value.trim())) {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    positive(field, message) {
        if (Number(field.value) < 0) {
            ClienteManager.notify.showFieldError(field, message);
            return false;
        }
        ClienteManager.notify.clearFieldError(field);
        return true;
    },

    // ---------- Validaciones específicas (con prefijo) ----------
    validarTipoDocumento(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-id-tipo`);
        return this.requiredSelect(input, 'Seleccione el tipo de documento.');
    },

    validarTipoCliente(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-tipo-tercero`);
        return this.requiredSelect(input, 'Seleccione el tipo de cliente.');
    },

    validarCategoria(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cat-tercero`);
        return this.requiredSelect(input, 'Seleccione la categoría.');
    },

    validarNombre(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-nombre`);
        if (!this.required(input, 'Ingrese el nombre del cliente.')) return false;
        if (!this.minLength(input, 3, 'Debe contener mínimo 3 caracteres.')) return false;
        if (!this.maxLength(input, 150, 'No puede superar los 150 caracteres.')) return false;
        return true;
    },

    validarFechaNacimiento(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-fec-nac`);
        ClienteManager.notify.clearFieldError(input);
        if (input.value === '') return true;
        const fecha = new Date(input.value);
        if (isNaN(fecha.getTime())) {
            ClienteManager.notify.showFieldError(input, 'Fecha inválida.');
            return false;
        }
        return true;
    },

    validarGenero(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-genero`);
        return this.requiredSelect(input, 'Seleccione el género.');
    },

    validarPrefijo(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-prefijo-movil`);
        return this.requiredSelect(input, 'Seleccione el prefijo.');
    },

    validarCelular(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-tel-movil`);
        if (!this.required(input, 'Ingrese el número celular.')) return false;
        if (!this.numeric(input, 'El celular debe contener solo números.')) return false;
        const numero = input.value.trim();
        if (numero.length < 7 || numero.length > 15) {
            ClienteManager.notify.showFieldError(input, 'Número celular inválido (7-15 dígitos).');
            return false;
        }
        return true;
    },

    validarTelefono(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-tel-fijo`);
        ClienteManager.notify.clearFieldError(input);
        const numero = input.value.trim();
        if (numero === '') return true;
        if (!/^[0-9]{7,15}$/.test(numero)) {
            ClienteManager.notify.showFieldError(input, 'Número telefónico inválido (7-15 dígitos).');
            return false;
        }
        return true;
    },

    validarEmail(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-email`);
        ClienteManager.notify.clearFieldError(input);
        const correo = input.value.trim();
        if (correo === '') return true;
        return this.email(input);
    },

    validarDireccion(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-direccion`);
        if (!this.required(input, 'Ingrese la dirección.')) return false;
        if (!this.minLength(input, 5, 'La dirección es demasiado corta.')) return false;
        return true;
    },

    validarCiudad(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-ciudad`);
        return this.requiredSelect(input, 'Seleccione la ciudad.');
    },

    validarRestriccion(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-restriccion`);
        return this.requiredSelect(input, 'Seleccione la restricción.');
    },

    validarPuntos(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-puntos`);
        ClienteManager.notify.clearFieldError(input);
        const valor = parseInt(input.value || 0);
        if (isNaN(valor) || valor < 0) {
            ClienteManager.notify.showFieldError(input, 'Los puntos no pueden ser negativos.');
            return false;
        }
        return true;
    },

    validarEstado(prefijo = 'edit') {
        const input = document.getElementById(`${prefijo}-cliente-estado`);
        return this.requiredSelect(input, 'Seleccione el estado.');
    },

    validarCupo(prefijo = 'edit') {
        const creditoHidden = document.getElementById(`${prefijo}-credito-hidden`);
        const credito = creditoHidden ? creditoHidden.value === 'true' : true;
        if (!credito) return true;
        const input = document.getElementById(`${prefijo}-cliente-cupo`);
        ClienteManager.notify.clearFieldError(input);
        const valor = parseFloat(input.value);
        if (isNaN(valor) || valor <= 0) {
            ClienteManager.notify.showFieldError(input, 'Ingrese un cupo válido (mayor a 0).');
            return false;
        }
        return true;
    },

    validarDiasCartera(prefijo = 'edit') {
        const creditoHidden = document.getElementById(`${prefijo}-credito-hidden`);
        const credito = creditoHidden ? creditoHidden.value === 'true' : true;
        if (!credito) return true;
        const input = document.getElementById(`${prefijo}-cliente-diascartera`);
        ClienteManager.notify.clearFieldError(input);
        const valor = parseInt(input.value);
        if (isNaN(valor) || valor <= 0) {
            ClienteManager.notify.showFieldError(input, 'Ingrese los días de cartera (mayor a 0).');
            return false;
        }
        return true;
    },   
           bindLiveValidation() {
        ClienteManager.rules.forEach(rule => {
            const input = document.getElementById(rule.id);
            if (input) {
                input.addEventListener(rule.event, rule.fn);
            }
        });
    },

 validarFormularioNuevo() {

    ClienteManager.notify.clearAllErrors('modal-new-cliente');

    const validaciones = [

        { tab:'general', fn:()=>this.validarTipoDocumento('new') },
        { tab:'general', fn:()=>this.validarTipoCliente('new') },
        { tab:'general', fn:()=>this.validarCategoria('new') },
        { tab:'general', fn:()=>this.validarNombre('new') },
        { tab:'general', fn:()=>this.validarFechaNacimiento('new') },
        { tab:'general', fn:()=>this.validarGenero('new') },

        { tab:'contacto', fn:()=>this.validarPrefijo('new') },
        { tab:'contacto', fn:()=>this.validarCelular('new') },
        { tab:'contacto', fn:()=>this.validarTelefono('new') },
        { tab:'contacto', fn:()=>this.validarEmail('new') },
        { tab:'contacto', fn:()=>this.validarDireccion('new') },
        { tab:'contacto', fn:()=>this.validarCiudad('new') },

        { tab:'comercial', fn:()=>this.validarRestriccion('new') },
        { tab:'comercial', fn:()=>this.validarPuntos('new') },
        { tab:'comercial', fn:()=>this.validarEstado('new') },
        { tab:'comercial', fn:()=>this.validarCupo('new') },
        { tab:'comercial', fn:()=>this.validarDiasCartera('new') }

    ];

    for (const validacion of validaciones) {

        if (!validacion.fn()) {

            ClienteManager.changeNewTab(validacion.tab);

            return false;

        }

    }

    return true;

},
            validarFormularioEditar() {
                ClienteManager.notify.clearAllErrors('modal-edit-cliente');
                const validaciones = [
                    // GENERAL
                {
                    tab: 'general',
                    fn: () => this.validarTipoDocumento()
                },
                {
                    tab: 'general',
                    fn: () => this.validarTipoCliente()
                },
                {
                    tab: 'general',
                    fn: () => this.validarCategoria()
                },
                {
                    tab: 'general',
                    fn: () => this.validarNombre()
                },
                {
                    tab: 'general',
                    fn: () => this.validarFechaNacimiento()
                },
                {
                    tab: 'general',
                    fn: () => this.validarGenero()
                },
                // CONTACTO
                {
                    tab: 'contacto',
                    fn: () => this.validarPrefijo()
                },
                {
                    tab: 'contacto',
                    fn: () => this.validarCelular()
                },
                {
                    tab: 'contacto',
                    fn: () => this.validarTelefono()
                },
                {
                    tab: 'contacto',
                    fn: () => this.validarEmail()
                },
                {
                    tab: 'contacto',
                    fn: () => this.validarDireccion()
                },
                {
                    tab: 'contacto',
                    fn: () => this.validarCiudad()
                },
                // COMERCIAL
                {
                    tab: 'comercial',
                    fn: () => this.validarRestriccion()
                },
                {
                    tab: 'comercial',
                    fn: () => this.validarPuntos()
                },
                {
                    tab: 'comercial',
                    fn: () => this.validarEstado()
                },
                {
                    tab: 'comercial',
                    fn: () => this.validarCupo()
                },
                {
                    tab: 'comercial',
                    fn: () => this.validarDiasCartera()
                }
            ];
            for (const validacion of validaciones) {
                if (!validacion.fn()) {
                    ClienteManager.changeEditTab(validacion.tab);
                    return false;
                }
            }
            return true;
        },                   
            required(field, message){

                if(field.value.trim() === ''){

                    ClienteManager.notify.showFieldError(field, message);
                    return false;

                }

                ClienteManager.notify.clearFieldError(field);
                return true;

            },

            requiredSelect(field, message){

                if(
                    field.value === '' ||
                    field.value === '0' ||
                    field.selectedIndex === 0
                ){

                    ClienteManager.notify.showFieldError(field, message);
                    return false;

                }

                ClienteManager.notify.clearFieldError(field);
                return true;

            },            

            minLength(field, length, message){

                if(field.value.trim().length < length){

                    ClienteManager.notify.showFieldError(field, message);
                    return false;

                }

                ClienteManager.notify.clearFieldError(field);
                return true;

            },
    maxLength(){},

            email(field){

                const regex =
                /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

                if(field.value.trim()===''){

                    ClienteManager.notify.showFieldError(
                        field,
                        'Ingrese el correo electrónico.'
                    );

                    return false;

                }

                if(!regex.test(field.value.trim())){

                    ClienteManager.notify.showFieldError(
                        field,
                        'Ingrese un correo válido.'
                    );

                    return false;

                }

                ClienteManager.notify.clearFieldError(field);

                return true;

            },

    phone(){},

            numeric(field, message){

                if(!/^\d+$/.test(field.value.trim())){

                    ClienteManager.notify.showFieldError(field, message);
                    return false;

                }

                ClienteManager.notify.clearFieldError(field);
                return true;

            },

            positive(field, message){

                if(Number(field.value) < 0){

                    ClienteManager.notify.showFieldError(
                        field,
                        message
                    );

                    return false;

                }

                ClienteManager.notify.clearFieldError(field);

                return true;

            },

    date(){},

            validarGenero(){

                const input=document.getElementById('edit-cliente-genero');

                ClienteManager.notify.clearFieldError(input);

                if(input.value===''){

                    ClienteManager.notify.showFieldError(
                        input,
                        'Seleccione el género.'
                    );

                    return false;

                }

                return true;

            },


},

            
//CAMBIAR PESTAÑA DEL MODAL EDITAR
            changeEditTab(tab) {
                document
                    .querySelectorAll('#modal-edit-cliente .detail-tab')
                    .forEach(btn => {
                        btn.classList.toggle(
                            'active',
                            btn.dataset.editTab === tab
                        );
                    });
                document
                    .querySelectorAll('#modal-edit-cliente .edit-section')
                    .forEach(section => {
                        section.classList.toggle(
                            'active',
                            section.id === `edit-${tab}`
                        );
                    });
            },

    // ========================================================================
    // 5. MODALES - Ciclo de vida claro
    // ========================================================================
    modals: {
        openNew() {
            const form = document.getElementById('new-cliente-form');
            if (form) form.reset();
            ClienteManager.notify.clearAllErrors('modal-new-cliente');
            ClienteManager.dom.show('modal-new-cliente');
            document.getElementById('new-cliente-id')?.focus();
        },

        closeNew() {
            ClienteManager.dom.hide('modal-new-cliente');
        },

        openEdit(id) {
            const cliente = clientesData.find(c => c.id_cliente === id);
            if (!cliente) {
                ClienteManager.notify.showToast('Cliente no encontrado', 'error');
                return;
            }

            ClienteManager.state.currentEditId = id;
            ClienteManager.notify.clearAllErrors('modal-edit-cliente');
            ClienteManager._populateEditForm(cliente);
            ClienteManager.dom.show('modal-edit-cliente');
        },

        closeEdit() {
            ClienteManager.dom.hide('modal-edit-cliente');
            ClienteManager.state.currentEditId = null;
        },

        openDetail(id) {
            const cliente = clientesData.find(c => c.id_cliente === id);
            if (!cliente) {
                ClienteManager.notify.showToast('Cliente no encontrado', 'error');
                return;
            }

            // PESTAÑA DE DETALLE
                        document.querySelectorAll('.detail-tab')
                .forEach(t => t.classList.remove('active'));

            document.querySelectorAll('.detail-section')
                .forEach(s => s.classList.remove('active'));

            document.querySelector('[data-tab="general"]')
                ?.classList.add('active');

            document.getElementById('detail-general')
                ?.classList.add('active');

                // CIERRE DE PESTALAL DE DETALLE
            ClienteManager._populateDetailModal(cliente);
            ClienteManager.dom.show('modal-detail');


            
        },

        closeDetail() {
            ClienteManager.dom.hide('modal-detail');
        },

        openConfirmDelete(id) {
            const cliente = clientesData.find(c => c.id_cliente === id);
            if (!cliente) {
                ClienteManager.notify.showToast('Cliente no encontrado', 'error');
                return;
            }

            ClienteManager.state.pendingDeleteId = id;
            ClienteManager.dom.setText('confirm-message', 
                `¿Deseas eliminar al cliente "${ClienteManager.security.escapeHtml(cliente.nom_tercero)}"?`);
            ClienteManager.dom.show('modal-confirm');
        },

        closeConfirm() {
            ClienteManager.dom.hide('modal-confirm');
            ClienteManager.state.pendingDeleteId = null;
        }
    },
    initEditTabs() {
    const tabs = document.querySelectorAll('#modal-edit-cliente .detail-tab');

    const sections = document.querySelectorAll('#modal-edit-cliente .edit-section');

    tabs.forEach(tab => {

        tab.addEventListener('click', () => {

            tabs.forEach(t => t.classList.remove('active'));

            sections.forEach(s => s.classList.remove('active'));

            tab.classList.add('active');

            document
                .getElementById('edit-' + tab.dataset.editTab)
                .classList.add('active');

        });

    });

},


    // ========================================================================
    // modal de nuevo
    // ========================================================================
    changeNewTab(tab) {

    document
        .querySelectorAll('#modal-new-cliente .detail-tab')
        .forEach(btn => {

            btn.classList.toggle(
                'active',
                btn.dataset.newTab === tab
            );

        });

    document
        .querySelectorAll('#modal-new-cliente .edit-section')
        .forEach(section => {

            section.classList.toggle(
                'active',
                section.id === `new-${tab}`
            );

        });

},

initNewTabs(){

    const tabs=document.querySelectorAll(
        '#modal-new-cliente .detail-tab'
    );

    const sections=document.querySelectorAll(
        '#modal-new-cliente .edit-section'
    );

    tabs.forEach(tab=>{

        tab.addEventListener('click',()=>{

            tabs.forEach(t=>t.classList.remove('active'));

            sections.forEach(s=>s.classList.remove('active'));

            tab.classList.add('active');

            document
                .getElementById(
                    'new-'+tab.dataset.newTab
                )
                .classList.add('active');

        });

    });

},
updateNewNombreLabel(){

    const tipo=document.getElementById(
        'new-tipo-tercero'
    );

    const label=document.getElementById(
        'lbl-new-nombre'
    );

    if(!tipo || !label) return;

    label.textContent=

        tipo.value==='true'

        ? 'Razón Social'

        : 'Nombre Completo';

},
clearNewForm(){

    const form=document.getElementById(
        'new-cliente-form'
    );

    if(form){

        form.reset();

    }

    this.notify.clearAllErrors(
        'modal-new-cliente'
    );

    this.changeNewTab('general');

    this.updateNewNombreLabel();

    this._setToggleState(

        'new-credito-switch',

        'new-credito-hidden',

        false

    );

    document.getElementById(
        'new-cliente-cupo'
    ).disabled=true;

    document.getElementById(
        'new-cliente-diascartera'
    ).disabled=true;

},
    // ========================================================================
    // 6. LLENADO DE FORMULARIOS
    // ========================================================================
    _populateEditForm(cliente) {
        ClienteManager.dom.setVal('hid-edit-id-cliente', cliente.id_cliente);
        ClienteManager.dom.setSelectVal('edit-id-tipo', cliente.id_tipo ?? '');
        ClienteManager.dom.setVal('edit-cliente-id', cliente.id_cliente);
        ClienteManager.dom.setSelectVal('edit-cat-tercero', cliente.id_cat_tercero ?? '');
        ClienteManager.dom.setSelectVal('edit-tipo-tercero', cliente.ind_tipo_tercero ? 'true' : 'false');
        // Actualizar el texto del label
        ClienteManager.updateNombreLabel();
        ClienteManager.dom.setVal('edit-cliente-nombre', cliente.nom_tercero ?? '');
        ClienteManager.dom.setSelectVal('edit-prefijo-movil', cliente.id_prefijo_movil ?? '');
        ClienteManager.dom.setVal('edit-cliente-tel-movil', cliente.tel_movil ?? '');
        ClienteManager.dom.setVal('edit-cliente-tel-fijo', cliente.tel_fijo ?? '');
        ClienteManager.dom.setVal('edit-cliente-email', cliente.email ?? '');
        ClienteManager.dom.setVal('edit-cliente-direccion', cliente.direccion ?? '');
        ClienteManager.dom.setSelectVal('edit-cliente-ciudad', cliente.id_ciudad ?? '');
        ClienteManager.dom.setSelectVal('edit-cliente-restriccion', cliente.id_restriccion ?? '');
        ClienteManager.dom.setVal('edit-cliente-fec-nac', cliente.fec_nacimi ?? '');
        ClienteManager.dom.setSelectVal('edit-cliente-genero', cliente.ind_genero ?? 'F');
        ClienteManager.dom.setVal('edit-cliente-puntos', cliente.val_puntos ?? 0);
        ClienteManager.dom.setSelectVal('edit-cliente-estado', cliente.ind_estado_cliente ? 'true' : 'false');

        // Toggle de crédito
        const tieneCredito = cliente.ind_credito === true || cliente.ind_credito === 'true';
        ClienteManager._setToggleState('edit-credito-switch', 'edit-credito-hidden', tieneCredito);
        const cupo = document.getElementById('edit-cliente-cupo');
const dias = document.getElementById('edit-cliente-diascartera');

if (cupo) {
    cupo.disabled = !tieneCredito;
}

if (dias) {
    dias.disabled = !tieneCredito;
}ClienteManager.dom.setVal('edit-cliente-cupo', cliente.val_cupocredito ?? 0);
        ClienteManager.dom.setVal('edit-cliente-diascartera', cliente.val_diascartera ?? 0);
    },
    

    _populateDetailModal(cliente) {
        const estado = cliente.ind_estado_cliente ? 'Activo' : 'Inactivo';
        const tieneCredito = cliente.ind_credito ? 'Sí' : 'No';
        const generos = { 'F': 'Femenino', 'M': 'Masculino', 'NB': 'No binario', 'T': 'Transgénero' };
        const general=document.getElementById('detail-general');
        const contacto=document.getElementById('detail-contacto');
        const comercial=document.getElementById('detail-comercial');

        const generalHtml = `
            <div class="detail-item">
                <div class="label">Identificación</div>
                <div class="value">${ClienteManager.security.escapeHtml(cliente.id_cliente)}</div>
            </div>

            <div class="detail-item">
                <div class="label">Nombre</div>
                <div class="value">${ClienteManager.security.escapeHtml(cliente.nom_tercero)}</div>
            </div>

            <div class="detail-item">
                <div class="label">Tipo de Cliente</div>
                <div class="value">${cliente.tipo_cliente || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Tipo Identificación</div>
                <div class="value">${cliente.nom_tipo || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Categoría</div>
                <div class="value">${cliente.nom_categoria || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Ciudad</div>
                <div class="value">${cliente.nom_ciudad || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Fecha Nacimiento</div>
                <div class="value">${cliente.fec_nacimi || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Género</div>
                <div class="value">${generos[cliente.ind_genero] || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Estado</div>
                <div class="value">
                    <span class="badge ${cliente.ind_estado_cliente ? 'badge-success' : 'badge-danger'}">
                        ${estado}
                    </span>
                </div>
            </div>
            `;
        const contactoHtml = `
            <div class="detail-item">
                <div class="label">Correo Electrónico</div>
                <div class="value">${cliente.email || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Celular</div>
                <div class="value">${cliente.tel_movil || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Teléfono Fijo</div>
                <div class="value">${cliente.tel_fijo || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Dirección</div>
                <div class="value">${cliente.direccion || 'N/A'}</div>
            </div>

            <div class="detail-item">
                <div class="label">Ciudad</div>
                <div class="value">${cliente.nom_ciudad || 'N/A'}</div>
            </div>
            `;
        const comercialHtml = `
            <div class="detail-item">
                <div class="label">Crédito</div>
                <div class="value">${tieneCredito}</div>
            </div>

            <div class="detail-item">
                <div class="label">Cupo de Crédito</div>
                <div class="value">
                    $${Number(cliente.val_cupocredito || 0).toLocaleString('es-CO')}
                </div>
            </div>

            <div class="detail-item">
                <div class="label">Días de Cartera</div>
                <div class="value">${cliente.val_diascartera || 0}</div>
            </div>

            <div class="detail-item">
                <div class="label">Puntos</div>
                <div class="value">${cliente.val_puntos || 0}</div>
            </div>

            <div class="detail-item">
                <div class="label">Restricción</div>
                <div class="value">${cliente.nom_restriccion || 'Ninguna'}</div>
            </div>
            `;
                    
            if (general) general.innerHTML = generalHtml;
            if (contacto) contacto.innerHTML = contactoHtml;
            if (comercial) comercial.innerHTML = comercialHtml;
    },

_setToggleState(toggleId, hiddenId, isOn) {

    const toggle = document.getElementById(toggleId);
    const hidden = document.getElementById(hiddenId);

    if (!toggle) return;

    toggle.classList.toggle("on", isOn);

    const span = toggle.querySelector("span");

    if (span) {
        span.textContent = isOn ? "Sí" : "No";
    }

    if (hidden) {
        hidden.value = isOn ? "true" : "false";
    }

},

    // ========================================================================
    // 7. ESTADÍSTICAS Y FILTROS
    // ========================================================================
    stats: {
        update(data) {
            const total = data.length;
            const activos = data.filter(c => c.ind_estado_cliente).length;
            const conCredito = data.filter(c => c.ind_credito).length;   
            const cupoTotal = data.reduce((s,c)=> s + (c.ind_credito ? Number(c.val_cupocredito) : 0) ,0);

            ClienteManager.dom.setText('stat-total', total);
            ClienteManager.dom.setText('stat-activos', activos);
            ClienteManager.dom.setText('stat-credito', conCredito);
            ClienteManager.dom.setText('stat-cupo', '$' + cupoTotal.toLocaleString('es-CO'));
        }
    },

    filters: {
        apply() {
            const texto = ClienteManager.security.normalize(
                ClienteManager.security.sanitizeText(
                    document.getElementById('cliente-search')?.value || ''
                )
            );

            const filtro = document.querySelector('.filter-toggle.active')?.dataset.filter || 'all';

            const filas = document.querySelectorAll('#clientes-tbody tr:not(.empty-row)');

            let visibles = 0;

            filas.forEach((fila, index) => {

                const cliente = clientesData[index];

                if (!cliente) return;

                const pasaBusqueda =
                    !texto || ClienteManager.security
                                .normalize(cliente.search)
                                .includes(texto);

                let pasaEstado = true;

                if (filtro === 'active')
                    pasaEstado = cliente.ind_estado_cliente;

                if (filtro === 'inactive')
                    pasaEstado = !cliente.ind_estado_cliente;

                fila.style.display =
                    pasaBusqueda && pasaEstado
                        ? ''
                        : 'none';

                if (pasaBusqueda && pasaEstado)
                    visibles++;

            });

            ClienteManager.dom.setText(
                'clientes-count',
                `${visibles} resultado${visibles !== 1 ? 's' : ''}`
            );

            document.getElementById('btn-clear-filters').style.display =
                (texto || filtro !== 'all')
                    ? 'flex'
                    : 'none';
        },

        clear() {
            const input = document.getElementById('cliente-search');
            if (input) input.value = '';
            document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
            document.querySelector('.filter-toggle[data-filter="all"]')?.classList.add('active');
            document.querySelectorAll('#clientes-tbody tr:not(.empty-row)')
                .forEach(fila => fila.style.display = '');

            const btnClear = document.getElementById('btn-clear-filters');
            if (btnClear) btnClear.style.display = 'none';

            ClienteManager.dom.setText('clientes-count', 
                `${clientesData.length} resultado${clientesData.length !== 1 ? 's' : ''}`);
        }
    },

    // ========================================================================
    // 8. ACCIONES AJAX (CRUD)
    // ========================================================================
    ajax: {
        async submit(formId, modalId) {
            const form = document.getElementById(formId);
            if (!form) return;

            const btn = form.querySelector('button[type="submit"]');
            if (!btn || ClienteManager.state.isSubmitting) return;

            ClienteManager.state.isSubmitting = true;
            btn.disabled = true;
            const originalHtml = btn.innerHTML;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';

            try {
                const formData = new FormData(form);
                const response = await fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                let result;

                try {
                    result = JSON.parse(text);
                } catch {
                    result = { success: false, message: 'Respuesta inválida del servidor' };
                }

                if (result.success) {
                    ClienteManager.notify.showToast(result.message || 'Operación exitosa', 'success');
                    if (modalId === 'modal-new-cliente') ClienteManager.modals.closeNew();
                    if (modalId === 'modal-edit-cliente') ClienteManager.modals.closeEdit();
                    setTimeout(() => {
                        window.location.href = window.location.href.split('?')[0] + '?t=' + Date.now();
                    }, 1500);
                } else {
                    if (result.errors && typeof result.errors === 'object') {
                        Object.entries(result.errors).forEach(([campo, mensaje]) => {
                            const input = document.getElementById(campo);
                            if (input) {
                                ClienteManager.notify.showFieldError(input, mensaje);
                            }
                        });
                    } else {
                            ClienteManager.notify.showToast(
                                    result.message || 'Error en la operación',
                                    'error'
                                );                    }
                }
            } catch (error) {
                console.error('AJAX Error:', error);
                ClienteManager.notify.showToast('Error de conexión con el servidor', 'error');
            } finally {
                ClienteManager.state.isSubmitting = false;
                btn.disabled = false;
                btn.innerHTML = originalHtml;
            }
        },

        async delete(id) {
            if (!id) return;

            const form = document.createElement('form');
            form.method = 'POST';
            form.innerHTML = `<input type="hidden" name="btn_eliminar" value="1">
                             <input type="hidden" name="txt_id_cliente" value="${ClienteManager.security.escapeHtml(id)}">`;

            const btn = document.createElement('button');
            btn.type = 'submit';

            form.appendChild(btn);
            document.body.appendChild(form);

            const originalBtnDelete = Array.from(document.querySelectorAll('.btn-table-delete'))
                .find(b => b.dataset.id === id);
            if (originalBtnDelete) {
                const originalHtml = originalBtnDelete.innerHTML;
                originalBtnDelete.disabled = true;
                originalBtnDelete.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

                try {
                    const response = await fetch(window.location.href, {
                        method: 'POST',
                        body: new FormData(form)
                    });

                    const text = await response.text();
                    let result;

                    try {
                        result = JSON.parse(text);
                    } catch {
                        result = { success: false, message: 'Respuesta inválida' };
                    }

                    if (result.success) {
                        ClienteManager.notify.showToast('Cliente eliminado correctamente', 'success');
                        ClienteManager.modals.closeConfirm();
                        setTimeout(() => {
                            window.location.href = window.location.href.split('?')[0] + '?t=' + Date.now();
                        }, 1500);
                    } else {
                        ClienteManager.notify.showToast(result.message || 'Error al eliminar', 'error');
                        originalBtnDelete.disabled = false;
                        originalBtnDelete.innerHTML = originalHtml;
                    }
                } catch (error) {
                    console.error('Delete Error:', error);
                    ClienteManager.notify.showToast('Error de conexión', 'error');
                    originalBtnDelete.disabled = false;
                    originalBtnDelete.innerHTML = originalHtml;
                }
            }

            document.body.removeChild(form);
        }
    },

    // ========================================================================
    // 9. EVENT LISTENERS
    // ========================================================================

    
    bindEvents() {
        // Toggle crédito (Editar)
        document.getElementById('edit-credito-switch')?.addEventListener('click', function() {
            const isOn = !this.classList.contains('on');
            ClienteManager._setToggleState('edit-credito-switch', 'edit-credito-hidden', isOn);
            const cupo = document.getElementById('edit-cliente-cupo');
const dias = document.getElementById('edit-cliente-diascartera');

if (cupo) {
    cupo.disabled = !isOn;
}

if (dias) {
    dias.disabled = !isOn;
}document.getElementById('edit-cliente-diascartera').disabled = !isOn;
            if (!isOn) {
                ClienteManager.dom.setVal('edit-cliente-cupo', 0);
                ClienteManager.dom.setVal('edit-cliente-diascartera', 0);
            }
        });



        // Confirmación de eliminación
        document.getElementById('confirm-ok-btn')?.addEventListener('click', () => {
            if (this.state.pendingDeleteId) {
                this.ajax.delete(this.state.pendingDeleteId);
            }
        });

        // Cerrar modales
        document.querySelectorAll('.btn-close-new-modal, .btn-cancel-new-modal').forEach(b => 
            b.addEventListener('click', () => this.modals.closeNew()));
        document.querySelectorAll('.btn-close-edit-modal, .btn-cancel-edit-modal').forEach(b => 
            b.addEventListener('click', () => this.modals.closeEdit()));
        document.querySelectorAll('.btn-close-detail-modal, .btn-cancel-detail-modal').forEach(b => 
            b.addEventListener('click', () => this.modals.closeDetail()));
        document.getElementById('confirm-cancel-btn')?.addEventListener('click', 
            () => this.modals.closeConfirm());

        // Cerrar modales con overlay
        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', (e) => {
                if (e.target === overlay) {
                    if (overlay.id === 'modal-new-cliente') this.modals.closeNew();
                    else if (overlay.id === 'modal-edit-cliente') this.modals.closeEdit();
                    else if (overlay.id === 'modal-detail') this.modals.closeDetail();
                    else if (overlay.id === 'modal-confirm') this.modals.closeConfirm();
                }
            });
        });

        // Filtros
        document.getElementById('cliente-search')?.addEventListener('input', 
            () => this.filters.apply());
        document.querySelectorAll('.filter-toggle').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.filter-toggle').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                ClienteManager.filters.apply();
            });
        });
        document.getElementById('btn-clear-filters')?.addEventListener('click', 
            () => this.filters.clear());

        // Delegación de eventos para botones de tabla (Editar, Detalle, Eliminar)
        document.getElementById('clientes-tbody')?.addEventListener('click', (e) => {
            const target = e.target.closest('[data-id]');
            if (!target) return;

            const id = target.dataset.id;
            if (e.target.closest('.btn-table-edit')) this.modals.openEdit(id);
            else if (e.target.closest('.btn-table-detail')) this.modals.openDetail(id);
            else if (e.target.closest('.btn-table-delete')) this.modals.openConfirmDelete(id);
        });
        // PESTAÑA DE DETALLE
        document.querySelectorAll('.detail-tab').forEach(tab => {

            tab.addEventListener('click', function () {

                document.querySelectorAll('.detail-tab')
                    .forEach(t => t.classList.remove('active'));

                document.querySelectorAll('.detail-section')
                    .forEach(s => s.classList.remove('active'));

                this.classList.add('active');

                const destino = document.getElementById(
                    'detail-' + this.dataset.tab
                );

                if (destino) {
                    destino.classList.add('active');
                }

            });

        });

        // PESTAÑA EDITAR
        document.querySelectorAll('#modal-edit-cliente .detail-tab').forEach(tab => {

            tab.addEventListener('click', function () {

                document.querySelectorAll('#modal-edit-cliente .detail-tab')
                    .forEach(t => t.classList.remove('active'));

                document.querySelectorAll('#modal-edit-cliente .detail-section')
                    .forEach(s => s.classList.remove('active'));

                this.classList.add('active');

                const destino = document.getElementById(
                    'edit-' + this.dataset.editTab
                );

                if (destino) {
                    destino.classList.add('active');
                }

            });

        });
        // tipo de cliente
        const tipoCliente = document.getElementById('edit-tipo-tercero');
            if (tipoCliente) {
                tipoCliente.addEventListener('change', () => {
                    this.updateNombreLabel();
                });
            }

            document.getElementById('edit-cliente-form')?.addEventListener('submit', (e) => {
                e.preventDefault();
                if (!this.validation.validarFormularioEditar()) {
                    return;
                }
                this.ajax.submit(
                    'edit-cliente-form',
                    'modal-edit-cliente'
                );
            });
            // modal de nuevo
        document.getElementById('new-cliente-form')?.addEventListener('submit', (e) => {
         e.preventDefault();
            if (!this.validation.validarFormularioNuevo()) {
        return;
            }
        this.ajax.submit(
        'new-cliente-form',
        'modal-new-cliente'
        );
         });
            // Abrir modal nuevo

document
.getElementById('btn-add-cliente')
?.addEventListener('click',()=>{

    this.clearNewForm();

    this.modals.openNew();

});


// Cambiar Nombre / Razón Social

document
.getElementById('new-tipo-tercero')
?.addEventListener('change',()=>{

    this.updateNewNombreLabel();

});


// Toggle Crédito

document.getElementById('new-credito-switch')?.addEventListener('click', () => {

    const hidden = document.getElementById('new-credito-hidden');

    const activo = hidden.value !== 'true';

    ClienteManager._setToggleState(
        'new-credito-switch',
        'new-credito-hidden',
        activo
    );

    const cupo = document.getElementById('new-cliente-cupo');
    const dias = document.getElementById('new-cliente-diascartera');

    if (cupo) {
        cupo.disabled = !activo;
        if (!activo) cupo.value = 0;
    }

    if (dias) {
        dias.disabled = !activo;
        if (!activo) dias.value = 0;
    }

});
    },

    // ========================================================================
// ACTUALIZAR LABEL SEGÚN TIPO DE CLIENTE
// ========================================================================
updateNombreLabel() {

    const tipo = document.getElementById('edit-tipo-tercero');
    const label = document.getElementById('lbl-edit-nombre');

    if (!tipo || !label) return;

    label.textContent =
        tipo.value === 'true'
            ? 'Razón Social'
            : 'Nombre Completo';

},

    // ========================================================================
    // 10. INICIALIZACIÓN
    // ========================================================================
    init() {
        this.bindEvents();
        this.initEditTabs();
        this.initNewTabs();
        this.validation.bindLiveValidation();
        this.stats.update(clientesData);
        this.dom.setText('clientes-count', 
            `${clientesData.length} resultado${clientesData.length !== 1 ? 's' : ''}`);

          const modal = document.getElementById("modal-edit-cliente");
const body = modal.querySelector(".modal-body");

body.addEventListener("scroll", () => {

    modal.classList.toggle(
        "compact",
        body.scrollTop > 20
    );

});  
       
    }
};

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => ClienteManager.init());


