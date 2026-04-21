-- ============================================================================
-- QUERY 4: Ranking de paises por cumplimiento relativo respecto a metas
-- Ticket: DST-847 | Criterio de Aceptacion #4
-- Tablas: METAS_CAMPANA, VENTAS, PRODUCTOS, CAMPANAS, MARCAS, CATEGORIAS
-- ============================================================================

WITH ultimas_campanas AS (
    SELECT CAMPANA_ID, PAIS, NUMERO_CAMPANA
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
    SUM(mc.VENTA_PLANIFICADA)                                                         AS TOTAL_PLANIFICADO,
    SUM(mc.MUST_HAVE_VENTA)                                                            AS TOTAL_MUST_HAVE,
    SUM(COALESCE(vr.VENTA_REAL, 0))                                                    AS TOTAL_VENTA_REAL,
    ROUND(SUM(COALESCE(vr.VENTA_REAL, 0)) / NULLIF(SUM(mc.VENTA_PLANIFICADA), 0) * 100, 2) AS PCT_CUMPLIMIENTO_PLAN,
    ROUND(SUM(COALESCE(vr.VENTA_REAL, 0)) / NULLIF(SUM(mc.MUST_HAVE_VENTA), 0) * 100, 2)  AS PCT_CUMPLIMIENTO_MH,
    SUM(CASE WHEN COALESCE(vr.VENTA_REAL, 0) < mc.MUST_HAVE_VENTA THEN 1 ELSE 0 END) AS COMBINACIONES_BAJO_MH,
    COUNT(*)                                                                            AS TOTAL_COMBINACIONES,
    ROUND(SUM(CASE WHEN COALESCE(vr.VENTA_REAL, 0) < mc.MUST_HAVE_VENTA THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 1)                                                           AS PCT_COMBINACIONES_CRITICAS,
    RANK() OVER (ORDER BY SUM(COALESCE(vr.VENTA_REAL, 0)) / NULLIF(SUM(mc.VENTA_PLANIFICADA), 0) DESC) AS RANKING
FROM BELCORP_ANALYTICS.COMERCIAL.METAS_CAMPANA mc
JOIN ultimas_campanas c ON mc.CAMPANA_ID = c.CAMPANA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.MARCAS m      ON mc.MARCA_ID = m.MARCA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.CATEGORIAS cat ON mc.CATEGORIA_ID = cat.CATEGORIA_ID
LEFT JOIN ventas_reales vr ON mc.CAMPANA_ID = vr.CAMPANA_ID
    AND mc.MARCA_ID = vr.MARCA_ID
    AND mc.CATEGORIA_ID = vr.CATEGORIA_ID
GROUP BY c.PAIS
ORDER BY RANKING;
