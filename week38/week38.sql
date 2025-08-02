USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET WEEK_NUMBER = 38;

-- 動的にデータベースとスキーマを作成
SET DB_NAME = 'DB_WEEK' || $WEEK_NUMBER;
SET SCHEMA_NAME = $DB_NAME || '.SCHEMA_WEEK' || $WEEK_NUMBER;

BEGIN
-- データベース作成
EXECUTE IMMEDIATE 'CREATE DATABASE ' || $DB_NAME;

-- スキーマ作成
EXECUTE IMMEDIATE 'CREATE SCHEMA ' || $SCHEMA_NAME;

-- スキーマをUSE
EXECUTE IMMEDIATE 'USE SCHEMA ' || $SCHEMA_NAME;
END;

-- setup code
-- Create first table
CREATE TABLE employees (
id INT,
name VARCHAR(50),
department VARCHAR(50)
);

-- Insert example data into first table

INSERT INTO employees (id, name, department)
VALUES
(1, 'Alice', 'Sales'),
(2, 'Bob', 'Marketing');

-- Create second table
CREATE TABLE sales (
id INT,
employee_id INT,
sale_amount DECIMAL(10, 2)
);

-- Insert example data into second table
INSERT INTO sales (id, employee_id, sale_amount)
VALUES
(1, 1, 100.00),
(2, 1, 200.00),
(3, 2, 150.00);

-- Create view that combines both tables
CREATE VIEW employee_sales AS
SELECT e.id, e.name, e.department, s.sale_amount
FROM employees e
JOIN sales s ON e.id = s.employee_id;

-- Query the view to verify the data
SELECT * FROM employee_sales;

CREATE OR REPLACE STREAM employee_sales_stream ON VIEW employee_sales;

delete from sales where id=1;

table sales;

select * from employee_sales_stream where metadata$action = 'DELETE';


create table deleted_sales
as (select name, department,sale_amount from employee_sales_stream where metadata$action = 'DELETE');

table deleted_sales;