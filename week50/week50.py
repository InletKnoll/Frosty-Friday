# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col

def method_python(session): 
    tableName = 'DB_WEEK50.SCHEMA_WEEK50.F_F_50'
    dataframe = session.table(tableName).filter(col("last_name") == 'Deery')
    return dataframe

def method_sql(session): 
    dataframe = session.sql("SELECT * FROM DB_WEEK50.SCHEMA_WEEK50.F_F_50 WHERE LAST_NAME = 'Deery'")
    return dataframe

def main(session: snowpark.Session): 

    # dataframe = method_python(session)
    dataframe = method_sql(session)

    dataframe.show()

    return dataframe