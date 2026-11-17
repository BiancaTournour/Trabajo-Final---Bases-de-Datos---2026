-- Definición de triggers

-- Horarios de centros sin superposicion
CREATE OR REPLACE FUNCTION horario_centro_sin_superposicion()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM horariocentro
    WHERE id_centro = NEW.id_centro
      AND dia = NEW.dia
      AND horario_apertura < NEW.horario_cierre
      AND horario_cierre > NEW.horario_apertura
      AND id_horario_centro <> NEW.id_horario_centro
  ) THEN
    RAISE EXCEPTION 'El horario se superpone con otro existente para el mismo centro y día.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_horario_centro_sin_superposicion
BEFORE INSERT OR UPDATE ON horariocentro
FOR EACH ROW EXECUTE FUNCTION horario_centro_sin_superposicion();

--Horarios de servicios sin superposicion
CREATE OR REPLACE FUNCTION horario_servicio_sin_superposicion()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM horarioservicio
    WHERE id_servicio = NEW.id_servicio
      AND dia = NEW.dia
      AND horario_apertura < NEW.horario_cierre
      AND horario_cierre > NEW.horario_apertura
      AND id_horario_servicio <> NEW.id_horario_servicio
  ) THEN
    RAISE EXCEPTION 'El horario se superpone con otro existente para el mismo servicio y día.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_horario_servicio_sin_superposicion
BEFORE INSERT OR UPDATE ON horarioservicio
FOR EACH ROW EXECUTE FUNCTION horario_servicio_sin_superposicion();

-- Impedir baja de especializaciones requeridas por servicios
CREATE OR REPLACE FUNCTION proveedor_especializacion_impedir_baja()
RETURNS TRIGGER AS $$
BEGIN 
  IF EXISTS (
    SELECT 1 
    FROM servicio s
    JOIN tipo_servicio ts
    ON s.id_tipo_servicio = ts.id_tipo_servicio
    WHERE ts.id_especializacion_requerida = OLD.id_especializacion
    AND (
      s.medico_a_cargo_matricula = OLD.nro_matricula
      OR EXISTS (
        SELECT 1
        FROM asignacionservicio a 
        WHERE a.id_servicio = s.id_servicio
        AND a.nro_matricula = OLD.nro_matricula
      )
    )
  ) THEN 
    RAISE EXCEPTION 'No se puede eliminar la especialización: el profesional participa en un servicio que la requiere.';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE trigger tgr_proveedor_especializacion_impedir_baja
BEFORE DELETE ON proveedor_especializacion
FOR EACH ROW EXECUTE FUNCTION proveedor_especializacion_impedir_baja();

-- Verificacion de medico a cargo valido
CREATE OR REPLACE FUNCTION servicio_medico_a_cargo_valido()
RETURNS TRIGGER AS $$
BEGIN
  -- 1) El profesional a cargo debe existir y ser de tipo Medico
  IF NOT EXISTS (
    SELECT 1
    FROM proveedor p
    WHERE p.nro_matricula = NEW.medico_a_cargo_matricula
      AND p.tipo_profesional = 'Medico'
  ) THEN
    RAISE EXCEPTION 'El profesional a cargo (matricula %) debe ser un Medico.',
      NEW.medico_a_cargo_matricula;
  END IF;

  -- 2) Si el tipo de servicio requiere una especializacion, el medico debe tenerla
  IF EXISTS (
    SELECT 1
    FROM tipo_servicio ts
    WHERE ts.id_tipo_servicio = NEW.id_tipo_servicio
      AND ts.id_especializacion_requerida IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM proveedor_especializacion pe
        WHERE pe.nro_matricula = NEW.medico_a_cargo_matricula
          AND pe.id_especializacion = ts.id_especializacion_requerida
      )
  ) THEN
    RAISE EXCEPTION 'El medico a cargo (matricula %) no posee la especializacion requerida por el tipo de servicio.',
      NEW.medico_a_cargo_matricula;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_servicio_medico_a_cargo_valido
BEFORE INSERT OR UPDATE ON servicio
FOR EACH ROW EXECUTE FUNCTION servicio_medico_a_cargo_valido();

-- Impedir cambios en un tipo de servicio que ya tiene servicios creados
CREATE OR REPLACE FUNCTION tipo_servicio_impedir_cambios()
RETURNS TRIGGER AS $$
BEGIN
  IF (
       NEW.cant_medicos_asist IS DISTINCT FROM OLD.cant_medicos_asist
    OR NEW.cant_enferm_asist IS DISTINCT FROM OLD.cant_enferm_asist
    OR NEW.id_especializacion_requerida IS DISTINCT FROM OLD.id_especializacion_requerida
  )
  AND EXISTS (
    SELECT 1
    FROM servicio s
    WHERE s.id_tipo_servicio = OLD.id_tipo_servicio
  ) THEN
    RAISE EXCEPTION 'No se puede modificar la dotacion, la especializacion requerida ni la marca de internacion del tipo de servicio %: ya tiene servicios creados.',
      OLD.id_tipo_servicio;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_tipo_servicio_impedir_cambios
BEFORE UPDATE ON tipo_servicio
FOR EACH ROW EXECUTE FUNCTION tipo_servicio_impedir_cambios();

-- AsignacionServicio
CREATE OR REPLACE FUNCTION asignacion_servicio_profesional_valido()
RETURNS TRIGGER AS $$
DECLARE
  v_tipo_profesional tipoprofesional;
  v_medico_a_cargo   INTEGER;
  v_id_espec_req     INTEGER;
BEGIN
  -- Busco el tipo del profesional que se quiere asignar
  SELECT p.tipo_profesional
  INTO v_tipo_profesional
  FROM proveedor p
  WHERE p.nro_matricula = NEW.nro_matricula;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El profesional con matricula % no existe.', NEW.nro_matricula;
  END IF;

  -- 1) El rol debe coincidir con el tipo de profesional
  IF (NEW.rol = 'Medico_Asistente'    AND v_tipo_profesional <> 'Medico')
  OR (NEW.rol = 'Enfermero_Asistente' AND v_tipo_profesional <> 'Enfermero') THEN
    RAISE EXCEPTION 'El rol % no corresponde a un profesional de tipo % (matricula %).',
      NEW.rol, v_tipo_profesional, NEW.nro_matricula;
  END IF;

  -- Busco el medico a cargo y la especializacion que pide el tipo de servicio
  SELECT s.medico_a_cargo_matricula, ts.id_especializacion_requerida
  INTO v_medico_a_cargo, v_id_espec_req
  FROM servicio s
  JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio
  WHERE s.id_servicio = NEW.id_servicio;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El servicio % no existe.', NEW.id_servicio;
  END IF;

  -- 2) No puede ser el medico a cargo del mismo servicio
  IF v_medico_a_cargo = NEW.nro_matricula THEN
    RAISE EXCEPTION 'El profesional (matricula %) ya es el medico a cargo del servicio %.',
      NEW.nro_matricula, NEW.id_servicio;
  END IF;

  -- 3) Debe tener la especializacion requerida (si el tipo de servicio pide una)
  IF v_id_espec_req IS NOT NULL AND NOT EXISTS (
    SELECT 1
    FROM proveedor_especializacion pe
    WHERE pe.nro_matricula = NEW.nro_matricula
      AND pe.id_especializacion = v_id_espec_req
  ) THEN
    RAISE EXCEPTION 'El profesional (matricula %) no posee la especializacion requerida por el tipo de servicio.',
      NEW.nro_matricula;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_asignacion_servicio_profesional_valido
BEFORE INSERT OR UPDATE ON asignacionservicio
FOR EACH ROW EXECUTE FUNCTION asignacion_servicio_profesional_valido();

-- asignacion servicio cupo
CREATE OR REPLACE FUNCTION asignacion_servicio_cupo()
RETURNS TRIGGER AS $$
DECLARE
  v_cupo     INTEGER;
  v_actuales INTEGER;
BEGIN
  -- Cupo permitido segun el rol que se quiere asignar
  SELECT CASE NEW.rol
           WHEN 'Medico_Asistente' THEN ts.cant_medicos_asist
           ELSE ts.cant_enferm_asist
         END
  INTO v_cupo
  FROM servicio s
  JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio
  WHERE s.id_servicio = NEW.id_servicio;

  -- Cuantos hay ya asignados con ese rol (sin contar la fila que se esta modificando)
  SELECT COUNT(*)
  INTO v_actuales
  FROM asignacionservicio a
  WHERE a.id_servicio = NEW.id_servicio
    AND a.rol = NEW.rol
    AND (TG_OP = 'INSERT'
         OR (a.id_servicio, a.nro_matricula) <> (OLD.id_servicio, OLD.nro_matricula));

  IF v_actuales + 1 > v_cupo THEN
    RAISE EXCEPTION 'Se supera la cantidad de % permitida para el servicio % (maximo: %).',
      NEW.rol, NEW.id_servicio, v_cupo;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_asignacion_servicio_cupo
BEFORE INSERT OR UPDATE ON asignacionservicio
FOR EACH ROW EXECUTE FUNCTION asignacion_servicio_cupo();

-- asignacion servicio impedir baja
CREATE OR REPLACE FUNCTION asignacion_servicio_impedir_baja()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.rol = 'Medico_Asistente' AND EXISTS (
    SELECT 1
    FROM historiaclinica h
    WHERE h.id_servicio = OLD.id_servicio
      AND h.medico_matricula = OLD.nro_matricula
  ) THEN
    RAISE EXCEPTION 'No se puede quitar al medico (matricula %) del servicio %: ya atendio pacientes en el.',
      OLD.nro_matricula, OLD.id_servicio;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_asignacion_servicio_impedir_baja
BEFORE DELETE ON asignacionservicio
FOR EACH ROW EXECUTE FUNCTION asignacion_servicio_impedir_baja();

-- historia clinica medico valido
CREATE OR REPLACE FUNCTION historia_clinica_medico_valido()
RETURNS TRIGGER AS $$
BEGIN
  -- 1) Quien atiende debe ser Medico
  IF NOT EXISTS (
    SELECT 1
    FROM proveedor p
    WHERE p.nro_matricula = NEW.medico_matricula
      AND p.tipo_profesional = 'Medico'
  ) THEN
    RAISE EXCEPTION 'El profesional que atiende (matricula %) debe ser un Medico.',
      NEW.medico_matricula;
  END IF;

  -- 2) Debe estar a cargo del servicio o asignado como medico asistente
  IF NOT EXISTS (
    SELECT 1
    FROM servicio s
    WHERE s.id_servicio = NEW.id_servicio
      AND s.medico_a_cargo_matricula = NEW.medico_matricula
  ) AND NOT EXISTS (
    SELECT 1
    FROM asignacionservicio a
    WHERE a.id_servicio = NEW.id_servicio
      AND a.nro_matricula = NEW.medico_matricula
      AND a.rol = 'Medico_Asistente'
  ) THEN
    RAISE EXCEPTION 'El medico (matricula %) no esta a cargo ni asignado como asistente en el servicio %.',
      NEW.medico_matricula, NEW.id_servicio;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_historia_clinica_medico_valido
BEFORE INSERT OR UPDATE ON historiaclinica
FOR EACH ROW EXECUTE FUNCTION historia_clinica_medico_valido();

-- internacion servicio valido
CREATE OR REPLACE FUNCTION internacion_servicio_valido()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM historiaclinica h
    JOIN servicio s       ON s.id_servicio = h.id_servicio
    JOIN tipo_servicio ts ON ts.id_tipo_servicio = s.id_tipo_servicio
    WHERE h.id_historia_clinica = NEW.id_historia_clinica
      AND ts.es_internacion = TRUE
  ) THEN
    RAISE EXCEPTION 'La historia clinica % no corresponde a un servicio de internacion.',
      NEW.id_historia_clinica;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_internacion_servicio_valido
BEFORE INSERT OR UPDATE ON internacion
FOR EACH ROW EXECUTE FUNCTION internacion_servicio_valido();

-- internacion sin superposicion
CREATE OR REPLACE FUNCTION internacion_sin_superposicion()
RETURNS TRIGGER AS $$
DECLARE
  v_dni INTEGER;
BEGIN
  -- Paciente al que pertenece esta internacion
  SELECT h.paciente_dni
  INTO v_dni
  FROM historiaclinica h
  WHERE h.id_historia_clinica = NEW.id_historia_clinica;

  -- Otras internaciones del mismo paciente que se pisen con las fechas nuevas
  IF EXISTS (
    SELECT 1
    FROM internacion i
    JOIN historiaclinica h ON h.id_historia_clinica = i.id_historia_clinica
    WHERE h.paciente_dni = v_dni
      AND i.id_internacion <> NEW.id_internacion
      AND i.fecha_ingreso <= COALESCE(NEW.fecha_egreso, 'infinity'::date)
      AND COALESCE(i.fecha_egreso, 'infinity'::date) >= NEW.fecha_ingreso
  ) THEN
    RAISE EXCEPTION 'El paciente (DNI %) ya tiene una internacion que se superpone con el periodo indicado.',
      v_dni;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_internacion_sin_superposicion
BEFORE INSERT OR UPDATE ON internacion
FOR EACH ROW EXECUTE FUNCTION internacion_sin_superposicion();

-- imperdir cambios
CREATE OR REPLACE FUNCTION servicio_impedir_cambios()
RETURNS TRIGGER AS $$
BEGIN
  IF (
       NEW.id_centro IS DISTINCT FROM OLD.id_centro
    OR NEW.id_tipo_servicio IS DISTINCT FROM OLD.id_tipo_servicio
  )
  AND (
       EXISTS (SELECT 1 FROM horarioservicio hs WHERE hs.id_servicio = OLD.id_servicio)
    OR EXISTS (SELECT 1 FROM asignacionservicio a WHERE a.id_servicio = OLD.id_servicio)
    OR EXISTS (SELECT 1 FROM historiaclinica h WHERE h.id_servicio = OLD.id_servicio)
  ) THEN
    RAISE EXCEPTION 'No se puede cambiar el centro ni el tipo del servicio %: ya tiene horarios, asignaciones o historias clinicas.',
      OLD.id_servicio;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_servicio_impedir_cambios
BEFORE UPDATE ON servicio
FOR EACH ROW EXECUTE FUNCTION servicio_impedir_cambios();