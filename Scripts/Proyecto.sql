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


-- Tabla para almacenar los cambios de la base de datos y usarla para respaldos incrementales.
CREATE TABLE RegistroCambios (
    CambioID INT AUTO_INCREMENT PRIMARY KEY,
    TablaAfectada VARCHAR(50) NOT NULL,
    IDRegistro INT NOT NULL,
    TipoCambio ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    FechaCambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Triggers para registrar los cambios que se hacen en cada tabla 
-- Clientes

CREATE TRIGGER after_insert_clientes
AFTER INSERT ON Clientes
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Clientes', NEW.ClienteID, 'INSERT');

CREATE TRIGGER after_update_clientes
AFTER UPDATE ON Clientes
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Clientes', NEW.ClienteID, 'UPDATE');

CREATE TRIGGER after_delete_clientes
AFTER DELETE ON Clientes
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Clientes', OLD.ClienteID, 'DELETE');

-- Peliculas
CREATE TRIGGER after_insert_peliculas
AFTER INSERT ON Peliculas
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Peliculas', NEW.PeliculaID, 'INSERT');

CREATE TRIGGER after_update_peliculas
AFTER UPDATE ON Peliculas
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Peliculas', NEW.PeliculaID, 'UPDATE'); 

CREATE TRIGGER after_delete_peliculas
AFTER DELETE ON Peliculas
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Peliculas', OLD.PeliculaID, 'DELETE');

-- Funciones
CREATE TRIGGER after_insert_funciones
AFTER INSERT ON Funciones
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Funciones', NEW.FuncionID, 'INSERT');

CREATE TRIGGER after_update_funciones
AFTER UPDATE ON Funciones
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Funciones', NEW.FuncionID, 'UPDATE');

CREATE TRIGGER after_delete_funciones
AFTER DELETE ON Funciones
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Funciones', OLD.FuncionID, 'DELETE');

-- Boletos
CREATE TRIGGER after_insert_boletos
AFTER INSERT ON Boletos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Boletos', NEW.BoletoID, 'INSERT');

CREATE TRIGGER after_update_boletos
AFTER UPDATE ON Boletos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Boletos', NEW.BoletoID, 'UPDATE');

CREATE TRIGGER after_delete_boletos
AFTER DELETE ON Boletos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Boletos', OLD.BoletoID, 'DELETE');

-- Pagos
CREATE TRIGGER after_insert_pagos
AFTER INSERT ON Pagos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Pagos', NEW.PagoID, 'INSERT');

CREATE TRIGGER after_update_pagos
AFTER UPDATE ON Pagos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Pagos', NEW.PagoID, 'UPDATE');

CREATE TRIGGER after_delete_pagos
AFTER DELETE ON Pagos
FOR EACH ROW
INSERT INTO RegistroCambios (TablaAfectada, IDRegistro, TipoCambio)
VALUES ('Pagos', OLD.PagoID, 'DELETE');


/*INDICES CREADOS*/
-- Crear índice en la columna ClienteID de la tabla Boletos
CREATE INDEX idx_clienteid ON Boletos(ClienteID);

-- Crear índice en la columna PeliculaID de la tabla Funciones
CREATE INDEX idx_peliculaid ON Funciones(PeliculaID);


-- Ejemplo de EXPLAIN
EXPLAIN
SELECT Clientes.Nombre, Funciones.PeliculaID, Boletos.AsientosReservados
FROM Clientes
JOIN Boletos ON Clientes.ClienteID = Boletos.ClienteID
JOIN Funciones ON Boletos.FuncionID = Funciones.FuncionID
WHERE Boletos.PrecioTotal > 100.00;

-- Practica: Aplicación de 3 join
EXPLAIN
SELECT Clientes.Nombre, Funciones.PeliculaID, Peliculas.Titulo, Boletos.AsientosReservados, Boletos.PrecioTotal
FROM Clientes
JOIN Boletos ON Clientes.ClienteID = Boletos.ClienteID
JOIN Funciones ON Boletos.FuncionID = Funciones.FuncionID
JOIN Peliculas ON Funciones.PeliculaID = Peliculas.PeliculaID
WHERE Boletos.PrecioTotal > 100.00;

-- Particionamiento de la tabla 
-- 1  Eliminar restricciones de claves foráneas
ALTER TABLE Funciones DROP FOREIGN KEY fk_pelicula;
-- 2 Crear el índice único 
CREATE UNIQUE INDEX idx_fechaHora ON Funciones (FechaHora);
-- 3 Particionar la tabla Funciones
ALTER TABLE Funciones
PARTITION BY RANGE (YEAR(FechaHora)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);
-- 4 Restaurar la clave foránea
ALTER TABLE Funciones
ADD CONSTRAINT fk_pelicula FOREIGN KEY (PeliculaID) 
REFERENCES Peliculas(PeliculaID) ON DELETE CASCADE;
-- 5 Verificar la partición
SELECT * 
FROM information_schema.partitions 
WHERE table_name = 'Funciones';
-- Consultar las filas de una partición específica
SELECT * 
FROM Funciones
WHERE YEAR(FechaHora) = 2023;


-- 5.1 Crear un procedimiento para calcular el precio total de una reserva
 
DELIMITER $$

CREATE PROCEDURE CalcularPrecioReserva(
    IN p_clienteID INT,
    IN p_funcionID INT,
    IN p_asientosReservados INT,
    OUT p_precioTotal DECIMAL(10, 2)
)
BEGIN
    DECLARE precioBase DECIMAL(10, 2);
    DECLARE descuento DECIMAL(10, 2) DEFAULT 0;
    DECLARE cargoAdicional DECIMAL(10, 2) DEFAULT 0;

    -- Obtenemos el precio base de la función
    SELECT 10.00 + (p_asientosReservados * 2.00) INTO precioBase
    FROM Funciones
    WHERE FuncionID = p_funcionID;

    -- Aplicar descuento si el cliente tiene un descuento
    IF MOD(p_clienteID, 2) = 0 THEN
        SET descuento = precioBase * 0.10;
    END IF;

    -- Aplicar cargos adicionales si el cliente opta por asientos VIP
    IF p_asientosReservados > 3 THEN
        SET cargoAdicional = p_asientosReservados * 1.50;  -- por asientos VIP
    END IF;

    -- Calcular el precio total
    SET p_precioTotal = precioBase - descuento + cargoAdicional;

END $$

DELIMITER ;


-- Ejercicio 1 --
-- Calcular el precio total para una reserva de 3 asientos con un descuento y un cargo adicional.
CALL CalcularPrecioReserva(1, 2, 3, @precioFinal);
SELECT @precioFinal;

-- Ejercicio 2 --
-- Calcular el precio total para una reserva sin descuento y sin cargo adicional:
CALL CalcularPrecioReserva(2, 3, 5, @precioFinal);
SELECT @precioFinal;  


-- 5.2	Crear vistas para simplificar consultas complejas.

-- Vista para obtener la lista de películas disponibles con sus funciones
CREATE VIEW Vista_Peliculas_Funciones AS
SELECT 
    p.PeliculaID, 
    p.Titulo, 
    p.Genero, 
    p.Duracion, 
    p.Clasificacion, 
    p.FechaEstreno, 
    f.FuncionID, 
    f.Sala, 
    f.FechaHora, 
    f.AsientosDisponibles
FROM Peliculas p
JOIN Funciones f ON p.PeliculaID = f.PeliculaID;

SELECT * FROM Vista_Peliculas_Funciones LIMIT 10;

-- Vista para obtener los boletos comprados por cada cliente
CREATE VIEW Vista_Boletos_Clientes AS
SELECT 
    c.ClienteID, 
    c.Nombre, 
    c.Apellido, 
    c.Email, 
    b.BoletoID, 
    f.FuncionID, 
    p.Titulo AS Pelicula, 
    f.Sala, 
    f.FechaHora, 
    b.AsientosReservados, 
    b.PrecioTotal
FROM Clientes c
JOIN Boletos b ON c.ClienteID = b.ClienteID
JOIN Funciones f ON b.FuncionID = f.FuncionID
JOIN Peliculas p ON f.PeliculaID = p.PeliculaID;

SELECT * FROM Vista_Boletos_Clientes LIMIT 10;


-- Vista para obtener el historial de pagos realizados por los clientes
CREATE VIEW Vista_Historial_Pagos AS
SELECT 
    p.PagoID, 
    c.Nombre, 
    c.Apellido, 
    c.Email, 
    b.BoletoID, 
    pel.Titulo AS Pelicula, 
    f.FechaHora, 
    p.MetodoPago, 
    p.FechaPago, 
    p.Monto
FROM Pagos p
JOIN Boletos b ON p.BoletoID = b.BoletoID
JOIN Clientes c ON b.ClienteID = c.ClienteID
JOIN Funciones f ON b.FuncionID = f.FuncionID
JOIN Peliculas pel ON f.PeliculaID = pel.PeliculaID;

SELECT * FROM Vista_Historial_Pagos LIMIT 10;

show tables;

-- 5.3 Crear triggers que registren cambios en las tablas de Reservas y Pagos:
-- Crear la tabla para registrar cambios en Boletos

CREATE TABLE Registro_Boletos (
    id SERIAL PRIMARY KEY,
    id_boleto INT,
    accion VARCHAR(10),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50)
);

-- Trigger para registrar actualizaciones en Boletos
CREATE TRIGGER trigger_actualizar_boleto
AFTER UPDATE ON Boletos
FOR EACH ROW
INSERT INTO Registro_Boletos (id_boleto, accion, usuario)
VALUES (OLD.BoletoID, 'UPDATE', CURRENT_USER);
DESC Boletos;


-- Trigger para registrar eliminaciones en Boletos
CREATE TRIGGER trigger_eliminar_boleto
AFTER DELETE ON Boletos
FOR EACH ROW
INSERT INTO Registro_Boletos (id_boleto, accion, usuario)
VALUES (OLD.BoletoID, 'DELETE', CURRENT_USER);

-- Crear la tabla para registrar cambios en Pagos
CREATE TABLE Registro_Pagos (
    id SERIAL PRIMARY KEY,
    id_pago INT,
    accion VARCHAR(10),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50)
);
DESC Boletos;

-- Trigger para registrar actualizaciones en Pagos
CREATE TRIGGER trigger_actualizar_pago
AFTER UPDATE ON Pagos
FOR EACH ROW
INSERT INTO Registro_Pagos (id_pago, accion, usuario)
VALUES (OLD.PagoID, 'UPDATE', CURRENT_USER);

-- Trigger para registrar eliminaciones en Pagos
CREATE TRIGGER trigger_eliminar_pago
AFTER DELETE ON Pagos
FOR EACH ROW
INSERT INTO Registro_Pagos (id_pago, accion, usuario)
VALUES (OLD.PagoID, 'DELETE', CURRENT_USER);

-- 6. Monitoreo y Optimización de Recursos
-- Usar herramientas como SHOW PROCESSLIST para detectar consultas lentas y optimizarlas.
SHOW PROCESSLIST;

SHOW VARIABLES LIKE 'long_query_time';  -- umbral para consultas lentas
SHOW GLOBAL STATUS LIKE 'Slow_queries'; -- consultas lentas

-- Activamos el log de consultas lentas
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- Consultas que tarden más de 2 segundos


-- Para optimizar una consulta
EXPLAIN
SELECT Clientes.Nombre, Funciones.PeliculaID, Boletos.AsientosReservados
FROM Clientes
JOIN Boletos ON Clientes.ClienteID = Boletos.ClienteID
JOIN Funciones ON Boletos.FuncionID = Funciones.FuncionID
WHERE Boletos.PrecioTotal > 100.00;

-- Revisaremos la ejecución de consultas con múltiples JOIN
EXPLAIN
SELECT Clientes.Nombre, Funciones.PeliculaID, Peliculas.Titulo, Boletos.AsientosReservados, Boletos.PrecioTotal
FROM Clientes
JOIN Boletos ON Clientes.ClienteID = Boletos.ClienteID
JOIN Funciones ON Boletos.FuncionID = Funciones.FuncionID
JOIN Peliculas ON Funciones.PeliculaID = Peliculas.PeliculaID
WHERE Boletos.PrecioTotal > 100.00;

SHOW INDEXES FROM Boletos;
SHOW INDEXES FROM Funciones;

EXPLAIN SELECT * FROM Boletos WHERE ClienteID = 1;
EXPLAIN SELECT * FROM Funciones WHERE PeliculaID = 2;

SHOW ERRORS;
SHOW TABLE STATUS WHERE Name = 'Funciones';
SHOW TABLE STATUS WHERE Name = 'Peliculas';

SELECT 1;

-- Verificamos los indices de nuestra base de datos
SHOW INDEX FROM Clientes;
SHOW INDEX FROM Peliculas;
SHOW INDEX FROM Boletos;
SHOW INDEX FROM Funciones;

CREATE INDEX idx_pelicula_fecha ON Funciones (PeliculaID, FechaHora);


CREATE INDEX idx_cliente_funcion ON Boletos (ClienteID, FuncionID);

