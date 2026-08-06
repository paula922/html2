<?php
// ========== PERSONALIZAR PÁGINA ==========
$page_title = "ADSOERP | Explorador de Menús";
$page_description = "Estructura completa del sistema (vista de administrador)";
$page_icon = "bi-diagram-3";
$page_extra_css = [];
$page_extra_js = [];
$show_welcome = false;
// ==========================================

if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

// ============================================
// VERIFICAR COLUMNA DESCRIPCION
// ============================================
try {
    $check = $pdo->query("SELECT column_name FROM information_schema.columns WHERE table_name = 'tab_menus' AND column_name = 'descripcion'");
    if ($check->rowCount() == 0) {
        $pdo->exec("ALTER TABLE tab_menus ADD COLUMN descripcion TEXT");
    }
} catch (PDOException $e) {
    // Columna ya existe
}

// ============================================
// OBTENER TODOS LOS MENÚS
// ============================================
$stmt = $pdo->query("
    SELECT id_menu, nom_menu, ind_id_padre, nom_programa, COALESCE(descripcion, '') as descripcion 
    FROM tab_menus 
    ORDER BY 
        CASE WHEN ind_id_padre = '0' THEN 0 ELSE 1 END,
        ind_id_padre, 
        id_menu
");
$menus_raw = $stmt->fetchAll();

// ============================================
// CONSTRUIR ÁRBOL COMPLETO
// ============================================
function buildCompleteTree($items, $parentId = '0') {
    $children = [];
    foreach ($items as $item) {
        $children[$item['ind_id_padre']][] = $item;
    }
    
    function buildBranch($parentId, &$children, $level = 0) {
        $branch = [];
        if (isset($children[$parentId])) {
            foreach ($children[$parentId] as $item) {
                $item['level'] = $level;
                $item['children'] = buildBranch($item['id_menu'], $children, $level + 1);
                $branch[] = $item;
            }
        }
        return $branch;
    }
    
    $tree = buildBranch($parentId, $children, 0);
    
    $existingIds = array_column($items, 'id_menu');
    $orphans = [];
    foreach ($items as $item) {
        if ($item['ind_id_padre'] != '0' && !in_array($item['ind_id_padre'], $existingIds)) {
            $item['level'] = 0;
            $item['is_orphan'] = true;
            $orphans[] = $item;
        }
    }
    
    return array_merge($tree, $orphans);
}

$menu_tree = buildCompleteTree($menus_raw);
$total_menus = count($menus_raw);
$total_huerfanos = count(array_filter($menu_tree, function($item) {
    return isset($item['is_orphan']) && $item['is_orphan'] === true;
}));

$f_id = "";
$f_nom = "";
$f_padre = "0";
$f_programa = "";
$f_descripcion = "";
$f_id_readonly = false;
$w_mensaje = "";
$w_tipo_alerta = "";

// ============================================
// PROCESAR POST - CON ELIMINACIÓN EN CASCADA
// ============================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $redirect_url = 'menu_principal.php';
    $params = [];
    if (!empty($_POST['_padre'])) $params[] = 'padre=' . (int)$_POST['_padre'];
    if (!empty($_POST['_hijo'])) $params[] = 'hijo=' . (int)$_POST['_hijo'];
    if (!empty($_POST['_nieto'])) $params[] = 'nieto=' . (int)$_POST['_nieto'];
    if ($params) $redirect_url .= '?' . implode('&', $params);

    try {
        if (isset($_POST['btn_guardar'])) {
            $w_id = trim($_POST['txt_id_menu']);
            $w_nom = trim($_POST['txt_nom_menu']);
            $w_padre = trim($_POST['txt_id_padre'] ?? '0');
            $w_programa = trim($_POST['txt_nom_programa'] ?? '');
            $w_descripcion = trim($_POST['txt_descripcion'] ?? '');

            if (empty($w_id)) throw new Exception("El ID es obligatorio.");
            if (empty($w_nom)) throw new Exception("El nombre es obligatorio.");
            if (preg_match('/\s/', $w_id)) throw new Exception("El ID no puede contener espacios.");
            
            if ($w_padre != '0') {
                $stmt_check_padre = $pdo->prepare("SELECT COUNT(*) FROM tab_menus WHERE id_menu = ?");
                $stmt_check_padre->execute([$w_padre]);
                if ($stmt_check_padre->fetchColumn() == 0) {
                    throw new Exception("El menú padre seleccionado no existe.");
                }
            }

            $stmt_check = $pdo->prepare("SELECT COUNT(*) FROM tab_menus WHERE id_menu = ?");
            $stmt_check->execute([$w_id]);
            $existe = $stmt_check->fetchColumn();

            if ($existe) {
                $stmt = $pdo->prepare("UPDATE tab_menus SET nom_menu=?, ind_id_padre=?, nom_programa=?, descripcion=? WHERE id_menu = ?");
                $stmt->execute([$w_nom, $w_padre, $w_programa, $w_descripcion, $w_id]);
                $w_mensaje = "✅ Menú actualizado correctamente.";
            } else {
                $stmt = $pdo->prepare("INSERT INTO tab_menus (id_menu, nom_menu, ind_id_padre, nom_programa, descripcion) VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([$w_id, $w_nom, $w_padre, $w_programa, $w_descripcion]);
                $w_mensaje = "✅ Menú creado correctamente.";
            }
            $w_tipo_alerta = "success";
            echo "<script>window.location.href='$redirect_url';</script>";
            exit();
        }

        if (isset($_POST['btn_eliminar'])) {
            $w_id = $_POST['hid_id_menu'];
            $w_password = $_POST['txt_password'] ?? '';
            
            $usuario_actual = $_SESSION['id_usuario'] ?? null;
            if (!$usuario_actual) {
                throw new Exception("No hay sesión activa.");
            }
            
            $stmt_pass = $pdo->prepare("SELECT pass_usuario FROM tab_usuarios WHERE id_usuario = ?");
            $stmt_pass->execute([$usuario_actual]);
            $hash_actual = $stmt_pass->fetchColumn();
            
            if (!$hash_actual || !password_verify($w_password, $hash_actual)) {
                throw new Exception("❌ Contraseña incorrecta.");
            }
            
            // 🔥 ELIMINACIÓN EN CASCADA 🔥
            $stmt_cascada = $pdo->prepare("SELECT fun_delete_menu_cascada(?)");
            $stmt_cascada->execute([$w_id]);
            $resultado = $stmt_cascada->fetchColumn();
            
            $w_mensaje = "✅ " . $resultado;
            $w_tipo_alerta = "success";
            echo "<script>window.location.href='$redirect_url';</script>";
            exit();
        }
    } catch (Exception $e) {
        $w_mensaje = $e->getMessage();
        $w_tipo_alerta = "danger";
    }
}
?>

<link rel="stylesheet" href="../src/css/menus.css">

<style>
/* ============================================
   ESTILOS ADICIONALES PARA MODALES
   ============================================ */
.modal-pass-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(4px);
    align-items: center;
    justify-content: center;
    z-index: 1001;
}
.modal-pass-overlay.show { display: flex; }
.modal-pass-card {
    background: white;
    border-radius: 24px;
    max-width: 400px;
    width: 90%;
    overflow: hidden;
    animation: fadeInScale 0.2s ease;
}
@keyframes fadeInScale {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}
.modal-pass-header {
    background: linear-gradient(135deg, #ef4444, #dc2626);
    padding: 1rem 1.25rem;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.modal-pass-header h3 { margin: 0; font-size: 1rem; }
.modal-pass-header h3 i { margin-right: 0.5rem; }
.modal-pass-body { padding: 1.25rem; }
.modal-pass-footer { padding: 1rem 1.25rem; border-top: 1px solid #e2e8f0; display: flex; gap: 0.75rem; }

.modal-info-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(4px);
    align-items: center;
    justify-content: center;
    z-index: 1002;
}
.modal-info-overlay.show { display: flex; }
.modal-info-card {
    background: white;
    border-radius: 24px;
    max-width: 420px;
    width: 90%;
    overflow: hidden;
    animation: fadeInScale 0.2s ease;
}
.modal-info-header {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    padding: 1rem 1.25rem;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.modal-info-header h3 { margin: 0; font-size: 1rem; }
.modal-info-body { padding: 1.25rem; }
.modal-info-footer { padding: 1rem 1.25rem; border-top: 1px solid #e2e8f0; text-align: center; }

.info-desc-box {
    background: #f0fdf4;
    border-radius: 12px;
    padding: 1rem;
    border-left: 3px solid #10b981;
}
.info-desc-text { font-size: 0.85rem; color: #065f46; line-height: 1.5; margin-top: 0.5rem; }

.pass-warning {
    background: #fef2f2;
    border-left: 3px solid #ef4444;
    border-radius: 10px;
    padding: 0.75rem;
    margin-bottom: 1rem;
    font-size: 0.75rem;
    color: #991b1b;
}
.pass-warning i { margin-right: 0.3rem; }
.pass-input-group {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    background: #f8fafc;
    border-radius: 10px;
    padding: 0.2rem 0.7rem;
    border: 1px solid #e2e8f0;
}
.pass-input-group input {
    flex: 1;
    border: none;
    background: none;
    padding: 0.6rem 0;
    outline: none;
}
.pass-toggle { background: none; border: none; cursor: pointer; color: #64748b; }
.pass-error { color: #dc2626; font-size: 0.7rem; margin-top: 0.5rem; display: none; }

.btn-pass-cancel, .btn-pass-confirm {
    flex: 1;
    padding: 0.6rem;
    border-radius: 30px;
    cursor: pointer;
    text-align: center;
}
.btn-pass-cancel { border: 1px solid #e2e8f0; background: white; }
.btn-pass-confirm { border: none; background: #ef4444; color: white; }
.btn-info-close {
    background: linear-gradient(135deg, #1e293b, #334155);
    color: white;
    border: none;
    padding: 0.5rem 1.5rem;
    border-radius: 30px;
    cursor: pointer;
}

.modal-close-btn {
    background: rgba(255,255,255,0.1);
    border: none;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    color: white;
    cursor: pointer;
}
.modal-close-btn:hover { background: rgba(255,255,255,0.2); }
</style>

<div class="menu-explorer">
    <!-- Cabecera -->
    <div class="menu-explorer-header">
        <div class="menu-stats">
            <span><i class="bi bi-folder-fill" style="color:#f59e0b;"></i> <span id="totalFolders">0</span> carpetas</span>
            <span><i class="bi bi-file-text-fill" style="color:#64748b;"></i> <span id="totalFiles">0</span> ítems</span>
            <span><i class="bi bi-diagram-3"></i> <span id="totalMenus"><?= $total_menus ?></span> total</span>
            <?php if ($total_huerfanos > 0): ?>
                <span class="badge-orphan"><i class="bi bi-exclamation-triangle-fill"></i> <?= $total_huerfanos ?> huérfanos</span>
            <?php endif; ?>
        </div>
        
        <div class="menu-actions">
            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" id="searchInput" placeholder="Buscar por ID o nombre..." onkeyup="filtrarArbol()">
            </div>
            <button class="action-btn" onclick="expandirTodo()" title="Expandir todo">
                <i class="bi bi-plus-square"></i> Expandir
            </button>
            <button class="action-btn" onclick="contraerTodo()" title="Contraer todo">
                <i class="bi bi-dash-square"></i> Contraer
            </button>
            <button class="action-btn btn-add" onclick="abrirModal()">
                <i class="bi bi-plus-circle"></i> Nuevo Menú
            </button>
        </div>
    </div>
    
    <!-- Mensajes de alerta -->
    <?php if ($w_mensaje): ?>
        <div style="padding: 12px 20px 0 20px;">
            <div class="alert alert-<?= $w_tipo_alerta ?> alert-dismissible fade show">
                <i class="bi <?= $w_tipo_alerta === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill' ?>"></i>
                <?= htmlspecialchars($w_mensaje) ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert">&times;</button>
            </div>
        </div>
    <?php endif; ?>
    
    <!-- Árbol de menús -->
    <div class="tree-container" id="treeContainer">
        <ul class="tree-root" id="treeRoot">
            <?php
            function renderExplorerTree($nodes, $level = 0) {
                $html = '';
                foreach ($nodes as $node) {
                    $hasChildren = !empty($node['children']);
                    $isOrphan = isset($node['is_orphan']) && $node['is_orphan'] === true;
                    $programa = !empty($node['nom_programa']) && $node['nom_programa'] != 'no_aplica' 
                        ? htmlspecialchars($node['nom_programa']) : null;
                    $isRoot = ($node['ind_id_padre'] == '0');
                    $nodeId = 'node_' . $node['id_menu'];
                    $descripcion = htmlspecialchars($node['descripcion'] ?? '');
                    
                    $html .= '<li id="' . $nodeId . '" data-id="' . htmlspecialchars($node['id_menu']) . '"
                              data-nom="' . strtolower(htmlspecialchars($node['nom_menu'])) . '"
                              data-prog="' . strtolower(htmlspecialchars($node['nom_programa'] ?? '')) . '"
                              data-desc="' . addslashes($descripcion) . '"
                              data-type="' . ($hasChildren ? 'folder' : 'file') . '"
                              data-parent="' . htmlspecialchars($node['ind_id_padre']) . '">';
                    
                    $html .= '<div class="tree-node" onclick="toggleNodeClick(event, this, \'' . $nodeId . '\')">';
                    $html .= '<div class="tree-node-content">';
                    
                    for ($i = 0; $i < $level; $i++) {
                        $html .= '<span class="tree-indent"></span>';
                    }
                    
                    if ($hasChildren) {
                        $html .= '<span class="tree-toggle" onclick="event.stopPropagation(); toggleNode(this, \'' . $nodeId . '\')">
                                    <i class="bi bi-chevron-right"></i>
                                  </span>';
                    } else {
                        $html .= '<span class="tree-toggle" style="visibility:hidden;"></span>';
                    }
                    
                    if ($hasChildren) {
                        $html .= '<span class="tree-icon folder-icon"><i class="bi bi-folder-fill"></i></span>';
                    } else {
                        $html .= '<span class="tree-icon file-icon"><i class="bi bi-file-text-fill"></i></span>';
                    }
                    
                    $html .= '<div class="tree-info">';
                    $html .= '<span class="tree-name">' . htmlspecialchars($node['nom_menu']) . '</span>';
                    $html .= '<span class="tree-id">ID: ' . htmlspecialchars($node['id_menu']) . '</span>';
                    
                    if ($isRoot) {
                        $html .= '<span class="tree-badge badge-root"><i class="bi bi-star-fill"></i> Raíz</span>';
                    } else {
                        $html .= '<span class="tree-badge badge-child"><i class="bi bi-arrow-return-right"></i> Padre: ' . htmlspecialchars($node['ind_id_padre']) . '</span>';
                    }
                    
                    if ($isOrphan) {
                        $html .= '<span class="tree-badge badge-orphan"><i class="bi bi-exclamation-triangle-fill"></i> Huérfano</span>';
                    }
                    
                    if ($programa) {
                        $html .= '<span class="badge-prog"><i class="bi bi-file-code"></i> ' . $programa . '</span>';
                    }
                    
                    $html .= '</div>';
                    $html .= '</div>';
                    
                    $html .= '<div class="tree-actions" onclick="event.stopPropagation()">
                                <button class="btn-icon edit" onclick="abrirModalEdicion(\'' . htmlspecialchars($node['id_menu']) . '\')" title="Editar">
                                    <i class="bi bi-pencil-square"></i>
                                </button>
                                <button class="btn-icon info" onclick="verInfoMenu(\'' . htmlspecialchars($node['id_menu']) . '\', \'' . addslashes($node['nom_menu']) . '\', \'' . addslashes($descripcion) . '\')" title="Ver información">
                                    <i class="bi bi-info-circle"></i>
                                </button>
                                <button class="btn-icon delete" onclick="solicitarPassword(event, \'' . htmlspecialchars($node['id_menu']) . '\', \'' . addslashes($node['nom_menu']) . '\')" title="Eliminar en cascada">
                                    <i class="bi bi-trash3"></i>
                                </button>
                            </div>';
                    
                    $html .= '</div>';
                    
                    if ($hasChildren) {
                        $html .= '<ul class="tree-children" id="children_' . $nodeId . '">';
                        $html .= renderExplorerTree($node['children'], $level + 1);
                        $html .= '</ul>';
                    }
                    
                    $html .= '</li>';
                }
                return $html;
            }
            
            echo renderExplorerTree($menu_tree);
            ?>
        </ul>
    </div>
    
    <div class="menu-footer">
        <span id="itemCount"><?= $total_menus ?> menús</span> | 
        <span>⚠️ Eliminación en cascada activa: elimina menú y todos sus submenús</span>
    </div>
</div>

<!-- Modal para crear/editar -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalSiOverlay(event)">
    <div class="modal-card">
        <div class="modal-card-header">
            <span id="modal_titulo"><i class="bi bi-plus-circle-fill"></i> Nuevo Menú</span>
            <button class="modal-close-btn" onclick="cerrarModal()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-card-body">
            <form method="POST" id="formMenus">
                <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">

                <div class="mb-3">
                    <label class="form-label-custom">ID MENÚ *</label>
                    <input type="text" name="txt_id_menu" id="f_id" class="form-control-sm" placeholder="Ej: 100" required style="font-family:monospace;" value="<?= htmlspecialchars($f_id) ?>" <?= $f_id_readonly ? 'readonly' : '' ?>>
                    <div id="val_id" class="val-feedback" style="font-size:0.7rem;color:#ef4444;"></div>
                    <small class="text-muted">Identificador único numérico</small>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">NOMBRE *</label>
                    <input type="text" name="txt_nom_menu" id="f_nom" class="form-control-sm" placeholder="Nombre del menú" required value="<?= htmlspecialchars($f_nom) ?>">
                    <div id="val_nom" class="val-feedback" style="font-size:0.7rem;color:#ef4444;"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">MENÚ PADRE</label>
                    <select name="txt_id_padre" id="f_padre" class="form-control-sm" style="width:100%;">
                        <option value="0">— Ninguno (Raíz) —</option>
                        <?php
                        $stmt_opts = $pdo->query("SELECT id_menu, nom_menu FROM tab_menus ORDER BY id_menu");
                        foreach ($stmt_opts->fetchAll() as $opt) {
                            $selected = ($opt['id_menu'] == $f_padre) ? 'selected' : '';
                            echo '<option value="' . htmlspecialchars($opt['id_menu']) . '" ' . $selected . '>' 
                                 . htmlspecialchars($opt['id_menu']) . ' - ' . htmlspecialchars($opt['nom_menu']) . '</option>';
                        }
                        ?>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">PROGRAMA / URL</label>
                    <input type="text" name="txt_nom_programa" id="f_programa" class="form-control-sm" placeholder="ej: usuarios.php" value="<?= htmlspecialchars($f_programa) ?>">
                    <small class="text-muted">Archivo PHP que se ejecutará al hacer clic</small>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">DESCRIPCIÓN</label>
                    <textarea name="txt_descripcion" id="f_descripcion" class="form-control-sm" rows="2" placeholder="Describe para qué sirve este menú..."><?= htmlspecialchars($f_descripcion) ?></textarea>
                    <small class="text-muted">Descripción detallada de la funcionalidad del menú</small>
                </div>

                <button type="submit" name="btn_guardar" id="btnGuardar" class="btn-guardar">
                    <i class="bi bi-save me-1"></i> GUARDAR
                </button>
                <button type="button" onclick="limpiarFormulario()" class="btn-nuevo">
                    <i class="bi bi-arrow-counterclockwise me-1"></i> LIMPIAR
                </button>
            </form>
        </div>
    </div>
</div>

<!-- Modal de información -->
<div id="modalInfo" class="modal-info-overlay" onclick="cerrarModalInfoSiOverlay(event)">
    <div class="modal-info-card">
        <div class="modal-info-header">
            <h3><i class="bi bi-info-circle-fill"></i> <span id="infoTitulo">Información del Menú</span></h3>
            <button class="modal-close-btn" onclick="cerrarModalInfo()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-info-body">
            <div class="info-desc-box">
                <i class="bi bi-chat-quote-fill"></i> <strong>Descripción</strong>
                <div class="info-desc-text" id="infoDescripcion">
                    <em>No hay descripción disponible</em>
                </div>
            </div>
        </div>
        <div class="modal-info-footer">
            <button class="btn-info-close" onclick="cerrarModalInfo()"><i class="bi bi-check-lg"></i> Entendido</button>
        </div>
    </div>
</div>

<!-- Modal de confirmación de contraseña para eliminar -->
<div id="modalPassword" class="modal-pass-overlay" onclick="cerrarModalPasswordSiOverlay(event)">
    <div class="modal-pass-card">
        <div class="modal-pass-header">
            <h3><i class="bi bi-shield-lock-fill"></i> Verificar seguridad</h3>
            <button class="modal-close-btn" onclick="cerrarModalPassword()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-pass-body">
            <div class="pass-warning">
                <i class="bi bi-exclamation-triangle-fill"></i> 
                <strong>¡Atención! Eliminación en cascada</strong><br>
                Se eliminará el menú "<span id="passMenuNombre"></span>" y <strong>TODOS sus submenús</strong> permanentemente.
            </div>
            
            <form id="formEliminarMenu" method="POST">
                <input type="hidden" name="_padre" value="<?= htmlspecialchars($_GET['padre'] ?? '') ?>">
                <input type="hidden" name="_hijo" value="<?= htmlspecialchars($_GET['hijo'] ?? '') ?>">
                <input type="hidden" name="_nieto" value="<?= htmlspecialchars($_GET['nieto'] ?? '') ?>">
                <input type="hidden" name="hid_id_menu" id="hidIdMenu" value="">
                <input type="hidden" name="btn_eliminar" value="1">
                
                <div class="pass-input-group">
                    <i class="bi bi-key-fill"></i>
                    <input type="password" id="txtPassword" placeholder="Contraseña de usuario" autocomplete="off" required>
                    <button type="button" class="pass-toggle" onclick="togglePasswordVisibility()"><i class="bi bi-eye-slash"></i></button>
                </div>
                
                <div id="passErrorMessage" class="pass-error"></div>
                
                <div class="modal-pass-footer">
                    <button type="button" class="btn-pass-cancel" onclick="cerrarModalPassword()">Cancelar</button>
                    <button type="button" class="btn-pass-confirm" onclick="confirmarEliminarConPassword()"><i class="bi bi-trash3"></i> Eliminar en cascada</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// ============================================
// VARIABLES GLOBALES
// ============================================
let searchTimeout = null;
let menuAEliminar = null;
let nombreMenuAEliminar = null;

// ============================================
// EXPANDIR/CONTRAER NODO
// ============================================
function toggleNode(toggleBtn, nodeId) {
    const li = document.getElementById(nodeId);
    const children = li ? li.querySelector(':scope > .tree-children') : null;
    const icon = toggleBtn.querySelector('i');
    
    if (children) {
        if (children.classList.contains('open')) {
            children.classList.remove('open');
            icon.classList.remove('bi-chevron-down');
            icon.classList.add('bi-chevron-right');
            toggleBtn.classList.remove('expanded');
        } else {
            children.classList.add('open');
            icon.classList.remove('bi-chevron-right');
            icon.classList.add('bi-chevron-down');
            toggleBtn.classList.add('expanded');
        }
    }
}

function toggleNodeClick(event, nodeDiv, nodeId) {
    if (event.target.closest('.tree-actions')) return;
    if (event.target.closest('.tree-toggle')) return;
    
    const li = document.getElementById(nodeId);
    const children = li ? li.querySelector(':scope > .tree-children') : null;
    const toggleBtn = nodeDiv.querySelector('.tree-toggle');
    
    if (children && toggleBtn && window.getComputedStyle(toggleBtn).visibility !== 'hidden') {
        const icon = toggleBtn.querySelector('i');
        if (children.classList.contains('open')) {
            children.classList.remove('open');
            icon.classList.remove('bi-chevron-down');
            icon.classList.add('bi-chevron-right');
            toggleBtn.classList.remove('expanded');
        } else {
            children.classList.add('open');
            icon.classList.remove('bi-chevron-right');
            icon.classList.add('bi-chevron-down');
            toggleBtn.classList.add('expanded');
        }
    }
    
    document.querySelectorAll('.tree-node').forEach(n => n.classList.remove('selected'));
    nodeDiv.classList.add('selected');
}

function expandirTodo() {
    document.querySelectorAll('.tree-children').forEach(el => el.classList.add('open'));
    document.querySelectorAll('.tree-toggle').forEach(btn => {
        const icon = btn.querySelector('i');
        if (icon && window.getComputedStyle(btn).visibility !== 'hidden') {
            icon.classList.remove('bi-chevron-right');
            icon.classList.add('bi-chevron-down');
            btn.classList.add('expanded');
        }
    });
}

function contraerTodo() {
    document.querySelectorAll('.tree-children').forEach(el => el.classList.remove('open'));
    document.querySelectorAll('.tree-toggle').forEach(btn => {
        const icon = btn.querySelector('i');
        if (icon && window.getComputedStyle(btn).visibility !== 'hidden') {
            icon.classList.remove('bi-chevron-down');
            icon.classList.add('bi-chevron-right');
            btn.classList.remove('expanded');
        }
    });
}

// ============================================
// FILTRAR ÁRBOL
// ============================================
function filtrarArbol() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        const term = document.getElementById('searchInput').value.toLowerCase().trim();
        const items = document.querySelectorAll('#treeRoot li[data-id]');
        let visible = 0;
        let folders = 0;
        let files = 0;
        
        items.forEach(li => {
            const nom = li.dataset.nom || '';
            const id = li.dataset.id || '';
            const prog = li.dataset.prog || '';
            const type = li.dataset.type || '';
            const matches = !term || nom.includes(term) || id.includes(term) || prog.includes(term);
            
            if (matches) {
                visible++;
                if (type === 'folder') folders++;
                else files++;
                li.style.display = '';
            } else {
                li.style.display = 'none';
            }
            
            const treeName = li.querySelector('.tree-name');
            if (treeName && term) {
                const original = treeName.innerText;
                if (original.toLowerCase().includes(term)) {
                    const regex = new RegExp(`(${term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
                    treeName.innerHTML = original.replace(regex, '<span class="highlight">$1</span>');
                } else {
                    treeName.innerHTML = original;
                }
            } else if (treeName) {
                treeName.innerHTML = treeName.innerText;
            }
        });
        
        document.getElementById('totalFolders').innerText = folders;
        document.getElementById('totalFiles').innerText = files;
        document.getElementById('itemCount').innerText = `${visible} menú${visible !== 1 ? 's' : ''} visibles`;
        
        if (term) {
            items.forEach(li => {
                if (li.style.display !== 'none') {
                    let parent = li.parentElement.closest('li');
                    while (parent) {
                        const children = parent.querySelector(':scope > .tree-children');
                        const toggleBtn = parent.querySelector('.tree-toggle');
                        if (children && !children.classList.contains('open')) {
                            children.classList.add('open');
                            const icon = toggleBtn?.querySelector('i');
                            if (icon) {
                                icon.classList.remove('bi-chevron-right');
                                icon.classList.add('bi-chevron-down');
                            }
                        }
                        parent = parent.parentElement?.closest('li');
                    }
                }
            });
        }
    }, 200);
}

// ============================================
// MODAL CRUD
// ============================================
function abrirModal() {
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-plus-circle-fill"></i> Nuevo Menú';
    document.getElementById('f_id').readOnly = false;
    document.getElementById('formMenus').reset();
    document.getElementById('f_padre').value = '0';
    document.getElementById('f_descripcion').value = '';
    document.getElementById('modalOverlay').classList.add('show');
    limpiarValidaciones();
}

function abrirModalEdicion(id) {
    document.getElementById('modal_titulo').innerHTML = '<i class="bi bi-pencil-square"></i> Editar Menú';
    document.getElementById('f_id').readOnly = true;
    
    const li = document.querySelector(`li[data-id="${id}"]`);
    if (li) {
        const nombre = li.querySelector('.tree-name')?.innerText || '';
        let padre = '0';
        const badgePadre = li.querySelector('.badge-child');
        if (badgePadre) {
            const match = badgePadre.innerText.match(/\d+/);
            if (match) padre = match[0];
        }
        let programa = '';
        const badgeProg = li.querySelector('.badge-prog');
        if (badgeProg) {
            programa = badgeProg.innerText.replace(/[^\w\/\.-]/g, '');
        }
        const descripcion = li.dataset.desc || '';
        
        document.getElementById('f_id').value = id;
        document.getElementById('f_nom').value = nombre;
        document.getElementById('f_padre').value = padre;
        document.getElementById('f_programa').value = programa;
        document.getElementById('f_descripcion').value = descripcion;
    }
    document.getElementById('modalOverlay').classList.add('show');
    limpiarValidaciones();
}

function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('show');
}

function cerrarModalSiOverlay(e) {
    if (e.target === document.getElementById('modalOverlay')) cerrarModal();
}

function limpiarFormulario() {
    document.getElementById('formMenus').reset();
    document.getElementById('f_padre').value = '0';
    document.getElementById('f_id').readOnly = false;
    document.getElementById('f_descripcion').value = '';
    limpiarValidaciones();
}

function limpiarValidaciones() {
    ['f_id', 'f_nom'].forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.style.borderColor = '';
            const feedback = document.getElementById('val_' + id);
            if (feedback) feedback.innerHTML = '';
        }
    });
}

// ============================================
// MODAL INFORMACIÓN
// ============================================
function verInfoMenu(id, nombre, descripcion) {
    document.getElementById('infoTitulo').innerHTML = `<i class="bi bi-info-circle-fill"></i> ${nombre}`;
    if (descripcion && descripcion.trim() !== '') {
        document.getElementById('infoDescripcion').innerHTML = descripcion;
    } else {
        document.getElementById('infoDescripcion').innerHTML = '<em>No hay descripción disponible para este menú.</em>';
    }
    document.getElementById('modalInfo').classList.add('show');
}

function cerrarModalInfo() {
    document.getElementById('modalInfo').classList.remove('show');
}

function cerrarModalInfoSiOverlay(e) {
    if (e.target === document.getElementById('modalInfo')) cerrarModalInfo();
}

// ============================================
// MODAL PASSWORD (ELIMINAR EN CASCADA)
// ============================================
function togglePasswordVisibility() {
    const input = document.getElementById('txtPassword');
    const icon = document.querySelector('.pass-toggle i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('bi-eye-slash');
        icon.classList.add('bi-eye');
    } else {
        input.type = 'password';
        icon.classList.remove('bi-eye');
        icon.classList.add('bi-eye-slash');
    }
}

function solicitarPassword(event, idMenu, nombreMenu) {
    event.stopPropagation();
    menuAEliminar = idMenu;
    nombreMenuAEliminar = nombreMenu;
    
    document.getElementById('passMenuNombre').innerText = nombreMenu;
    document.getElementById('hidIdMenu').value = idMenu;
    document.getElementById('txtPassword').value = '';
    document.getElementById('passErrorMessage').style.display = 'none';
    document.getElementById('modalPassword').classList.add('show');
    document.body.style.overflow = 'hidden';
    
    setTimeout(() => {
        document.getElementById('txtPassword').focus();
    }, 100);
}

function cerrarModalPassword() {
    document.getElementById('modalPassword').classList.remove('show');
    document.body.style.overflow = '';
    menuAEliminar = null;
    nombreMenuAEliminar = null;
    const errorDiv = document.getElementById('passErrorMessage');
    errorDiv.style.display = 'none';
    errorDiv.innerHTML = '';
}

function cerrarModalPasswordSiOverlay(e) {
    if (e.target === document.getElementById('modalPassword')) cerrarModalPassword();
}

function mostrarAlertaPassword(mensaje) {
    const errorDiv = document.getElementById('passErrorMessage');
    errorDiv.innerHTML = `<i class="bi bi-exclamation-triangle-fill"></i> ${mensaje}`;
    errorDiv.style.display = 'block';
    setTimeout(() => {
        errorDiv.style.display = 'none';
    }, 4000);
}

function confirmarEliminarConPassword() {
    const password = document.getElementById('txtPassword').value.trim();
    const idMenu = document.getElementById('hidIdMenu').value;
    
    if (!password) {
        mostrarAlertaPassword('Ingrese su contraseña para confirmar la eliminación');
        document.getElementById('txtPassword').focus();
        return;
    }
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '';
    
    const params = {
        '_padre': '<?= htmlspecialchars($_GET['padre'] ?? '') ?>',
        '_hijo': '<?= htmlspecialchars($_GET['hijo'] ?? '') ?>',
        '_nieto': '<?= htmlspecialchars($_GET['nieto'] ?? '') ?>',
        'hid_id_menu': idMenu,
        'txt_password': password,
        'btn_eliminar': '1'
    };
    
    for (const [key, value] of Object.entries(params)) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = value;
        form.appendChild(input);
    }
    
    document.body.appendChild(form);
    form.submit();
}

// ============================================
// VALIDACIÓN ANTES DE ENVIAR
// ============================================
document.getElementById('formMenus').addEventListener('submit', function(e) {
    const idMenu = document.getElementById('f_id').value.trim();
    const nombre = document.getElementById('f_nom').value.trim();
    let error = false;
    
    if (!idMenu) {
        document.getElementById('val_id').innerHTML = 'El ID es obligatorio';
        document.getElementById('f_id').style.borderColor = '#ef4444';
        error = true;
    } else if (/\s/.test(idMenu)) {
        document.getElementById('val_id').innerHTML = 'El ID no puede contener espacios';
        document.getElementById('f_id').style.borderColor = '#ef4444';
        error = true;
    } else {
        document.getElementById('val_id').innerHTML = '';
        document.getElementById('f_id').style.borderColor = '';
    }
    
    if (!nombre) {
        document.getElementById('val_nom').innerHTML = 'El nombre es obligatorio';
        document.getElementById('f_nom').style.borderColor = '#ef4444';
        error = true;
    } else {
        document.getElementById('val_nom').innerHTML = '';
        document.getElementById('f_nom').style.borderColor = '';
    }
    
    if (error) e.preventDefault();
});

// ============================================
// INICIALIZACIÓN
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    const total = document.querySelectorAll('#treeRoot li[data-id]').length;
    const folders = document.querySelectorAll('#treeRoot li[data-type="folder"]').length;
    const files = total - folders;
    
    document.getElementById('totalFolders').innerText = folders;
    document.getElementById('totalFiles').innerText = files;
    document.getElementById('totalMenus').innerText = total;
    document.getElementById('itemCount').innerText = `${total} menús`;
    
    const scrollContainer = document.querySelector('.tree-container');
    if (scrollContainer) {
        scrollContainer.style.scrollBehavior = 'smooth';
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        cerrarModal();
        cerrarModalPassword();
        cerrarModalInfo();
    }
});

setTimeout(() => {
    document.querySelectorAll('.alert').forEach(alert => {
        alert.classList.remove('show');
        setTimeout(() => alert.remove(), 300);
    });
}, 5000);
</script>