
WITH products AS (

    SELECT *
    FROM {{ ref('stg_products') }}

),

cleaned AS (

    SELECT
        product_id,

        COALESCE(
            NULLIF(TRIM(product_category_name), ''),
            'Unknown'
        ) AS product_category_name,

        product_name_length,
        product_description_length,
        product_photos_qty,

        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    FROM products

),

final AS (

    SELECT
        product_id,
        product_category_name,

        product_name_length,
        product_description_length,
        product_photos_qty,

        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,

        CASE
            WHEN product_weight_g IS NULL
              OR product_length_cm IS NULL
              OR product_height_cm IS NULL
              OR product_width_cm IS NULL
            THEN TRUE
            ELSE FALSE
        END AS has_missing_dimensions

    FROM cleaned

)

SELECT *
FROM final
