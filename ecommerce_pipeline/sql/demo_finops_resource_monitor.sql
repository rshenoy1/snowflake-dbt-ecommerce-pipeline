USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- BONUS MODULE 2: FINOPS RESOURCE MONITORS (HARD CREDIT CIRCUIT BREAKER)
-- ============================================================================

-- 1. Create a Resource Monitor capping monthly spend at 10 credits
CREATE OR REPLACE RESOURCE MONITOR transform_wh_monitor
  WITH CREDIT_QUOTA = 10
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- 2. Attach the circuit breaker to TRANSFORM_WH
ALTER WAREHOUSE TRANSFORM_WH SET RESOURCE_MONITOR = transform_wh_monitor;

-- 3. Inspect active monitors and credit consumption
SHOW RESOURCE MONITORS;