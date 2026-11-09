/* =====================================================================
   SISTEMA DE ÓRDENES DE TRABAJO - TALLER AUTOMOTRIZ
   Script 01: creación de la base de datos y tablas
   Ejecutar en SQL Server Management Studio (SSMS) en orden: 01, 02, 03, 04
   ===================================================================== */

IF DB_ID('TallerDB') IS NULL
    CREATE DATABASE TallerDB;
GO
USE TallerDB;
GO

/* ---------------------------------------------------------------
   CATÁLOGOS
   --------------------------------------------------------------- */
CREATE TABLE EstadoOrden (
    IdEstado     TINYINT       NOT NULL PRIMARY KEY,
    Nombre       NVARCHAR(30)  NOT NULL UNIQUE,
    Secuencia    TINYINT       NOT NULL   -- orden lógico del flujo
);

CREATE TABLE MetodoPago (
    IdMetodoPago TINYINT IDENTITY(1,1) PRIMARY KEY,
    Nombre       NVARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Especialidad (
    IdEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
    Nombre         NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Servicio (
    IdServicio   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre       NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion  NVARCHAR(300) NULL,
    PrecioBase   DECIMAL(10,2) NOT NULL CONSTRAINT CK_Servicio_Precio CHECK (PrecioBase >= 0),
    Activo       BIT NOT NULL DEFAULT 1
);

CREATE TABLE Repuesto (
    IdRepuesto   INT IDENTITY(1,1) PRIMARY KEY,
    Codigo       NVARCHAR(30)  NOT NULL UNIQUE,
    Nombre       NVARCHAR(100) NOT NULL,
    Precio       DECIMAL(10,2) NOT NULL CONSTRAINT CK_Repuesto_Precio CHECK (Precio >= 0),
    Stock        INT NOT NULL DEFAULT 0 CONSTRAINT CK_Repuesto_Stock CHECK (Stock >= 0),
    StockMinimo  INT NOT NULL DEFAULT 5
);

/* ---------------------------------------------------------------
   PERSONAS Y VEHÍCULOS
   --------------------------------------------------------------- */
CREATE TABLE Cliente (
    IdCliente     INT IDENTITY(1,1) PRIMARY KEY,
    Nombre        NVARCHAR(100) NOT NULL,
    NIT           NVARCHAR(15)  NOT NULL DEFAULT 'CF',
    Telefono      NVARCHAR(15)  NOT NULL,
    Correo        NVARCHAR(100) NULL,
    Direccion     NVARCHAR(200) NULL,
    FechaRegistro DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE Vehiculo (
    IdVehiculo  INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente   INT NOT NULL,
    Placa       NVARCHAR(10) NOT NULL CONSTRAINT UQ_Vehiculo_Placa UNIQUE,
    Marca       NVARCHAR(50) NOT NULL,
    Modelo      NVARCHAR(50) NOT NULL,
    Anio        SMALLINT NOT NULL CONSTRAINT CK_Vehiculo_Anio CHECK (Anio BETWEEN 1950 AND 2100),
    Color       NVARCHAR(30) NULL,
    VIN         NVARCHAR(17) NULL,
    Kilometraje INT NOT NULL DEFAULT 0 CONSTRAINT CK_Vehiculo_Km CHECK (Kilometraje >= 0),
    CONSTRAINT FK_Vehiculo_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);

CREATE TABLE Mecanico (
    IdMecanico   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre       NVARCHAR(100) NOT NULL,
    Telefono     NVARCHAR(15)  NULL,
    TarifaHora   DECIMAL(10,2) NOT NULL CONSTRAINT CK_Mecanico_Tarifa CHECK (TarifaHora >= 0),
    Activo       BIT NOT NULL DEFAULT 1
);

-- Relación muchos a muchos: un mecánico tiene varias especialidades
CREATE TABLE MecanicoEspecialidad (
    IdMecanico     INT NOT NULL,
    IdEspecialidad INT NOT NULL,
    CONSTRAINT PK_MecanicoEspecialidad PRIMARY KEY (IdMecanico, IdEspecialidad),
    CONSTRAINT FK_ME_Mecanico     FOREIGN KEY (IdMecanico)     REFERENCES Mecanico(IdMecanico),
    CONSTRAINT FK_ME_Especialidad FOREIGN KEY (IdEspecialidad) REFERENCES Especialidad(IdEspecialidad)
);

/* ---------------------------------------------------------------
   ÓRDENES DE TRABAJO
   --------------------------------------------------------------- */
CREATE TABLE OrdenTrabajo (
    IdOrden        INT IDENTITY(1,1) PRIMARY KEY,
    IdVehiculo     INT NOT NULL,
    IdEstado       TINYINT NOT NULL DEFAULT 1,
    FechaIngreso   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    KmIngreso      INT NOT NULL CONSTRAINT CK_Orden_Km CHECK (KmIngreso >= 0),
    FallaReportada NVARCHAR(500)  NOT NULL,
    Diagnostico    NVARCHAR(1000) NULL,
    Observaciones  NVARCHAR(1000) NULL,
    Descuento      DECIMAL(10,2) NOT NULL DEFAULT 0 CONSTRAINT CK_Orden_Descuento CHECK (Descuento >= 0),
    FechaEntrega   DATETIME2 NULL,
    CONSTRAINT FK_Orden_Vehiculo FOREIGN KEY (IdVehiculo) REFERENCES Vehiculo(IdVehiculo),
    CONSTRAINT FK_Orden_Estado   FOREIGN KEY (IdEstado)   REFERENCES EstadoOrden(IdEstado)
);

-- Reto 1: historial de cambios de estado
CREATE TABLE HistorialEstado (
    IdHistorial    INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden        INT NOT NULL,
    EstadoAnterior TINYINT NULL,          -- NULL cuando la orden se crea
    EstadoNuevo    TINYINT NOT NULL,
    FechaCambio    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Usuario        NVARCHAR(50) NOT NULL,
    Comentario     NVARCHAR(300) NULL,
    CONSTRAINT FK_Hist_Orden    FOREIGN KEY (IdOrden)        REFERENCES OrdenTrabajo(IdOrden),
    CONSTRAINT FK_Hist_EstAnt   FOREIGN KEY (EstadoAnterior) REFERENCES EstadoOrden(IdEstado),
    CONSTRAINT FK_Hist_EstNuevo FOREIGN KEY (EstadoNuevo)    REFERENCES EstadoOrden(IdEstado)
);

-- Servicios realizados en la orden + mecánico asignado + mano de obra
CREATE TABLE OrdenServicio (
    IdOrdenServicio INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden         INT NOT NULL,
    IdServicio      INT NOT NULL,
    IdMecanico      INT NOT NULL,
    Precio          DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),         -- precio del servicio al momento
    HorasManoObra   DECIMAL(5,2)  NOT NULL DEFAULT 0 CHECK (HorasManoObra >= 0),
    TarifaHora      DECIMAL(10,2) NOT NULL CHECK (TarifaHora >= 0),     -- tarifa del mecánico al momento
    CONSTRAINT FK_OS_Orden    FOREIGN KEY (IdOrden)    REFERENCES OrdenTrabajo(IdOrden),
    CONSTRAINT FK_OS_Servicio FOREIGN KEY (IdServicio) REFERENCES Servicio(IdServicio),
    CONSTRAINT FK_OS_Mecanico FOREIGN KEY (IdMecanico) REFERENCES Mecanico(IdMecanico)
);

CREATE TABLE OrdenRepuesto (
    IdOrdenRepuesto INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden         INT NOT NULL,
    IdRepuesto      INT NOT NULL,
    Cantidad        INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario  DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario >= 0),
    CONSTRAINT FK_OR_Orden    FOREIGN KEY (IdOrden)    REFERENCES OrdenTrabajo(IdOrden),
    CONSTRAINT FK_OR_Repuesto FOREIGN KEY (IdRepuesto) REFERENCES Repuesto(IdRepuesto)
);

CREATE TABLE Pago (
    IdPago       INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden      INT NOT NULL,
    IdMetodoPago TINYINT NOT NULL,
    Monto        DECIMAL(10,2) NOT NULL CONSTRAINT CK_Pago_Monto CHECK (Monto > 0),
    FechaPago    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Referencia   NVARCHAR(50) NULL,
    CONSTRAINT FK_Pago_Orden  FOREIGN KEY (IdOrden)      REFERENCES OrdenTrabajo(IdOrden),
    CONSTRAINT FK_Pago_Metodo FOREIGN KEY (IdMetodoPago) REFERENCES MetodoPago(IdMetodoPago)
);

-- Índices para consultas frecuentes
CREATE INDEX IX_Vehiculo_Cliente ON Vehiculo(IdCliente);
CREATE INDEX IX_Orden_Vehiculo   ON OrdenTrabajo(IdVehiculo);
CREATE INDEX IX_Orden_Estado     ON OrdenTrabajo(IdEstado);
CREATE INDEX IX_Hist_Orden       ON HistorialEstado(IdOrden);
CREATE INDEX IX_Pago_Orden       ON Pago(IdOrden);
GO
