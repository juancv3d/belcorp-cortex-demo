# Historia Tecnica: Top 10 Consultoras por Ingreso Neto

## FUENTES DE DATOS:
- `BELCORP_ANALYTICS.COMERCIAL.VENTAS` - Transacciones de venta (VENTA_ID, CAMPANA_ID, CONSULTORA_ID, PRODUCTO_ID, UNIDADES, INGRESO_NETO, GANANCIA)
- `BELCORP_ANALYTICS.COMERCIAL.CONSULTORAS` - Maestro de consultoras (CONSULTORA_ID PK, NOMBRE, ZONA, REGION, SEGMENTO)
- `BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS` - Catalogo de productos (PRODUCTO_ID PK, MARCA_ID)
- `BELCORP_ANALYTICS.COMERCIAL.MARCAS` - Maestro de marcas (MARCA_ID PK, NOMBRE_MARCA)
- `BELCORP_ANALYTICS.COMERCIAL.CAMPANAS` - Ciclos comerciales (CAMPANA_ID PK, ESTADO, FECHA_FIN)

## TRANSFORMACIONES REQUERIDAS:
1. Identificar la ultima campana con ESTADO = 'Finalizada' ordenando por FECHA_FIN DESC
2. Filtrar VENTAS por esa campana
3. JOIN con CONSULTORAS para obtener datos demograficos
4. JOIN con PRODUCTOS y MARCAS para obtener el nombre de marca
5. Agregar por consultora con SUM de unidades, ingreso neto y ganancia
6. PIVOT por marca usando CASE WHEN para desglose (Esika, L'Bel, Cyzone)
7. Ordenar por ingreso neto descendente y limitar a 10

## LOGICA DE NEGOCIO:
- Solo se consideran campanas con estado 'Finalizada'
- Se toma la mas reciente por FECHA_FIN
- El ingreso neto ya viene calculado en la tabla VENTAS (no requiere calculo adicional)
- El desglose por marca se obtiene via PRODUCTOS.MARCA_ID -> MARCAS.NOMBRE_MARCA

## SUPUESTOS:
- Existe al menos una campana con estado 'Finalizada'
- Todas las consultoras en VENTAS existen en la tabla CONSULTORAS (integridad referencial)
- Los PRODUCTO_ID en VENTAS tienen MARCA_ID valido en PRODUCTOS

## VALIDACIONES:
- Verificar que la subconsulta de ultima campana retorna exactamente 1 fila
- Verificar que no hay CONSULTORA_ID en VENTAS sin match en CONSULTORAS
- Verificar que los valores de INGRESO_NETO son positivos

## SQL PROPUESTO:

```sql
WITH ultima_campana AS (
    SELECT CAMPANA_ID
    FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
    WHERE ESTADO = 'Finalizada'
    ORDER BY FECHA_FIN DESC
    LIMIT 1
)
SELECT
    c.CONSULTORA_ID,
    c.NOMBRE,
    c.ZONA,
    c.REGION,
    c.SEGMENTO,
    SUM(v.UNIDADES)                                                           AS TOTAL_UNIDADES,
    ROUND(SUM(v.INGRESO_NETO), 2)                                            AS INGRESO_NETO_TOTAL,
    ROUND(SUM(v.GANANCIA), 2)                                                AS GANANCIA_TOTAL,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'Ésika'  THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_ESIKA,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'L''Bel' THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_LBEL,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'Cyzone' THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_CYZONE
FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
JOIN BELCORP_ANALYTICS.COMERCIAL.CONSULTORAS c ON v.CONSULTORA_ID = c.CONSULTORA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS p   ON v.PRODUCTO_ID = p.PRODUCTO_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.MARCAS m      ON p.MARCA_ID = m.MARCA_ID
WHERE v.CAMPANA_ID = (SELECT CAMPANA_ID FROM ultima_campana)
GROUP BY c.CONSULTORA_ID, c.NOMBRE, c.ZONA, c.REGION, c.SEGMENTO
ORDER BY INGRESO_NETO_TOTAL DESC
LIMIT 10;
```
