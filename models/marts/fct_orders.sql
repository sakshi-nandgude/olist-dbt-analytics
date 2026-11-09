
WITH orders AS (

    SELECT *
    FROM {{ ref('int_orders_aggregated') }}

),

customers AS (

    SELECT
        customer_id,
        customer_unique_id
    FROM {{ ref('stg_customers') }}

),

final AS (

    SELECT
        -- Order identifiers
        o.order_id,
        o.customer_id,
        c.customer_unique_id,

        -- Order status
        o.order_status,

        CASE
            WHEN o.order_status = 'delivered' THEN TRUE
            ELSE FALSE
        END AS is_delivered,

        CASE
            WHEN o.order_status = 'canceled' THEN TRUE
            ELSE FALSE
        END AS is_cancelled,

        -- Order dates
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Order quantities
        o.total_items,
        o.unique_products,

        -- Financial metrics
        o.product_revenue,
        o.freight_revenue,
        o.total_order_value AS order_revenue,

        -- Delivery performance
        o.delivery_days,
        o.is_late_delivery

    FROM orders o

    LEFT JOIN customers c
        ON o.customer_id = c.customer_id

)

SELECT *
FROM final
