<?php
/**
 * COPIAR PERFIL DE USUARIO - SistNomina V.2.0
 * Permite copiar los menús asignados de un usuario origen a un usuario destino
 * Integrado con layout de menu_principal.php
 */

// Verificar que está siendo incluido desde menu_principal.php
if (!defined('INCLUDE_MENU_PRINCIPAL')) {
    header("Location: menu_principal.php");
    exit();
}

require_once('prepare.php');

$lista_usuarios = [];
$error_carga = null;
$mensaje = '';
$tipo_mensaje = '';

try {
    $stmt_list_usuarios->execute();
    $lista_usuarios = $stmt_list_usuarios->fetchAll(PDO::FETCH_ASSOC);
    
    // Procesar copia de perfil
    if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['btn_copiar'])) {
        $usuario_origen = $_POST['usuario_origen'] ?? '';
        $usuario_destino = $_POST['usuario_destino'] ?? '';
        
        if (empty($usuario_origen) || empty($usuario_destino)) {
            $mensaje = "Debe seleccionar ambos usuarios (origen y destino)";
            $tipo_mensaje = "danger";
        } elseif ($usuario_origen == $usuario_destino) {
            $mensaje = "No puede copiar el perfil al mismo usuario";
            $tipo_mensaje = "danger";
        } else {
            try {
                // Iniciar transacción
                $pdo->beginTransaction();
                
                // 1. Obtener menús del usuario origen
                $stmt_origen = $pdo->prepare("SELECT id_menu FROM tab_menu_usuarios WHERE id_usuario = CAST(? AS TEXT)");
                $stmt_origen->execute([$usuario_origen]);
                $menus_origen = $stmt_origen->fetchAll(PDO::FETCH_COLUMN);
                
                // 2. Eliminar menús actuales del usuario destino
                $stmt_del = $pdo->prepare("DELETE FROM tab_menu_usuarios WHERE id_usuario = CAST(? AS TEXT)");
                $stmt_del->execute([$usuario_destino]);
                
                // 3. Insertar nuevos menús al usuario destino
                if (!empty($menus_origen)) {
                    $stmt_ins = $pdo->prepare("INSERT INTO tab_menu_usuarios (id_usuario, id_menu) VALUES (CAST(? AS TEXT), CAST(? AS TEXT))");
                    foreach ($menus_origen as $id_menu) {
                        $stmt_ins->execute([$usuario_destino, $id_menu]);
                    }
                    $mensaje = "✅ Perfil copiado exitosamente. Se copiaron " . count($menus_origen) . " menús.";
                } else {
                    $mensaje = "⚠️ El usuario origen no tiene menús asignados. Se eliminaron los menús del destino.";
                }
                $tipo_mensaje = "success";
                
                // Confirmar transacción
                $pdo->commit();
                
            } catch (Exception $e) {
                $pdo->rollBack();
                $mensaje = "❌ Error al copiar el perfil: " . $e->getMessage();
                $tipo_mensaje = "danger";
            }
        }
    }
    
} catch (Exception $e) {
    $error_carga = $e->getMessage();
}
?>

<!-- ESTILOS PROPIOS DE copiar_perfil.php -->
<style>
    .copiar-container {
        max-width: 100%;
        margin: 0;
        padding: 0;
    }

    .copiar-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
        padding-bottom: 0.75rem;
        border-bottom: 2px solid #e2e8f0;
    }

    .copiar-title h2 {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 0;
        color: #1a1a2e;
    }

    .copiar-title p {
        margin: 0;
        font-size: 0.8rem;
        color: #6c7a8a;
    }

    /* Layout principal */
    .copiar-layout {
        display: flex;
        gap: 1.5rem;
        flex-wrap: wrap;
    }

    /* Panel izquierdo - Instrucciones */
    .panel-instrucciones {
        flex: 1;
        min-width: 280px;
    }

    /* Panel derecho - Formulario */
    .panel-formulario {
        flex: 2;
        min-width: 400px;
    }

    /* Tarjetas */
    .card-copiar {
        background: white;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        overflow: hidden;
        margin-bottom: 1.5rem;
    }

    .card-copiar-header {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        padding: 0.75rem 1.25rem;
        color: white;
        font-weight: 600;
        font-size: 0.9rem;
    }

    .card-copiar-header i {
        margin-right: 0.5rem;
        color: #00d9ff;
    }

    .card-copiar-body {
        padding: 1.25rem;
    }

    /* Selects */
    .select-copiar {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        font-size: 0.9rem;
        background: white;
        transition: all 0.2s;
    }

    .select-copiar:focus {
        border-color: #00d9ff;
        outline: none;
        box-shadow: 0 0 0 3px rgba(0,217,255,0.1);
    }

    /* Info box */
    .info-box-copiar {
        background: #f0f9ff;
        border-left: 3px solid #00d9ff;
        padding: 0.75rem;
        border-radius: 10px;
        margin-top: 1rem;
        font-size: 0.75rem;
        color: #475569;
    }

    .info-box-copiar i {
        color: #00d9ff;
        margin-right: 0.5rem;
    }

    /* Botón */
    .btn-copiar {
        width: 100%;
        background: linear-gradient(135deg, #00b4d8 0%, #0077b6 100%);
        border: none;
        padding: 0.75rem;
        font-weight: 600;
        color: white;
        border-radius: 12px;
        transition: all 0.2s;
        cursor: pointer;
    }

    .btn-copiar:hover:not(:disabled) {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0,180,216,0.3);
    }

    .btn-copiar:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    /* Alertas */
    .alert-copiar {
        border-radius: 12px;
        padding: 12px 16px;
        margin-bottom: 1rem;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .alert-success-copiar {
        background: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }

    .alert-danger-copiar {
        background: #fee2e2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }

    .alert-warning-copiar {
        background: #fef3c7;
        color: #b45309;
        border: 1px solid #fde68a;
    }

    /* Label */
    .label-copiar {
        font-size: 0.7rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #5a6c7e;
        margin-bottom: 0.5rem;
        display: block;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .copiar-layout {
            flex-direction: column;
        }
        .panel-formulario {
            min-width: auto;
        }
    }
</style>

<div class="copiar-container">
    <!-- HEADER -->
    <div class="copiar-header">
        <div class="copiar-title">
            <h2><i class="bi bi-files" style="color: #00d9ff;"></i> Copiar Perfil de Menús</h2>
            <p>Copie los accesos de un usuario a otro</p>
        </div>
    </div>

    <!-- Mensajes -->
    <?php if ($mensaje): ?>
        <div class="alert-copiar alert-<?= $tipo_mensaje ?>-copiar">
            <i class="bi bi-<?= $tipo_mensaje == 'success' ? 'check-circle-fill' : ($tipo_mensaje == 'warning' ? 'exclamation-triangle-fill' : 'x-circle-fill') ?>"></i>
            <?= htmlspecialchars($mensaje) ?>
        </div>
    <?php endif; ?>

    <?php if ($error_carga): ?>
        <div class="alert-copiar alert-danger-copiar">
            <i class="bi bi-exclamation-triangle-fill"></i>
            Error al cargar usuarios: <?= htmlspecialchars($error_carga) ?>
        </div>
    <?php endif; ?>

    <div class="copiar-layout">
        <!-- PANEL IZQUIERDO: INSTRUCCIONES -->
        <div class="panel-instrucciones">
            <div class="card-copiar">
                <div class="card-copiar-header">
                    <i class="bi bi-info-circle-fill"></i> Instrucciones
                </div>
                <div class="card-copiar-body">
                    <p>Seleccione un <strong>usuario origen</strong> y un <strong>usuario destino</strong>.</p>
                    <p>Al copiar, los menús del usuario destino se <strong>reemplazarán</strong> por los del usuario origen.</p>
                    
                    <div class="info-box-copiar">
                        <i class="bi bi-shield-exclamation"></i>
                        <strong>Nota importante:</strong> Si el usuario destino tiene menús asignados, estos se eliminarán antes de copiar el perfil. Esta acción es irreversible.
                    </div>
                    
                    <div class="info-box-copiar" style="margin-top: 0.75rem; background: #e6f7ff;">
                        <i class="bi bi-arrow-left-right"></i>
                        <strong>¿Para qué sirve?</strong> Esta herramienta es útil para clonar rápidamente los accesos de un usuario a otro, por ejemplo cuando un empleado reemplaza a otro o cuando se crean usuarios con perfiles similares.
                    </div>
                </div>
            </div>
        </div>

        <!-- PANEL DERECHO: FORMULARIO -->
        <div class="panel-formulario">
            <div class="card-copiar">
                <div class="card-copiar-header">
                    <i class="bi bi-person-arrows"></i> Copiar Menús
                </div>
                <div class="card-copiar-body">
                    <form id="form_copiar" method="POST">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="label-copiar" for="sel_origen">
                                    <i class="bi bi-person-up"></i> Usuario Origen
                                </label>
                                <select id="sel_origen" name="usuario_origen" class="select-copiar" required>
                                    <option value="">-- Seleccione un usuario --</option>
                                    <?php foreach ($lista_usuarios as $u): ?>
                                        <?php $isAdmin = ($u['id_usuario'] === 'admin'); ?>
                                        <option value="<?= htmlspecialchars($u['id_usuario']) ?>" <?= $isAdmin ? 'disabled' : '' ?>>
                                            <?= htmlspecialchars($u['nom_usuario']) ?> (<?= htmlspecialchars($u['id_usuario']) ?>)
                                            <?= $isAdmin ? ' - Administrador' : '' ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <small class="text-muted" style="font-size: 0.7rem;">Desde aquí se copiarán los menús</small>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="label-copiar" for="sel_destino">
                                    <i class="bi bi-person-down"></i> Usuario Destino
                                </label>
                                <select id="sel_destino" name="usuario_destino" class="select-copiar" required>
                                    <option value="">-- Seleccione un usuario --</option>
                                    <?php foreach ($lista_usuarios as $u): ?>
                                        <?php $isAdmin = ($u['id_usuario'] === 'admin'); ?>
                                        <option value="<?= htmlspecialchars($u['id_usuario']) ?>" <?= $isAdmin ? 'disabled' : '' ?>>
                                            <?= htmlspecialchars($u['nom_usuario']) ?> (<?= htmlspecialchars($u['id_usuario']) ?>)
                                            <?= $isAdmin ? ' - Administrador' : '' ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <small class="text-muted" style="font-size: 0.7rem;">Aquí se pegarán los menús</small>
                            </div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" name="btn_copiar" id="btn_copiar" class="btn-copiar" disabled>
                                <i class="bi bi-files me-2"></i> COPIAR MENÚS
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Habilitar botón solo cuando ambos selects tengan valores
const selOrigen = document.getElementById('sel_origen');
const selDestino = document.getElementById('sel_destino');
const btnCopiar = document.getElementById('btn_copiar');

function validarFormulario() {
    const origenValido = selOrigen && selOrigen.value !== '';
    const destinoValido = selDestino && selDestino.value !== '';
    const mismosUsuarios = selOrigen && selDestino && selOrigen.value === selDestino.value;
    
    if (btnCopiar) {
        btnCopiar.disabled = !(origenValido && destinoValido && !mismosUsuarios);
    }
    
    // Mostrar advertencia si son el mismo usuario
    if (mismosUsuarios && origenValido && destinoValido) {
        const alertContainer = document.querySelector('.copiar-container');
        let warningAlert = document.getElementById('warning-same-user');
        if (!warningAlert) {
            warningAlert = document.createElement('div');
            warningAlert.id = 'warning-same-user';
            warningAlert.className = 'alert-copiar alert-warning-copiar';
            warningAlert.innerHTML = '<i class="bi bi-exclamation-triangle-fill"></i> No puede copiar el perfil al mismo usuario';
            const header = document.querySelector('.copiar-header');
            if (header && header.parentNode) {
                header.parentNode.insertBefore(warningAlert, header.nextSibling);
            }
        }
    } else {
        const warningAlert = document.getElementById('warning-same-user');
        if (warningAlert) warningAlert.remove();
    }
}

if (selOrigen) selOrigen.addEventListener('change', validarFormulario);
if (selDestino) selDestino.addEventListener('change', validarFormulario);

// Confirmación antes de copiar
if (document.getElementById('form_copiar')) {
    document.getElementById('form_copiar').addEventListener('submit', function(e) {
        const origen = selOrigen ? selOrigen.options[selOrigen.selectedIndex]?.text : '';
        const destino = selDestino ? selDestino.options[selDestino.selectedIndex]?.text : '';
        
        const confirmar = confirm(
            `¿Está seguro de copiar los menús?\n\n` +
            `Origen: ${origen}\n` +
            `Destino: ${destino}\n\n` +
            `⚠️ ADVERTENCIA: Los menús actuales del usuario destino serán ELIMINADOS y reemplazados por los del usuario origen.\n\n` +
            `¿Desea continuar?`
        );
        
        if (!confirmar) {
            e.preventDefault();
        }
    });
}

// Detectar cambios sin guardar
let hasChanges = false;
if (selOrigen) selOrigen.addEventListener('change', () => hasChanges = true);
if (selDestino) selDestino.addEventListener('change', () => hasChanges = true);


document.addEventListener('submit', function() {
    hasChanges = false;
});
</script>