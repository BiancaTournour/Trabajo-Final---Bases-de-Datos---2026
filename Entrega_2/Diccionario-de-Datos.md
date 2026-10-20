# Diccionario de Datos – BBDD TPFI

---
## Provincia

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_provincia` | Identificador de la provincia | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre de la provincia | VARCHAR | - | UNIQUE, NOT NULL | - | - | - |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`: rechaza nombres vacíos o con solo espacios.

**Triggers asociados:** ninguno.

---

## Departamento

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_departamento` | Identificador del departamento | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre del departamento | VARCHAR | - | NOT NULL | - | - | - |
| `id_provincia` | Provincia a la que pertenece | Int | - | NOT NULL | - | - | X (`Provincia`)  |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`

**Triggers asociados:** ninguno.

---

## Ciudad

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_ciudad` | Identificador de la ciudad | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre de la ciudad | VARCHAR | - | NOT NULL | - | - | - |
| `codigo_postal` | Código postal identificador de la ciudad | Int | 1000 < x < 9432 | UNIQUE, NOT NULL | - | - | - |
| `id_departamento` | Departamento al que pertenece | Int | - | NOT NULL | - | - | X (`Departamento`)  |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`
- `CHECK (codigo_postal > 1000 AND codigo_postal < 9432)`

**Triggers asociados:** ninguno.

---

## Barrio

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_barrio` | Identificador del barrio | Int | - | UNIQUE | - | X | - |
| `nombre` | Nombre del barrio | VARCHAR | - | NOT NULL | - | - | - |
| `id_ciudad` | Ciudad a la que pertenece | Int | - | NOT NULL | - | - | X (`Ciudad`)  |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`

**Triggers asociados:** ninguno.

---

## Obra_Social

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_obra_social` | Identificador de la obra social | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre de la obra social | VARCHAR | - | UNIQUE, NOT NULL | - | - | - |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`

**Triggers asociados:** ninguno.

---

## Paciente

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `dni` | Documento nacional de identidad | Int | 1.000.000 a 99.999.999 | UNIQUE | - | X | - |
| `nombre` | Nombre del paciente | VARCHAR | - | NOT NULL | - | - | - |
| `apellido` | Apellido del paciente | VARCHAR | - | NOT NULL | - | - | - |
| `domicilio` | Domicilio del paciente | VARCHAR | - | NOT NULL | - | - | - |
| `fecha_nacimiento` | Fecha de nacimiento del paciente | Date | <= fecha actual | NOT NULL | - | - | - |
| `id_barrio` | Barrio del paciente | Int | - | NOT NULL | - | - | X (`Barrio`)  |
| `id_obra_social` | Obra social del paciente | Int | - | NULL permitido | - | - | X (`Obra_Social`)  |
| `nro_afiliado` | Número de afiliado a la obra social | Int | - | NULL permitido; obligatorio si hay obra social | - | - | - |

**Restricciones CHECK**

- `CHECK (dni BETWEEN 1000000 AND 99999999)`
- `CHECK (fecha_nacimiento <= CURRENT_DATE)`
- `CHECK ((id_obra_social IS NULL AND nro_afiliado IS NULL) OR (id_obra_social IS NOT NULL AND nro_afiliado IS NOT NULL))`: si no hay obra social, `nro_afiliado` debe ser NULL; si la hay, es obligatorio.

**Triggers asociados:** ninguno.

---

## Centro

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_centro` | Identificador del centro de salud | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre del centro de salud | VARCHAR | - | NOT NULL | - | - | - |
| `direccion` | Dirección del centro de salud | VARCHAR | - | NOT NULL | - | - | - |
| `fecha_inauguracion` | Fecha de inauguración del centro | Date | <= fecha actual | NOT NULL | - | - | - |
| `id_barrio` | Barrio al que pertenece | Int | - | NOT NULL | - | - | X (`Barrio`)  |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0 AND length(trim(direccion)) > 0)`
- `CHECK (fecha_inauguracion <= CURRENT_DATE)`

**Triggers asociados:** ninguno.

---

## HorarioCentro

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_horario_centro` | Identificador del horario del centro | Int | - | UNIQUE | - | X | - |
| `dia` | Día de la semana | Dias (`<<Enum>>`) | Lunes a Domingo | NOT NULL | - | - | - |
| `horario_apertura` | Horario de apertura del día | Time | < horario_cierre | NOT NULL | - | - | - |
| `horario_cierre` | Horario de cierre del día | Time | > horario_apertura | NOT NULL | - | - | - |
| `id_centro` | Centro al que pertenece el horario | Int | - | NOT NULL | - | - | X (`Centro`)  |

**Restricciones CHECK**

- `CHECK (horario_apertura < horario_cierre)`

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_horario_centro_sin_superposicion` | Rechaza franjas que se superponen con otra del mismo centro y el mismo día (requiere `SELECT` sobre franjas existentes) | INSERT, UPDATE |

---

## HorarioServicio

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_horario_servicio` | Identificador del horario del servicio | Int | - | UNIQUE | - | X | - |
| `dia` | Día de la semana | Dias (`<<Enum>>`) | Lunes a Domingo | NOT NULL | - | - | - |
| `horario_apertura` | Horario de apertura del día | Time | < horario_cierre | NOT NULL | - | - | - |
| `horario_cierre` | Horario de cierre del día | Time | > horario_apertura | NOT NULL | - | - | - |
| `id_servicio` | Servicio al que pertenece el horario | Int | - | NOT NULL | - | - | X (`Servicio`)  |

**Restricciones CHECK**

- `CHECK (horario_apertura < horario_cierre)`

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_horario_servicio_sin_superposicion` | Rechaza franjas que se superponen con otra del mismo servicio y el mismo día (requiere `SELECT` sobre franjas existentes) | INSERT, UPDATE |

---

## Proveedor

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `nro_matricula` | Número de matrícula del profesional | Int | > 0 | UNIQUE, NOT NULL | - | X | - |
| `tipo_profesional` | Título del profesional (médico o enfermero) | tipo_profesional (`<<Enum>>`) | - | NOT NULL | - | - | - |
| `nombre` | Nombre del profesional | VARCHAR | - | NOT NULL | - | - | - |
| `apellido` | Apellido del profesional | VARCHAR | - | NOT NULL | - | - | - |
| `telefono` | Teléfono del profesional | VARCHAR | - | NOT NULL | - | - | - |
| `email` | Email del profesional | VARCHAR | Formato válido (usuario@dominio) | NOT NULL | - | - | - |
| `fecha_nacimiento` | Fecha de nacimiento del profesional | Date | <= fecha actual | NOT NULL | - | - | - |

**Restricciones CHECK**

- `CHECK (nro_matricula > 0)`
- `CHECK (length(trim(nombre)) > 0 AND length(trim(apellido)) > 0)`
- `CHECK (email LIKE '%@%.%')`
- `CHECK (fecha_nacimiento <= CURRENT_DATE)`

**Triggers asociados:** ninguno.

---

## Especializacion

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_especializacion` | Identificador de la especialización | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre de la especialización | VARCHAR | - | UNIQUE, NOT NULL | - | - | - |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`

**Triggers asociados:** ninguno.

---

## Proveedor_Especializacion

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `nro_matricula` | Matrícula del profesional que posee la especialización | Int | - | NOT NULL | - | X | X (`Proveedor`)  |
| `id_especializacion` | Especialización que posee el profesional | Int | - | NOT NULL | - | X | X (`Especializacion`)  |

La clave primaria compuesta `PRIMARY KEY (nro_matricula, id_especializacion)` garantiza que no se repita la misma especialización para un mismo proveedor.

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_proveedor_especializacion_impedir_baja` | Impide quitarle una especialización a un proveedor que esté a cargo o asignado a un servicio cuyo tipo la requiere (consulta multitabla) | DELETE |

---

## Tipo_Servicio

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_tipo_servicio` | Identificador del tipo de servicio | Int | - | UNIQUE, NOT NULL | - | X | - |
| `nombre` | Nombre del tipo de servicio | VARCHAR | - | UNIQUE, NOT NULL | - | - | - |
| `cant_medicos_asist` | Cantidad de médicos asistentes que requiere el tipo de servicio | Int | >= 0 | NOT NULL | - | - | - |
| `cant_enferm_asist` | Cantidad de enfermeros asistentes que requiere el tipo de servicio | Int | >= 0 | NOT NULL | - | - | - |
| `id_especializacion_requerida` | Especialización que deben tener los profesionales para operar el servicio (NULL en internación) | Int | - | NULL permitido | - | - | X (`Especializacion`)  |

**Restricciones CHECK**

- `CHECK (length(trim(nombre)) > 0)`
- `CHECK (cant_medicos_asist >= 0 AND cant_enferm_asist >= 0)`

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_tipo_servicio_impedir_cambios` | Impide modificar la dotación o la especialización requerida de un tipo que ya tiene servicios creados (consulta a `Servicio`) | UPDATE |

---

## Servicio

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_servicio` | Identificador del servicio | Int | - | NOT NULL, UNIQUE | - | X | - |
| `id_centro` | Centro donde funciona el servicio | Int | - | NOT NULL | - | - | X (`Centro`)  |
| `id_tipo_servicio` | Identificador del tipo de servicio | Int | - | NOT NULL | - | - | X (`Tipo_Servicio`)  |
| `medico_a_cargo_matricula` | Matrícula del médico a cargo | Int | - | NOT NULL | - | - | X (`Proveedor`)  |

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_servicio_medico_a_cargo_valido` | Verifica que el médico a cargo sea de tipo Médico (`Proveedor`) y tenga la especialización que requiere el tipo de servicio (`Proveedor_Especializacion`) | INSERT, UPDATE |
| `tgr_servicio_impedir_cambios` | Impide cambiar el centro o el tipo de un servicio que ya tiene horarios, asignaciones o historias clínicas | UPDATE |

---

## AsignacionServicio

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_servicio` | Servicio al que se asigna el profesional | Int | - | NOT NULL | - | X | X (`Servicio`)  |
| `nro_matricula` | Matrícula del profesional asignado | Int | - | NOT NULL | - | X | X (`Proveedor`)  |
| `rol` | Rol que cumple el profesional en el servicio | RolAsignacion (`<<Enum>>`) | Médico asistente, Enfermero asistente | NOT NULL | - | - | - |

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_asignacion_servicio_profesional_valido` | Verifica que el rol coincida con el tipo de profesional, que tenga la especialización requerida por el tipo de servicio y que no sea el médico a cargo | INSERT, UPDATE |
| `tgr_asignacion_servicio_cupo` | Impide superar la cantidad de médicos o enfermeros asistentes que define el tipo de servicio (`COUNT(*)` contra `Tipo_Servicio`) | INSERT, UPDATE |
| `tgr_asignacion_servicio_impedir_baja` | Impide quitar a un médico de un servicio donde ya atendió pacientes (consulta a `HistoriaClinica`) | DELETE |

---

## HistoriaClinica

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_historia_clinica` | Identificador de la historia clínica | Int | - | UNIQUE, NOT NULL | - | X | - |
| `dia_visita` | Día en que el paciente visitó el centro | Date | <= fecha actual | NOT NULL | - | - | - |
| `diagnostico` | Diagnóstico indicado al paciente | VARCHAR | - | NOT NULL | - | - | - |
| `tratamiento` | Tratamiento indicado al paciente | VARCHAR | - | NOT NULL | - | - | - |
| `paciente_dni` | Paciente atendido | Int | 1.000.000 a 99.999.999 | NOT NULL | - | - | X (`Paciente`)  |
| `id_servicio` | Servicio utilizado en la visita | Int | - | NOT NULL | - | - | X (`Servicio`)  |
| `medico_matricula` | Médico que atendió al paciente | Int | - | NOT NULL | - | - | X (`Proveedor`)  |

**Restricciones CHECK**

- `CHECK (dia_visita <= CURRENT_DATE)`
- `CHECK (length(trim(diagnostico)) > 0 AND length(trim(tratamiento)) > 0)`

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_historia_clinica_medico_valido` | Verifica que quien atiende sea de tipo Médico y esté a cargo del servicio o asignado como médico asistente (`Servicio` / `AsignacionServicio`) | INSERT, UPDATE |

---

## Internacion

| Atributo | Descripción | Dominio | Rango | Restricciones | Valor por defecto | PK | FK (tabla referida) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `id_internacion` | Identificador de la internación | Int | - | UNIQUE, NOT NULL | - | X | - |
| `fecha_ingreso` | Fecha de ingreso al establecimiento | Date | <= fecha actual | NOT NULL | - | - | - |
| `fecha_egreso` | Fecha de egreso (NULL mientras siga internado) | Date | >= fecha_ingreso | NULL permitido | NULL | - | - |
| `id_historia_clinica` | Visita que originó la internación | Int | - | UNIQUE, NOT NULL | - | - | X (`HistoriaClinica`)  |

**Restricciones CHECK**

- `CHECK (fecha_ingreso <= CURRENT_DATE AND (fecha_egreso IS NULL OR (fecha_egreso >= fecha_ingreso AND fecha_egreso <= CURRENT_DATE)))`

**Triggers asociados**

| Trigger | Descripción | Operaciones vinculadas |
| :--- | :--- | :--- |
| `tgr_internacion_servicio_valido` | Verifica que la historia clínica corresponda a un servicio de tipo Internación | INSERT, UPDATE |
| `tgr_internacion_sin_superposicion` | Impide que un mismo paciente tenga dos internaciones superpuestas, incluida una que siga abierta (`fecha_egreso IS NULL`) | INSERT, UPDATE |

