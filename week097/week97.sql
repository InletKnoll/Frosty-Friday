
-- 社内離職率分析
-- 過去と現在の従業員データを比較し、どのマネージャーが高い離職率を出しているかを調査しました。
-- ・2024-01-01：正常な時期（コントロールデータ）
-- ・2024-10-10：検証対象（離職の有無を調べる）

USE ROLE SYSADMIN;

-- 週番号を変数として設定
SET WEEK_NUMBER =97;

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
CREATE OR REPLACE TABLE employees (
    employee_id INT AUTOINCREMENT,
    level VARCHAR(2) DEFAULT 'L1',
    manager_id INT,
    base_salary INT,
    time_with_company INT,
    measurement_date DATE
);

-- employees テーブルに対して、擬似データ（1000行）を一括で挿入
-- CTE（Common Table Expression）とは、一時的な名前付きの結果セットです。
-- 通常は、複雑なクエリを分かりやすく整理するために使われます。
-- SQL構文の一部として、WITH キーワードで始まり、そのあとに名前（エイリアス）を付けたサブクエリを定義します。
-- これにより、CTEは一時的な仮想テーブルのように動作します。
-- WITH cte_name AS (
--     -- 何らかのSELECTクエリ
-- )
-- SELECT * FROM cte_name;
INSERT INTO employees (manager_id, base_salary,time_with_company, measurement_date)
WITH emp_data_control AS (
    SELECT
        UNIFORM(1, 20, RANDOM()) AS manager_id,
        CASE
            WHEN RANDOM() < 0.3 THEN UNIFORM(3500, 4499, RANDOM())
            ELSE UNIFORM(4500, 5500, RANDOM())
        END AS base_salary,
        UNIFORM(6, 20, RANDOM()) AS time_with_company,
        DATE_FROM_PARTS(2024, 1, 1) AS measurement_date
    FROM 
        TABLE(GENERATOR(ROWCOUNT => 1000))
)
SELECT * FROM emp_data_control;

-- -- manager_id = 10 のみ impact = 'high_negative' とラベル付け
-- manager_id = 10 に短期勤務の従業員を集中させる

-- JOIN managers ON true により、全マネージャーに一様に従業員を割り当て
-- 	•	クロス結合的に各行にマネージャーを振り分ける（結果的に20人のマネージャー × 多数の従業員）
-- 関数 SEQ4() は、連番（0, 1, 2, …, n）を生成
INSERT INTO employees (manager_id, base_salary,time_with_company, measurement_date)
WITH managers AS (
    SELECT
        manager_id,
        CASE
            WHEN manager_id = 10 THEN 'high_negative'
            ELSE 'high_positive'
        END AS impact
    FROM (
        SELECT SEQ4() AS manager_id
        FROM TABLE(GENERATOR(ROWCOUNT => 20))
    )
),
emp_data AS (
    SELECT
        m.manager_id AS manager_id,
        CASE
            WHEN RANDOM() < 0.3 THEN UNIFORM(4000, 4999, RANDOM()) 
            ELSE UNIFORM(5000, 6000, RANDOM()) 
        END AS base_salary, 
        CASE 
            WHEN m.impact = 'high_negative' THEN UNIFORM(1, 5, RANDOM()) 
            ELSE UNIFORM(6, 20, RANDOM()) 
        END AS time_with_company, 
        DATE_FROM_PARTS(2024, 10, 10) AS measurement_date 
    FROM 
        TABLE(GENERATOR(ROWCOUNT => 1000))
    JOIN 
        managers AS m ON true
    ORDER BY RANDOM()
)
SELECT * FROM emp_data;


-- 数値列は連続ディメンションとして扱われ、文字列とブール値の列はカテゴリディメンションとして扱われます。数値列をカテゴリディメンジョンとして扱うには、文字列にキャストします。
CREATE OR REPLACE VIEW employees_view AS(
    SELECT
        -- TO_VARCHAR(manager_id) AS manager_id,
        '/' || TO_VARCHAR(manager_id) AS manager_id,
        time_with_company,
        -- measurement_date,
        measurement_date >= '2024-10-10' as label
    FROM employees
);


-- table employees_view;
desc view employees_view;

CREATE SNOWFLAKE.ML.TOP_INSIGHTS IF NOT EXISTS my_insights();

-- DROP SNOWFLAKE.ML.TOP_INSIGHTS my_insights;

-- LABEL_COLNAME: コントロールデータ (FALSE) とテストデータ (TRUE) を示すラベル
-- ・2024-01-01：正常な時期（コントロールデータ）
-- ・2024-10-10：検証対象（テストデータ）
-- METRIC_COLNAME: 含まれるディメンジョンによって影響を受けた注目値
-- 異常なインサイト ⇒ CONTRIBUTION が大きい傾向あり
CALL my_insights!get_drivers (
  INPUT_DATA => TABLE(employees_view),
  LABEL_COLNAME => 'label',
  METRIC_COLNAME => 'time_with_company');


SELECT TOP_INSIGHTS_OUTPUT.*
FROM (
    SELECT
        {
            'manager_id': "MANAGER_ID"
        } AS CATEGORICAL_DIMENSIONS,
        {
            -- 'base_salary': "BASE_SALARY"
        } AS CONTINUOUS_DIMENSIONS,
        "TIME_WITH_COMPANY" AS METRIC,
        "MEASUREMENT_DATE" >= '2024-10-10' AS LABEL
    FROM EMPLOYEES
) AS INPUTS,
TABLE(
    SNOWFLAKE.ML.TOP_INSIGHTS(
        INPUTS.CATEGORICAL_DIMENSIONS,
        INPUTS.CONTINUOUS_DIMENSIONS,
        CAST(INPUTS.METRIC AS FLOAT),
        INPUTS.LABEL
    )
    OVER (PARTITION BY 0)
) AS TOP_INSIGHTS_OUTPUT
WHERE NOT TOP_INSIGHTS_OUTPUT.MISSING_IN_TEST
ORDER BY TOP_INSIGHTS_OUTPUT.SURPRISE ASC;