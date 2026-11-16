-- definición de vistas

-- Vista_Pacientes_Internados_Actuales
CREATE VIEW vista_pacientes_internados_actuales AS
SELECT
  p.nombre AS nombre_paciente,
  p.apellido AS apellido_paciente,
  p.dni AS documento,
  i.fecha_ingreso,
  c.nombre AS centro,
  b.nombre AS barrio
FROM internacion i
JOIN historiaclinica hc ON hc.id_historia_clinica = i.id_historia_clinica
JOIN paciente p ON p.dni = hc.paciente_dni
JOIN servicio s ON s.id_servicio = hc.id_servicio
JOIN centro c ON c.id_centro = s.id_centro
JOIN barrio b ON b.id_barrio = c.id_barrio
WHERE i.fecha_egreso IS NULL;

-- Vista_Oferta_Servicios_Centro