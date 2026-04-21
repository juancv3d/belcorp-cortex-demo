# EVIDENCIA DE PRUEBAS — DST-847

## Resumen

| Test | Descripcion | Resultado |
|------|------------|-----------|
| T-01 | Filtro temporal: ultimas 6 campanas finalizadas | PASS — 6 periodos, 36 campanas, 6 paises |
| T-02 | Valor original 'Cerrada' retorna 0 filas | PASS — Confirma error corregido |
| T-03 | Columna NOMBRE_MARCA existe, NOMBRE no | PASS — Confirma error corregido |
| T-04 | Clasificacion usa MUST_HAVE_VENTA correctamente | PASS — 289 Cumple + 359 Por Debajo = 648 |
| T-05 | Validacion cruzada: 648 filas esperadas | PASS |

## Detalle

### T-01: Filtro Temporal
6 periodos distintos, 36 campanas (6x6 paises), rango C10-C15 2025.

### T-02: Error Original Cerrada
`SELECT COUNT(*) FROM CAMPANAS WHERE ESTADO = 'Cerrada'` retorna 0. El SQL original nunca retornaba datos.

### T-03: Columna Correcta
MARCAS tiene: MARCA_ID, NOMBRE_MARCA, SEGMENTO_MARCA. No existe columna NOMBRE.

### T-04: Clasificacion
- Cumple Must-Have: 289 combinaciones (44.6%)
- Por Debajo Must-Have: 359 combinaciones (55.4%)
- Supera Meta: 0 combinaciones

### T-05: Completitud
648 metas en periodo = 648 filas en resultado. Cobertura completa.

---

*Ejecutado: 21 Abr 2026 | Base: BELCORP_ANALYTICS.COMERCIAL*
