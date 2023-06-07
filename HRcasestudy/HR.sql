-- Questions
/*
1. Find the longest ongoing project for each department.
2. Find all employees who are not managers.
3. Find all employees who have been hired after the start of a project in their department.
4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
*/

Create database SQLcasestudy;

use sqlcasestudy;

-- Create 'departments' table
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name1 VARCHAR(50),
    manager_id INT
);

drop table departments;

-- Create 'employees' table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name1 VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

drop table employees;

-- Create 'projects' table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name1 VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

drop table projects;

-- Insert data into 'departments'
INSERT INTO departments (name1, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name1, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name1, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
 INSERT INTO projects (name1, start_date, end_date, department_id)
 VALUES ('HR Project 2', '2023-01-01', '2023-05-30', 1);
 
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name1 = 'John Doe')
WHERE name1 = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name1 = 'Jane Smith')
WHERE name1 = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name1 = 'Alice Johnson')
WHERE name1 = 'Sales';

select * from departments;

select * from employees;

delete from projects
where id =4;

select * from projects;

-- 1. Find the longest ongoing project for each department.

SELECT *
FROM projects
WHERE MONTH(CURDATE()) between MONTH(start_date) and MONTH(end_date)
AND YEAR(CURDATE()) between YEAR(start_date) and YEAR(end_date)
order by department_id;

-- Solution 1
SELECT D.name1 as Departments,P.name1,P.start_date,P.end_date, P.department_id
from Departments D inner join Projects P 
on D.id=P.department_id
WHERE CURDATE() between start_date and end_date
order by department_id;


-- Solution 2

select D.name1 as Departments,P.name1,P.start_date,P.end_date, P.department_id
from Departments D inner join Projects P 
on D.id=P.department_id
where curdate() >= start_date and
      curdate() <= end_date;
      
-- 2. Find all employees who are not managers.

-- Solution 1
select * from employees 
where id not in (select id from departments);

-- Solution 2
select E.*, M.manager_id
from employees E
left JOIN Departments M ON E.id = M.id
where manager_id is null;

-- 3. Find all employees who have been hired after the start of a project in their department.

-- Solution 1
select E.*,P.start_date,P.end_date from Employees E inner join Projects P
on E.department_id=P.department_id
where hire_date >= start_date and hire_date <= end_date;

-- Solution 2
select E.*,P.start_date,P.end_date from Employees E inner join Projects P
on E.department_id=P.department_id
where hire_date between start_date and end_date;

-- 4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
 
 with cte as (
select *,
rank() over(partition by department_id order by hire_date) as Highest_rank
from employees)
select * from cte
where Highest_rank =1;



-- 5. Find the duration between the hire date of each employee and the hire date of 
--     the next employee hired in the same department.

with cte as (
select *, datediff(curdate(), Hire_Date) as No_of_days_Different,
row_number() over(partition by department_id order by hire_date) RW
from employees)
, cte1 as (select *,
lead(No_of_days_Different)  over(partition by department_id order by hire_date) as next_employee_days
from cte)
select *, No_of_days_Different-next_employee_days as No_of_days_diff_between_employees_days
from cte1
where next_employee_days is not null;





      