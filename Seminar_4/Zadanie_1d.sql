-- Active: 1790180945242@@127.0.0.1@5432@superstore

select customer_name, order_id, order_date
from (select
        c.customer_name,
        o.order_id,
        o.order_date,
        row_number() over (
            partition by o.customer_id
            order by o.order_date desc
        ) as rn
    from customers c
    join orders o on o.customer_id = c.customer_id
) t
where rn <= 2
order by customer_name, rn;

--Uloha 2
select
    region,
    customer_name,
    total_profit,
    rank() over (
        partition by region
        order by total_profit desc
    ) as rank_profit,
    dense_rank() over (
        partition by region
        order by total_profit desc
    ) as dense_rank_profit
from (
    select
        c.customer_id,
        c.customer_name,
        c.region,
        sum(o.profit) as total_profit
    from customers c
    join orders o on o.customer_id = c.customer_id
    group by c.customer_id, c.customer_name, c.region
) t
order by region, rank_profit, customer_name;

--Uloha 3
select
    customer_name,
    total_sales,
    ntile(4) over (
        order by total_sales desc
    ) as quartile
from (
    select
        c.customer_id,
        c.customer_name,
        sum(o.sales) as total_sales
    from customers c
    join orders o on o.customer_id = c.customer_id
    group by c.customer_id, c.customer_name
) t
order by quartile, total_sales desc, customer_name;

--Uloha 4
select
    month,
    monthly_sales,
    lag(monthly_sales, 1) over (order by month) as prev_month_sales,
    lead(monthly_sales, 1) over (order by month) as next_month_sales
from (
    select
        date_trunc('month', order_date)::date as month,
        sum(sales) as monthly_sales
    from orders
    group by date_trunc('month', order_date)
) t
order by month;

--Uloha 5
with product_totals as (
    select
        p.product_id,
        p.category,
        p.product_name,
        sum(o.sales) as product_sales
    from orders o
    join products p on p.product_id = o.product_id
    group by p.product_id, p.category, p.product_name
)
select
    category,
    product_name,
    product_sales,
    sum(product_sales) over (partition by category) as category_total,
    round(
        product_sales * 100.0 / sum(product_sales) over (partition by category),
        2
    ) as pct_of_category
from product_totals
order by category, pct_of_category desc, product_name;

--Uloha 6
select distinct
    customer_id,
    customer_name,
    last_order_date
from (
    select
        c.customer_id,
        c.customer_name,
        o.order_date,
        max(o.order_date) over (
            partition by c.customer_id
        ) as last_order_date,
        max(o.order_date) over () as latest_order_date
    from customers c
    join orders o on o.customer_id = c.customer_id
) t
where last_order_date < latest_order_date - interval '90 days'
order by last_order_date, customer_name;

--Uloha 7
with monthly as (
    select
        date_trunc('month', order_date)::date as month,
        sum(sales) as monthly_sales
    from orders
    group by date_trunc('month', order_date)
),
with_prev as (
    select
        month,
        monthly_sales,
        lag(monthly_sales) over (order by month) as prev_month_sales
    from monthly
)
select
    month,
    monthly_sales,
    prev_month_sales,
    monthly_sales - prev_month_sales as sales_change,
    round(
        (monthly_sales - prev_month_sales) * 100.0 / nullif(prev_month_sales, 0),
        2
    ) as growth_percentage
from with_prev
order by month;

--Uloha 8
with first_purchase as (
    select
        customer_id,
        date_trunc('month', min(order_date))::date as first_month
    from orders
    group by customer_id
)
select count(*) as returning_customers
from first_purchase fp
where fp.first_month = date '2024-06-01'
  and exists (
      select 1
      from orders o
      where o.customer_id = fp.customer_id
        and o.order_date >= fp.first_month + interval '1 month'
  );