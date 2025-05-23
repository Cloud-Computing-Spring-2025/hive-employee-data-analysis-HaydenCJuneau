# Assignment 2 - Hadoop Hive Employee Database

## Setup
```
use employee_db;


create table if not exists employees ( 
    emp_id int,
    name string,
    age int,
    job_role string,
    salary int,
    project string,
    join_date date)
partitioned by (department string)
row format delimited
fields terminated by ','
tblproperties("skip.header.line.count"="1"); 


create table if not exists temp_employees (
    emp_id int,
    name string,
    age int,
    job_role string,
    salary int,
    project string,
    join_date date,
    department string) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',' 
tblproperties("skip.header.line.count"="1");


load data inpath '/user/example/employees.csv' into table temp_employees;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;


insert into table employees partition (department)
select emp_id, name, age, job_role, salary, project, join_date, department
from temp_employees;

show partitions employees;

select * from employees limit 10;
```

## Queries
### 1: Employees who joined after 2015
```
select emp_id, name, join_date
from employee_db.employees
where year(join_date) >= 2015
order by join_date;
```

### 2: Average Salary for each department
```
select department, round(avg(salary), 2) as average_salary
from employee_db.employees
group by department;
```

### 3: Employees working on the Alpha project
```
select emp_id, name, department, project
from employee_db.employees
where project = "Alpha"
order by department;
```

### 4: Count employees for each Job Role
```
select job_role, count(*) as employee_count
from employee_db.employees
group by job_role;
```

### 5: Employees earning more than Average Salary for their dept
```
select e.emp_id, e.name, e.salary, e.department
from employee_db.employees e
join (
    select department, avg(salary) as avg_salary
    from employee_db.employees 
    group by department
) dept_avg
on e.department = dept_avg.department
where e.salary > dept_avg.avg_salary;
```

### 6: Department with highest employee count
```
select department, count(*) as employee_count
from employee_db.employees
group by department
order by employee_count desc
limit 1;
```

### 7: Exclude any rows with null values
```
-- Create a non-null view
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
```

### 8: Join with Department Table
```
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
```

### 9: Rank employess based on Salary for their Department
```
select e.emp_id, e.name, e.salary, e.department,
rank() over (
    partition by e.department
    order by e.salary desc
) as salary_rank
from employee_db.employees e;
```

### 10: Top three earners for each Department
```
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
```