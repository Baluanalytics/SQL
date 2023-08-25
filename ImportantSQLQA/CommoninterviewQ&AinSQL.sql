use SQLpractice;

-- 1) Write the SQL query to get the third maximum salary of an employee from a table named employees

drop table if exists employees;
create table employees(
employee_name varchar(133),
salary integer);

insert into employees (employee_name,salary)
values ('Ram' ,'23000'),
('Sunar',' 44000'),
('Pichai',' 67000'),
('Babu',' 85000'),
('Anbu',' 21000'),
('Arivu',' 40000'),
('Ramu','50000');


select * from employees;


-- Method 1 How to find third highest salary in employee Table?

Select top 1 * from
(Select top 3 * from employees
order by salary desc) A
order by salary asc;








-- Method 2 How to find the nth highest salary in SQL?
-- To find the 2nd highest sal set n = 2
-- To find the 3rd highest sal set n = 3 and so on.
-- Let’s check to find 3rd highest salary:

select * from
(Select *,
RANK() over( order by salary desc) RK
from employees) A 
Where RK=2;





--MYSQL To find the 3rdh Highest salary query will return 3th highest 

Select * from employees
order by salary desc limit 2,1;   






---------------------------------------- 

--2)  How to delete duplicate rows from a SQL Table?

drop table if exists emp_details;
create table emp_details(
id varchar(133),
name varchar(133),
age integer);

insert into emp_details (id,name,age) 
values ('1','Arun','25'),
('2','Balu','27'),
('2','Balu','27'),
('3','Dev','22'),
('4','Edwin','25'),
('5','George','26'),
('4','Edwin','25');

select * from emp_details;





-- How to find duplicates from a table?

with cte as 
(select *,
ROW_NUMBER() over(partition by id order by age ) as RK
from emp_details) 
select * from cte
where RK>1;



-- How to delete duplicate in a table?

with cte as 
(select *,
ROW_NUMBER() over(partition by id order by age ) as RK
from emp_details) 
delete from cte
where RK>1;


-- Method 1

select distinct id,name,age from emp_details;



-- Method 2 In this step, we have to find how many rows are duplicated.
delete from emp_details where id in (
select id,COUNT(ID) 
from emp_details
group by id
having COUNT(ID)>1);

-- create a new duplicate table from original table
select * into emp_details_back from emp_details;

select * from emp_details_back;

-- Delete originial table
delete from emp_details;

-- copy table from duplicate to original
insert into emp_details select distinct * from emp_details_back;

select * from emp_details;

delete from emp_details_back;

-- Method 3 window functions

insert into emp_details_back
select id,name,age from
(select *,
ROW_NUMBER() over(partition by id order by age ) as RK
from emp_details) a
where RK=1;

delete from emp_details;
insert into emp_details select * from emp_details_back;




select * from emp_details;
-------------------------------


4) Extract username from email in SQL?

drop table if exists emp_tab;
create table emp_tab(
name varchar(133),
email varchar(133));


insert into emp_tab (name,email) values 
('Anbu','AnbuCSEAWN@EMAIL.COM'),
('Babu','BabuIRYF@EMAIL.COM'),
('Carbu','CarbuQZANB@EMAIL.COM'),
('Dhana','DhanaJN@EMAIL.COM'),
('Elango','ElangoVDHS09@kwglobal.COM'),
('Selva','Selva235263@xyz.COM'),
('Deva','DevaFNJHC65@EMAIL.COM'),
('Mala','Mala8BHSBX5GCS@yahoo.COM');

select * from emp_tab;

-- Write a query to extract username(characters before @ symbol) from the Email_ID column.


Select LEFT(email, charindex('@',email)-1) as Username from emp_tab;










-- Extract domain of Email from table in SQL Server

Select right(email, LEN(email) - charindex('@',email)) from emp_tab;







SELECT SUBSTRING (Email, CHARINDEX( '@', Email) + 1, LEN(Email)) 
FROM emp_tab;



--  Write a query to extract domain name like .com, .in, .au etc. from the Email_ID column.

--Method 1
Select right(email, LEN(email) - charindex('.',email)) from emp_tab;


--Method 2
SELECT substring(Email, CHARINDEX('.',email)+ 1, LEN(email)) FROM emp_tab; 

---------------------------


6) Employees who earn more than their managers?

drop table if exists emp_tab1;
create table emp_tab1(
ID INTEGER,
name varchar(133),
SALARY INTEGER,
MANAGERID INTEGER);

INSERT INTO emp_tab1 (ID,NAME,SALARY,MANAGERID)
VALUES 
('1','Kumar','70000','3'),
('2','Kanna','80000','4'),
('3','Arun','60000',NULL),
('4','Karuna','90000',NULL)
;

select A.id,A.name,A.salary,A.Managerid,B.Salary as Manager_salary
from emp_tab1 A left join emp_tab1 B on A.MANAGERID=B.ID
where A.SALARY>B.SALARY;




7) Employees who are not the managers?


select * from emp_tab1
where MANAGERID is not null;

select A.id,A.name,A.salary,A.Managerid,B.Salary as Manager_salary
from emp_tab1 A left join emp_tab1 B on A.MANAGERID=B.ID
where a.MANAGERID is not null;



select * from emp_tab1
where ID not in (select MANAGERID from emp_tab1 where MANAGERID is not null);









select * from emp_tab1 a
where not exists 
(select * from emp_tab1 where managerid =a.id);

-----------------------------------

-- MySQL Query to Copy, Duplicate or Backup Table

CREATE TABLE emp_dummy AS SELECT * FROM  transactions;

-- All the columns copied without any data.

CREATE TABLE emp_dummy AS SELECT * FROM  transactions
where 1!=1;

-- Query to Copy, Duplicate or Backup Table using Microsoft SQL Management studio

SELECT * INTO emp_back
FROM emp_tab;

-- All the columns copied without any data.

SELECT * INTO emp_back1
FROM emp_tab1
where 1!=1;

select * from emp_back1;


*******************

-- How to swap Gender in employees?

drop table if exists emp_Gender;
create table emp_Gender(
employee_name varchar(133),
salary integer,
Gender varchar(133));

insert into emp_Gender (employee_name,salary,Gender)
values ('Ram' ,'23000','Female'),
('Sundari',' 44000','Male'),
('Pichai',' 67000','Female'),
('Babu',' 85000','Female'),
('Anu',' 21000','Male'),
('Arivuselvi',' 40000','Male'),
('Ramu','50000','Female');



update emp_Gender
set Gender = Case when Gender = 'Male' Then 'Female'
			 Else 'Male'
			 End;

 select * from emp_gender;