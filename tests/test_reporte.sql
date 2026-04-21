-- =============================================================
-- Test Cases: Top 10 Consultoras por Ingreso Neto
-- Generado por Cortex Code via skill belcorp-user-story
-- =============================================================

-- TEST 1: Integridad referencial - Todas las consultoras en VENTAS existen en CONSULTORAS
-- Esperado: 0 filas (no hay huerfanos)
SELECT COUNT(*) AS CONSULTORAS_HUERFANAS
FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
LEFT JOIN BELCORP_ANALYTICS.COMERCIAL.CONSULTORAS c ON v.CONSULTORA_ID = c.CONSULTORA_ID
WHERE c.CONSULTORA_ID IS NULL;

-- TEST 2: Integridad referencial - Todos los productos en VENTAS existen en PRODUCTOS
-- Esperado: 0 filas
SELECT COUNT(*) AS PRODUCTOS_HUERFANOS
FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
LEFT JOIN BELCORP_ANALYTICS.COMERCIAL.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
WHERE p.PRODUCTO_ID IS NULL;

-- TEST 3: Existe al menos una campana finalizada
-- Esperado: >= 1
SELECT COUNT(*) AS CAMPANAS_FINALIZADAS
FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
WHERE ESTADO = 'Finalizada';

-- TEST 4: Ingreso neto es positivo en la ultima campana
-- Esperado: 0 filas con ingreso negativo
WITH ultima_campana AS (
    SELECT CAMPANA_ID FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
    WHERE ESTADO = 'Finalizada' ORDER BY FECHA_FIN DESC LIMIT 1
)
SELECT COUNT(*) AS INGRESOS_NEGATIVOS
FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS
WHERE CAMPANA_ID = (SELECT CAMPANA_ID FROM ultima_campana)
  AND INGRESO_NETO < 0;

-- TEST 5: El reporte retorna exactamente 10 filas
-- Esperado: 10
WITH ultima_campana AS (
    SELECT CAMPANA_ID FROM BELCORP_ANALYTICS.COMERCIAL.CAMPANAS
    WHERE ESTADO = 'Finalizada' ORDER BY FECHA_FIN DESC LIMIT 1
)
SELECT COUNT(*) AS TOTAL_FILAS
FROM (
    SELECT c.CONSULTORA_ID
    FROM BELCORP_ANALYTICS.COMERCIAL.VENTAS v
    JOIN BELCORP_ANALYTICS.COMERCIAL.CONSULTORAS c ON v.CONSULTORA_ID = c.CONSULTORA_ID
    WHERE v.CAMPANA_ID = (SELECT CAMPANA_ID FROM ultima_campana)
    GROUP BY c.CONSULTORA_ID
    ORDER BY SUM(v.INGRESO_NETO) DESC
    LIMIT 10
);

-- TEST 6: Las 3 marcas existen en el sistema
-- Esperado: Ésika, L'Bel, Cyzone
SELECT NOMBRE_MARCA FROM BELCORP_ANALYTICS.COMERCIAL.MARCAS ORDER BY MARCA_ID;
