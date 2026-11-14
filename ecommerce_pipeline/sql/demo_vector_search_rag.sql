USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSFORM_WH;

-- ============================================================================
-- LEVEL 4 - MODULE 2: VECTOR SEARCH & RAG RETRIEVAL IN SNOWFLAKE
-- ============================================================================

-- 1. Create a Knowledge Base table with a native VECTOR(FLOAT, 3) column
CREATE OR REPLACE TABLE ANALYTICS.DBT_DEV.SUPPORT_KNOWLEDGE_BASE (
    doc_id INT,
    topic STRING,
    chunk_text STRING,
    embedding VECTOR(FLOAT, 3)
);

-- 2. Insert 3 support knowledge chunks with pre-computed embeddings
INSERT INTO ANALYTICS.DBT_DEV.SUPPORT_KNOWLEDGE_BASE
SELECT 1, 'Network Speed', 'Restart your 5G Home Router and place it near a window for stronger signal.', [0.95, 0.05, 0.10]::VECTOR(FLOAT, 3)
UNION ALL
SELECT 2, 'Billing', 'Duplicate charges are automatically refunded within 3 to 5 business days.', [0.05, 0.96, 0.05]::VECTOR(FLOAT, 3)
UNION ALL
SELECT 3, 'Mobile App', 'Clear the mobile app cache or update to v4.2 to fix login crashes.', [0.10, 0.05, 0.94]::VECTOR(FLOAT, 3);

-- 3. Retrieve the top matching chunk for a billing question ([0.04, 0.98, 0.02])
SELECT
    doc_id,
    topic,
    chunk_text,
    ROUND(VECTOR_COSINE_SIMILARITY(embedding, [0.04, 0.98, 0.02]::VECTOR(FLOAT, 3)), 4) AS similarity_score
FROM ANALYTICS.DBT_DEV.SUPPORT_KNOWLEDGE_BASE
ORDER BY similarity_score DESC
LIMIT 1;