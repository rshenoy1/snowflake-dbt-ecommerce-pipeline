USE ROLE ACCOUNTADMIN;
USE WAREHOUSE TRANSFORM_WH;

-- ============================================================================
-- LEVEL 4 - MODULE 1: SNOWFLAKE AISQL (AI_COMPLETE FOR UNSTRUCTURED TEXT)
-- Note: Hosted LLM inference functions (AI_COMPLETE / AI_SENTIMENT) require a
-- standard/enterprise Snowflake account and are blocked on free trial accounts.
-- ============================================================================

-- 1. Create a table holding unstructured customer reviews
CREATE OR REPLACE TABLE ANALYTICS.DBT_DEV.RAW_CUSTOMER_REVIEWS (
    review_id INT,
    customer_id INT,
    review_text STRING
);

-- 2. Load 3 sample unstructured text reviews
INSERT INTO ANALYTICS.DBT_DEV.RAW_CUSTOMER_REVIEWS VALUES
  (1, 1, 'The 5G home router arrived two days early and setup took less than five minutes. Blazing fast speeds!'),
  (2, 2, 'Terrible experience. My billing was charged twice this month and customer support kept me on hold for 45 minutes.'),
  (3, 3, 'The device hardware works fine, though the mobile app crashes occasionally when checking data usage.');

-- 3. Run AI_COMPLETE directly inside SQL for sentiment & category classification
SELECT
    review_id,
    customer_id,
    AI_COMPLETE(
        'llama3.1-8b',
        'Classify the sentiment of this review as Positive, Negative, or Mixed (reply with ONE word only): ' || review_text
    ) AS ai_sentiment,
    AI_COMPLETE(
        'llama3.1-8b',
        'Classify this review into ONE category (Billing, Network Speed, App Bug) and reply with ONLY the category name: ' || review_text
    ) AS ai_category,
    review_text
FROM ANALYTICS.DBT_DEV.RAW_CUSTOMER_REVIEWS;