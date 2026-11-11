
SELECT
    order_id,
    product_revenue,
    freight_revenue,
    order_revenue

FROM {{ ref('fct_orders') }}

WHERE ABS(
    order_revenue -
    (product_revenue + freight_revenue)
) > 0.01
