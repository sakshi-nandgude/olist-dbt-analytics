
WITH orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

order_items AS (

    SELECT *
    FROM {{ ref('int_order_items_enriched') }}

),

item_aggregates AS (

    SELECT
        order_id,

        COUNT(*) AS total_items,

        COUNT(DISTINCT product_id) AS unique_products,

        SUM(price) AS product_revenue,

        SUM(freight_value) AS freight_revenue,

        SUM(total_item_value) AS total_order_value

    FROM order_items

    GROUP BY order_id

),

final AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,

        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        COALESCE(i.total_items, 0) AS total_items,
        COALESCE(i.unique_products, 0) AS unique_products,

        COALESCE(i.product_revenue, 0) AS product_revenue,
        COALESCE(i.freight_revenue, 0) AS freight_revenue,
        COALESCE(i.total_order_value, 0) AS total_order_value,

        DATE_DIFF(
            'day',
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS delivery_days,

        CASE
            WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
            THEN
                o.order_delivered_customer_date >
                o.order_estimated_delivery_date
            ELSE NULL
        END AS is_late_delivery

    FROM orders o

    LEFT JOIN item_aggregates i
        ON o.order_id = i.order_id

)

SELECT *
FROM final
