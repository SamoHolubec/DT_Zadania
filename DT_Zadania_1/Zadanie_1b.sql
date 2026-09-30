-- Active: 1790180945242@@127.0.0.1@5432@datacraftinglab_db
create database datacraftinglab_db;

create table flourmills_sales (
    sales_id int primary key,
    sale_date date,
    region varchar(100),
    state varchar(100),
    product_category varchar(100),
    product_name varchar(150),
    customer_type varchar(100),
    customer_id int,
    quantity_sold int,
    unit_price decimal(10,2),
    discount_rate int,
    payment_method varchar(100),
    sales_rep varchar(150),
    warehouse varchar(100),
    delivery_status varchar(100),
    order_channel varchar(100),
    batch_number int,
    production_date date,
    total_amount decimal(10,2)
);

select * from flourmills_sales;

--Uloha 2
select product_name, total_amount
from flourmills_sales
where total_amount > (select avg(total_amount) from flourmills_sales);

--Uloha 3
select * from flourmills_sales
where product_category = ( select product_category from flourmills_sales
    group by product_category order by sum(total_amount) desc limit 1)
order by sales_id asc;

--Uloha 4
select product_name, total_amount, (select avg(total_amount) from flourmills_sales) as avg_amount
from flourmills_sales;

--Uloha 5
select product_name, total_amount, total_amount / (select sum(total_amount) from flourmills_sales) as amount_share
from flourmills_sales;

--Uloha 6
select month, monthly_sales
from (select extract(month from sale_date) as month, sum(total_amount) as monthly_sales from flourmills_sales
    group by extract(month from sale_date)) order by monthly_sales desc;

--Uloha 7
select product_category, total_sales from 
(select product_category, sum(total_amount) as total_sales from flourmills_sales group by product_category) where total_sales > 50000000;

--Uloha 8
select product_name, product_category, total_amount from flourmills_sales s1
where total_amount > (select avg(s2.total_amount) from flourmills_sales s2 where s2.product_category = s1.product_category);

--Uloha 9
select s1.product_name, s1.region, s1.total_amount, (select min(s2.total_amount) from flourmills_sales s2
where s2.region = s1.region) as region_min_amount from flourmills_sales s1;

--Uloha 10
select * from flourmills_sales s1
where exists (select 1 from flourmills_sales s2 where s2.product_name = s1.product_name
group by s2.product_name having count(distinct extract(month from s2.sale_date)) > 1);

--Uloha 11
select * from flourmills_sales s1
where exists (select 1 from flourmills_sales s2 where s2.product_category = s1.product_category and s2.total_amount > 200000);

--Uloha 12
select distinct s1.product_category from flourmills_sales s1
where exists (select 1 from flourmills_sales s2 where s2.product_category = s1.product_category 
group by s2.product_category having count(distinct s2.region) > 3);

--Uloha 13
select * from flourmills_sales s1
where exists (select 1 from flourmills_sales s2 where s2.region = s1.region and extract(year from s2.sale_date) = 2024);

--Uloha 14
select distinct s1.product_category from flourmills_sales s1
where not exists (select 1 from flourmills_sales s2 where s2.product_category = s1.product_category and s2.total_amount > 500000);

--Uloha 15
select distinct s1.region from flourmills_sales s1
where not exists (select 1 from flourmills_sales s2 where s2.region = s1.region and s2.product_category = 'Flour');