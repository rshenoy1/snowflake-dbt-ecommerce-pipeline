USE ROLE TRANSFORMER_ROLE;
USE WAREHOUSE TRANSFORM_WH;
USE DATABASE ANALYTICS;
USE SCHEMA DBT_DEV;

-- 1. Create a Dynamic Table that stays within 1 minute of RAW_ORDERS
CREATE OR REPLACE DYNAMIC TABLE DT_CUSTOMER_ORDER_SUMMARY
  TARGET_LAG = '1 minute'
  WAREHOUSE = TRANSFORM_WH
AS
SELECT
    raw_json:customer_id::INT AS customer_id,
    COUNT(DISTINCT raw_json:order_id::INT) AS total_orders,
    SUM(raw_json:amount::FLOAT) AS total_revenue,
    MAX(loaded_at) AS last_order_timestamp
FROM RAW_DATA.ECOMMERCE.RAW_ORDERS
WHERE raw_json:status::STRING != 'refunded'
GROUP BY 1;

-- 2. Query the Dynamic Table to verify it initialized with data
SELECT * FROM DT_CUSTOMER_ORDER_SUMMARY;

-- 3. Add a Clustering Key to FCT_ORDERS for fast customer lookups at scale
ALTER TABLE ANALYTICS.DBT_DEV.FCT_ORDERS CLUSTER BY (customer_id);

-- 4. Inspect clustering metadata (depth & overlap)
SELECT SYSTEM$CLUSTERING_INFORMATION('ANALYTICS.DBT_DEV.FCT_ORDERS', '(customer_id)');