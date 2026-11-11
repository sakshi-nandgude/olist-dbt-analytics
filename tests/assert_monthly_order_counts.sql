
WITH fact_counts AS (

    SELECT
        DATE_TRUNC(
            'month',
            order_purchase_timestamp
        ) AS order_month,

        COUNT(*) AS total_orders

    FROM {{ ref('fct_orders') }}

    GROUP BY 1

),

mart_counts AS (

    SELECT
        order_month,
        total_orders

    FROM {{ ref('mart_monthly_revenue') }}

)

SELECT
    f.order_month,
    f.total_orders AS fact_orders,
    m.total_orders AS mart_orders

FROM fact_counts f

LEFT JOIN mart_counts m
    ON f.order_month = m.order_month

WHERE m.total_orders IS NULL
   OR f.total_orders != m.total_orders
