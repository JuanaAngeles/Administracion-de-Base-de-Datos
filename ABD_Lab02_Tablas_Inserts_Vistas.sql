--ACTIVIDAD 01
create table empleados (
    DNI number(8) primary key,
    NOMBRE varchar2(10) not null,
    APELLIDO1 varchar2(15) not null,
    APELLIDO2 varchar2(15),
    DIRECC1 varchar2(25),
    DIRECC2 varchar2(20),
    CIUDAD varchar2(20),
    PROVINCIA varchar2(20),
    COD_POSTAL varchar2(5),
    SEXO varchar2(1) check (SEXO in ('H', 'M')),
    FECHA_NAC date
) tablespace data_employees;

create table departamentos (
    DPTO_COD number(5) primary key,
    NOMBRE_DPTO varchar2(30) not null,
    DPTO_PADRE number(5),
    PRESUPUESTO number not null,
    PRES_ACTUAL number,
    constraint uq_departamentos_nombre unique (NOMBRE_DPTO),
    constraint fk_departamentos_padre foreign key (DPTO_PADRE) references departamentos(DPTO_COD)
) tablespace data_employees;

create table trabajos (
    TRABAJO_COD number(5) primary key,
    NOMBRE_TRAB varchar2(20) not null,
    SALARIO_MIN number(2) not null,
    SALARIO_MAX number(2) not null,
    constraint uq_trabajos_nombre unique (NOMBRE_TRAB)
) tablespace data_employees;

create table universidades (
    UNIV_COD number(5) primary key,
    NOMBRE_UNIV varchar2(25) not null,
    CIUDAD varchar2(20),
    MUNICIPIO varchar2(2),
    COD_POSTAL varchar2(5)
) tablespace data_employees;

create table historial_laboral (
    EMPLEADO_DNI number(8),
    TRABAJO_COD number(5),
    FECHA_INICIO date,
    FECHA_FIN date,
    DPTO_COD number(5),
    SUPERVISOR_DNI number(8),
    constraint pk_historial_laboral primary key (EMPLEADO_DNI, TRABAJO_COD, FECHA_INICIO),
    constraint fk_histlab_empleado foreign key (EMPLEADO_DNI) references empleados(DNI),
    constraint fk_histlab_trabajo foreign key (TRABAJO_COD) references trabajos(TRABAJO_COD),
    constraint fk_histlab_departamento foreign key (DPTO_COD) references departamentos(DPTO_COD),
    constraint fk_histlab_supervisor foreign key (SUPERVISOR_DNI) references empleados(DNI)
) tablespace data_employees;

create table historial_salarial (
    EMPLEADO_DNI number(8),
    SALARIO number not null,
    FECHA_COMIENZO date,
    FECHA_FIN date,
    constraint pk_historial_salarial primary key (EMPLEADO_DNI, FECHA_COMIENZO),
    constraint fk_histsal_empleado foreign key (EMPLEADO_DNI) references empleados(DNI)
) tablespace data_employees;

create table estudios (
    EMPLEADO_DNI number(8),
    UNIVERSIDAD number(5),
    AÑO number,
    GRADO varchar2(3),
    ESPECIALIDAD varchar2(20),
    constraint pk_estudios primary key (EMPLEADO_DNI, UNIVERSIDAD),
    constraint fk_estudios_empleado foreign key (EMPLEADO_DNI) references empleados(DNI),
    constraint fk_estudios_univ foreign key (UNIVERSIDAD) references universidades(UNIV_COD)
) tablespace data_employees;

select constraint_name
from user_constraints
where table_name = 'EMPLEADOS'
  and constraint_type = 'C';

select constraint_name, search_condition
from user_constraints
where table_name = 'EMPLEADOS'
  and constraint_type = 'C';

alter table empleados drop constraint check_empleados_sexo;

alter table empleados
    add check (SEXO in ('H','M'));

--ACTIVIDAD 04         
create or replace trigger trg_histsal_no_solape
before insert or update on historial_salarial
for each row
declare
    v_count integer;
begin
    select count(*) into v_count
    from historial_salarial
    where EMPLEADO_DNI = :new.EMPLEADO_DNI
      and (:new.FECHA_FIN is null or FECHA_COMIENZO <= :new.FECHA_FIN)
      and (FECHA_FIN is null or :new.FECHA_COMIENZO <= FECHA_FIN)
      and not (EMPLEADO_DNI = :new.EMPLEADO_DNI and FECHA_COMIENZO = :new.FECHA_COMIENZO);

    if v_count > 0 then
        raise_application_error(-20001, 'Ya existe un salario vigente en ese periodo.');
    end if;
end;
/

create or replace trigger trg_histlab_no_solape
before insert or update on historial_laboral
for each row
declare
    v_count integer;
begin
    select count(*) into v_count
    from historial_laboral
    where EMPLEADO_DNI = :new.EMPLEADO_DNI
      and (:new.FECHA_FIN is null or FECHA_INICIO <= :new.FECHA_FIN)
      and (FECHA_FIN is null or :new.FECHA_INICIO <= FECHA_FIN)
      and not (EMPLEADO_DNI = :new.EMPLEADO_DNI and TRABAJO_COD = :new.TRABAJO_COD and FECHA_INICIO = :new.FECHA_INICIO);

    if v_count > 0 then
        raise_application_error(-20002, 'Ya existe un trabajo vigente en ese periodo.');
    end if;
end;
/

select trigger_name, table_name, status
from user_triggers;

--ACTIVIDAD 06
alter table empleados
    add (TELEFONO varchar2(12),
         CELULAR varchar2(12));
         
alter table trabajos modify (SALARIO_MIN number);
alter table trabajos modify (SALARIO_MAX number);
alter table universidades modify (MUNICIPIO varchar2(20));

--ACTIVIDAD 07
--1) DEPARTAMENTOS
insert into departamentos (DPTO_COD, NOMBRE_DPTO, DPTO_PADRE, PRESUPUESTO, PRES_ACTUAL) values (10, 'Administracion', null, 50000, 30000);
insert into departamentos (DPTO_COD, NOMBRE_DPTO, DPTO_PADRE, PRESUPUESTO, PRES_ACTUAL) values (20, 'Contabilidad', null, 40000, 20000);
insert into departamentos (DPTO_COD, NOMBRE_DPTO, DPTO_PADRE, PRESUPUESTO, PRES_ACTUAL) values (30, 'Recursos Humanos', null, 30000, 15000);
insert into departamentos (DPTO_COD, NOMBRE_DPTO, DPTO_PADRE, PRESUPUESTO, PRES_ACTUAL) values (40, 'Tecnologia', null, 80000, 60000);

-- 2) TRABAJOS
insert into trabajos (TRABAJO_COD, NOMBRE_TRAB, SALARIO_MIN, SALARIO_MAX) values (100, 'Analista', 1000, 5000);
insert into trabajos (TRABAJO_COD, NOMBRE_TRAB, SALARIO_MIN, SALARIO_MAX) values (200, 'Cajero', 900, 2500);
insert into trabajos (TRABAJO_COD, NOMBRE_TRAB, SALARIO_MIN, SALARIO_MAX) values (300, 'Gerente', 5000, 12000);
insert into trabajos (TRABAJO_COD, NOMBRE_TRAB, SALARIO_MIN, SALARIO_MAX) values (400, 'Programador', 1200, 6000);

-- 3) UNIVERSIDADES 
insert into universidades (UNIV_COD, NOMBRE_UNIV, CIUDAD, MUNICIPIO, COD_POSTAL) values (1, 'UNMSM', 'Lima', 'Lima', '15001');
insert into universidades (UNIV_COD, NOMBRE_UNIV, CIUDAD, MUNICIPIO, COD_POSTAL) values (2, 'PUCP', 'Lima', 'San Miguel', '15086');
insert into universidades (UNIV_COD, NOMBRE_UNIV, CIUDAD, MUNICIPIO, COD_POSTAL) values (3, 'UNSA', 'Arequipa', 'Arequipa', '04001');
insert into universidades (UNIV_COD, NOMBRE_UNIV, CIUDAD, MUNICIPIO, COD_POSTAL) values (4, 'UNSAAC', 'Cusco', 'Cusco', '08001');

-- 4) EMPLEADOS 
insert into empleados (DNI, NOMBRE, APELLIDO1, APELLIDO2, DIRECC1, DIRECC2, CIUDAD, PROVINCIA, COD_POSTAL, SEXO, FECHA_NAC, TELEFONO, CELULAR) values (111222, 'Sergio', 'Palma', 'Entrena', null, null, null, null, null, 'H', null, null, null);
insert into empleados (DNI, NOMBRE, APELLIDO1, APELLIDO2, DIRECC1, DIRECC2, CIUDAD, PROVINCIA, COD_POSTAL, SEXO, FECHA_NAC, TELEFONO, CELULAR) values (222333, 'Lucia', 'Ortega', 'Plus', null, null, null, null, null, 'M', null, null, null);
insert into empleados (DNI, NOMBRE, APELLIDO1, APELLIDO2, DIRECC1, DIRECC2, CIUDAD, PROVINCIA, COD_POSTAL, SEXO, FECHA_NAC, TELEFONO, CELULAR) values (333444, 'Carlos', 'Fernandez', 'Lopez', 'Av. Ejercito 789', null, 'Arequipa', 'Arequipa', '04001', 'H', to_date('1963-02-10','yyyy-mm-dd'), '054765432', '986987654');
insert into empleados (DNI, NOMBRE, APELLIDO1, APELLIDO2, DIRECC1, DIRECC2, CIUDAD, PROVINCIA, COD_POSTAL, SEXO, FECHA_NAC, TELEFONO, CELULAR) values (444555, 'Marina', 'Seclen', 'Diaz', 'Av. Grau 321', null, 'Lima', 'Lima', '15002', 'M', to_date('1962-04-08','yyyy-mm-dd'), '014444555', '999888777');

-- 5) HISTORIAL LABORAL
insert into historial_laboral (EMPLEADO_DNI, TRABAJO_COD, FECHA_INICIO, FECHA_FIN, DPTO_COD, SUPERVISOR_DNI) values (111222, 100, to_date('1996-06-16','YYYY-MM-DD'), null, 10, null);
insert into historial_laboral (EMPLEADO_DNI, TRABAJO_COD, FECHA_INICIO, FECHA_FIN, DPTO_COD, SUPERVISOR_DNI) values (222333, 200, to_date('1998-03-01','YYYY-MM-DD'), null, 20, 111222);
insert into historial_laboral (EMPLEADO_DNI, TRABAJO_COD, FECHA_INICIO, FECHA_FIN, DPTO_COD, SUPERVISOR_DNI) values (333444, 300, to_date('1995-05-05','YYYY-MM-DD'), null, 30, null);
insert into historial_laboral (EMPLEADO_DNI, TRABAJO_COD, FECHA_INICIO, FECHA_FIN, DPTO_COD, SUPERVISOR_DNI) values (444555, 400, to_date('1999-07-04','YYYY-MM-DD'), null, 40, null);

-- 6) HISTORIAL SALARIAL
insert into historial_salarial (EMPLEADO_DNI, SALARIO, FECHA_COMIENZO, FECHA_FIN) values (111222, 2500, to_date('1996-06-16','YYYY-MM-DD'), null);
insert into historial_salarial (EMPLEADO_DNI, SALARIO, FECHA_COMIENZO, FECHA_FIN) values (222333, 2000, to_date('1998-03-01','YYYY-MM-DD'), null);
insert into historial_salarial (EMPLEADO_DNI, SALARIO, FECHA_COMIENZO, FECHA_FIN) values (333444, 6000, to_date('1995-05-05','YYYY-MM-DD'), null);
insert into historial_salarial (EMPLEADO_DNI, SALARIO, FECHA_COMIENZO, FECHA_FIN) values (444555, 4800, to_date('1999-07-04','YYYY-MM-DD'), null);

-- 7) ESTUDIOS
insert into estudios (EMPLEADO_DNI, UNIVERSIDAD, AÑO, GRADO, ESPECIALIDAD) values (111222, 1, 1995, 'LIC', 'Administracion');
insert into estudios (EMPLEADO_DNI, UNIVERSIDAD, AÑO, GRADO, ESPECIALIDAD) values (222333, 2, 1997, 'LIC', 'Administración');
insert into estudios (EMPLEADO_DNI, UNIVERSIDAD, AÑO, GRADO, ESPECIALIDAD) values (333444, 2, 1987, 'ING', 'Industrial');
insert into estudios (EMPLEADO_DNI, UNIVERSIDAD, AÑO, GRADO, ESPECIALIDAD) values (444555, 1, 1990, 'ING', 'Software');

-- Confirmar cambios
COMMIT;

-- Departamentos
SELECT * FROM departamentos;

-- Trabajos
SELECT * FROM trabajos;

-- Universidades
SELECT * FROM universidades;

-- Empleados
SELECT * FROM empleados;

-- Historial laboral
SELECT * FROM historial_laboral;

-- Historial salarial
SELECT * FROM historial_salarial;

-- Estudios
SELECT * FROM estudios;

--Visualizar cada detalle de la Tabla
DESCRIBE ESTUDIOS;
DESCRIBE EMPLEADOS;
DESCRIBE HISTORIAL_LABORAL;
DESCRIBE HISTORIAL_SALARIAL;

--ACTIVIDAD 08
update historial_laboral set supervisor_dni = 123456 
    where empleado_dni = 111222 and trabajo_cod = 100 and fecha_inicio = date '1996-06-16';

--ACTIVIDAD 09
delete from universidades where univ_cod = '1';
-- 1) (Opcional) ver el nombre actual de la constraint
select constraint_name from user_constraints
    where table_name = 'ESTUDIOS' and constraint_type = 'R';
-- 2) Borrar la constraint existente (fk_estudios_univ):
alter table ESTUDIOS drop constraint fk_estudios_univ;
-- 3) Crear la nueva FK con ON DELETE CASCADE:
alter table ESTUDIOS add constraint fk_estudios_univ foreign key (UNIVERSIDAD) references UNIVERSIDADES (UNIV_COD) on delete cascade;

--ACTIVIDAD 10
alter table empleados add constraint chk_ciudad_codpostal check (ciudad is null or cod_postal is not null);

--ACTIVIDAD 11
-- Agregar columna con valor por defecto
alter table empleados add (valoracion number(2) default 5);
-- Forzar rango entre 1 y 10
alter table empleados add constraint chk_valoracion_range check (valoracion between 1 and 10);
-- Forzar que la columna sea obligatoria
alter table empleados modify (valoracion not null);

--ACTIVIDAD 12
alter table empleados modify (nombre varchar2(20) null);

--ACTIVIDAD 13
alter table empleados modify (direcc1 varchar2(40));

--ACTIVIDAD 14
-- No se recomienda:
alter table empleados modify (fecha_nac varchar2(20));
-- Mejor usar TO_CHAR en consultas
select nombre, apellido1, to_char(fecha_nac, 'YYYY-MM-DD') as fecha_nac_texto
from empleados;


--ACTIVIDAD 15
-- 1: Eliminar las FOREIGN KEYS dependientes de EMPLEADOS
alter table historial_salarial drop constraint fk_histsal_empleado;
alter table historial_laboral drop constraint fk_histlab_empleado;
alter table historial_laboral drop constraint fk_histlab_supervisor;
alter table estudios drop constraint fk_estudios_empleado;
-- 2: Eliminar la PRIMARY KEY actual (DNI)
alter table empleados drop constraint SYS_C008267;
-- 3: Crear la nueva PRIMARY KEY compuesta
alter table empleados add constraint pk_empleados_nom_ape primary key (nombre, apellido1, apellido2);
-- Paso 4: Modificar las tablas dependientes para apuntar a la nueva PK
-- HISTORIAL_SALARIAL
alter table historial_salarial add (
    nombre varchar2(10), apellido1 varchar2(15), apellido2 varchar2(15));
alter table historial_salarial add constraint fk_histsal_emp foreign key (nombre, apellido1, apellido2)
    references empleados (nombre, apellido1, apellido2);
-- HISTORIAL_LABORAL
alter table historial_laboral add (
    nombre varchar2(10), apellido1 varchar2(15), apellido2 varchar2(15),
    nombre_sup varchar2(10), apellido1_sup varchar2(15), apellido2_sup varchar2(15));
alter table historial_laboral add constraint fk_histlab_emp foreign key (nombre, apellido1, apellido2)
    references empleados (nombre, apellido1, apellido2);
alter table historial_laboral add constraint fk_histlab_sup foreign key (nombre_sup, apellido1_sup, apellido2_sup)
    references empleados (nombre, apellido1, apellido2);
-- ESTUDIOS
alter table estudios add (
    nombre varchar2(10), apellido1 varchar2(15), apellido2 varchar2(15));
alter table estudios add constraint fk_estudios_emp foreign key (nombre, apellido1, apellido2)
    references empleados (nombre, apellido1, apellido2);

--ACTIVIDAD 16
create table informacion_universitaria (
    nombre_completo varchar2(50),
    universidad varchar2(25)
) tablespace data_employees;
-- Insertar datos combinando nombres y apellidos
insert into informacion_universitaria (nombre_completo, universidad)
select 
    e.nombre || ' ' || e.apellido1 || ' ' || e.apellido2 as nombre_completo,
    u.nombre_univ as universidad
from empleados e
join estudios s on e.dni = s.empleado_dni
join universidades u on s.universidad = u.univ_cod;

--ACTIVIDAD 17
create view nombre_empleados as
select nombre || ' ' || apellido1 || ' ' || apellido2 as nombre_completo
from empleados
where ciudad = 'Málaga';

select * from nombre_empleados;

--ACTIVIDAD 18
create view informacion_empleados as
select nombre || ' ' || apellido1 || ' ' || apellido2 as nombre_completo,
       floor(months_between(sysdate, fecha_nac)/12) as edad
from empleados;

select * from informacion_empleados;

--ACTIVIDAD 19
create view informacion_actual as
select ie.nombre_completo,
       ie.edad,
       hs.salario
from informacion_empleados ie
join historial_salarial hs
  on ie.nombre_completo = (select nombre || ' ' || apellido1 || ' ' || apellido2 from empleados e where e.dni = hs.empleado_dni)
where hs.fecha_fin is null;

select * from informacion_actual;

--ACTIVIDAD 20
-- Primero, eliminar tablas dependientes por FK
drop table estudios cascade constraints;
drop table historial_salarial cascade constraints;
drop table historial_laboral cascade constraints;
drop table empleados cascade constraints;
drop table trabajos cascade constraints;
drop table departamentos cascade constraints;
drop table universidades cascade constraints;
drop table informacion_universitaria cascade constraints;
