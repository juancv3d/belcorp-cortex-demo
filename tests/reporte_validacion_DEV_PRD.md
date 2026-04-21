# REPORTE DE VALIDACION CROSS-ENVIRONMENT
## DST-912 | DEV vs PRD | 21 Abr 2026

### Resumen Ejecutivo

| Metrica | Valor |
|---------|-------|
| Tests ejecutados | 5 |
| PASS | 0 |
| FAIL | 3 |
| WARNING | 2 |
| Recomendacion | **RECHAZAR DEPLOY** |

### Hallazgos por Severidad

#### Criticos

1. **Schema incompatible (TC-01)**: DEV.CONSULTORAS tiene estructura diferente a PRD.CONSULTORAS
   - Columnas faltantes en DEV: PAIS, REGION, NIVEL
   - Columna diferente: DEV tiene ZONA_ID (NUMBER) vs PRD tiene ZONA (TEXT)
   - Impacto: Queries que referencien PAIS, REGION o NIVEL fallaran en DEV

2. **Data drift masivo (TC-03)**: Los 200 registros compartidos tienen valores diferentes
   - NOMBRE: 200/200 diferentes (100%)
   - FECHA_INGRESO: 200/200 diferentes (100%)
   - SEGMENTO: 155/200 diferentes (77.5%)
   - ESTADO: 87/200 diferentes (43.5%)
   - Impacto: Los datos de DEV no representan el estado real de produccion

3. **Completitud insuficiente (TC-04)**: DEV contiene solo una fraccion de PRD
   - CONSULTORAS: 49,800 registros en PRD sin match en DEV (99.6% faltante)
   - VENTAS: 2,138,857 registros en PRD sin match en DEV (97.2% faltante)
   - Impacto: Tests en DEV no son representativos del volumen de produccion

#### Advertencias

4. **Volumetria desproporcionada (TC-02)**:
   - CONSULTORAS: DEV tiene 200 vs PRD 50,000 (99.6% diferencia)
   - VENTAS: DEV tiene 61,143 vs PRD 2,200,000 (97.2% diferencia)
   - CAMPANAS: Iguales (216 en ambos) - OK

#### Informativos

- No se encontraron registros en DEV ausentes en PRD (0 huerfanos)
- CAMPANAS es la unica tabla sincronizada correctamente

### Detalle de Ejecucion

| ID | Test | Estado | Hallazgo |
|----|------|--------|----------|
| TC-01 | Schema comparison CONSULTORAS | FAIL | 3 columnas faltantes en DEV, 1 columna con tipo diferente |
| TC-02 | Row count comparison (3 tablas) | WARNING | CONSULTORAS -99.6%, VENTAS -97.2%, CAMPANAS 0% |
| TC-03 | Data drift CONSULTORAS (campos compartidos) | FAIL | NOMBRE 100%, SEGMENTO 77.5%, ESTADO 43.5%, FECHA 100% |
| TC-04 | Completitud CONSULTORAS y VENTAS | FAIL | 49,800 consultoras y 2.1M ventas faltantes en DEV |
| TC-05 | Muestra de registros con drift | INFO | Ejemplos concretos documentados (IDs 1-5) |

### Ejemplos de Data Drift

| ID | NOMBRE PRD | NOMBRE DEV | SEGMENTO PRD | SEGMENTO DEV | ESTADO PRD | ESTADO DEV |
|----|-----------|-----------|-------------|-------------|-----------|-----------|
| 1 | Lorena Vargas | Isabel Morales | Baja | Baja | Retirada | Activa |
| 2 | Liliana Mendoza | Rosa Flores | Baja | Media | Activa | Activa |
| 3 | Fernanda Herrera | Claudia Ramirez | Nueva | Baja | Activa | Activa |
| 4 | Pilar Cruz | Camila Flores | Baja | Baja | Activa | Activa |
| 5 | Camila Medina | Andrea Rivera | Baja | Baja | Retirada | Activa |

### Recomendacion

**RECHAZAR el deploy a produccion.** Se identificaron 3 hallazgos criticos que deben resolverse:

1. Alinear el schema de DEV.CONSULTORAS para incluir las columnas PAIS, REGION y NIVEL
2. Sincronizar los datos de DEV con PRD para que los registros compartidos tengan valores consistentes
3. Cargar un volumen representativo de datos en DEV antes de certificar

---

*Generado automaticamente por Cortex Code | Skill: belcorp-testing | Ticket: DST-912*
