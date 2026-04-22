# DESARROLLO Y EVIDENCIAS — DST-847

## Casos de Prueba

| N | Definicion del Criterio | Datos de Entrada | Resultado Esperado | Criterio de Exito | Query de Validacion |
|---|------------------------|-----------------|-------------------|-------------------|-------------------|
| 1 | Integridad referencial: MARCA_ID en METAS_CAMPANA existe en MARCAS | METAS_CAMPANA.MARCA_ID | 0 FK huerfanas | FK_HUERFANAS = 0 | NOT EXISTS subquery |
| 2 | Completitud: sin NULLs en VENTA_PLANIFICADA, MUST_HAVE_VENTA, CAMPANA_ID | METAS_CAMPANA | 0 NULLs en columnas criticas | Todos los conteos = 0 | SUM(CASE WHEN IS NULL) |
| 3 | Rangos validos: PCT_CUMPLIMIENTO entre 0% y 200% | Resultado del query | Min >= 0, Max <= 200 | Rango coherente | MIN/MAX sobre PCT_CUMPLIMIENTO |
| 4 | Periodo correcto: 36 campanas (6 paises x 6 campanas) | CAMPANAS filtradas | 36 campanas distintas | COUNT(DISTINCT) = 36 | COUNT(DISTINCT CAMPANA_ID) |
| 5 | Logica de clasificacion: categorias presentes | Resultado del query | Bajo, Cerca de Meta presentes | Al menos 2 categorias | GROUP BY CLASIFICACION |
| 6 | Cobertura: 6 paises Belcorp presentes | Resultado del query | Bolivia, Chile, Colombia, Ecuador, Mexico, Peru | 6 paises | SELECT DISTINCT PAIS |
| 7 | Consistencia: MUST_HAVE_VENTA siempre menor que VENTA_PLANIFICADA | METAS_CAMPANA | 0 registros inconsistentes | Conteo = 0 | WHERE MUST_HAVE > PLAN |

## Resultados de Ejecucion

| N | Test | Resultado | Detalle |
|---|------|-----------|---------|
| 1 | Integridad referencial MARCA_ID | PASO | 0 FK huerfanas |
| 2 | Completitud columnas criticas | PASO | 0 NULLs en las 3 columnas |
| 3 | Rangos PCT_CUMPLIMIENTO | PASO | Min: 68.97%, Max: 95.24% |
| 4 | Periodo 6 campanas | PASO | 36 campanas distintas (6 x 6) |
| 5 | Clasificacion completa | PASO | Bajo: 359, Cerca de Meta: 289 |
| 6 | Cobertura 6 paises | PASO | Bolivia, Chile, Colombia, Ecuador, Mexico, Peru |
| 7 | MUST_HAVE < VENTA_PLANIFICADA | PASO | 0 inconsistencias |

## Resumen

- **7 tests ejecutados**: 7 PASO, 0 FALLO
- **Hallazgo notable**: Ninguna combinacion supero la meta planificada en las ultimas 6 campanas (solo Bajo y Cerca de Meta)
