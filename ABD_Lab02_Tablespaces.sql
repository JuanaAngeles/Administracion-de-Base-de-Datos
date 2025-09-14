
create tablespace data_employees
datafile 'C:\Oracle\XE21c\oradata\XE\data_employees01.dbf' size 500m
    autoextend on next 100m maxsize 20g
extent management local
segment space management manual
logging;

create temporary tablespace temp_employees
tempfile 'C:\Oracle\XE21c\oradata\XE\temp_employees01.dbf' size 200m
extent management local
uniform size 1m;

create user app_empleados identified by employees123
  default tablespace data_employees
  temporary tablespace temp_employees
  quota unlimited on data_employees;

grant create session, create table, create view, create procedure,

create sequence, create trigger to app_empleados;
