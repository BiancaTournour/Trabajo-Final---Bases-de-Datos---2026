-- Esquema Centro de Salud, Tablas, Enums y Checks

-- Tipos enumerados
CREATE TYPE dias AS ENUM
  ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo');

CREATE TYPE tipoprofesional AS ENUM
  ('Medico', 'Enfermero');

CREATE TYPE rolasignacion AS ENUM
  ('Medico_Asistente', 'Enfermero_Asistente');

--  Ubicacion
CREATE TABLE provincia (
  id_provincia INTEGER PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL UNIQUE,
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE departamento (
  id_departamento INTEGER PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL,
  id_provincia INTEGER NOT NULL REFERENCES provincia (id_provincia),
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE ciudad (
  id_ciudad INTEGER PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL,
  codigo_postal INTEGER NOT NULL UNIQUE,
  id_departamento INTEGER NOT NULL REFERENCES departamento (id_departamento),
  CHECK (length(trim(nombre)) > 0),
  CHECK (codigo_postal > 1000 AND codigo_postal < 9432)
);

CREATE TABLE barrio (
  id_barrio INTEGER PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL,
  id_ciudad INTEGER NOT NULL REFERENCES ciudad (id_ciudad),
  CHECK (length(trim(nombre)) > 0)
);

--  Pacientes
CREATE TABLE obra_social (
  id_obra_social INTEGER PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE,
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE paciente (
  dni INTEGER PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(30) NOT NULL,
  domicilio VARCHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  id_barrio INTEGER NOT NULL REFERENCES barrio (id_barrio),
  id_obra_social INTEGER REFERENCES obra_social (id_obra_social),
  nro_afiliado INTEGER,
  CHECK (dni BETWEEN 1000000 AND 99999999),
  CHECK (fecha_nacimiento <= CURRENT_DATE),
  CHECK (
    (id_obra_social IS NULL AND nro_afiliado IS NULL) OR
    (id_obra_social IS NOT NULL AND nro_afiliado IS NOT NULL)
  )
);

--  Centros
CREATE TABLE centro (
  id_centro INTEGER PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  direccion VARCHAR(30) NOT NULL,
  fecha_inauguracion DATE NOT NULL,
  id_barrio INTEGER NOT NULL REFERENCES barrio (id_barrio),
  CHECK (length(trim(nombre)) > 0 AND length(trim(direccion)) > 0),
  CHECK (fecha_inauguracion <= CURRENT_DATE)
);

CREATE TABLE horariocentro (
  id_horario_centro INTEGER PRIMARY KEY,
  dia dias NOT NULL,
  horario_apertura TIME NOT NULL,
  horario_cierre TIME NOT NULL,
  id_centro INTEGER NOT NULL REFERENCES centro (id_centro),
  CHECK (horario_apertura < horario_cierre)
);

-- Profesionales
CREATE TABLE especializacion (
  id_especializacion INTEGER PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL UNIQUE,
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE proveedor (
  nro_matricula INTEGER PRIMARY KEY,
  tipo_profesional tipoprofesional NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  apellido VARCHAR(30) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(30) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  CHECK (nro_matricula > 0),
  CHECK (length(trim(nombre)) > 0 AND length(trim(apellido)) > 0),
  CHECK (email LIKE '%@%.%'),
  CHECK (fecha_nacimiento <= CURRENT_DATE)
);

CREATE TABLE proveedor_especializacion (
  nro_matricula INTEGER REFERENCES proveedor (nro_matricula),
  id_especializacion INTEGER REFERENCES especializacion (id_especializacion),
  PRIMARY KEY (nro_matricula, id_especializacion)
);

--  Servicios
CREATE TABLE tipo_servicio (
  id_tipo_servicio INTEGER PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  cant_medicos_asist INTEGER NOT NULL,
  cant_enferm_asist INTEGER NOT NULL,
  id_especializacion_requerida INTEGER REFERENCES especializacion (id_especializacion),
  es_internacion BOOLEAN NOT NULL DEFAULT FALSE,
  CHECK (length(trim(nombre)) > 0),
  CHECK (cant_medicos_asist >= 0 AND cant_enferm_asist >= 0)
);

CREATE TABLE servicio (
  id_servicio INTEGER PRIMARY KEY,
  id_centro INTEGER NOT NULL REFERENCES centro (id_centro),
  id_tipo_servicio INTEGER NOT NULL REFERENCES tipo_servicio (id_tipo_servicio),
  medico_a_cargo_matricula INTEGER NOT NULL REFERENCES proveedor (nro_matricula)
);

CREATE TABLE horarioservicio (
  id_horario_servicio INTEGER PRIMARY KEY,
  dia dias NOT NULL,
  horario_apertura TIME NOT NULL,
  horario_cierre TIME NOT NULL,
  id_servicio INTEGER NOT NULL REFERENCES servicio (id_servicio),
  CHECK (horario_apertura < horario_cierre)
);

CREATE TABLE asignacionservicio (
  id_servicio INTEGER REFERENCES servicio (id_servicio),
  nro_matricula INTEGER REFERENCES proveedor (nro_matricula),
  rol rolasignacion NOT NULL,
  PRIMARY KEY (id_servicio, nro_matricula)
);

--  Atencion
CREATE TABLE historiaclinica (
  id_historia_clinica INTEGER PRIMARY KEY,
  dia_visita DATE NOT NULL,
  diagnostico TEXT NOT NULL,
  tratamiento TEXT NOT NULL,
  paciente_dni INTEGER NOT NULL REFERENCES paciente (dni),
  id_servicio INTEGER NOT NULL REFERENCES servicio (id_servicio),
  medico_matricula INTEGER NOT NULL REFERENCES proveedor (nro_matricula),
  CHECK (dia_visita <= CURRENT_DATE),
  CHECK (length(trim(diagnostico)) > 0 AND length(trim(tratamiento)) > 0)
);

CREATE TABLE internacion (
  id_internacion INTEGER PRIMARY KEY,
  fecha_ingreso DATE NOT NULL,
  fecha_egreso DATE,
  id_historia_clinica INTEGER NOT NULL UNIQUE REFERENCES historiaclinica (id_historia_clinica),
  CHECK (
    fecha_ingreso <= CURRENT_DATE AND
    (fecha_egreso IS NULL OR
      (fecha_egreso >= fecha_ingreso AND fecha_egreso <= CURRENT_DATE))
  )
);