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

**Implementación prevista:** una función recibirá como parámetro el tipo de servicio buscado. Se relacionarán `Tipo_Servicio → Servicio → Centro → HorarioServicio` mediante `JOIN`, mediante `JOIN`, ya que cada horario de servicio se registra en `HorarioServicio`. Con `WHERE` se filtrarán el tipo de servicio, el día actual y las franjas que incluyan la hora actual. La hora de apertura será inclusiva y la de cierre exclusiva. El día y la hora se interpretarán según el horario de Argentina. Se agrupará por centro para evitar duplicados cuando haya más de una franja horaria en el día y se ordenará por nombre del centro.

#### Consulta C: Médico con mayor cantidad de pacientes atendidos en cada centro, organizado por barrio

**Objetivo:** determinar qué médico atendió a más pacientes en cada centro de salud, organizando los resultados por barrio.

**Implementación prevista:** se utilizarán `COUNT` y `DISTINCT` para evitar contar pacientes repetidos. Los `JOIN` conectarán a cada médico con el centro en el que trabaja y con los pacientes atendidos, mediante `HistoriaClinica.medico_matricula`, `HistoriaClinica.id_servicio`, `Servicio.id_centro` y `Centro.id_barrio`. Se filtrarán los proveedores cuyo `tipo_profesional` sea médico y se agrupará por centro, barrio y médico. Se utilizará `COUNT(DISTINCT HistoriaClinica.paciente_dni)` para contar pacientes únicos. Para obtener el máximo de cada centro se utilizará una consulta auxiliar o una función de ventana, conservando los empates.

#### Consulta D: Centro de salud con mayor cantidad de servicios en cada barrio

**Objetivo:** identificar el centro o los centros que ofrecen la mayor cantidad de servicios dentro de cada barrio.

**Implementación prevista:** se utilizarán `JOIN` para relacionar `Servicio → Centro → Barrio`, mediante `LEFT JOIN` para no excluir centros sin servicios. Se prevé utilizar vistas auxiliares, `COUNT` y `GROUP BY` por centro para contar sus servicios, y `MAX` agrupado por barrio para obtener el máximo correspondiente. La condición `WHERE` conservará los centros cuya cantidad de servicios coincida con el máximo del barrio. Si hay empate, se mostrarán todos los centros empatados. Los resultados se ordenarán por barrio y centro.

#### Consulta E: Diez pacientes con mayor cantidad de ingresos a centros de salud durante el último mes

**Objetivo:** listar los diez pacientes con más ingresos a centros de salud en el último mes.

**Implementación prevista:** se relacionarán `Paciente → HistoriaClinica → Internacion → Servicio → Centro` mediante `JOIN`. Con `WHERE` se seleccionarán las internaciones cuyo ingreso haya ocurrido durante el último mes, tomando como referencia `CURRENT_DATE`. Se utilizará `COUNT(Internacion.id_internacion)` para contar las internaciones por paciente y `GROUP BY` para agrupar los resultados por paciente. Finalmente, se ordenará de forma descendente por cantidad de ingresos y se limitará el resultado a diez registros mediante `LIMIT 10`.

#### Consulta F: Cantidad de pacientes con menos de cinco atenciones en los últimos seis meses que están actualmente internados

**Objetivo:** contar los pacientes que se encuentran internados en algún centro y registran menos de cinco atenciones durante los últimos seis meses.

**Implementación prevista:** se combinarán las tablas `Paciente`, `Internacion` e `HistoriaClinica`. Se identificarán los pacientes actualmente internados mediante `WHERE fecha_egreso IS NULL`. Luego se relacionará `HistoriaClinica` para considerar las atenciones registradas durante los últimos seis meses. Se agrupará por paciente con `GROUP BY` y se aplicará `HAVING COUNT(HistoriaClinica.id) < 5`. Sobre el conjunto resultante se realizará un conteo global para obtener la cantidad total de pacientes que cumplen las condiciones.

### A.2. Vistas

#### `Vista_Pacientes_Internados_Actuales`

**Objetivo:** consolidar la información de los pacientes que se encuentran internados actualmente.

**Implementación prevista:** recorrerá las tablas `Paciente → HistoriaClinica → Internacion → Servicio → Centro → Barrio` y filtrará los registros mediante `WHERE fecha_egreso IS NULL`. La vista mostrará el nombre del paciente, documento, fecha de ingreso, nombre del centro de salud y barrio. Permitirá consultar la ocupación activa sin tener que repetir las uniones en cada informe.

#### `Vista_Oferta_Servicios_Centro`

**Objetivo:** listar los servicios disponibles en cada centro de salud.

**Implementación prevista:** relacionará `Centro → Servicio → Tipo_Servicio` mediante `JOIN`, y `Barrio → Ciudad` para obtener la ubicación. Mostrará el nombre del centro, barrio, ciudad y los tipos de servicios ofrecidos.

### A.3. Restricciones (constraints)

#### `CHECK_Internacion_Fechas`

Se implementará como una restricción `CHECK` sobre la tabla `Internacion`. Validará que la fecha de egreso sea posterior o igual a la fecha de ingreso (`fecha_egreso >= fecha_ingreso`), permitiendo `NULL` mientras la internación continúe activa. Su objetivo es evitar inconsistencias temporales en los registros de internación.

#### `CHECK_HorarioServicio_Valido`

Se implementará como una restricción `CHECK` sobre la tabla `HorarioServicio`. Verificará que `horario_apertura` sea anterior a `horario_cierre` (`horario_apertura < horario_cierre`), garantizando la validez de las franjas horarias definidas.

### A.4. Triggers (disparadores)

#### `tgr_horario_servicio_sin_superposicion`

Se ejecutará antes de insertar o actualizar registros en `HorarioServicio`. Verificará que no existan franjas horarias superpuestas para el mismo servicio y día. Si detecta una superposición, cancelará la operación.

#### `tgr_horario_centro_sin_superposicion`

Se ejecutará antes de insertar o actualizar registros en `HorarioCentro`. Verificará que no existan franjas horarias superpuestas para el mismo centro y día. Si detecta una superposición, cancelará la operación.

#### tgr_proveedor_especializacion_impedir_baja
Se ejecutará antes de eliminar registros de Proveedor_Especializacion. Impedirá quitar una especialización a un proveedor cuando esta sea requerida por un servicio en el que participa como profesional asignado o médico a cargo.

#### tgr_tipo_servicio_impedir_cambios
Se ejecutará antes de actualizar registros de Tipo_Servicio. Impedirá modificar la dotación o la especialización requerida cuando el tipo de servicio ya tenga servicios asociados.

#### tgr_servicio_medico_a_cargo_valido
Se ejecutará antes de insertar o actualizar registros de Servicio. Verificará que el médico a cargo sea un proveedor de tipo Médico y que posea la especialización requerida por el tipo de servicio correspondiente.

#### tgr_servicio_impedir_cambios
Se ejecutará antes de actualizar registros de Servicio. Impedirá modificar el centro o el tipo de servicio cuando existan horarios, asignaciones o historias clínicas asociadas que dependan de esa configuración.

#### tgr_asignacion_servicio_profesional_valido
Se ejecutará antes de insertar o actualizar registros de AsignacionServicio. Verificará que el profesional asignado tenga el rol correspondiente, posea la especialización requerida por el tipo de servicio y no sea el médico a cargo del mismo.

#### tgr_asignacion_servicio_cupo
Se ejecutará antes de insertar o actualizar registros de AsignacionServicio. Controlará que la cantidad de profesionales asignados no supere la dotación de médicos y enfermeros establecida para el tipo de servicio.

#### tgr_asignacion_servicio_impedir_baja
Se ejecutará antes de eliminar registros de AsignacionServicio. Impedirá eliminar la asignación de un médico que ya haya intervenido en atenciones registradas en HistoriaClinica para ese servicio.

#### tgr_historia_clinica_medico_valido
Se ejecutará antes de insertar o actualizar registros de HistoriaClinica. Verificará que el profesional interviniente sea de tipo Médico y que esté habilitado para atender en el servicio, ya sea como médico a cargo o como profesional asignado mediante AsignacionServicio.

#### tgr_internacion_servicio_valido
Se ejecutará antes de insertar o actualizar registros de Internacion. Verificará que la historia clínica asociada corresponda a una atención realizada en un servicio cuyo tipo sea Internación.

#### tgr_internacion_sin_superposicion
Se ejecutará antes de insertar o actualizar registros de Internacion. Impedirá que un mismo paciente tenga dos internaciones cuyos períodos se superpongan. También contemplará las internaciones que todavía no tengan fecha de egreso.

### A.5. Procedimientos almacenados y funciones

#### `FN_Centros_Abiertos_Por_Servicio(p_id_tipo_servicio INT)`

Esta función encapsulará la lógica de la consulta B. Recibirá como argumento el identificador del tipo de servicio (`p_id_tipo_servicio INT`) y retornará los centros que ofrecen ese tipo de servicio y cuyo horario registrado en `HorarioServicio` incluye el día y la hora de ejecución. Comparará `dia`, `horario_apertura` y `horario_cierre` con la fecha y hora actuales. Los resultados se agruparán por centro y se ordenarán por nombre.

#### `SP_Registrar_Alta_Paciente(p_id_internacion INT, p_fecha_egreso DATE)`

Este procedimiento almacenado gestionará el egreso de una internación. Recibirá el identificador de la internación y la fecha de egreso (`p_id_internacion INT`, `p_fecha_egreso DATE`). Verificará que la internación exista y continúe activa (`fecha_egreso IS NULL`) y actualizará `Internacion.fecha_egreso` con la fecha recibida. La operación se ejecutará dentro de una transacción.

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
- **Restricciones:** no tendrá permisos de modificación sobre `HistoriaClinica`; el acceso de lectura se limitará a las vistas autorizadas.

### B.4. Auditor / analista estadístico

- **Rol:** `rol_auditor`
- **Usuario asociado:** `usr_auditoria`
- **Responsabilidad:** consultar métricas de salud pública, ocupación de centros y datos de control de calidad operacional.
- **Permisos previstos:**
  - `SELECT` sobre `Vista_Pacientes_Internados_Actuales` y `Vista_Oferta_Servicios_Centro`.
  - `SELECT` sobre `Vista_Pacientes_Internados_Actuales` y `Vista_Oferta_Servicios_Centro`.
- **Restricciones:** tendrá acceso exclusivo de lectura, sin privilegios de `INSERT`, `UPDATE` o `DELETE`.

## C. Plan de poblado de la base de datos

Se ingresará una cantidad de información suficiente para probar todas las consultas, vistas, triggers, restricciones y roles de usuario. Para mantener la integridad referencial y evitar violaciones de claves foráneas (`FOREIGN KEY`), la carga se organizará en cuatro fases, de acuerdo con las dependencias entre tablas.

### C.1. Fases de inserción

#### Nivel 1 — Tablas catálogo y geográficas

Tablas iniciales:

- `Provincia` y `Obra_Social`: catálogos sin dependencias.
- `Especializacion`: catálogo de especializaciones.

#### Nivel 2 — Entidades principales

- `Departamento`, vinculado con `Provincia`; `Ciudad`, vinculada con `Departamento`; y `Barrio`, vinculado con `Ciudad`.
- `Centro` y `Paciente`, vinculados con `Barrio`; `Proveedor`, con los datos de médicos y enfermeros.

#### Nivel 3 — Tablas de configuración y relación

- `Tipo_Servicio`, vinculado con `Especializacion`.
- `Proveedor_Especializacion`, que relaciona profesionales y especializaciones.
- `Servicio`, que relaciona `Centro`, `Tipo_Servicio` y el médico a cargo.
- `HorarioCentro` y `HorarioServicio`, junto con `AsignacionServicio`.

#### Nivel 4 — Tablas transaccionales e históricas

- `HistoriaClinica`: registro de atenciones, diagnósticos, pacientes, servicios y profesionales intervinientes.
- `Internacion`: registro de ingresos y egresos vinculado con la historia clínica que originó la internación.

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

- Intentar registrar una internación con fecha de egreso anterior a la fecha de ingreso (`fecha_egreso < fecha_ingreso`) y verificar el rechazo por parte de `CHECK_Internacion_Fechas`.
- Intentar registrar un horario de atención cuya hora de apertura sea posterior o igual a la hora de cierre (`horario_apertura >= horario_cierre`) y verificar el rechazo por parte de `CHECK_HorarioServicio_Valido`.

#### Pruebas de triggers

- Intentar insertar una franja horaria que se solape con otra existente para el mismo centro y servicio. Se verificará que `tgr_horario_servicio_sin_superposicion` cancele la operación.
- Modificar `fecha_egreso` de una internación activa y comprobar que se actualice correctamente y que se rechacen fechas anteriores a `fecha_ingreso`.
- Insertar y actualizar franjas horarias superpuestas en HorarioCentro para un mismo centro y día. Verificar que `tgr_horario_centro_sin_superposicion` rechace las operaciones.
- Intentar eliminar una especialización de Proveedor_Especializacion que sea requerida por un servicio en el que participa el proveedor. Verificar que `tgr_proveedor_especializacion_impedir_baja` impida la eliminación.
- Intentar modificar un Tipo_Servicio que ya tenga servicios asociados. Verificar que `tgr_tipo_servicio_impedir_cambios` rechace la modificación.
- Insertar o actualizar un Servicio con un médico a cargo que no cumpla los requisitos de tipo de profesional o especialización. Verificar que `tgr_servicio_medico_a_cargo_valido` rechace la operación.
- Intentar modificar el centro o el tipo de un Servicio que tenga horarios, asignaciones o historias clínicas asociadas. Verificar que `tgr_servicio_impedir_cambios` impida la modificación.
- Insertar o actualizar una AsignacionServicio con un profesional que no cumpla los requisitos de rol o especialización, o que ya sea el médico a cargo. Verificar que `tgr_asignacion_servicio_profesional_valido` rechace la operación.
- Intentar superar la cantidad de profesionales permitida para un tipo de servicio mediante inserciones o actualizaciones en AsignacionServicio. Verificar que `tgr_asignacion_servicio_cupo` rechace la operación.
- Intentar eliminar la asignación de un médico que ya haya atendido pacientes en ese servicio. Verificar que `tgr_asignacion_servicio_impedir_baja` impida la eliminación.
- Insertar o actualizar una HistoriaClinica con un profesional que no esté habilitado para atender en el servicio. Verificar que `tgr_historia_clinica_medico_valido` rechace la operación.
- Insertar o actualizar una Internacion cuya historia clínica no corresponda a un servicio de tipo Internación. Verificar que `tgr_internacion_servicio_valido` rechace la operación.
- Intentar registrar internaciones superpuestas para un mismo paciente, incluyendo internaciones sin fecha de egreso. Verificar que `tgr_internacion_sin_superposicion` rechace la operación.

### D.2. Pruebas funcionales de consultas principales y vistas

Se ejecutarán las seis consultas principales y las vistas asociadas sobre los datos cargados. Los resultados obtenidos se compararán con los resultados esperados.

- **Consulta A:** verificar el conteo exacto de pacientes únicos (`COUNT` y `DISTINCT`) agrupados por diagnóstico y ciudad.
- **Consulta B y función `FN_Centros_Abiertos_Por_Servicio`:** evaluar el filtrado dinámico de los servicios abiertos según el día y la hora exacta de ejecución en Argentina.
- **Consulta C:** comprobar la identificación del médico con mayor cantidad de pacientes atendidos en cada centro, organizada por barrio.
- **Consulta D:** verificar qué centro o centros tienen la mayor cantidad de servicios en cada barrio y comprobar la inclusión correcta de empates.
- **Consulta E:** validar el listado de los diez pacientes con más ingresos durante el último mes, mediante `LIMIT 10`.
- **Consulta F:** verificar el conteo de pacientes actualmente internados (`fecha_egreso IS NULL`) que registren menos de cinco atenciones durante los últimos seis meses.

### D.3. Pruebas de roles, permisos y control de acceso (DCL)

Se probarán distintos caminos de interacción según el perfil de usuario para comprobar que la matriz de seguridad permita o limite el acceso según lo previsto.

- **Administrador (`usr_admin_db`):** confirmar el acceso irrestricto a operaciones DDL, DML y DCL.
- **Personal médico (`usr_medico`):** confirmar los permisos de lectura y escritura sobre `HistoriaClinica`, la ejecución de `SP_Registrar_Alta_Paciente` y el bloqueo de intentos de borrado (`DELETE`) o modificación de la estructura.
- **Personal administrativo (`usr_recepcion`):** confirmar la posibilidad de registrar y modificar pacientes e internaciones, y comprobar el bloqueo explícito del acceso a `HistoriaClinica`.
- **Auditor (`usr_auditoria`):** confirmar el acceso exclusivo de lectura (`SELECT`) sobre las vistas y tablas autorizadas, y verificar el rechazo de intentos de inserción o modificación.