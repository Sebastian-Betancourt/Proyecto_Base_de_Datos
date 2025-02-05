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

