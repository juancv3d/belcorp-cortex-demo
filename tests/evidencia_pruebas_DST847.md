# DESARROLLO Y EVIDENCIAS — DST-847

## Casos de Prueba

| N | Definicion del Criterio | Datos de Entrada | Resultado Esperado | Criterio de Exito | Query de Validacion |
|---|------------------------|-----------------|-------------------|-------------------|-------------------|
| 1 | Integridad referencial: MARCA_ID en METAS_CAMPANA existe en MARCAS | METAS_CAMPANA.MARCA_ID | 0 FK huerfanas | FK_HUERFANAS = 0 | SELECT COUNT(*) WHERE NOT EXISTS |
| 2 | Completitud: sin NULLs en VENTA_PLANIFICADA, MUST_HAVE_VENTA, CAMPANA_ID | METAS_CAMPANA | 0 NULLs en columnas criticas | Todos los conteos = 0 | SUM(CASE WHEN IS NULL) |
| 3 | Rangos validos: PCT_CUMPLIMIENTO entre 0% y 200% | Resultado del query principal | Min >= 0, Max <= 200 | Rango coherente | MIN/MAX sobre PCT_CUMPLIMIENTO |
| 4 | Periodo correcto: exactamente 6 campanas finalizadas en el filtro | CAMPANAS con ESTADO = Finalizada | 36 campanas (6 por pais) | >= 6 campanas distintas | COUNT(DISTINCT CAMPANA_ID) |
| 5 | Logica de clasificacion: las 3 categorias presentes | Resultado del query | Supera Meta, Cerca de Meta, Bajo | Al menos 2 categorias presentes | GROUP BY CLASIFICACION |
| 6 | Cobertura de paises: 6 paises Belcorp presentes | Resultado del query | Bolivia, Chile, Colombia, Ecuador, Mexico, Peru | 6 paises | SELECT DISTINCT PAIS |
| 7 | Consistencia: MUST_HAVE_VENTA siempre menor a VENTA_PLANIFICADA | METAS_CAMPANA | 0 registros con must-have > plan | Conteo = 0 | WHERE MUST_HAVE > PLAN |

## Resultados de Ejecucion

| N | Test | Resultado | Detalle |
|---|------|-----------|---------|
| 1 | Integridad referencial MARCA_ID | PASO | 0 FK huerfanas encontradas |
| 2 | Completitud columnas criticas | PASO | 0 NULLs en VENTA_PLANIFICADA, MUST_HAVE_VENTA, CAMPANA_ID |
| 3 | Rangos PCT_CUMPLIMIENTO | PASO | Min: 68.97%, Max: 95.24% - rango coherente |
| 4 | Periodo 6 campanas | PASO | 36 campanas distintas (6 paises x 6 campanas) |
| 5 | Clasificacion completa | PASO | Bajo: 359, Cerca de Meta: 289. Nota: no hay "Supera Meta" en este periodo - ningun cruce supero la meta planificada |
| 6 | Cobertura 6 paises | PASO | Bolivia, Chile, Colombia, Ecuador, Mexico, Peru |
| 7 | MUST_HAVE < VENTA_PLANIFICADA | PASO | 0 registros con inconsistencia |

## Resumen

- **7 tests ejecutados**: 7 PASO, 0 FALLO
- **Hallazgo notable**: Ninguna combinacion marca-categoria supero la meta planificada en las ultimas 6 campanas (solo Bajo y Cerca de Meta)
