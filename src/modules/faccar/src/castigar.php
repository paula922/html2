<?php
// ==================================================
// Módulo: Castigar Cartera (ERP ADSO)
// Tabla: tab_carteras (cuentas incobrables)
// ==================================================

$pageTitle    = 'ERP ADSO — Castigar Cartera';
$activeModule = 'castigar_cartera';
$page_title   = 'ADSOERP | Castigar Cartera';
$page_description = 'Cuentas con mora superior al límite configurado, candidatas a castigo';
$page_icon    = 'bi-exclamation-octagon';
$page_extra_css = ["../modules/faccar/css/castigar.css"];
$page_extra_js  = ["../modules/faccar/js/castigar.js"];
$show_welcome   = false;

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

ob_start();
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<div id="mod-castigarcartera" class="app-view active">
    <!-- Encabezado -->
    <div class="page-header">
        <div>
            <div class="page-title">Castigar Cartera</div>
            <div class="page-subtitle">Cuentas con mora superior al límite configurado por la empresa</div>
        </div>
    </div>

    <div class="alerta-umbral">
        <i class="fas fa-circle-info"></i>
        <span>Días máximo de cartera configurados en Parámetros: </span>
        <input type="text" inputmode="numeric" id="umbral-dias" class="umbral-input" value="180">
        <span>días. Las cuotas vencidas por más tiempo aparecen como candidatas a castigo.</span>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="stats-grid-3">
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-triangle-exclamation"></i></div>
            <div>
                <div class="stat-label">Candidatas a Castigo</div>
                <div class="stat-value" id="stat-cas-candidatas">0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="fas fa-sack-dollar"></i></div>
            <div>
                <div class="stat-label">Valor en Riesgo</div>
                <div class="stat-value" id="stat-cas-valor" style="font-size:18px;">$0</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="fas fa-ban"></i></div>
            <div>
                <div class="stat-label">Ya Castigadas</div>
                <div class="stat-value" id="stat-cas-castigadas">0</div>
            </div>
        </div>
    </div>

    <!-- Filtros y acción masiva -->
    <div class="filters-bar">
        <div class="search-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" id="cas-search" placeholder="Buscar por factura o cliente...">
        </div>
        <span class="filter-info" id="cas-count">0 resultados</span>
        <button id="btn-castigar-sel" class="btn-eliminar" style="border-radius:30px; padding:9px 18px; display:flex; align-items:center; gap:8px;" disabled>
            <i class="fas fa-ban"></i> Castigar Seleccionadas (<span id="cas-sel-count">0</span>)
        </button>
    </div>

    <!-- Tabla -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th width="40"><input type="checkbox" id="cas-check-all"></th>
                    <th width="100">Factura</th>
                    <th>Cliente</th>
                    <th width="100">Pendiente</th>
                    <th width="100">Próx. Pago</th>
                    <th width="90">Días Mora</th>
                    <th width="100">Estado</th>
                </tr>
            </thead>
            <tbody id="cas-tbody">
                <tr><td colspan="7">
                    <div class="empty-state">
                        <i class="fas fa-circle-check"></i>
                        <p>Sin cuentas candidatas a castigo</p>
                        <span>No hay cuotas vencidas por encima del límite configurado</span>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL CONFIRMACIÓN -->
<div id="modal-confirm" class="modal-overlay hidden">
    <div class="modal-container confirm-box">
        <div class="confirm-icon"><i class="fas fa-exclamation-triangle"></i></div>
        <h4 id="confirm-title"></h4>
        <p id="confirm-body"></p>
        <div class="confirm-buttons">
            <button class="btn-cancelar" id="confirm-cancel-btn">Cancelar</button>
            <button class="btn-eliminar" id="confirm-ok-btn">Confirmar</button>
        </div>
    </div>
</div>

<!-- TOAST -->
<div id="toast" class="toast hidden">
    <i class="fas fa-check-circle"></i>
    <span id="toast-message"></span>
</div>

<?php
$moduleContent = ob_get_clean();
echo $moduleContent;
?>
