-- Definición de funciones y procedimientos

-- FN_Centros_Abiertos_Por_Servicio
CREATE OR REPLACE FUNCTION fn_centros_abiertos_por_servicio(p_id_tipo_servicio INTEGER)
RETURNS TABLE (centro VARCHAR) AS $$
DECLARE
  ahora TIMESTAMP := now() AT TIME ZONE 'America/Argentina/Buenos_Aires';
BEGIN
  RETURN QUERY
  SELECT c.nombre
  FROM centro c
  JOIN servicio s ON s.id_centro = c.id_centro
  JOIN horarioservicio hs ON hs.id_servicio = s.id_servicio
  WHERE s.id_tipo_servicio = p_id_tipo_servicio
    AND hs.dia = (enum_range(NULL::dias))[EXTRACT(ISODOW FROM ahora)::INT]
    AND ahora::TIME >= hs.horario_apertura
    AND ahora::TIME <  hs.horario_cierre
  GROUP BY c.id_centro, c.nombre
  ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

-- SP_Registrar_Alta_Paciente
CREATE OR REPLACE PROCEDURE sp_registrar_alta_paciente(p_id_internacion INTEGER, p_fecha_egreso DATE)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_fecha_ingreso DATE;
  v_fecha_egreso  DATE;
BEGIN
  IF p_fecha_egreso IS NULL THEN
    RAISE EXCEPTION 'La fecha de egreso es obligatoria.';
  END IF;

  -- Se bloquea la fila para que dos altas simultaneas no se pisen
  SELECT i.fecha_ingreso, i.fecha_egreso
  INTO v_fecha_ingreso, v_fecha_egreso
  FROM internacion i
  WHERE i.id_internacion = p_id_internacion
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'La internacion % no existe.', p_id_internacion;
  END IF;

  IF v_fecha_egreso IS NOT NULL THEN
    RAISE EXCEPTION 'La internacion % ya tiene el alta registrada (%).',
      p_id_internacion, v_fecha_egreso;
  END IF;

  IF p_fecha_egreso < v_fecha_ingreso THEN
    RAISE EXCEPTION 'La fecha de egreso (%) no puede ser anterior a la de ingreso (%).',
      p_fecha_egreso, v_fecha_ingreso;
  END IF;

  IF p_fecha_egreso > CURRENT_DATE THEN
    RAISE EXCEPTION 'La fecha de egreso (%) no puede ser futura.', p_fecha_egreso;
  END IF;

  UPDATE internacion
  SET fecha_egreso = p_fecha_egreso
  WHERE id_internacion = p_id_internacion;
END;
$$;