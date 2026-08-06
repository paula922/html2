CREATE OR REPLACE FUNCTION fun_mensaje_error(p_sqlstate TEXT, p_sqlerrm TEXT)
RETURNS TEXT AS
$$
DECLARE
    v_mensaje TEXT;
BEGIN
    -- Caso especial: error manual (nuestras validaciones con RAISE EXCEPTION)
    IF p_sqlstate = 'P0001' THEN
        RETURN COALESCE(p_sqlerrm, 'Ocurrió un error inesperado.');
    END IF;

    -- Intentamos buscar el mensaje amigable
    BEGIN
        SELECT mensaje INTO v_mensaje FROM tab_cat_errores
        WHERE cod_sqlstate = p_sqlstate;
    EXCEPTION WHEN OTHERS THEN
        -- Si la tabla de errores falla, no rompemos todo. Devolvemos el error técnico original.
        RETURN 'Error del sistema al buscar mensaje. Detalle técnico: ' || COALESCE(p_sqlerrm, 'Error desconocido');
    END;

    -- Si existe en tabla, usarlo; si no, genérico con el código para ayudar a depurar
    RETURN COALESCE(v_mensaje, 'Ocurrió un error inesperado. (Código: ' || p_sqlstate || ')');
END;
$$ LANGUAGE plpgsql;

INSERT INTO tab_cat_errores (cod_sqlstate, mensaje) VALUES

-- ✅ Éxito / advertencias
('00000', 'Operación realizada correctamente'),
('01000', 'Advertencia general'),
('02000', 'No se encontraron datos'),

-- 🔐 Integridad (LOS MÁS IMPORTANTES)
('23505', 'El registro ya existe (duplicado)'),
('23503', 'El valor no existe o está relacionado con otros datos'),
('23502', 'Un campo obligatorio está vacío'),
('23514', 'El valor no cumple las reglas permitidas'),

-- 📊 Datos inválidos
('22001', 'El texto es demasiado largo'),
('22003', 'El número está fuera de rango'),
('22004', 'No se permite valor nulo'),
('22007', 'Formato de fecha incorrecto'),
('22012', 'No se puede dividir entre cero'),
('22P02', 'Formato de dato inválido'),

-- 🧠 Lógica / consultas
('42P01', 'La tabla no existe'),
('42703', 'La columna no existe'),
('42601', 'Error de sintaxis en la consulta'),
('42804', 'Tipo de dato incorrecto'),
('42883', 'La función no existe'),

-- 🔁 Transacciones
('40001', 'Conflicto de transacción, intente nuevamente'),
('40P01', 'Se detectó un bloqueo entre procesos'),

-- 🔒 Permisos
('42501', 'No tiene permisos para realizar esta acción'),

-- 🌐 Conexión
('08003', 'La conexión no está activa'),
('08006', 'Error en la conexión a la base de datos'),

-- ⚙️ Sistema / recursos
('53000', 'Recursos insuficientes'),
('53100', 'No hay espacio en disco'),
('53200', 'Memoria insuficiente'),

-- ⚠️ Estado / ejecución
('25000', 'Estado de transacción inválido'),
('25P02', 'La transacción falló previamente'),

-- 🧩 PL/pgSQL
('P0001', 'Error generado manualmente'),
('P0002', 'No se encontraron resultados'),
('P0003', 'Se encontraron demasiados resultados'),

-- 🧨 Otros útiles
('21000', 'Error: se esperaban menos resultados'),
('2200F', 'Texto vacío no permitido'),
('2200L', 'Documento XML inválido'),
('22032', 'JSON inválido');

-- DELETE FROM tab_cat_errores
-- Select * from tab_cat_errores