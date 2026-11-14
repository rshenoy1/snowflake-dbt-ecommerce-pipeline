# Enterprise Snowflake, dbt & AI Data Engineering Platform

An end-to-end, production-grade cloud data platform built on **Snowflake** and **dbt Core**, demonstrating layered dimensional modeling, FinOps cost governance, pushdown Python compute (**Snowpark**), event-driven Change Data Capture (**Streams & Task DAGs**), open lakehouse patterns (**Apache Iceberg**), and native **Vector Search / RAG** pipelines.

---

## Architecture Overview

```text
[RAW SOURCES]                 [SNOWFLAKE INGESTION]            [TRANSFORM & AI LAYER]
 JSON / CSV / Kafka ───────►  RAW_DATA.ECOMMERCE       ──────►  dbt Core (Staging -> Marts)
                              • VARIANT (Semi-structured)       • Incremental MERGE + QUALIFY
                              • COPY INTO (Internal Stage)      • Dynamic Tables (1-min lag)
                              • Streams (Row-level CDC)         • Snowpark Python (Pushdown)
                                                                • Native VECTOR RAG Search
```

---

## Key Capabilities & Production Patterns

### 1. Analytics Engineering & Data Contracts (`ecommerce_pipeline/`)
* **Layered Dimensional Modeling:** Separates raw JSON/CSV cleanup (`models/staging/` views) from business-ready Star Schema tables (`fct_orders` and `dim_customers` in `models/marts/`).
* **Incremental Deduplication:** Uses dbt `is_incremental()` combined with Snowflake `QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY loaded_at DESC) = 1` to safely deduplicate append-only source logs during `MERGE` operations.
* **Automated Data Quality Gates:** Enforces `unique`, `not_null`, `accepted_values`, foreign-key `relationships`, and custom singular business rules (`assert_positive_order_amount.sql`) via `dbt build` and **GitHub Actions CI/CD** (`.github/workflows/`).

### 2. FinOps, Performance & Governance (`sql/`)
* **Compute Cost Controls:** Configured `TRANSFORM_WH` (`X-SMALL`) with `AUTO_SUSPEND = 60` and `AUTO_RESUME = TRUE`, plus `WHEN SYSTEM$STREAM_HAS_DATA(...)` guards on scheduled Tasks to guarantee **\$0 idle compute cost**.
* **Micro-Partition Pruning & Clustering:** Applied `CLUSTER BY (customer_id)` on `FCT_ORDERS` and verified partition health (`average_depth: 1.0`, `average_overlaps: 0.0`) via `SYSTEM$CLUSTERING_INFORMATION()`.
* **Security & Recovery:** Implemented least-privilege RBAC (`TRANSFORMER_ROLE` with `ON FUTURE TABLES` grants), Zero-Copy Cloning for instant dev sandboxes, and Time Travel point-in-time recovery.

### 3. Pushdown Python & Event-Driven Streaming (`snowpark/` & `sql/`)
* **Snowpark Python (`snowpark/snowpark_customer_tiers.py`):** Executes lazy DataFrame transformations (`VIP`, `Regular`, `New / Prospect` segmentation) directly inside Snowflake's virtual warehouse with zero local data egress.
* **CDC Streams & Task DAGs (`sql/demo_cdc_streams_and_tasks.sql`, `sql/demo_task_dag_orchestration.sql`):** Captures row-level changes via `RAW_ORDERS_STREAM` and orchestrates parent-child `AFTER` dependencies.
* **Declarative & Open Lakehouse Patterns:** Built near-real-time `DYNAMIC TABLE` pipelines (`TARGET_LAG = '1 minute'`) and documented customer-managed AWS S3 **Apache Iceberg** architectures (`EXTERNAL VOLUME` + `CATALOG INTEGRATION`).

### 4. AI-Native Data Engineering (`sql/demo_vector_search_rag.sql`, `sql/demo_cortex_ai_sentiment.sql`)
* **Native Vector Search & RAG:** Stores dense embeddings in native `VECTOR(FLOAT, N)` columns alongside relational metadata and executes semantic retrieval via `VECTOR_COSINE_SIMILARITY()`.
* **Snowflake AISQL:** Implements governed unstructured text classification (`AI_COMPLETE`) designed for incremental stream processing.

---

## Repository Structure

```text
snowflake-dbt-ecommerce-pipeline/
├── .github/workflows/        # Automated dbt CI/CD pipeline
├── ecommerce_pipeline/
│   ├── models/
│   │   ├── staging/          # 1:1 raw cleanup views & sources.yml
│   │   └── marts/            # Incremental fct_orders, dim_customers & schema tests
│   ├── tests/                # Singular SQL business rule assertions
│   ├── snowpark/             # Pushdown Python DataFrame transformations
│   └── sql/                  # RBAC, Cloning/Time Travel, Dynamic Tables, CDC DAGs, Iceberg & Vector RAG
└── README.md
```