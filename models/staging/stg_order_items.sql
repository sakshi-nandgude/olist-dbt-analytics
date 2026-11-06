
WITH source AS (

    SELECT *
    FROM {{ source('olist', 'order_items') }}

),

renamed AS (

    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
        CAST(price AS DECIMAL(12, 2)) AS price,
        CAST(freight_value AS DECIMAL(12, 2)) AS freight_value

    FROM source

)

SELECT * FROM renamed
