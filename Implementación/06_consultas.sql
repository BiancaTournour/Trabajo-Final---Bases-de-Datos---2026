-- Definicion de consultas principales

-- Consulta A: Pacientes con un diagnóstico determinado por ciudad
SELECT
    ci.nombre AS ciudad,
    COUNT(DISTINCT p.dni) AS cantidad_pacientes
FROM historiaclinica hc
JOIN paciente p
    ON hc.paciente_dni = p.dni
JOIN barrio b
    ON p.id_barrio = b.id_barrio
JOIN ciudad ci
    ON b.id_ciudad = ci.id_ciudad
WHERE hc.diagnostico = 'Migraña' --Reemplazar con el diagnóstico deseado
GROUP BY ci.id_ciudad, ci.nombre
ORDER BY ci.nombre;

-- Consulta B: Centros de salud que ofrecen un servicio determinado y están abiertos al momento de la consulta
SELECT *
FROM fn_centros_abiertos_por_servicio(11); --Reemplazar 11 por el id del TIPO de servicio deseado (tipo_servicio.id_tipo_servicio). Si no devuelve filas, no hay ningun centro abierto en este momento para ese tipo de servicio


-- Consulta C: Médico con mayor cantidad de pacientes por centro
WITH paciente_por_medico AS (
    SELECT 
        c.id_centro,
        b.nombre as barrio,
        c.nombre AS centro,
        p.nombre || ' ' || p.apellido AS medico,
        p.nro_matricula,
        COUNT(DISTINCT hc.paciente_dni) AS cantidad_pacientes
    FROM historiaclinica hc
    JOIN proveedor p
        ON p.nro_matricula = hc.medico_matricula
    JOIN servicio s
        ON s.id_servicio = hc.id_servicio
    JOIN centro c
        ON c.id_centro = s.id_centro
    JOIN barrio b
        ON c.id_barrio = b.id_barrio
    WHERE p.tipo_profesional = 'Medico' --Filtramos solo los médicos
    GROUP BY
        c.id_centro,
        b.nombre,
        c.nombre,
        p.nombre,
        p.apellido,
        p.nro_matricula
),
ranking_medicos AS (
    SELECT 
        *,
        RANK() OVER (
            PARTITION BY id_centro
            ORDER BY cantidad_pacientes DESC
        ) AS posicion
    FROM paciente_por_medico
)
SELECT 
    barrio,
    centro,
    medico,
    cantidad_pacientes
FROM ranking_medicos
WHERE posicion = 1
ORDER BY barrio, centro, medico;

-- Consulta D: Centro de salud con mayor cantidad de servicios en cada barrio
WITH servicios_por_centro AS (
    SELECT 
        b.id_barrio,
        b.nombre AS barrio,
        c.nombre AS centro,
        c.id_centro,
        COUNT(s.id_servicio) AS cantidad_servicios
    FROM centro c
    JOIN barrio b
        ON c.id_barrio = b.id_barrio
    LEFT JOIN servicio s
        ON c.id_centro = s.id_centro
    GROUP BY 
        b.id_barrio,
        b.nombre, 
        c.nombre, 
        c.id_centro
),
maximos_por_barrio AS (
    SELECT
        id_barrio,
        MAX(cantidad_servicios) AS max_servicios
    FROM servicios_por_centro
    GROUP BY id_barrio
)
SELECT
    sc.barrio,
    sc.centro,
    sc.cantidad_servicios
FROM servicios_por_centro sc
JOIN maximos_por_barrio mb
    ON mb.id_barrio = sc.id_barrio
    AND mb.max_servicios = sc.cantidad_servicios
ORDER BY
    sc.barrio,
    sc.centro;

-- Consulta E: Diez pacientes con mayor cantidad de ingresos a centros de salud durante el último mes
SELECT
    p.dni,
    p.nombre,
    p.apellido,
    COUNT(i.id_internacion) AS cantidad_ingresos
FROM paciente p
JOIN historiaclinica hc
    ON hc.paciente_dni = p.dni
JOIN internacion i
    ON i.id_historia_clinica = hc.id_historia_clinica
WHERE i.fecha_ingreso >= CURRENT_DATE - INTERVAL '1 month'
    AND i.fecha_ingreso <= CURRENT_DATE
GROUP BY
    p.dni,
    p.nombre,
    p.apellido
ORDER BY
    cantidad_ingresos DESC,
    p.apellido,
    p.nombre
LIMIT 10;

-- Consulta F: Cantidad de pacientes actualmente internados con menos de cinco atenciones en los ultimos seis meses
WITH pacientes_internados AS (
    -- Pacientes con una internacion activa (sin fecha de egreso)
    SELECT DISTINCT
        hc.paciente_dni AS dni
    FROM internacion i
    JOIN historiaclinica hc
        ON hc.id_historia_clinica = i.id_historia_clinica
    WHERE i.fecha_egreso IS NULL
),
atenciones_por_paciente AS (
    -- Todas las historias clinicas de esos pacientes en los ultimos seis meses
    SELECT
        pin.dni,
        COUNT(hc.id_historia_clinica) AS cantidad_atenciones
    FROM pacientes_internados pin
    LEFT JOIN historiaclinica hc
        ON hc.paciente_dni = pin.dni
        AND hc.dia_visita >= CURRENT_DATE - INTERVAL '6 months'
        AND hc.dia_visita <= CURRENT_DATE
    GROUP BY pin.dni
)
SELECT COUNT(*) AS total_pacientes
FROM atenciones_por_paciente
WHERE cantidad_atenciones < 5;