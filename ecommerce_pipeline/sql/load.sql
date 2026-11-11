USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS TRANSFORM_WH 
  WITH WAREHOUSE_SIZE = 'X-SMALL' 
  AUTO_SUSPEND = 60 
  AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS RAW_DATA;
CREATE SCHEMA IF NOT EXISTS RAW_DATA.ECOMMERCE;

CREATE OR REPLACE TABLE RAW_DATA.ECOMMERCE.RAW_ORDERS (
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    raw_json VARIANT
);

INSERT INTO RAW_DATA.ECOMMERCE.RAW_ORDERS (raw_json)
SELECT PARSE_JSON(column1) FROM VALUES
  ('{"order_id": 101, "customer": {"id": 1, "name": "Alice"}, "amount": 50.00, "status": "completed"}'),
  ('{"order_id": 102, "customer": {"id": 2, "name": "Bob"}, "amount": 120.50, "status": "completed"}'),
  ('{"order_id": 103, "customer": {"id": 1, "name": "Alice"}, "amount": -15.00, "status": "refunded"}'),
  ('{"order_id": 104, "customer": {"id": 3, "name": "Charlie"}, "amount": 75.00, "status": "pending"}');

SELECT * FROM RAW_DATA.ECOMMERCE.RAW_ORDERS;
