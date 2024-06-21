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
        120510, -- EspacioID
        1005, -- SesionID
        1503, -- UsuarioID
        NOW(),
        '2024-06-20 10:00:00',
        '2024-06-20 12:00:00'
    );

-- Un usuario puede cancelar una reserva
DELETE FROM Reservas WHERE ReservaID = 1016;

-- Consultas

-- Ver la lista de espacios de trabajo disponibles de una sala en una sesión x

SELECT e.EspacioID, e.Fila, e.Columna
FROM
    Espacios_de_Trabajo e
    LEFT JOIN Reservas r ON e.EspacioID = r.EspacioID
    AND r.SesionID = 1017
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