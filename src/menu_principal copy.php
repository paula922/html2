<?php
session_start();
require_once('../auth/src/prepare_auth.php');

$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
$host     = $_SERVER['HTTP_HOST'];
$base_url = $protocol . $host;

if (!isset($_SESSION['id_usuario'])) {
    header("Location: /erpadso/auth/");
    exit();
}

$wid_usuario  = $_SESSION['id_usuario'];
$wnom_usuario = $_SESSION['nom_usuario'];

$page_title       = "ADSOERP | Menú Principal";
$page_description = "Sistema de gestión administrativa y nómina";
$page_extra_css   = [];
$page_extra_js    = [];
$show_welcome     = true;

/* ══════════════════════════════════════════
   CONSTRUCCIÓN DEL MENÚ JERÁRQUICO
══════════════════════════════════════════ */
try {
    $sql = "SELECT m.id_menu, m.nom_menu, m.ind_id_padre, m.nom_programa
            FROM tab_menu_usuarios mu
            INNER JOIN tab_menus m ON mu.id_menu = m.id_menu
            WHERE mu.id_usuario = CAST(? AS TEXT)
            ORDER BY m.id_menu ASC";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$wid_usuario]);
    $menu_raw   = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $menu_final = [];
    foreach ($menu_raw as $item) {
        if ($item['ind_id_padre'] == '0') {
            $menu_final[$item['id_menu']]             = $item;
            $menu_final[$item['id_menu']]['submenus'] = [];
        } else {
            $padre_id = $item['ind_id_padre'];
            if (isset($menu_final[$padre_id])) {
                $menu_final[$padre_id]['submenus'][$item['id_menu']]          = $item;
                $menu_final[$padre_id]['submenus'][$item['id_menu']]['items'] = [];
            } else {
                foreach ($menu_final as $abuelo_id => $info_abuelo) {
                    if (isset($menu_final[$abuelo_id]['submenus'][$padre_id])) {
                        $menu_final[$abuelo_id]['submenus'][$padre_id]['items'][] = $item;
                    }
                }
            }
        }
    }
} catch (Exception $e) {
    die("Error en Jerarquía: " . $e->getMessage());
}

/* ══════════════════════════════════════════
   MAPA DE ICONOS
══════════════════════════════════════════ */
function getIcon(string $nombre): string {
    $n   = strtolower($nombre);
    $map = [
        'config'    => 'bi-gear',
        'usuario'   => 'bi-people',
        'perfil'    => 'bi-person-badge',
        'menu'      => 'bi-list',
        'acceso'    => 'bi-lock',
        'departam'  => 'bi-building',
        'cargo'     => 'bi-briefcase',
        'liquidac'  => 'bi-calculator',
        'proceso'   => 'bi-play-circle',
        'nómin'     => 'bi-file-earmark-text',
        'nomin'     => 'bi-file-earmark-text',
        'rrhh'      => 'bi-people-fill',
        'reporte'   => 'bi-file-bar-graph',
        'tabla'     => 'bi-table',
        'copia'     => 'bi-files',
        'cambiar'   => 'bi-key',
        'compra'    => 'bi-cart3',
        'tesorer'   => 'bi-cash-stack',
        'cuentas'   => 'bi-wallet2',
        'financ'    => 'bi-graph-up-arrow',
        'contab'    => 'bi-journal-check',
        'marketing' => 'bi-megaphone',
        'comercial' => 'bi-shop',
        'ventas'    => 'bi-bag-check',
        'document'  => 'bi-folder2-open',
        'calidad'   => 'bi-patch-check',
        'expedient' => 'bi-folder-symlink',
        'sst'       => 'bi-shield-check',
        'seguridad' => 'bi-shield-lock',
        'salud'     => 'bi-heart-pulse',
        'afines'    => 'bi-diagram-3',
        'dashboard' => 'bi-speedometer2',
        'inventar'  => 'bi-boxes',
        'almacen'   => 'bi-archive',
        'proyecto'  => 'bi-kanban',
        'contrato'  => 'bi-file-earmark-ruled',
        'proveedor' => 'bi-truck',
        'pago'      => 'bi-credit-card',
        'factura'   => 'bi-receipt',
        'impuesto'  => 'bi-percent',
        'banco'     => 'bi-bank',
        'activo'    => 'bi-building-gear',
    ];
    foreach ($map as $k => $v) {
        if (stripos($n, $k) !== false) return $v;
    }
    return 'bi-circle';
}

/* ══════════════════════════════════════════
   PARÁMETROS DE NAVEGACIÓN
══════════════════════════════════════════ */
$padre_activo_id = isset($_GET['padre']) ? (int)$_GET['padre'] : null;
$hijo_activo_id  = isset($_GET['hijo'])  ? (int)$_GET['hijo']  : null;
$nieto_activo_id = isset($_GET['nieto']) ? (int)$_GET['nieto'] : null;

if (!$padre_activo_id && count($menu_final) > 0) {
    $primer_padre    = reset($menu_final);
    $padre_activo_id = $primer_padre['id_menu'];
}

/* ── Hijos del padre activo ── */
$hijos_activos = [];
if ($padre_activo_id && isset($menu_final[$padre_activo_id]['submenus'])) {
    $hijos_activos = $menu_final[$padre_activo_id]['submenus'];
}

/* ── Nombre del padre activo ── */
$nombre_padre_activo = '';
foreach ($menu_final as $p) {
    if ($p['id_menu'] == $padre_activo_id) {
        $nombre_padre_activo = $p['nom_menu'];
        break;
    }
}

/* ── Verificar si el padre activo tiene nom_programa tipo Exit ── */
if ($padre_activo_id && isset($menu_final[$padre_activo_id])) {
    $pp = trim($menu_final[$padre_activo_id]['nom_programa'] ?? '');
    if ($pp !== '' && $pp !== 'no_aplica') {
        if (strcasecmp($pp, 'Exit') === 0 || strcasecmp($pp, 'Fin') === 0) {
            header("Location: ../auth/index.php");
            exit();
        }
    }
}

/* ── Auto-seleccionar primer hijo si el padre no es Configuración ── */
$es_configuracion = stripos($nombre_padre_activo, 'config') !== false;
if (!isset($_GET['hijo']) && count($hijos_activos) > 0 && !$es_configuracion) {
    $primer_hijo = reset($hijos_activos);
    header("Location: ?padre={$padre_activo_id}&hijo={$primer_hijo['id_menu']}");
    exit();
}

/* ── Nietos del hijo activo ── */
$nietos_activos = [];
if ($hijo_activo_id && isset($hijos_activos[$hijo_activo_id]['items'])) {
    $nietos_activos = $hijos_activos[$hijo_activo_id]['items'];
}

/* ══════════════════════════════════════════
   CARGA DE MÓDULO/PROGRAMA
══════════════════════════════════════════ */
if (!defined('INCLUDE_MENU_PRINCIPAL')) define('INCLUDE_MENU_PRINCIPAL', true);

$programa_a_cargar = null;
$contenido_modulo  = '';

if ($nieto_activo_id && $nietos_activos) {
    foreach ($nietos_activos as $n) {
        if ($n['id_menu'] == $nieto_activo_id && !empty($n['nom_programa'])) {
            $programa_a_cargar = $n['nom_programa'];
            break;
        }
    }
}
if (!$programa_a_cargar && $hijo_activo_id && isset($hijos_activos[$hijo_activo_id])) {
    $h = $hijos_activos[$hijo_activo_id];
    if (!empty($h['nom_programa'])) $programa_a_cargar = $h['nom_programa'];
}
if ($programa_a_cargar) {
    $prog_trim = trim($programa_a_cargar);
    if (strcasecmp($prog_trim, 'Exit') === 0 || strcasecmp($prog_trim, 'Fin') === 0) {
        header("Location: ../index.php");
        exit();
    }
    if (file_exists($programa_a_cargar)) {
        ob_start();
        include($programa_a_cargar);
        $contenido_modulo = ob_get_clean();
    }
}

$inicial = strtoupper(substr($wnom_usuario, 0, 1));
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title><?= htmlspecialchars($page_title) ?></title>
<meta name="description" content="<?= htmlspecialchars($page_description) ?>">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
<link rel="stylesheet" href="/erpadso/src/css/menu_principal.css">
<link rel="stylesheet" href="/erpadso/src/css/swal-dark.css">

<?php if (!empty($page_extra_css)):
    $css_base = '/erpadso/src/css/';
    foreach ($page_extra_css as $css): ?>
    <link rel="stylesheet" href="<?= $css_base . htmlspecialchars($css) ?>">
<?php endforeach; endif; ?>

<script src="/erpadso/src/js/menu_principal.js" defer></script>
<script src="/erpadso/src/js/sidebar.js" defer></script>

<?php if (!empty($page_extra_js)):
    foreach ($page_extra_js as $js): ?>
    <script src="/erpadso/src/js/<?= htmlspecialchars($js) ?>" defer></script>
<?php endforeach; endif; ?>

<style>
/* ══════════════════════════════════════════
   RESET & BASE
══════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   FIX CRÍTICO — Layout tipo "shell" profesional
   El body nunca genera scroll propio.
   Solo scrollean las zonas internas (sidebar y main).
   Esto es el estándar de Odoo, SAP Fiori, MS Dynamics.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
html, body {
    margin: 0;
    padding: 0;
    height: 100%;
    overflow: hidden; /* ← FIX #1: el body nunca scrollea */
}
body {
    background: #f4f6f9;
    font-family: system-ui, -apple-system, sans-serif;
}

/* ══════════════════════════════════════════
   TOP NAV
══════════════════════════════════════════ */
.top-nav {
    position: fixed;
    top: 0; left: 0; right: 0;
    height: 60px;
    z-index: 1000;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    box-shadow: 0 2px 10px rgba(0,0,0,.2);
    display: flex;
    align-items: center;
    padding: 0 16px;
    gap: 12px;
}

.menu-toggle-btn {
    display: none;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    background: none;
    border: none;
    color: #fff;
    font-size: 1.4rem;
    cursor: pointer;
    padding: 6px 8px;
    border-radius: 6px;
    transition: background .2s;
    line-height: 1;
}
.menu-toggle-btn:hover { background: rgba(255,255,255,.12); }

.top-nav-logo {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-shrink: 0;
    color: #fff;
    font-weight: 700;
    font-size: 1.1rem;
    margin-right: 8px;
    text-decoration: none;
}
.top-nav-logo i { font-size: 1.4rem; color: #00d9ff; }

.nav-scroll-wrapper {
    flex: 1;
    min-width: 0;
    display: flex;
    align-items: center;
    overflow: hidden;
}

.top-nav-menu {
    display: flex;
    list-style: none;
    margin: 0; padding: 0;
    gap: 4px;
    flex-shrink: 0;
}
.top-nav-menu li a {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 7px 14px;
    color: #bbb;
    text-decoration: none;
    border-radius: 8px;
    font-size: 0.86rem;
    font-weight: 500;
    white-space: nowrap;
    transition: background .2s, color .2s;
}
.top-nav-menu li a:hover  { background: rgba(255,255,255,.09); color: #fff; }
.top-nav-menu li a.active { background: #00d9ff; color: #1a1a2e; font-weight: 600; }

/* ══════════════════════════════════════════
   BOTÓN "MÁS"
══════════════════════════════════════════ */
#navMoreContainer { flex-shrink: 0; margin-left: 2px; }

.nav-more-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 11px;
    background: rgba(255,255,255,.08);
    border: 1px solid rgba(255,255,255,.2);
    color: #fff;
    border-radius: 8px;
    font-size: 0.84rem;
    font-weight: 500;
    cursor: pointer;
    white-space: nowrap;
    user-select: none;
    transform: none;
    transition: background .2s, border-color .2s;
    line-height: 1;
}
.nav-more-btn:hover { background: rgba(255,255,255,.15); border-color: rgba(255,255,255,.35); }
.nav-more-btn.is-open { background: rgba(255,255,255,.18); border-color: rgba(255,255,255,.4); }

.nav-more-badge {
    background: #00d9ff;
    color: #1a1a2e;
    border-radius: 10px;
    font-size: 0.70rem;
    font-weight: 700;
    padding: 2px 7px;
    min-width: 20px;
    text-align: center;
    line-height: 1.4;
}
.nav-more-chevron {
    font-size: 0.65rem;
    opacity: .7;
    transition: transform .2s;
}
.nav-more-btn.is-open .nav-more-chevron { transform: rotate(180deg); opacity: 1; }

#navMoreDropdown {
    position: fixed;
    min-width: 220px;
    padding: 6px;
    background: #1a2535;
    border: 1px solid rgba(255,255,255,.13);
    border-radius: 10px;
    box-shadow: 0 10px 32px rgba(0,0,0,.5);
    z-index: 2000;
    list-style: none;
    margin: 0;
    display: none;
}
#navMoreDropdown li a {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 9px 13px;
    color: #ccc;
    border-radius: 7px;
    font-size: 0.85rem;
    white-space: nowrap;
    text-decoration: none;
    transition: background .15s, color .15s;
}
#navMoreDropdown li a:hover  { background: rgba(255,255,255,.09); color: #fff; }
#navMoreDropdown li a.active { background: #00d9ff; color: #1a1a2e; font-weight: 600; }

/* ══════════════════════════════════════════
   BOTÓN USUARIO
══════════════════════════════════════════ */
.top-nav-user { position: relative; flex-shrink: 0; background: none; }

.user-btn {
    all: unset;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 0;
    color: #fff;
    font-size: 0.88rem;
    font-weight: 500;
    cursor: pointer;
    white-space: nowrap;
    line-height: 1;
    box-sizing: border-box;
    opacity: 1;
    transition: opacity .2s;
}
.user-btn:hover  { opacity: .8; }
.user-btn:focus, .user-btn:active { outline: none; box-shadow: none; opacity: .8; }

.u-avatar-desktop {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 26px; height: 26px;
    border-radius: 50%;
    background: #00d9ff;
    color: #1a1a2e;
    font-size: 0.72rem;
    font-weight: 700;
    flex-shrink: 0;
    line-height: 1;
}
.u-avatar {
    display: none;
    width: 32px; height: 32px;
    border-radius: 50%;
    background: #00d9ff;
    color: #1a1a2e;
    font-size: 0.82rem;
    font-weight: 700;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    line-height: 1;
}

.u-chevron {
    font-size: 0.70rem;
    opacity: .7;
    transition: transform .2s;
}
.user-btn[aria-expanded="true"] .u-chevron { transform: rotate(180deg); opacity: 1; }

.user-dropdown-menu {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    min-width: 200px;
    background: #1a2535;
    border: 1px solid rgba(255,255,255,.13);
    border-radius: 10px;
    box-shadow: 0 10px 32px rgba(0,0,0,.5);
    z-index: 2000;
    padding: 6px;
    display: none;
    list-style: none;
    margin: 0;
}
.user-dropdown-menu.show { display: block; }
.user-dropdown-menu .u-name-label {
    padding: 8px 12px 6px;
    font-size: 0.75rem;
    color: #888;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: .04em;
}
.user-dropdown-menu hr { margin: 4px 0; border-color: rgba(255,255,255,.1); }
.user-dropdown-menu li a {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 9px 13px;
    color: #ccc;
    border-radius: 7px;
    font-size: 0.85rem;
    text-decoration: none;
    transition: background .15s, color .15s;
}
.user-dropdown-menu li a:hover       { background: rgba(255,255,255,.09); color: #fff; }
.user-dropdown-menu li a.text-danger { color: #ff6b6b; }
.user-dropdown-menu li a.text-danger:hover { background: rgba(255,80,80,.15); color: #ff4444; }

/* ══════════════════════════════════════════
   LAYOUT PRINCIPAL — FIX CRÍTICO
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ANTES: min-height: calc(100vh - 60px)
     → el body crecía y generaba scroll global
   AHORA: height fijo + overflow hidden
     → "shell" que no desborda nunca
══════════════════════════════════════════ */
.app-layout {
    display: flex;
    margin-top: 60px;
    height: calc(100vh - 60px); /* ← FIX #2: height fijo, no min-height */
    overflow: hidden;           /* ← FIX #2: contiene a sus hijos */
}

/* ══════════════════════════════════════════
   SIDEBAR IZQUIERDO — FIX CRÍTICO
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ANTES: sin height → el sidebar no tenía límite vertical
     → cuando el contenido era corto, el scroll
        aparecía en toda la página
   AHORA: height: 100% → el sidebar ocupa exactamente
     el espacio del .app-layout y scrollea de forma
     independiente solo cuando sus items lo necesitan
══════════════════════════════════════════ */
.sidebar-left {
    width: 280px;
    height: 100%;              /* ← FIX #3: limita el sidebar al contenedor */
    flex-shrink: 0;
    background: #fff;
    border-right: 1px solid #e8eaf0;
    box-shadow: 2px 0 8px rgba(0,0,0,.05);
    overflow-y: auto;          /* scrollea solo si sus items lo necesitan */
    transition: transform .3s ease;
}
.sidebar-header {
    padding: 18px 20px 14px;
    border-bottom: 1px solid #eee;
    background: #fafbfc;
}
.sidebar-header h5 {
    margin: 0;
    font-size: 0.95rem;
    font-weight: 600;
    color: #1a1a2e;
}
.sidebar-header h5 i { color: #00d9ff; margin-right: 7px; }
.sidebar-header p { margin: 4px 0 0; font-size: 0.73rem; color: #999; }

.sidebar-menu { list-style: none; margin: 0; padding: 8px 0; }
.sidebar-menu li a {
    display: flex;
    align-items: center;
    gap: 11px;
    padding: 11px 20px;
    color: #555;
    text-decoration: none;
    font-size: 0.88rem;
    border-left: 3px solid transparent;
    transition: background .15s, border-color .15s, color .15s;
}
.sidebar-menu li a:hover  { background: #f4f7ff; border-left-color: #00d9ff; color: #1a1a2e; }
.sidebar-menu li a.active { background: #e6f2ff; border-left-color: #00aaff; color: #0077cc; font-weight: 600; }

.sidebar-menu .has-nietos > a::after {
    content: "›";
    margin-left: auto;
    font-size: 1.1rem;
    color: #bbb;
    transition: transform .2s;
}
.sidebar-menu .has-nietos.open > a::after { transform: rotate(90deg); }

.nietos-menu { display: none; list-style: none; margin: 0; padding: 0 0 4px 44px; background: #f8f9fc; }
.nietos-menu.show { display: block; }
.nietos-menu li a { padding: 9px 14px; font-size: 0.82rem; border-left: none; }
.nietos-menu li a:hover  { background: #eef3ff; color: #1a1a2e; }
.nietos-menu li a.active { color: #0077cc; font-weight: 600; }

.sidebar-empty { padding: 40px 20px; text-align: center; color: #bbb; }
.sidebar-empty i { font-size: 2rem; display: block; margin-bottom: 8px; }

/* ══════════════════════════════════════════
   ÁREA PRINCIPAL — FIX CRÍTICO
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ANTES: sin height → el área crecía infinitamente
   AHORA: height: 100% + overflow-y: auto
     → el contenido scrollea dentro de su zona,
        nunca arrastra al resto del layout
══════════════════════════════════════════ */
.main-area {
    flex: 1;
    height: 100%;              /* ← FIX #4: limita el área al contenedor */
    padding: 24px;
    overflow-y: auto;          /* scrollea solo el contenido del módulo */
    min-width: 0;
}
.content-card {
    background: #fff;
    border-radius: 12px;
    padding: 28px;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
    min-height: 200px;
}

/* ══════════════════════════════════════════
   OVERLAY MÓVIL
══════════════════════════════════════════ */
.mobile-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 998; }
.mobile-overlay.active { display: block; }

/* ══════════════════════════════════════════
   RESPONSIVE — TABLET (≤992px)
══════════════════════════════════════════ */
@media (max-width: 992px) {
    .top-nav-menu li a { padding: 7px 10px; font-size: 0.82rem; }
    .sidebar-left { width: 250px; }
}

/* ══════════════════════════════════════════
   RESPONSIVE — MÓVIL (≤768px)
══════════════════════════════════════════ */
@media (max-width: 768px) {
    .menu-toggle-btn { display: flex; }

    .sidebar-left {
        position: fixed;
        top: 60px; left: 0; bottom: 0;
        z-index: 999;
        width: 270px;
        height: calc(100vh - 60px); /* en móvil también es fijo */
        transform: translateX(-100%);
    }
    .sidebar-left.mobile-open { transform: translateX(0); }

    .top-nav-logo .logo-text { display: none; }
    .top-nav-logo { margin-right: 0; }

    .top-nav { gap: 10px; padding: 0 12px; }
    .top-nav-menu { gap: 6px; }
    .top-nav-menu li a { padding: 8px 10px; gap: 0; justify-content: center; }
    .top-nav-menu li a .nav-label { display: none; }
    .top-nav-menu li a i { margin: 0; font-size: 1rem; }

    .nav-more-btn {
        padding: 0;
        gap: 0;
        width: 32px; height: 32px;
        justify-content: center;
        border: 1px solid rgba(255,255,255,.25);
        background: rgba(255,255,255,.08);
        border-radius: 8px;
        position: relative;
        margin-left: 4px;
    }
    .nav-more-btn:hover { background: rgba(255,255,255,.18); }
    .nav-more-btn .bi-grid-3x3-gap-fill { font-size: 0.92rem; }
    .nav-more-text, .nav-more-chevron { display: none; }
    .nav-more-badge {
        position: absolute;
        top: -5px; right: -5px;
        padding: 0 4px;
        font-size: 0.55rem;
        min-width: 14px;
        line-height: 1.8;
        border-radius: 6px;
    }

    .top-nav-user {
        background: none !important;
        display: flex;
        align-items: center;
    }
    .user-btn {
        all: unset;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0;
        gap: 0;
        margin-left: 8px;
        background: none !important;
        border: none !important;
        box-shadow: none !important;
        width: 32px;
        height: 32px;
        border-radius: 50% !important;
        opacity: 1;
    }
    .user-btn:hover { opacity: .85; background: none !important; }
    .user-btn .u-name, .user-btn .u-chevron, .u-avatar-desktop { display: none !important; }
    .u-avatar {
        display: inline-flex;
        width: 32px; height: 32px;
        min-width: 32px; min-height: 32px;
        border-radius: 50%;
        font-size: 0.78rem;
        line-height: 1;
    }
}

/* ══════════════════════════════════════════
   RESPONSIVE — MÓVIL PEQUEÑO (≤480px)
══════════════════════════════════════════ */
@media (max-width: 480px) {
    .top-nav { padding: 0 6px; gap: 4px; }
    .main-area { padding: 14px; }
    .content-card { padding: 18px; }
    .top-nav-menu { gap: 1px; }
    .top-nav-menu li a { padding: 8px 7px; }
}
</style>
</head>
<body>

<div class="top-nav">

    <!-- sidebar.js inserta .menu-toggle-btn aquí -->

    <a href="?" class="top-nav-logo">
        <i class="bi bi-grid-1x2-fill"></i>
        <span class="logo-text">ADSOERP</span>
    </a>

    <div class="nav-scroll-wrapper" id="navScrollWrapper">
        <ul class="top-nav-menu" id="topNavMenu">
            <?php foreach ($menu_final as $padre): ?>
            <li>
                <a href="?padre=<?= $padre['id_menu'] ?>"
                   class="<?= ($padre_activo_id == $padre['id_menu']) ? 'active' : '' ?>"
                   title="<?= htmlspecialchars($padre['nom_menu']) ?>">
                    <i class="bi <?= getIcon($padre['nom_menu']) ?>"></i>
                    <span class="nav-label"><?= htmlspecialchars($padre['nom_menu']) ?></span>
                </a>
            </li>
            <?php endforeach; ?>
        </ul>
    </div>

    <div id="navMoreContainer" style="display:none; flex-shrink:0;">
        <div class="nav-more-btn"
             id="navMoreBtn"
             role="button"
             tabindex="0"
             aria-expanded="false"
             aria-haspopup="true">
            <i class="bi bi-grid-3x3-gap-fill"></i>
            <span class="nav-more-text">Más</span>
            <span class="nav-more-badge" id="navMoreBadge">0</span>
            <i class="bi bi-chevron-down nav-more-chevron"></i>
        </div>
        <ul id="navMoreDropdown"></ul>
    </div>

    <div class="top-nav-user">
        <div class="user-btn"
             id="userBtn"
             role="button"
             tabindex="0"
             aria-expanded="false"
             aria-haspopup="true"
             title="<?= htmlspecialchars($wnom_usuario) ?>">
            <span class="u-avatar-desktop" aria-hidden="true"><?= $inicial ?></span>
            <span class="u-name"><?= strtoupper(htmlspecialchars($wnom_usuario)) ?></span>
            <i class="bi bi-chevron-down u-chevron"></i>
            <span class="u-avatar" aria-hidden="true"><?= $inicial ?></span>
        </div>

        <ul class="user-dropdown-menu" id="userDropdownMenu" aria-labelledby="userBtn">
            <li>
                <div class="u-name-label"><?= htmlspecialchars($wnom_usuario) ?></div>
            </li>
            <li><hr></li>
            <li>
                <a href="cambiar_clave.php">
                    <i class="bi bi-key"></i> Cambiar Contraseña
                </a>
            </li>
            <li><hr></li>
            <li>
                <a href="logout.php" class="text-danger">
                    <i class="bi bi-box-arrow-right"></i> Cerrar Sesión
                </a>
            </li>
        </ul>
    </div>

</div><!-- /top-nav -->

<div class="app-layout">

    <aside class="sidebar-left">
        <div class="sidebar-header">
            <h5>
                <i class="bi bi-menu-button-wide-fill"></i>
                <?= htmlspecialchars($nombre_padre_activo) ?>
            </h5>
            <p>Seleccione una opción</p>
        </div>

        <?php if (count($hijos_activos) > 0): ?>
        <ul class="sidebar-menu">
            <?php foreach ($hijos_activos as $hijo):
                $tiene_nietos = !empty($hijo['items']); ?>
            <li class="<?= $tiene_nietos ? 'has-nietos' : '' ?> <?= ($hijo_activo_id == $hijo['id_menu']) ? 'open' : '' ?>">
                <a href="<?= $tiene_nietos ? '#' : '?padre='.$padre_activo_id.'&hijo='.$hijo['id_menu'] ?>"
                   class="<?= ($hijo_activo_id == $hijo['id_menu']) ? 'active' : '' ?>"
                   <?= $tiene_nietos ? 'data-toggle-nietos' : '' ?>>
                    <i class="bi <?= getIcon($hijo['nom_menu']) ?>"></i>
                    <?= htmlspecialchars($hijo['nom_menu']) ?>
                </a>
                <?php if ($tiene_nietos): ?>
                <ul class="nietos-menu <?= ($hijo_activo_id == $hijo['id_menu']) ? 'show' : '' ?>">
                    <?php foreach ($hijo['items'] as $nieto): ?>
                    <li>
                        <a href="?padre=<?= $padre_activo_id ?>&hijo=<?= $hijo['id_menu'] ?>&nieto=<?= $nieto['id_menu'] ?>"
                           class="<?= ($nieto_activo_id == $nieto['id_menu']) ? 'active' : '' ?>">
                            <i class="bi <?= getIcon($nieto['nom_menu']) ?>"></i>
                            <?= htmlspecialchars($nieto['nom_menu']) ?>
                        </a>
                    </li>
                    <?php endforeach; ?>
                </ul>
                <?php endif; ?>
            </li>
            <?php endforeach; ?>
        </ul>
        <?php else: ?>
        <div class="sidebar-empty">
            <i class="bi bi-inbox"></i>
            <span>No hay opciones disponibles</span>
        </div>
        <?php endif; ?>
    </aside>

    <div class="main-area">
        <div class="content-card">
            <?php if (!empty($contenido_modulo)):
                echo $contenido_modulo;
            elseif ($show_welcome): ?>
            <h2 style="color:#1a1a2e;">
                <i class="bi bi-person-check-fill" style="color:#00d9ff;"></i>
                Bienvenido, <?= htmlspecialchars($wnom_usuario) ?>!
            </h2>
            <p class="text-muted">Has ingresado al sistema de gestión. Selecciona una opción del menú lateral para comenzar.</p>
            <hr>
            <div class="row mt-4 g-3">
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm text-center p-4">
                        <i class="bi bi-people" style="font-size:2rem;color:#00d9ff;"></i>
                        <h6 class="mt-2 mb-1">Gestión de Usuarios</h6>
                        <small class="text-muted">Administre accesos y perfiles</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm text-center p-4">
                        <i class="bi bi-calculator" style="font-size:2rem;color:#00d9ff;"></i>
                        <h6 class="mt-2 mb-1">Procesos de Nómina</h6>
                        <small class="text-muted">Cálculo y liquidación</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm text-center p-4">
                        <i class="bi bi-file-text" style="font-size:2rem;color:#00d9ff;"></i>
                        <h6 class="mt-2 mb-1">Reportes</h6>
                        <small class="text-muted">Consultas y análisis</small>
                    </div>
                </div>
            </div>
            <?php endif; ?>
        </div>
    </div>

</div><!-- /app-layout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* ══════════════════════════════════════════════════════════
   NAV OVERFLOW — Priority+ Navigation
══════════════════════════════════════════════════════════ */
(function () {
    var topNav        = document.querySelector('.top-nav');
    var menu          = document.getElementById('topNavMenu');
    var moreContainer = document.getElementById('navMoreContainer');
    var moreBtn       = document.getElementById('navMoreBtn');
    var moreBadge     = document.getElementById('navMoreBadge');
    var moreDropdown  = document.getElementById('navMoreDropdown');

    if (!menu || !moreContainer) return;

    var items  = Array.from(menu.querySelectorAll('li'));
    var isOpen = false;

    function getAvailableWidth() {
        var isMobile = window.innerWidth <= 768;
        var logoEl   = document.querySelector('.top-nav-logo');
        var userEl   = document.querySelector('.top-nav-user');
        var togEl    = document.querySelector('.menu-toggle-btn');
        var logoW    = logoEl ? logoEl.offsetWidth + 8  : 0;
        var userW    = userEl ? userEl.offsetWidth + 12 : 0;
        var togW     = togEl && getComputedStyle(togEl).display !== 'none' ? togEl.offsetWidth + 12 : 0;
        var moreW    = isMobile ? 40 : 128;
        var padW     = isMobile ? 12 : 32;
        return topNav.offsetWidth - logoW - userW - togW - moreW - padW;
    }

    function positionDropdown() {
        var rect = moreBtn.getBoundingClientRect();
        moreDropdown.style.top  = (rect.bottom + 6) + 'px';
        var left = rect.right - moreDropdown.offsetWidth;
        moreDropdown.style.left = Math.max(8, left) + 'px';
    }

    function openMore() {
        if (typeof window._closeUserDropdown === 'function') window._closeUserDropdown();
        moreDropdown.style.display = 'block';
        isOpen = true;
        moreBtn.setAttribute('aria-expanded', 'true');
        moreBtn.classList.add('is-open');
        requestAnimationFrame(positionDropdown);
    }
    function closeMore() {
        moreDropdown.style.display = 'none';
        isOpen = false;
        moreBtn.setAttribute('aria-expanded', 'false');
        moreBtn.classList.remove('is-open');
    }

    moreBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        isOpen ? closeMore() : openMore();
    });
    moreBtn.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); isOpen ? closeMore() : openMore(); }
    });
    document.addEventListener('click', function (e) {
        if (isOpen && !moreContainer.contains(e.target)) closeMore();
    });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && isOpen) closeMore();
    });
    window.addEventListener('scroll', function () { if (isOpen) positionDropdown(); }, true);
    window.addEventListener('resize',  function () { if (isOpen) positionDropdown(); });

    function compute() {
        if (isOpen) closeMore();

        items.forEach(function (li) {
            li.style.visibility = 'hidden';
            li.style.display    = '';
        });
        moreContainer.style.display = 'none';
        moreDropdown.innerHTML = '';

        var available = getAvailableWidth();
        var total = 0, cutFrom = -1;

        for (var i = 0; i < items.length; i++) {
            total += items[i].offsetWidth + 4;
            if (cutFrom < 0 && total > available) { cutFrom = i; }
        }

        items.forEach(function (li) { li.style.visibility = ''; });

        if (cutFrom < 0) return;

        items.slice(cutFrom).forEach(function (li) { li.style.display = 'none'; });
        moreContainer.style.display = 'flex';
        moreBadge.textContent = items.length - cutFrom;

        items.slice(cutFrom).forEach(function (li) {
            var a    = li.querySelector('a');
            var ddLi = document.createElement('li');
            var ddA  = document.createElement('a');
            ddA.href      = a.href;
            ddA.innerHTML = a.innerHTML;
            ddA.className = a.classList.contains('active') ? 'active' : '';
            ddA.addEventListener('click', closeMore);
            ddLi.appendChild(ddA);
            moreDropdown.appendChild(ddLi);
        });
    }

    if (window.ResizeObserver) {
        new ResizeObserver(compute).observe(topNav);
    } else {
        window.addEventListener('resize', compute);
    }
    document.fonts && document.fonts.ready
        ? document.fonts.ready.then(compute)
        : setTimeout(compute, 200);
})();

/* ══════════════════════════════════════════════════════════
   DROPDOWN USUARIO
══════════════════════════════════════════════════════════ */
(function () {
    var btn  = document.getElementById('userBtn');
    var menu = document.getElementById('userDropdownMenu');
    if (!btn || !menu) return;

    function openUser() {
        var moreBtn      = document.getElementById('navMoreBtn');
        var moreDropdown = document.getElementById('navMoreDropdown');
        if (moreDropdown && moreDropdown.style.display === 'block') {
            moreDropdown.style.display = 'none';
            if (moreBtn) { moreBtn.setAttribute('aria-expanded','false'); moreBtn.classList.remove('is-open'); }
        }
        menu.classList.add('show');
        btn.setAttribute('aria-expanded', 'true');
    }
    function closeUser() {
        menu.classList.remove('show');
        btn.setAttribute('aria-expanded', 'false');
    }

    btn.addEventListener('click', function (e) {
        e.stopPropagation();
        menu.classList.contains('show') ? closeUser() : openUser();
    });
    btn.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); menu.classList.contains('show') ? closeUser() : openUser(); }
    });
    document.addEventListener('click', function (e) {
        if (!btn.closest('.top-nav-user').contains(e.target)) closeUser();
    });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeUser();
    });

    window._closeUserDropdown = closeUser;
})();

/* ══════════════════════════════════════════════════════════
   TOGGLE SUBMENÚS DE TERCER NIVEL (nietos)
══════════════════════════════════════════════════════════ */
document.querySelectorAll('[data-toggle-nietos]').forEach(function (link) {
    link.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
        var li  = this.closest('li.has-nietos');
        var sub = li && li.querySelector('.nietos-menu');
        if (sub) { sub.classList.toggle('show'); li.classList.toggle('open'); }
    }, true);
});
</script>
</body>
</html>