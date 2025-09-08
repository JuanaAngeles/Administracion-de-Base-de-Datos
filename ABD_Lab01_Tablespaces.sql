-- 1) Tablespace de datos
create tablespace data_cyclis
datafile 'C:\Oracle\XE21c\oradata\XE\data_cyclis01.dbf' size 500m
    autoextend on next 100m maxsize 20g
extent management local
segment space management manual
logging;

-- 2) Tablespace temporal
create temporary tablespace temp_cyclis
tempfile 'C:\Oracle\XE21c\oradata\XE\temp_cyclis01.dbf' size 200m
autoextend on next 50m maxsize 5g
extent management local
uniform size 1m;

-- crear usuario para la aplicación
create user app_ciclismo identified by AppCicl1
  default tablespace data_cyclis
  temporary tablespace temp_cyclis
  quota unlimited on data_cyclis;

grant create session, create table, create view, create procedure,
      create sequence, create trigger to app_ciclismo;