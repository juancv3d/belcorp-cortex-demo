# EVIDENCIA DE PRUEBAS — DST-847

## Resumen Ejecutivo

| Test | Descripcion | Resultado | Detalle |
|------|------------|-----------|---------|
| T-01 | Filtro temporal: ultimas 6 campanas finalizadas | PASS | 6 periodos, 36 campanas (6 paises), rango C10-C15 2025 |
| T-02 | Completitud: todas las metas tienen ventas asociadas | PASS | 648 metas, 648 combinaciones con venta, 0 sin match |
| T-03 | Rango logico de % cumplimiento | PASS | Min 68.97%, Max 95.24%, Avg 87.18%, 0 negativos, 0 >200% |
| T-04 | Integridad referencial y calidad de datos | PASS | 0 ventas sin producto, 0 metas sin campana. 569K registros con ingreso negativo (25.87%) — devoluciones/descuentos |
| T-05 | Validacion cruzada de totales entre queries | PASS | Total planificado $36.9M, venta real $31.9M, cumplimiento global 86.47% |

## Detalle por Test

### T-01: Filtro Temporal

**Objetivo:** Verificar que el CTE `ultimas_campanas` selecciona exactamente las 6 campanas mas recientes con estado Finalizada.

```sql
-- Resultado:
-- PERIODOS_DISTINTOS: 6
-- TOTAL_CAMPANAS: 36 (6 periodos x 6 paises)
-- CAMPANA_MIN: 10, CAMPANA_MAX: 15
-- PAISES: 6
```

**Conclusion:** El filtro temporal opera correctamente. Se seleccionan campanas 10 a 15 de 2025 para los 6 paises (Peru, Bolivia, Mexico, Colombia, Ecuador, Chile).

### T-02: Completitud de Datos

**Objetivo:** Verificar que cada combinacion campana-marca-categoria en METAS_CAMPANA tiene ventas reales asociadas.

```sql
-- Resultado:
-- TOTAL_METAS: 648
-- COMBINACIONES_CON_VENTA: 648
-- METAS_SIN_VENTA: 0
```

**Conclusion:** Cobertura completa. No hay combinaciones huerfanas que requieran tratamiento especial con COALESCE (aunque se mantiene como practica defensiva).

### T-03: Rango de % Cumplimiento

**Objetivo:** Validar que los porcentajes calculados estan en un rango logico (sin anomalias por division, negativos o valores extremos).

```sql
-- Resultado:
-- MIN_PCT: 68.97%
-- MAX_PCT: 95.24%
-- AVG_PCT: 87.18%
-- NEGATIVOS: 0
-- MAYORES_200: 0
```

**Conclusion:** Todos los valores de cumplimiento son positivos y menores al 100%, lo cual es consistente con el hallazgo de que ninguna combinacion supera la meta planificada en el agregado.

### T-04: Integridad Referencial y Calidad

**Objetivo:** Validar que no existen registros huerfanos en los joins clave, y documentar la presencia de ingresos negativos.

```sql
-- Resultado:
-- VENTAS_SIN_PRODUCTO: 0
-- METAS_SIN_CAMPANA: 0
-- REGISTROS_INGRESO_NEGATIVO: 569,114
-- PCT_NEGATIVOS: 25.87%
```

**Conclusion:** Integridad referencial intacta. Los registros con ingreso negativo representan devoluciones y descuentos aplicados — comportamiento esperado en el modelo de venta directa de Belcorp. No se excluyen del analisis ya que reflejan el ingreso neto real.

### T-05: Validacion Cruzada

**Objetivo:** Verificar que la suma de los resultados parciales (Query 1 por combinacion) es consistente con los totales agregados (Query 4 por pais).

```sql
-- Resultado:
-- TOTAL_PLANIFICADO: $36,935,390.67
-- TOTAL_MUST_HAVE: $33,241,852.05
-- TOTAL_VENTA_REAL: $31,936,919.03
-- PCT_GLOBAL: 86.47%
```

**Conclusion:** El cumplimiento global (86.47%) es consistente con el promedio ponderado por combinacion (87.18%). La diferencia se explica por el efecto de ponderacion (combinaciones con mayor planificacion tienen mayor peso en el calculo global).

---

*Ejecutado: 21 Abr 2026 | Base: BELCORP_ANALYTICS.COMERCIAL | Campanas evaluadas: C10-C15 2025*
