# Plan de pruebas funcionales

Para cada caso guarden una captura (evidencia) y marquen el resultado.

| # | Módulo | Acción | Resultado esperado | ¿OK? |
|---|---|---|---|---|
| 1 | Login | Entrar con contraseña incorrecta | Mensaje de error, no entra | |
| 2 | Clientes | Registrar cliente con vehículo nuevo | Aparece en la lista | |
| 3 | Clientes | Registrar con una placa existente | "Ya existe un vehículo con esa placa" y no se crea el cliente (rollback) | |
| 4 | Clientes | Dejar el teléfono vacío | El formulario no se envía | |
| 5 | Clientes | Eliminar cliente con órdenes | "No se puede eliminar…" | |
| 6 | Órdenes | Crear orden con km menor al registrado | Error del SP | |
| 7 | Órdenes | Crear segunda orden para un vehículo con orden abierta | Error del SP | |
| 8 | Órdenes | Pasar a Reparación sin diagnóstico | Error del SP | |
| 9 | Órdenes | Agregar repuesto con cantidad mayor al stock | "Stock insuficiente", el stock no cambia | |
| 10 | Órdenes | Agregar repuesto válido | Stock baja, total sube | |
| 11 | Órdenes | Pagar más que el saldo | Error del SP | |
| 12 | Órdenes | Pago con tarjeta sin referencia | Error del SP | |
| 13 | Órdenes | Entregar con saldo pendiente | Error del SP | |
| 14 | Órdenes | Cancelar orden con repuestos | Estado Cancelado y stock restaurado | |
| 15 | Órdenes | Revisar historial tras varios cambios | Cada cambio con fecha y usuario | |
| 16 | Historial | Consultar placa existente / inexistente | Lista de servicios / mensaje | |
| 17 | Catálogos | Crear, editar y desactivar un mecánico | Cambios visibles; inactivo no aparece en órdenes | |
| 18 | Reportes | Cambiar rango de fechas | Datos cambian según el rango | |
| 19 | Consulta pública | Placa + número de orden correctos | Muestra el avance sin iniciar sesión | |

## Prueba directa en SSMS (para demostrar el ROLLBACK)
```sql
DECLARE @antes INT = (SELECT Stock FROM Repuesto WHERE IdRepuesto = 5);
BEGIN TRY EXEC sp_AgregarRepuestoOrden 3, 5, 999; END TRY
BEGIN CATCH PRINT ERROR_MESSAGE(); END CATCH
SELECT @antes AS StockAntes, Stock AS StockDespues FROM Repuesto WHERE IdRepuesto = 5;  -- deben ser iguales
```
