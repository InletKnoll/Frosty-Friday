USE ROLE SYSADMIN;

-- 週番号を変数として設定
SET WEEK_NUMBER = 8;

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

CREATE OR REPLACE TABLE payment(id int, payment_date date, card_type varchar,amount_spent number(11, 2));

-- 一時的に使用するステージを作成
CREATE STAGE TEMP;

-- snowsightからcsvをアップロード

-- 一行目はスキップする
COPY INTO payment from @TEMP/payments.csv FILE_FORMAT = (SKIP_HEADER = 1);

-- select * from payment;