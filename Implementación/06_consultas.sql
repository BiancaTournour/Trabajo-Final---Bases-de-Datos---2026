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
FROM fn_centros_abiertos_por_servicio(11); --Para el servicio con id 11, reemplazar con el id del servicio deseado, si sale sin data es porque no hay centro abierto en ese momento para ese servicio


-- Consulta C: Médico con mayor cantidad de pacientes por centro
WITH paciente_por_medico AS (
    SELECT 
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
            PARTITION BY centro
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
ORDER BY barrio, centro;

-- Consulta D: Centro de salud con mayor cantidad de servicios en cada barrio
WITH servicios_por_centro AS (
    SELECT 
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
    b.nombre, 
    c.nombre, 
    c.id_centro
),
maximos_por_barrio AS (
    SELECT
        barrio,
        MAX(cantidad_servicios) AS max_servicios
    FROM servicios_por_centro
    GROUP BY barrio
)
SELECT
    sc.barrio,
    sc.centro,
    sc.cantidad_servicios
FROM servicios_por_centro sc
JOIN maximos_por_barrio mb
    ON mb.barrio = sc.barrio
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
JOIN servicio s
    ON s.id_servicio = hc.id_servicio
JOIN centro c
    ON c.id_centro = s.id_centro
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

-- Consulta F: Pacientes internados con menos de cinco atenciones
WITH pacientes_internados AS (
    SELECT
        p.dni,
        p.nombre,
        p.apellido,
        COUNT(hc.id_historia_clinica) AS cantidad_atenciones
    FROM paciente p
    JOIN historiaclinica hc
        ON hc.paciente_dni = p.dni
    JOIN internacion i
        ON i.id_historia_clinica = hc.id_historia_clinica
    WHERE i.fecha_egreso IS NULL 
        AND hc.dia_visita >= CURRENT_DATE - INTERVAL '6 months'
        AND hc.dia_visita <= CURRENT_DATE
    GROUP BY
        p.dni,
        p.nombre,
        p.apellido
    HAVING COUNT(hc.id_historia_clinica) < 5
)
SELECT COUNT (*) AS total_pacientes
FROM pacientes_internados;
