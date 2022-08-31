Create database census2011;

use census2011;

create table censusdata1(
District varchar(30),
State varchar(30),
Growth float,
Sex_Ratio int,
Literacy decimal(5,2));

SET SESSION sql_mode = '';

load data infile 
'D:/Popdataset.csv'
into table censusdata1 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

create table censusdata2(
District varchar(30),
State varchar(25),
Area_km2 int,
Population int);

SET SESSION sql_mode = '';

load data infile 
'D:/Dataset3.csv'
into table censusdata2
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

select * from censusdata1;

select * from censusdata2;

/* number of rows into our dataset */

select count(*) from censusdata1;

select count(*) from censusdata2;

/*  dataset for Census2011, analyze for Tamil nadu */

select * from censusdata1
where state = 'Tamil nadu';

-- population of India 2011

select sum(population) as totalpopulationindia 
from censusdata2;

-- avg growth in all state India

select state, avg(growth) from censusdata1
group by state order by growth desc;

-- avg growth in Tamil Nadu

select state, avg(growth) avg_growth from censusdata1
where state = 'Tamil nadu';

-- avg sex ratio in india

select state, round(avg(sex_ratio),0) avg_sexratio  from censusdata1
group by state order by avg_sexratio desc;

-- avg sex ratio in Tamil Nadu

select state, round(avg(sex_ratio),0) avg_sexratio from censusdata1
where state = 'Tamil Nadu';

-- top 3 state showing highest growth ratio

select state, round(avg(sex_ratio),0) avg_sexratio  from censusdata1
group by state order by avg_sexratio desc limit 3;

-- bottom 3 state showing highest growth ratio

select state, round(avg(sex_ratio),0) avg_sexratio from censusdata1
group by state order by avg_sexratio asc limit 3;

-- avg literacy rate in India

select state, round(avg(literacy),0) avg_literacy from censusdata1
group by state order by avg_literacy desc;


-- avg literacy rate more than 90% in India

select state, round(avg(literacy),0) avg_literacy from censusdata1
group by state having avg_literacy >90 order by avg_literacy desc;

-- avg literacy rate in Tamil Nadu

select state, round(avg(literacy),0) avg_literacy from censusdata1
where state in ('Tamil nadu');

-- top and bottom 3 states in literacy using union

drop table if exists topstates;
create table topstates
( state varchar(255),
  topstate float);

insert into topstates
select state, round(avg(literacy),0) avg_literacy from censusdata1
group by state order by avg_literacy desc limit 3;

drop table if exists bottomstates;
create table bottomstates
( state varchar(255),
  bottomstate float);

insert into bottomstates
select state, round(avg(literacy),0) avg_literacy from censusdata1
group by state order by avg_literacy asc limit 3;

select state, topstate from topstates
union 
select state, bottomstate from bottomstates;

-- distinct state in India

select distinct(state) from censusdata1;

-- select state start with letters in vowles,  without duplicate and also alphabetical order

select distinct(state) from censusdata1
where left(state,1) in ('a','e','i','o','u')
order by state asc;

-- select state start with letters in vowles and also end with letters in vowles, without duplicate 

select distinct(state) from censusdata1
where left(state,1) in ('a','e','i','o','u') and 
right(state,1) in ('a','e','i','o','u')
order by state asc;

-- Either start and end with letters in vowles in state

select distinct(state) from censusdata1
where left(state,1) in ('a','e','i','o','u') or
right(state,1) in ('a','e','i','o','u')
order by state asc;

select * from censusdata1;
select * from censusdata2;

-- Inner join both tables

select a.district, a.state, a.sex_ratio, b.population from censusdata1 a
inner join censusdata2 b
on a.district = b.district;

-- total males and females

select d.state,sum(d.males) Total_Males,sum(d.females) Total_Females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) Males, 
round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) Females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio, b.population from 
censusdata1 a inner join censusdata2 b on a.district=b.district) c) d
group by d.state order by d.state;  

-- total literacy rate

select c.State,sum(literate_people) Total_Literate_pop,sum(illiterate_people) Total_Lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from censusdata1 a 
inner join censusdata2 b on a.district=b.district) d) c
group by c.state order by c.state;

-- population in previous census


select sum(m.previous_census_population) Previous_Census_Population,sum(m.current_census_population) Current_Census_Population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from censusdata1 a inner join censusdata2 b on a.district=b.district) d) e
group by e.state)m;


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from censusdata1 a inner join censusdata2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from censusdata2)z) r on q.keyy=r.keyy)g;

-- window function

-- output top 3 districts from each state with highest literacy rate in India


select top.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) disrnk from censusdata1) top
where top.disrnk in (1,2,3) order by state;

-- output bottom 3 districts from each state with lowest literacy rate in India

select bot.* from
(select district,state,literacy,
rank() over(partition by state order by literacy asc) botrank from censusdata1) bot
where bot.botrank in (1,2,3) order by state;

-- Tamil Nadu literacy rate from top to bottom

select TNLiteracy.* from
(select state,district,literacy,
rank() over(partition by state order by literacy desc) TNrank from censusdata1) TNLiteracy
where state ='Tamil Nadu';

-- CTE
-- Kerala literacy rate from top to bottom

with KLiteracy as
(select state,district,literacy,
rank() over(partition by state order by literacy desc) Krank from censusdata1) 
select state,district,literacy,Krank from KLiteracy
where state ='Kerala';

-- Total population in Tamil Nadu district wise rank

select a.* from
(select *,
rank() over(partition by state order by population desc) poprank
from censusdata2) a
where state = 'Tamil Nadu';

-- Total population state wise in India (rank function)

with toppop as 
(select state, sum(population) totalpopulation from censusdata2
group by state order by totalpopulation desc) 
select state,totalpopulation,
rank() over(order by totalpopulation desc) poprank from toppop;

-- Total population in India rows runing total

with popruningtotal as 
(select state, sum(population) totalpopulation from censusdata2
group by state order by totalpopulation desc) 
select State,Totalpopulation,
sum(totalpopulation) over(order by totalpopulation desc rows between unbounded preceding and current row) 
Runingtotal from popruningtotal;

-- Total population in India rows runing total

with poptotal as 
(select state, sum(population) totalpopulationstate from censusdata2
group by state order by totalpopulationstate desc) 
select State,Totalpopulationstate,
sum(totalpopulationstate) over(order by totalpopulationstate desc rows between unbounded preceding and unbounded following) 
TotalpopulationIndia from poptotal;

