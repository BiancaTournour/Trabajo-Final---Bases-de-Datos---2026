# Bases de Datos
## Trabajo Final – Entrega 1

Grupo 13: Poggio Joaquin, Schaab Valentina, Tournour Bianca.

## Entrega 1

A) El modelo lógico de la BD, indicando claves primarias, dominio y demás restricciones de todos los atributos y la cardinalidad de las relaciones.

B) El modelo relacional de la BD, normalizado y llevado a la FN3.

## Propuesta

### Propuesta 1: Centros de salud

La secretaría de salud de la provincia busca crear un sistema de administración para todos los centros de salud de la provincia. Cada centro de salud se encuentra en un barrio, ciudad y departamento en particular y cuenta con distintos servicios de salud de acuerdo al centro. Cada centro tiene un nombre, dirección, fecha de inauguración, días hábiles y horarios de atención. El sistema también almacena los datos de los distintos proveedores de salud, tanto médicos como enfermeros. De cada uno se almacena el tipo de profesional, su nombre y apellido, número de matrícula, edad, teléfono y email de contacto, fecha de nacimiento y especializaciones que es capaz de realizar.

Cada servicio de salud brindado por un centro (tomgrafías, laboratorio químico, ginecología, etc) debe tener un médico a cargo y, de acuerdo al tipo de servicio, una cantidad determinada de médicos y enfermeros asistentes. Estos médicos y enfermeros deberán tener la especialización correcta para poder operar el servicio. Cada servicio particular de un centro de salud podrá tener sus horarios de atención y días hábiles propios. Además de los servicios, cada centro de salud puede contar con un ala de internación, la cual se considerará como un servicio separado que puede ser dirigido por cualquier médico. El sistema también será capaz de almacenar los datos de los distintos pacientes que se atienden en cada centro, contando con su dni, nombres y apellidos, domicilio, fecha de nacimiento, edad, obra social y número de asociado (de tenerla).

De cada paciente se almacenará su historia clínica, registrando el día de visita, el centro de salud visitado, el médico que lo atendió, el servicio utilizado, el diagnóstico y tratamiento indicado. Además, en caso de que su visita sea por una internación, se deberán almacenar las fechas de ingreso y egreso del establecimiento.

## Consultas

- A. Cantidad de pacientes con un diagnóstico determinado de cada ciudad
- B. Centros de salud que cuenten con un servicio determinado que estén abiertos a la hora y día actual de consulta
- C. El médico con mayor cantidad de pacientes atendidos de cada centro, organizados por barrio.
- D. Centro de salud con mayor cantidad de servicios de cada barrio
- E. Mostrar los 10 pacientes con mayor cantidad de ingresos a centros de salud en el último mes
- F. Cantidad de pacientes con menos de 5 atenciones en los últimos 6 meses que se encuentren actualmente internados en algún centro.

## Modelo Relacional

```text
VAR BASE RELATION Provincia (
id_provincia Int,
nombre VARCHAR(45),
PRIMARY KEY (id_provincia)
)
```

```text
VAR BASE RELATION Departamento (
id_departamento Int,
nombre VARCHAR(45),
id_provincia Int,
PRIMARY KEY (id_departamento),
FOREIGN KEY (id_provincia) REFERENCES Provincia
)
```

```text
VAR BASE RELATION Ciudad (
id_ciudad Int,
nombre VARCHAR(45),
codigo_postal VARCHAR(10),
id_departamento Int,
PRIMARY KEY (id_ciudad),
FOREIGN KEY (id_departamento) REFERENCES Departamento
)
```

```text
VAR BASE RELATION Barrio (
id_barrio Int,
nombre VARCHAR(45),
id_ciudad Int,
PRIMARY KEY (id_barrio),
FOREIGN KEY (id_ciudad) REFERENCES Ciudad
)
```

```text
VAR BASE RELATION Obra_Social (
id_obra_social Int,
nombre VARCHAR(20),
PRIMARY KEY (id_obra_social)
)
```

```text
VAR BASE RELATION Paciente (
dni Int,
nombre VARCHAR(50),
apellido VARCHAR(30),
domicilio VARCHAR(50),
fecha_nacimiento Date,
id_barrio Int,
id_obra_social Int,
nro_afiliado Int,
PRIMARY KEY (dni),
FOREIGN KEY (id_barrio) REFERENCES Barrio,
FOREIGN KEY (id_obra_social) REFERENCES Obra_Social
)
```

```text
VAR BASE RELATION Centro (
id_centro Int,
nombre VARCHAR(50),
direccion VARCHAR(30),
fecha_inauguracion Date,
id_barrio Int,
PRIMARY KEY (id_centro),
FOREIGN KEY (id_barrio) REFERENCES Barrio
)
```

```text
VAR BASE RELATION HorarioCentro (
id_horario_centro Int,
dia Dias,
horario_apertura Time,
horario_cierre Time,
id_centro Int,
PRIMARY KEY (id_horario_centro),
FOREIGN KEY (id_centro) REFERENCES Centro
)
```

```text
VAR BASE RELATION HorarioServicio (
id_horario_servicio Int,
dia Dias,
horario_apertura Time,
horario_cierre Time,
id_servicio Int,
PRIMARY KEY (id_horario_servicio),
FOREIGN KEY (id_servicio) REFERENCES Servicio
)
```

```text
VAR BASE RELATION Proveedor (
nro_matricula Int,
tipo_profesional tipoprofesional,
nombre VARCHAR(30),
apellido VARCHAR(30),
telefono VARCHAR(20),
email VARCHAR(30),
fecha_nacimiento Date,
PRIMARY KEY (nro_matricula)
)
```

```text
VAR BASE RELATION Especializacion (
id_especializacion Int,
nombre VARCHAR(40),
PRIMARY KEY (id_especializacion)
)
```

```text
VAR BASE RELATION Proveedor_Especializacion (
nro_matricula Int,
id_especializacion Int,
PRIMARY KEY (nro_matricula, id_especializacion),
FOREIGN KEY (nro_matricula) REFERENCES Proveedor,
FOREIGN KEY (id_especializacion) REFERENCES Especializacion
)
```

```text
VAR BASE RELATION Tipo_Servicio (
id_tipo_servicio Int,
nombre VARCHAR(50),
cant_medicos_asist Int,
cant_enferm_asist Int,
id_especializacion_requerida Int,
PRIMARY KEY (id_tipo_servicio),
FOREIGN KEY (id_especializacion_requerida) REFERENCES Especializacion
)
```

```text
VAR BASE RELATION Servicio (
id_servicio Int,
id_centro Int,
id_tipo_servicio Int,
medico_a_cargo_matricula Int,
PRIMARY KEY (id_servicio),
FOREIGN KEY (id_centro) REFERENCES Centro,
FOREIGN KEY (id_tipo_servicio) REFERENCES Tipo_Servicio,
FOREIGN KEY (medico_a_cargo_matricula) REFERENCES Proveedor
)
```

```text
VAR BASE RELATION AsignacionServicio (
id_servicio Int,
nro_matricula Int,
rol RolAsignacion,
PRIMARY KEY (id_servicio, nro_matricula),
FOREIGN KEY (id_servicio) REFERENCES Servicio,
FOREIGN KEY (nro_matricula) REFERENCES Proveedor
)
```

```text
VAR BASE RELATION HistoriaClinica (
id_historia_clinica Int,
dia_visita Date,
diagnostico Text,
tratamiento Text,
paciente_dni Int,
id_servicio Int,
medico_matricula Int,
PRIMARY KEY (id_historia_clinica),
FOREIGN KEY (paciente_dni) REFERENCES Paciente,
FOREIGN KEY (id_servicio) REFERENCES Servicio,
FOREIGN KEY (medico_matricula) REFERENCES Proveedor
)
```

```text
VAR BASE RELATION Internacion (
id_internacion Int,
fecha_ingreso Date,
fecha_egreso Date,
id_historia_clinica Int,
PRIMARY KEY (id_internacion),
FOREIGN KEY (id_historia_clinica) REFERENCES HistoriaClinica
)
```

## Normalización

### 1. Verificación de Primera Forma Normal (1FN)

**Requisito:** Todos los atributos de la relación deben contener valores atómicos (indivisibles) y debe existir una Clave Primaria (PK) explícitamente definida.

**Verificación en el Modelo:**

- **Atributos multivaluados eliminados:** Las especializaciones de los profesionales no están como listas dentro de Proveedor, sino que se extrajeron a la relación intermedia Proveedor_Especializacion.
- **Valores atómicos:** Todos los campos (nombre, domicilio, fechas, teléfonos) representan valores únicos indivisibles.
- **Claves primarias:** Cada una de las 16 relaciones posee una PK única o compuesta claramente identificada.

### 2. Verificación de Segunda Forma Normal (2FN)

**Requisito:** Estar en 1FN y que todos los atributos no clave dependan de forma plena e irreducible de la totalidad de la clave primaria (sin dependencias parciales).

**Verificación en el Modelo:**

- **Tablas con Clave Primaria Simple:** Para Provincia, Departamento, Ciudad, Barrio, Obra_Social, Paciente, Centro, Atencion, Proveedor, Especializacion, Tipo_Servicio, Servicio, HistoriaClinica e Internacion, al tener una clave de un solo atributo, la 2FN se cumple trivialmente.

- **Tablas con Clave Primaria Compuesta:**

  - **Proveedor_Especializacion (nro_matricula, id_especializacion):** Todos sus componentes forman la clave primaria compuesta, por lo que no existen atributos no clave que puedan incurrir en dependencias parciales.

  - **AsignacionServicio (id_servicio, nro_matricula, rol):** El atributo no clave rol depende funcionalmente de la combinación completa de (id_servicio, nro_matricula), ya que un mismo proveedor puede desempeñar roles diferentes en distintos servicios.

### 3. Verificación de Tercera Forma Normal (3FN)

**Requisito:** Estar en 2FN y que ningún atributo no clave dependa transitivamente de otro atributo no clave (cada atributo no clave debe depender directamente e irreduciblemente solo de la clave primaria).

**Verificación en el Modelo:**

- **Sin atributos derivados:** Se omitió la edad en Paciente y Proveedor (calculada dinámicamente mediante fecha_nacimiento), evitando dependencias transitivas.

- **Separación de Catálogo e Instancia:** Se mantuvo la separación de Tipo_Servicio (definición general) y Servicio (instancia en un centro de salud), evitando que los datos descriptivos del tipo de prestación dependan transitivamente del centro.

- **Jerarquía Geográfica Descompuesta:** Paciente y Centro solo almacenan la referencia directa a id_barrio. Los datos de la ciudad, departamento y provincia se obtienen navegando por sus relaciones correspondientes, evitando redundancia y dependencias transitivas como dni -> barrio -> ciudad.

- **Atención e Internación:** En HistoriaClinica, diagnostico, tratamiento y dia_visita dependen únicamente de id_historia_clinica. Igualmente, las fechas de ingreso y egreso en Internacion dependen de id_internacion.
