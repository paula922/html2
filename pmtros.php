<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title       = "ADSOERP | Parámetros Generales";
$page_description = "Configuración de la empresa (NIT, ubicación, parámetros financieros)";
$page_icon        = "bi-building-gear";
$page_extra_css   = [];
$page_extra_js    = [];
$show_welcome     = false;
// ==========================================

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

$w_mensaje     = "";
$w_tipo_alerta = "success";

$stmt_get_empresa_detalle->execute();
$empresa = $stmt_get_empresa_detalle->fetch();

$es_autorete = isset($empresa['ind_autorete']) && in_array($empresa['ind_autorete'], [true, 't', '1', 1], true);

$anio_actual = date('Y');
$mes_actual  = date('m');
$nombre_mes  = ucfirst(strftime('%B', strtotime("$anio_actual-$mes_actual-01")));

// Completitud del perfil (solo campos que existen en la tabla)
$campos_completitud = [
    !empty($empresa['id_empresa']),
    !empty($empresa['nom_empresa']),
    !empty($empresa['nom_replegal']),
    !empty($empresa['barrio']),
    !empty($empresa['direccion']),
    !empty($empresa['tel_fijo']),
    !empty($empresa['tel_movil']),
    !empty($empresa['email']),
    !empty($empresa['val_poriva']),
    !empty($empresa['val_latitud']),
    !empty($empresa['riesgo_arl']),
];
$completitud = $empresa
    ? round(array_sum($campos_completitud) / count($campos_completitud) * 100)
    : 0;

// ── POST ──────────────────────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['btn_guardar'])) {
    try {
        $w_id_empresa   = filter_input(INPUT_POST, 'txt_id_empresa', FILTER_VALIDATE_INT);
        $w_nom_empresa  = trim($_POST['txt_nom_empresa'] ?? '');
        $w_nom_replegal = trim($_POST['txt_nom_replegal'] ?? '');
        $w_barrio       = trim($_POST['txt_barrio'] ?? '');
        $w_direccion    = trim($_POST['txt_direccion'] ?? '');
        $w_tel_fijo     = filter_input(INPUT_POST, 'txt_tel_fijo', FILTER_VALIDATE_INT);
        $w_id_prefijo   = filter_input(INPUT_POST, 'txt_id_prefijo', FILTER_VALIDATE_INT);
        $w_tel_movil    = filter_input(INPUT_POST, 'txt_tel_movil', FILTER_VALIDATE_INT);
        $w_email        = trim($_POST['txt_email'] ?? '');

        // Financieros
        $w_val_poriva  = filter_input(INPUT_POST, 'txt_val_poriva',  FILTER_VALIDATE_FLOAT) ?: 0;
        $w_val_pordesc = filter_input(INPUT_POST, 'txt_val_pordesc', FILTER_VALIDATE_FLOAT) ?: 0;
        $w_val_porrete = filter_input(INPUT_POST, 'txt_val_porrete', FILTER_VALIDATE_FLOAT) ?: 0;
        $w_val_reteica = filter_input(INPUT_POST, 'txt_val_reteica', FILTER_VALIDATE_FLOAT) ?: 0;
        $w_val_porutil = filter_input(INPUT_POST, 'txt_val_porutil', FILTER_VALIDATE_FLOAT) ?: 0;

        $w_val_latitud  = filter_input(INPUT_POST, 'txt_val_latitud',  FILTER_VALIDATE_FLOAT);
        $w_val_longitud = filter_input(INPUT_POST, 'txt_val_longitud', FILTER_VALIDATE_FLOAT);

        $w_ind_autorete = isset($_POST['chk_ind_autorete']) ? 't' : 'f';
        $w_riesgo_arl   = trim($_POST['sel_riesgo_arl'] ?? '1');

        // Validaciones
        if ($w_id_empresa === false || $w_id_empresa < 10000000)
            throw new Exception('NIT debe ser ≥ 10.000.000');
        if (strlen($w_nom_empresa) < 5 || strlen($w_nom_empresa) > 60)
            throw new Exception('Nombre empresa: 5-60 caracteres');
        if (strlen($w_nom_replegal) < 5 || strlen($w_nom_replegal) > 60)
            throw new Exception('Representante legal: 5-60 caracteres');
        if (empty($w_barrio) || strlen($w_barrio) > 100)
            throw new Exception('Barrio/Vereda obligatorio (máx 100)');
        if (empty($w_direccion))
            throw new Exception('Dirección obligatoria');
        if ($w_tel_fijo !== null && $w_tel_fijo !== false && ($w_tel_fijo < 1000000 || $w_tel_fijo > 9999999999))
            throw new Exception('Teléfono fijo: 7-10 dígitos');
        if ($w_id_prefijo === false || $w_id_prefijo < 1 || $w_id_prefijo > 9999)
            throw new Exception('Prefijo móvil inválido (1-9999)');
        if ($w_tel_movil === false || $w_tel_movil < 1000000000 || $w_tel_movil > 9999999999)
            throw new Exception('Celular: 10 dígitos');
        if (!filter_var($w_email, FILTER_VALIDATE_EMAIL))
            throw new Exception('Email inválido');
        if ($w_val_poriva < 0 || $w_val_poriva > 99)
            throw new Exception('IVA entre 0 y 99');
        if ($w_val_porrete < 0 || $w_val_porrete > 99)
            throw new Exception('Retención entre 0 y 99');
        if ($w_val_latitud !== false && $w_val_latitud !== null && ($w_val_latitud < -4 || $w_val_latitud > 80))
            throw new Exception('Latitud entre -4 y 80');
        if ($w_val_longitud !== false && $w_val_longitud !== null && ($w_val_longitud < -80 || $w_val_longitud > -50))
            throw new Exception('Longitud entre -80 y -50');
        if (!in_array($w_riesgo_arl, ['1','2','3','4','5']))
            throw new Exception('Riesgo ARL inválido');

        // tel_fijo es opcional → null si vacío
        $tel_fijo_val = ($w_tel_fijo !== false && $w_tel_fijo !== null && $w_tel_fijo !== 0)
            ? $w_tel_fijo
            : null;

        $stmt_check = $pdo->prepare(
            "SELECT COUNT(*) FROM tab_pmtros_grales WHERE id_empresa = ? AND ind_borrado = FALSE"
        );
        $stmt_check->execute([$w_id_empresa]);
        $existe = $stmt_check->fetchColumn();

        // 18 parámetros — los campos del composite van SEPARADOS,
        // la función PL/pgSQL arma el ROW() internamente.
        // Orden exacto de fun_insert/update_pmtros_grales:
        //   wid_empresa, wnom_empresa,
        //   wnom_corto, wdireccion, wtel_fijo, wid_prefijo_movil, wtel_movil, wemail,
        //   wnom_replegal,
        //   wval_poriva, wval_pordesc, wval_porrete, wval_reteica, wval_porutil,
        //   wval_latitud, wval_longitud,
        //   wind_autorete, wriesgo_arl
        $params = [
            $w_id_empresa,
            $w_nom_empresa,
            $w_barrio,          // wnom_corto
            $w_direccion,       // wdireccion
            $tel_fijo_val,      // wtel_fijo  (null si vacío)
            $w_id_prefijo,      // wid_prefijo_movil
            $w_tel_movil,       // wtel_movil
            $w_email,           // wemail
            $w_nom_replegal,
            $w_val_poriva,
            $w_val_pordesc,
            $w_val_porrete,
            $w_val_reteica,
            $w_val_porutil,
            $w_val_latitud,
            $w_val_longitud,
            $w_ind_autorete,    // 't' o 'f'
            $w_riesgo_arl,      // '1'..'5'
        ];

        if ($existe) {
            $stmt_fun_upd_pmtros_grales->execute($params);
            $w_res = $stmt_fun_upd_pmtros_grales->fetchColumn();
        } else {
            $stmt_fun_ins_pmtros_grales->execute($params);
            $w_res = $stmt_fun_ins_pmtros_grales->fetchColumn();
        }

        $ok = strpos($w_res, '') !== false;

        if ($ok) {
            $flash_msg = json_encode($w_res);
            $redirect  = $_SERVER['REQUEST_URI'];
            while (ob_get_level() > 0) ob_end_clean();
            header('Content-Type: text/html; charset=utf-8');
            echo '<!DOCTYPE html><html><head><meta charset="utf-8">'
               . '<script>sessionStorage.setItem("_pg_flash",JSON.stringify({msg:'
               . $flash_msg . ',type:"success"}));'
               . 'window.location.replace(' . json_encode($redirect) . ');'
               . '</script></head><body></body></html>';
            exit();
        }

        $w_tipo_alerta = 'danger';
        $w_mensaje     = '❌ ' . $w_res;

    } catch (PDOException $e) {
        $w_mensaje     = "❌ Error BD: " . $e->getMessage();
        $w_tipo_alerta = "danger";
    } catch (Exception $e) {
        $w_mensaje     = "❌ " . $e->getMessage();
        $w_tipo_alerta = "danger";
    }
}

// Opciones de riesgo ARL
$riesgos_arl = [
    '1' => '1 — 0.522%',
    '2' => '2 — 1.044%',
    '3' => '3 — 2.436%',
    '4' => '4 — 4.350%',
    '5' => '5 — 6.960%',
];
?>

<style>
/* Ocultar flechas en inputs numéricos */
input[type=number]::-webkit-outer-spin-button,
input[type=number]::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
input[type=number] { -moz-appearance: textfield; }

.empresa-pg { display: flex; gap: 24px; align-items: stretch; margin-top: 20px; }
.empresa-panel-l { flex: 0 0 300px; }
.empresa-panel-r { flex: 1; }

/* Tarjeta resumen */
.empresa-cc { background: #0f1729; border-radius: 18px; overflow: hidden; color: #fff; box-shadow: 0 8px 20px rgba(0,0,0,.1); }
.empresa-cc-top { padding: 18px 20px 0; display: flex; justify-content: flex-end; }
.empresa-badge-act { background: rgba(0,200,224,.15); color: #00c8e0; border: 1px solid rgba(0,200,224,.28); font-size: 11px; font-weight: 600; padding: 4px 12px; border-radius: 30px; display: inline-flex; align-items: center; gap: 6px; }
.empresa-badge-act::before { content: ''; width: 6px; height: 6px; background: #00c8e0; border-radius: 50%; animation: blink 2s infinite; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.4} }
.empresa-cc-body { padding: 20px; }
.empresa-cc-nit  { font-size: 11px; color: rgba(255,255,255,.5); margin-bottom: 6px; }
.empresa-cc-name { font-size: 18px; font-weight: 700; line-height: 1.3; margin-bottom: 6px; }
.empresa-cc-rep  { font-size: 12px; color: rgba(255,255,255,.6); margin-bottom: 20px; }
.empresa-prog-wrap { margin-bottom: 20px; }
.empresa-prog-row { display: flex; justify-content: space-between; font-size: 11px; color: rgba(255,255,255,.5); margin-bottom: 6px; }
.empresa-prog-row span:last-child { color: #00c8e0; font-weight: 700; }
.empresa-prog-track { height: 4px; background: rgba(255,255,255,.1); border-radius: 4px; overflow: hidden; }
.empresa-prog-fill  { height: 100%; background: #00c8e0; border-radius: 4px; transition: width .5s; }
.empresa-cc-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 20px; }
.empresa-cc-stat  { background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.08); border-radius: 8px; padding: 10px 12px; }
.empresa-cc-slbl  { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: rgba(255,255,255,.4); }
.empresa-cc-sval  { font-size: 20px; font-weight: 700; line-height: 1; }
.empresa-cc-foot  { border-top: 1px solid rgba(255,255,255,.08); padding: 14px 20px; display: flex; flex-direction: column; gap: 8px; }
.empresa-cc-meta  { font-size: 11px; color: rgba(255,255,255,.5); display: flex; align-items: center; gap: 8px; }
.empresa-cc-meta i { color: #00c8e0; font-size: 13px; }
.empresa-sin-datos { text-align: center; padding: 40px 0; color: rgba(255,255,255,.4); }

/* Cabecera */
.empresa-cfg-header { margin-bottom: 16px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.empresa-cfg-icon   { width: 36px; height: 36px; background: #00c8e0; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.empresa-cfg-icon i { font-size: 18px; color: #0f1729; }
.empresa-cfg-title  { font-size: 22px; font-weight: 700; margin: 0; color: #0f1729; }
.empresa-cfg-sub    { font-size: 13px; color: #6c757d; margin-top: 2px; flex-basis: 100%; }

/* Alerta */
.empresa-alert       { padding: 12px 16px; border-radius: 12px; font-size: 13px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; margin-bottom: 16px; }
.empresa-alert.success { border-left-color: #10b981; background: #f0fdf4; color: #065f46; }
.empresa-alert.danger  { border-left-color: #ef4444; background: #fef2f2; color: #b91c1c; }
.empresa-alert i { font-size: 16px; }
.empresa-alert-close { margin-left: auto; background: none; border: none; cursor: pointer; font-size: 18px; color: inherit; line-height: 1; }

/* Tarjeta formulario */
.empresa-card { background: #fff; border-radius: 18px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,.03); }

/* Tabs */
.empresa-tab-bar { display: flex; border-bottom: 1px solid #e2e8f0; padding: 0 16px; background: #fafcff; }
.empresa-tab-btn { padding: 14px 18px; font-size: 13px; font-weight: 500; color: #4a5568; background: transparent; border: none; border-bottom: 2px solid transparent; cursor: pointer; transition: all .2s; display: flex; align-items: center; gap: 8px; }
.empresa-tab-btn i { font-size: 15px; }
.empresa-tab-btn:hover { color: #0f1729; }
.empresa-tab-btn.active { color: #0f1729; font-weight: 600; border-bottom-color: #00c8e0; }
.empresa-tab-pane { display: none; padding: 24px 28px; }
.empresa-tab-pane.active { display: block; }

/* Campos */
.empresa-fg { margin-bottom: 18px; }
.empresa-fl { display: block; font-size: 11px; font-weight: 700; letter-spacing: .5px; text-transform: uppercase; color: #4a5568; margin-bottom: 6px; }
.empresa-fl .req { color: #00c8e0; }
.empresa-fi { width: 100%; padding: 10px 14px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 14px; font-family: inherit; color: #0f1729; background: #fff; outline: none; transition: all .2s; box-sizing: border-box; }
.empresa-fi:focus { border-color: #00c8e0; box-shadow: 0 0 0 3px rgba(0,200,224,.1); }
.empresa-fi.error { border-color: #ef4444; background: #fef2f2; }
.empresa-error-msg { font-size: 11px; color: #ef4444; margin-top: 5px; display: none; }
.empresa-error-msg.show { display: block; }
.empresa-fhint { font-size: 10px; color: #9aa3b2; margin-top: 4px; }
.empresa-r2 { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.empresa-r3 { display: grid; grid-template-columns: repeat(3,1fr); gap: 18px; }
.empresa-sep { height: 1px; background: #e2e8f0; margin: 20px 0; }

/* Prefijo + celular en la misma fila */
.empresa-tel-row { display: flex; gap: 10px; }
.empresa-tel-row .prefijo { flex: 0 0 110px; }
.empresa-tel-row .movil   { flex: 1; }

/* Checkbox autorete */
.empresa-chk-row { display: flex; align-items: center; gap: 12px; padding: 12px 16px; background: #f4f6fa; border: 1.5px solid #e2e8f0; border-radius: 8px; cursor: pointer; margin-bottom: 18px; transition: all .2s; }
.empresa-chk-row.on { border-color: #00c8e0; background: rgba(0,200,224,.05); }
.empresa-chk-row input { width: 18px; height: 18px; accent-color: #0f1729; cursor: pointer; }
.empresa-chk-row label { font-size: 13px; font-weight: 500; color: #0f1729; cursor: pointer; flex: 1; }

/* Fila fiscal */
.empresa-fiscal-row { background: #f4f6fa; border-radius: 8px; padding: 14px 18px; display: flex; align-items: center; gap: 20px; border: 1px solid #e2e8f0; }
.empresa-fiscal-row i { font-size: 24px; color: #00c8e0; }
.empresa-fc p { font-size: 10px; text-transform: uppercase; color: #9aa3b2; margin-bottom: 2px; }
.empresa-fc strong { font-size: 16px; font-weight: 700; color: #0f1729; }
.empresa-fdiv { width: 1px; height: 30px; background: #e2e8f0; }

/* Footer formulario */
.empresa-form-footer { padding: 16px 28px; border-top: 1px solid #e2e8f0; background: #f4f6fa; display: flex; align-items: center; justify-content: flex-end; gap: 12px; }
.empresa-chg-ind { font-size: 11px; color: #9aa3b2; display: flex; align-items: center; gap: 6px; margin-right: auto; opacity: 0; transition: opacity .2s; }
.empresa-chg-ind.on { opacity: 1; color: #f59e0b; }
.empresa-chg-ind::before { content: ''; width: 8px; height: 8px; background: #f59e0b; border-radius: 50%; display: inline-block; }
.empresa-btn-secondary, .empresa-btn-primary { padding: 9px 22px; font-size: 13px; font-weight: 600; border-radius: 8px; cursor: pointer; transition: all .2s; border: none; }
.empresa-btn-secondary { background: transparent; border: 1.5px solid #e2e8f0; color: #4a5568; }
.empresa-btn-secondary:hover { background: #fff; border-color: #cbd5e1; }
.empresa-btn-primary { background: #0f1729; color: #fff; display: inline-flex; align-items: center; gap: 8px; }
.empresa-btn-primary:disabled { opacity: .5; cursor: not-allowed; background: #94a3b8; }
.empresa-btn-primary:not(:disabled):hover { background: #1a2540; }
.btn-gps { background: #eef2ff; border: 1px solid #cbd5e1; border-radius: 8px; padding: 0 12px; font-size: 13px; font-weight: 500; color: #1e40af; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 6px; height: 42px; }
.btn-gps:hover { background: #e0e7ff; border-color: #00c8e0; }

@media (max-width: 900px) {
    .empresa-pg { flex-direction: column; }
    .empresa-r2, .empresa-r3 { grid-template-columns: 1fr; gap: 12px; }
}
</style>

<div class="empresa-pg">

    <!-- ── Panel izquierdo: resumen ── -->
    <div class="empresa-panel-l">
        <div class="empresa-cc">
            <div class="empresa-cc-top">
                <span class="empresa-badge-act">Empresa activa</span>
            </div>
            <div class="empresa-cc-body">
                <?php if ($empresa): ?>
                    <div class="empresa-cc-nit">NIT <?= htmlspecialchars($empresa['id_empresa']) ?></div>
                    <div class="empresa-cc-name"><?= htmlspecialchars($empresa['nom_empresa']) ?></div>
                    <div class="empresa-cc-rep">Rep. Legal: <?= htmlspecialchars(substr($empresa['nom_replegal'], 0, 35)) ?></div>
                    <div class="empresa-prog-wrap">
                        <div class="empresa-prog-row">
                            <span>Completitud del perfil</span>
                            <span><?= $completitud ?>%</span>
                        </div>
                        <div class="empresa-prog-track">
                            <div class="empresa-prog-fill" style="width:<?= $completitud ?>%"></div>
                        </div>
                    </div>
                    <div class="empresa-cc-stats">
                        <div class="empresa-cc-stat">
                            <div class="empresa-cc-slbl">IVA</div>
                            <div class="empresa-cc-sval"><?= $empresa['val_poriva'] ?? 0 ?>%</div>
                        </div>
                        <div class="empresa-cc-stat">
                            <div class="empresa-cc-slbl">Retención</div>
                            <div class="empresa-cc-sval"><?= $empresa['val_porrete'] ?? 0 ?>%</div>
                        </div>
                        <div class="empresa-cc-stat">
                            <div class="empresa-cc-slbl">Año Fiscal</div>
                            <div class="empresa-cc-sval"><?= $empresa['anio_fiscal'] ?? $anio_actual ?></div>
                        </div>
                        <div class="empresa-cc-stat">
                            <div class="empresa-cc-slbl">Mes Fiscal</div>
                            <div class="empresa-cc-sval"><?= $empresa['mes_fiscal'] ?? $mes_actual ?></div>
                        </div>
                    </div>
                <?php else: ?>
                    <div class="empresa-sin-datos">
                        <i class="bi bi-building" style="font-size:48px;display:block;margin-bottom:12px;"></i>
                        Sin empresa configurada
                    </div>
                <?php endif; ?>
            </div>
            <div class="empresa-cc-foot">
                <div class="empresa-cc-meta">
                    <i class="bi bi-geo-alt-fill"></i>
                    <?= htmlspecialchars($empresa['barrio'] ?? 'Barrio no definido') ?>,
                    <?= htmlspecialchars($empresa['direccion'] ?? '') ?>
                </div>
                <div class="empresa-cc-meta">
                    <i class="bi bi-envelope"></i>
                    <?= htmlspecialchars($empresa['email'] ?? 'sin email') ?>
                </div>
                <div class="empresa-cc-meta">
                    <i class="bi bi-phone"></i>
                    +<?= htmlspecialchars($empresa['id_prefijo_movil'] ?? '57') ?>
                    <?= htmlspecialchars($empresa['tel_movil'] ?? '') ?>
                </div>
                <?php if ($es_autorete): ?>
                    <div class="empresa-cc-meta">
                        <i class="bi bi-shield-check"></i> Auto-retenedor Sí
                    </div>
                <?php endif; ?>
                <?php if (!empty($empresa['riesgo_arl'])): ?>
                    <div class="empresa-cc-meta">
                        <i class="bi bi-exclamation-triangle"></i>
                        Riesgo ARL: <?= htmlspecialchars($riesgos_arl[$empresa['riesgo_arl']] ?? $empresa['riesgo_arl']) ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- ── Panel derecho: formulario ── -->
    <div class="empresa-panel-r">
        <div class="empresa-cfg-header">
            <div class="empresa-cfg-icon"><i class="bi bi-gear-fill"></i></div>
            <h2 class="empresa-cfg-title">Configuración de empresa</h2>
            <p class="empresa-cfg-sub">
                Parámetros generales ·
                <?= $empresa ? htmlspecialchars($empresa['nom_empresa']) : 'Nueva empresa' ?>
            </p>
        </div>

        <?php if ($w_mensaje): ?>
            <div class="empresa-alert <?= $w_tipo_alerta ?>">
                <i class="bi bi-<?= $w_tipo_alerta === 'success' ? 'check-circle-fill' : 'exclamation-triangle-fill' ?>"></i>
                <?= nl2br(htmlspecialchars($w_mensaje)) ?>
                <button type="button" class="empresa-alert-close"
                        onclick="this.closest('.empresa-alert').remove()">
                    <i class="bi bi-x"></i>
                </button>
            </div>
        <?php endif; ?>

        <div class="empresa-card">
            <div class="empresa-tab-bar">
                <button class="empresa-tab-btn active" data-tab="general">
                    <i class="bi bi-building"></i> General
                </button>
                <button class="empresa-tab-btn" data-tab="ubicacion">
                    <i class="bi bi-geo-alt"></i> Ubicación &amp; Contacto
                </button>
                <button class="empresa-tab-btn" data-tab="financiero">
                    <i class="bi bi-currency-dollar"></i> Financiero
                </button>
            </div>

            <form method="POST" id="empresaForm" novalidate>

                <!-- ── Tab General ── -->
                <div class="empresa-tab-pane active" id="tab-general">
                    <div class="empresa-fg">
                        <label class="empresa-fl">ID EMPRESA (NIT) <span class="req">*</span></label>
                        <input type="number" class="empresa-fi" name="txt_id_empresa" id="nit"
                               value="<?= htmlspecialchars($empresa['id_empresa'] ?? '') ?>"
                               <?= $empresa ? 'readonly' : '' ?> required>
                        <div class="empresa-fhint">Solo lectura si ya existe el registro</div>
                        <div class="empresa-error-msg" id="error-nit"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">NOMBRE EMPRESA <span class="req">*</span></label>
                        <input type="text" class="empresa-fi" name="txt_nom_empresa" id="nombreEmpresa"
                               value="<?= htmlspecialchars($empresa['nom_empresa'] ?? '') ?>" required>
                        <div class="empresa-error-msg" id="error-nombre"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">REPRESENTANTE LEGAL <span class="req">*</span></label>
                        <input type="text" class="empresa-fi" name="txt_nom_replegal" id="repLegal"
                               value="<?= htmlspecialchars($empresa['nom_replegal'] ?? '') ?>" required>
                        <div class="empresa-error-msg" id="error-replegal"></div>
                    </div>

                    <div class="empresa-chk-row <?= $es_autorete ? 'on' : '' ?>" id="chkRow">
                        <input type="checkbox" name="chk_ind_autorete" id="fAutorete"
                               <?= $es_autorete ? 'checked' : '' ?>>
                        <label for="fAutorete">Auto-retenedor de impuestos</label>
                    </div>

                    <div class="empresa-fiscal-row">
                        <i class="bi bi-calendar3"></i>
                        <div class="empresa-fc"><p>Año Fiscal</p><strong><?= $anio_actual ?></strong></div>
                        <div class="empresa-fdiv"></div>
                        <div class="empresa-fc"><p>Mes Fiscal</p><strong><?= $mes_actual ?> — <?= $nombre_mes ?></strong></div>
                    </div>
                    <div class="empresa-fhint">anio_fiscal y mes_fiscal se calculan automáticamente por constraint de BD</div>
                </div>

                <!-- ── Tab Ubicación & Contacto ── -->
                <div class="empresa-tab-pane" id="tab-ubicacion">
                    <div class="empresa-fg">
                        <label class="empresa-fl">BARRIO / VEREDA <span class="req">*</span></label>
                        <input type="text" class="empresa-fi" name="txt_barrio" id="barrio"
                               value="<?= htmlspecialchars($empresa['barrio'] ?? '') ?>" required>
                        <div class="empresa-error-msg" id="error-barrio"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">DIRECCIÓN <span class="req">*</span></label>
                        <input type="text" class="empresa-fi" name="txt_direccion" id="direccion"
                               value="<?= htmlspecialchars($empresa['direccion'] ?? '') ?>" required>
                        <div class="empresa-error-msg" id="error-direccion"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">TELÉFONO FIJO</label>
                        <input type="number" class="empresa-fi" name="txt_tel_fijo" id="telFijo"
                               value="<?= htmlspecialchars($empresa['tel_fijo'] ?? '') ?>"
                               placeholder="Ej: 6076543210">
                        <div class="empresa-fhint">7-10 dígitos (opcional)</div>
                        <div class="empresa-error-msg" id="error-telfijo"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">CELULAR <span class="req">*</span></label>
                        <div class="empresa-tel-row">
                            <div class="prefijo">
                                <input type="number" class="empresa-fi" name="txt_id_prefijo" id="idPrefijo"
                                       value="<?= htmlspecialchars($empresa['id_prefijo_movil'] ?? '57') ?>"
                                       placeholder="57" required>
                                <div class="empresa-fhint">Prefijo país</div>
                            </div>
                            <div class="movil">
                                <input type="number" class="empresa-fi" name="txt_tel_movil" id="telMovil"
                                       value="<?= htmlspecialchars($empresa['tel_movil'] ?? '') ?>"
                                       placeholder="Ej: 3001234567" required>
                                <div class="empresa-fhint">10 dígitos</div>
                            </div>
                        </div>
                        <div class="empresa-error-msg" id="error-telmovil"></div>
                        <div class="empresa-error-msg" id="error-idPrefijo"></div>
                    </div>
                    <div class="empresa-fg">
                        <label class="empresa-fl">EMAIL <span class="req">*</span></label>
                        <input type="email" class="empresa-fi" name="txt_email" id="email"
                               value="<?= htmlspecialchars($empresa['email'] ?? '') ?>" required>
                        <div class="empresa-error-msg" id="error-email"></div>
                    </div>

                    <div class="empresa-sep"></div>

                    <div class="empresa-r2">
                        <div class="empresa-fg">
                            <label class="empresa-fl">LATITUD</label>
                            <div style="display:flex;align-items:center;gap:8px">
                                <input type="number" step="any" class="empresa-fi" name="txt_val_latitud"
                                       id="latitud"
                                       value="<?= htmlspecialchars($empresa['val_latitud'] ?? '') ?>"
                                       placeholder="Ej: 4.7110" style="flex:1">
                                <button type="button" class="btn-gps" id="btnGps">
                                    <i class="bi bi-geo-alt-fill"></i> GPS
                                </button>
                            </div>
                            <div class="empresa-fhint">Rango -4 a 80</div>
                            <div class="empresa-error-msg" id="error-latitud"></div>
                        </div>
                        <div class="empresa-fg">
                            <label class="empresa-fl">LONGITUD</label>
                            <input type="number" step="any" class="empresa-fi" name="txt_val_longitud"
                                   id="longitud"
                                   value="<?= htmlspecialchars($empresa['val_longitud'] ?? '') ?>"
                                   placeholder="Ej: -74.0721">
                            <div class="empresa-fhint">Rango -80 a -50</div>
                            <div class="empresa-error-msg" id="error-longitud"></div>
                        </div>
                    </div>
                </div>

                <!-- ── Tab Financiero ── -->
                <div class="empresa-tab-pane" id="tab-financiero">
                    <div class="empresa-r2">
                        <div class="empresa-fg">
                            <label class="empresa-fl">IVA (%)</label>
                            <input type="number" class="empresa-fi" name="txt_val_poriva"
                                   id="iva" min="0" max="99"
                                   value="<?= htmlspecialchars($empresa['val_poriva'] ?? 0) ?>"
                                   placeholder="0">
                            <div class="empresa-error-msg" id="error-iva"></div>
                        </div>
                        <div class="empresa-fg">
                            <label class="empresa-fl">DESCUENTO (%)</label>
                            <input type="number" class="empresa-fi" name="txt_val_pordesc"
                                   id="descuento" min="0" max="99"
                                   value="<?= htmlspecialchars($empresa['val_pordesc'] ?? 0) ?>"
                                   placeholder="0">
                        </div>
                    </div>
                    <div class="empresa-r2">
                        <div class="empresa-fg">
                            <label class="empresa-fl">RETENCIÓN (%)</label>
                            <input type="number" class="empresa-fi" name="txt_val_porrete"
                                   id="retencion" min="0" max="99"
                                   value="<?= htmlspecialchars($empresa['val_porrete'] ?? 0) ?>"
                                   placeholder="0">
                            <div class="empresa-error-msg" id="error-retencion"></div>
                        </div>
                        <div class="empresa-fg">
                            <label class="empresa-fl">RETEICA (%)</label>
                            <input type="number" class="empresa-fi" name="txt_val_reteica"
                                   id="reteica" min="0" max="99"
                                   value="<?= htmlspecialchars($empresa['val_reteica'] ?? 0) ?>"
                                   placeholder="0">
                        </div>
                    </div>
                    <div class="empresa-r2">
                        <div class="empresa-fg">
                            <label class="empresa-fl">UTILIDAD (%)</label>
                            <input type="number" class="empresa-fi" name="txt_val_porutil"
                                   id="utilidad" min="0" max="100"
                                   value="<?= htmlspecialchars($empresa['val_porutil'] ?? 0) ?>"
                                   placeholder="0">
                        </div>
                        <div class="empresa-fg">
                            <label class="empresa-fl">RIESGO ARL <span class="req">*</span></label>
                            <select class="empresa-fi" name="sel_riesgo_arl" id="riesgoArl">
                                <?php foreach ($riesgos_arl as $k => $v): ?>
                                    <option value="<?= $k ?>"
                                        <?= ($empresa['riesgo_arl'] ?? '1') == $k ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($v) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <div class="empresa-fhint">Clase de riesgo para ARL (afecta liquidación nómina)</div>
                        </div>
                    </div>
                </div>

                <div class="empresa-form-footer">
                    <div class="empresa-chg-ind" id="chgInd">Cambios sin guardar</div>
                    <button type="button" class="empresa-btn-secondary"
                            onclick="if(confirm('¿Descartar los cambios realizados?')) window.location.reload()">
                        Descartar
                    </button>
                    <button type="submit" name="btn_guardar" class="empresa-btn-primary"
                            id="btnGuardar" disabled>
                        <i class="bi bi-floppy"></i> Guardar cambios
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let hasChanges = false;
const touched  = {};

const ERROR_MSGS = {
    nit:          'NIT debe ser ≥ 10.000.000',
    nombreEmpresa:'Nombre empresa: 5-60 caracteres',
    repLegal:     'Representante legal: 5-60 caracteres',
    barrio:       'Barrio/Vereda obligatorio (máx 100 caracteres)',
    direccion:    'Dirección obligatoria',
    telFijo:      'Teléfono fijo: 7-10 dígitos',
    idPrefijo:    'Prefijo país: 1-9999',
    telMovil:     'Celular: 10 dígitos',
    email:        'Email inválido',
    iva:          'IVA entre 0 y 99',
    retencion:    'Retención entre 0 y 99',
    latitud:      'Latitud entre -4 y 80 (Colombia)',
    longitud:     'Longitud entre -80 y -50 (Colombia)',
};

const V = {
    nit:          v => v && !isNaN(v) && parseInt(v) >= 10000000,
    nombreEmpresa:v => v && v.length >= 5 && v.length <= 60,
    repLegal:     v => v && v.length >= 5 && v.length <= 60,
    barrio:       v => v && v.length > 0 && v.length <= 100,
    direccion:    v => v && v.trim() !== '',
    telFijo:      v => v === '' || /^\d{7,10}$/.test(v),
    idPrefijo:    v => v !== '' && !isNaN(v) && parseInt(v) >= 1 && parseInt(v) <= 9999,
    telMovil:     v => /^\d{10}$/.test(v),
    email:        v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
    iva:          v => v === '' || (parseFloat(v) >= 0 && parseFloat(v) <= 99),
    retencion:    v => v === '' || (parseFloat(v) >= 0 && parseFloat(v) <= 99),
    latitud:      v => v === '' || (parseFloat(v) >= -4  && parseFloat(v) <= 80),
    longitud:     v => v === '' || (parseFloat(v) >= -80 && parseFloat(v) <= -50),
};

const FIELD_MAP = [
    { id: 'nit',           v: V.nit,           err: 'error-nit',       req: true  },
    { id: 'nombreEmpresa', v: V.nombreEmpresa,  err: 'error-nombre',    req: true  },
    { id: 'repLegal',      v: V.repLegal,       err: 'error-replegal',  req: true  },
    { id: 'barrio',        v: V.barrio,         err: 'error-barrio',    req: true  },
    { id: 'direccion',     v: V.direccion,      err: 'error-direccion', req: true  },
    { id: 'idPrefijo',     v: V.idPrefijo,      err: 'error-idPrefijo', req: true  },
    { id: 'telMovil',      v: V.telMovil,       err: 'error-telmovil',  req: true  },
    { id: 'email',         v: V.email,          err: 'error-email',     req: true  },
    { id: 'telFijo',       v: V.telFijo,        err: 'error-telfijo',   req: false },
    { id: 'iva',           v: V.iva,            err: 'error-iva',       req: false },
    { id: 'retencion',     v: V.retencion,      err: 'error-retencion', req: false },
    { id: 'latitud',       v: V.latitud,        err: 'error-latitud',   req: false },
    { id: 'longitud',      v: V.longitud,       err: 'error-longitud',  req: false },
];

function showError(fieldId, errorSpanId, isValid) {
    const el   = document.getElementById(fieldId);
    const span = document.getElementById(errorSpanId);
    if (!el || !span) return;
    if (!isValid && touched[fieldId]) {
        span.textContent = ERROR_MSGS[fieldId] || 'Campo inválido';
        span.classList.add('show');
        el.classList.add('error');
    } else {
        span.classList.remove('show');
        el.classList.remove('error');
    }
}

function validateAll(forSubmit = false) {
    if (forSubmit) {
        FIELD_MAP.forEach(f => { if (f.req) touched[f.id] = true; });
        ['telFijo','iva','retencion','latitud','longitud'].forEach(id => {
            const el = document.getElementById(id);
            if (el && el.value !== '') touched[id] = true;
        });
    }

    let allOk = true;
    FIELD_MAP.forEach(({ id, v, err, req }) => {
        const el = document.getElementById(id);
        if (!el) return;
        const valid = v(el.value);
        showError(id, err, valid);
        if (req && !valid) allOk = false;
        if (!req && el.value !== '' && !valid) allOk = false;
    });

    document.getElementById('btnGuardar').disabled = !allOk;
    return allOk;
}

function markChanged() {
    hasChanges = true;
    document.getElementById('chgInd').classList.add('on');
    validateAll();
}

function obtenerGPS() {
    const btn = document.getElementById('btnGps');
    if (!navigator.geolocation) { alert('Su navegador no soporta geolocalización.'); return; }
    btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Obteniendo...';
    btn.disabled  = true;
    navigator.geolocation.getCurrentPosition(
        pos => {
            document.getElementById('latitud').value  = pos.coords.latitude.toFixed(6);
            document.getElementById('longitud').value = pos.coords.longitude.toFixed(6);
            ['latitud','longitud'].forEach(id => { touched[id] = true; });
            markChanged();
            btn.innerHTML = '<i class="bi bi-geo-alt-fill"></i> GPS';
            btn.disabled  = false;
        },
        err => {
            const msgs = {
                [err.PERMISSION_DENIED]:    'Permiso denegado.',
                [err.POSITION_UNAVAILABLE]: 'Ubicación no disponible.',
                [err.TIMEOUT]:              'Tiempo de espera agotado.',
            };
            alert('Error: ' + (msgs[err.code] || 'Error desconocido.'));
            btn.innerHTML = '<i class="bi bi-geo-alt-fill"></i> GPS';
            btn.disabled  = false;
        }
    );
}

function mostrarFlash(msg, type) {
    const wrap = document.querySelector('.empresa-panel-r');
    if (!wrap) return;
    const div = document.createElement('div');
    div.className = 'empresa-alert ' + type;
    const ico = type === 'success' ? 'check-circle-fill' : 'exclamation-triangle-fill';
    div.innerHTML = '<i class="bi bi-' + ico + '"></i> ' + msg
        + '<button type="button" class="empresa-alert-close" onclick="this.closest(\'.empresa-alert\').remove()"><i class="bi bi-x"></i></button>';
    const header = wrap.querySelector('.empresa-cfg-header');
    header ? header.after(div) : wrap.prepend(div);
    if (type === 'success') setTimeout(() => div.remove(), 6000);
}

document.addEventListener('DOMContentLoaded', () => {

    try {
        const flashRaw = sessionStorage.getItem('_pg_flash');
        if (flashRaw) {
            sessionStorage.removeItem('_pg_flash');
            const { msg, type } = JSON.parse(flashRaw);
            mostrarFlash(msg, type);
        }
    } catch(e) {}

    // Tabs
    document.querySelectorAll('.empresa-tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.empresa-tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.empresa-tab-pane').forEach(p => p.classList.remove('active'));
            btn.classList.add('active');
            document.getElementById('tab-' + btn.dataset.tab).classList.add('active');
        });
    });

    // Checkbox autorete
    document.getElementById('fAutorete')?.addEventListener('change', function() {
        document.getElementById('chkRow').classList.toggle('on', this.checked);
        markChanged();
    });

    // Eventos genéricos
    document.querySelectorAll('#empresaForm input, #empresaForm select').forEach(el => {
        el.addEventListener('input',  markChanged);
        el.addEventListener('change', markChanged);
        el.addEventListener('blur', e => {
            touched[e.target.id] = true;
            validateAll();
        });
    });

    document.getElementById('btnGps')?.addEventListener('click', obtenerGPS);

    document.getElementById('empresaForm').addEventListener('submit', e => {
        if (!validateAll(true)) {
            e.preventDefault();
            const firstError = document.querySelector('.empresa-fi.error');
            if (firstError) {
                const pane = firstError.closest('.empresa-tab-pane');
                if (pane) {
                    const tabId = pane.id.replace('tab-', '');
                    document.querySelector(`[data-tab="${tabId}"]`)?.click();
                    setTimeout(() => firstError.focus(), 50);
                }
            }
        }
    });

    if (document.getElementById('nit').value !== '') {
        validateAll();
    }
});
</script>