USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET WEEK_NUMBER = 106;

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

-- -- setup code
CREATE TABLE customer_data (
    customer_id INTEGER,
    name STRING,
    email STRING,
    phone STRING,
    address STRING,
    credit_card_number STRING,
    account_balance FLOAT
);

INSERT INTO customer_data (customer_id, name, email, phone, address, credit_card_number, account_balance) VALUES
(1, 'John Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', '4111111111111111', 15000.00),
(2, 'Jane Smith', 'jane.smith@example.com', '234-567-8901', '456 Elm St', '4222222222222222', 8500.00),
(3, 'Alice Johnson', 'alice.johnson@example.com', '345-678-9012', '789 Oak St', '4333333333333333', 3000.00),
(4, 'Bob Brown', 'bob.brown@example.com', '456-789-0123', '101 Pine St', '4444444444444444', 500.00),
(5, 'Charlie Davis', 'charlie.davis@example.com', '567-890-1234', '202 Maple St', '4555555555555555', 12000.00),
(6, 'Diana Evans', 'diana.evans@example.com', '678-901-2345', '303 Cedar St', '4666666666666666', 2000.00),
(7, 'Frank Green', 'frank.green@example.com', '789-012-3456', '404 Birch St', '4777777777777777', 30000.00),
(8, 'Hannah White', 'hannah.white@example.com', '890-123-4567', '505 Willow St', '4888888888888888', 4500.00),
(9, 'Ian Black', 'ian.black@example.com', '901-234-5678', '606 Aspen St', '4999999999999999', 7500.00),
(10, 'Jill Blue', 'jill.blue@example.com', '012-345-6789', '707 Cherry St', '4000000000000000', 500.00);


-- role作成
USE ROLE SECURITYADMIN;
CREATE ROLE admin;
CREATE ROLE manager;
CREATE ROLE analyst;
GRANT ROLE admin TO USER hiroki;
GRANT ROLE manager TO USER hiroki;
GRANT ROLE analyst TO USER hiroki;

GRANT USAGE ON DATABASE DB_WEEK106 TO ROLE admin;
GRANT USAGE ON DATABASE DB_WEEK106 TO ROLE manager;
GRANT USAGE ON DATABASE DB_WEEK106 TO ROLE analyst;

GRANT USAGE ON SCHEMA DB_WEEK106.SCHEMA_WEEK106 TO ROLE admin;
GRANT USAGE ON SCHEMA DB_WEEK106.SCHEMA_WEEK106 TO ROLE manager;
GRANT USAGE ON SCHEMA DB_WEEK106.SCHEMA_WEEK106 TO ROLE analyst;
GRANT SELECT ON TABLE DB_WEEK106.SCHEMA_WEEK106.customer_data TO ROLE admin;
GRANT SELECT ON TABLE DB_WEEK106.SCHEMA_WEEK106.customer_data TO ROLE manager;
GRANT SELECT ON TABLE DB_WEEK106.SCHEMA_WEEK106.customer_data TO ROLE analyst;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE admin;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE manager;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE analyst;
-- show grants to user hiroki;

-- create or replace view test as select customer_id from customer_data;
-- select * from test;
-- drop view test;

-- マスキングポリシー作成
USE ROLE SYSADMIN;
CREATE OR REPLACE MASKING POLICY mask_credit_card AS (val string) returns string ->
  CASE
    WHEN is_role_in_session('ADMIN') THEN VAL
    -- 下4桁のみ表示
    WHEN is_role_in_session('MANAGER') THEN REGEXP_REPLACE(VAL,'^(.*)(.{4})$','******\\2')
    ELSE repeat('*', 6)
  END;

CREATE OR REPLACE MASKING POLICY mask_email AS (val string) returns string ->
  CASE
    WHEN is_role_in_session('ADMIN') THEN VAL
    -- ドメイン部分をマスク
    WHEN is_role_in_session('MANAGER') or is_role_in_session('ANALYST') THEN REGEXP_REPLACE(VAL,'@.*$','@******')
    ELSE repeat('*', 6)
  END;

CREATE OR REPLACE MASKING POLICY mask_account_balance AS (val float) returns float ->
  CASE
    WHEN is_role_in_session('ADMIN') THEN VAL
    -- 四捨五入して部分的にマスキング
    WHEN is_role_in_session('MANAGER') THEN ROUND(VAL)
    ELSE null
  END;

-- マスキングポリシー有効化
ALTER TABLE IF EXISTS customer_data MODIFY COLUMN credit_card_number SET MASKING POLICY mask_credit_card;
ALTER TABLE IF EXISTS customer_data MODIFY COLUMN email SET MASKING POLICY mask_email;
ALTER TABLE IF EXISTS customer_data MODIFY COLUMN account_balance SET MASKING POLICY mask_account_balance;

-- ALTER TABLE IF EXISTS customer_data MODIFY COLUMN credit_card_number UNSET MASKING POLICY;
-- ALTER TABLE IF EXISTS customer_data MODIFY COLUMN account_balance UNSET MASKING POLICY;

-- test
USE ROLE ADMIN;
select * from customer_data;

USE ROLE MANAGER;
select * from customer_data;

USE ROLE ANALYST;
select * from customer_data;