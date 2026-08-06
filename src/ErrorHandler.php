<?php
/**
 * GESTIÓN CENTRALIZADA DE ERRORES
 * 
 * Esta clase la hice para tener un control unificado de todos los errores
 * que pueden pasar en el sistema. Traduce errores de PostgreSQL a mensajes
 * que el usuario pueda entender y también guarda los errores en un log
 * para que yo pueda revisarlos después.
 * 
 * Categoriza errores por origen: Base de Datos, Validación, Sistema, Red
 */

class ErrorHandler {
    
    /**
     * Mapa de códigos SQLSTATE de PostgreSQL a mensajes en español
     * Los fui investigando en la documentación de PostgreSQL
     * https://www.postgresql.org/docs/current/errcodes-appendix.html
     */
    private static $sqlErrorMap = [
        // Errores de restricción (los más comunes)
        '23505' => 'Violación de clave única. Este registro ya existe en la base de datos.',
        '23503' => 'Error de integridad referencial. Este dato está relacionado con otros registros y no puede ser eliminado.',
        '23502' => 'Violación de restricción NOT NULL. Un campo requerido está vacío.',
        '23514' => 'Violación de restricción CHECK. Los datos no cumplen con las reglas de validación.',
        
        // Errores de sintaxis (no deberían pasar en producción)
        '42601' => 'Error de sintaxis SQL. Contacte al administrador.',
        '42883' => 'Función o procedimiento no encontrado.',
        '42P01' => 'Tabla no encontrada en la base de datos.',
        '42P02' => 'Columna no encontrada en la tabla.',
        
        // Errores de permisos
        '42501' => 'Permisos insuficientes para ejecutar esta operación.',
        '28P01' => 'Contraseña incorrecta o usuario no existe.',
        
        // Errores de conexión
        '08000' => 'Error de conexión a base de datos.',
        '08003' => 'Conexión perdida con la base de datos.',
        '08006' => 'Fallo de comunicación con la base de datos.',
        
        // Errores de transacción (cuando hay problemas de concurrencia)
        '40P01' => 'Deadlock detectado. Reintente la operación.',
        '40000' => 'Error de transacción. La operación fue cancelada.',
        
        // Errores de tipo de dato
        '22007' => 'Formato de fecha/hora inválido.',
        '22P02' => 'Formato de valor inválido para el tipo de dato.',
        '22012' => 'División por cero.',
    ];

    /**
     * Crea una estructura de respuesta estandarizada
     * Esto lo uso para las respuestas JSON en las peticiones AJAX
     * 
     * @return array con el formato unificado de respuesta
     */
    public static function createResponse($status, $message, $source = 'UNKNOWN', $sqlstate = null, $debug = null) {
        return [
            'status' => $status,           // 'success' o 'error'
            'message' => $message,          // Mensaje para el usuario
            'source' => $source,            // Origen del error: DATABASE, VALIDATION, SYSTEM, NETWORK
            'sqlstate' => $sqlstate,        // Código SQLSTATE (si aplica)
            'timestamp' => date('Y-m-d H:i:s'), // Momento exacto del error
            'debug' => $debug                // Info técnica (solo en desarrollo)
        ];
    }

    /**
     * Procesa excepciones de PDO (errores de base de datos)
     * Toma la excepción, busca el código SQLSTATE y devuelve un mensaje amigable
     * 
     * @param PDOException $e La excepción que atrapé
     * @return array Respuesta formateada
     */
    public static function handleDatabaseException(PDOException $e) {
        $errorInfo = $e->errorInfo;
        $sqlstate = $errorInfo[0] ?? null;    // Código SQLSTATE
        $nativeCode = $errorInfo[1] ?? null;   // Código nativo de PostgreSQL
        $nativeMessage = $errorInfo[2] ?? null; // Mensaje original de PostgreSQL

        // Busco si tengo una traducción para ese código, si no, uso un mensaje genérico
        $userMessage = self::$sqlErrorMap[$sqlstate] ?? 
                      self::getGenericDatabaseMessage($sqlstate);

        // Información técnica para el log (no se la muestro al usuario)
        $debugInfo = [
            'sqlstate' => $sqlstate,
            'native_code' => $nativeCode,
            'native_message' => $nativeMessage,
            'exception_msg' => $e->getMessage()
        ];

        // Registro el error en el log del sistema
        self::logError('DATABASE_ERROR', $sqlstate, $nativeMessage);

        return self::createResponse(
            'error',
            $userMessage,
            'DATABASE',
            $sqlstate,
            $debugInfo
        );
    }

    /**
     * Procesa excepciones generales (validación, lógica de negocio)
     * 
     * @param Exception $e Excepción general
     * @return array Respuesta formateada
     */
    public static function handleValidationException(Exception $e) {
        $debugInfo = [
            'exception_msg' => $e->getMessage(),
            'file' => $e->getFile(),      // Archivo donde ocurrió el error
            'line' => $e->getLine()        // Línea exacta del error
        ];

        self::logError('VALIDATION_ERROR', 'N/A', $e->getMessage());

        return self::createResponse(
            'error',
            $e->getMessage(),               // En validación, puedo mostrar el mensaje directo
            'VALIDATION',
            null,
            $debugInfo
        );
    }

    /**
     * Construye un mensaje genérico para errores de BD que no tengo en el mapa
     * Uso el prefijo del código SQLSTATE para dar una idea general del error
     * 
     * @return string Mensaje genérico
     */
    private static function getGenericDatabaseMessage($sqlstate) {
        if (!$sqlstate) {
            return 'Error desconocido en base de datos. Contacte al administrador.';
        }

        $prefix = substr($sqlstate, 0, 2); // Los primeros 2 caracteres indican la categoría
        
        switch ($prefix) {
            case '08': return 'Error de conexión con la base de datos. Verifique su conexión.';
            case '23': return 'Error de integridad de datos. Los datos no cumplen con las reglas.';
            case '42': return 'Error de estructura. Contacte al administrador.';
            case '40': return 'Error de transacción. Reintente la operación.';
            case '22': return 'Formato de datos inválido.';
            default:   return 'Error en base de datos (Código: ' . $sqlstate . '). Contacte al administrador.';
        }
    }

    /**
     * Valida que un ID no esté vacío
     * Lo uso en varios lugares para no repetir código
     * 
     * @param mixed $id El valor a validar
     * @param string $fieldName Nombre del campo (para el mensaje)
     * @throws Exception Si está vacío
     */
    public static function validateNotEmpty($id, $fieldName = 'Campo') {
        if (empty($id)) {
            throw new Exception("$fieldName es requerido y no puede estar vacío.");
        }
    }

    /**
     * Valida que un array tenga elementos
     * 
     * @param array $arr Array a validar
     * @param string $fieldName Nombre del campo
     * @throws Exception Si no es array o está vacío
     */
    public static function validateArray($arr, $fieldName = 'Lista') {
        if (!is_array($arr) || empty($arr)) {
            throw new Exception("$fieldName no puede estar vacía.");
        }
    }

    /**
     * Registra errores en archivo de log
     * Así puedo revisar después qué pasó sin molestar al usuario
     * 
     * @param string $errorType Tipo de error
     * @param string $code Código del error
     * @param string $message Mensaje del error
     */
    private static function logError($errorType, $code, $message) {
        $logFile = __DIR__ . '/../logs/error_handler.log';
        
        // Creo el directorio de logs si no existe
        if (!is_dir(dirname($logFile))) {
            mkdir(dirname($logFile), 0755, true);
        }

        // Formato: [fecha] TIPO | Code: código | Message: mensaje | IP: dirección
        $logEntry = sprintf(
            "[%s] %s | Code: %s | Message: %s | IP: %s\n",
            date('Y-m-d H:i:s'),
            $errorType,
            $code,
            $message,
            $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN'
        );

        // Escribo al final del archivo (FILE_APPEND) y bloqueo el archivo (LOCK_EX)
        file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
    }

    /**
     * Envía respuesta JSON y termina la ejecución
     * Lo uso en los endpoints AJAX para devolver errores formateados
     * 
     * @param array $response La respuesta a enviar
     */
    public static function sendJSON($response) {
        header('Content-Type: application/json; charset=utf-8');
        // Si es error, envío código 400 (Bad Request)
        http_response_code($response['status'] === 'error' ? 400 : 200);
        echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }

    /**
     * Retorna un mensaje legible para el usuario en alertas
     * Le agrego un emoji según el origen para que sea más visual
     * 
     * @param array $errorResponse La respuesta de error
     * @return string Mensaje formateado
     */
    public static function getUserMessage($errorResponse) {
        $source = $errorResponse['source'] ?? 'UNKNOWN';
        $message = $errorResponse['message'] ?? 'Error desconocido';
        
        $prefix = '';
        switch ($source) {
            case 'DATABASE':
                $prefix = "🔴 [Error de Base de Datos]\n";
                break;
            case 'VALIDATION':
                $prefix = "⚠️ [Error de Validación]\n";
                break;
            case 'SYSTEM':
                $prefix = "⚙️ [Error del Sistema]\n";
                break;
            case 'NETWORK':
                $prefix = "📡 [Error de Red]\n";
                break;
            default:
                $prefix = "❌ [Error]\n";
        }

        return $prefix . $message;
    }

    /**
     * Procesa errores de clave foránea con contexto mejorado
     * Detecta la tabla y da un mensaje más específico según la operación
     * 
     * @param PDOException $e La excepción
     * @param string $operation 'DELETE', 'INSERT', 'UPDATE'
     * @param array $context Información extra (tabla, etc.)
     * @return array Respuesta formateada
     */
    public static function handleForeignKeyViolation(PDOException $e, $operation = 'DELETE', $context = []) {
        $errorInfo = $e->errorInfo;
        $sqlstate = $errorInfo[0] ?? null;
        $nativeMessage = $errorInfo[2] ?? '';
        
        // Mensajes específicos según la tabla y la operación
        // Los fui agregando a medida que aparecían errores
        if ($operation === 'DELETE') {
            if (strpos($nativeMessage, 'tab_menu_usuarios') !== false) {
                $userMessage = "❌ No se puede eliminar este menú.\n\n" .
                    "Motivo: Está asignado a usuarios.\n\n" .
                    "Acción: Primero debe desasignarlo en Gestión de Accesos.";
            } elseif (strpos($nativeMessage, 'tab_usuarios') !== false) {
                $userMessage = "❌ No se puede eliminar este usuario.\n\n" .
                    "Motivo: Tiene registros relacionados.\n\n" .
                    "Acción: Primero resuelva esas relaciones.";
            } else {
                $userMessage = "❌ No se puede eliminar.\n\n" .
                    "Motivo: Está relacionado con otros datos.\n\n" .
                    "Acción: Primero elimine los datos dependientes.";
            }
        } elseif ($operation === 'INSERT' || $operation === 'UPDATE') {
            $userMessage = "❌ No se puede guardar. Referencia inválida.\n\n" .
                "Motivo: Uno de los datos referenciados no existe.\n\n" .
                "Acción: Verifique que todos los IDs existan.";
        } else {
            $userMessage = "Error de integridad referencial. Contacte al administrador.";
        }

        $debugInfo = [
            'sqlstate' => $sqlstate,
            'operation' => $operation,
            'native_message' => $nativeMessage,
            'context' => $context
        ];

        self::logError('REFERENTIAL_INTEGRITY_ERROR', $sqlstate, $nativeMessage);

        return self::createResponse(
            'error',
            $userMessage,
            'DATABASE',
            $sqlstate,
            $debugInfo
        );
    }
}
?>