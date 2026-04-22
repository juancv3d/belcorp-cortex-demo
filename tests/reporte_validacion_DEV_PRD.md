# REPORTE DE VALIDACION CROSS-ENVIRONMENT
## DST-912 | DEV vs PRD

### Resumen Ejecutivo

| Metrica | Valor |
|---------|-------|
| Tests ejecutados | 10 |
| PASS | 3 |
| FAIL | 7 |
| WARNING | 0 |

**Recomendacion: RECHAZAR DEPLOY** — Se detectaron 7 hallazgos criticos que impiden la promocion a produccion.

---

### Hallazgos por Severidad

#### Criticos

1. **Schema CONSULTORAS incompatible**: DEV tiene 6 columnas, PRD tiene 9. Faltan en DEV: NIVEL, PAIS, REGION, ZONA. DEV tiene ZONA_ID (no existe en PRD).
2. **Volumetria CONSULTORAS**: DEV tiene 200 registros vs 50,000 en PRD (99.60% gap). Solo 0.4% de los datos de produccion estan representados.
3. **Volumetria VENTAS**: DEV tiene 61,143 registros vs 2,200,000 en PRD (97.22% gap).
4. **Data Drift CONSULTORAS**: De los 200 registros compartidos, 100% tienen NOMBRE diferente, 100% FECHA_INGRESO diferente, 77.5% SEGMENTO diferente, 43.5% ESTADO diferente.
5. **Completitud CONSULTORAS**: 49,800 registros en PRD no existen en DEV.
6. **Completitud VENTAS**: 2,138,857 registros en PRD no existen en DEV.
7. **Integridad referencial DEV**: 60,921 ventas en DEV referencian CONSULTORA_IDs que no existen en DEV.CONSULTORAS — indica que la tabla CONSULTORAS de DEV es un subset incompleto.

#### Advertencias

Ninguna.

#### Informativos

Ninguno.

---

### Detalle de Ejecucion

| ID | Test | Estado | Hallazgo |
|----|------|--------|----------|
| TC-01 | Schema CONSULTORAS DEV vs PRD | FAIL | DEV: 6 columnas, PRD: 9 columnas. Faltan: NIVEL, PAIS, REGION, ZONA. Extra en DEV: ZONA_ID |
| TC-02 | Schema VENTAS DEV vs PRD | PASS | 11 columnas identicas en ambos ambientes |
| TC-03 | Schema CAMPANAS DEV vs PRD | PASS | 7 columnas identicas en ambos ambientes |
| TC-04 | Volumetria CONSULTORAS | FAIL | PRD: 50,000 / DEV: 200 / Gap: 99.60% |
| TC-05 | Volumetria VENTAS | FAIL | PRD: 2,200,000 / DEV: 61,143 / Gap: 97.22% |
| TC-06 | Volumetria CAMPANAS | PASS | PRD: 216 / DEV: 216 / Gap: 0% |
| TC-07 | Data Drift CONSULTORAS | FAIL | NOMBRE: 100%, FECHA_INGRESO: 100%, SEGMENTO: 77.5%, ESTADO: 43.5% |
| TC-08 | Completitud CONSULTORAS | FAIL | 49,800 en PRD ausentes en DEV, 0 en DEV ausentes en PRD |
| TC-09 | Completitud VENTAS | FAIL | 2,138,857 en PRD ausentes en DEV, 0 en DEV ausentes en PRD |
| TC-10 | Integridad referencial VENTAS DEV | FAIL | 60,921 FKs huerfanas (CONSULTORA_ID sin match en DEV.CONSULTORAS) |

---

### Recomendacion

**RECHAZAR DEPLOY a produccion.**

Justificacion:
- El ambiente DEV no es representativo de PRD. Contiene solo 0.4% de consultoras y 2.8% de ventas.
- La tabla CONSULTORAS en DEV tiene un schema diferente (4 columnas faltantes, 1 extra) lo que indica que fue cargada desde una fuente diferente.
- El 100% de los registros compartidos tiene drift en campos clave (NOMBRE, FECHA_INGRESO), lo que sugiere que DEV fue cargado con datos de prueba, no con una copia de PRD.
- 60,921 ventas en DEV referencian consultoras inexistentes, rompiendo la integridad referencial.

**Acciones requeridas antes del deploy:**
1. Alinear schema de DEV.CONSULTORAS con PRD (agregar NIVEL, PAIS, REGION, ZONA; remover o mapear ZONA_ID)
2. Cargar un dataset representativo en DEV (minimo 10% del volumen de PRD)
3. Sincronizar datos de CONSULTORAS compartidas para eliminar drift
4. Resolver integridad referencial en VENTAS
