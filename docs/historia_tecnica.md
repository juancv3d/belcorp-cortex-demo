# DEFINICION TECNICA — DST-847

## FUENTES DE DATOS

| Tabla | Descripcion | Columnas Relevantes |
|-------|-------------|-------------------|
| BELCORP_ANALYTICS.COMERCIAL.CAMPANAS | Campanas comerciales por pais | CAMPANA_ID, PAIS, ANIO, NUMERO_CAMPANA, ESTADO, FECHA_FIN |
| BELCORP_ANALYTICS.COMERCIAL.METAS_CAMPANA | Metas de venta por marca-categoria-campana | META_ID, CAMPANA_ID, MARCA_ID, CATEGORIA_ID, VENTA_PLANIFICADA, MUST_HAVE_VENTA |
| BELCORP_ANALYTICS.COMERCIAL.VENTAS | Transacciones de venta por consultora | VENTA_ID, CAMPANA_ID, PRODUCTO_ID, INGRESO_NETO |
| BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS | Catalogo de productos | PRODUCTO_ID, MARCA_ID, CATEGORIA_ID |
| BELCORP_ANALYTICS.COMERCIAL.MARCAS | Marcas Belcorp | MARCA_ID, NOMBRE_MARCA (Esika, LBel, Cyzone) |
| BELCORP_ANALYTICS.COMERCIAL.CATEGORIAS | Categorias de producto | CATEGORIA_ID, NOMBRE_CATEGORIA |

## ERRORES CORREGIDOS EN SQL EXISTENTE

Se revisaron 59 lineas del archivo `sql/analisis_cumplimiento.sql` y se detectaron 7 errores:

| # | Error | Correccion | Linea |
|---|-------|------------|-------|
| 1 | ESTADO = Cerrada (valor inexistente) | Cambiado a Finalizada | 13 |
| 2 | ESTADO = Cerrada (repetido en subquery) | Cambiado a Finalizada | 18 |
| 3 | LIMIT 3 (historia pide 6 campanas) | Cambiado a LIMIT 6 | 20 |
| 4 | m.NOMBRE (columna inexistente en MARCAS) | Cambiado a m.NOMBRE_MARCA | 41 |
| 5 | Falta MUST_HAVE_VENTA en SELECT | Agregado mc.MUST_HAVE_VENTA | 43 |
| 6 | Clasificacion usa VENTA_PLANIFICADA * 0.9 (arbitrario) | Cambiado a mc.MUST_HAVE_VENTA (umbral real Belcorp) | 49 |
| 7 | JOIN excluye metas sin ventas | Cambiado a LEFT JOIN para incluir cumplimiento 0% | 56 |

## LOGICA DE NEGOCIO

- **Periodo**: Ultimas 6 campanas con ESTADO = Finalizada, identificadas por las 6 FECHA_FIN mas recientes
- **Cruce metas vs ventas**: METAS_CAMPANA define la meta por marca-categoria-campana; VENTAS se agrupa por CAMPANA_ID + MARCA_ID + CATEGORIA_ID via PRODUCTOS
- **% Cumplimiento**: VENTA_REAL / VENTA_PLANIFICADA * 100
- **Clasificacion**:
  - Supera Meta: venta real >= venta planificada
  - Cerca de Meta: venta real >= MUST_HAVE_VENTA (umbral minimo Belcorp)
  - Bajo: venta real < MUST_HAVE_VENTA
- **LEFT JOIN**: Garantiza que combinaciones marca-categoria sin ventas aparezcan con VENTA_REAL = 0

## SQL CORREGIDO Y VALIDADO

Archivo: `sql/analisis_cumplimiento.sql` (corregido in-place, 7 errores resueltos)
Resultado: Query ejecutado exitosamente, retorna datos para 6 paises x 3 marcas x 6 categorias x 6 campanas
