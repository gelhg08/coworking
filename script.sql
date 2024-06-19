-- Creación de tablas

CREATE TABLE IF NOT EXISTS Usuarios (
    UsuarioID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Salas (
    SalaID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ubicacion VARCHAR(100),
    Filas INT,
    Columnas INT
);

CREATE TABLE IF NOT EXISTS Espacios_de_Trabajo (
    EspacioID SERIAL PRIMARY KEY,
    SalaID INT REFERENCES Salas (SalaID),
    Fila INT,
    Columna INT
);

CREATE TABLE IF NOT EXISTS Sesiones (
    SesionID SERIAL PRIMARY KEY,
    FechaInicio TIMESTAMP,
    FechaFin TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Reservas (
    ReservaID SERIAL PRIMARY KEY,
    EspacioID INT REFERENCES Espacios_de_Trabajo (EspacioID),
    SesionID INT REFERENCES Sesiones (SesionID),
    UsuarioID INT REFERENCES Usuarios (UsuarioID),
    FechaReserva TIMESTAMP,
    FechaInicio TIMESTAMP,
    FechaFin TIMESTAMP
);

-- Inserción de 100 Usuarios
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Usuarios (Nombre, Email, Telefono) 
        VALUES (
            'Usuario ' || i,
            'usuario' || i || '@example.com',
            '555-000' || i
        ) ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Inserción de 100 Salas
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Salas (Nombre, Ubicacion, Filas, Columnas)
        VALUES (
            'Sala ' || i,
            'Ubicacion ' || i,
            10,
            10
        ) ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Inserción de espacios de trabajo
DO $$
DECLARE
    sala_id INT;
    fila INT;
    columna INT;
BEGIN
    FOR sala_id IN (SELECT SalaID FROM Salas) LOOP
        fila := 1;
        columna := 1;
        FOR i IN 1..(SELECT Filas FROM Salas WHERE SalaID = sala_id) LOOP
            FOR j IN 1..(SELECT Columnas FROM Salas WHERE SalaID = sala_id) LOOP
                INSERT INTO Espacios_de_Trabajo (SalaID, Fila, Columna)
                VALUES (sala_id, fila, columna) ON CONFLICT DO NOTHING;
                columna := columna + 1;
            END LOOP;
            fila := fila + 1;
            columna := 1;
        END LOOP;
    END LOOP;
END $$;

-- Inserción de 100 Sesiones
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Sesiones (FechaInicio, FechaFin)
        VALUES (
            NOW() + (i || ' hours')::INTERVAL,
            NOW() + ((i + 1) || ' hours')::INTERVAL
        ) ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Inserción de 100 Reservas
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Reservas (EspacioID, SesionID, UsuarioID, FechaReserva, FechaInicio, FechaFin)
        VALUES (
            i,                          
            (i % 100) + 1,              
            (i % 100) + 1,              
            NOW(),                      
            NOW() + (i || ' hours')::INTERVAL,       
            NOW() + ((i + 1) || ' hours')::INTERVAL   
        ) ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Un Usuario puede reservar un espacio de trabajo en una sesión x
INSERT INTO
    Reservas (
        EspacioID,
        SesionID,
        UsuarioID,
        FechaReserva,
        FechaInicio,
        FechaFin
    )
VALUES (
        1, -- EspacioID
        1, -- SesionID
        1, -- UsuarioID
        NOW(),
        '2024-06-20 10:00:00',
        '2024-06-20 12:00:00'
    );

-- Un usuario puede cancelar una reserva
DELETE FROM Reservas WHERE ReservaID = 1;

-- Consultas

-- Ver la lista de espacios de trabajo disponibles de una sala en una sesión x

SELECT e.EspacioID, e.Fila, e.Columna
FROM
    Espacios_de_Trabajo e
    LEFT JOIN Reservas r ON e.EspacioID = r.EspacioID
    AND r.SesionID = 1 
WHERE
    e.SalaID = 1 
    AND r.ReservaID IS NULL;

-- Ver la lista de espacios de trabajo ocupados de una sala en una sesión x

SELECT e.EspacioID, e.Fila, e.Columna, r.UsuarioID
FROM
    Espacios_de_Trabajo e
    JOIN Reservas r ON e.EspacioID = r.EspacioID
WHERE
    e.SalaID = 1 --
    AND r.SesionID = 1;


-- Ver las sesiones con orden por las más ocupadas
SELECT s.SesionID, s.FechaInicio, s.FechaFin, COUNT(r.ReservaID) AS total_asignaciones
FROM Sesiones s
    LEFT JOIN Reservas r ON s.SesionID = r.SesionID
GROUP BY
    s.SesionID,
    s.FechaInicio,
    s.FechaFin
ORDER BY total_asignaciones DESC;


-- Ver las sesiones con orden por las más disponibles
SELECT s.SesionID, s.FechaInicio, s.FechaFin, (
        COUNT(e.EspacioID) - COUNT(r.ReservaID)
    ) AS total_disponibles
FROM
    Sesiones s
    JOIN Espacios_de_Trabajo e ON s.SesionID = e.SesionID
    LEFT JOIN Reservas r ON s.SesionID = r.SesionID
    AND e.EspacioID = r.EspacioID
GROUP BY
    s.SesionID,
    s.FechaInicio,
    s.FechaFin
ORDER BY total_disponibles DESC;


-- Ver la lista de espacios de trabajo asignados a un usuario

SELECT e.EspacioID, e.Fila, e.Columna, s.SesionID, s.FechaInicio, s.FechaFin
FROM
    Reservas r
    JOIN Espacios_de_Trabajo e ON r.EspacioID = e.EspacioID
    JOIN Sesiones s ON r.SesionID = s.SesionID
WHERE
    r.UsuarioID = 1;


-- Ver la lista de espacios de trabajo asignados a una sesión
SELECT e.EspacioID, e.Fila, e.Columna, r.UsuarioID
FROM
    Reservas r
    JOIN Espacios_de_Trabajo e ON r.EspacioID = e.EspacioID
WHERE
    r.SesionID = 1;
-- Cambiar SesionID
-- Verificación de datos
-- Verificar usuarios insertados
SELECT * FROM Usuarios LIMIT 5;

-- Verificar salas insertadas
SELECT * FROM Salas LIMIT 5;

-- Verificar espacios de trabajo insertados
SELECT * FROM Espacios_de_Trabajo LIMIT 5;

-- Verificar sesiones insertadas
SELECT * FROM Sesiones LIMIT 5;

-- Verificar reservas insertadas
SELECT * FROM Reservas LIMIT 5;