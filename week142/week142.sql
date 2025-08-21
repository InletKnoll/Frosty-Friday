-- Use Snowflake Cortex to translate and summarize international customer reviews in various languages. 
-- Analyze a single combined dataset (customer_feedback_combined) containing reviews in English, Spanish, French, German, and Japanese.
USE ROLE SYSADMIN;

USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET
    WEEK_NUMBER = 142;

-- 動的にデータベースとスキーマを作成
SET
    DB_NAME = 'DB_WEEK' || $WEEK_NUMBER;

SET
    SCHEMA_NAME = $DB_NAME || '.SCHEMA_WEEK' || $WEEK_NUMBER;

BEGIN
-- データベース作成
EXECUTE IMMEDIATE 'CREATE DATABASE ' || $DB_NAME;

-- スキーマ作成
EXECUTE IMMEDIATE 'CREATE SCHEMA ' || $SCHEMA_NAME;

-- スキーマをUSE
EXECUTE IMMEDIATE 'USE SCHEMA ' || $SCHEMA_NAME;

END;

-- setup code
CREATE OR REPLACE TABLE customer_feedback (review_id INT, review_text STRING);

INSERT INTO
    customer_feedback (review_id, review_text)
VALUES
    (
        1,
        'It was okay, but could be better. Excellent customer support throughout the process. It was okay, but could be better. Excellent customer support throughout the process. It was okay, but could be better. Excellent customer support throughout the process. It was okay, but could be better. Excellent customer support throughout the process. It was okay, but could be better. Excellent customer support throughout the process.'
    );

INSERT INTO
    customer_feedback (review_id, review_text)
VALUES
    (
        1,
        'Estuvo bien, pero podría mejorar. No estoy satisfecho con la calidad del artículo. Estuvo bien, pero podría mejorar. No estoy satisfecho con la calidad del artículo. Estuvo bien, pero podría mejorar. No estoy satisfecho con la calidad del artículo. Estuvo bien, pero podría mejorar. No estoy satisfecho con la calidad del artículo. Estuvo bien, pero podría mejorar. No estoy satisfecho con la calidad del artículo.'
    );

INSERT INTO
    customer_feedback (review_id, review_text)
VALUES
    (
        1,
        'Je recommanderais certainement ce produit. La livraison était rapide et le service excellent. Je recommanderais certainement ce produit. La livraison était rapide et le service excellent. Je recommanderais certainement ce produit. La livraison était rapide et le service excellent. Je recommanderais certainement ce produit. La livraison était rapide et le service excellent. Je recommanderais certainement ce produit. La livraison était rapide et le service excellent.'
    );

INSERT INTO
    customer_feedback (review_id, review_text)
VALUES
    (
        1,
        'Ich würde dieses Produkt auf jeden Fall empfehlen. Es war okay, aber es könnte besser sein. Ich würde dieses Produkt auf jeden Fall empfehlen. Es war okay, aber es könnte besser sein. Ich würde dieses Produkt auf jeden Fall empfehlen. Es war okay, aber es könnte besser sein. Ich würde dieses Produkt auf jeden Fall empfehlen. Es war okay, aber es könnte besser sein. Ich würde dieses Produkt auf jeden Fall empfehlen. Es war okay, aber es könnte besser sein.'
    );

INSERT INTO
    customer_feedback (review_id, review_text)
VALUES
    (
        1,
        '全体的に優れたカスタマーサポートでした。 この製品は間違いなくおすすめです。 全体的に優れたカスタマーサポートでした。 この製品は間違いなくおすすめです。 全体的に優れたカスタマーサポートでした。 この製品は間違いなくおすすめです。 全体的に優れたカスタマーサポートでした。 この製品は間違いなくおすすめです。 全体的に優れたカスタマーサポートでした。 この製品は間違いなくおすすめです。'
    );

TABLE customer_feedback;

-- １件毎に要約する
SELECT
    SNOWFLAKE.CORTEX.TRANSLATE (review_text, '', 'en') AS en,
    SNOWFLAKE.CORTEX.SUMMARIZE (en) AS summary,
    SNOWFLAKE.CORTEX.TRANSLATE (summary, '', 'ja') AS ja,
    SNOWFLAKE.CORTEX.SENTIMENT (summary) AS sentiment_score
FROM
    customer_feedback;

-- 全件を結合して要約する
WITH
    translated AS (
        SELECT
            SNOWFLAKE.CORTEX.TRANSLATE (review_text, '', 'en') AS en
        FROM
            customer_feedback
    ),
    combined AS (
        SELECT
            listagg(en, '') AS all_reviews
        FROM
            translated
    )
SELECT
    SNOWFLAKE.CORTEX.SUMMARIZE (all_reviews) AS summary,
    SNOWFLAKE.CORTEX.TRANSLATE (summary, '', 'ja') AS ja,
    SNOWFLAKE.CORTEX.SENTIMENT (summary) AS sentiment_score
FROM
    combined;

-- 第二引数を空にすると、ソース言語は自動的に検出される
-- CREATE TABLE customer_feedback_combined AS (
--     SELECT
--         SNOWFLAKE.CORTEX.TRANSLATE (review_text, '', 'en') AS en,
--         SNOWFLAKE.CORTEX.SUMMARIZE (en) AS summary,
--         SNOWFLAKE.CORTEX.TRANSLATE (summary, '', 'ja') AS ja
--     FROM
--         customer_feedback
-- );
-- TABLE customer_feedback_combined;