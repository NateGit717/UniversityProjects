SET GLOBAL event_scheduler = ON;

show databases; # This statement shows the list of databases
drop database if exists DBEx2; # This statement drops/deletes the database named DBEx2
create database DBEx2; # Create the database named DBEx2
show databases;
use DBEx2; -- Use the database DBEx2 we just created
show tables; # This statement shows the list of tables in the database DBEx2
show procedure status; # Shows the list of procedures
show function status; # Shows the list of functions
show triggers; # Shows the list of triggers
SHOW PROCEDURE STATUS WHERE db = 'dbex2'; /* Shows the list of procedures in the
database DBEx2 */
SHOW function STATUS WHERE db = 'dbex2'; /* Shows the list of functions in the database
DBEx2 */
SHOW triggers in dbex2; # Shows the list of triggers in the database DBEx2
drop table if exists Employees;
create table Employees(
LName varchar(12) NOT NULL,
BirthDay date NOT NULL,
IDN int NOT NULL PRIMARY KEY,
Salary Decimal(20,2) NULL DEFAULT 0 ,
Deduction decimal(20, 2) NULL DEFAULT 0 );
/* IDN is primary key, the display order may be default to increasing IDN order */
describe Employees;
select * from Employees;
insert into Employees values ('Peter', '1986-9-6', 1, 1000, 10), ('Mary', '1996-9-6', 12, 2000,
0), ('Tony', '1989-7-9', 22, 4000, 32),
('Mike', '1999-11-12', 17, 4000, 10), ('John', '1980-3-2', 93, null, null);
select * from Employees;

drop table if exists IRAs;
create table IRAs(
FK_IDN int NOT NULL, /* FK_IDN is the foreign key */
IRA_acct varchar(12),
Balance decimal(20, 2),
FOREIGN KEY (FK_IDN) REFERENCES Employees(IDN));
describe iras;
select * from iras;
insert into IRAs values(1, 'A1', 100), (22, 'A2', 200), (22, 'A3', 400), (93, 'A4', 500);
select * from iras;

drop table if exists AddressCity;
create table AddressCity(
FK_IDN int NOT NULL, /* FK_IDN is the foreign key */
CompanyCity varchar(22),
HomeCity varchar(22),
FOREIGN KEY (FK_IDN) REFERENCES Employees(IDN));
describe addresscity;
select * from addresscity;
insert into addresscity values (1, 'Saint Louis', 'Saint Louis'), (12, 'Saint Louis',
'Chesterfield'),(22, 'Chesterfield', 'Saint Louis'), (93, 'Chesterfield', 'Chesterfield'), (17, 'Fenton',
'Fenton');
select * from addresscity;

# ---------------------- Assignment 8 ----------------------

#A1a
drop trigger if exists UpcaseLName;
delimiter //
create trigger UpcaseLName
before update on Employees for each row
begin
set new.LName = Upper(old.LName);
end//
delimiter ;

SHOW triggers in dbex2;
select * from employees;
update Employees set salary = salary + 100 where salary < 2000;
select * from employees;








#A1b
create table EmployeesUpdateRecords(
LName varchar(12), BirthDay date,
IDN int, Salary Decimal(20,2), Deduction decimal(20, 2),
UpdateTime datetime );
select * from EmployeesUpdateRecords;

drop trigger if exists ReSetDeductionOnNewSalary;
delimiter //
create trigger ReSetDeductionOnNewSalary before update on Employees for each row
Begin
set new.deduction = new.salary * (0.01);
insert into EmployeesUpdateRecords
values (old.LName, old.BirthDay, old.IDN, old.Salary, old.Deduction, now() );
end//
delimiter ;
SHOW triggers in dbex2;

select * from employees;
update Employees set salary = salary + 100 where salary < 1500;
select * from employees;

select * from EmployeesUpdateRecords;
update Employees set salary = salary + 100 where salary < 3000;
select * from employees;
select * from EmployeesUpdateRecords;
update Employees set salary = salary + 100 where salary < 1000;
select * from employees;
select * from EmployeesUpdateRecords;

#A2
drop trigger if exists CheckSalaryOnEmployees;
delimiter //
create trigger CheckSalaryOnEmployees before update on Employees for each row
Begin
If (new.Salary>10000)
then SIGNAL SQLSTATE 'HY000'
set MESSAGE_TEXT = 'Salary too high beyond consideration! ';
end if;
end//
delimiter ;

SHOW triggers in dbex2;
update Employees set Salary = Salary + 9000 where Salary > 2000;
select * from employees;
select * from EmployeesUpdateRecords; 
select * from employees;
select * from EmployeesUpdateRecords;

#A3
create table EmployeesAudit(
LName varchar(12), BirthDay date,
IDN int, Salary Decimal(20,2), Deduction decimal(20, 2),
InsertTime datetime );
select * from EmployeesAudit;
select * from employees;

DROP TRIGGER IF EXISTS EmployeesAfterInsert;
delimiter //
create trigger EmployeesAfterInsert after insert on Employees for each row
Begin
insert into EmployeesAudit
values (new.LName, new.BirthDay, new.IDN, new.Salary, new.Deduction, now());
end//
delimiter ;

insert into Employees values ('Peter1','1986-9-6', 101,1000,10);
select * from Employees;
select * from EmployeesAudit;
insert into Employees values ('Peter2', '1986-9-6', 102, 1000, 10), ('Mary1', '1996-9-6', 112,
2000, 0), ('Tony1', '1989-7-9', 122, 6000, 32);
select * from Employees;
select * from EmployeesAudit;

#A4
create table EmployeesDeleteRecords(
LName varchar(12), BirthDay date,
IDN int, Salary Decimal(20,2), Deduction decimal(20, 2),
DeleteTime datetime );
select * from EmployeesDeleteRecords;
select * from Employees;

DROP TRIGGER IF EXISTS EmployeesAfterDelete;
delimiter //
create trigger EmployeesAfterDelete after delete on Employees for each row
Begin
insert into EmployeesDeleteRecords
values (old.LName, old.BirthDay, old.IDN, old.Salary, old.Deduction, now());
end//
delimiter ;

delete from Employees where IDN = 101;
select * from Employees;
select * from EmployeesDeleteRecords;
delete from Emplyees where IDN between 102 and 122;
select * from Employees;
select * from EmployeesDeleteRecords;
SHOW triggers in dbex2;

#B*
SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE 'event_scheduler';
select * from iras;

#B
DROP EVENT IF EXISTS UpdateIRAsNow;
DELIMITER //
CREATE EVENT UpdateIRAsNow
ON SCHEDULE
AT CURRENT_TIMESTAMP
DO
Begin
Update IRAs set Balance = Balance * (1.1);
End//
DELIMITER ;
select * from iras;

#Ba
drop table if exists MessageEvents;
create table MessageEvents ( IDN INT PRIMARY KEY auto_increment, Message VARCHAR(50), InsertedAt DATETIME);
select * from MessageEvents;

DROP EVENT IF EXISTS MessageEvent1;
DELIMITER //
CREATE EVENT MessageEvent1
ON SCHEDULE
AT CURRENT_TIMESTAMP
DO
Begin
INSERT INTO MessageEvents(Message, InsertedAt)
VALUES('Just a message inserted by MessageEvent1', NOW());
End//
DELIMITER ;
SELECT * FROM MessageEvents;
SHOW EVENTS FROM classicmodels;
SHOW EVENTS;

#Bb
DROP EVENT IF EXISTS MessageEvent2;
DELIMITER //
CREATE EVENT MessageEvent2
ON SCHEDULE
AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
ON COMPLETION PRESERVE
DO
Begin
INSERT INTO MessageEvents(Message, InsertedAt)
VALUES('Just a message inserted by MessageEvent2', NOW());
End//
DELIMITER ;
SELECT * FROM MessageEvents;
show events;

#Bc
DROP EVENT IF EXISTS MessageEvent3;
DELIMITER //
CREATE EVENT MessageEvent3
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
Begin
INSERT INTO MessageEvents(Message, InsertedAt)
VALUES('Just a message inserted by MessageEvent3', NOW());
End//
delimiter ;
SELECT * FROM MessageEvents;
SHOW EVENTS;

#B1
select * from EmployeesAudit;
DROP EVENT IF EXISTS OnetimeDeleteEmployeesAudit;
DELIMITER //
CREATE EVENT OnetimeDeleteEmployeesAudit
ON SCHEDULE AT NOW() + INTERVAL 1 Minute
DO
BEGIN
DELETE FROM EmployeesAudit
WHERE InsertTime < NOW() - INTERVAL 1 hour LIMIT 2;
End//
DELIMITER ;
select * from EmployeesAudit;

#B2
select * from EmployeesDeleteRecords;

DROP EVENT IF EXISTS EveryMinuteDeleteRows;
DELIMITER //
CREATE EVENT EveryMinuteDeleteRows
ON SCHEDULE every 1 minute
starts CURRENT_TIMESTAMP
DO
BEGIN
DELETE FROM EmployeesDeleteRecords
WHERE DeleteTime < NOW() - INTERVAL 1 hour LIMIT 2;
End//
DELIMITER ;
select * from EmployeesDeleteRecords;



--------------------------------------------------------
select * from employees;



drop trigger if exists CheckSalaryOnEmployees;
delimiter //
create trigger CheckSalaryOnEmployees before update on Employees for each row
Begin
If (new.Salary>10000)
then SIGNAL SQLSTATE 'HY000'
set MESSAGE_TEXT = 'Salary too high beyond consideration! ';
end if;
end//
delimiter ;
update Employees set Salary = Salary + 9000 where Salary > 2000;



drop trigger if exists CheckDeductionOnEmployees;
delimiter //
create trigger CheckDeductionOnEmployees before update on Employees for each row
Begin
If (new.Deduction>50)
then SIGNAL SQLSTATE 'HY000'
set MESSAGE_TEXT = 'Deduction too high beyond consideration! ';
end if;
end//
delimiter ;
update Employees set Deduction = Salary*(0.1) where Salary > 2000;



create table AddressInsertRows(FK_IDN int, CompanyCity varchar(20), HomeCity varchar(20), InsertTime datetime);

delimiter //
create trigger AddressCityAfterInsert after insert on AddressCity for each row
begin
insert into AddressInsertRows values(new.FK_IDN, new.CompanyCity, new.HomeCity, now());
end//
delimiter ;

insert into AddressCity values(69,'Compton','Hompton');
select * from AddressCity;
select * from AddressInsertRows;
