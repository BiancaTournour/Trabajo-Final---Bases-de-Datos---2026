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
- [x] Entrega 3: definición de consultas, vistas, restricciones, triggers, SP/funciones, usuarios y permisos, plan de poblado y plan de testing.

---

# Guía de uso e implementación

## Requisitos previos

- Tener instalado **PostgreSQL**.
- Contar con una herramienta para ejecutar scripts SQL, por ejemplo **pgAdmin 4** o `psql`.
- Disponer de un usuario con permisos suficientes para crear tablas, tipos, funciones, triggers, roles y usuarios (por ejemplo, el usuario administrador de PostgreSQL).

## 1. Crear la base de datos

Antes de ejecutar los archivos del proyecto, crear una base de datos llamada:

```sql
CREATE DATABASE Centro-de-Salud;
```

Luego, conectarse a `Centro-de-Salud`. **Todos los archivos SQL del proyecto deben ejecutarse sobre esa misma base de datos**, salvo que se indique lo contrario.

En pgAdmin, seleccionar la base de datos `Centro-de-Salud` y abrir una ventana de Query Tool para ejecutar los scripts.

## 2. Orden de ejecución de los archivos

Los archivos SQL ubicados en `Implementación/` deben ejecutarse en el siguiente orden. Es importante respetarlo porque algunos componentes dependen de tablas, funciones o vistas creadas previamente.

| Orden | Archivo | Descripción |
|:--:|---|---|
| 1 | `00_tablas.sql` | Crea los tipos enumerados, las tablas, las claves primarias y foráneas, y las restricciones `CHECK`. |
| 2 | `01_triggers.sql` | Crea las funciones disparadoras y los triggers que validan las reglas de integridad del sistema. |
| 3 | `02_vistas.sql` | Crea las vistas utilizadas para consultar información de pacientes internados y la oferta de servicios de los centros. |
| 4 | `03_funciones_procedimientos.sql` | Crea la función `FN_Centros_Abiertos_Por_Servicio` y el procedimiento `SP_Registrar_Alta_Paciente`. |
| 5 | `04_poblado.sql` | Inserta los datos de prueba en las tablas. Debe ejecutarse después de crear la estructura y los componentes que validan los datos. |
| 6 | `05_roles_permisos.sql` | Crea los roles y usuarios del sistema y asigna los permisos correspondientes. Requiere que existan previamente las tablas, vistas, funciones y procedimientos referenciados. |
| 7 | `06_consultas.sql` | Contiene las seis consultas principales del proyecto. Se ejecuta para consultar y verificar los resultados sobre la base de datos poblada. |

**Importante:** los archivos de creación de estructura (`00` a `05`) están pensados para una instalación inicial. No deben ejecutarse nuevamente sobre una base de datos que ya contenga esos objetos, porque varias instrucciones (`CREATE TABLE`, `CREATE TYPE`, `CREATE ROLE`, `CREATE USER`, entre otras) pueden producir errores si los objetos ya existen.

Si se necesita comenzar desde cero, crear una nueva base de datos vacía o eliminar y recrear la base de datos existente. Esta última operación elimina todos sus datos y objetos.

## 3. Usuarios, roles y contraseñas

El archivo `05_roles_permisos.sql` crea los siguientes usuarios y les asigna sus roles:

| Usuario | Rol asignado | Contraseña de prueba |
|---|---|---|
| `usr_admin_db` | `rol_admin` | `admin123` |
| `usr_medico` | `rol_medico` | `medico123` |
| `usr_recepcion` | `rol_administrativo` | `recepcion123` |
| `usr_auditoria` | `rol_auditor` | `auditoria123` |

**Advertencia de seguridad:** las contraseñas incluidas en el script son valores ficticios y se utilizan exclusivamente con fines académicos y de prueba. No deben utilizarse en un entorno real ni en sistemas productivos. Para un despliegue real, deben reemplazarse por contraseñas seguras y únicas, y evitar almacenar credenciales directamente en archivos SQL versionados.

El archivo de permisos debe ejecutarse con un usuario que tenga autorización para crear roles y usuarios y conceder privilegios. Además, el script otorga permisos sobre la base de datos `centros_de_salud`, por lo que ese nombre debe coincidir con el de la base creada en el paso 1.

## 4. Consultas principales

Una vez ejecutados los scripts anteriores, se puede ejecutar `06_consultas.sql` para revisar las consultas A a F.

Algunas consultas utilizan valores de ejemplo que pueden modificarse para probar otros escenarios. En particular:

- La consulta A filtra por un diagnóstico determinado.
- La consulta B invoca `FN_Centros_Abiertos_Por_Servicio` con el identificador de un tipo de servicio. El resultado depende del día y la hora actuales; que no devuelva filas no implica necesariamente un error.
- Las consultas restantes trabajan sobre los datos cargados por `04_poblado.sql`.

## 5. Pruebas del sistema

Los archivos de pruebas se encuentran en `Implementación/Pruebas/`.

La ejecución de las pruebas debe realizarse **después de completar la instalación y el poblado de la base de datos**. Se organizan en tres grupos:

1. **`pruebas_triggers.sql`:** pruebas de restricciones y triggers, incluyendo operaciones que deben aceptarse y operaciones inválidas que deben ser rechazadas.
2. **`pruebas_consultas.sql`:** pruebas funcionales de las consultas principales, vistas y función.
3. **`pruebas_permisos.sql`:** comprobaciones de los permisos asignados a cada usuario.

Para las pruebas de permisos, conectarse con el usuario que corresponda a cada perfil. Una comprobación de permisos realizada únicamente con el usuario administrador no permite verificar las restricciones de los demás usuarios.

Los scripts de prueba pueden contener operaciones de inserción, actualización o eliminación preparadas para generar escenarios de validación. Revisar sus instrucciones y transacciones antes de ejecutarlos. Cuando un script finalice con `ROLLBACK`, los cambios realizados durante esa prueba se revierten y no quedan almacenados.

## 6. Consideraciones importantes

- Mantener el orden de ejecución indicado para evitar errores por dependencias entre objetos.
- Ejecutar todos los scripts sobre la base `Centro-de-Salud`.
- El archivo `04_poblado.sql` contiene datos ficticios para pruebas; no representa información real de pacientes ni profesionales.
- Si se vuelve a ejecutar el poblado sobre tablas que ya contienen esos registros, pueden producirse errores por claves primarias o restricciones `UNIQUE`.
- Las consultas que dependen de fechas, horarios o de la hora actual pueden devolver resultados diferentes según el momento de ejecución.
- Los nombres de usuarios y contraseñas del script son exclusivamente de prueba.
