
WITH order_items AS (

    SELECT *
    FROM {{ ref('stg_order_items') }}

),

orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

products AS (

    SELECT *
    FROM {{ ref('stg_products') }}

),

enriched AS (

    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,

        o.customer_id,
        o.order_status,

        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        p.product_category_name,

        oi.price,
        oi.freight_value,

        oi.price + oi.freight_value AS total_item_value,

        CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
            THEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            ELSE NULL
        END AS is_late_delivery

    FROM order_items oi

    LEFT JOIN orders o
        ON oi.order_id = o.order_id

    LEFT JOIN products p
        ON oi.product_id = p.product_id

)

SELECT *
FROM enriched
