-- Active: 1790180945242@@127.0.0.1@5432@superstore

--Uloha 1
create view high_value_customers as
select c.customer_id, c.customer_name, sum(o.sales) as total_sales
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.sales) > 2000;

SELECT * FROM high_value_customers;

--Uloha 2
create view regional_monthly_sales as
select c.region, date_trunc('month', o.order_date) as month, sum(o.sales) as monthly_sales
from customers c
join orders o on c.customer_id = o.customer_id
group by c.region, date_trunc('month', o.order_date);

select * from regional_monthly_sales;

--Uloha 3
create view analyst_orders as
select order_id, customer_id, product_id, sales, quantity, discount
from orders;

select * from analyst_orders;

--Uloha 4
create index idx_orders_customer_id on orders(customer_id);

select * from orders where customer_id = 'C001';

--Uloha 5
create index idx_orders_order_date on orders(order_date);

select date_trunc('month', order_date) as month, sum(sales) as total_sales
from orders
group by date_trunc('month', order_date)
order by month asc;

--Uloha 6
create index idx_orders_region_category on orders(customer_id, order_date);

select o.*, c.customer_name, c.region
from orders o
join customers c on c.customer_id = o.customer_id
where c.region = 'West' and o.order_date >= '2024-01-01';

--Uloha 7
explain analyze
select *
from orders
where customer_id = 'C001';

create database retail_sales;

create table orders (
    order_id varchar(20) primary key,
    customer_id varchar(20) not null,
    product_id varchar(20) not null,
    order_date date not null,
    region varchar(20) not null,
    category varchar(50) not null,
    ship_mode varchar(30) not null,
    sales decimal(10, 2) not null,
    profit decimal(10, 2) not null
);

alter database retail_sales set datestyle to 'ISO, MDY';

select * from orders;

--Uloha 8
create or replace procedure get_customer_sales(p_customer_id varchar)
language plpgsql
as $$
declare
    v_total_sales decimal(10, 2);
begin
    select sum(sales) into v_total_sales
    from orders
    where customer_id = p_customer_id;

    raise notice 'customer_id: %, total_sales: %', p_customer_id, v_total_sales;
end;
$$;

call get_customer_sales('C001');

--Uloha 9
create or replace procedure apply_regional_discount(region_name varchar, discount_rate decimal)
language plpgsql
as $$
begin
    update orders o
    set sales = o.sales * (1 - discount_rate)
    from customers c
    where c.customer_id = o.customer_id and c.region = region_name;

    raise notice 'aplikovana zlava % pre region %', discount_rate, region_name;
end;
$$;

call apply_regional_discount('West', 0.10);
call apply_regional_discount('West', 0.10);

--Uloha 10
create or replace procedure get_sales_between(start_date date, end_date date)
language plpgsql
as $$
declare
    v_total_sales decimal(12, 2);
begin
    select sum(sales) into v_total_sales
    from orders
    where order_date between start_date and end_date;

    raise notice 'od: %, do: %, total_sales: %', start_date, end_date, v_total_sales;
end;
$$;

call get_sales_between('2024-01-01', '2024-03-31');