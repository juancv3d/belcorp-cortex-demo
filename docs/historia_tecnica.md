# DEFINICION TECNICA — DST-847

## FUENTES DE DATOS

| Tabla | Descripcion | Columnas Relevantes | Registros |
|-------|-------------|-------------------|-----------|
| METAS_CAMPANA | Metas planificadas por cruce | CAMPANA_ID, MARCA_ID, CATEGORIA_ID, VENTA_PLANIFICADA, MUST_HAVE_VENTA | 3,888 |
| VENTAS | Ventas reales transaccionales | CAMPANA_ID, PRODUCTO_ID, INGRESO_NETO | 2,200,000+ |
| CAMPANAS | Dimension temporal y geografica | CAMPANA_ID, PAIS, ANIO, NUMERO_CAMPANA, ESTADO | 216 |
| PRODUCTOS | Puente ventas-marca-categoria | PRODUCTO_ID, MARCA_ID, CATEGORIA_ID | 309 |
| MARCAS | Dimension marca | MARCA_ID, NOMBRE_MARCA | 3 |
| CATEGORIAS | Dimension categoria | CATEGORIA_ID, NOMBRE_CATEGORIA | 6 |

## ERRORES CORREGIDOS EN SQL EXISTENTE

| # | Error | Correccion | Linea |
|---|-------|------------|-------|
| 1 | `ESTADO = 'Cerrada'` (valor inexistente, 0 filas) | Cambiar a `'Finalizada'` | 13, 18 |
| 2 | `LIMIT 3` (historia pide 6 campanas) | Cambiar a `LIMIT 6` | 20 |
| 3 | `m.NOMBRE` (columna inexistente en MARCAS) | Cambiar a `m.NOMBRE_MARCA` | 41 |
| 4 | Falta `MUST_HAVE_VENTA` en SELECT | Agregar `mc.MUST_HAVE_VENTA` | 43 |
| 5 | Clasificacion usa `VENTA_PLANIFICADA * 0.9` | Usar `mc.MUST_HAVE_VENTA` como umbral | 48 |
| 6 | `JOIN` pierde combinaciones sin venta | Cambiar a `LEFT JOIN` | 55 |

## LOGICA DE NEGOCIO

- Filtro temporal: ultimas 6 campanas con ESTADO = 'Finalizada' (campanas 10-15 de 2025)
- Granularidad: campana x marca x categoria (648 combinaciones)
- Join VENTAS -> PRODUCTOS para obtener MARCA_ID y CATEGORIA_ID
- Clasificacion: Supera Meta / Cumple Must-Have / Por Debajo Must-Have

## SQL CORREGIDO Y VALIDADO

Archivo: `sql/analisis_cumplimiento.sql` — 648 filas retornadas, ejecucion exitosa.
