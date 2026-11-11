SELECT
    customer_id,
    TRIM(customer_name) AS customer_name,
    LOWER(TRIM(email)) AS email,
    signup_date
FROM {{ source('ecommerce', 'raw_customers') }}