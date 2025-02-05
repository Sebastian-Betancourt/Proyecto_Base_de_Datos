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