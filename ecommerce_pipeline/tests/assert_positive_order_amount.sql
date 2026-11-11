-- Any row returned by this query causes the test to FAIL
SELECT
    order_id,
    amount
FROM {{ ref('fct_orders') }}
WHERE amount <= 0