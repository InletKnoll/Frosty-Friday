import streamlit as st
import snowflake.snowpark as snowpark
from snowflake.snowpark import Session
from dotenv import load_dotenv
import os

# .envファイルを読み込んで環境変数を設定
load_dotenv()

# 環境変数からSnowflake接続情報を取得
connection_parameters = {
    "account": os.getenv("SNOWFLAKE_ACCOUNT"),
    "user": os.getenv("SNOWFLAKE_USER"),
    "password": os.getenv("SNOWFLAKE_PASSWORD"),
    "role": os.getenv("SNOWFLAKE_ROLE"),
}

# 全体のレイアウトを左寄せにする
st.markdown("""
    <style>
        #root .block-container {
            margin-left: 0 !important;
            padding-left: 1.5rem !important;
            padding-right: 1.5rem !important;
            max-width: 100% !important;
        }
    </style>
""", unsafe_allow_html=True)

# セッション作成処理をキャッシュ（ページ再読み込み時の再接続を防ぐ）
@st.cache_resource
def create_session():
    return Session.builder.configs(connection_parameters).create()

session = create_session()

# アプリのタイトルと説明文
st.title("Snowflake Account Info App")
st.write(
  "Use this app to quickly see high-level info about your Snowflake account."
)

# サイドバー設定
with st.sidebar:
    # トリプルクォートを使うことで、ダブルクオーテーションが文内に含まれていてもエスケープすることなく利用可能
    # Frosty Friday のロゴを中央に表示
    st.markdown("""
    <img src="https://frostyfriday.org/wp-content/uploads/2022/11/ff_logo_trans.png" height="200" width="250" style="display: block; margin-left: auto; margin-right: auto;">
    """, unsafe_allow_html=True)
    
    # 表示する情報の選択肢
    options = [
        "None",
        "Shares",
        "Roles",
        "Grants",
        "Users",
        "Warehouses",
        "Databases",
        "Schemas",
        "Tables",
        "Views",
    ]

    # ドロップダウンで選択
    selectbox = st.selectbox(
        "Select what account info you would like to see",
        options
    )

    # Snowparkバージョンをサイドバー下部に表示
    st.sidebar.markdown(
        f"<p style='position: fixed; bottom: 0; width: 16rem; text-align: center; font-size: small;'>App created using Snowpark version {snowpark.__version__}</p>",
        unsafe_allow_html=True
    )

# データ表示部分
if selectbox != 'None':
    if selectbox == 'Grants':
        query = f"SHOW {selectbox} ON ACCOUNT"
    else:
        query = f"SHOW {selectbox} IN ACCOUNT"
    #  use_container_width=TrueはStreamlitで表やチャートを表示するときに、そのコンポーネントを画面の横幅にフィットさせるオプション
    #  デフォルトだと、st.dataframe は狭めに表示されてスクロールが必要だが、このオプションをつけると画面いっぱいに広がり見やすくなる
    st.dataframe(session.sql(query), use_container_width=True)
else:
    st.info("No data is shown because 'None' is selected. Please choose a category from the sidebar to view Snowflake account information.")
