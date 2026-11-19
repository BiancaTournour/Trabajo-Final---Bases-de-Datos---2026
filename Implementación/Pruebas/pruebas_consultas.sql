-- ============================================================
-- PRUEBAS FUNCIONALES: CONSULTAS PRINCIPALES
-- Proyecto: Centro de Salud - Bases de Datos 2026
--
-- Requisitos:
--   1. Ejecutar previamente 00_tablas.sql
--   2. Ejecutar 04_poblado.sql
--   3. Ejecutar 03_funciones_procedimientos.sql (para la Consulta B)
--
-- Estas pruebas ejecutan las seis consultas principales sobre los
-- datos cargados. Comparar los resultados obtenidos con los
-- comportamientos esperados indicados en cada apartado.
--
-- IMPORTANTE:
--   - Ejecutar cada bloque completo, especialmente los que usan WITH.
--   - La Consulta B depende del día y la hora exactos de ejecución.
--   - No se insertan, modifican ni eliminan datos.
-- ============================================================


-- ------------------------------------------------------------
-- CONSULTA A: Pacientes con un diagnóstico determinado por ciudad
-- Esperado: cantidad de pacientes únicos por ciudad para el
-- diagnóstico indicado. COUNT(DISTINCT) evita duplicados.
-- ------------------------------------------------------------

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
WHERE hc.diagnostico = 'Migraña'
GROUP BY ci.id_ciudad, ci.nombre
ORDER BY ci.nombre;

-- ------------------------------------------------------------
-- CONSULTA B: Centros abiertos para un tipo de servicio
-- Esperado: centros que ofrecen el tipo de servicio indicado
-- y cuyo horario incluye el día y la hora de ejecución.
-- La función utiliza la hora de Argentina.
-- El ID 1 corresponde al servicio en los datos cargados.
-- ------------------------------------------------------------

SELECT *
FROM fn_centros_abiertos_por_servicio(1);

-- ------------------------------------------------------------
-- CONSULTA C: Médico con más pacientes atendidos en cada centro
-- Esperado: médico/s con mayor cantidad de pacientes únicos
-- por centro, organizados por barrio. RANK conserva empates.
-- ------------------------------------------------------------

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

-- ------------------------------------------------------------
-- CONSULTA D: Centro con mayor cantidad de servicios por barrio
-- Esperado: centro/s con la mayor cantidad de servicios en cada
-- barrio. LEFT JOIN incluye centros que no tengan servicios;
-- la comparación con MAX conserva los empates.
-- ------------------------------------------------------------

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

-- ------------------------------------------------------------
-- CONSULTA E: Diez pacientes con más ingresos durante el último mes
-- Esperado: hasta diez pacientes, ordenados por cantidad de
-- internaciones en forma descendente.
-- ------------------------------------------------------------

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

-- ------------------------------------------------------------
-- CONSULTA F: Pacientes actualmente internados con menos de cinco
-- atenciones en los últimos seis meses.
-- Esperado: un único valor con la cantidad total de pacientes.
-- Se cuentan todas las historias clínicas recientes de cada
-- paciente internado actualmente, no solo la historia asociada
-- a su internación.
-- ------------------------------------------------------------

WITH pacientes_internados AS (
    SELECT DISTINCT
        hc.paciente_dni
    FROM internacion i
    JOIN historiaclinica hc
        ON hc.id_historia_clinica = i.id_historia_clinica
    WHERE i.fecha_egreso IS NULL
),
atenciones_por_paciente AS (
    SELECT
        p.dni,
        p.nombre,
        p.apellido,
        COUNT(hc.id_historia_clinica) AS cantidad_atenciones
    FROM pacientes_internados pi
    JOIN paciente p
        ON p.dni = pi.paciente_dni
    LEFT JOIN historiaclinica hc
        ON hc.paciente_dni = p.dni
        AND hc.dia_visita >= CURRENT_DATE - INTERVAL '6 months'
        AND hc.dia_visita <= CURRENT_DATE
    GROUP BY
        p.dni,
        p.nombre,
        p.apellido
    HAVING COUNT(hc.id_historia_clinica) < 5
)
SELECT COUNT(*) AS total_pacientes
FROM atenciones_por_paciente;