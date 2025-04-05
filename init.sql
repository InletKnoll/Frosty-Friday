USE ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;

-- セカンダリロールを無効化
CREATE DATABASE CONFIG;
CREATE SCHEMA WORK;

CREATE OR REPLACE PROCEDURE update_default_secondary_roles_for_all()
RETURNS VARIANT NOT NULL
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
let updated_users = [];
let users = snowflake.execute({sqlText: "SHOW USERS"});
while (users.next()) {
    let username = users.getColumnValue("name");
    let dsr = users.getColumnValue("default_secondary_roles");

    // SNOWFLAKEユーザーの場合はスキップ
    if (username === 'SNOWFLAKE') {
        continue;
    }

    // default_secondary_rolesが["ALL"]の場合のみ処理を実行
    if (dsr === '["ALL"]') {
        snowflake.execute({
            sqlText: "alter user identifier(?) set default_secondary_roles=()",
            binds: ["\"" + username + "\""],
        });
        updated_users.push(username);
    }
}
return updated_users;
$$;

USE ROLE ACCOUNTADMIN; 
CALL update_default_secondary_roles_for_all();

-- check
show users;
SELECT "name", "default_secondary_roles"
FROM TABLE(result_scan(last_query_id()));
