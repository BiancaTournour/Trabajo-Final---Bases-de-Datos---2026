-- Pruebas de roles y permisos (plan de testing D.3)
--
-- Requisitos: haber ejecutado 00_tablas, 01_triggers, 02_vistas,
-- 03_funciones_procedimientos, 04_poblado y 05_roles_permisos.
-- Ejecutar el archivo completo con una conexion de superusuario (postgres):
-- cada prueba cambia de usuario con SET ROLE.
--
-- Cada prueba ejecuta UNA sentencia como el usuario indicado:
--   PERMITIDO -> debe ejecutarse sin errores.
--   DENEGADO  -> debe fallar por falta de permisos (permission denied / must be owner).
-- Si una sentencia denegada falla por otro motivo, se informa como FALLO.
--
-- Todo corre dentro de una transaccion que termina en ROLLBACK:
-- la base queda como estaba. Si el script se corta, ejecutar ROLLBACK;
-- Debe ejecutarse completo y en una sola sesion. Probado con psql:
--   psql -U postgres -d Centro-de-Salud -f pruebas_permisos.sql

BEGIN;

CREATE TEMP TABLE resultados (
    nro      SERIAL,
    usuario  TEXT,
    prueba   TEXT,
    esperado TEXT,
    resultado TEXT,
    detalle  TEXT
);

-- Ejecuta p_sql como p_usuario y guarda si el resultado fue el esperado.
CREATE FUNCTION pg_temp.probar(p_usuario TEXT, p_prueba TEXT, p_sql TEXT, p_esperado TEXT)
RETURNS VOID AS $$
DECLARE
    v_ok      BOOLEAN;
    v_detalle TEXT;
BEGIN
    EXECUTE format('SET LOCAL ROLE %I', p_usuario);
    BEGIN
        EXECUTE p_sql;
        v_ok      := (p_esperado = 'PERMITIDO');
        v_detalle := CASE WHEN v_ok THEN 'Se ejecuto sin errores'
                          ELSE 'Se ejecuto y debia ser denegada' END;
    EXCEPTION
        WHEN insufficient_privilege THEN
            v_ok      := (p_esperado = 'DENEGADO');
            v_detalle := SQLERRM;
        WHEN OTHERS THEN
            v_ok      := FALSE;
            v_detalle := 'Error que no es de permisos: ' || SQLERRM;
    END;
    RESET ROLE;

    INSERT INTO resultados (usuario, prueba, esperado, resultado, detalle)
    VALUES (p_usuario, p_prueba, p_esperado, CASE WHEN v_ok THEN 'OK' ELSE 'FALLO' END, v_detalle);
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    -- -----------------------------------------------------------------
    -- Personal medico (usr_medico)
    -- -----------------------------------------------------------------
    PERFORM pg_temp.probar('usr_medico', 'SELECT sobre historiaclinica',
        'SELECT * FROM historiaclinica', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'INSERT sobre historiaclinica',
        'INSERT INTO historiaclinica
         SELECT id_historia_clinica + 100000, dia_visita, diagnostico, tratamiento,
                paciente_dni, id_servicio, medico_matricula
         FROM historiaclinica ORDER BY id_historia_clinica LIMIT 1', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'UPDATE sobre historiaclinica',
        'UPDATE historiaclinica SET tratamiento = tratamiento
         WHERE id_historia_clinica = (SELECT MIN(id_historia_clinica) FROM historiaclinica)',
        'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'UPDATE sobre paciente',
        'UPDATE paciente SET domicilio = domicilio
         WHERE dni = (SELECT MIN(dni) FROM paciente)', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'Ejecutar FN_Centros_Abiertos_Por_Servicio',
        'SELECT * FROM fn_centros_abiertos_por_servicio(1)', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'Ejecutar SP_Registrar_Alta_Paciente',
        format('CALL sp_registrar_alta_paciente(%s, CURRENT_DATE)',
               (SELECT MIN(id_internacion) FROM internacion WHERE fecha_egreso IS NULL)),
        'PERMITIDO');
    PERFORM pg_temp.probar('usr_medico', 'DELETE sobre historiaclinica',
        'DELETE FROM historiaclinica WHERE false', 'DENEGADO');
    PERFORM pg_temp.probar('usr_medico', 'ALTER TABLE sobre historiaclinica',
        'ALTER TABLE historiaclinica ADD COLUMN nota_prueba TEXT', 'DENEGADO');
    PERFORM pg_temp.probar('usr_medico', 'DROP TABLE sobre historiaclinica',
        'DROP TABLE historiaclinica', 'DENEGADO');

    -- -----------------------------------------------------------------
    -- Personal administrativo / recepcion (usr_recepcion)
    -- -----------------------------------------------------------------
    PERFORM pg_temp.probar('usr_recepcion', 'SELECT sobre paciente',
        'SELECT * FROM paciente', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_recepcion', 'INSERT sobre paciente',
        $q$INSERT INTO paciente (dni, nombre, apellido, domicilio, fecha_nacimiento, id_barrio)
           VALUES (99999999, 'Prueba', 'Recepcion', 'Calle 1', DATE '1990-01-01',
                   (SELECT id_barrio FROM paciente LIMIT 1))$q$, 'PERMITIDO');
    PERFORM pg_temp.probar('usr_recepcion', 'UPDATE sobre paciente',
        'UPDATE paciente SET domicilio = domicilio
         WHERE dni = (SELECT MIN(dni) FROM paciente)', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_recepcion', 'UPDATE sobre internacion',
        'UPDATE internacion SET fecha_egreso = fecha_egreso
         WHERE id_internacion = (SELECT MIN(id_internacion) FROM internacion)', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_recepcion', 'SELECT sobre Vista_Pacientes_Internados_Actuales',
        'SELECT * FROM vista_pacientes_internados_actuales', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_recepcion', 'SELECT sobre historiaclinica',
        'SELECT * FROM historiaclinica', 'DENEGADO');
    PERFORM pg_temp.probar('usr_recepcion', 'UPDATE sobre historiaclinica',
        'UPDATE historiaclinica SET tratamiento = tratamiento WHERE false', 'DENEGADO');

    -- -----------------------------------------------------------------
    -- Auditor (usr_auditoria)
    -- -----------------------------------------------------------------
    PERFORM pg_temp.probar('usr_auditoria', 'SELECT sobre Vista_Pacientes_Internados_Actuales',
        'SELECT * FROM vista_pacientes_internados_actuales', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_auditoria', 'SELECT sobre Vista_Oferta_Servicios_Centro',
        'SELECT * FROM vista_oferta_servicios_centro', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_auditoria', 'SELECT directo sobre paciente',
        'SELECT * FROM paciente', 'DENEGADO');
    PERFORM pg_temp.probar('usr_auditoria', 'INSERT sobre paciente',
        $q$INSERT INTO paciente (dni, nombre, apellido, domicilio, fecha_nacimiento, id_barrio)
           VALUES (99999997, 'Prueba', 'Auditor', 'Calle 1', DATE '1990-01-01', 1)$q$, 'DENEGADO');
    PERFORM pg_temp.probar('usr_auditoria', 'UPDATE sobre paciente',
        'UPDATE paciente SET domicilio = domicilio WHERE false', 'DENEGADO');
    PERFORM pg_temp.probar('usr_auditoria', 'DELETE sobre paciente',
        'DELETE FROM paciente WHERE false', 'DENEGADO');

    -- -----------------------------------------------------------------
    -- Administrador (usr_admin_db)
    -- -----------------------------------------------------------------
    PERFORM pg_temp.probar('usr_admin_db', 'DML: SELECT sobre historiaclinica',
        'SELECT * FROM historiaclinica', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DML: INSERT sobre paciente',
        $q$INSERT INTO paciente (dni, nombre, apellido, domicilio, fecha_nacimiento, id_barrio)
           VALUES (99999998, 'Prueba', 'Admin', 'Calle 1', DATE '1990-01-01',
                   (SELECT id_barrio FROM paciente LIMIT 1))$q$, 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DML: UPDATE sobre paciente',
        'UPDATE paciente SET domicilio = ''Calle 2'' WHERE dni = 99999998', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DML: DELETE sobre paciente',
        'DELETE FROM paciente WHERE dni = 99999998', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DDL: CREATE TABLE',
        'CREATE TABLE prueba_admin (id INTEGER)', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DDL: ALTER TABLE sobre paciente',
        'ALTER TABLE paciente ADD COLUMN nota_prueba TEXT', 'PERMITIDO');
    PERFORM pg_temp.probar('usr_admin_db', 'DDL: DROP TABLE',
        'DROP TABLE prueba_admin', 'PERMITIDO');
    -- Un GRANT sin permiso solo emite un WARNING (no un error), por eso se
    -- comprueba que el privilegio realmente se haya otorgado.
    PERFORM pg_temp.probar('usr_admin_db', 'DCL: GRANT sobre paciente',
        $q$DO $x$
           BEGIN
               GRANT SELECT ON paciente TO rol_auditor;
               IF NOT has_table_privilege('rol_auditor', 'paciente', 'SELECT') THEN
                   RAISE EXCEPTION 'El GRANT no tuvo efecto' USING ERRCODE = 'insufficient_privilege';
               END IF;
           END $x$ $q$, 'PERMITIDO');
END $$;

-- Resultados
SELECT nro, usuario, prueba, esperado, resultado, detalle
FROM resultados
ORDER BY nro;

SELECT COUNT(*)                                AS pruebas,
       COUNT(*) FILTER (WHERE resultado = 'OK')    AS ok,
       COUNT(*) FILTER (WHERE resultado = 'FALLO') AS fallos
FROM resultados;

ROLLBACK;