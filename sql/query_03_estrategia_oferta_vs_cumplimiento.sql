-- ============================================================================
-- QUERY 3: Correlacion entre estrategia de oferta y nivel de cumplimiento
-- Ticket: DST-847 | Criterio de Aceptacion #3
-- Tablas: VENTAS, PRODUCTOS, METAS_CAMPANA, CAMPANAS
-- ============================================================================

WITH ultimas_campanas AS (
    SELECT CAMPANA_ID
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

ventas_detalle AS (
    SELECT
        v.CAMPANA_ID,
        p.MARCA_ID,
        p.CATEGORIA_ID,
        v.ESTRATEGIA_OFERTA,
        v.INGRESO_NETO
    FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
    JOIN BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE v.CAMPANA_ID IN (SELECT CAMPANA_ID FROM ultimas_campanas)
),

venta_total AS (
    SELECT CAMPANA_ID, MARCA_ID, CATEGORIA_ID, SUM(INGRESO_NETO) AS VENTA_REAL
    FROM ventas_detalle
    GROUP BY CAMPANA_ID, MARCA_ID, CATEGORIA_ID
),

clasificacion AS (
    SELECT
        vt.CAMPANA_ID, vt.MARCA_ID, vt.CATEGORIA_ID,
        CASE WHEN vt.VENTA_REAL >= mc.MUST_HAVE_VENTA THEN 'Cumple' ELSE 'No Cumple' END AS ESTADO_MH
    FROM venta_total vt
    JOIN BELCORP_ANALYTICS.COMERCIAL.METAS_CAMPANA mc
        ON vt.CAMPANA_ID = mc.CAMPANA_ID
        AND vt.MARCA_ID = mc.MARCA_ID
        AND vt.CATEGORIA_ID = mc.CATEGORIA_ID
)

SELECT
    vd.ESTRATEGIA_OFERTA,
    cl.ESTADO_MH,
    COUNT(*)                    AS NUM_TRANSACCIONES,
    ROUND(SUM(vd.INGRESO_NETO), 2) AS INGRESO_TOTAL,
    ROUND(AVG(vd.INGRESO_NETO), 2) AS TICKET_PROMEDIO
FROM ventas_detalle vd
JOIN clasificacion cl
    ON vd.CAMPANA_ID = cl.CAMPANA_ID
    AND vd.MARCA_ID = cl.MARCA_ID
    AND vd.CATEGORIA_ID = cl.CATEGORIA_ID
GROUP BY vd.ESTRATEGIA_OFERTA, cl.ESTADO_MH
ORDER BY vd.ESTRATEGIA_OFERTA, cl.ESTADO_MH;
