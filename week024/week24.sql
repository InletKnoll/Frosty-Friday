USE ROLE SYSADMIN;

-- 週番号を変数として設定
SET WEEK_NUMBER = 24;

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


-- アプリ一覧を表示
SHOW STREAMLITS;

-- アプリの詳細を表示
DESC STREAMLIT DB_WEEK24.SCHEMA_WEEK24.ST24;

-- GUIから作成したアプリの名前を修正
-- ALTER STREAMLIT DB_WEEK24.SCHEMA_WEEK24.W31T0INCJSEVF190 RENAME TO DB_WEEK24.SCHEMA_WEEK24.ST24;


CREATE STAGE DB_WEEK24.SCHEMA_WEEK24.STREAMLIT_STAGE;

CREATE STREAMLIT DB_WEEK24.SCHEMA_WEEK24.ST24
ROOT_LOCATION = '@DB_WEEK24.SCHEMA_WEEK24.STREAMLIT_STAGE'
MAIN_FILE = '/main.py'
QUERY_WAREHOUSE = COMPUTE_WH;


CREATE OR REPLACE PROCEDURE DB_WEEK24.SCHEMA_WEEK24.SHOW_INFO(entity_type STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT 
EXECUTE AS CALLER
AS
$$
//引数名は、ストアドプロシージャコードの SQL 部分では大文字と小文字を区別しませんが、JavaScript部分では大文字と小文字を区別します。
//https://docs.snowflake.com/ja/developer-guide/stored-procedure/stored-procedures-javascript#case-sensitivity-in-javascript-arguments
  var sqlText = "SHOW " + ENTITY_TYPE;  // 引数を直接SHOWコマンドに組み込む
  
  try {
      // SQLステートメントを作成
      var stmt = snowflake.createStatement({sqlText: sqlText});
  
      // SQLを実行
      var resultSet = stmt.execute();

      // 結果を返す
      return stmt.getQueryId();

  } catch (err) {
      // エラーがあればエラーメッセージを返す
      return "Error executing SHOW command: " + err.message;
  }
$$
;


CALL DB_WEEK24.SCHEMA_WEEK24.SHOW_INFO('USERS');

SELECT * FROM TABLE(RESULT_SCAN('01bbf903-0002-5154-0002-3fe60001020a'));

