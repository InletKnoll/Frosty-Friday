USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET WEEK_NUMBER = 140;

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
-- Create invoice_line_items table
CREATE OR REPLACE TABLE invoice_line_items (
    line_item_id INTEGER,
    service_description STRING
);

-- Create service_categories table
CREATE OR REPLACE TABLE service_categories (
    category_id INTEGER,
    category_name STRING
);

-- Insert sample invoice line items
INSERT INTO invoice_line_items (line_item_id, service_description) VALUES
(1, 'Deployment of Snowflake project - Phase 1'),
(2, 'Data ingestion pipeline optimization'),
(3, 'Security and access review for Snowflake'),
(4, 'Ongoing data modeling support'),
(5, 'Snowflake training session for analysts');

-- Insert sample categories
INSERT INTO service_categories (category_id, category_name) VALUES
(1, 'Snowflake Deployment'),
(2, 'Data Engineering'),
(3, 'Security Review'),
(4, 'Training'),
(5, 'Analytics Support');

-- Classification
WITH category_list AS (
    SELECT ARRAY_AGG(category_name) AS categories
    FROM service_categories
)
SELECT
    i.line_item_id,
    i.service_description,
    c.categories,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        i.service_description,
        c.categories
    ) AS predicted_category
FROM
    invoice_line_items i
CROSS JOIN
    category_list c;