# Data quality and cleaning decisions

Findings from the checks in [`03_quality_checks.sql`](../sql/03_quality_checks.sql), [`05_extra_checks.sql`](../sql/05_extra_checks.sql) and [`01_staging.sql`](../sql/01_staging.sql), and the decisions they led to. Tables and columns are described in [data_dictionary.md](data_dictionary.md).

## 1. Check results

| ID | Check | Result | Reading | Action |
|---|---|---:|---|---|
| A | Orders without items | 775 | 767 are `canceled` (164) or `unavailable` (603); the other 8 are in-flight (`created` 5, `invoiced` 2, `shipped` 1) | No revenue by construction; see decision 4 for delivery metrics |
| B | Items without order | 0 | No orphan items | None |
| C | Orders with more than one review | 547 | Review is not a unique key per order | Keep the latest review (`v_reviews`) |
| D | Orders with more than one payment | 2,961 | Several payment rows per order | Revenue computed from item prices, not payments |
| F | `delivered` orders with NULL delivery date | 8 | Incomplete delivery data | Excluded from delivery metrics (`v_delivery`) |
| G | First order date | 2016-09-04 21:15:19 | | |
| H | Last order date | 2018-10-17 17:30:18 | | |
| I | Categories without translation | 2 | 13 products are affected; a further 610 products (1.9%) have a NULL category, which this check does not count | See decision 7 |
| K | Orders with items from more than one seller | 1,278 | 1.3% of orders with items; justifies the (order, seller) grain | See decision 8 |
| L | Orders with items from more than one category | 786 | 0.8% of orders with items; justifies the (order, category) grain | See decision 8 |

### Order status distribution (check E)

| Status | Orders | Revenue queries (`extra_02`, `extra_03`) | Delivery and satisfaction queries (`q00` to `q06`) |
|---|---:|---|---|
| `delivered` | 96,478 | included | included (8 excluded: NULL delivery date) |
| `shipped` | 1,107 | included | not applicable |
| `canceled` | 625 | excluded | not applicable |
| `unavailable` | 609 | excluded | not applicable |
| `invoiced` | 314 | included | not applicable |
| `processing` | 301 | included | not applicable |
| `created` | 5 | included | not applicable |
| `approved` | 2 | included | not applicable |
| **Total** | **99,441** | | |

### Orders per month (check J)

<details>
<summary>Show the monthly table</summary>

| Month | Orders | Month | Orders |
|---|---:|---|---:|
| 2016-09 | 4 | 2017-11 | 7,544 |
| 2016-10 | 324 | 2017-12 | 5,673 |
| 2016-12 | 1 | 2018-01 | 7,269 |
| 2017-01 | 800 | 2018-02 | 6,728 |
| 2017-02 | 1,780 | 2018-03 | 7,211 |
| 2017-03 | 2,682 | 2018-04 | 6,939 |
| 2017-04 | 2,404 | 2018-05 | 6,873 |
| 2017-05 | 3,700 | 2018-06 | 6,167 |
| 2017-06 | 3,245 | 2018-07 | 6,292 |
| 2017-07 | 4,026 | 2018-08 | 6,512 |
| 2017-08 | 4,331 | 2018-09 | 16 |
| 2017-09 | 4,285 | 2018-10 | 4 |
| 2017-10 | 4,631 | | |

</details>

Observations:

- Volumes outside 2017-01 to 2018-08 are negligible: 2016 has 329 orders in total (no orders in 2016-11), and 2018-09 and 2018-10 have 16 and 4.
- The date window alone keeps 99,092 of 99,441 orders (99.6%); the status filter then removes the `canceled` and `unavailable` ones, leaving 97,910 orders in scope (check Z1), 96,203 of them delivered (check Z2).
- Volume grows from 800 orders in 2017-01 to about 7,500 in 2017-11: trends in 2017 partly reflect the growth of the platform.
- 2017-11 (7,544 orders against 4,631 in 2017-10) has the third highest late rate (12.4%), after 2018-03 (19.0%) and 2018-02 (14.1%).

### Primary key checks

Rows / distinct keys, from checks K01 to K08 of `05_extra_checks.sql`.

| Table | Key | Result |
|---|---|---|
| `orders` | `order_id` | 99,441 rows, 99,441 distinct |
| `order_items` | `order_id`, `order_item_id` | 112,650 rows, 112,650 distinct |
| `customers` | `customer_id` | 99,441 rows, 99,441 distinct (96,096 distinct `customer_unique_id`) |
| `products` | `product_id` | 32,951 rows, 32,951 distinct |
| `sellers` | `seller_id` | 3,095 rows, 3,095 distinct |
| `order_payments` | `order_id`, `payment_sequential` | 103,886 rows, 103,886 distinct |
| `order_reviews` | none usable | 99,224 rows, 98,410 distinct `review_id`, 98,673 distinct `order_id` |
| `translation` | `product_category_name` | 71 rows, 71 distinct |

## 2. Decision log

| # | Decision | Evidence | Where applied | Status |
|---|---|---|---|---|
| 1 | Analysis window: orders purchased from 2017-01-01 to 2018-08-31 | Check J: months outside have at most 324 orders and 2016-11 is missing; months inside have at least 800. Any threshold between 325 and 799 orders per month gives the same window; the window keeps 99.6% of orders | `v_orders_scope` | Applied |
| 2 | Exclude `canceled` and `unavailable` orders | Check E: 625 and 609 orders | `v_orders_scope` | Applied |
| 3 | Delivery metrics use `delivered` orders with a delivery date | Check F: 8 orders without date | `v_delivery` | Applied |
| 4 | Orders without items: no revenue by construction; `q00` also requires an item | Check A: 775 orders without items; check M: 0 delivered orders in scope without items, so the item requirement in `q00` changes nothing for delivery metrics | `v_order_revenues`, `q00`, `extra_02`, `extra_03` | Applied |
| 5 | Revenue is `SUM(price)` from `order_items`, freight excluded | Check D: 2,961 orders with several payment rows; check R: paid differs from items + freight for 387 of 98,665 orders (0.4%) | `v_order_revenues` | Applied |
| 6 | Keep the latest review per order | Check C: 547 orders with more than one review. The latest answer is the customer's last opinion on the order; ties are broken by `review_id` for determinism | `v_reviews` | Applied |
| 7 | Categories without translation keep the Portuguese name; NULL categories are labelled `unknown` | Check I: 2 categories, plus NULL categories (checks C1 to C3) | `q06`, `extra_03` | Applied |
| 8 | Analysis grain is the order; seller analysis uses (order, seller) pairs and category analysis (order, category) pairs | `order_items` has 112,650 rows against 99,441 orders: joining items to order-level views multiplies rows | `q00` to `q06`, `extra_04`, `04_headlines`, `v_order_sellers` | Applied |
| 9 | Late means delivered on a later calendar day than the estimated delivery date (`days_late > 0`) | `date_diff('day')` counts calendar-day boundaries; check E1: every estimated date is at 00:00:00, so this is a comparison of dates | `v_delivery` | Applied |
| 10 | Minimum sample of 30 orders for ranked groups (months, states, sellers); categories need 30 reviewed orders in both groups | Rates on small groups are noise | `q01`, `q04`, `q05`, `q06`, `extra_04`, `04_headlines` | Applied |
| 11 | Delay buckets are defined once, in `v_delivery.delay_bucket` | Avoids drift between queries | `v_delivery`, `q02`, `q03` | Applied |
| 12 | Keep orders with inconsistent timestamps | Check D2: 1,359 orders handed to the carrier before approval; D3: 23 delivered before the carrier date. The analysis uses purchase, estimated and delivery dates only: D2 does not touch them and D3 is 0.02% of delivered orders | `v_delivery` | Applied |

## 3. Additional checks

Run with [`05_extra_checks.sql`](../sql/05_extra_checks.sql); each row of its output has the ID in the first column.

| Check | ID | Why | Result |
|---|---|---|---|
| Breakdown of the 775 orders without items by status | A | Confirms they are mostly canceled or unavailable | 164 `canceled`, 5 `created`, 2 `invoiced`, 1 `shipped`, 603 `unavailable` |
| Delivered orders in scope without items | M | Supports decision 4 | 0 |
| Payments vs items plus freight, per order | R | Supports decision 5 | 387 of 98,665 (0.4%) |
| Reviews answered before the delivery date | S | Such a review may not reflect the delivery, or may complain about its absence | 4,648 of 95,560 (4.9%); [`extra_05`](../sql/extra_05_reviews_before_delivery.sql) shows the score by delay bucket with and without them |
| Products with NULL or untranslated category | C1 to C3 | Completes check I and decision 7 | 610 products with NULL category (1.9%); 13 products in 2 untranslated categories |
| Timestamp order (approval, carrier, delivery vs purchase) | D1 to D4 | Catches impossible durations | D1 0, D2 1,359, D3 23, D4 0 (decision 12) |
| `price` less than or equal to 0, `review_score` outside 1 to 5 | V1 to V3 | Range checks | 0, 0, 0 |
| Orphan keys towards `products`, `sellers`, `customers`; orders without payments | O1 to O4 | Referential integrity | O1 0, O2 0, O3 1, O4 0 |
| Time part of the estimated delivery date | E1 | Affects `days_late` (decision 9) | 0 |
| Null percentage of the main columns | N1 to N4 | Completes the data dictionary | N1 3.0%, N2 1.9%, N3 88.3%, N4 58.7% |

Review coverage among delivered orders in scope is 99.3% (`q00`), so the self-selection limit is small.

## 4. Open questions

- Whether the in-flight statuses (`shipped`, `invoiced`, `processing`, `created`, `approved`: 1,729 orders, about 1.7% of all orders) should count as revenue. They are currently included in the revenue queries.
- Whether to exclude the reviews answered before the delivery date (4.9% of the reviews in scope, check S) from the satisfaction metrics; see `extra_05`.
