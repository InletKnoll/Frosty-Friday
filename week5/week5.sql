USE ROLE SYSADMIN;

CREATE DATABASE DB_WEEK5;

CREATE SCHEMA DB_WEEK5.SCHEMA_WEEK5;

USE SCHEMA DB_WEEK5.SCHEMA_WEEK5;

CREATE OR REPLACE TABLE FF_week_5 (START_INT VARCHAR);

DESC TABLE FF_WEEK_5;

SELECT
  count(*)
FROM
  FF_WEEK_5;

SELECT
  *
FROM
  FF_WEEK_5;

-- SQL ステートメントでの変数の使用（バインド）
-- https://docs.snowflake.com/ja/developer-guide/snowflake-scripting/variables#using-a-variable-in-a-sql-statement-binding
BEGIN 
    FOR i IN 1 TO 10 DO
        INSERT INTO FF_week_5 
        VALUES (:i);
    END FOR;
END;

-- sqlでudfを作成
CREATE OR REPLACE FUNCTION timesthree(i INT)
RETURNS INT
AS
$$
  i * 3
$$;

SELECT timesthree(start_int)
FROM FF_week_5;