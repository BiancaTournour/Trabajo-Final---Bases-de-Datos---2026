# Planificación

## Proyecto: Centro de Salud

Esta entrega define preliminarmente la tercera sección del Trabajo Final del proyecto **Centro de Salud**, correspondiente a la materia **Bases de Datos 2026**. Se detallan las consultas, vistas, restricciones, triggers, procedimientos almacenados y funciones previstos, junto con la definición de roles y permisos, el plan de poblado de la base de datos y el plan de testing.

## A. Consultas, vistas, restricciones, triggers y procedimientos almacenados/funciones

### A.1. Consultas

#### Consulta A: Cantidad de pacientes con un diagnóstico determinado por ciudad

**Objetivo:** obtener la cantidad de pacientes que presentan un diagnóstico específico en cada ciudad.

**Implementación prevista:** se utilizarán `JOIN` para relacionar las tablas siguiendo el recorrido `HistoriaClinica → Paciente → Barrio → Ciudad`. Se aplicarán `COUNT` y `DISTINCT` para contar pacientes únicos. La condición `WHERE` filtrará por el diagnóstico buscado y `GROUP BY` agrupará los resultados por ciudad.

#### Consulta B: Centros de salud que ofrecen un servicio determinado y están abiertos al momento de la consulta

**Objetivo:** identificar los centros que ofrecen un tipo de servicio específico y se encuentran abiertos en el día y horario de ejecución de la consulta.

**Implementación prevista:** una función recibirá como parámetro el tipo de servicio buscado. Se relacionarán `Tipo_Servicio → Servicio → Centro → HorarioServicio` mediante `JOIN`, utilizando `LEFT JOIN` para contemplar que no todos los servicios tienen un horario propio. Con `WHERE` se filtrarán el tipo de servicio, el día actual y las franjas que incluyan la hora actual. La hora de apertura será inclusiva y la de cierre exclusiva. El día y la hora se interpretarán según el horario de Argentina. Se agrupará por centro para evitar duplicados cuando haya más de una franja horaria en el día y se ordenará por nombre del centro.

#### Consulta C: Médico con mayor cantidad de pacientes atendidos en cada centro, organizado por barrio

**Objetivo:** determinar qué médico atendió a más pacientes en cada centro de salud, organizando los resultados por barrio.

**Implementación prevista:** se utilizarán `COUNT` y `DISTINCT` para evitar contar pacientes repetidos. Los `JOIN` conectarán a cada médico con el centro en el que trabaja y con los pacientes atendidos, siguiendo el recorrido `Proveedor → HistoriaClinica → Servicio → Centro → Barrio`; los pacientes se relacionarán directamente desde su historia clínica. Se filtrarán los proveedores para considerar únicamente médicos, se agrupará por centro, barrio y médico con `GROUP BY` y se ordenará la cantidad de pacientes atendidos de mayor a menor con `ORDER BY DESC`.

#### Consulta D: Centro de salud con mayor cantidad de servicios en cada barrio

**Objetivo:** identificar el centro o los centros que ofrecen la mayor cantidad de servicios dentro de cada barrio.

**Implementación prevista:** se utilizarán `JOIN` para relacionar `Servicio → Centro → Barrio`, mediante `LEFT JOIN` para no excluir centros sin servicios. Se prevé utilizar vistas auxiliares, `COUNT` y `GROUP BY` por centro para contar sus servicios, y `MAX` agrupado por barrio para obtener el máximo correspondiente. La condición `WHERE` conservará los centros cuya cantidad de servicios coincida con el máximo del barrio. Si hay empate, se mostrarán todos los centros empatados. Los resultados se ordenarán por barrio y centro.

#### Consulta E: Diez pacientes con mayor cantidad de ingresos a centros de salud durante el último mes

**Objetivo:** listar los diez pacientes con más ingresos a centros de salud en el último mes.

**Implementación prevista:** se relacionarán `Paciente → Internacion → Centro` mediante `JOIN`. Con `WHERE` se seleccionarán las internaciones cuyo ingreso haya ocurrido durante el último mes, tomando como referencia `CURRENT_DATE`. Se utilizará `COUNT(Internacion.id)` para contar las internaciones por paciente y `GROUP BY` para agrupar los resultados por paciente. Finalmente, se ordenará de forma descendente por cantidad de ingresos y se limitará el resultado a diez registros mediante `LIMIT 10` o `TOP 10`, según el sistema gestor utilizado.

#### Consulta F: Cantidad de pacientes con menos de cinco atenciones en los últimos seis meses que están actualmente internados

**Objetivo:** contar los pacientes que se encuentran internados en algún centro y registran menos de cinco atenciones durante los últimos seis meses.

**Implementación prevista:** se combinarán las tablas `Paciente`, `Internacion` e `HistoriaClinica`. Se identificarán los pacientes actualmente internados mediante `WHERE fecha_egreso IS NULL`. Luego se relacionará `HistoriaClinica` para considerar las atenciones registradas durante los últimos seis meses. Se agrupará por paciente con `GROUP BY` y se aplicará `HAVING COUNT(HistoriaClinica.id) < 5`. Sobre el conjunto resultante se realizará un conteo global para obtener la cantidad total de pacientes que cumplen las condiciones.

### A.2. Vistas

#### `Vista_Pacientes_Internados_Actuales`

**Objetivo:** consolidar la información de los pacientes que se encuentran internados actualmente.

**Implementación prevista:** recorrerá las tablas `Paciente → Internacion → Centro → Barrio` y filtrará los registros mediante `WHERE fecha_egreso IS NULL`. La vista mostrará el nombre del paciente, documento, fecha de ingreso, nombre del centro de salud y barrio. Permitirá consultar la ocupación activa sin tener que repetir las uniones en cada informe.

#### `Vista_Oferta_Servicios_Centro`

**Objetivo:** listar los servicios disponibles en cada centro de salud.

**Implementación prevista:** relacionará `Centro → Servicio → Tipo_Servicio` mediante `JOIN`. Mostrará el nombre del centro, barrio, ciudad y los tipos de servicios ofrecidos, agrupando la información para facilitar la lectura de la cobertura asistencial de cada establecimiento.

### A.3. Restricciones (constraints)

#### `CHK_Internacion_Fechas`

Se implementará como una restricción `CHECK` sobre la tabla `Internacion`. Validará que la fecha y hora de egreso sea posterior o igual a la fecha y hora de ingreso (`fecha_egreso >= fecha_ingreso`). Su objetivo es evitar inconsistencias temporales en los registros de internación.

#### `CHK_HorarioServicio_Valido`

Se implementará como una restricción `CHECK` sobre la tabla `HorarioServicio`. Verificará que la hora de apertura sea anterior a la hora de cierre (`hora_apertura < hora_cierre`), garantizando la validez de las franjas horarias definidas.

### A.4. Triggers (disparadores)

#### `TRG_Validar_Solapamiento_Horarios`

Será un trigger `BEFORE INSERT OR UPDATE` sobre `HorarioServicio`. Antes de insertar o modificar una franja horaria de un servicio en un centro determinado, verificará si existe otra franja que se solape para el mismo día y servicio. Si detecta una superposición, cancelará la operación mediante una excepción personalizada.

#### `TRG_Auditoria_Alta_Internacion`

Será un trigger `AFTER UPDATE` sobre `Internacion`. Se ejecutará cuando `fecha_egreso` cambie de `NULL` a un valor concreto. Registrará en la tabla de auditoría `Auditoria_Internaciones` el usuario que procesó el alta, la fecha y hora del movimiento y el identificador de la internación finalizada.

### A.5. Procedimientos almacenados y funciones

#### `FN_Centros_Abiertos_Por_Servicio(p_tipo_servicio VARCHAR)`

Esta función encapsulará la lógica de la consulta B. Recibirá como argumento el tipo de servicio buscado y retornará una tabla con los centros de salud abiertos al momento de la ejecución. Evaluará el día de la semana y la hora actual, según el horario de Argentina, y relacionará `Tipo_Servicio → Servicio → Centro → HorarioServicio` mediante `LEFT JOIN`. Los resultados se agruparán por centro y se ordenarán por nombre.

#### `SP_Registrar_Alta_Paciente(p_id_internacion INT, p_fecha_egreso TIMESTAMP)`

Este procedimiento almacenado gestionará el alta médica de un paciente. Recibirá el identificador de la internación y la fecha de egreso. Ejecutará una transacción que primero verificará que la internación esté activa (`fecha_egreso IS NULL`), actualizará la fecha de egreso con la fecha proporcionada y confirmará la operación mediante `COMMIT`. En caso de error, realizará `ROLLBACK`.

## B. Definición de roles, usuarios y permisos

### B.1. Administrador de base de datos

- **Rol:** `rol_admin`
- **Usuario asociado:** `usr_admin_db`
- **Responsabilidad:** mantenimiento de la base de datos, gestión de esquemas, ejecución de migraciones y administración de accesos globales.
- **Permisos previstos:**
  - `GRANT ALL PRIVILEGES ON DATABASE centros_de_salud TO rol_admin;`
  - Administración total (`CREATE`, `ALTER`, `DROP`, `GRANT`) sobre tablas, vistas, triggers, funciones y procedimientos almacenados.

### B.2. Personal médico

- **Rol:** `rol_medico`
- **Usuario asociado:** `usr_medico`
- **Responsabilidad:** consultar historias clínicas y registrar atenciones, diagnósticos y altas médicas de internación.
- **Permisos previstos:**
  - `SELECT`, `INSERT` y `UPDATE` sobre `HistoriaClinica` y `Paciente`.
  - `SELECT` sobre `Centro`, `Servicio`, `Tipo_Servicio` y `HorarioServicio`.
  - Ejecución de `FN_Centros_Abiertos_Por_Servicio`.
  - Ejecución de `SP_Registrar_Alta_Paciente`.
- **Restricciones:** no tendrá permisos de eliminación (`DELETE`) sobre registros médicos ni permisos para modificar la estructura de las tablas.

### B.3. Personal administrativo / recepción

- **Rol:** `rol_administrativo`
- **Usuario asociado:** `usr_recepcion`
- **Responsabilidad:** registrar admisiones de pacientes, actualizar datos personales y gestionar ingresos y egresos de internaciones.
- **Permisos previstos:**
  - `SELECT`, `INSERT` y `UPDATE` sobre `Paciente` e `Internacion`.
  - `SELECT` sobre `Centro`, `Barrio`, `Ciudad`, `Servicio` y `HorarioServicio`.
  - `SELECT` sobre `Vista_Pacientes_Internados_Actuales` y `Vista_Oferta_Servicios_Centro`.
- **Restricciones:** no tendrá acceso de lectura ni escritura a `HistoriaClinica`, para resguardar la confidencialidad de los diagnósticos médicos.

### B.4. Auditor / analista estadístico

- **Rol:** `rol_auditor`
- **Usuario asociado:** `usr_auditoria`
- **Responsabilidad:** consultar métricas de salud pública, ocupación de centros y datos de control de calidad operacional.
- **Permisos previstos:**
  - `SELECT` sobre `Vista_Pacientes_Internados_Actuales` y `Vista_Oferta_Servicios_Centro`.
  - `SELECT` sobre `Auditoria_Internaciones`.
- **Restricciones:** tendrá acceso exclusivo de lectura, sin privilegios de `INSERT`, `UPDATE` o `DELETE`.

## C. Plan de poblado de la base de datos

Se ingresará una cantidad de información suficiente para probar todas las consultas, vistas, triggers, restricciones y roles de usuario. Para mantener la integridad referencial y evitar violaciones de claves foráneas (`FOREIGN KEY`), la carga se organizará en cuatro fases, de acuerdo con las dependencias entre tablas.

### C.1. Fases de inserción

#### Nivel 1 — Tablas catálogo y geográficas

Tablas sin dependencias previas:

- `Provincia`, `Departamento` y `Barrio`: estructura de ubicación geográfica.
- `Tipo_Servicio` y `Especialidad`: categorías de atención médica y profesional.

#### Nivel 2 — Entidades principales

- Centros médicos, vinculados con su correspondiente barrio.
- Pacientes, registrados con sus datos personales y vinculados a un barrio.
- Proveedores, incluyendo médicos y enfermeros.

#### Nivel 3 — Tablas de configuración y relación

- `Servicio`: asociación de cada centro con los tipos de servicio que ofrece.
- `HorarioServicio`: definición de días, horas de apertura y cierre de los servicios de cada centro.
- `Medico_Especialidad` y `Medico_Centro`: asignación de profesionales a sus especialidades y centros de trabajo.

#### Nivel 4 — Tablas transaccionales e históricas

- `HistoriaClinica`: registro de atenciones, diagnósticos y profesionales intervinientes para cada paciente.
- `Internacion`: registro de ingresos y egresos hospitalarios.

### C.2. Cantidad mínima estimada de datos

- **Pacientes:** al menos 30.
- **Centros médicos:** al menos 3.
- **Proveedores (médicos y enfermeros):** al menos 30.
- **Servicios:** al menos 5.
- **Ubicación (barrio, provincia y departamento):** al menos 5 registros por cada nivel relacional.

La cantidad y variedad de los datos permitirá comprobar agregaciones (`COUNT`, `DISTINCT`), filtros por fechas y horarios, internaciones activas, disparadores (`triggers`) y restricciones asociadas a los roles. Para que las pruebas cubran los distintos escenarios planteados, los datos deberán incluir casos que satisfagan y que no satisfagan las condiciones de las consultas y validaciones.

## D. Plan de testing

Una vez poblada la base de datos, se ejecutará una batería de pruebas dividida en tres etapas secuenciales.

### D.1. Pruebas de validación de datos: triggers y restricciones

Se realizarán inserciones y actualizaciones con datos no válidos para comprobar que el sistema mantenga la integridad de la información y cancele correctamente las operaciones que no cumplan las reglas definidas.

#### Pruebas de restricciones (`CHECK`)

- Intentar registrar una internación con fecha de egreso anterior a la fecha de ingreso (`fecha_egreso < fecha_ingreso`) y verificar el rechazo por parte de `CHK_Internacion_Fechas`.
- Intentar registrar un horario de atención cuya hora de apertura sea posterior o igual a la hora de cierre (`hora_apertura >= hora_cierre`) y verificar el rechazo por parte de `CHK_HorarioServicio_Valido`.

#### Pruebas de triggers

- Intentar insertar una franja horaria que se solape con otra existente para el mismo centro y servicio. Se verificará que `TRG_Validar_Solapamiento_Horarios` cancele la operación y emita un mensaje de error personalizado.
- Modificar `fecha_egreso` de una internación activa y comprobar que `TRG_Auditoria_Alta_Internacion` registre automáticamente el movimiento en `Auditoria_Internaciones`.

### D.2. Pruebas funcionales de consultas principales y vistas

Se ejecutarán las seis consultas principales y las vistas asociadas sobre los datos cargados. Los resultados obtenidos se compararán con los resultados esperados.

- **Consulta A:** verificar el conteo exacto de pacientes únicos (`COUNT` y `DISTINCT`) agrupados por diagnóstico y ciudad.
- **Consulta B y función `FN_Centros_Abiertos_Por_Servicio`:** evaluar el filtrado dinámico de los servicios abiertos según el día y la hora exacta de ejecución en Argentina.
- **Consulta C:** comprobar la identificación del médico con mayor cantidad de pacientes atendidos en cada centro, organizada por barrio.
- **Consulta D:** verificar qué centro o centros tienen la mayor cantidad de servicios en cada barrio y comprobar la inclusión correcta de empates mediante vistas auxiliares.
- **Consulta E:** validar el listado de los diez pacientes con más ingresos durante el último mes, mediante `LIMIT 10` o `TOP 10`.
- **Consulta F:** verificar el conteo de pacientes actualmente internados (`fecha_egreso IS NULL`) que registren menos de cinco atenciones durante los últimos seis meses.

### D.3. Pruebas de roles, permisos y control de acceso (DCL)

Se probarán distintos caminos de interacción según el perfil de usuario para comprobar que la matriz de seguridad permita o limite el acceso según lo previsto.

- **Administrador (`usr_admin_db`):** confirmar el acceso irrestricto a operaciones DDL, DML y DCL.
- **Personal médico (`usr_medico`):** confirmar los permisos de lectura y escritura sobre `HistoriaClinica`, la ejecución de `SP_Registrar_Alta_Paciente` y el bloqueo de intentos de borrado (`DELETE`) o modificación de la estructura.
- **Personal administrativo (`usr_recepcion`):** confirmar la posibilidad de registrar y modificar pacientes e internaciones, y comprobar el bloqueo explícito del acceso a `HistoriaClinica`.
- **Auditor (`usr_auditoria`):** confirmar el acceso exclusivo de lectura (`SELECT`) sobre las vistas y tablas de auditoría, y verificar el rechazo de intentos de inserción o modificación.
