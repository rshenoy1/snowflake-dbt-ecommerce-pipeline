import os
import yaml
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, when, lit

def get_snowflake_session() -> Session:
    """Reads credentials securely from ~/.dbt/profiles.yml so no secrets live in code."""
    profiles_path = os.path.expanduser("~/.dbt/profiles.yml")
    with open(profiles_path, "r", encoding="utf-8") as f:
        profiles = yaml.safe_load(f)

    dev_cfg = profiles["ecommerce_pipeline"]["outputs"]["dev"]
    connection_params = {
        "account": dev_cfg["account"],
        "user": dev_cfg["user"],
        "password": dev_cfg["password"],
        "role": dev_cfg["role"],
        "warehouse": dev_cfg["warehouse"],
        "database": dev_cfg["database"],
        "schema": dev_cfg["schema"],
    }
    return Session.builder.configs(connection_params).create()

def main():
    print("1. Connecting to Snowflake via Snowpark...")
    session = get_snowflake_session()

    try:
        # 2. Lazy reference to DIM_CUSTOMERS (zero data downloaded to laptop)
        customers_df = session.table("DIM_CUSTOMERS")

        # 3. Transform using Python DataFrame API (pushes down to Snowflake SQL)
        tiered_df = customers_df.with_column(
            "customer_tier",
            when(col("LIFETIME_VALUE") >= 100, lit("VIP"))
            .when(col("LIFETIME_VALUE") > 0, lit("Regular"))
            .otherwise(lit("New / Prospect"))
        ).select(
            col("CUSTOMER_ID"),
            col("CUSTOMER_NAME"),
            col("EMAIL"),
            col("TOTAL_ORDERS"),
            col("LIFETIME_VALUE"),
            col("CUSTOMER_TIER")
        )

        # 4. Inspect the compiled SQL that Snowpark generated from Python
        print("\n2. Compiled Snowflake SQL Plan:")
        tiered_df.explain()

        # 5. Execute inside TRANSFORM_WH and save as a physical table
        print("\n3. Writing results to ANALYTICS.DBT_DEV.SNOWPARK_CUSTOMER_TIERS...")
        tiered_df.write.mode("overwrite").save_as_table("SNOWPARK_CUSTOMER_TIERS")

        print("\n4. Verified Output from Snowflake:")
        session.table("SNOWPARK_CUSTOMER_TIERS").show()

    finally:
        session.close()
        print("Session closed cleanly.")

if __name__ == "__main__":
    main()