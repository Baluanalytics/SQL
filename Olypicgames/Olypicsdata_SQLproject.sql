use namastesql;

select * from athlete_event; --Total Records 65,535

select * from athlete;   -- Total Records 65.535


--1 which team has won the maximum gold medals over the years.

SELECT TOP 1 B.team, COUNT(distinct A.event) as Gold_medals  FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id
WHERE A.medal='Gold'
GROUP BY B.team
ORDER BY Gold_medals DESC;


--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

WITH cte AS( 
SELECT B.team, A.year,  COUNT(distinct A.event) as silver_medals,
RANK() OVER(PARTITION BY TEAM ORDER BY COUNT(DISTINCT A.event) DESC) AS RK FROM
athlete_event A inner join athlete B on A.athlete_id=B.id
WHERE A.medal='Silver' 
GROUP BY B.team,A.year)
SELECT team, SUM(silver_medals) as total_silver_medals, MAX(CASE WHEN RK=1 then year end) as year_of_max_silver
from cte
GROUP BY team;


--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

WITH cte as (
SELECT B.name,A.medal  FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id)
SELECT TOP 1 name,COUNT(1) as No_of_goldmedals from cte
where name not in (select distinct name from cte where medal in ('silver','bronze')) and medal='Gold'
group by name
order by No_of_goldmedals desc;


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

WITH cte as (
SELECT A.year, B.name, COUNT(1) as No_of_goldmedals FROM
athlete_event A inner join athlete B on A.athlete_id=B.id
where medal='Gold'
GROUP BY A.year,B.name)
SELECT year,No_of_goldmedals,STRING_AGG(name,',') as players from
(SELECT *,
RANK() over(PARTITION BY YEAR ORDER BY No_of_goldmedals DESC) AS RK
from cte) a where RK=1
GROUP BY year,No_of_goldmedals;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

WITH cte AS (
SELECT A.medal,A.year,A.event,COUNT(distinct A.event) as Sport FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id
WHERE B.team='India' and A.medal in ('Gold','silver','bronze')
GROUP BY A.medal,A.year,A.event)
, cte1 AS (SELECT *,
RANK() over(PARTITION by medal ORDER BY year asc) AS RK
FROM cte)
SELECT medal,YEAR,event from cte1
WHERE RK=1;

--6 find players who won gold medal in summer and winter olympics both.

SELECT B.name, COUNT(distinct A.season) as Gold_medals  FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id
WHERE A.medal='Gold'and A.season in ('summer','winter')
GROUP BY B.name
HAVING COUNT(DISTINCT A.season) =2;

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.


SELECT B.name, A.year  FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id
WHERE A.medal IN ('Gold','silver','bronze')
GROUP BY B.name,A.year
HAVING COUNT(DISTINCT A.medal) =3
ORDER BY B.name asc;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

WITH cte as (
SELECT B.name, A.year,A.event  FROM athlete_event A 
inner join athlete B on A.athlete_id=B.id
WHERE A.year>=2000 and A.season='Summer' and A.medal='Gold')
, cte1 AS (SELECT *,
LAG(year,1) over(PARTITION BY name,event ORDER BY year ) as Prev_year
, LEAD(year,1) over(PARTITION BY name,event ORDER BY year ) as Nex_year
from cte)
SELECT * from cte1
WHERE year=Prev_year+4 and year=Nex_year-4
;
 