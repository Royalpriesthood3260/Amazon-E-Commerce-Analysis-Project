-- ============================================================
--  AMAZON E-COMMERCE SQL ANALYSIS PROJECT
--  Dataset : amazon_ecommerce_1M  (1,000,000 rows | 20 cols)
--  Dialect : PostgreSQL
-- ============================================================


-- ============================================================
-- DATA CLEANING
-- ============================================================

-- CHECK 1: Nulls
SELECT
    SUM(CASE WHEN user_id         IS NULL THEN 1 ELSE 0 END) AS null_user_id,
    SUM(CASE WHEN product_id      IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN price           IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN final_price     IS NULL THEN 1 ELSE 0 END) AS null_final_price,
    SUM(CASE WHEN rating          IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_delivery_status
FROM amazon_ecommerce;

-- CHECK 2: Duplicate rows
SELECT user_id, product_id, purchase_date, COUNT(*) AS cnt
FROM amazon_ecommerce
GROUP BY user_id, product_id, purchase_date
HAVING COUNT(*) > 1;

-- CHECK 3: Price logic
SELECT COUNT(*) AS bad_price_rows
FROM amazon_ecommerce
WHERE final_price > price
   OR discount < 0
   OR discount > 100;
;

-- CHECK 4: Rating bounds
SELECT COUNT(*) AS bad_ratings
FROM amazon_ecommerce
WHERE rating        NOT BETWEEN 0 AND 5
   OR seller_rating NOT BETWEEN 0 AND 5;
;

-- CHECK 5: is_returned vs delivery_status mismatch
SELECT COUNT(*) AS mismatches
FROM amazon_ecommerce
WHERE (is_returned = TRUE AND delivery_status != 'Returned')
   OR (is_returned = FALSE AND delivery_status  = 'Returned');
;


-- ============================================================
-- EDA
-- ============================================================

-- 1. Basic Numbers
SELECT
    ROUND(AVG(price),              2) AS avg_listed_price,
    ROUND(AVG(final_price),        2) AS avg_paid_price,
    ROUND(AVG(discount),           2) AS avg_discount_pct,
    ROUND(AVG(rating),             3) AS avg_rating,
    ROUND(AVG(seller_rating),      3) AS avg_seller_rating,
    ROUND(AVG(shipping_time_days), 2) AS avg_shipping_days,
    MIN(price)                        AS min_price,
    MAX(price)                        AS max_price,
    MIN(purchase_date)                AS earliest_order,
    MAX(purchase_date)                AS latest_order
FROM amazon_ecommerce;

-- Customers are paying about 9,939 on average — discounts are cutting almost 30% off the original price. Sellers are rated a bit lower than the products, meaning people are happier with what they bought than who they bought it from.


-- 2. Orders and Performance by Category
SELECT
    category,
    COUNT(*)                              AS total_orders,
    ROUND(AVG(final_price), 2)            AS avg_order_value,
    ROUND(AVG(discount),    2)            AS avg_discount_pct,
    ROUND(AVG(rating),      3)            AS avg_rating,
    ROUND(AVG(is_returned::INT) * 100, 2) AS return_rate_pct
FROM amazon_ecommerce
GROUP BY category
ORDER BY avg_order_value DESC;

--Every category has around the same number of orders but Electronics makes way more money simply because it costs more. Clothing gives the biggest discounts but still ends up last in both revenue and ratings.


-- 3. Delivery Status Breakdown
SELECT
    delivery_status,
    COUNT(*)                                           AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)  AS pct_share
FROM amazon_ecommerce
GROUP BY delivery_status
ORDER BY orders DESC;

-- Only about 1 in 3 orders actually makes it to the customer. There are just as many delayed orders as delivered ones — that's a big problem.


-- 4. Orders by Device
SELECT
    device,
    COUNT(*)                                           AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)  AS pct_share
FROM amazon_ecommerce
GROUP BY device
ORDER BY orders DESC;

-- Orders are split almost perfectly between Mobile, Web, and Tablet. No device is more popular than the other.


-- ============================================================
-- Business Questions
-- ============================================================

-- 1. Which category makes the most money, and why?
SELECT
    category,
    COUNT(*)                                           AS total_orders,
    ROUND(SUM(final_price), 2)                         AS total_revenue,
    ROUND(AVG(final_price), 2)                         AS avg_order_value,
    ROUND(AVG(discount),    2)                         AS avg_discount_pct,
    ROUND(SUM(final_price) * 100.0
        / SUM(SUM(final_price)) OVER(), 2)             AS revenue_share_pct
FROM amazon_ecommerce
WHERE delivery_status = 'Delivered'
GROUP BY category
ORDER BY total_revenue DESC;

-- Electronics makes 65% of all the money but has the same number of orders as every other category. It's not selling more — it's just way pricier. Clothing has the biggest discounts and still comes in last.


-- 2. Does how you pay affect whether you return something?
SELECT
    payment_method,
    COUNT(*)                                                AS total_orders,
    SUM(CASE WHEN is_returned THEN 1 ELSE 0 END)            AS total_returns,
    ROUND(
        SUM(CASE WHEN is_returned THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                             AS return_rate_pct,
    ROUND(AVG(final_price), 2)                             AS avg_order_value
FROM amazon_ecommerce
GROUP BY payment_method
ORDER BY return_rate_pct DESC;

-- No matter how someone pays, return rates are almost identical. Cash on Delivery customers actually return the least — most people would assume the opposite. Returns have nothing to do with payment, it's more of a product and delivery issue.


-- 3. What does the customer base look like by spending level?
WITH customer_totals AS (
    SELECT
        user_id,
        SUM(final_price) AS total_spent,
        COUNT(*)         AS num_orders
    FROM amazon_ecommerce
    WHERE delivery_status = 'Delivered'
    GROUP BY user_id
),
segmented AS (
    SELECT *,
        CASE
            WHEN total_spent <  5000  THEN 'Low (<5K)'
            WHEN total_spent <  20000 THEN 'Medium (5K-20K)'
            WHEN total_spent <  50000 THEN 'High (20K-50K)'
            ELSE                           'Premium (>50K)'
        END AS segment
    FROM customer_totals
)
SELECT
    segment,
    COUNT(*)                                       AS customers,
    ROUND(AVG(total_spent), 2)                     AS avg_lifetime_value,
    ROUND(AVG(num_orders),  2)                     AS avg_orders,
    ROUND(SUM(total_spent) * 100.0
        / SUM(SUM(total_spent)) OVER(), 2)         AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY avg_lifetime_value DESC;

-- The top 17% of customers bring in 63% of the money. The biggest group (Low tier) barely contributes anything. High spenders aren't buying more often — they're just buying more expensive stuff.


-- 4. Do bigger discounts lead to better ratings or fewer returns?
SELECT
    category,
    CASE
        WHEN discount < 15              THEN '1. Low (5-15%)'
        WHEN discount BETWEEN 15 AND 30 THEN '2. Medium (15-30%)'
        WHEN discount BETWEEN 30 AND 50 THEN '3. High (30-50%)'
        ELSE                                 '4. Very High (50-70%)'
    END                                      AS discount_band,
    COUNT(*)                                 AS orders,
    ROUND(AVG(rating), 3)                    AS avg_rating,
    ROUND(AVG(is_returned::INT) * 100, 2)    AS return_rate_pct
FROM amazon_ecommerce
GROUP BY category, discount_band
ORDER BY category, discount_band;

-- Bigger discounts don't lead to better ratings or fewer returns — the numbers barely change no matter the discount size. If the goal is making customers happier, discounts aren't the answer.

-- 5. Which cities have the worst delivery problems?
SELECT
    location,
    COUNT(*)                                                        AS total_orders,
    ROUND(AVG(shipping_time_days), 2)                               AS avg_shipping_days,
    SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END)  AS delivered,
    SUM(CASE WHEN delivery_status = 'Delayed'   THEN 1 ELSE 0 END)  AS delayed,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                                      AS delay_rate_pct,
    ROUND(SUM(final_price), 2)                                      AS total_revenue
FROM amazon_ecommerce
GROUP BY location
ORDER BY delay_rate_pct DESC;

-- Delhi and Mumbai ship the fastest but still have the most delays — the problem isn't speed, it's the last part of delivery getting stuck. Every city has about a 30% delay rate so this isn't just one city's problem, it's happening everywhere.