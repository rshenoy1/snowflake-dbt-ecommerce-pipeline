SELECT
    order_id,
    customer_id,
    customer_name,
    amount,
    order_status,
    loaded_at
FROM {{ ref('stg_orders') }}
WHERE order_status != 'refunded'