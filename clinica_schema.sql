-- ------------------------------------------------------------
-- Base de datos: clinica
-- Motor: MariaDB/MySQL 10+  |  Juego de caracteres: utf8mb4
-- Este script crea el esquema del diagrama y carga datos mínimos.
-- ------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS clinica
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinica;

-- -------------------- Catálogos (tablas maestras) --------------------
CREATE TABLE IF NOT EXISTS sexo (
  id_sexo TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS estado_civil (
  id_civil TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profesion (
  id_profesion SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS turno (
  id_turno TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Se usa para estados generales (cuentas, citas, etc.)
CREATE TABLE IF NOT EXISTS estado (
  id_estado TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS servicio (
  id_servicio SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS consultorio (
  id_consultorio SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS especialidad (
  id_especialidad SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS enfermedad (
  id_enfermedad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- -------------------- Entidades principales --------------------
CREATE TABLE IF NOT EXISTS cliente (
  id_cliente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  apellido VARCHAR(60) NOT NULL,
  telefono VARCHAR(30),
  direccion VARCHAR(150),
  saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  nit VARCHAR(20),
  razon_social VARCHAR(120),
  nr_emergencia VARCHAR(30),
  nombre_emergencia VARCHAR(100),
  id_sexo TINYINT UNSIGNED,
  id_civil TINYINT UNSIGNED,
  CONSTRAINT fk_cliente_sexo FOREIGN KEY (id_sexo) REFERENCES sexo(id_sexo),
  CONSTRAINT fk_cliente_civil FOREIGN KEY (id_civil) REFERENCES estado_civil(id_civil),
  INDEX idx_cliente_nombre (apellido, nombre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS empleado (
  id_empleado INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  apellidos VARCHAR(60) NOT NULL,
  telefono VARCHAR(30),
  direccion VARCHAR(150),
  fecha_contratacion DATE NOT NULL,
  id_profesion SMALLINT UNSIGNED,
  id_turno TINYINT UNSIGNED,
  id_sexo TINYINT UNSIGNED,
  id_civil TINYINT UNSIGNED,
  CONSTRAINT fk_empleado_profesion FOREIGN KEY (id_profesion) REFERENCES profesion(id_profesion),
  CONSTRAINT fk_empleado_turno FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
  CONSTRAINT fk_empleado_sexo FOREIGN KEY (id_sexo) REFERENCES sexo(id_sexo),
  CONSTRAINT fk_empleado_civil FOREIGN KEY (id_civil) REFERENCES estado_civil(id_civil)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medico (
  id_medico INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT UNSIGNED NOT NULL UNIQUE,
  id_especialidad SMALLINT UNSIGNED,
  id_profesion SMALLINT UNSIGNED,
  id_turno TINYINT UNSIGNED,
  matricula_medico VARCHAR(50) NOT NULL,
  CONSTRAINT fk_medico_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad),
  CONSTRAINT fk_medico_profesion FOREIGN KEY (id_profesion) REFERENCES profesion(id_profesion),
  CONSTRAINT fk_medico_turno FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
) ENGINE=InnoDB;

-- Usuarios del sistema (empleados) para login
CREATE TABLE IF NOT EXISTS login (
  id_login INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,  -- usar password_hash() de PHP (bcrypt)
  email VARCHAR(120) UNIQUE,
  id_empleado INT UNSIGNED NOT NULL,
  id_estado TINYINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login DATETIME NULL,
  CONSTRAINT fk_login_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  CONSTRAINT fk_login_estado FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ficha (
  id_ficha INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT UNSIGNED NOT NULL,
  id_enfermedad INT UNSIGNED,
  fecha_atencion DATE,
  antecedentes_med TEXT,
  observaciones TEXT,
  CONSTRAINT fk_ficha_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_ficha_enfermedad FOREIGN KEY (id_enfermedad) REFERENCES enfermedad(id_enfermedad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cita (
  id_cita INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  id_cliente INT UNSIGNED NOT NULL,
  id_medico INT UNSIGNED NOT NULL,
  id_estado TINYINT UNSIGNED NOT NULL, -- pendiente/confirmada/cancelada
  motivo VARCHAR(200),
  observaciones TEXT,
  id_servicio SMALLINT UNSIGNED,
  id_consultorio SMALLINT UNSIGNED,
  CONSTRAINT fk_cita_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
  CONSTRAINT fk_cita_estado FOREIGN KEY (id_estado) REFERENCES estado(id_estado),
  CONSTRAINT fk_cita_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
  CONSTRAINT fk_cita_consultorio FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
  INDEX idx_cita_fecha (fecha, hora)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS atencion (
  id_atencion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cita INT UNSIGNED NOT NULL,
  id_ficha INT UNSIGNED NOT NULL,
  tratamiento TEXT,
  diagnostico TEXT,
  fecha_atencion DATETIME NOT NULL,
  observaciones TEXT,
  id_medico INT UNSIGNED NOT NULL,
  CONSTRAINT fk_atencion_cita FOREIGN KEY (id_cita) REFERENCES cita(id_cita),
  CONSTRAINT fk_atencion_ficha FOREIGN KEY (id_ficha) REFERENCES ficha(id_ficha),
  CONSTRAINT fk_atencion_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
) ENGINE=InnoDB;

-- -------------------- Datos mínimos --------------------
INSERT IGNORE INTO sexo (detalle) VALUES ('Femenino'), ('Masculino'), ('Otro');
INSERT IGNORE INTO estado_civil (detalle) VALUES ('Soltero/a'), ('Casado/a'), ('Divorciado/a'), ('Viudo/a');
INSERT IGNORE INTO profesion (detalle) VALUES ('Administrativo'), ('Médico'), ('Enfermería');
INSERT IGNORE INTO turno (detalle) VALUES ('Mañana'), ('Tarde'), ('Noche');
INSERT IGNORE INTO estado (detalle) VALUES ('Activo'), ('Inactivo'), ('Pendiente'), ('Confirmada'), ('Cancelada');
INSERT IGNORE INTO servicio (detalle) VALUES ('Consulta general'), ('Laboratorio'), ('Odontología');
INSERT IGNORE INTO consultorio (detalle) VALUES ('101'), ('102'), ('103');
INSERT IGNORE INTO especialidad (detalle) VALUES ('Medicina General'), ('Cardiología'), ('Pediatría');
INSERT IGNORE INTO enfermedad (detalle) VALUES ('No especificada'), ('Gripe'), ('COVID-19');

-- Empleado de ejemplo
INSERT INTO empleado (nombre, apellidos, telefono, direccion, fecha_contratacion, id_profesion, id_turno, id_sexo, id_civil)
VALUES ('Luciana', 'Sosa', '70000000', 'Av. Ejemplo 123', '2025-09-01', 1, 1, 1, 1);

-- Médico vinculado a ese empleado
INSERT INTO medico (id_empleado, id_especialidad, id_profesion, id_turno, matricula_medico)
VALUES (1, 1, 2, 1, 'MAT-001');

-- Cliente de ejemplo
INSERT INTO cliente (nombre, apellido, telefono, direccion, saldo, nit, razon_social, nr_emergencia, nombre_emergencia, id_sexo, id_civil)
VALUES ('Camila', 'Rojas', '70123456', 'Calle Falsa 123', 0, '1234567', 'Camila Rojas', '70999999', 'Mamá', 1, 1);

-- Ficha y cita de ejemplo
INSERT INTO ficha (id_cliente, id_enfermedad, fecha_atencion, antecedentes_med, observaciones)
VALUES (1, 1, '2025-09-09', 'Sin antecedentes', 'Primera visita');

INSERT INTO cita (fecha, hora, id_cliente, id_medico, id_estado, motivo, observaciones, id_servicio, id_consultorio)
VALUES ('2025-09-10', '09:30:00', 1, 1, 3, 'Chequeo general', '—', 1, 1);

-- Usuario de login de ejemplo (PASSWORD EN TEXTO PLANO SOLO PARA PRUEBA)
-- Cambia a bcrypt con PHP cuanto antes (ver archivos PHP incluidos).
INSERT INTO login (usuario, password_hash, email, id_empleado, id_estado)
VALUES ('admin', 'admin123', 'admin@clinica.test', 1, 1);