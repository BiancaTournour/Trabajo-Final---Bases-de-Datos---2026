``` mermaid
classDiagram
    direction TB

    class tipoprofesional {
        <<enumeration>>
        medico
        enfermero
    }

    class Dias {
        <<enumeration>>
        LUNES
        MARTES
        MIERCOLES
        JUEVES
        VIERNES
        SABADO
        DOMINGO
    }

    class RolAsignacion {
        <<enumeration>>
        MEDICO_ASISTENTE
        ENFERMERO_ASISTENTE
    }

    class Centro {
        +ID: Int PK
        +nombre: VARCHAR
        +dirección: VARCHAR
        +fecha_inaguracion: Date
    }

    class Proveedor {
        +nro_matricula: Int PK
        +tipo_profesional: tipoprofesional
        +nombre: VARCHAR
        +apellido: VARCHAR
        +telefono: VARCHAR
        +email: VARCHAR
        +fechaNac: Date
    }

    class Servicio {
        +ID: Int PK
    }

    class Tipo_Servicio {
        +id: Int PK
        +nombre: VARCHAR
        +cant_Medicos_Asist: Int
        +cant_Enferm_Asist: Int
    }

    class Internacion {
        +ID: Int PK
        +FechaIngreso: Date
        +FechaEgreso: Date
    }

    class Paciente {
        +DNI: Int PK
        +nombre: VARCHAR
        +apellido: VARCHAR
        +domicilio: VARCHAR
        +fechaNac: Date
        +nro_afiliado: Int
    }

    class HistoriaClinica {
        +ID: Int PK
        +dia_visita: Date
        +diagnostico: Text
        +tratamiento: Text
    }

    class Obra_Social {
        +ID: Int PK
        +nombre: VARCHAR
    }

    class Provincia {
        +ID: Int PK
        +nombre: VARCHAR
    }

    class Departamento {
        +ID: Int PK
        +nombre: VARCHAR
    }

    class Ciudad {
        +ID: Int PK
        +codigo_postal: Int
        +nombre: VARCHAR
    }

    class Barrio {
        +ID: Int PK
        +nombre: VARCHAR
    }

    class HorarioCentro {
        +ID: Int PK
        +dia: Dias
        +horario_apertura: Time
        +horario_cierre: Time
    }

    class HorarioServicio {
        +ID: Int PK
        +dia: Dias
        +horario_apertura: Time
        +horario_cierre: Time
    }

    class AsignacionServicio {
        +ID: Int PK
        +rol: RolAsignacion
    }

    class Especializacion {
        +ID: Int PK
        +nombre: VARCHAR
    }

    class Proveedor_Especializacion {
        +ID: Int PK
    }

    Provincia "1" -- "*" Departamento
    Departamento "1" -- "*" Ciudad
    Ciudad "1" -- "*" Barrio

    Especializacion "1" -- "0..*" Tipo_Servicio
    Obra_Social "0..1" -- "*" Paciente

    Barrio "1" -- "*" Centro
    Barrio "1" -- "0..*" Paciente

    Centro "1" -- "*" HorarioCentro
    Tipo_Servicio "1" -- "*" Servicio

    Proveedor "1" -- "0..*" Servicio : A cargo de
    Proveedor "1" -- "0..*" Proveedor_Especializacion
    Especializacion "1" -- "*" Proveedor_Especializacion

    Servicio "1" -- "*" HorarioServicio
    Centro "1" -- "*" Servicio

    Paciente "1" -- "*" HistoriaClinica
    HistoriaClinica "1" -- "0..1" Internacion
    Servicio "1" -- "*" HistoriaClinica
    Proveedor "1" -- "*" HistoriaClinica

    Servicio "1" -- "*" AsignacionServicio
    Proveedor "1" -- "*" AsignacionServicio
```
