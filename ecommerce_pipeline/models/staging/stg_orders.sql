SELECT
    raw_json:order_id::INT AS order_id,
    COALESCE(raw_json:customer.id::INT, raw_json:customer_id::INT) AS customer_id,
    raw_json:customer.name::STRING AS customer_name,
    raw_json:amount::FLOAT AS amount,
    raw_json:status::STRING AS order_status,
    loaded_at
FROM {{ source('ecommerce', 'raw_orders') }}