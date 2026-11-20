-- Creación de roles y permisos

-- 1. CREACIÓN DE ROLES

CREATE ROLE rol_admin;
CREATE ROLE rol_medico;
CREATE ROLE rol_administrativo;
CREATE ROLE rol_auditor;


-- 2. CREACIÓN DE USUARIOS

CREATE USER usr_admin_db WITH PASSWORD 'admin123';
CREATE USER usr_medico WITH PASSWORD 'medico123';
CREATE USER usr_recepcion WITH PASSWORD 'recepcion123';
CREATE USER usr_auditoria WITH PASSWORD 'auditoria123';


-- 3. ASIGNACIÓN DE ROLES A USUARIOS

GRANT rol_admin TO usr_admin_db;
GRANT rol_medico TO usr_medico;
GRANT rol_administrativo TO usr_recepcion;
GRANT rol_auditor TO usr_auditoria;


-- 4. PERMISOS SOBRE LA BASE DE DATOS

-- Permisos administrativos
GRANT ALL PRIVILEGES ON DATABASE "Centro-de-Salud"
TO rol_admin;

-- Permiso de conexión para los demás perfiles
GRANT CONNECT ON DATABASE "Centro-de-Salud"
TO rol_medico, rol_administrativo, rol_auditor;


-- 5. PERMISOS SOBRE EL ESQUEMA

-- El administrador puede crear objetos en el esquema
GRANT ALL PRIVILEGES ON SCHEMA public
TO rol_admin;

-- Los demás perfiles pueden acceder al esquema
GRANT USAGE ON SCHEMA public
TO rol_medico, rol_administrativo, rol_auditor;


-- 6. B.1. ADMINISTRADOR DE BASE DE DATOS

-- Permisos sobre todas las tablas existentes
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
TO rol_admin;

-- Permisos sobre todas las secuencias existentes
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
TO rol_admin;

-- Ejecución de funciones y procedimientos
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public
TO rol_admin;

GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public
TO rol_admin;

-- Administración de los tipos enumerados
GRANT USAGE ON TYPE dias, tipoprofesional, rolasignacion
TO rol_admin;


-- 7. B.2. PERSONAL MÉDICO

-- Consulta y modificación de pacientes
GRANT SELECT, INSERT, UPDATE
ON TABLE paciente
TO rol_medico;

-- Consulta y modificación de historias clínicas
GRANT SELECT, INSERT, UPDATE
ON TABLE historiaclinica
TO rol_medico;

-- Consulta de información de centros y servicios
GRANT SELECT
ON TABLE centro, servicio, tipo_servicio, horarioservicio
TO rol_medico;

-- Ejecución de la función:
-- FN_Centros_Abiertos_Por_Servicio
GRANT EXECUTE
ON FUNCTION fn_centros_abiertos_por_servicio(INTEGER)
TO rol_medico;

-- Ejecución del procedimiento:
-- SP_Registrar_Alta_Paciente
GRANT EXECUTE
ON PROCEDURE sp_registrar_alta_paciente(INTEGER, DATE)
TO rol_medico;

-- Permiso de utilización del tipo enumerado
-- utilizado por la función de consulta de horarios
GRANT USAGE ON TYPE dias
TO rol_medico;

 
-- 8. B.3. PERSONAL ADMINISTRATIVO / RECEPCIÓN

-- Consulta y modificación de pacientes
GRANT SELECT, INSERT, UPDATE
ON TABLE paciente
TO rol_administrativo;

-- Consulta y modificación de internaciones
GRANT SELECT, INSERT, UPDATE
ON TABLE internacion
TO rol_administrativo;

-- Consulta de información geográfica
GRANT SELECT
ON TABLE barrio, ciudad
TO rol_administrativo;

-- Consulta de centros y servicios
GRANT SELECT
ON TABLE centro, servicio, horarioservicio
TO rol_administrativo;

-- Consulta de vistas autorizadas
GRANT SELECT
ON TABLE vista_pacientes_internados_actuales,
          vista_oferta_servicios_centro
TO rol_administrativo;


-- 9. B.4. AUDITOR / ANALISTA ESTADÍSTICO

-- Acceso de lectura exclusivamente a las vistas autorizadas
GRANT SELECT
ON TABLE vista_pacientes_internados_actuales,
          vista_oferta_servicios_centro
TO rol_auditor;


-- 10. SEGURIDAD DE FUNCIONES Y PROCEDIMIENTOS

-- Se revoca el permiso de ejecución pública por defecto.
-- De esta manera, las rutinas solamente podrán ejecutarse
-- mediante los permisos concedidos explícitamente.

REVOKE ALL
ON FUNCTION fn_centros_abiertos_por_servicio(INTEGER)
FROM PUBLIC;

REVOKE ALL
ON PROCEDURE sp_registrar_alta_paciente(INTEGER, DATE)
FROM PUBLIC;

-- Se vuelve a garantizar el acceso administrativo
GRANT EXECUTE
ON FUNCTION fn_centros_abiertos_por_servicio(INTEGER)
TO rol_admin;

GRANT EXECUTE
ON PROCEDURE sp_registrar_alta_paciente(INTEGER, DATE)
TO rol_admin;


-- 11. PERMISOS PARA OBJETOS FUTUROS

-- IMPORTANTE:
-- Los objetos nuevos deberán crearse utilizando SET ROLE rol_admin.
-- Estos permisos por defecto se aplican a los objetos creados
-- por rol_admin, no a los creados por otros propietarios.

-- Administrador
ALTER DEFAULT PRIVILEGES FOR ROLE rol_admin
IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO rol_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE rol_admin
IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO rol_admin;

-- Personal médico
ALTER DEFAULT PRIVILEGES FOR ROLE rol_admin
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE ON TABLES TO rol_medico;

-- Personal administrativo
ALTER DEFAULT PRIVILEGES FOR ROLE rol_admin
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE ON TABLES TO rol_administrativo;

-- 12. PROPIEDAD DE LOS OBJETOS
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT c.relname, c.relkind
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind IN ('r', 'v')
    LOOP
        EXECUTE format('ALTER %s %I OWNER TO rol_admin',
                       CASE r.relkind WHEN 'v' THEN 'VIEW' ELSE 'TABLE' END, r.relname);
    END LOOP;

    FOR r IN
        SELECT p.oid::regprocedure AS firma, p.prokind
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
    LOOP
        EXECUTE format('ALTER %s %s OWNER TO rol_admin',
                       CASE r.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END, r.firma);
    END LOOP;
END $$;

ALTER TYPE dias OWNER TO rol_admin;
ALTER TYPE tipoprofesional OWNER TO rol_admin;
ALTER TYPE rolasignacion OWNER TO rol_admin;