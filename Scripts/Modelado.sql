CREATE DATABASE cine;
USE cine;
-- Tabla Clientes
CREATE TABLE Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(15),
    DNI_ID VARCHAR(20) UNIQUE NOT NULL,
    Contraseña VARCHAR(255) NOT NULL
);

-- Tabla Películas
CREATE TABLE Peliculas (
    PeliculaID INT AUTO_INCREMENT PRIMARY KEY,
    Titulo VARCHAR(200) NOT NULL,
    Genero VARCHAR(100) NOT NULL,
    Duracion INT NOT NULL,
    Clasificacion VARCHAR(50) NOT NULL,
    FechaEstreno DATE NOT NULL
);

-- Tabla Funciones
CREATE TABLE Funciones (
    FuncionID INT AUTO_INCREMENT PRIMARY KEY,
    PeliculaID INT,
    Sala VARCHAR(50) NOT NULL,
    FechaHora DATETIME NOT NULL,
    AsientosDisponibles INT NOT NULL,
    FOREIGN KEY (PeliculaID) REFERENCES Peliculas(PeliculaID) ON DELETE CASCADE
);

-- Tabla Boletos
CREATE TABLE Boletos (
    BoletoID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT,
    FuncionID INT,
    AsientosReservados INT NOT NULL,
    PrecioTotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) ON DELETE CASCADE,
    FOREIGN KEY (FuncionID) REFERENCES Funciones(FuncionID) ON DELETE CASCADE
);

-- Tabla Pagos
CREATE TABLE Pagos (
    PagoID INT AUTO_INCREMENT PRIMARY KEY,
    BoletoID INT,
    MetodoPago ENUM('Tarjeta', 'PayPal', 'Efectivo') NOT NULL,
    FechaPago DATETIME DEFAULT CURRENT_TIMESTAMP,
    Monto DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (BoletoID) REFERENCES Boletos(BoletoID) ON DELETE CASCADE
);

-- Restricciones de integridad referencial
ALTER TABLE Funciones
ADD CONSTRAINT fk_pelicula
FOREIGN KEY (PeliculaID) REFERENCES Peliculas(PeliculaID)
ON DELETE CASCADE
ON UPDATE CASCADE;



ALTER TABLE Boletos
ADD CONSTRAINT fk_cliente
FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Boletos
ADD CONSTRAINT fk_funcion
FOREIGN KEY (FuncionID) REFERENCES Funciones(FuncionID)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Pagos
ADD CONSTRAINT fk_boleto
FOREIGN KEY (BoletoID) REFERENCES Boletos(BoletoID)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Crear roles
CREATE ROLE 'AdminCine', 'Usuario', 'Auditor';
-- Asignar permisos al rol Administrador
GRANT ALL PRIVILEGES ON cine.* TO 'AdminCine';
-- Asignar permisos al rol Usuario
GRANT SELECT, INSERT, UPDATE ON cine.Boletos TO 'Usuario';
GRANT SELECT ON cine.Funciones TO 'Usuario';
-- Asignar permisos al rol Auditor
GRANT SELECT ON cine.* TO 'Auditor';


ALTER TABLE Funciones
PARTITION BY RANGE (YEAR(FechaHora)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);

-- Cifrar contraseñas usando AES_ENCRYPT
SET SQL_SAFE_UPDATES = 0; -- Desactivar Modo Seguro
UPDATE Clientes
SET Contraseña = AES_ENCRYPT('contraseña_segura', 'clave_secreta');
SET SQL_SAFE_UPDATES = 1; -- Vuelve a activarlo para evitar errores en el futuro.


-- Habilitar logs de auditoría
SET GLOBAL log_output = 'FILE';
SET GLOBAL general_log = 'ON';