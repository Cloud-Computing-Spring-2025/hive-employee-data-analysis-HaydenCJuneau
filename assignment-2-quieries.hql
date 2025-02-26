-- Employees who joined after 2015
select emp_id, name, join_date
from employee_db.employees
where year(join_date) >= 2015
order by join_date;

-- Average Salary of each department
select department, round(avg(salary), 2) as average_salary
from employee_db.employees
group by department;

-- Employees working on project Alpha
select emp_id, name, department, project
from employee_db.employees
where project = "Alpha"
order by department;

-- Count Employees by job role
select job_role, count(*) as employee_count
from employee_db.employees
group by job_role;

-- Employees earning more than average for their department
select e.emp_id, e.name, e.salary, e.department
from employee_db.employees e
join (
    select department, avg(salary) as avg_salary
    from employee_db.employees 
    group by department
) dept_avg
on e.department = dept_avg.department
where e.salary > dept_avg.avg_salary;

-- Department with Highest number of employees
select department, count(*) as employee_count
from employee_db.employees
group by department
order by employee_count desc
limit 1;

-- Remove null values
CREATE VIEW employees_no_nulls AS 
SELECT * FROM employee_db.employees 
WHERE emp_id IS NOT NULL 
    AND name IS NOT NULL 
    AND age IS NOT NULL 
    AND job_role IS NOT NULL 
    AND salary IS NOT NULL 
    AND project IS NOT NULL 
    AND join_date IS NOT NULL 
    AND department IS NOT NULL;

-- Join with dept table
create table if not exists departments (
    dept_id int,
    department_name string,
    loc string) 
row format delimited
fields terminated by ',' 
tblproperties("skip.header.line.count"="1");

load data inpath '/user/example/departments.csv' into table departments;

select e.emp_id, e.name, e.age, e.job_role, e.salary, e.join_date, 
       e.department, d.loc
from employee_db.employees e
join employee_db.departments d
ON e.department = d.department_name;

-- Rank employees based on salary
select e.emp_id, e.name, e.salary, e.department,
rank() over (
    partition by e.department
    order by e.salary desc
) as salary_rank
from employee_db.employees e;

-- Rank employees based on salary, take top 3
select emp_id, name, salary, department
from (
    select e.emp_id, e.name, e.salary, e.department,
    rank() over (
        partition by e.department
        order by e.salary desc
    ) as salary_rank
    from employee_db.employees e
) ranked_employees
where salary_rank <= 3;