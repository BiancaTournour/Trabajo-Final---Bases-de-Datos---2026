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