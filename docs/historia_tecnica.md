# HISTORIA TECNICA — DST-847

## 1. Informacion General

| Campo | Valor |
|-------|-------|
| Ticket Origen | DST-847 |
| Tipo | Analisis y Medicion de Impacto |
| Base de Datos | BELCORP_ANALYTICS |
| Schema | COMERCIAL |
| Tech Lead | @Pendiente de asignacion |

## 2. Mapeo de Tablas Fuente

### 2.1 Tablas Principales

| Tabla | Columnas Clave | Registros | Rol en el Analisis |
|-------|---------------|-----------|-------------------|
| METAS_CAMPANA | META_ID, CAMPANA_ID, MARCA_ID, CATEGORIA_ID, VENTA_PLANIFICADA, MUST_HAVE_VENTA | 3,888 | Metas planificadas por marca-categoria-campana |
| VENTAS | VENTA_ID, CAMPANA_ID, PRODUCTO_ID, ESTRATEGIA_OFERTA, INGRESO_NETO | 2,200,000+ | Ventas reales a nivel transaccion |
| CAMPANAS | CAMPANA_ID, PAIS, ANIO, NUMERO_CAMPANA, ESTADO | 216 | Dimension temporal y geografica |
| PRODUCTOS | PRODUCTO_ID, MARCA_ID, CATEGORIA_ID | 309 | Puente entre VENTAS y dimensiones marca/categoria |
| MARCAS | MARCA_ID, NOMBRE_MARCA | 3 | L'Bel, Esika, Cyzone |
| CATEGORIAS | CATEGORIA_ID, NOMBRE_CATEGORIA | 6 | Maquillaje, Fragancias, Cuidado Facial, etc. |

### 2.2 Modelo de Joins

```
METAS_CAMPANA (granularidad: campana x marca x categoria)
    |-- JOIN CAMPANAS       ON CAMPANA_ID    → filtro ultimas 6 finalizadas
    |-- JOIN MARCAS          ON MARCA_ID
    |-- JOIN CATEGORIAS      ON CATEGORIA_ID
    |-- LEFT JOIN ventas_agg ON CAMPANA_ID + MARCA_ID + CATEGORIA_ID
            |-- VENTAS JOIN PRODUCTOS ON PRODUCTO_ID → agrega INGRESO_NETO
```

### 2.3 Filtro Temporal

Ultimas 6 campanas con `ESTADO = 'Finalizada'` (campanas 10 a 15 de 2025), cubriendo 6 paises: Peru, Bolivia, Mexico, Colombia, Ecuador, Chile.

### 2.4 Notas de Datos

- La marca Esika se almacena como `Esika` (con acento en la e)
- Existen 2,623 registros con INGRESO_NETO negativo — corresponden a devoluciones/descuentos (comportamiento esperado)
- METAS_CAMPANA no tiene columna PAIS directamente; se obtiene via JOIN con CAMPANAS

## 3. Queries por Criterio de Aceptacion

### CA-1: % de cumplimiento por marca-categoria-campana

**Archivo:** `sql/query_01_cumplimiento_marca_categoria.sql`

**Logica:** Cruza METAS_CAMPANA con ventas reales agregadas por campana-marca-categoria. Calcula PCT_CUMPLIMIENTO y clasifica en: Supera Meta / Cumple Must-Have / Por Debajo Must-Have.

**Resultado:** 648 filas (6 paises x 6 campanas x 3 marcas x 6 categorias)

### CA-2: Combinaciones bajo must-have

**Archivo:** `sql/query_02_combinaciones_bajo_must_have.sql`

**Logica:** Agrupa por marca-categoria-pais y cuenta en cuantas de las 6 campanas la venta real quedo por debajo del must-have.

**Resultado:** 103 combinaciones con al menos 1 incumplimiento

**Hallazgo clave:** L'Bel presenta 100% de incumplimiento en las 6 categorias y los 6 paises durante las 6 campanas evaluadas (36 combinaciones criticas).

### CA-3: Estrategia de oferta vs cumplimiento

**Archivo:** `sql/query_03_estrategia_oferta_vs_cumplimiento.sql`

**Logica:** Clasifica cada combinacion campana-marca-categoria como "Cumple"/"No Cumple" must-have, luego analiza la distribucion de transacciones e ingresos por estrategia de oferta en cada grupo.

**Resultado:** 12 filas (6 estrategias x 2 estados)

**Hallazgo:** No se identifica correlacion significativa entre la estrategia de oferta predominante y el cumplimiento de metas. La distribucion de estrategias es homogenea entre combinaciones que cumplen y las que no.

### CA-4: Ranking de paises

**Archivo:** `sql/query_04_ranking_paises.sql`

**Logica:** Agrega venta planificada, must-have y venta real por pais. Calcula % de cumplimiento y ranking.

**Resultado:**

| Ranking | Pais | % Cumplimiento Plan | % Cumplimiento MH | Combinaciones Criticas |
|---------|------|--------------------|--------------------|----------------------|
| 1 | Mexico | 87.05% | 96.72% | 50.9% |
| 2 | Chile | 86.94% | 96.60% | 53.7% |
| 3 | Bolivia | 86.69% | 96.32% | 50.9% |
| 4 | Ecuador | 86.63% | 96.25% | 61.1% |
| 5 | Peru | 86.19% | 95.77% | 54.6% |
| 6 | Colombia | 85.29% | 94.77% | 61.1% |

**Hallazgo:** Mexico lidera en cumplimiento; Colombia presenta el menor desempeno relativo con 61.1% de combinaciones criticas.

## 4. Validacion

- [x] Todos los queries ejecutan sin errores
- [x] Conteo de filas consistente con dimensionalidad esperada (648 = 6x6x3x6)
- [x] Join METAS_CAMPANA-VENTAS validado via CAMPANA_ID + MARCA_ID + CATEGORIA_ID
- [x] Registros negativos de INGRESO_NETO identificados como devoluciones (no anomalia)
