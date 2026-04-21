-- =============================================================
-- Reporte: Top 10 Consultoras por Ingreso Neto - Ultima Campana
-- Generado por Cortex Code via skill belcorp-user-story
-- =============================================================

WITH ultima_campana AS (
    SELECT CAMPANA_ID
    FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
    WHERE ESTADO = 'Finalizada'
    ORDER BY FECHA_FIN DESC
    LIMIT 1
)
SELECT
    c.CONSULTORA_ID,
    c.NOMBRE,
    c.ZONA,
    c.REGION,
    c.SEGMENTO,
    SUM(v.UNIDADES)                                                           AS TOTAL_UNIDADES,
    ROUND(SUM(v.INGRESO_NETO), 2)                                            AS INGRESO_NETO_TOTAL,
    ROUND(SUM(v.GANANCIA), 2)                                                AS GANANCIA_TOTAL,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'Ésika'  THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_ESIKA,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'L''Bel' THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_LBEL,
    ROUND(SUM(CASE WHEN m.NOMBRE_MARCA = 'Cyzone' THEN v.INGRESO_NETO ELSE 0 END), 2) AS INGRESO_CYZONE
FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
JOIN BELCORP_ANALYTICS.COMERCIAL.CONSULTORAS c ON v.CONSULTORA_ID = c.CONSULTORA_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS p   ON v.PRODUCTO_ID = p.PRODUCTO_ID
JOIN BELCORP_ANALYTICS.COMERCIAL.MARCAS m      ON p.MARCA_ID = m.MARCA_ID
WHERE v.CAMPANA_ID = (SELECT CAMPANA_ID FROM ultima_campana)
GROUP BY c.CONSULTORA_ID, c.NOMBRE, c.ZONA, c.REGION, c.SEGMENTO
ORDER BY INGRESO_NETO_TOTAL DESC
LIMIT 10;
