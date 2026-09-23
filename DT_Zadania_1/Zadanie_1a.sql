-- Active: 1790180945242@@127.0.0.1@5432@superstore
create database superstore;

create table customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country varchar(50),
    region VARCHAR(50)
);

create table products(
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

create table orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    product_id varchar(20) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10, 2),
    quantity INT,
    discount DECIMAL(10, 2),
    profit DECIMAL(10, 2)
);

select * from customers;
select * from products;
select * from orders;

--Uloha 2
select orders.order_id, customers.customer_name, orders.sales from orders 
join customers on orders.customer_id = customers.customer_id 
where orders.sales > 500 
order by orders.sales desc;

--Uloha 3
select orders.order_id, customers.customer_name, products.sub_category, orders.sales
from orders
join customers on orders.customer_id = customers.customer_id
join products on orders.product_id = products.product_id;

--Uloha 4
select customers.region, SUM(orders.sales) as celkova_hodnota
from customers customers
left join orders on customers.customer_id = orders.customer_id
group by customers.region
order by celkova_hodnota desc;

--Uloha 5
select products.product_name, SUM(orders.sales) as celkova_hodnota
from products
left join orders ON products.product_id = orders.product_id
group by products.product_name
order by celkova_hodnota desc;

--Uloha 6
select c.customer_name, o.order_id, o.sales
from customers c
left join orders o on c.customer_id = o.customer_id
union
select c.customer_name, o.order_id, o.sales
from customers c
right join orders o on c.customer_id = o.customer_id;

--Uloha7
select 
    c.region,
    SUM(o.sales) AS celkova_hodnota
from customers c
join orders o ON c.customer_id = o.customer_id
group by c.region
order by celkova_hodnota desc;

--Uloha 8
select 
    c.customer_name,
    count(o.order_id) as pocet_objednavok
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_name
order by pocet_objednavok desc;

--Uloha 9
select 
    p.sub_category,
    avg(o.discount) as priemerna_zlava
from products p
join orders o on p.product_id = o.product_id
group by p.sub_category
order by priemerna_zlava desc;

--Uloha 10
select 
    c.customer_name,
    sum(o.sales) as celkova_hodnota_nakupov
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_name
having sum(o.sales) > 2000
order by celkova_hodnota_nakupov desc;

--Uloha 11
select 
    c.region,
    sum(o.sales) as celkova_hodnota_predaja,
    avg(o.discount) as priemerna_zlava,
    count(o.order_id) as pocet_objednavok
from customers c
join orders o on c.customer_id = o.customer_id
group by c.region
order by celkova_hodnota_predaja desc;

--Uloha 12
select 
    c.region,
    count(case when o.sales > 1000 then o.order_id end) as pocet_high_value,
    count(case when o.sales <= 1000 then o.order_id end) as pocet_low_value
from customers c
join orders o on c.customer_id = o.customer_id
group by c.region
order by c.region;

--Uloha 13
select 
    c.customer_name,
    sum(o.sales) as celkovy_predaj,
    avg(o.discount) as priemerna_zlava,
    count(o.order_id) as pocet_objednavok,
    case 
        when sum(o.sales) > 2500 then 'VIP'
        else 'REGULAR'
    end as typ_zakaznika
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_name
order by celkovy_predaj desc;