-- Esquema Centro de Salud 

-- Tipos enumerados 
CREATE TYPE dias AS ENUM
  ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo');

CREATE TYPE tipoprofesional AS ENUM
  ('Medico', 'Enfermero');

CREATE TYPE rolasignacion AS ENUM
  ('Medico', 'Enfermero');

--  Ubicacion 
CREATE TABLE provincia (
  id_provincia INTEGER PRIMARY KEY,
  nombre VARCHAR(45),
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE departamento (
  id_departamento INTEGER PRIMARY KEY,
  nombre VARCHAR(45),
  id_provincia INTEGER REFERENCES provincia (id_provincia),
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE ciudad (
  id_ciudad INTEGER PRIMARY KEY,
  nombre VARCHAR(45),
  codigo_postal VARCHAR(10),
  id_departamento INTEGER REFERENCES departamento (id_departamento),
  CHECK (length(trim(nombre)) > 0),
  CHECK (
    CASE WHEN codigo_postal ~ '^[0-9]{1,9}$'
         THEN codigo_postal::INTEGER > 1000 AND codigo_postal::INTEGER < 9432
         ELSE FALSE
    END
  )
);

CREATE TABLE barrio (
  id_barrio INTEGER PRIMARY KEY,
  nombre VARCHAR(45),
  id_ciudad INTEGER REFERENCES ciudad (id_ciudad),
  CHECK (length(trim(nombre)) > 0)
);

--  Pacientes 
CREATE TABLE obra_social (
  id_obra_social INTEGER PRIMARY KEY,
  nombre VARCHAR(20),
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE paciente (
  dni INTEGER PRIMARY KEY,
  nombre VARCHAR(50),
  apellido VARCHAR(30),
  domicilio VARCHAR(50),
  fecha_nacimiento DATE,
  id_barrio INTEGER REFERENCES barrio (id_barrio),
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
  nombre VARCHAR(50),
  direccion VARCHAR(30),
  fecha_inauguracion DATE,
  id_barrio INTEGER REFERENCES barrio (id_barrio),
  CHECK (length(trim(nombre)) > 0 AND length(trim(direccion)) > 0),
  CHECK (fecha_inauguracion <= CURRENT_DATE)
);

CREATE TABLE horariocentro (
  id_horario_centro INTEGER PRIMARY KEY,
  dia dias,
  horario_apertura TIME,
  horario_cierre TIME,
  id_centro INTEGER REFERENCES centro (id_centro),
  CHECK (horario_apertura < horario_cierre)
);

-- Profesionales 
CREATE TABLE especializacion (
  id_especializacion INTEGER PRIMARY KEY,
  nombre VARCHAR(40),
  CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE proveedor (
  nro_matricula INTEGER PRIMARY KEY,
  tipo_profesional tipoprofesional,
  nombre VARCHAR(30),
  apellido VARCHAR(30),
  telefono VARCHAR(20),
  email VARCHAR(30),
  fecha_nacimiento DATE,
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
  nombre VARCHAR(50),
  cant_medicos_asist INTEGER,
  cant_enferm_asist INTEGER,
  id_especializacion_requerida INTEGER REFERENCES especializacion (id_especializacion),
  CHECK (length(trim(nombre)) > 0),
  CHECK (cant_medicos_asist >= 0 AND cant_enferm_asist >= 0)
);

CREATE TABLE servicio (
  id_servicio INTEGER PRIMARY KEY,
  id_centro INTEGER REFERENCES centro (id_centro),
  id_tipo_servicio INTEGER REFERENCES tipo_servicio (id_tipo_servicio),
  medico_a_cargo_matricula INTEGER REFERENCES proveedor (nro_matricula)
);

CREATE TABLE horarioservicio (
  id_horario_servicio INTEGER PRIMARY KEY,
  dia dias,
  horario_apertura TIME,
  horario_cierre TIME,
  id_servicio INTEGER REFERENCES servicio (id_servicio),
  CHECK (horario_apertura < horario_cierre)
);

CREATE TABLE asignacionservicio (
  id_servicio INTEGER REFERENCES servicio (id_servicio),
  nro_matricula INTEGER REFERENCES proveedor (nro_matricula),
  rol rolasignacion,
  PRIMARY KEY (id_servicio, nro_matricula)
);

--  Atencion 
CREATE TABLE historiaclinica (
  id_historia_clinica INTEGER PRIMARY KEY,
  dia_visita DATE,
  diagnostico TEXT,
  tratamiento TEXT,
  paciente_dni INTEGER REFERENCES paciente (dni),
  id_servicio INTEGER REFERENCES servicio (id_servicio),
  medico_matricula INTEGER REFERENCES proveedor (nro_matricula),
  CHECK (dia_visita <= CURRENT_DATE),
  CHECK (length(trim(diagnostico)) > 0 AND length(trim(tratamiento)) > 0)
);

CREATE TABLE internacion (
  id_internacion INTEGER PRIMARY KEY,
  fecha_ingreso DATE,
  fecha_egreso DATE,
  id_historia_clinica INTEGER REFERENCES historiaclinica (id_historia_clinica),
  CHECK (
    fecha_ingreso <= CURRENT_DATE AND
    (fecha_egreso IS NULL OR
      (fecha_egreso >= fecha_ingreso AND fecha_egreso <= CURRENT_DATE))
  )
);