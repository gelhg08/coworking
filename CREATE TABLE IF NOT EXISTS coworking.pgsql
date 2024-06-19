CREATE TABLE IF NOT EXISTS coworking.Usuarios (
    UsuarioID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS coworking.Salas (
    SalaID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ubicacion VARCHAR(100),
    Filas INT,
    Columnas INT
);

CREATE TABLE IF NOT EXISTS coworking.Espacios_de_Trabajo (
    EspacioID SERIAL PRIMARY KEY,
    SalaID INT REFERENCES coworking.Salas (SalaID),
    Fila INT,
    Columna INT
);

CREATE TABLE IF NOT EXISTS coworking.Sesiones (
    SesionID SERIAL PRIMARY KEY,
    FechaInicio TIMESTAMP,
    FechaFin TIMESTAMP
);

CREATE TABLE IF NOT EXISTS coworking.Reservas (
    ReservaID SERIAL PRIMARY KEY,
    EspacioID INT REFERENCES coworking.Espacios_de_Trabajo (EspacioID),
    SesionID INT REFERENCES coworking.Sesiones (SesionID),
    UsuarioID INT REFERENCES coworking.Usuarios (UsuarioID),
    FechaReserva TIMESTAMP,
    FechaInicio TIMESTAMP,
    FechaFin TIMESTAMP
);
