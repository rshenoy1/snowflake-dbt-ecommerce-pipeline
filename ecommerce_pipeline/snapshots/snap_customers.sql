{% snapshot snap_customers %}

{{
    config(
      target_schema='DBT_DEV',
      unique_key='customer_id',
      strategy='check',
      check_cols=['customer_name', 'email']
    )
}}

SELECT
    customer_id,
    customer_name,
    email
FROM {{ ref('stg_customers') }}

{% endsnapshot %}