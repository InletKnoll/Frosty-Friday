-- https://frostyfriday.org/blog/2023/01/13/week-29-intermediate/

USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET WEEK_NUMBER = 29;

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
create or replace file format frosty_csv
    type = csv
    skip_header = 1
    field_optionally_enclosed_by = '"';

create stage w29_stage
    url = 's3://frostyfridaychallenges/challenge_29/'
    file_format = frosty_csv;
    
list @w29_stage;
    
create table week29 as     
select t.$1::int as id, 
        t.$2::varchar(100) as first_name, 
        t.$3::varchar(100) as surname, 
        t.$4::varchar(250) as email, 
        t.$5::datetime as start_date 
from @w29_stage (pattern=>'.*start_dates.*') t;

