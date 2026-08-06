<?php
/**
 * AJAX para Gestión de Accesos - SistNomina
 * Maneja las peticiones asíncronas para cargar y guardar menús por usuario
 */

require_once('prepare.php');
session_start();

header('Content-Type: application/json');

// Verificar autenticación
if (!isset($_SESSION['id_usuario'])) {
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit();
}

$action = $_POST['action'] ?? '';

try {
    if ($action === 'get_menus_usuario') {
        $id_usuario = $_POST['id_usuario'] ?? '';
        
        if (empty($id_usuario)) {
            echo json_encode(['success' => false, 'message' => 'ID de usuario no proporcionado']);
            exit();
        }
        
        // Obtener menús asignados al usuario
        $stmt = $pdo->prepare("SELECT id_menu FROM tab_menu_usuarios WHERE id_usuario = CAST(? AS TEXT)");
        $stmt->execute([$id_usuario]);
        $menus = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        echo json_encode([
            'success' => true, 
            'menus_asignados' => $menus
        ]);
        
    } elseif ($action === 'guardar_accesos') {
        $id_usuario = $_POST['id_usuario'] ?? '';
        $menus_json = $_POST['menus'] ?? '[]';
        $menus = json_decode($menus_json, true);
        
        if (empty($id_usuario)) {
            echo json_encode(['success' => false, 'message' => 'ID de usuario no proporcionado']);
            exit();
        }
        
        // Iniciar transacción
        $pdo->beginTransaction();
        
        // Eliminar menús actuales del usuario
        $stmt_del = $pdo->prepare("DELETE FROM tab_menu_usuarios WHERE id_usuario = CAST(? AS TEXT)");
        $stmt_del->execute([$id_usuario]);
        
        // Insertar nuevos menús
        if (!empty($menus)) {
            $stmt_ins = $pdo->prepare("INSERT INTO tab_menu_usuarios (id_usuario, id_menu) VALUES (CAST(? AS TEXT), CAST(? AS TEXT))");
            foreach ($menus as $id_menu) {
                $stmt_ins->execute([$id_usuario, $id_menu]);
            }
        }
        
        // Confirmar transacción
        $pdo->commit();
        
        echo json_encode([
            'success' => true, 
            'message' => 'Accesos guardados correctamente'
        ]);
        
    } else {
        echo json_encode([
            'success' => false, 
            'message' => 'Acción no válida'
        ]);
    }
    
} catch (PDOException $e) {
    // Rollback en caso de error
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    
    echo json_encode([
        'success' => false, 
        'message' => 'Error en base de datos: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false, 
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>