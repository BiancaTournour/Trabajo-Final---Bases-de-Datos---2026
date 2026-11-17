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

-- Impedir cambios en tipo de servicios asociados.
CREATE OR REPLACE FUNCTION tipo_servicio_impedir_cambios()
RETURNS TRIGGER AS $$
BEGIN 
  IF EXISTS (
    SELECT 1 
    FROM servicio
    WHERE s.id_tipo_servicio = OLD.id_tipo_servicio
  ) AND (
    NEW.cant_medicos_asist IS DISTINCT FROM OLD.cant_medicos_asist
    OR NEW.cant_enferm_asist IS DISTINCT FROM OLD.cant_enferm_asist
    OR NEW.id_especializacion_requerida
    IS DISTINCT FROM OLD.id_especializacion_requerida
  ) THEN 
    RAISE EXCEPTION 
    'No se puede modificar la dotacion ni la especializacion requerida: existen servicios asociados.';
  END IF;

  RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_tipo_servicio_impedir_cambios
BEFORE UPDATE ON tipo_servicio
FOR EACH ROW EXECUTE FUNCTION tipo_servicio_impedir_cambios();

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
