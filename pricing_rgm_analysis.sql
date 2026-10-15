
USE pricing_rgm;

SELECT
    CASE
        WHEN FEATURE = 1 AND DISPLAY = 1 THEN 'Feature + Display'
        WHEN FEATURE = 1 THEN 'Feature'
        WHEN DISPLAY = 1 THEN 'Display'
        WHEN TPR_ONLY = 1 THEN 'TPR'
        ELSE 'Sin promocion'
    END AS tipo_promocion,
    COUNT(*) AS registros,
    ROUND(AVG(PRICE), 2) AS precio_promedio,
    ROUND(AVG(BASE_PRICE), 2) AS precio_base_promedio,
    ROUND(AVG((BASE_PRICE - PRICE) / NULLIF(BASE_PRICE, 0)) * 100, 2)
        AS descuento_promedio_pct,
    ROUND(AVG(UNITS), 2) AS unidades_promedio,
    ROUND(AVG(SPEND), 2) AS ventas_promedio,
    ROUND(SUM(SPEND), 2) AS ventas_totales
FROM transaction_data_final
WHERE UPC = '3800039118'
GROUP BY tipo_promocion
ORDER BY ventas_promedio DESC;

-- 2. Promotional performance across the dataset
SELECT
    FEATURE,
    DISPLAY,
    TPR_ONLY,
    COUNT(*) AS registros,
    ROUND(AVG(UNITS), 2) AS unidades_promedio,
    ROUND(AVG(PRICE), 2) AS precio_promedio,
    ROUND(AVG(BASE_PRICE), 2) AS precio_base_promedio,
    ROUND(AVG(SPEND), 2) AS ventas_promedio
FROM transaction_data_final
GROUP BY FEATURE, DISPLAY, TPR_ONLY
ORDER BY unidades_promedio DESC;


-- 3. Sales and discount analysis by price segment
SELECT
    CASE
        WHEN PRICE < BASE_PRICE * 0.80 THEN 'Descuento > 20%'
        WHEN PRICE < BASE_PRICE * 0.90 THEN 'Descuento 10%-20%'
        WHEN PRICE < BASE_PRICE THEN 'Descuento < 10%'
        ELSE 'Sin descuento'
    END AS segmento_precio,
    COUNT(*) AS registros,
    ROUND(AVG(UNITS), 2) AS unidades_promedio,
    ROUND(AVG(PRICE), 2) AS precio_promedio,
    ROUND(AVG(SPEND), 2) AS ventas_promedio
FROM transaction_data_final
GROUP BY segmento_precio
ORDER BY unidades_promedio DESC;

