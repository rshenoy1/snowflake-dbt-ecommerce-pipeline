USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSFORM_WH;
USE DATABASE ANALYTICS;
USE SCHEMA DBT_DEV;

-- ============================================================================
-- BONUS MODULE 1: DYNAMIC DATA MASKING (COLUMN-LEVEL PII GOVERNANCE)
-- ============================================================================

-- 1. Create a reusable Masking Policy checking CURRENT_ROLE() at query time
CREATE OR REPLACE MASKING POLICY email_mask_policy AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'TRANSFORMER_ROLE') THEN val
    ELSE '***MASKED***'
  END;

-- 2. Attach the policy to the EMAIL column on DIM_CUSTOMERS
ALTER TABLE ANALYTICS.DBT_DEV.DIM_CUSTOMERS
  MODIFY COLUMN EMAIL SET MASKING POLICY email_mask_policy;

-- 3. Grant read access to PUBLIC so we can test an unprivileged role
GRANT USAGE ON WAREHOUSE TRANSFORM_WH TO ROLE PUBLIC;
GRANT USAGE ON DATABASE ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA ANALYTICS.DBT_DEV TO ROLE PUBLIC;
GRANT SELECT ON TABLE ANALYTICS.DBT_DEV.DIM_CUSTOMERS TO ROLE PUBLIC;

-- 4. Query as ACCOUNTADMIN -> Sees real emails (alice@example.com)
SELECT customer_id, customer_name, email FROM ANALYTICS.DBT_DEV.DIM_CUSTOMERS;

-- 5. Query as PUBLIC -> Sees '***MASKED***' on the exact same table!
USE ROLE PUBLIC;
SELECT customer_id, customer_name, email FROM ANALYTICS.DBT_DEV.DIM_CUSTOMERS;

-- 6. Switch back to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;