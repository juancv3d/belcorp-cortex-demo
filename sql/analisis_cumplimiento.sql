-- ============================================================================
-- ANALISIS DE CUMPLIMIENTO DE METAS POR MARCA-CATEGORIA
-- Ticket: DST-847
-- Autor: Analista Jr. - Equipo Data Strategy
-- Fecha: 10 Abr 2026
-- Descripcion: Query para evaluar cumplimiento de metas de venta planificada
--              vs ventas reales por marca, categoria y pais.
-- ============================================================================

WITH ultimas_campanas AS (
    SELECT CAMPANA_ID, PAIS, ANIO, NUMERO_CAMPANA
    FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
    WHERE ESTADO = 'Finalizada'
      AND FECHA_FIN >= (
          SELECT MIN(FECHA_FIN) FROM (
              SELECT DISTINCT FECHA_FIN
              FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
              WHERE ESTADO = 'Finalizada'
              ORDER BY FECHA_FIN DESC
              LIMIT 6
          )
      )
),

ventas_reales AS (
    SELECT
        v.CAMPANA_ID,
        p.MARCA_ID,
        p.CATEGORIA_ID,
        SUM(v.INGRESO_NETO) AS VENTA_REAL
    FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
    JOIN BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE v.CAMPANA_ID IN (SELECT CAMPANA_ID FROM ultimas_campanas)
    GROUP BY v.CAMPANA_ID, p.MARCA_ID, p.CATEGORIA_ID
)

SELECT
    c.PAIS,
    c.ANIO,
    c.NUMERO_CAMPANA,
    m.NOMBRE_MARCA,
    cat.NOMBRE_CATEGORIA,
    mc.VENTA_PLANIFICADA,
    mc.MUST_HAVE_VENTA,
    COALESCE(vr.VENTA_REAL, 0)                                                    AS VENTA_REAL,
    ROUND(COALESCE(vr.VENTA_REAL, 0) / NULLIF(mc.VENTA_PLANIFICADA, 0) * 100, 2) AS PCT_CUMPLIMIENTO,
    CASE
        WHEN COALESCE(vr.VENTA_REAL, 0) >= mc.VENTA_PLANIFICADA THEN 'Supera Meta'
        WHEN COALESCE(vr.VENTA_REAL, 0) >= mc.MUST_HAVE_VENTA THEN 'Cerca de Meta'
        ELSE 'Bajo'
    END AS CLASIFICACION
FROM BELCORP_ANALYTICS.COMERCIAL.METAS_CAMPANA mc
JOIN ultimas_campanas c ON mc.CAMPANA_ID = c.CAMPANA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.MARCAS m ON mc.MARCA_ID = m.MARCA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.CATEGORIAS cat ON mc.CATEGORIA_ID = cat.CATEGORIA_ID
LEFT JOIN ventas_reales vr ON mc.CAMPANA_ID = vr.CAMPANA_ID
    AND mc.MARCA_ID = vr.MARCA_ID
    AND mc.CATEGORIA_ID = vr.CATEGORIA_ID
ORDER BY c.PAIS, c.NUMERO_CAMPANA, m.NOMBRE_MARCA, cat.NOMBRE_CATEGORIA;
