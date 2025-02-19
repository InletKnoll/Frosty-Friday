USE ROLE SYSADMIN;

CREATE DATABASE DB_WEEK2;
CREATE SCHEMA DB_WEEK2.SCHEMA_WEEK2;

USE SCHEMA DB_WEEK2.SCHEMA_WEEK2;

--ロードするデータに対応したフォーマットを作成する
CREATE FILE FORMAT PARQUET_FORMAT
    TYPE = PARQUET;

--ファイルフォーマットを指定しない場合、このあとのステージに対してのSELECTがエラーになる
CREATE OR REPLACE STAGE INTERNAL_STAGE
    FILE_FORMAT = PARQUET_FORMAT;

-- SNOWSIGHTからファイルを内部ステージにアップロード
DESC STAGE INTERNAL_STAGE;

--ファイルが格納されていることを確認
LIST @INTERNAL_STAGE;

--$1はParquetデータが格納されている単一列を指す
--取り出す列の名前は大文字・小文字を正しく指定する必要あり
SELECT $1:city FROM @DB_WEEK2.SCHEMA_WEEK2.internal_stage/employees.parquet;

SELECT * FROM @DB_WEEK2.SCHEMA_WEEK2.internal_stage/employees.parquet;


--PARQUETのデータ構造を確認する
SELECT* FROM TABLE(INFER_SCHEMA(
            LOCATION=>'@INTERNAL_STAGE/employees.parquet',
            FILE_FORMAT=>'PARQUET_FORMAT'
));

--Create table using infer_schema
--CREATE TABLE ... USING TEMPLATE （ステージングされたファイルのセットから派生した列定義を持つテーブルを作成）
-- https://docs.snowflake.com/ja/sql-reference/sql/create-table#create-table-using-template
	-- 1.	INFER_SCHEMA で Parquet のスキーマを取得。
	-- 2.	取得したスキーマを OBJECT_CONSTRUCT(*) で JSON オブジェクト化。
	-- 3.	ARRAY_AGG(...) でオブジェクトのリストに変換。
	-- 4.	USING TEMPLATE(...) で、そのスキーマを元に EMPLOYEES テーブルを作成。
CREATE OR REPLACE TABLE EMPLOYEES USING TEMPLATE(
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION=>'@INTERNAL_STAGE/employees.parquet',
            FILE_FORMAT=>'PARQUET_FORMAT'
        )
    )
);

-- テーブル構造を確認
DESC TABLE EMPLOYEES;

-- MATCH_BY_COLUMN_NAMEを指定することで、テーブル名とデータの列名が同じであればロード可能。SENSITIVEにすると大文字小文字を区別する
COPY INTO EMPLOYEES FROM @INTERNAL_STAGE/employees.parquet MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE';

SELECT * FROM EMPLOYEES;

-- 特定列のみ変更をキャプチャをしたい場合はVIEWを経由すれば良い。
-- employee_idはキャプチャ対象ではないが、これを入れていないと後でSTREAMを見てもどのレコードが変更されたかわからないので含める
-- 元となるテーブルで列名が小文字になっているので、ダブルクォートで囲う必要あり
CREATE VIEW EMPLOYEES_VIEW 
AS SELECT "employee_id", "dept", "job_title" FROM EMPLOYEES;


-- VIEWに対してストリームを作成する
CREATE STREAM EMPLOYESS_CHANGE ON VIEW EMPLOYEES_VIEW;

-- データの更新
UPDATE EMPLOYEES SET "country" = 'Japan' WHERE "employee_id" = 8;
UPDATE EMPLOYEES SET "last_name" = 'Forester' WHERE "employee_id" = 22;
UPDATE EMPLOYEES SET "dept" = 'Marketing' WHERE "employee_id" = 25;
UPDATE EMPLOYEES SET "title" = 'Ms' WHERE "employee_id" = 32;
UPDATE EMPLOYEES SET "job_title" = 'Senior Financial Analyst' WHERE "employee_id" = 68;

-- ストリームを確認する
SELECT * FROM EMPLOYESS_CHANGE;