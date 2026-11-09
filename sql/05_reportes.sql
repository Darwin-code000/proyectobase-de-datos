/* Script 05: consultas de reportes (las mismas que usa Django en reportes/)
   Sirven para probar en SSMS y para explicarlas en la defensa. */
USE TallerDB;
GO

-- R1. Ingresos por método de pago en un rango (SUM, COUNT, AVG, MAX, MIN)
EXEC sp_ReporteIngresos '2026-01-01', '2026-12-31';

-- R2. Servicios más solicitados
SELECT s.Nombre, COUNT(os.IdOrdenServicio) AS VecesRealizado,
       SUM(os.Precio + os.HorasManoObra * os.TarifaHora) AS Ingreso
FROM Servicio s
INNER JOIN OrdenServicio os ON os.IdServicio = s.IdServicio
INNER JOIN OrdenTrabajo o   ON o.IdOrden = os.IdOrden
WHERE o.IdEstado <> 6
GROUP BY s.Nombre
ORDER BY VecesRealizado DESC, Ingreso DESC;

-- R3. Productividad por mecánico
SELECT m.Nombre, COUNT(DISTINCT os.IdOrden) AS Ordenes,
       SUM(os.HorasManoObra) AS Horas,
       SUM(os.HorasManoObra * os.TarifaHora) AS ManoObraGenerada,
       AVG(os.HorasManoObra) AS PromedioHorasPorServicio
FROM Mecanico m
INNER JOIN OrdenServicio os ON os.IdMecanico = m.IdMecanico
INNER JOIN OrdenTrabajo o   ON o.IdOrden = os.IdOrden
WHERE o.IdEstado <> 6
GROUP BY m.Nombre
ORDER BY ManoObraGenerada DESC;

-- R4. Tiempo promedio (horas) entre Recibido y Terminado, usando el historial
SELECT AVG(DATEDIFF(MINUTE, h1.FechaCambio, h4.FechaCambio) / 60.0) AS HorasPromedio,
       MAX(DATEDIFF(MINUTE, h1.FechaCambio, h4.FechaCambio) / 60.0) AS HorasMaximo,
       MIN(DATEDIFF(MINUTE, h1.FechaCambio, h4.FechaCambio) / 60.0) AS HorasMinimo,
       COUNT(*) AS OrdenesTerminadas
FROM HistorialEstado h1
INNER JOIN HistorialEstado h4 ON h4.IdOrden = h1.IdOrden AND h4.EstadoNuevo = 4
WHERE h1.EstadoNuevo = 1;

-- R5. Órdenes con saldo pendiente
SELECT IdOrden, Cliente, Telefono, Placa, Estado, Total, Pagado, Saldo
FROM vw_OrdenesDetalle
WHERE Saldo > 0 AND IdEstado <> 6
ORDER BY Saldo DESC;

-- R6. Repuestos con stock bajo
SELECT Codigo, Nombre, Stock, StockMinimo
FROM Repuesto WHERE Stock <= StockMinimo ORDER BY Stock;

-- R7. Órdenes por estado
SELECT e.Nombre, COUNT(o.IdOrden) AS Cantidad
FROM EstadoOrden e LEFT JOIN OrdenTrabajo o ON o.IdEstado = e.IdEstado
GROUP BY e.Nombre, e.Secuencia ORDER BY e.Secuencia;
