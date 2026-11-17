-- Poblado de la base de datos, inserción de datos

BEGIN;

-- provincia: 15 registros
INSERT INTO provincia (id_provincia, nombre) VALUES
    (1, 'Entre Ríos'),
    (2, 'Buenos Aires'),
    (3, 'Santa Fe'),
    (4, 'Córdoba'),
    (5, 'Mendoza'),
    (6, 'Misiones'),
    (7, 'Corrientes'),
    (8, 'Chaco'),
    (9, 'Formosa'),
    (10, 'Salta'),
    (11, 'Jujuy'),
    (12, 'Tucumán'),
    (13, 'San Juan'),
    (14, 'San Luis'),
    (15, 'Neuquén');


-- departamento: 15 registros
INSERT INTO departamento (id_departamento, nombre, id_provincia) VALUES
    (1, 'Paraná', 1),
    (2, 'La Plata', 2),
    (3, 'Rosario', 3),
    (4, 'Capital', 4),
    (5, 'Capital', 5),
    (6, 'Capital', 6),
    (7, 'Capital', 7),
    (8, 'San Fernando', 8),
    (9, 'Formosa', 9),
    (10, 'Capital', 10),
    (11, 'Doctor Manuel Belgrano', 11),
    (12, 'Capital', 12),
    (13, 'Capital', 13),
    (14, 'Juan Martín de Pueyrredón', 14),
    (15, 'Confluencia', 15);


-- ciudad: 15 registros
INSERT INTO ciudad (id_ciudad, nombre, codigo_postal, id_departamento) VALUES
    (1, 'Paraná', '3100', 1),
    (2, 'La Plata', '1900', 2),
    (3, 'Rosario', '2000', 3),
    (4, 'Córdoba', '5000', 4),
    (5, 'Mendoza', '5500', 5),
    (6, 'Posadas', '3300', 6),
    (7, 'Corrientes', '3400', 7),
    (8, 'Resistencia', '3500', 8),
    (9, 'Formosa', '3600', 9),
    (10, 'Salta', '4400', 10),
    (11, 'San Salvador de Jujuy', '4600', 11),
    (12, 'San Miguel de Tucumán', '4000', 12),
    (13, 'San Juan', '5400', 13),
    (14, 'San Luis', '5700', 14),
    (15, 'Neuquén', '8300', 15);


-- barrio: 15 registros
INSERT INTO barrio (id_barrio, nombre, id_ciudad) VALUES
    (1, 'Centro', 1),
    (2, 'Villa Elisa', 2),
    (3, 'Pichincha', 3),
    (4, 'Nueva Córdoba', 4),
    (5, 'Quinta Sección', 5),
    (6, 'Villa Sarita', 6),
    (7, 'La Rosada', 7),
    (8, 'Villa San Martín', 8),
    (9, 'San Martín', 9),
    (10, 'Tres Cerritos', 10),
    (11, 'Centro', 11),
    (12, 'Barrio Norte', 12),
    (13, 'Desamparados', 13),
    (14, 'Centro', 14),
    (15, 'Santa Genoveva', 15);


-- obra_social: 15 registros
INSERT INTO obra_social (id_obra_social, nombre) VALUES
    (1, 'IOSPER'),
    (2, 'PAMI'),
    (3, 'OSDE'),
    (4, 'Swiss Medical'),
    (5, 'Prevención Salud'),
    (6, 'Sancor Salud'),
    (7, 'Galeno'),
    (8, 'Medifé'),
    (9, 'Jerárquicos Salud'),
    (10, 'Federada Salud'),
    (11, 'Luis Pasteur'),
    (12, 'OSECAC'),
    (13, 'Unión Personal'),
    (14, 'Avalian'),
    (15, 'Particular');


-- especializacion: 15 registros
INSERT INTO especializacion (id_especializacion, nombre) VALUES
    (1, 'Clínica médica'),
    (2, 'Cardiología'),
    (3, 'Pediatría'),
    (4, 'Medicina general'),
    (5, 'Traumatología'),
    (6, 'Dermatología'),
    (7, 'Ginecología'),
    (8, 'Neurología'),
    (9, 'Oftalmología'),
    (10, 'Odontología'),
    (11, 'Kinesiología'),
    (12, 'Laboratorio'),
    (13, 'Diagnóstico por imágenes'),
    (14, 'Salud mental'),
    (15, 'Vacunación');


-- paciente: 30 registros
INSERT INTO paciente (dni, nombre, apellido, domicilio, fecha_nacimiento, id_barrio, id_obra_social, nro_afiliado) VALUES
    (30000001, 'Lucía', 'Gómez', 'San Martín 125', '1950-01-01', 1, 1, 500000),
    (30000002, 'Mateo', 'Fernández', 'Belgrano 842', '1957-02-04', 2, 2, 500001),
    (30000003, 'Sofía', 'López', 'Urquiza 310', '1964-03-07', 3, 3, 500002),
    (30000004, 'Benjamín', 'Martínez', 'Sarmiento 1560', '1971-04-10', 4, 4, 500003),
    (30000005, 'Valentina', 'Díaz', 'Italia 455', '1978-05-13', 5, 5, 500004),
    (30000006, 'Joaquín', 'Pérez', 'Mitre 920', '1985-06-16', 6, 6, 500005),
    (30000007, 'Martina', 'Sosa', '25 de Mayo 711', '1992-07-19', 7, 7, 500006),
    (30000008, 'Thiago', 'Romero', 'Alberdi 234', '1999-08-22', 8, 8, 500007),
    (30000009, 'Camila', 'Álvarez', 'Rivadavia 1880', '1951-09-25', 9, 9, 500008),
    (30000010, 'Santiago', 'Torres', 'Pueyrredón 605', '1958-10-01', 10, 10, 500009),
    (30000011, 'Mía', 'Ruiz', 'Las Heras 430', '1965-11-04', 11, 11, 500010),
    (30000012, 'Tomás', 'Benítez', 'Brown 1275', '1972-12-07', 12, 12, 500011),
    (30000013, 'Emma', 'Acosta', 'Moreno 390', '1979-01-10', 13, 13, 500012),
    (30000014, 'Bautista', 'Medina', 'España 166', '1986-02-13', 14, 14, 500013),
    (30000015, 'Catalina', 'Herrera', 'Entre Ríos 740', '1993-03-16', 15, 15, 500014),
    (30000016, 'Felipe', 'Suárez', 'Jujuy 221', '2000-04-19', 1, 1, 500015),
    (30000017, 'Olivia', 'Aguirre', 'Córdoba 980', '1952-05-22', 2, 2, 500016),
    (30000018, 'Lautaro', 'Gutiérrez', 'Santa Fe 512', '1959-06-25', 3, 3, 500017),
    (30000019, 'Julieta', 'Molina', 'Mendoza 1450', '1966-07-01', 4, 4, 500018),
    (30000020, 'Franco', 'Castro', 'Catamarca 330', '1973-08-04', 5, 5, 500019),
    (30000021, 'Renata', 'Ortiz', 'Paraguay 615', '1980-09-07', 6, 6, 500020),
    (30000022, 'Bruno', 'Silva', 'Chile 1020', '1987-10-10', 7, 7, 500021),
    (30000023, 'Abril', 'Rojas', 'Perú 275', '1994-11-13', 8, 8, 500022),
    (30000024, 'Dylan', 'Núñez', 'San Juan 890', '2001-12-16', 9, 9, 500023),
    (30000025, 'Pilar', 'Cabrera', 'Maipú 410', '1953-01-19', 10, 10, 500024),
    (30000026, 'Facundo', 'Vega', 'Laprida 720', '1960-02-22', 11, NULL, NULL),
    (30000027, 'Malena', 'Méndez', 'Junín 155', '1967-03-25', 12, NULL, NULL),
    (30000028, 'Agustín', 'Flores', 'Tucumán 1340', '1974-04-01', 13, NULL, NULL),
    (30000029, 'Alma', 'Ibarra', 'Salta 580', '1981-05-04', 14, NULL, NULL),
    (30000030, 'Nicolás', 'Navarro', 'Corrientes 965', '1988-06-07', 15, NULL, NULL);


-- centro: 15 registros
INSERT INTO centro (id_centro, nombre, direccion, fecha_inauguracion, id_barrio) VALUES
    (1, 'Centro de Salud Paraná Norte', 'Urquiza 450', '1980-01-15', 1),
    (2, 'Centro Médico La Plata', 'Calle 12 845', '1981-02-15', 2),
    (3, 'Centro de Salud Rosario Este', 'Bv. Oroño 1250', '1982-03-15', 3),
    (4, 'Centro Integral Córdoba', 'Av. Colón 760', '1983-04-15', 4),
    (5, 'Centro Médico Mendoza', 'San Martín 980', '1984-05-15', 5),
    (6, 'Centro de Salud Posadas', 'Bolívar 320', '1985-06-15', 6),
    (7, 'Centro Asistencial Corrientes', 'Junín 640', '1986-07-15', 7),
    (8, 'Centro Médico Resistencia', 'Güemes 1150', '1987-08-15', 8),
    (9, 'Centro de Salud Formosa', 'Belgrano 525', '1988-09-15', 9),
    (10, 'Centro Integral Salta', 'España 890', '1989-10-15', 10),
    (11, 'Centro Médico Jujuy', 'Lavalle 430', '1990-11-15', 11),
    (12, 'Centro de Salud Tucumán', 'Maipú 710', '1991-12-15', 12),
    (13, 'Centro Asistencial San Juan', 'Mitre 360', '1992-01-15', 13),
    (14, 'Centro Médico San Luis', 'Pringles 580', '1993-02-15', 14),
    (15, 'Centro de Salud Neuquén', 'Av. Argentina 1020', '1994-03-15', 15);


-- horariocentro: 15 registros
INSERT INTO horariocentro (id_horario_centro, dia, horario_apertura, horario_cierre, id_centro) VALUES
    (1, 'Lunes', '08:00:00', '20:00:00', 1),
    (2, 'Martes', '08:00:00', '20:00:00', 2),
    (3, 'Miercoles', '08:00:00', '20:00:00', 3),
    (4, 'Jueves', '08:00:00', '20:00:00', 4),
    (5, 'Viernes', '08:00:00', '20:00:00', 5),
    (6, 'Sabado', '08:00:00', '20:00:00', 6),
    (7, 'Lunes', '08:00:00', '20:00:00', 7),
    (8, 'Martes', '08:00:00', '20:00:00', 8),
    (9, 'Miercoles', '08:00:00', '20:00:00', 9),
    (10, 'Jueves', '08:00:00', '20:00:00', 10),
    (11, 'Viernes', '08:00:00', '20:00:00', 11),
    (12, 'Sabado', '08:00:00', '20:00:00', 12),
    (13, 'Lunes', '08:00:00', '20:00:00', 13),
    (14, 'Martes', '08:00:00', '20:00:00', 14),
    (15, 'Miercoles', '08:00:00', '20:00:00', 15);


-- proveedor: 30 registros
INSERT INTO proveedor (nro_matricula, tipo_profesional, nombre, apellido, telefono, email, fecha_nacimiento) VALUES
    (1001, 'Medico', 'Ana', 'Ríos', '343-410000', 'medico1@centrosalud.com', '1970-01-12'),
    (1002, 'Medico', 'Carlos', 'Méndez', '343-410001', 'medico2@centrosalud.com', '1971-02-12'),
    (1003, 'Medico', 'María', 'Paz', '343-410002', 'medico3@centrosalud.com', '1972-03-12'),
    (1004, 'Medico', 'Jorge', 'Acosta', '343-410003', 'medico4@centrosalud.com', '1973-04-12'),
    (1005, 'Medico', 'Paula', 'Varela', '343-410004', 'medico5@centrosalud.com', '1974-05-12'),
    (1006, 'Medico', 'Diego', 'Quiroga', '343-410005', 'medico6@centrosalud.com', '1975-06-12'),
    (1007, 'Medico', 'Florencia', 'Luna', '343-410006', 'medico7@centrosalud.com', '1976-07-12'),
    (1008, 'Medico', 'Martín', 'Peralta', '343-410007', 'medico8@centrosalud.com', '1977-08-12'),
    (1009, 'Medico', 'Carolina', 'Ferrer', '343-410008', 'medico9@centrosalud.com', '1978-09-12'),
    (1010, 'Medico', 'Pablo', 'Godoy', '343-410009', 'medico10@centrosalud.com', '1979-10-12'),
    (1011, 'Medico', 'Verónica', 'Cáceres', '343-410010', 'medico11@centrosalud.com', '1980-11-12'),
    (1012, 'Medico', 'Andrés', 'Arias', '343-410011', 'medico12@centrosalud.com', '1981-12-12'),
    (1013, 'Medico', 'Gabriela', 'Mansilla', '343-410012', 'medico13@centrosalud.com', '1982-01-12'),
    (1014, 'Medico', 'Ricardo', 'Ponce', '343-410013', 'medico14@centrosalud.com', '1983-02-12'),
    (1015, 'Medico', 'Natalia', 'Leiva', '343-410014', 'medico15@centrosalud.com', '1984-03-12'),
    (2001, 'Enfermero', 'Elena', 'Duarte', '343-420000', 'enfermero1@centrosalud.com', '1975-01-18'),
    (2002, 'Enfermero', 'Miguel', 'Benítez', '343-420001', 'enfermero2@centrosalud.com', '1976-02-18'),
    (2003, 'Enfermero', 'Rocío', 'Alem', '343-420002', 'enfermero3@centrosalud.com', '1977-03-18'),
    (2004, 'Enfermero', 'Pablo', 'Vázquez', '343-420003', 'enfermero4@centrosalud.com', '1978-04-18'),
    (2005, 'Enfermero', 'Silvia', 'Roldán', '343-420004', 'enfermero5@centrosalud.com', '1979-05-18'),
    (2006, 'Enfermero', 'Hernán', 'Iglesias', '343-420005', 'enfermero6@centrosalud.com', '1980-06-18'),
    (2007, 'Enfermero', 'Lorena', 'Franco', '343-420006', 'enfermero7@centrosalud.com', '1981-07-18'),
    (2008, 'Enfermero', 'Esteban', 'Márquez', '343-420007', 'enfermero8@centrosalud.com', '1982-08-18'),
    (2009, 'Enfermero', 'Cecilia', 'Córdoba', '343-420008', 'enfermero9@centrosalud.com', '1983-09-18'),
    (2010, 'Enfermero', 'Ramiro', 'Acuña', '343-420009', 'enfermero10@centrosalud.com', '1984-10-18'),
    (2011, 'Enfermero', 'Noelia', 'Bravo', '343-420010', 'enfermero11@centrosalud.com', '1985-11-18'),
    (2012, 'Enfermero', 'Gustavo', 'Ojeda', '343-420011', 'enfermero12@centrosalud.com', '1986-12-18'),
    (2013, 'Enfermero', 'Marina', 'Ferreyra', '343-420012', 'enfermero13@centrosalud.com', '1987-01-18'),
    (2014, 'Enfermero', 'Sergio', 'Maidana', '343-420013', 'enfermero14@centrosalud.com', '1988-02-18'),
    (2015, 'Enfermero', 'Carla', 'Correa', '343-420014', 'enfermero15@centrosalud.com', '1989-03-18');


-- proveedor_especializacion: 30 registros
INSERT INTO proveedor_especializacion (nro_matricula, id_especializacion) VALUES
    (1001, 1),
    (1002, 1),
    (1003, 1),
    (1004, 1),
    (1005, 1),
    (1006, 2),
    (1007, 3),
    (1008, 4),
    (1009, 5),
    (1010, 6),
    (1011, 7),
    (1012, 8),
    (1013, 9),
    (1014, 10),
    (1015, 11),
    (2001, 1),
    (2002, 1),
    (2003, 1),
    (2004, 1),
    (2005, 1),
    (2006, 2),
    (2007, 3),
    (2008, 4),
    (2009, 5),
    (2010, 6),
    (2011, 7),
    (2012, 8),
    (2013, 9),
    (2014, 10),
    (2015, 11);


-- tipo_servicio: 15 registros
INSERT INTO tipo_servicio (id_tipo_servicio, nombre, cant_medicos_asist, cant_enferm_asist, id_especializacion_requerida, es_internacion) VALUES
    (1, 'Internación', 0, 1, 1, TRUE),
    (2, 'Cardiología', 0, 1, 2, FALSE),
    (3, 'Pediatría', 0, 1, 3, FALSE),
    (4, 'Medicina general', 0, 1, 4, FALSE),
    (5, 'Traumatología', 0, 1, 5, FALSE),
    (6, 'Dermatología', 0, 1, 6, FALSE),
    (7, 'Ginecología', 0, 1, 7, FALSE),
    (8, 'Neurología', 0, 1, 8, FALSE),
    (9, 'Oftalmología', 0, 1, 9, FALSE),
    (10, 'Odontología', 0, 1, 10, FALSE),
    (11, 'Kinesiología', 0, 1, 11, FALSE),
    (12, 'Laboratorio', 0, 1, 12, FALSE),
    (13, 'Diagnóstico por imágenes', 0, 1, 13, FALSE),
    (14, 'Salud mental', 0, 1, 14, FALSE),
    (15, 'Vacunación', 0, 1, 15, FALSE);


-- servicio: 15 registros
INSERT INTO servicio (id_servicio, id_centro, id_tipo_servicio, medico_a_cargo_matricula) VALUES
    (1, 1, 1, 1001),
    (2, 2, 1, 1002),
    (3, 3, 1, 1003),
    (4, 4, 1, 1004),
    (5, 5, 1, 1005),
    (6, 6, 2, 1006),
    (7, 7, 3, 1007),
    (8, 8, 4, 1008),
    (9, 9, 5, 1009),
    (10, 10, 6, 1010),
    (11, 11, 7, 1011),
    (12, 12, 8, 1012),
    (13, 13, 9, 1013),
    (14, 14, 10, 1014),
    (15, 15, 11, 1015);


-- horarioservicio: 15 registros
INSERT INTO horarioservicio (id_horario_servicio, dia, horario_apertura, horario_cierre, id_servicio) VALUES
    (1, 'Lunes', '08:00:00', '18:00:00', 1),
    (2, 'Martes', '08:00:00', '18:00:00', 2),
    (3, 'Miercoles', '08:00:00', '18:00:00', 3),
    (4, 'Jueves', '08:00:00', '18:00:00', 4),
    (5, 'Viernes', '08:00:00', '18:00:00', 5),
    (6, 'Sabado', '08:00:00', '18:00:00', 6),
    (7, 'Lunes', '08:00:00', '18:00:00', 7),
    (8, 'Martes', '08:00:00', '18:00:00', 8),
    (9, 'Miercoles', '08:00:00', '18:00:00', 9),
    (10, 'Jueves', '08:00:00', '18:00:00', 10),
    (11, 'Viernes', '08:00:00', '18:00:00', 11),
    (12, 'Sabado', '08:00:00', '18:00:00', 12),
    (13, 'Lunes', '08:00:00', '18:00:00', 13),
    (14, 'Martes', '08:00:00', '18:00:00', 14),
    (15, 'Miercoles', '08:00:00', '18:00:00', 15);


-- asignacionservicio: 15 registros
INSERT INTO asignacionservicio (id_servicio, nro_matricula, rol) VALUES
    (1, 2001, 'Enfermero_Asistente'),
    (2, 2002, 'Enfermero_Asistente'),
    (3, 2003, 'Enfermero_Asistente'),
    (4, 2004, 'Enfermero_Asistente'),
    (5, 2005, 'Enfermero_Asistente'),
    (6, 2006, 'Enfermero_Asistente'),
    (7, 2007, 'Enfermero_Asistente'),
    (8, 2008, 'Enfermero_Asistente'),
    (9, 2009, 'Enfermero_Asistente'),
    (10, 2010, 'Enfermero_Asistente'),
    (11, 2011, 'Enfermero_Asistente'),
    (12, 2012, 'Enfermero_Asistente'),
    (13, 2013, 'Enfermero_Asistente'),
    (14, 2014, 'Enfermero_Asistente'),
    (15, 2015, 'Enfermero_Asistente');


-- historiaclinica: 60 registros
INSERT INTO historiaclinica (id_historia_clinica, dia_visita, diagnostico, tratamiento, paciente_dni, id_servicio, medico_matricula) VALUES
    (1, '2026-11-01', 'Neumonía adquirida en la comunidad', 'Tratamiento farmacológico y control en 48 horas', 30000001, 1, 1001),
    (2, '2026-11-02', 'Hipertensión arterial', 'Control de presión y seguimiento mensual', 30000002, 2, 1002),
    (3, '2026-11-03', 'Control clínico anual', 'Indicaciones preventivas y nuevo control', 30000003, 3, 1003),
    (4, '2026-11-04', 'Diabetes mellitus tipo 2', 'Plan alimentario y medicación indicada', 30000004, 4, 1004),
    (5, '2026-11-05', 'Fractura de radio', 'Inmovilización y control traumatológico', 30000005, 5, 1005),
    (6, '2026-11-06', 'Dermatitis alérgica', 'Tratamiento tópico y seguimiento', 30000006, 1, 1001),
    (7, '2026-11-07', 'Control ginecológico', 'Estudios complementarios y control', 30000007, 2, 1002),
    (8, '2026-11-08', 'Migraña', 'Analgesia y pautas de alarma', 30000008, 3, 1003),
    (9, '2026-11-09', 'Conjuntivitis', 'Colirio y control evolutivo', 30000009, 4, 1004),
    (10, '2026-11-10', 'Caries dental', 'Tratamiento odontológico indicado', 30000010, 5, 1005),
    (11, '2026-11-11', 'Lumbalgia', 'Fisioterapia y reposo relativo', 30000011, 1, 1001),
    (12, '2026-11-12', 'Anemia ferropénica', 'Suplementación y control hematológico', 30000012, 2, 1002),
    (13, '2026-11-13', 'Esguince de tobillo', 'Reposo, hielo y evaluación posterior', 30000013, 3, 1003),
    (14, '2026-11-14', 'Ansiedad', 'Seguimiento psicológico y pautas de cuidado', 30000014, 4, 1004),
    (15, '2026-11-15', 'Control de vacunación', 'Esquema de vacunación actualizado', 30000015, 5, 1005),
    (16, '2026-10-20', 'Infección urinaria', 'Tratamiento farmacológico y control en 48 horas', 30000016, 1, 1001),
    (17, '2026-10-21', 'Gastroenteritis aguda', 'Control de presión y seguimiento mensual', 30000017, 2, 1002),
    (18, '2026-10-22', 'Asma persistente', 'Indicaciones preventivas y nuevo control', 30000018, 3, 1003),
    (19, '2026-10-23', 'Bronquitis aguda', 'Plan alimentario y medicación indicada', 30000019, 4, 1004),
    (20, '2026-10-24', 'Dolor abdominal', 'Inmovilización y control traumatológico', 30000020, 5, 1005),
    (21, '2026-10-25', 'Otitis media', 'Tratamiento tópico y seguimiento', 30000021, 1, 1001),
    (22, '2026-10-26', 'Hipotiroidismo', 'Estudios complementarios y control', 30000022, 2, 1002),
    (23, '2026-10-27', 'Artritis', 'Analgesia y pautas de alarma', 30000023, 3, 1003),
    (24, '2026-10-28', 'Rinitis alérgica', 'Colirio y control evolutivo', 30000024, 4, 1004),
    (25, '2026-10-29', 'Cefalea tensional', 'Tratamiento odontológico indicado', 30000025, 5, 1005),
    (26, '2026-10-30', 'Dislipidemia', 'Fisioterapia y reposo relativo', 30000026, 1, 1001),
    (27, '2026-10-31', 'Faringitis', 'Suplementación y control hematológico', 30000027, 2, 1002),
    (28, '2026-11-01', 'Contractura muscular', 'Reposo, hielo y evaluación posterior', 30000028, 3, 1003),
    (29, '2026-11-02', 'Control pediátrico', 'Seguimiento psicológico y pautas de cuidado', 30000029, 4, 1004),
    (30, '2026-11-03', 'Evaluación nutricional', 'Esquema de vacunación actualizado', 30000030, 5, 1005),
    (31, '2026-11-01', 'Migraña', 'Tratamiento tópico y seguimiento', 30000001, 6, 1006),
    (32, '2026-11-02', 'Conjuntivitis', 'Estudios complementarios y control', 30000002, 7, 1007),
    (33, '2026-11-03', 'Caries dental', 'Analgesia y pautas de alarma', 30000003, 8, 1008),
    (34, '2026-11-04', 'Lumbalgia', 'Colirio y control evolutivo', 30000004, 9, 1009),
    (35, '2026-11-05', 'Anemia ferropénica', 'Tratamiento odontológico indicado', 30000005, 10, 1010),
    (36, '2026-11-06', 'Esguince de tobillo', 'Fisioterapia y reposo relativo', 30000006, 11, 1011),
    (37, '2026-11-07', 'Ansiedad', 'Suplementación y control hematológico', 30000007, 12, 1012),
    (38, '2026-11-08', 'Control de vacunación', 'Reposo, hielo y evaluación posterior', 30000008, 13, 1013),
    (39, '2026-11-09', 'Infección urinaria', 'Seguimiento psicológico y pautas de cuidado', 30000009, 14, 1014),
    (40, '2026-11-10', 'Gastroenteritis aguda', 'Esquema de vacunación actualizado', 30000010, 15, 1015),
    (41, '2026-11-11', 'Asma persistente', 'Tratamiento farmacológico y control en 48 horas', 30000011, 6, 1006),
    (42, '2026-11-12', 'Bronquitis aguda', 'Control de presión y seguimiento mensual', 30000012, 7, 1007),
    (43, '2026-11-13', 'Dolor abdominal', 'Indicaciones preventivas y nuevo control', 30000013, 8, 1008),
    (44, '2026-11-14', 'Otitis media', 'Plan alimentario y medicación indicada', 30000014, 9, 1009),
    (45, '2026-11-15', 'Hipotiroidismo', 'Inmovilización y control traumatológico', 30000015, 10, 1010),
    (46, '2026-11-16', 'Artritis', 'Tratamiento tópico y seguimiento', 30000016, 11, 1011),
    (47, '2026-11-01', 'Rinitis alérgica', 'Estudios complementarios y control', 30000017, 12, 1012),
    (48, '2026-11-02', 'Cefalea tensional', 'Analgesia y pautas de alarma', 30000018, 13, 1013),
    (49, '2026-11-03', 'Dislipidemia', 'Colirio y control evolutivo', 30000019, 14, 1014),
    (50, '2026-11-04', 'Faringitis', 'Tratamiento odontológico indicado', 30000020, 15, 1015),
    (51, '2026-11-05', 'Contractura muscular', 'Fisioterapia y reposo relativo', 30000021, 6, 1006),
    (52, '2026-11-06', 'Control pediátrico', 'Suplementación y control hematológico', 30000022, 7, 1007),
    (53, '2026-11-07', 'Evaluación nutricional', 'Reposo, hielo y evaluación posterior', 30000023, 8, 1008),
    (54, '2026-11-08', 'Neumonía adquirida en la comunidad', 'Seguimiento psicológico y pautas de cuidado', 30000024, 9, 1009),
    (55, '2026-11-09', 'Hipertensión arterial', 'Esquema de vacunación actualizado', 30000025, 10, 1010),
    (56, '2026-11-10', 'Control clínico anual', 'Tratamiento farmacológico y control en 48 horas', 30000026, 11, 1011),
    (57, '2026-11-11', 'Diabetes mellitus tipo 2', 'Control de presión y seguimiento mensual', 30000027, 12, 1012),
    (58, '2026-11-12', 'Fractura de radio', 'Indicaciones preventivas y nuevo control', 30000028, 13, 1013),
    (59, '2026-11-13', 'Dermatitis alérgica', 'Plan alimentario y medicación indicada', 30000029, 14, 1014),
    (60, '2026-11-14', 'Control ginecológico', 'Inmovilización y control traumatológico', 30000030, 15, 1015);


-- internacion: 30 registros
INSERT INTO internacion (id_internacion, fecha_ingreso, fecha_egreso, id_historia_clinica) VALUES
    (1, '2026-11-01', NULL, 1),
    (2, '2026-11-02', NULL, 2),
    (3, '2026-11-03', NULL, 3),
    (4, '2026-11-04', NULL, 4),
    (5, '2026-11-05', NULL, 5),
    (6, '2026-11-06', NULL, 6),
    (7, '2026-11-07', NULL, 7),
    (8, '2026-11-08', NULL, 8),
    (9, '2026-11-09', NULL, 9),
    (10, '2026-11-10', NULL, 10),
    (11, '2026-11-11', NULL, 11),
    (12, '2026-11-12', NULL, 12),
    (13, '2026-11-13', NULL, 13),
    (14, '2026-11-14', NULL, 14),
    (15, '2026-11-15', NULL, 15),
    (16, '2026-10-20', '2026-10-23', 16),
    (17, '2026-10-21', '2026-10-24', 17),
    (18, '2026-10-22', '2026-10-25', 18),
    (19, '2026-10-23', '2026-10-26', 19),
    (20, '2026-10-24', '2026-10-27', 20),
    (21, '2026-10-25', '2026-10-28', 21),
    (22, '2026-10-26', '2026-10-29', 22),
    (23, '2026-10-27', '2026-10-30', 23),
    (24, '2026-10-28', '2026-10-31', 24),
    (25, '2026-10-29', '2026-11-01', 25),
    (26, '2026-10-30', '2026-11-02', 26),
    (27, '2026-10-31', '2026-11-03', 27),
    (28, '2026-11-01', '2026-11-04', 28),
    (29, '2026-11-02', '2026-11-05', 29),
    (30, '2026-11-03', '2026-11-06', 30);

COMMIT;
