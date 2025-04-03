USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- 週番号を変数として設定
SET WEEK_NUMBER = 50;

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
create table F_F_50 (
	id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(50)
);
insert into F_F_50 (id, first_name, last_name, email) values (1, 'Arly', 'Lissaman', 'alissaman0@auda.org.au');
insert into F_F_50 (id, first_name, last_name, email) values (2, 'Cary', 'Baggalley', 'cbaggalley1@aol.com');
insert into F_F_50 (id, first_name, last_name, email) values (3, 'Kimbell', 'Bertrand', 'kbertrand2@twitpic.com');
insert into F_F_50 (id, first_name, last_name, email) values (4, 'Peria', 'Deery', 'pdeery3@addtoany.com');
insert into F_F_50 (id, first_name, last_name, email) values (5, 'Edmund', 'Caselli', 'ecaselli4@prweb.com');
insert into F_F_50 (id, first_name, last_name, email) values (6, 'Davin', 'Daysh', 'ddaysh5@liveinternet.ru');
insert into F_F_50 (id, first_name, last_name, email) values (7, 'Starla', 'Legging', 'slegging6@soundcloud.com');
insert into F_F_50 (id, first_name, last_name, email) values (8, 'Maud', 'Jaggers', 'mjaggers7@businesswire.com');
insert into F_F_50 (id, first_name, last_name, email) values (9, 'Barn', 'Campsall', 'bcampsall8@is.gd');
insert into F_F_50 (id, first_name, last_name, email) values (10, 'Marcelia', 'Yearn', 'myearn9@moonfruit.com');


select * from F_F_50;