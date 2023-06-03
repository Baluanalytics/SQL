use SQLpractice;

--1) Which product has the highest price? Only return a single row.

--2) Which customer has made the most orders?

--3) What’s the total revenue per product?

--4) Find the day with the highest revenue.

--5) Find the first order (by date) for each customer.

--6) Find the top 3 customers who have ordered the most distinct products

--7) Which product has been bought the least in terms of quantity?

--8) What is the median order total?

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

--10) Find customers who have ordered the product with the highest price.


CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

select * from customers;
select * from products;
select * from orders;
select * from order_items;

--1) Which product has the highest price? Only return a single row.


select * from products
where price in (select MAX(price) from products);


--2) Which customer has made the most orders?

select a.customer_id,COUNT(*) as No_of_orders,concat(b.first_name,' ',b.last_name) as Customer_name from orders a 
inner join customers b on
a.customer_id=b.customer_id
group by a.customer_id,b.customer_id,b.first_name,b.last_name
having COUNT(*)>1;

--3) What’s the total revenue per product?


with cte as (select P.*, O.order_id,O.quantity, price*quantity as Total from products P inner join order_items O
on P.product_id=O.product_id)
select product_id,product_name,SUM(Total) as Total_revenue_per_product
from cte
group by product_id,product_name
order by Total_revenue_per_product desc;


--4) Find the day with the highest revenue.

with cte as (
select P.*, OI.order_id,OI.quantity, O.order_date, price*quantity as Total from products P 
inner join order_items OI
on P.product_id=OI.product_id
inner join orders O
on O.order_id=OI.order_id)
select order_date, SUM(Total) as Highest_revnue_per_day
from cte
group by order_date
order by Highest_revnue_per_day desc;


--5) Find the first order (by date) for each customer.


select distinct(a.customer_id),concat(b.first_name,' ',b.last_name) as Customer_name,min(a.order_date) as first_order_date from orders a 
inner join customers b on
a.customer_id=b.customer_id
group by a.customer_id,b.first_name,b.last_name;

--6) Find the top 3 customers who have ordered the most distinct products

select concat(C.first_name,' ',C.last_name) as Customer_name, count(distinct P.product_name) as Uniqueproduct from order_items OI 
inner join orders O on OI.order_id=O.order_id
inner join customers C on C.customer_id= O.customer_id
inner join products P on P.product_id=OI.product_id
group by C.first_name,C.last_name
order by Uniqueproduct desc;

--7) Which product has been bought the least in terms of quantity?

with cte as (select P.*, O.order_id,O.quantity from products P inner join order_items O
on P.product_id=O.product_id)
select product_id,product_name,SUM(quantity) as Total_no_of_quantity
from cte
group by product_id,product_name
order by Total_no_of_quantity;

--8) What is the median order total?


with cte as (select O.order_id, SUM( price*quantity) as Total from orders O inner join order_items OI
on  O.order_id=OI.order_id
inner join products P on OI.product_id=P.product_id
group by O.order_id)
select PERCENTILE_CONT(0.5)
within group (order by Total) over () as Median_price
from cte; 



--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.


with cte as (
select P.*, OI.order_id,OI.quantity, O.order_date, price*quantity as Total from products P 
inner join order_items OI
on P.product_id=OI.product_id
inner join orders O
on O.order_id=OI.order_id)
, cte1 as (select order_id, SUM(Total) as Total_amt
from cte
group by order_id)
select order_id, Total_amt, 
case when Total_amt > 300 then 'Expensive'
	when Total_amt > 100 then 'Affordable'
	else 'Cheap' end as Rate_flag
	from cte1
	order by Total_amt desc;


--10) Find customers who have ordered the product with the highest price.

	
with cte as (
select P.*, OI.order_id,OI.quantity, O.order_date, price*quantity as Total,c.customer_id,concat(c.first_name,' ',c.last_name) as Customer_name from products P 
inner join order_items OI
on P.product_id=OI.product_id
inner join orders O
on O.order_id=OI.order_id
inner join customers C
on O.customer_id=C.customer_id)
select top 2 customer_id,customer_name,product_name, count(quantity) as quantity,price as highest_price
from cte
group by customer_id,customer_name,product_name,price 
order by highest_price desc;