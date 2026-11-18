-- ============================================================
-- PRUEBAS DE VALIDACION: TRIGGERS Y RESTRICCIONES
-- Proyecto: Centro de Salud - Bases de Datos 2026
--
-- Requisitos:
--   1. Ejecutar previamente 00_tablas.sql
--   2. Ejecutar 01_triggers.sql
--   3. Ejecutar 04_poblado.sql
--
-- Todas las pruebas se ejecutan dentro de una transaccion que
-- termina con ROLLBACK. Los datos originales no quedan modificados.
--
-- IMPORTANTE:
--   Las pruebas utilizan los identificadores incluidos en 04_poblado.sql.
--   Ejecutar el archivo completo en una base de pruebas ya poblada.
-- ============================================================

BEGIN;

DO $$
DECLARE
    v_rechazado BOOLEAN;
    v_mensaje TEXT;
BEGIN
    RAISE NOTICE 'INICIO: pruebas de CHECK y triggers';

    
    -- 1. CHECK de Internacion: fecha de egreso anterior al ingreso
    
    v_rechazado := FALSE;

    BEGIN
        INSERT INTO internacion
            (id_internacion, fecha_ingreso, fecha_egreso, id_historia_clinica)
        VALUES
            (900001, CURRENT_DATE - 5, CURRENT_DATE - 6, 1);
    EXCEPTION
        WHEN check_violation THEN
            v_rechazado := TRUE;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 1: se acepto una fecha de egreso anterior al ingreso.';
    END IF;

    RAISE NOTICE 'OK 1: CHECK de fechas de Internacion rechazo el registro invalido.';

    
    -- 2. CHECK de HorarioServicio: apertura posterior al cierre
    
    v_rechazado := FALSE;

    BEGIN
        INSERT INTO horarioservicio
            (id_horario_servicio, dia, horario_apertura, horario_cierre, id_servicio)
        VALUES
            (900001, 'Lunes', '18:00', '08:00', 1);
    EXCEPTION
        WHEN check_violation THEN
            v_rechazado := TRUE;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 2: se acepto un horario con apertura posterior al cierre.';
    END IF;

    RAISE NOTICE 'OK 2: CHECK de HorarioServicio rechazo el horario invalido.';

    
    -- 3. Trigger HorarioServicio: INSERT superpuesto
    -- El servicio 1 ya tiene los lunes de 08:00 a 18:00.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO horarioservicio
            (id_horario_servicio, dia, horario_apertura, horario_cierre, id_servicio)
        VALUES
            (900002, 'Lunes', '10:00', '12:00', 1);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se superpone' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 3: no se rechazo el horario superpuesto de HorarioServicio. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 3: el trigger de HorarioServicio rechazo el INSERT superpuesto.';

    
    -- 4. Trigger HorarioCentro: INSERT superpuesto
    -- El centro 1 ya tiene los lunes de 08:00 a 20:00.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO horariocentro
            (id_horario_centro, dia, horario_apertura, horario_cierre, id_centro)
        VALUES
            (900001, 'Lunes', '09:00', '11:00', 1);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se superpone' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 4: no se rechazo el horario superpuesto de HorarioCentro. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 4: el trigger de HorarioCentro rechazo el INSERT superpuesto.';

    
    -- 5. Trigger HorarioServicio: UPDATE superpuesto
    -- Se crea primero un horario valido para el martes y luego
    -- se intenta modificarlo para que se superponga el lunes.
    
    INSERT INTO horarioservicio
        (id_horario_servicio, dia, horario_apertura, horario_cierre, id_servicio)
    VALUES
        (900003, 'Martes', '08:00', '10:00', 1);

    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        UPDATE horarioservicio
        SET dia = 'Lunes',
            horario_apertura = '09:00',
            horario_cierre = '11:00'
        WHERE id_horario_servicio = 900003;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se superpone' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 5: no se rechazo el UPDATE superpuesto de HorarioServicio. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 5: el trigger de HorarioServicio rechazo el UPDATE superpuesto.';

    
    -- 6. Trigger HorarioCentro: UPDATE superpuesto
    
    INSERT INTO horariocentro
        (id_horario_centro, dia, horario_apertura, horario_cierre, id_centro)
    VALUES
        (900002, 'Martes', '08:00', '10:00', 1);

    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        UPDATE horariocentro
        SET dia = 'Lunes',
            horario_apertura = '09:00',
            horario_cierre = '11:00'
        WHERE id_horario_centro = 900002;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se superpone' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 6: no se rechazo el UPDATE superpuesto de HorarioCentro. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 6: el trigger de HorarioCentro rechazo el UPDATE superpuesto.';

    
    -- 7. Trigger Proveedor_Especializacion: impedir DELETE
    -- El medico 1001 posee la especializacion 1 y es medico a
    -- cargo del servicio 1, cuyo tipo requiere esa especialidad.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        DELETE FROM proveedor_especializacion
        WHERE nro_matricula = 1001
          AND id_especializacion = 1;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('no se puede eliminar la especializacion' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 7: se permitio eliminar una especializacion requerida. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 7: se impidio eliminar una especializacion requerida.';

    
    -- 8. Trigger Tipo_Servicio: impedir cambios si tiene servicios
    -- El tipo 1 tiene servicios asociados.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        UPDATE tipo_servicio
        SET cant_enferm_asist = cant_enferm_asist + 1
        WHERE id_tipo_servicio = 1;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('no se puede modificar' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 8: se permitio modificar un Tipo_Servicio con servicios asociados. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 8: se impidio modificar un Tipo_Servicio que ya tiene servicios.';

    
    -- 9. Trigger Servicio: medico a cargo de tipo incorrecto
    -- La matricula 2001 corresponde a un enfermero.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        UPDATE servicio
        SET medico_a_cargo_matricula = 2001
        WHERE id_servicio = 1;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('debe ser un medico' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 9: se permitio asignar un enfermero como medico a cargo. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 9: se rechazo un profesional que no es medico como medico a cargo.';

    
    -- 10. Trigger Servicio: impedir cambio de centro/tipo con
    -- dependencias existentes. El servicio 1 tiene horarios,
    -- asignaciones e historias clinicas.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        UPDATE servicio
        SET id_centro = 2
        WHERE id_servicio = 1;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('no se puede modificar' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 10: se permitio cambiar el centro de un servicio con dependencias. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 10: se impidio modificar un servicio con dependencias.';

    
    -- 11. Trigger AsignacionServicio: rol no compatible
    -- La matricula 2002 es Enfermero, pero se intenta asignar
    -- como Medico_Asistente.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    -- En los datos de poblado, todos los tipos tienen cupo 0 de
    -- medicos asistentes. Se desactiva temporalmente el trigger de
    -- cupo para aislar la validacion del rol. Se reactiva enseguida.
    ALTER TABLE asignacionservicio
        DISABLE TRIGGER tgr_asignacion_servicio_cupo;

    BEGIN
        INSERT INTO asignacionservicio (id_servicio, nro_matricula, rol)
        VALUES (1, 2002, 'Medico_Asistente');
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('no corresponde' IN LOWER(v_mensaje)) > 0;
    END;

    ALTER TABLE asignacionservicio
        ENABLE TRIGGER tgr_asignacion_servicio_cupo;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 11: no se rechazo el rol incompatible. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 11: se rechazo una asignacion con rol incompatible.';

    
    -- 12. Trigger AsignacionServicio: superar el cupo
    -- El servicio 1 permite un enfermero asistente y ya tiene
    -- asignado al profesional 2001.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO asignacionservicio (id_servicio, nro_matricula, rol)
        VALUES (1, 2002, 'Enfermero_Asistente');
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se supera la cantidad' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 12: no se rechazo la asignacion que supera el cupo. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 12: se rechazo una asignacion que supera el cupo.';

    
    -- 13. Trigger HistoriaClinica: profesional no habilitado
    -- El profesional 2001 es enfermero, no puede registrar
    -- una atencion como medico.
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO historiaclinica
            (id_historia_clinica, dia_visita, diagnostico, tratamiento,
             paciente_dni, id_servicio, medico_matricula)
        VALUES
            (900001, CURRENT_DATE, 'Diagnostico de prueba',
             'Tratamiento de prueba', 30000001, 1, 2001);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('debe ser un medico' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 13: se permitio registrar una historia con un enfermero como medico. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 13: se rechazo una historia clinica con profesional no medico.';

    
    -- 14. Trigger Internacion: la historia no pertenece a un
    -- servicio de internacion. La historia 31 corresponde al
    -- servicio 6, de tipo Cardiologia (no internacion).
    
    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO internacion
            (id_internacion, fecha_ingreso, fecha_egreso, id_historia_clinica)
        VALUES
            (900002, CURRENT_DATE, NULL, 31);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('no corresponde a un servicio de internacion' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 14: se permitio internar desde un servicio que no es de internacion. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 14: se rechazo una internacion originada en un servicio no habilitado.';

    
    -- 15. Trigger Internacion: impedir internaciones superpuestas
    -- El paciente 30000001 ya tiene una internacion activa (id 1).
    -- Se intenta crear otra internacion usando una nueva historia
    -- clinica del mismo paciente y un servicio de internacion.
    
    INSERT INTO historiaclinica
        (id_historia_clinica, dia_visita, diagnostico, tratamiento,
         paciente_dni, id_servicio, medico_matricula)
    VALUES
        (900003, CURRENT_DATE, 'Control para prueba de internacion',
         'Tratamiento de prueba', 30000001, 1, 1001);

    v_rechazado := FALSE;
    v_mensaje := NULL;

    BEGIN
        INSERT INTO internacion
            (id_internacion, fecha_ingreso, fecha_egreso, id_historia_clinica)
        VALUES
            (900003, CURRENT_DATE, NULL, 900003);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            v_rechazado := POSITION('se superpone' IN LOWER(v_mensaje)) > 0;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 15: se permitio una internacion superpuesta. Mensaje: %', v_mensaje;
    END IF;

    RAISE NOTICE 'OK 15: se rechazo una internacion superpuesta para el mismo paciente.';

    
    -- 16. Internacion: permitir actualizar el egreso de una
    -- internacion activa con una fecha valida.
    
    UPDATE internacion
    SET fecha_egreso = CURRENT_DATE
    WHERE id_internacion = 1
      AND fecha_egreso IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'FALLO prueba 16: no se encontro la internacion activa 1 para actualizar.';
    END IF;

    RAISE NOTICE 'OK 16: se permitio actualizar la fecha de egreso con una fecha valida.';

    
    -- 17. Internacion: rechazar UPDATE con egreso anterior
    -- al ingreso.
    
    v_rechazado := FALSE;

    BEGIN
        UPDATE internacion
        SET fecha_egreso = fecha_ingreso - 1
        WHERE id_internacion = 1;
    EXCEPTION
        WHEN check_violation THEN
            v_rechazado := TRUE;
    END;

    IF NOT v_rechazado THEN
        RAISE EXCEPTION 'FALLO prueba 17: se permitio actualizar una fecha de egreso anterior al ingreso.';
    END IF;

    RAISE NOTICE 'OK 17: CHECK rechazo un UPDATE con fecha de egreso invalida.';

    RAISE NOTICE 'FINALIZADO: todas las pruebas de validacion finalizaron correctamente.';
END;
$$;

-- Se revierten tanto las inserciones de prueba como la actualizacion
-- de la internacion utilizada en el caso 16.
ROLLBACK;
