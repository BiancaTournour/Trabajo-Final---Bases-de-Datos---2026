# Sistema de Gestión de Centros de Salud

**Materia:** Bases de Datos 2026  
**Grupo:** 13  

**Integrantes:**
- Poggio Joaquin
- Schaab Valentina
- Tournour Bianca

## Descripción del proyecto

El proyecto consiste en el diseño y desarrollo de una base de datos para un sistema de administración de centros de salud.

El sistema contempla la información de los centros de salud, su ubicación geográfica, los horarios de atención, los servicios que ofrecen, los profesionales de la salud, sus especializaciones, los pacientes y sus historias clínicas. También contempla el registro de internaciones, incluyendo las fechas de ingreso y egreso.

La base de datos busca organizar la información de manera consistente y permitir la realización de consultas sobre la atención de pacientes y el funcionamiento de los centros de salud.

## Entregas del proyecto

### Entrega 1 — Modelo de datos y normalización

Incluye:
- Modelo lógico de la base de datos, con claves primarias, dominios, restricciones de los atributos y cardinalidades de las relaciones.
- Modelo relacional normalizado hasta la Tercera Forma Normal (3FN).

### Entrega 2 — Diccionario de datos y reglas de la base de datos

Incluirá:
- Diccionario de datos.
- Triggers.
- Descripción y propiedades correspondientes.

### Entrega 3 — Entrega final

Incluirá los siguientes puntos:

**A. Definición de consultas, vistas, restricciones, triggers y procedimientos almacenados (SP) o funciones a realizar.**  
Se incorporará una descripción de cada elemento.

**B. Definición de usuarios y permisos.**

**C. Plan de poblado de la base de datos.**

**D. Plan de testing.**

## Consultas previstas

A partir de los requerimientos iniciales, se consideran las siguientes consultas:

1. Cantidad de pacientes con un diagnóstico determinado en cada ciudad.
2. Centros de salud que cuenten con un servicio determinado y estén abiertos en el día y horario de consulta.
3. Médico con mayor cantidad de pacientes atendidos en cada centro, organizados por barrio.
4. Centro de salud con mayor cantidad de servicios de cada barrio.
5. Los 10 pacientes con mayor cantidad de ingresos a centros de salud durante el último mes.
6. Cantidad de pacientes con menos de 5 atenciones en los últimos 6 meses que se encuentren actualmente internados en algún centro.

## Organización del repositorio

La estructura del repositorio se irá completando a medida que se incorporen los materiales y componentes de cada entrega.

- `README.md`: descripción general y documentación del proyecto.
- **Entrega 1:** modelo lógico, modelo relacional y normalización.
- **Entrega 2:** diccionario de datos, triggers, descripción y propiedades.
- **Entrega 3:** consultas, vistas, restricciones, triggers, SP/funciones, usuarios y permisos, plan de poblado y plan de testing.

## Estado del proyecto

- [x] Entrega 1: modelo relacional y normalización.
- [x] Entrega 2: diccionario de datos, triggers, descripción y propiedades.
- [ ] Entrega 3: definición de consultas, vistas, restricciones, triggers, SP/funciones, usuarios y permisos, plan de poblado y plan de testing.
