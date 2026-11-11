
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert'
    )
}}

WITH orders AS (

    SELECT *
    FROM {{ ref('int_orders_aggregated') }}

    {% if is_incremental() %}

        WHERE order_purchase_timestamp >= (
            SELECT COALESCE(
                MAX(order_purchase_timestamp) - INTERVAL 30 DAY,
                TIMESTAMP '1900-01-01'
            )
            FROM {{ this }}
        )

    {% endif %}

),

customers AS (

    SELECT
        customer_id,
        customer_unique_id
    FROM {{ ref('stg_customers') }}

),

final AS (

    SELECT
        o.order_id,
        o.customer_id,
        c.customer_unique_id,

        o.order_status,

        CASE
            WHEN o.order_status = 'delivered' THEN TRUE
            ELSE FALSE
        END AS is_delivered,

        CASE
            WHEN o.order_status = 'canceled' THEN TRUE
            ELSE FALSE
        END AS is_cancelled,

        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        o.total_items,
        o.unique_products,

        o.product_revenue,
        o.freight_revenue,
        o.total_order_value AS order_revenue,

        o.delivery_days,
        o.is_late_delivery

    FROM orders o

    LEFT JOIN customers c
        ON o.customer_id = c.customer_id

)

SELECT *
FROM final
