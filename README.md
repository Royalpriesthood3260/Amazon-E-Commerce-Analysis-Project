# 🛒 Amazon E-Commerce — SQL Analysis Project

> An SQL project analyzing 1 million e-commerce transactions. The project covers setting up the data, cleaning it, exploring it, and answering 5 business questions with real results and insights.

---

## 🎯 What This Project Is About

E-commerce platforms deal with huge amounts of data every day — orders, returns, shipping, customers, and products. Being able to dig into that data is valuable because it helps answer real business questions around pricing, logistics, and customer behaviour.

In this project I:

- Set up and cleaned a 1 million row dataset before touching any analysis
- Ran exploratory queries to understand what the data looks like
- Answered 5 business questions using intermediate SQL — GROUP BY, CASE, window functions, and a multi-step CTE
- Pulled out a clear insight from every single query

---

## 📁 Project Structure

```
amazon-sql-project/
│
├── amazon_ecommerce_Analysis.sql     # Main SQL script
└── README.md
```

---

## 📊 Dataset

| Field                | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `user_id`            | Unique customer ID                                                 |
| `product_id`         | Unique product ID                                                  |
| `category`           | Electronics / Sports / Beauty / Home / Clothing                    |
| `subcategory`        | Product type within the category                                   |
| `brand`              | Product brand                                                      |
| `price`              | Original listed price (₹)                                          |
| `discount`           | Discount applied (%)                                               |
| `final_price`        | Price after discount (₹)                                           |
| `rating`             | Customer product rating (0–5)                                      |
| `review_count`       | Number of reviews on the product                                   |
| `stock`              | Units in stock at time of purchase                                 |
| `seller_id`          | Seller ID                                                          |
| `seller_rating`      | Seller rating (0–5)                                                |
| `purchase_date`      | Date of the transaction (YYYY-MM-DD)                               |
| `shipping_time_days` | How many days it took to ship                                      |
| `location`           | Buyer city — Delhi / Mumbai / Bangalore / Chennai / Hyderabad      |
| `device`             | How the order was placed — Mobile App / Web / Tablet               |
| `payment_method`     | UPI / Credit Card / Debit Card / Cash on Delivery                  |
| `is_returned`        | Whether the order was returned (TRUE / FALSE)                      |
| `delivery_status`    | Delivered / Delayed / In Transit / Returned                        |

**1,000,000 rows · 20 columns · Mar 2024 – Mar 2026 · No missing values**

> **Download the dataset:** [Kaggle — Amazon E-Commerce Dataset](https://www.kaggle.com/datasets/sharmajicoder/amazon-e-commerce)

---

## 🏗 Setting Up the Data

The dataset was uploaded directly as a CSV through Supabase's Table Editor — no `CREATE TABLE` was needed as Supabase auto-generated the table from the file.

After the import, the following column types were manually updated in the Supabase Table Editor to make sure the queries ran correctly:

| Column | Changed To |
|--------|-----------|
| `price`, `discount`, `final_price`, `rating`, `seller_rating` | `numeric` |
| `review_count`, `stock`, `shipping_time_days` | `int4` |
| `is_returned` | `bool` |
| `purchase_date` | `date` |

---

## 🧹 Data Cleaning

Before any analysis, I ran 5 checks to make sure the data was good to use:

| Check | What I Checked | Result |
|-------|---------------|--------|
| 1 | Null values across all columns | ✔ 0 nulls |
| 2 | Duplicate rows | ✔ 0 duplicates |
| 3 | final_price is always less than or equal to price | ✔ 0 issues |
| 4 | Ratings are between 0 and 5 | ✔ 0 out-of-range values |
| 5 | is_returned matches delivery_status | ✔ 0 mismatches |

All 5 checks passed — data is clean.

---

## 📈 Exploratory Data Analysis

### EDA 1 — Basic Numbers

| Avg Listed Price | Avg Paid Price | Avg Discount | Avg Rating | Avg Seller Rating | Avg Shipping | Min Price | Max Price |
|------------------|----------------|--------------|------------|-------------------|--------------|-----------|-----------|
| ₹13,224          | ₹9,939         | 29%          | 3.93       | 3.75              | 3.17 days    | ₹200      | ₹79,999   |


---

### EDA 2 — Orders and Performance by Category

| Category    | Total Orders | Avg Order Value | Avg Discount | Avg Rating | Return Rate |
|-------------|--------------|-----------------|--------------|------------|-------------|
| Electronics | 200,038      | ₹32,889         | 22.5%        | 4.20       | 11.4%       |
| Home        | 200,922      | ₹7,615          | 27.5%        | 3.90       | 11.7%       |
| Sports      | 199,889      | ₹5,627          | 27.5%        | 3.88       | 11.6%       |
| Beauty      | 199,327      | ₹1,886          | 27.5%        | 3.82       | 11.7%       |
| Clothing    | 199,824      | ₹1,647          | 40.0%        | 3.83       | 11.8%       |


---

### EDA 3 — Delivery Status Breakdown

| Delivery Status | Orders  | Share  |
|-----------------|---------|--------|
| Delivered       | 295,234 | 29.52% |
| Delayed         | 294,983 | 29.50% |
| In Transit      | 293,793 | 29.38% |
| Returned        | 115,990 | 11.60% |


---

### EDA 4 — Orders by Device

| Device     | Orders  | Share  |
|------------|---------|--------|
| Mobile App | 333,637 | 33.36% |
| Web        | 333,297 | 33.33% |
| Tablet     | 333,066 | 33.31% |


---

## ❓ Business Questions & Insights

### Q1 — Which category makes the most money, and why?

| Category    | Orders | Revenue        | Avg Order Value | Avg Discount | Revenue Share |
|-------------|--------|----------------|-----------------|--------------|---------------|
| Electronics | 59,204 | ₹1,956,262,000 | ₹33,043         | 22.5%        | 65.3%         |
| Home        | 59,236 | ₹451,935,000   | ₹7,629          | 27.5%        | 15.1%         |
| Sports      | 59,077 | ₹333,039,000   | ₹5,637          | 27.5%        | 11.1%         |
| Beauty      | 58,861 | ₹111,074,000   | ₹1,887          | 27.6%        | 3.7%          |
| Clothing    | 58,856 | ₹96,908,000    | ₹1,647          | 40.0%        | 3.2%          |


---

### Q2 — Does how you pay affect whether you return something?

| Payment Method   | Total Orders | Returns | Return Rate | Avg Order Value |
|------------------|--------------|---------|-------------|-----------------|
| Credit Card      | 250,324      | 29,170  | 11.65%      | ₹9,956          |
| Debit Card       | 249,337      | 28,967  | 11.62%      | ₹9,957          |
| UPI              | 249,951      | 28,953  | 11.58%      | ₹9,917          |
| Cash on Delivery | 250,388      | 28,900  | 11.54%      | ₹9,926          |


---

### Q3 (CTE) — What does the customer base look like by spending level?

| Segment        | Customers | Avg Lifetime Value | Avg Orders | Revenue Share |
|----------------|-----------|--------------------|------------|---------------|
| Premium (>50K) | 13,236    | ₹61,149            | 1.45       | 27.44%        |
| High (20-50K)  | 30,555    | ₹34,657            | 1.32       | 35.91%        |
| Medium (5-20K) | 81,234    | ₹9,985             | 1.25       | 27.50%        |
| Low (<5K)      | 126,589   | ₹2,132             | 1.06       | 9.15%         |


---

### Q4 — Do bigger discounts lead to better ratings or fewer returns?

| Category    | Discount Band      | Orders | Avg Rating | Return Rate |
|-------------|--------------------|--------|------------|-------------|
| Electronics | 1. Low (5-15%)     | 57,039 | 4.203      | 11.4%       |
| Electronics | 3. High (30-50%)   | 57,285 | 4.209      | 11.2%       |
| Clothing    | 1. Low (5-15%)     | 16,835 | 3.819      | 12.0%       |
| Clothing    | 4. Very High       | 66,618 | 3.826      | 11.8%       |
| Beauty      | 3. High (30-50%)   | 88,374 | 3.825      | 11.7%       |


---

### Q5 — Which cities have the worst delivery problems?

| City      | Orders  | Avg Ship Days | Delivered | Delayed | Delay Rate | Revenue        |
|-----------|---------|---------------|-----------|---------|------------|----------------|
| Delhi     | 200,649 | 2.66          | 59,811    | 59,802  | 29.82%     | ₹2,000,521,000 |
| Mumbai    | 199,874 | 2.67          | 59,436    | 59,584  | 29.80%     | ₹1,988,988,000 |
| Bangalore | 200,270 | 3.50          | 58,695    | 58,826  | 29.37%     | ₹1,990,174,000 |
| Chennai   | 199,902 | 3.51          | 58,543    | 58,531  | 29.27%     | ₹1,981,130,000 |
| Hyderabad | 199,305 | 3.50          | 58,749    | 58,257  | 29.23%     | ₹1,978,064,000 |


---

## 🔑 Key Findings

1. Electronics drives 65% of revenue despite having the same order volume as every other category
2. The difference in revenue comes down to price — Electronics avg order value is ₹33,043 vs Clothing's ₹1,647
3. Clothing has the highest discount rate at 40% but generates the least revenue and has the worst ratings
4. Only 1 in 3 orders is actually delivered — delayed orders match delivered orders almost exactly
5. Every city has roughly a 30% delay rate — this is a platform-wide fulfilment issue
6. Delhi and Mumbai ship the fastest but have the highest delay rates — last-mile delivery is the bottleneck
7. Return rates are almost identical across all payment methods — how someone pays has no effect on returns
8. Cash on Delivery has the lowest return rate at 11.54% — the opposite of what most people assume
9. The top 17% of customers account for 63% of all revenue
10. Bigger discounts have zero impact on product ratings or return rates — the numbers barely move

---

## 🏁 Conclusion

This project went through 1 million e-commerce transactions using SQL to answer real business questions. A few things stood out clearly:

- Electronics is carrying the whole platform — same number of orders as every other category but 65% of the revenue
- Delivery is a serious problem — nearly 1 in 3 orders is delayed across every single city
- Discounts are being wasted — they don't improve ratings or reduce returns at all
- A small group of customers drives most of the money — keeping them happy matters more than chasing new ones

---

## 🛠 Tools Used

| Tool | Purpose |
|------|---------|
| Supabase | Database hosting and running SQL queries |
| PostgreSQL | SQL dialect used for all queries |

---

## 📦 SQL Concepts Used

| Concept | Where Used |
|---------|------------|
| `GROUP BY` + aggregate functions | All 5 questions |
| `CASE WHEN` | Q2, Q4, Q5 |
| Window functions (`SUM() OVER()`) | Q1, Q3, EDA 3 & 4 |
| Multi-step CTE (`WITH`) | Q3 |
| Boolean casting (`is_returned::INT`) | Q2, Q4, EDA 2 |

---

## 🙋 Author

Made by **Royalpriesthood Olola** · [LinkedIn](https://www.linkedin.com/in/royalpriesthoodolola) · [GitHub](https://github.com/Royalpriesthood3260)
