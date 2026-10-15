#Q1. Monthly revenue and growth

WITH monthly AS (
  SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
         COUNT(DISTINCT o.order_id) AS orders,
         ROUND(SUM(i.price), 2) AS revenue
  FROM delivered_orders o
  JOIN items i ON o.order_id = i.order_id
  WHERE o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
  GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT month, orders, revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

#Q2.Top 10 categories

SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       ROUND(SUM(i.price), 2) AS revenue,
       ROUND(100 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_of_total
FROM delivered_orders o
JOIN items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

#Q3 Late delivery rate

SELECT COUNT(*) AS delivered_orders,
       SUM(order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
       ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*), 2) AS late_pct
FROM delivered_orders;

#Q4Late vs on-time ratings

SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM delivered_orders o
JOIN order_review_score r ON o.order_id = r.order_id
GROUP BY delivery_status;

#Q5: Repeat customer rate

WITH cust AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders
  FROM delivered_orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS total_customers,
       SUM(orders > 1) AS repeat_customers,
       ROUND(100 * SUM(orders > 1) / COUNT(*), 2) AS repeat_pct
FROM cust;

#Q6: Do the top sellers generate most of the revenue?

WITH seller_rev AS (
  SELECT i.seller_id, SUM(i.price) AS revenue
  FROM delivered_orders o
  JOIN items i ON o.order_id = i.order_id
  GROUP BY i.seller_id
),
ranked AS (
  SELECT seller_id, revenue,
         NTILE(10) OVER (ORDER BY revenue DESC) AS decile
  FROM seller_rev
)
SELECT decile,
       COUNT(*) AS sellers,
       ROUND(SUM(revenue), 2) AS revenue,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS pct_of_total
FROM ranked
GROUP BY decile
ORDER BY decile;

#Q7: Late deliveries by state

SELECT c.customer_state,
       COUNT(*) AS orders,
       ROUND(100 * SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days
FROM delivered_orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;

#Q8 low reviews, late vs on-time
SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS orders,
       ROUND(100 * SUM(r.review_score <= 2) / COUNT(*), 1) AS pct_low_reviews
FROM delivered_orders o
JOIN order_review_score r ON o.order_id = r.order_id
GROUP BY delivery_status;




