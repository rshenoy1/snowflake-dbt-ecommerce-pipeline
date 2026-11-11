USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSFORM_WH;

-- 1. ZERO-COPY CLONING: Clone the entire ANALYTICS database instantly at  extra storage cost
CREATE OR REPLACE DATABASE ANALYTICS_CLONE CLONE ANALYTICS;

-- Verify the cloned table has all customer records
SELECT * FROM ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS;

-- 2. TIME TRAVEL: Simulate an accidental deletion in the cloned environment
DELETE FROM ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS;

-- Confirm the table is empty (0 rows)
SELECT COUNT(*) AS rows_after_accident FROM ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS;

-- 3. RESTORE DATA: Recover deleted rows using Time Travel (BEFORE => STATEMENT)
INSERT INTO ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS
SELECT * FROM ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS BEFORE(STATEMENT => LAST_QUERY_ID(-2));

-- Confirm all customer rows are restored
SELECT * FROM ANALYTICS_CLONE.DBT_DEV.DIM_CUSTOMERS;

-- 4. Clean up the temporary clone database
DROP DATABASE ANALYTICS_CLONE;