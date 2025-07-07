-- https://frostyfriday.org/blog/2024/03/29/week-87-basic/
-- https://docs.snowflake.com/ja/sql-reference/functions/translate-snowflake-cortex

USE ROLE SYSADMIN;

-- 週番号を変数として設定
SET WEEK_NUMBER =87;

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

-- startup
CREATE OR REPLACE TABLE WEEK_87 AS
SELECT 
  'Happy Easter' AS greeting,
  ARRAY_CONSTRUCT('DE', 'FR', 'IT', 'ES', 'PL', 'RO', 'JA', 'KO', 'PT') AS language_codes
;

table week_87;

-- FLATTENは、配列（ARRAY）やオブジェクト（OBJECT）の中身を1行ずつ展開するための関数です。
-- Snowflakeは通常、1つのセルの中にARRAY型やOBJECT型のデータを保持できますが、そのままだと中の要素を扱いづらいので、FLATTENを使って行に分解します。

-- 各言語コードに対して 'Happy Easter' を翻訳したい
select
  f.value as language_code,
  snowflake.cortex.translate(greeting, 'en', f.value) as translated_greeting
from
  week_87,
  lateral flatten(input => language_codes) f;