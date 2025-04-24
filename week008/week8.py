# StreamlitとSnowparkライブラリのインポート
import streamlit as st
from snowflake.snowpark.context import get_active_session

# アプリのタイトル表示
st.title("Payments in 2021")

# Snowparkセッションの取得（Streamlit環境にアタッチされているセッション）
session = get_active_session()

# 支払データを週ごとに集計するSQLクエリ
sql = """SELECT
  DATE_TRUNC('WEEK', PAYMENT_DATE) AS WEEK_START_DATE,
  SUM(AMOUNT_SPENT) AS TOTAL_AMOUNT_SPENT
FROM DB_WEEK8.SCHEMA_WEEK8.PAYMENT
GROUP BY WEEK_START_DATE
ORDER BY WEEK_START_DATE;"""

# Pandas DataFrameに変換するためにクエリ実行
df_pd = session.sql(sql).to_pandas()

# 最小・最大値をデータから取得
min_date = df_pd["WEEK_START_DATE"].min()
max_date = df_pd["WEEK_START_DATE"].max()

# 開始日（最小日）を選択するスライダー
min_date_slider = st.slider(
  "Select min date",
  min_value=min_date,
  max_value=max_date,
  value=min_date,  # デフォルトで最小値
)

# 終了日（最大日）を選択するスライダー
max_date_slider = st.slider(
  "Select max date",
  min_value=min_date,
  max_value=max_date,
  value=max_date,  # デフォルトで最大値
)

# 開始日以降かどうかの条件
is_after_min_date = df_pd["WEEK_START_DATE"] >= min_date_slider

# 終了日以前かどうかの条件
is_before_max_date = df_pd["WEEK_START_DATE"] <= max_date_slider

# 条件を満たすデータのみを対象に折れ線グラフを表示
st.line_chart(df_pd[is_after_min_date & is_before_max_date], x='WEEK_START_DATE', y='TOTAL_AMOUNT_SPENT')