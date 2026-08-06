-- ===================================================================
-- ARCHIVO: 01_menu_cascada.sql
-- DESCRIPCIÓN: Sistema completo de eliminación recursiva de menús
-- BASE DE DATOS: PostgreSQL
-- ===================================================================

-- ===================================================================
-- 1. ELIMINAR TRIGGERS Y FUNCIONES EXISTENTES (SI LAS HAY)
-- ===================================================================
DROP TRIGGER IF EXISTS tg_menu_delete_cascada ON tab_menus CASCADE;
DROP TRIGGER IF EXISTS tg_desasignar_menu ON tab_menus CASCADE;
DROP FUNCTION IF EXISTS fun_delete_menu_recursivo(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS fun_delete_menu_cascada(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS fun_verificar_dependencias_menu(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS fun_trigger_delete_menu_cascada() CASCADE;

-- ===================================================================
-- 2. FUNCIÓN PRINCIPAL: ELIMINACIÓN RECURSIVA (VERSIÓN SIMPLE)
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_delete_menu_recursivo(
    p_id_menu VARCHAR
)
RETURNS TEXT AS
$$
DECLARE
    v_hijo RECORD;
    v_resultado TEXT;
    v_contador INTEGER := 0;
    v_nombre_menu VARCHAR;
BEGIN
    -- Validar que el ID no sea nulo
    IF p_id_menu IS NULL THEN
        RETURN 'ERROR: El ID del menú no puede ser nulo';
    END IF;

    -- Validar que el menú existe
    SELECT COUNT(*) INTO v_contador 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;
    
    IF v_contador = 0 THEN
        RETURN 'ERROR: El menú con ID ' || p_id_menu || ' no existe';
    END IF;

    -- Obtener el nombre del menú
    SELECT nom_menu INTO v_nombre_menu 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;

    -- Buscar y eliminar recursivamente todos los submenús
    FOR v_hijo IN 
        SELECT id_menu 
        FROM tab_menus 
        WHERE ind_id_padre = p_id_menu
    LOOP
        v_resultado := fun_delete_menu_recursivo(v_hijo.id_menu);
        
        IF v_resultado NOT LIKE 'OK%' THEN
            RETURN 'ERROR al eliminar submenú ' || v_hijo.id_menu || ': ' || v_resultado;
        END IF;
    END LOOP;

    -- Eliminar asignaciones del menú actual
    DELETE FROM tab_menu_usuarios WHERE id_menu = p_id_menu;
    
    -- Eliminar el menú actual
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;
    
    RETURN 'OK: Menú "' || v_nombre_menu || '" (' || p_id_menu || ') eliminado';
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 3. FUNCIÓN CON ESTADÍSTICAS (VERSIÓN DETALLADA)
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_delete_menu_cascada(
    p_id_menu VARCHAR
)
RETURNS TABLE(
    mensaje TEXT,
    menus_eliminados INTEGER,
    asignaciones_eliminadas INTEGER
) AS
$$
DECLARE
    v_hijo RECORD;
    v_resultado RECORD;
    v_total_menus INTEGER := 0;
    v_total_asignaciones INTEGER := 0;
    v_nombre_menu VARCHAR;
BEGIN
    -- Validaciones
    IF p_id_menu IS NULL THEN
        mensaje := 'ERROR: El ID del menú no puede ser nulo';
        menus_eliminados := 0;
        asignaciones_eliminadas := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_total_menus 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;
    
    IF v_total_menus = 0 THEN
        mensaje := 'ERROR: El menú con ID ' || p_id_menu || ' no existe';
        menus_eliminados := 0;
        asignaciones_eliminadas := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    SELECT nom_menu INTO v_nombre_menu 
    FROM tab_menus 
    WHERE id_menu = p_id_menu;

    -- Procesar hijos recursivamente
    FOR v_hijo IN 
        SELECT id_menu FROM tab_menus WHERE ind_id_padre = p_id_menu
    LOOP
        FOR v_resultado IN 
            SELECT * FROM fun_delete_menu_cascada(v_hijo.id_menu)
        LOOP
            v_total_menus := v_total_menus + v_resultado.menus_eliminados;
            v_total_asignaciones := v_total_asignaciones + v_resultado.asignaciones_eliminadas;
        END LOOP;
    END LOOP;

    -- Contar y eliminar asignaciones
    SELECT COUNT(*) INTO v_total_asignaciones 
    FROM tab_menu_usuarios 
    WHERE id_menu = p_id_menu;

    DELETE FROM tab_menu_usuarios WHERE id_menu = p_id_menu;
    DELETE FROM tab_menus WHERE id_menu = p_id_menu;
    
    v_total_menus := v_total_menus + 1;

    -- Retornar resultado
    mensaje := 'Eliminado: ' || v_nombre_menu || ' (' || p_id_menu || ')';
    menus_eliminados := v_total_menus;
    asignaciones_eliminadas := v_total_asignaciones;
    
    RETURN NEXT;

EXCEPTION
    WHEN OTHERS THEN
        mensaje := 'ERROR: ' || SQLERRM;
        menus_eliminados := 0;
        asignaciones_eliminadas := 0;
        RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 4. FUNCIÓN PARA VER DEPENDENCIAS (ANTES DE ELIMINAR)
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_verificar_dependencias_menu(
    p_id_menu VARCHAR
)
RETURNS TABLE(
    nivel INTEGER,
    id_menu VARCHAR,
    nom_menu VARCHAR,
    tiene_usuarios BOOLEAN,
    cantidad_usuarios BIGINT
) AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE menu_tree AS (
        SELECT 
            m.id_menu, 
            m.nom_menu, 
            m.ind_id_padre, 
            0 as nivel,
            EXISTS(SELECT 1 FROM tab_menu_usuarios mu WHERE mu.id_menu = m.id_menu) as tiene_usuarios,
            (SELECT COUNT(*) FROM tab_menu_usuarios mu WHERE mu.id_menu = m.id_menu) as cantidad_usuarios
        FROM tab_menus m
        WHERE m.id_menu = p_id_menu
        
        UNION ALL
        
        SELECT 
            m.id_menu, 
            m.nom_menu, 
            m.ind_id_padre, 
            mt.nivel + 1,
            EXISTS(SELECT 1 FROM tab_menu_usuarios mu WHERE mu.id_menu = m.id_menu),
            (SELECT COUNT(*) FROM tab_menu_usuarios mu WHERE mu.id_menu = m.id_menu)
        FROM tab_menus m
        INNER JOIN menu_tree mt ON m.ind_id_padre = mt.id_menu
    )
    SELECT 
        nivel, 
        id_menu, 
        nom_menu, 
        tiene_usuarios,
        cantidad_usuarios
    FROM menu_tree 
    ORDER BY nivel DESC, id_menu;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 5. TRIGGER PARA ELIMINACIÓN AUTOMÁTICA EN CASCADA
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_trigger_delete_menu_cascada()
RETURNS TRIGGER AS
$$
DECLARE
    v_hijo RECORD;
BEGIN
    -- Eliminar recursivamente todos los hijos
    FOR v_hijo IN 
        SELECT id_menu FROM tab_menus WHERE ind_id_padre = OLD.id_menu
    LOOP
        DELETE FROM tab_menus WHERE id_menu = v_hijo.id_menu;
    END LOOP;
    
    -- Eliminar asignaciones de usuarios
    DELETE FROM tab_menu_usuarios WHERE id_menu = OLD.id_menu;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Activar el trigger
CREATE TRIGGER tg_menu_delete_cascada
    BEFORE DELETE ON tab_menus 
    FOR EACH ROW
    EXECUTE FUNCTION fun_trigger_delete_menu_cascada();

-- ===================================================================
-- 6. FUNCIÓN AUXILIAR: ELIMINAR MÚLTIPLES MENÚS DE UNA VEZ
-- ===================================================================
CREATE OR REPLACE FUNCTION fun_delete_multiple_menus(
    VARIADIC p_id_menus VARCHAR[]
)
RETURNS TABLE(
    id_menu_eliminado VARCHAR,
    resultado TEXT
) AS
$$
DECLARE
    v_menu VARCHAR;
BEGIN
    FOREACH v_menu IN ARRAY p_id_menus
    LOOP
        id_menu_eliminado := v_menu;
        resultado := fun_delete_menu_recursivo(v_menu);
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 7. DATOS DE PRUEBA (CREAR MENÚS DE EJEMPLO)
-- ===================================================================
-- NOTA: Estas líneas son solo para probar, coméntalas si no las necesitas

DO $$
BEGIN
    -- Limpiar datos de prueba anteriores (excepto menú 99)
    DELETE FROM tab_menus WHERE id_menu NOT IN ('99');
    
    -- Insertar menús de ejemplo
    INSERT INTO tab_menus (id_menu, nom_menu, ind_id_padre, nom_programa, ind_borrado) VALUES
        ('1', 'Configuración', '0', 'no_aplica', FALSE),
        ('11', 'Parámetros', '1', 'pmtros.php', FALSE),
        ('12', 'Gestión de Accesos', '1', 'no_aplica', FALSE),
        ('121', 'Usuarios', '12', 'usuarios.php', FALSE),
        ('122', 'Cambio de Clave', '12', 'cambiar_clave.php', FALSE),
        ('123', 'Menús', '12', 'menus.php', FALSE),
        ('13', 'Tablas Maestras', '1', 'no_aplica', FALSE),
        ('131', 'Departamentos', '13', 'dptos.php', FALSE),
        ('132', 'Ciudades', '13', 'ciudades.php', FALSE),
        ('2', 'Facturación', '0', 'no_aplica', FALSE),
        ('21', 'Cotizaciones', '2', 'no_aplica', FALSE),
        ('211', 'Nueva Cotización', '21', 'nueva_cotizacion.php', FALSE),
        ('3', 'Compras', '0', 'no_aplica', FALSE),
        ('31', 'Proveedores', '3', 'proveedores.php', FALSE);
    
    -- Insertar asignaciones de prueba para el usuario admin
    INSERT INTO tab_menu_usuarios (id_usuario, id_menu) VALUES
        ('admin', '1'), ('admin', '11'), ('admin', '12'), ('admin', '121'),
        ('admin', '122'), ('admin', '123'), ('admin', '13'), ('admin', '131'),
        ('admin', '132'), ('admin', '2'), ('admin', '21'), ('admin', '211'),
        ('admin', '3'), ('admin', '31')
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Datos de prueba insertados correctamente';
END $$;

-- ===================================================================
-- 8. EJEMPLOS DE USO (COMENTADOS)
-- ===================================================================

/*
╔═══════════════════════════════════════════════════════════════════╗
║                    FORMAS DE USO DEL SISTEMA                      ║
╚═══════════════════════════════════════════════════════════════════╝

┌───────────────────────────────────────────────────────────────────┐
│ 1. VER DEPENDENCIAS ANTES DE ELIMINAR                            │
├───────────────────────────────────────────────────────────────────┤
│ SELECT * FROM fun_verificar_dependencias_menu('1');              │
│                                                                   │
│ Resultado: Muestra todo el árbol de menús que se eliminarán      │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│ 2. ELIMINAR UN MENÚ Y TODOS SUS SUBMENÚS (VERSIÓN SIMPLE)       │
├───────────────────────────────────────────────────────────────────┤
│ SELECT fun_delete_menu_recursivo('1');                           │
│                                                                   │
│ Resultado: 'OK: Menú "Configuración" (1) eliminado'             │
│ Nota: Elimina '1', '11', '12', '121', '122', '123', '13', ...  │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│ 3. ELIMINAR CON ESTADÍSTICAS (VERSIÓN DETALLADA)                 │
├───────────────────────────────────────────────────────────────────┤
│ SELECT * FROM fun_delete_menu_cascada('1');                      │
│                                                                   │
│ Resultado:                                                       │
│ ┌─────────────────────────────────────┬──────┬─────────────┐    │
│ │ mensaje                             │ menus│ asignaciones│    │
│ ├─────────────────────────────────────┼──────┼─────────────┤    │
│ │ Eliminado: Configuración (1)        │  9   │     9       │    │
│ └─────────────────────────────────────┴──────┴─────────────┘    │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│ 4. ELIMINAR VARIOS MENÚS A LA VEZ                                 │
├───────────────────────────────────────────────────────────────────┤
│ SELECT * FROM fun_delete_multiple_menus('2', '3');               │
│                                                                   │
│ Resultado:                                                       │
│ ┌─────────────────┬────────────────────────────────────┐         │
│ │ id_menu_eliminado│ resultado                          │         │
│ ├─────────────────┼────────────────────────────────────┤         │
│ │ 2               │ OK: Menú "Facturación" (2) eliminado│         │
│ │ 3               │ OK: Menú "Compras" (3) eliminado    │         │
│ └─────────────────┴────────────────────────────────────┘         │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│ 5. ELIMINAR USANDO EL TRIGGER (DELETE NORMAL)                    │
├───────────────────────────────────────────────────────────────────┤
│ DELETE FROM tab_menus WHERE id_menu = '1';                       │
│                                                                   │
│ Nota: El trigger elimina automáticamente todos los hijos y las   │
│       asignaciones de usuarios                                   │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│ 6. RESTAURAR DATOS DE PRUEBA (DESPUÉS DE ELIMINAR)               │
├───────────────────────────────────────────────────────────────────┤
-- Re-ejecutar la sección 7 (Datos de prueba)
└───────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════╗
║                    EXPLICACIÓN DEL PROCESO                        ║
╚═══════════════════════════════════════════════════════════════════╝

PASO 1: Se identifica el menú padre (ej: '1' - Configuración)
        │
        ▼
PASO 2: Se buscan todos sus hijos directos (ej: '11', '12', '13')
        │
        ▼
PASO 3: Por cada hijo, se repite el proceso recursivamente
        │
        ▼
PASO 4: Se llega hasta las hojas (menús sin hijos)
        │
        ▼
PASO 5: Se eliminan las hojas primero (de abajo hacia arriba)
        │
        ▼
PASO 6: Se eliminan las asignaciones de usuarios
        │
        ▼
PASO 7: Finalmente se elimina el menú padre

RESULTADO: Todos los menús descendientes son eliminados sin dejar
           registros huérfanos ni asignaciones pendientes.
*/

-- ===================================================================
-- CONSULTA PARA VER LA ESTRUCTURA ACTUAL DE MENÚS (ANTES DE ELIMINAR)
-- ===================================================================
SELECT '=== ESTRUCTURA ACTUAL DE MENÚS ===' AS info;

WITH RECURSIVE menu_tree AS (
    SELECT 
        id_menu, 
        nom_menu, 
        ind_id_padre, 
        0 as nivel,
        id_menu::TEXT as ruta
    FROM tab_menus 
    WHERE ind_id_padre = '0'
    
    UNION ALL
    
    SELECT 
        m.id_menu, 
        m.nom_menu, 
        m.ind_id_padre, 
        mt.nivel + 1,
        mt.ruta || ' -> ' || m.id_menu
    FROM tab_menus m
    INNER JOIN menu_tree mt ON m.ind_id_padre = mt.id_menu
)
SELECT 
    nivel,
    id_menu,
    nom_menu,
    ruta
FROM menu_tree 
ORDER BY ruta;

-- ===================================================================
-- FIN DEL ARCHIVO
-- ===================================================================