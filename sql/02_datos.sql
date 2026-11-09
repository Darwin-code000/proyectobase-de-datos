/* Script 02: datos iniciales y de prueba */
USE TallerDB;
GO

INSERT INTO EstadoOrden (IdEstado, Nombre, Secuencia) VALUES
(1,'Recibido',1),(2,'Diagnóstico',2),(3,'Reparación',3),(4,'Terminado',4),(5,'Entregado',5),(6,'Cancelado',9);

INSERT INTO MetodoPago (Nombre) VALUES ('Efectivo'),('Tarjeta'),('Transferencia');

INSERT INTO Especialidad (Nombre) VALUES ('Motor'),('Frenos'),('Electricidad'),('Suspensión'),('Transmisión');

INSERT INTO Servicio (Nombre, Descripcion, PrecioBase) VALUES
('Cambio de aceite','Aceite y filtro',250),
('Alineación y balanceo','Cuatro llantas',200),
('Cambio de pastillas de freno','Eje delantero',300),
('Diagnóstico computarizado','Escáner OBD-II',150),
('Afinamiento mayor','Bujías, filtros, limpieza de inyectores',650),
('Revisión eléctrica','Batería, alternador y cableado',180);

INSERT INTO Repuesto (Codigo, Nombre, Precio, Stock, StockMinimo) VALUES
('ACE-5W30','Aceite 5W-30 (galón)',180,20,5),
('FIL-ACE','Filtro de aceite',45,30,10),
('PAS-DEL','Pastillas de freno delanteras',320,8,4),
('BUJ-IR','Bujía de iridio',75,40,12),
('BAT-12V','Batería 12V',850,3,4);

INSERT INTO Mecanico (Nombre, Telefono, TarifaHora) VALUES
('Carlos López','5511-2233',60),
('Mario Pérez','5522-3344',55),
('Luis Ajú','5533-4455',70);

INSERT INTO MecanicoEspecialidad VALUES (1,1),(1,5),(2,2),(2,4),(3,3),(3,1);

INSERT INTO Cliente (Nombre, NIT, Telefono, Correo, Direccion) VALUES
('Ana García','1234567-8','4455-6677','ana@correo.com','Zona 1, Guatemala'),
('José Méndez','CF','3344-5566',NULL,'Mixco'),
('Transportes El Rápido S.A.','9876543-2','2233-4455','info@elrapido.com','Zona 12, Guatemala');

INSERT INTO Vehiculo (IdCliente, Placa, Marca, Modelo, Anio, Color, Kilometraje) VALUES
(1,'P123ABC','Toyota','Corolla',2018,'Gris',85000),
(2,'P456DEF','Honda','Civic',2015,'Negro',120000),
(3,'C789GHI','Isuzu','NPR',2020,'Blanco',60000),
(3,'C321JKL','Hyundai','H100',2019,'Blanco',95000);
GO

/* Órdenes de ejemplo creadas con los procedimientos (ejecutar después del script 04) */
