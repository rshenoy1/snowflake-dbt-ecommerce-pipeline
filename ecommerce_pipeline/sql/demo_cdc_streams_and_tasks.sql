USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSFORM_WH;

-- ============================================================================
-- PART 1: STREAM CREATION & SIMULATED ARRIVAL
-- ============================================================================

-- 1. Create a Stream (bookmark) on RAW_ORDERS to track incoming rows
CREATE OR REPLACE STREAM RAW_DATA.ECOMMERCE.RAW_ORDERS_STREAM
  ON TABLE RAW_DATA.ECOMMERCE.RAW_ORDERS;

-- 2. Simulate a brand-new order arriving in RAW_ORDERS
INSERT INTO RAW_DATA.ECOMMERCE.RAW_ORDERS (raw_json, loaded_at)
SELECT PARSE_JSON('{"order_id": 201, "customer_id": 1, "amount": 250.00, "status": "completed"}'), CURRENT_TIMESTAMP();

-- 3. Peek at the stream (leaves the bookmark unchanged)
SELECT
    raw_json:order_id::INT AS order_id,
    raw_json:amount::FLOAT AS amount,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM RAW_DATA.ECOMMERCE.RAW_ORDERS_STREAM;


-- ============================================================================
-- PART 2: CDC DESTINATION TABLE & AUTOMATED TASK (SMART CRON)
-- ============================================================================

-- 4. Create the destination audit table for processed CDC events
CREATE OR REPLACE TABLE ANALYTICS.DBT_DEV.CDC_ORDERS_LOG (
    order_id INT,
    customer_id INT,
    amount FLOAT,
    status STRING,
    cdc_action STRING,
    processed_at TIMESTAMP_NTZ
);

-- 5. Create the Task (starts in SUSPENDED/paused state by default)
CREATE OR REPLACE TASK ANALYTICS.DBT_DEV.PROCESS_NEW_ORDERS_TASK
  WAREHOUSE = TRANSFORM_WH
  SCHEDULE = '1 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('RAW_DATA.ECOMMERCE.RAW_ORDERS_STREAM')
AS
INSERT INTO ANALYTICS.DBT_DEV.CDC_ORDERS_LOG
SELECT
    raw_json:order_id::INT,
    raw_json:customer_id::INT,
    raw_json:amount::FLOAT,
    raw_json:status::STRING,
    METADATA$ACTION,
    CURRENT_TIMESTAMP()
FROM RAW_DATA.ECOMMERCE.RAW_ORDERS_STREAM;


-- ============================================================================
-- PART 3: RESUME, VERIFY, AND SUSPEND
-- ============================================================================

-- 6. Turn the Task ON so it starts its 1-minute schedule
ALTER TASK ANALYTICS.DBT_DEV.PROCESS_NEW_ORDERS_TASK RESUME;

-- (WAIT ~65 SECONDS BEFORE RUNNING STEPS 7-9)

-- 7. Verify Order #201 moved into CDC_ORDERS_LOG
SELECT * FROM ANALYTICS.DBT_DEV.CDC_ORDERS_LOG;

-- 8. Verify the Stream bookmark moved forward (returns 0 rows)
SELECT * FROM RAW_DATA.ECOMMERCE.RAW_ORDERS_STREAM;

-- 9. Safety Cleanup: Pause the Task again after testing
ALTER TASK ANALYTICS.DBT_DEV.PROCESS_NEW_ORDERS_TASK SUSPEND;