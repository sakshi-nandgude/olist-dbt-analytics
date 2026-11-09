
WITH orders AS (

    SELECT *
    FROM {{ ref('fct_orders') }}

),

monthly AS (

    SELECT
        DATE_TRUNC(
            'month',
            order_purchase_timestamp
        ) AS order_month,

        COUNT(*) AS total_orders,

        COUNT(*) FILTER (
            WHERE is_delivered
        ) AS delivered_orders,

        COUNT(*) FILTER (
            WHERE is_cancelled
        ) AS cancelled_orders,

        SUM(product_revenue) AS product_revenue,

        SUM(freight_revenue) AS freight_revenue,

        SUM(order_revenue) AS total_revenue,

        AVG(order_revenue) AS average_order_value,

        COUNT(*) FILTER (
            WHERE is_late_delivery = TRUE
        ) AS late_delivered_orders,

        COUNT(*) FILTER (
            WHERE is_late_delivery IS NOT NULL
        ) AS evaluated_deliveries

    FROM orders

    GROUP BY 1

)

SELECT
    *,

    CAST(
        100.0 * late_delivered_orders /
        NULLIF(evaluated_deliveries, 0)
        AS DECIMAL(8, 2)
    ) AS late_delivery_percentage

FROM monthly
