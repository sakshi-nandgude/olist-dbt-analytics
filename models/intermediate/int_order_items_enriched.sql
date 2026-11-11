
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

customers AS (

    SELECT
        customer_id,
        customer_unique_id
    FROM {{ ref('stg_customers') }}

),

enriched AS (

    SELECT
        -- Order item identifiers
        oi.order_id,
        oi.order_item_id,

        -- Product and seller identifiers
        oi.product_id,
        oi.seller_id,

        -- Customer identifiers
        o.customer_id,
        c.customer_unique_id,

        -- Order information
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Product information
        p.product_category_name,

        -- Financial information
        oi.price,
        oi.freight_value,

        CAST(
            oi.price + oi.freight_value
            AS DECIMAL(12, 2)
        ) AS total_item_value,

        -- Delivery performance
        CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
            THEN
                o.order_delivered_customer_date >
                o.order_estimated_delivery_date
            ELSE NULL
        END AS is_late_delivery

    FROM order_items oi

    LEFT JOIN orders o
        ON oi.order_id = o.order_id

    LEFT JOIN products p
        ON oi.product_id = p.product_id

    LEFT JOIN customers c
        ON o.customer_id = c.customer_id

)

SELECT *
FROM enriched
