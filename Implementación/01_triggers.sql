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

