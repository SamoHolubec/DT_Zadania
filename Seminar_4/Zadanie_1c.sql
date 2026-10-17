-- Active: 1790180945242@@127.0.0.1@5432@retail
create database retail;

set datestyle = 'ISO, DMY';
alter database retail set datestyle = 'ISO, DMY';

create table retail_sales (
    invoice_no varchar(20),
    stock_code varchar(50),
    description text,
    quantity int,
    invoice_date timestamp,
    unit_price decimal(10,2),
    customer_id int,
    country varchar(100)
);

select * from retail_sales;

--Uloha 2
select
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    quantity * unit_price as revenue,
    sum(quantity * unit_price) over (
        partition by customer_id
        order by invoice_date
        range between interval '14 days' preceding and current row
    ) as revenue_last_14_days
from retail_sales
where customer_id is not null
order by customer_id, invoice_date;

--Uloha 3
select
    stock_code,
    country,
    invoice_date,
    quantity,
    round(avg(quantity) over (
        partition by stock_code, country
        order by invoice_date
        range between interval '7 days' preceding and current row
    ), 2) as avg_quantity_7_days
from retail_sales
where quantity > 1
order by stock_code, country, invoice_date;

--Uloha 4
with orders as (
    select distinct
        customer_id,
        invoice_no,
        invoice_date::date as invoice_date
    from retail_sales
    where customer_id is not null
),
next_orders as (
    select
        customer_id,
        invoice_no,
        invoice_date,
        lead(invoice_date) over (
            partition by customer_id
            order by invoice_date, invoice_no
        ) as next_invoice_date
    from orders
)
select
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date - invoice_date as days_to_next_invoice
from next_orders
where next_invoice_date is not null
order by days_to_next_invoice desc;

--Uloha 5
with price_changes as (
    select
        stock_code,
        invoice_no,
        invoice_date,
        lag(unit_price) over (
            partition by stock_code
            order by invoice_date, invoice_no
        ) as previous_price,
        unit_price as current_price
    from retail_sales
)
select
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    current_price - previous_price as price_difference
from price_changes
where previous_price is not null
  and current_price <> previous_price
order by invoice_date, stock_code;

--Uloha 6
with customer_totals as (
    select
        customer_id,
        sum(quantity * unit_price) as total_amount
    from retail_sales
    where customer_id is not null
    group by customer_id
)
select
    customer_id,
    total_amount,
    ntile(4) over (order by total_amount desc, customer_id) as sales_quartile
from customer_totals
order by total_amount desc, customer_id;

--Uloha 7
with monthly_sales as (
    select
        country,
        date_trunc('month', invoice_date)::date as sales_month,
        sum(quantity * unit_price) as total_amount
    from retail_sales
    group by country, date_trunc('month', invoice_date)::date
)
select
    country,
    sales_month,
    total_amount,
    ntile(4) over (
        partition by country
        order by total_amount desc, sales_month
    ) as sales_quartile
from monthly_sales
order by country, sales_month;

--Uloha 8
with ranked_purchases as (
    select
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        row_number() over (
            partition by customer_id
            order by invoice_date, invoice_no, stock_code
        ) as rn
    from retail_sales
    where customer_id is not null
)
select
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
from ranked_purchases
where rn = 1
order by customer_id;

--Uloha 9
with ranked_items as (
    select
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        quantity * unit_price as amount,
        row_number() over (
            partition by invoice_no
            order by quantity * unit_price desc, stock_code
        ) as row_num
    from retail_sales
)
select
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
from ranked_items
where row_num <= 3
order by invoice_no, row_num;

--Uloha 10
with customer_monthly_sales as (
    select
        country,
        date_trunc('month', invoice_date)::date as sales_month,
        customer_id,
        sum(quantity * unit_price) as total_amount
    from retail_sales
    where customer_id is not null
    group by country, date_trunc('month', invoice_date)::date, customer_id
),
ranked_customers as (
    select
        country,
        sales_month,
        customer_id,
        total_amount,
        dense_rank() over (
            partition by country, sales_month
            order by total_amount desc
        ) as sales_rank
    from customer_monthly_sales
)
select
    country,
    sales_month,
    customer_id,
    total_amount,
    sales_rank
from ranked_customers
where sales_rank <= 5
order by country, sales_month, sales_rank, customer_id;

--Uloha 11
with ranked_items as (
    select
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        dense_rank() over (
            partition by invoice_no
            order by unit_price desc
        ) as price_rank
    from retail_sales
)
select
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
from ranked_items
where price_rank <= 5
order by invoice_no, price_rank, stock_code;