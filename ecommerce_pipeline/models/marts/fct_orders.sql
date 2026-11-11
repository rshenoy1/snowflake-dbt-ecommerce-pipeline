{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

SELECT
    order_id,
    customer_id,
    customer_name,
    amount,
    order_status,
    loaded_at
FROM {{ ref('stg_orders') }}
WHERE order_status != 'refunded'

{% if is_incremental() %}
    AND loaded_at >= (SELECT MAX(loaded_at) FROM {{ this }})
{% endif %}

QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY loaded_at DESC) = 1