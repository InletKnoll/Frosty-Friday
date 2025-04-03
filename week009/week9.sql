-- https://docs.snowflake.com/ja/user-guide/tag-based-masking-policies

USE ROLE SYSADMIN;

-- 週番号を変数として設定
SET WEEK_NUMBER = 9;

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
--CREATE DATA
CREATE OR REPLACE TABLE data_to_be_masked(first_name varchar, last_name varchar,hero_name varchar);
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Eveleen', 'Danzelman','The Quiet Antman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Harlie', 'Filipowicz','The Yellow Vulture');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Mozes', 'McWhin','The Broken Shaman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Horatio', 'Hamshere','The Quiet Charmer');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Julianna', 'Pellington','Professor Ancient Spectacle');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Grenville', 'Southouse','Fire Wonder');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Analise', 'Beards','Purple Fighter');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Darnell', 'Bims','Mister Majestic Mothman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Micky', 'Shillan','Switcher');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Ware', 'Ledstone','Optimo');

--CREATE ROLE

USE ROLE SECURITYADMIN;

CREATE ROLE foo1;
CREATE ROLE foo2;
GRANT ROLE foo1 TO USER hiroki;
GRANT ROLE foo2 TO USER hiroki;

GRANT USAGE ON DATABASE DB_WEEK9 TO ROLE foo1;
GRANT USAGE ON DATABASE DB_WEEK9 TO ROLE foo2;

GRANT USAGE ON SCHEMA DB_WEEK9.SCHEMA_WEEK9 TO ROLE foo1;
GRANT USAGE ON SCHEMA DB_WEEK9.SCHEMA_WEEK9 TO ROLE foo2;
GRANT SELECT ON TABLE DB_WEEK9.SCHEMA_WEEK9.DATA_TO_BE_MASKED TO ROLE foo1;
GRANT SELECT ON TABLE DB_WEEK9.SCHEMA_WEEK9.DATA_TO_BE_MASKED TO ROLE foo2;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE foo1;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE foo2;

-- タグを作成
USE ROLE SYSADMIN;
CREATE OR REPLACE TAG level_tag allowed_values 'high', 'low';

-- テーブルにタグを設定
ALTER TABLE data_to_be_masked modify column
  first_name set tag level_tag = 'low',
  last_name set tag level_tag = 'high'
;

-- 大文字で指定する
CREATE OR REPLACE MASKING POLICY level_tag_mask AS (val string) returns string ->
  CASE
    WHEN system$get_tag_on_current_column('level_tag') = 'low' and (is_role_in_session('FOO1') or is_role_in_session('FOO2')) THEN VAL
    WHEN system$get_tag_on_current_column('level_tag') = 'high' and (is_role_in_session('FOO2')) THEN VAL
    ELSE repeat('*', 6)
  END;

-- タグに対するマスキングポリシーの割り当ておよび置き換えには、APPLY MASKING POLICY グローバル権限が必要です。
USE ROLE ACCOUNTADMIN;
alter tag level_tag set masking policy level_tag_mask;

-- ALTER TABLE IF EXISTS data_to_be_masked MODIFY COLUMN first_name SET MASKING POLICY first_name_mask;
-- ALTER TABLE IF EXISTS data_to_be_masked MODIFY COLUMN last_name SET MASKING POLICY last_name_mask;
-- ALTER TABLE IF EXISTS data_to_be_masked MODIFY COLUMN first_name UNSET MASKING POLICY;
-- ALTER TABLE IF EXISTS data_to_be_masked MODIFY COLUMN last_name UNSET MASKING POLICY;

-- check
USE ROLE ACCOUNTADMIN;
SELECT * FROM data_to_be_masked;

-- check
USE ROLE foo1;
SELECT * FROM data_to_be_masked;

-- check
USE ROLE foo2;
SELECT * FROM data_to_be_masked;