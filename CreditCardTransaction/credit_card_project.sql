use namastesql;

select * from credit_card_transcations;

select MIN(transaction_date) as Begin_date, MAX(transaction_date) as End_date from credit_card_transcations;

select distinct card_type from credit_card_transcations;
/*
Silver
Signature
Gold
Platinum
*/

select distinct exp_type from credit_card_transcations;
/*
Entertainment
Food
Bills
Fuel
Travel
Grocery
*/

-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

select * from credit_card_transcations;

with cte1 as(
select city,SUM(amount) as total_spend
from credit_card_transcations
group by city)
, total_spent as(select SUM(amount) as total_amount from credit_card_transcations)
select top 5 cte1.*, total_amount from
cte1, total_spent
order by total_spend desc;


with cte1 as(
select city,SUM(amount) as total_spend
from credit_card_transcations
group by city)
, total_spent as(select SUM(cast(amount as bigint)) as total_amount from credit_card_transcations)
select top 5 cte1.*, round(total_spend*1.0/total_amount*100,2) as percentage_contribution from
cte1 inner join total_spent on 1=1
order by total_spend desc;

-- 2- write a query to print highest spend month and amount spent in that month for each card type

with cte as
(select card_type, DATEPART(YEAR,transaction_date) as yt, DATEPART(MONTH,transaction_date) as mt, SUM(amount) as total_spend
from credit_card_transcations
group by card_type,DATEPART(YEAR,transaction_date),DATEPART(MONTH,transaction_date)
--order by card_type, total_spend desc
)
, rnk_cte as (
select *,
RANK() over(partition by card_type order by total_spend desc) as rn
from cte)
select * from rnk_cte
where rn =1;

-- 3- write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

select * from credit_card_transcations;

with cte as (
select *,
SUM(amount) over(partition by card_type order by transaction_date,transaction_id) as Total_spend
from credit_card_transcations)
, cte_rk as (
select *,
RANK() over(partition by card_type order by Total_spend) as rn
from cte
where Total_spend >= 1000000)
select * from cte_rk
where rn =1;
;

-- 4- write a query to find city which had lowest percentage spend for gold card type

select * from credit_card_transcations;

with cte as (
select city, card_type, SUM(amount) as amount, SUM(case when card_type='Gold' then amount end) as Gold_amount
from credit_card_transcations
group by city, card_type
)
select top 1 city, SUM(Gold_amount)*1.0/SUM(amount) as ratio
from cte
group by city
having SUM(Gold_amount) is not null
order by ratio;

with cte as (
select city, card_type, SUM(amount) as amount, SUM(case when card_type='Gold' then amount end) as Gold_amount
from credit_card_transcations
group by city, card_type
)
select top 1 city, SUM(Gold_amount)*1.0/SUM(amount) as ratio
from cte
group by city
having count(Gold_amount) > 0
order by ratio;

-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
select * from credit_card_transcations;


with cte as (
select city, exp_type, SUM(amount) as Total_amount from credit_card_transcations
group by city, exp_type)
, rank_city as (select *,
RANK() over(partition by city order by Total_amount desc) as rn_desc,
RANK() over(partition by city order by Total_amount asc) as rn_asc
from cte)
select 
city, max(case when rn_asc = 1 then exp_type end) as lowest_expense_type, 
min(case when rn_desc = 1 then exp_type end) as highest_expense_type
from rank_city
group by city
;

-- 6- write a query to find percentage contribution of spends by females for each expense type

select exp_type, SUM(case when gender = 'F' then amount else 0 end)/SUM(amount) as percentage_female_contribution
from credit_card_transcations
group by exp_type
order by percentage_female_contribution desc;

-- 7- which card and expense type combination saw highest month over month growth in Jan-2014

select * from credit_card_transcations;

with cte as (
select card_type, exp_type, SUM(amount) as Total_amount, DATEPART(year,transaction_date) as yt, DATEPART(month,transaction_date) as mt
from credit_card_transcations
group by card_type,exp_type,DATEPART(year,transaction_date),DATEPART(month,transaction_date))
, prev_mon_cte as ( select *,
LAG(total_amount) over(partition by card_type, exp_type order by yt,mt) as prev_month_spend
from cte)
select top 1 *, (total_amount -prev_month_spend)/prev_month_spend as month_growth
from prev_mon_cte
where prev_month_spend is not null and yt =2014 and mt=1
order by month_growth desc;

with cte as (
select card_type, exp_type, SUM(amount) as Total_amount, DATEPART(year,transaction_date) as yt, DATEPART(month,transaction_date) as mt
from credit_card_transcations
group by card_type,exp_type,DATEPART(year,transaction_date),DATEPART(month,transaction_date))
, prev_mon_cte as ( select *,
LAG(total_amount) over(partition by card_type, exp_type order by yt,mt) as prev_month_spend
from cte)
select top 1 *, (total_amount -prev_month_spend) as month_growth
from prev_mon_cte
where prev_month_spend is not null and yt =2014 and mt=1
order by month_growth desc;

-- 9- during weekends which city has highest total spend to total no of transcations ratio 

select top 1 city, SUM(amount)*1.0/COUNT(1) as ratio
from credit_card_transcations
where DATEPART(weekday,transaction_date) in (1,7)
group by city
order by ratio desc;

-- 10- which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte as (
select *
, ROW_NUMBER() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card_transcations)
select top 1 city, datediff(day,min(transaction_date),MAX(transaction_date)) as datediff1
from cte
where rn =1 or rn = 500
group by city
having COUNT(1)=2
order by datediff1;



