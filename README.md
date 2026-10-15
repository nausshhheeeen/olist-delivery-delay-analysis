# Why Are Customers Unhappy? Delivery Delays and Revenue Analysis of an E-Commerce Marketplace

**Tools:** MySQL Workbench (SQL: JOINs, CTEs, subqueries, window functions, views), Excel
**Dataset:** Brazilian E-Commerce Public Dataset by Olist (Kaggle)

---

## 1. Business Problem

Olist is an online marketplace in Brazil. This project asks:

1. Do late deliveries hurt customer satisfaction, and by how much?
2. Where are deliveries going wrong?
3. How is revenue spread across time, product categories and sellers?
4. Do customers come back?

The goal is to give a manager clear numbers and one actionable recommendation.

---

## 2. Data Used

Six tables from the Olist dataset:

| Table | Rows | What it holds |
|---|---|---|
| orders | 99,441 | One row per order, with status and dates |
| items (order items) | 112,650 | Products, sellers and prices in each order |
| reviews | 99,222 | Customer review scores |
| customers | 99,441 | Customer location and unique customer ID |
| products | 32,951 | Product category |
| category_translation | 71 | Category names in English |

Revenue in this project means **item price only (freight excluded)**.

---

## 3. Data Cleaning Log

1. **Imported 6 tables** into MySQL (MySQL Workbench). Row counts were checked against the Kaggle page.
2. **Date problem fixed:** order dates were stored as DD-MM-YYYY HH:MM (no seconds). The first import turned them into zero dates (0000-00-00). I reloaded the file with dates as text and converted them with `STR_TO_DATE`. Because seconds are missing, delay calculations are accurate to the minute.
3. **Duplicates:** 0 duplicate order IDs.
4. **Delivered orders only:** 96,478 orders had status "delivered". 8 had no delivery date and were removed, leaving **96,470 orders** for analysis (saved as the view `delivered_orders`).
5. **Multiple reviews:** 547 orders had more than one review. To avoid double counting, I used the **average review score per order** (view `order_review_score`).
6. **Missing reviews:** 648 delivered orders have no review, so rating analysis (Q4, Q8) covers 95,822 orders. This is why Q4 shows 7,660 late orders while Q3 shows 7,826.
7. **Data types checked:** prices are DECIMAL and review scores are integers.
8. **Monthly trend (Q1):** September to December 2016 and the final partial months were excluded because of very low volume, which produces misleading growth rates. Q1 totals therefore do not equal totals in other queries.

---

## 4. Analysis and Key Findings

### Q1. Monthly revenue and growth
- Monthly revenue grew from about 112K in January 2017 to about 726k in december 2017.
- Growth was uneven, with dips in April 2017 (-5.2%) and June 2017 (-13.7%) between strong months.

### Q2. Top product categories
- The top category, health_beauty, brings only 9.3% of revenue.
- The top 5 categories (health_beauty, watches_gifts, bed_bath_table, sports_leisure, computers_accessories) together bring about 39.7%.
- Revenue is spread across many categories, not dependent on one.

### Q3. Late delivery rate
- 7,826 of 96,470 delivered orders (**8.11%**) arrived after the estimated date.

### Q4. Do late orders get lower ratings? (key finding)
| Delivery | Orders | Average review score |
|---|---|---|
| On time | 88,162 | 4.29 |
| Late | 7,660 | 2.57 |

- Late orders score about **1.7 points lower (roughly 40% lower)**.

### Q5. Repeat customers
- Only **2,801 of 93,350** customers (**3%**) ordered more than once.
- Used `customer_unique_id`, because `customer_id` changes with every order.

### Q6. Seller concentration
- The top 10% of sellers (297 sellers) generate **67.1%** of revenue.
- Revenue falls sharply across the lower deciles, so the marketplace relies heavily on a small group of sellers.

### Q7. Late deliveries by state (states with 100+ orders)
| State | Orders | Late % | Avg delivery days |
|---|---|---|---|
| AL | 397 | 23.93% | 24.5 |
| MA | 717 | 19.67% | 21.5 |
| PI | 476 | 15.97% | 19.4 |
| CE | 1,279 | 15.32% | 21.2 |
| SE | 335 | 15.22% | 21.5 |
| BA | 3,256 | 14.04% | 19.3 |
| RJ | 12,350 | 13.47% | 15.2 |

- Alagoas (AL) has a late rate about 3x the overall 8.11%.
- Rio de Janeiro (RJ) has a lower rate but huge volume, so it produces about 1,660 late orders, the most among these states.

### Q8. Low reviews (1-2 stars), late vs on time
| Delivery | Orders | % low reviews |
|---|---|---|
| On time | 88,162 | 9.2% |
| Late | 7,660 | **54.0%** |

- More than half of late orders get a 1-2 star rating, almost **6x** the rate of on-time orders.

---

## 5. Recommendation

Focus on delivery performance first in **AL and MA** (highest late rates) and **RJ** (highest number of late orders). Late delivery is linked to a drop of about 1.7 rating points and a 54% low-review rate, so improving it should protect customer satisfaction and may help repeat purchases, which are currently only 3%.

Suggested next steps for a business team:
- Review carrier and seller performance in the worst states.
- Set more realistic delivery estimates where delays are common.
- Track late rate and average rating monthly.

---

## 6. Limitations

- The findings show an **association**, not proof of cause. Late delivery is linked to lower ratings, but other factors (product quality, price) may also affect them.
- Review scores are averaged per order, and 648 delivered orders have no review.
- Dates have no seconds, so delays are accurate to the minute only.
- The data covers roughly 2016-2018, and the 3% repeat rate may understate long-term repeat buying.
- Revenue excludes freight and is shown in the dataset's currency (Brazilian real).
- Early (2016) and late partial months were excluded from the monthly trend.

---

## 7. SQL Skills Demonstrated

- Joins across multiple tables
- CTEs and subqueries
- Window functions (`LAG`, `NTILE`, `SUM() OVER`)
- Views for clean, reusable data layers
- `CASE WHEN`, `GROUP BY`, `HAVING`
- Data cleaning and validation (type conversion, duplicate checks, NULL handling)

---

## 8. Files in This Repository

- `olist_analysis.sql` (all queries, commented)
- `results/` (exported query results)
- `README.md` (this file)

