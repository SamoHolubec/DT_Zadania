-- Active: 1790180945242@@127.0.0.1@5432@datacraftinglab_db

--Uloha 1
with daily_sales as (
    select sale_date, sum(total_amount) as total_sales
    from flourmills_sales
    group by sale_date
)
select sale_date, total_sales
from daily_sales
where total_sales > 3000000
order by total_sales desc;

--Uloha 2
with category_sales as (
    select product_category, sum(total_amount) as total_sales
    from flourmills_sales
    group by product_category
)
select product_category, total_sales
from category_sales
order by total_sales desc;

--Uloha 3
with product_sales as (
    select product_category, product_name, sum(total_amount) as total_product_sales
    from flourmills_sales
    group by product_category, product_name
),
ranked_products as (
    select product_category, product_name, total_product_sales,
           rank() over (partition by product_category order by total_product_sales desc) as category_rank
    from product_sales
)
select product_category, product_name, total_product_sales, category_rank
from ranked_products
where category_rank <= 3
order by product_category, category_rank;

--Uloha 4
with customer_revenue as (
    select customer_type, sum(total_amount) as revenue
    from flourmills_sales
    group by customer_type
),
revenue_share as (
    select customer_type, revenue,
           sum(revenue) over () as total_revenue,
           round(revenue * 100.0 / sum(revenue) over (), 2) as revenue_percentage
    from customer_revenue
)
select customer_type, revenue, total_revenue, revenue_percentage
from revenue_share
order by revenue desc;

--Uloha 5
with ranked_transactions as (
    select customer_id, product_name, sale_date, total_amount,
           row_number() over (partition by customer_id order by sale_date desc) as rn
    from flourmills_sales
)
select customer_id, product_name, sale_date, total_amount
from ranked_transactions
where rn = 1
order by customer_id asc;

--Uloha 6
with recursive date_range as (
    select min(sale_date) as start_date, max(sale_date) as end_date
    from flourmills_sales
),
calendar as (
    select start_date as calendar_date, end_date
    from date_range
    union all
    select (calendar_date + interval '1 day')::date, end_date
    from calendar
    where calendar_date < end_date
)
select calendar_date
from calendar
order by calendar_date asc;

--Uloha 7
with recursive monthly_revenue as (
    select date_trunc('month', sale_date) as month, sum(total_amount) as revenue
    from flourmills_sales
    group by date_trunc('month', sale_date)
),
ordered_months as (
    select row_number() over (order by month) as rn, month, revenue
    from monthly_revenue
),
cumulative_target as (
    select rn, month, revenue, revenue as cumulative_revenue
    from ordered_months
    where rn = 1

    union all

    select om.rn, om.month, om.revenue, ct.cumulative_revenue + om.revenue
    from cumulative_target ct
    join ordered_months om on om.rn = ct.rn + 1
    where ct.cumulative_revenue < 500000000
)
select rn, month, revenue, cumulative_revenue
from cumulative_target
order by rn;