
USE pricing_rgm;

-- =========================================================
-- PRICING & REVENUE GROWTH MANAGEMENT (RGM) ANALYSIS
-- Dataset: dunnhumby - Breakfast at the Frat
-- Purpose: Analyze pricing and promotional performance
-- =========================================================


-- 1. PROMOTIONAL PERFORMANCE FOR SELECTED PRODUCT
-- Product UPC: 3800039118
-- Compare sales, units, prices and discounts by promotion type.

SELECT
    CASE
        WHEN FEATURE = 1 AND DISPLAY = 1 THEN 'Feature + Display'
        WHEN FEATURE = 1 THEN 'Feature Only'
        WHEN DISPLAY = 1 THEN 'Display Only'
        WHEN TPR_ONLY = 1 THEN 'TPR Only'
        ELSE 'No Promotion'
    END AS promotion_type,
    COUNT(*) AS records,
    ROUND(AVG(PRICE), 2) AS avg_price,
    ROUND(AVG(BASE_PRICE), 2) AS avg_base_price,
    ROUND(
        AVG((BASE_PRICE - PRICE) / NULLIF(BASE_PRICE, 0)) * 100,
        2
    ) AS avg_discount_pct,
    ROUND(AVG(UNITS), 2) AS avg_units,
    ROUND(AVG(SPEND), 2) AS avg_sales_per_record,
    ROUND(SUM(SPEND), 2) AS total_sales
FROM transaction_data_final
WHERE UPC = '3800039118'
GROUP BY promotion_type
ORDER BY avg_sales_per_record DESC;


-- 2. PROMOTIONAL PERFORMANCE ACROSS THE DATASET
-- Compare promotional flags and average commercial metrics.

SELECT
    FEATURE,
    DISPLAY,
    TPR_ONLY,
    COUNT(*) AS records,
    ROUND(AVG(UNITS), 2) AS avg_units,
    ROUND(AVG(PRICE), 2) AS avg_price,
    ROUND(AVG(BASE_PRICE), 2) AS avg_base_price,
    ROUND(AVG(SPEND), 2) AS avg_sales_per_record,
    ROUND(SUM(SPEND), 2) AS total_sales
FROM transaction_data_final
GROUP BY FEATURE, DISPLAY, TPR_ONLY
ORDER BY avg_units DESC;


-- 3. SALES PERFORMANCE BY PROMOTION TYPE
-- Categorize records and compare average sales and units.
-- CASE order determines the category if flags overlap.

SELECT
    CASE
        WHEN FEATURE = 1 AND DISPLAY = 1 AND TPR_ONLY = 0
            THEN 'Feature + Display'
        WHEN FEATURE = 1 AND DISPLAY = 0 AND TPR_ONLY = 0
            THEN 'Feature Only'
        WHEN FEATURE = 0 AND DISPLAY = 1 AND TPR_ONLY = 0
            THEN 'Display Only'
        WHEN FEATURE = 0 AND DISPLAY = 0 AND TPR_ONLY = 1
            THEN 'TPR Only'
        WHEN FEATURE = 0 AND DISPLAY = 0 AND TPR_ONLY = 0
            THEN 'No Promotion'
        ELSE 'Other / Overlapping Flags'
    END AS promotion_type,
    COUNT(*) AS records,
    ROUND(AVG(UNITS), 2) AS avg_units,
    ROUND(AVG(SPEND), 2) AS avg_sales_per_record,
    ROUND(AVG(PRICE), 2) AS avg_price
FROM transaction_data_final
GROUP BY promotion_type
ORDER BY avg_sales_per_record DESC;


-- 4. DISCOUNT BAND ANALYSIS
-- Compare average units and sales across discount levels.

SELECT
    CASE
        WHEN BASE_PRICE IS NULL OR BASE_PRICE = 0
            THEN 'Invalid Base Price'
        WHEN PRICE >= BASE_PRICE
            THEN 'No Discount'
        WHEN (BASE_PRICE - PRICE) / BASE_PRICE < 0.10
            THEN 'Below 10%'
        WHEN (BASE_PRICE - PRICE) / BASE_PRICE <= 0.20
            THEN '10%-20%'
        ELSE 'Above 20%'
    END AS discount_band,
    COUNT(*) AS records,
    ROUND(AVG(UNITS), 2) AS avg_units,
    ROUND(AVG(PRICE), 2) AS avg_price,
    ROUND(AVG(SPEND), 2) AS avg_sales_per_record
FROM transaction_data_final
GROUP BY discount_band
ORDER BY avg_units DESC;


-- 5. DATA QUALITY CHECK: PROMOTION FLAG OVERLAP
-- Identify combinations of promotional flags in the source data.

SELECT
    FEATURE,
    DISPLAY,
    TPR_ONLY,
    COUNT(*) AS records
FROM transaction_data_final
GROUP BY FEATURE, DISPLAY, TPR_ONLY
ORDER BY records DESC;


-- INTERPRETATION NOTE:
-- These queries provide descriptive comparisons, not causal estimates.
-- Higher average sales during a promotion do not prove incremental impact.
-- Product costs and promotional costs are required to calculate
-- contribution margin and promotional ROI.
