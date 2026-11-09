"""
Capa de acceso a datos.

El proyecto NO usa el ORM de Django para el negocio: todo pasa por SQL directo,
vistas y procedimientos almacenados de SQL Server (requisito del curso).
Estas cuatro funciones son lo único que las vistas de Django necesitan.
"""
import re
from django.db import connection, DatabaseError


class ErrorNegocio(Exception):
    """Error lanzado por un THROW dentro de un procedimiento almacenado."""


def _filas(cursor):
    if cursor.description is None:
        return []
    columnas = [c[0] for c in cursor.description]
    return [dict(zip(columnas, fila)) for fila in cursor.fetchall()]


def _mensaje(error):
    """Extrae el texto limpio del THROW de SQL Server.
    pyodbc devuelve algo como: '[42000] [Microsoft]...[SQL Server]Stock insuficiente. (50032) ...'"""
    texto = " ".join(str(a) for a in error.args)
    m = re.search(r"\[SQL Server\](.+?)\s*\(\d+\)", texto)
    return m.group(1).strip() if m else texto


def consultar(sql, params=None):
    """SELECT que devuelve una lista de diccionarios."""
    with connection.cursor() as c:
        c.execute(sql, params or [])
        return _filas(c)


def uno(sql, params=None):
    """SELECT que devuelve un solo registro (o None)."""
    filas = consultar(sql, params)
    return filas[0] if filas else None


def ejecutar(sql, params=None):
    """INSERT / UPDATE / DELETE simple. Convierte errores de SQL en ErrorNegocio."""
    try:
        with connection.cursor() as c:
            c.execute(sql, params or [])
            return c.rowcount
    except DatabaseError as e:
        raise ErrorNegocio(_mensaje(e)) from e


def procedimiento(nombre, *params):
    """Ejecuta un procedimiento almacenado: EXEC nombre ?, ?, ...
    Devuelve las filas de su SELECT final (si tiene)."""
    marcas = ", ".join(["%s"] * len(params))
    try:
        with connection.cursor() as c:
            c.execute(f"SET NOCOUNT ON; EXEC {nombre} {marcas}", list(params))
            return _filas(c)
    except DatabaseError as e:
        raise ErrorNegocio(_mensaje(e)) from e
