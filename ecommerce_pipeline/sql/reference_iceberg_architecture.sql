-- ============================================================================
-- ARCHITECTURAL REFERENCE: APACHE ICEBERG TABLES IN SNOWFLAKE
-- Note: Requires an AWS S3 Bucket + IAM Role trust relationship to execute.
-- ============================================================================

-- 1. EXTERNAL VOLUME: Connects Snowflake securely to your AWS S3 bucket
CREATE OR REPLACE EXTERNAL VOLUME my_s3_iceberg_vol
  STORAGE_LOCATIONS = (
    (
      NAME = 'my-s3-us-east-1'
      STORAGE_PROVIDER = 'S3'
      STORAGE_BASE_URL = 's3://enterprise-datalake-prod/iceberg/'
      STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake-iceberg-role'
    )
  );

-- 2. CATALOG INTEGRATION: Defines who tracks Iceberg metadata snapshots
-- ('SNOWFLAKE' = Snowflake manages writes; 'GLUE' = External Spark/AWS writes)
CREATE OR REPLACE CATALOG INTEGRATION my_iceberg_catalog
  CATALOG_SOURCE = SNOWFLAKE
  TABLE_FORMAT = ICEBERG
  ENABLED = TRUE;

-- 3. ICEBERG TABLE: Stores open Parquet files directly in your S3 bucket
CREATE OR REPLACE ICEBERG TABLE ANALYTICS.DBT_DEV.ICEBERG_ORDERS (
    order_id INT,
    customer_id INT,
    amount FLOAT,
    order_date DATE
)
  CATALOG = 'my_iceberg_catalog'
  EXTERNAL_VOLUME = 'my_s3_iceberg_vol'
  BASE_LOCATION = 'orders/';