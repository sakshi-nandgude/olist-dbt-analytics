
WITH customers AS (

    SELECT *
    FROM {{ ref('stg_customers') }}

),

orders AS (

    SELECT *
    FROM {{ ref('int_orders_aggregated') }}

),

customer_orders AS (

    SELECT
        c.customer_unique_id,
        c.customer_id,

        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.total_order_value

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id

),

customer_metrics AS (

    SELECT
        customer_unique_id,

        COUNT(DISTINCT order_id) AS total_orders,

        COUNT(DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END) AS delivered_orders,

        SUM(CASE
            WHEN order_status = 'delivered'
            THEN total_order_value
            ELSE 0
        END) AS lifetime_value,

        MIN(order_purchase_timestamp) AS first_order_date,

        MAX(order_purchase_timestamp) AS last_order_date

    FROM customer_orders

    GROUP BY customer_unique_id

),

customer_profile AS (

    SELECT
        customer_unique_id,
        customer_id AS first_customer_id,

        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_purchase_timestamp, order_id
        ) AS row_num

    FROM customer_orders

)

SELECT
    m.customer_unique_id,
    p.first_customer_id,

    m.total_orders,
    m.delivered_orders,

    CAST(m.lifetime_value AS DECIMAL(12, 2))
        AS lifetime_value,

    CAST(
        m.lifetime_value /
        NULLIF(m.delivered_orders, 0)
        AS DECIMAL(12, 2)
    ) AS average_order_value,

    m.first_order_date,
    m.last_order_date,

    CASE
        WHEN m.delivered_orders > 1 THEN TRUE
        ELSE FALSE
    END AS is_repeat_customer

FROM customer_metrics m

LEFT JOIN customer_profile p
    ON m.customer_unique_id = p.customer_unique_id
    AND p.row_num = 1
