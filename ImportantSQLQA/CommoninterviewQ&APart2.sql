use SQLpractice;

--1) Write an SQL query to retreive all details where name from employee table which starts with 'A'

drop table if exists employees_nw;
create table employees_nw(
empID int,
Fname varchar(50),
Sname varchar(100),
salary integer);

insert into employees_nw (empID,Fname,Sname,salary)
values ('1','Ram' ,'Sundar', '23000'),
('2','Sunar','Pichai',' 44000'),
('3','Mani','Kumar','67000'),
('4','Babu','Kaja','85000'),
('5','Anbu','Selvan', '21000'),
('6','Arivu','Selvan',' 40000'),
('7','Karuna','Ramasamy','50000');

Select * from employees_nw
where Fname like 'A%';

-- 2) Write a query to calculate the even and odd records from a Table

-- Even
Select * from employees_nw
where ([empID]%2)=0;

-- ODD
Select * from employees_nw
where ([empID]%2)=1;

-- Method 2

Select *,
 Case when ([empID]%2)=0 then 'Even'
	  When ([empID]%2)=1 then 'Odd'
	  end as Even_odd
	  from employees_nw;

-- Write a query to display the first and the last record from the employeeinfo table?

Select * from employees_nw
where empID in (Select MIN(empid) from employees_nw);

Select * from employees_nw
where empID in (Select Max(empid) from employees_nw);

Select top 1 * from employees_nw
order by empID desc;

-- Write a query to retrieve the first four characters of employees name from the employee Table?

Select *, SUBSTRING(fname,1,4) as Newcol from employees_nw;

-- 3) How to concatenate the FIRSTNAME, MiddleName and LASTNAME from EMP table to give a complete name?
CREATE TABLE tbStudent
(
 StudentId           INT NOT NULL PRIMARY KEY IDENTITY(1,1),
 FirstName         VARCHAR(50) NOT NULL,
 MiddleName    VARCHAR(50),
 LastName          VARCHAR(50)NOT NULL,
);

INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Ankit','Kumar','Sharma');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Rahul',NULL,'Singh');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Mayank',NULL,'Sharma');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Rajesh','Singh','Thakur');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Narender',NULL,'Chauhan');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Puneet','Kumar','Verma');
INSERT INTO tbStudent (FirstName,MiddleName,LastName) VALUES('Varun',NULL,'Shawan');


Select * from tbStudent;

Select FirstName +' '+MiddleName+' '+LastName as FUllname from tbStudent;

Select FirstName +' '+Isnull(MiddleName,'')+' '+LastName as FUllname from tbStudent;

Select FirstName +' '+coalesce(MiddleName,'')+' '+LastName as FUllname from tbStudent;

Select *, CONCAT(FirstName, ' ',MiddleName,' ',LastName) as FUllname from tbStudent;

-- 4) How do you split the first name, middle name, and last name in SQL?


CREATE TABLE tbStudent_new
(
 StudentId           INT NOT NULL PRIMARY KEY IDENTITY(1,1),
 FullName         VARCHAR(150) NOT NULL
 );

INSERT INTO tbStudent_new (FullName) VALUES('Sachin Ramesh Tendulkar');
INSERT INTO tbStudent_new (FullName) VALUES('Ankit Kumar Sharma');
INSERT INTO tbStudent_new (FullName) VALUES('Rahul Singh');
INSERT INTO tbStudent_new (FullName) VALUES('Mayank Sharma');
INSERT INTO tbStudent_new (FullName) VALUES('Puneet Kumar Verma');

select * from tbStudent_new;

select FullName,
   substring(FullName,1,CHARINDEX(' ',fullname)-1) as FirstName,
   substring(Right(Fullname,len(fullname)-charindex(' ',fullname)),1,charindex(' ',
   Right(Fullname,len(fullname)-charindex(' ',fullname)))) As Middle_Name,
   SUBSTRING(Fullname,LEN(fullname)-CHARINDEX(' ',REVERSE(Fullname))+1,LEN(fullname)) As Last_name
   from tbStudent_new;

   -- 5) Write an SQL query to report all customers who never order anything?

drop table if exists table1a;
create table table1a(
id varchar(133),
name varchar(133));

insert into table1a (id,name) 
values ('1','n1'),
('2','n2'),
('3','n3'),
('4','n4');


drop table if exists table1b;
create table table1b(
id varchar(133),
orderid integer);

insert into table1b (id,orderid) 
values ('1','2'),
('2','1');

select * from table1a;
select * from table1b;

select a.id,A.name,B.orderid from table1a A left join table1b B on A.id =B.id
where orderid is null;

-- solution 1

select id,name from
(select a.id,A.name,B.orderid from table1a A left join table1b B on A.id =B.id) a
where orderid is null;

-- solution 2
select id,name from table1a
where id not in (select id from table1b);

-- 6) Who earns the most money in each department. A high earner in a department is someone 
	-- who earns one of the department top three Highest salaries

drop table if exists table101;
create table table101(
id varchar(133),
name varchar(133),
salary integer ,
deptid integer );

insert into table101 (id,name,salary,deptid) 
values ('1','Ram','85000','1'),
('2','Sundar','80000','2'),
('3','Pichai','60000','2'),
('4','Babu','90000','1'),
('5','Palani','69000','1'),
('6','Roy','85000','1'),
('7','Raj','70000','1');

drop table if exists table102;
create table table102(
id varchar(133),
dname varchar(133));

insert into table102 (id,dname) 
values ('1','Marketing'),
('2','HR');

select * from table101;
select * from table102;


With cte as (
select a.id,a.name,a.salary,a.deptid,dname from table101 a left join table102 b
on a.deptid = b.id)
, cte1 as (select *,
dense_RANK() over(partition by deptid order by salary desc) RK
from cte)
select * from cte1
where RK in (1,2,3);

-- 7) Write a single query to calculate the sum of all positive value of x and the sum of all negative value of x

drop table if exists table103;
create table table103(id integer);

insert into table103 (id) 
values
('-5'),('0'),('1'),('9'),('-2'),('-3'),('-2'),('4'),('8'),('6'),('0'),('7'),('7'),('7'),('0'),('-2'),('2'),('8'),('1');

select * from table6;

-- Solution 1

select P_N, sum(ID) as Positive_Negative_values from
(select ID, case when ID>=0 then 'P' else 'N' end as P_N from table103) a
group by P_N;

-- solution 2

select sum(case when ID>0 then ID else 0 end)sum_pos,
sum(case when ID<0 then ID else 0 end)sum_neg from table6;

--8) Write a query to find out the employees who are getting the maximum salary in their departments.


drop table if exists table104;
create table table104(
name varchar(133),
deptno integer,
salary integer);

insert into table104 (name,deptno,salary) 
values ('Anbu','1','2831'),
('Ajay','1','1988'),
('Vijay','1','914'),
('Logu','2','1006'),
('Sakthi','2','796'),
('Krishna','3','1109'),
('Sanjay','3','1324'),
('Ramasamy','3','2960'),
('Raji','4','1810'),
('Raju','4','2124');

Select * from 
(Select *,
RANK() over(partition by deptno order by salary desc) RK
from table104) a
Where RK =1;

--9) Find out department-wise minimum salary, maximum salary, total salary and average salary.

Select deptno, MAX(salary) as Max_salary, MIN(salary) as Min_salary, 
SUM(salary) as Total_salary, AVG(salary) as Avg_salary from table104
group by deptno;

-- 10) Write a query to find out the deviation from average salary for the employees who are getting more than the average 

-- Solution 1

select *, salary - avg_salary as Devivation from
(Select *,
AVG(salary) over() as avg_salary
from table104) a
where salary > avg_salary;

-- Solution 2

Select *, (select AVG(salary) from table104) as Avg_salary, salary - (select AVG(salary) from table104) as Deviation
from table104
where salary > (select AVG(salary) from table104);
