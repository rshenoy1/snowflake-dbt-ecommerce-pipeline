# Snowflake & dbt E-Commerce Data Pipeline

An end-to-end ELT data pipeline built with **Snowflake** and **dbt** featuring semi-structured JSON parsing, layered dimensional modeling, and automated data quality tests.

## Architecture
- **Raw Layer (RAW_DATA.ECOMMERCE):** Ingests semi-structured JSON payloads into a Snowflake VARIANT table (RAW_ORDERS).
- **Staging Layer (models/staging/):** Unpacks nested JSON keys (: and :: casting) into typed views (stg_orders).
- **Marts Layer (models/marts/):** Filters refunded transactions and materializes clean business tables (ct_orders) for analytics.
- **Data Quality Gates (_marts_models.yml & 	ests/):** Enforces unique, 
ot_null, ccepted_values, and custom singular SQL tests (ssert_positive_order_amount) via dbt build.
- **Cost Control:** Configured with an X-SMALL virtual warehouse (TRANSFORM_WH) set to AUTO_SUSPEND = 60.