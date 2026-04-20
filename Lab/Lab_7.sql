-- 1. Create the Specialization table
CREATE TABLE specialization (
    sname VARCHAR(25) NOT NULL,
    snumber INT NOT NULL PRIMARY KEY,
    mgrssn CHAR(9),
    mgrstartdate DATE
);

-- 2. Create the Doctor table
CREATE TABLE doctor (
    fname VARCHAR(15) NOT NULL,
    minit CHAR(1),
    lname VARCHAR(15) NOT NULL,
    ssn CHAR(9) NOT NULL PRIMARY KEY,
    bdate DATE,
    address VARCHAR(50),
    sex CHAR(1),
    salary DECIMAL(10,2),
    superssn CHAR(9),
    sno INT NOT NULL,
    FOREIGN KEY (sno) REFERENCES specialization(snumber),
    FOREIGN KEY (superssn) REFERENCES doctor(ssn)
);

-- 3. Add the foreign key for mgrssn in specialization
ALTER TABLE specialization
ADD FOREIGN KEY (mgrssn) REFERENCES doctor(ssn);

-- 4. Create the Dependent table
CREATE TABLE dependent (
    essn CHAR(9) NOT NULL,
    dependent_name VARCHAR(15) NOT NULL,
    sex CHAR(1),
    bdate DATE,
    relationship VARCHAR(8),
    PRIMARY KEY (essn, dependent_name),
    FOREIGN KEY (essn) REFERENCES doctor(ssn)
);

-- 5. Create the Spec_Locations table
CREATE TABLE spec_locations (
    snumber INT NOT NULL,
    slocation VARCHAR(15) NOT NULL,
    PRIMARY KEY (snumber, slocation),
    FOREIGN KEY (snumber) REFERENCES specialization(snumber)
);

-- 6. Create the Surgery table
CREATE TABLE surgery (
    sname VARCHAR(25) NOT NULL,
    snumber INT NOT NULL PRIMARY KEY,
    slocation VARCHAR(15),
    snum INT NOT NULL,
    FOREIGN KEY (snum) REFERENCES specialization(snumber)
);

-- 7. Create the Performed_By table
CREATE TABLE performed_by (
    essn CHAR(9) NOT NULL,
    sno INT NOT NULL,
    hours DECIMAL(4,1),
    PRIMARY KEY (essn, sno),
    FOREIGN KEY (essn) REFERENCES doctor(ssn),
    FOREIGN KEY (sno) REFERENCES surgery(snumber)
);

-- Disable constraints to allow insertion in any order
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Insert data into Specialization table
INSERT INTO specialization (sname, snumber, mgrssn, mgrstartdate) VALUES
('Immunology', 1, '123456789', '2023-01-01'),
('Pulmonology', 2, '987654321', '2023-02-01'),
('Cardiology', 3, '456123789', '2023-03-01'),
('Neurology', 4, '789456123', '2023-04-01'),
('Orthopedics', 5, '321654987', '2023-05-01'),
('Oncology', 6, '159753486', '2023-06-01'),
('Pediatrics', 7, '951357486', '2023-07-01'),
('Dermatology', 8, '753951486', '2023-08-01'),
('Radiology', 9, '852741963', '2023-09-01'),
('Psychiatry', 10, '654852963', '2023-10-01'),
('Public Relations', 11, '951753258', '2023-11-01'),
('Strategy', 12, '123789456', '2023-12-01');

-- Insert data into Doctor table
INSERT INTO doctor (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, sno) VALUES
('John', 'D', 'Smith', '123456789', '1980-01-01', '123 Main St', 'M', 50000.00, NULL, 1),
('Jane', 'A', 'Doe', '987654321', '1990-02-02', '456 Elm St', 'F', 60000.00, '123456789', 2),
('Emily', 'B', 'Jones', '456123789', '1985-03-03', '789 Oak St', 'F', 55000.00, '123456789', 3),
('Michael', 'C', 'Brown', '789456123', '1975-04-04', '321 Pine St', 'M', 75000.00, '987654321', 4),
('Chris', 'E', 'Davis', '321654987', '1988-05-05', '654 Maple St', 'M', 65000.00, '987654321', 5),
('Sara', 'F', 'Wilson', '159753486', '1992-06-06', '987 Spruce St', 'F', 47000.00, '456123789', 6),
('David', 'G', 'Taylor', '951357486', '1983-07-07', '135 Birch St', 'M', 52000.00, '159753486', 7),
('Sophia', 'H', 'Anderson', '753951486', '1991-08-08', '864 Cedar St', 'F', 48000.00, '951357486', 8),
('Ethan', 'I', 'Thomas', '852741963', '1995-09-09', '246 Walnut St', 'M', 56000.00, '753951486', 9),
('Olivia', 'J', 'Moore', '654852963', '1994-10-10', '579 Chestnut St', 'F', 62000.00, '753951486', 10),
('Tom', 'K', 'Holland', '112233445', '1993-11-11', '789 Cedar St', 'M', 57000.00, '456123789', 2),
('Lucy', 'L', 'Miller', '223344556', '1996-12-12', '999 Birch St', 'F', 60000.00, '987654321', 5);

-- Insert data into Dependent table
INSERT INTO dependent (essn, dependent_name, sex, bdate, relationship) VALUES
('123456789', 'Anna', 'F', '2005-01-01', 'Daughter'),
('123456789', 'Mark', 'M', '2008-02-02', 'Son'),
('987654321', 'Sam', 'M', '2007-03-03', 'Son'),
('456123789', 'Ella', 'F', '2010-04-04', 'Daughter'),
('789456123', 'Max', 'M', '2012-05-05', 'Son'),
('321654987', 'Liam', 'M', '2013-06-06', 'Son'),
('159753486', 'Emma', 'F', '2015-07-07', 'Daughter'),
('951357486', 'Olive', 'F', '2016-08-08', 'Daughter'),
('753951486', 'Lucas', 'M', '2017-09-09', 'Son'),
('852741963', 'Sophia', 'F', '2018-10-10', 'Daughter');

-- Insert data into Spec_Locations table
INSERT INTO spec_locations (snumber, slocation) VALUES
(1, 'New York'), (1, 'Chicago'), (2, 'Los Angeles'), (2, 'Houston'),
(3, 'San Francisco'), (3, 'Boston'), (4, 'Seattle'), (4, 'Denver'),
(5, 'Austin'), (5, 'Dallas'), (6, 'Atlanta'), (6, 'Miami'),
(7, 'Phoenix'), (7, 'Philadelphia'), (8, 'San Diego'), (8, 'San Jose'),
(9, 'Orlando'), (9, 'Tampa'), (10, 'Detroit'), (10, 'Cleveland'), (3, 'Seattle');

-- Insert data into Surgery table
INSERT INTO surgery (sname, snumber, slocation, snum) VALUES
('Bypass', 1, 'New York', 1),
('Beta-Repair', 2, 'Los Angeles', 2),
('Gamma-Scan', 3, 'San Francisco', 3),
('Delta-Op', 4, 'Seattle', 4),
('Epsilon-Fix', 5, 'Austin', 5),
('Zeta-TREAT', 6, 'Atlanta', 6),
('Eta-PROC', 7, 'Phoenix', 7),
('Theta-CARE', 8, 'San Diego', 8),
('Iota-SURG', 9, 'Orlando', 9),
('Kappa-EXAM', 10, 'Detroit', 10),
('Lambda-X', 11, 'Las Vegas', 3),
('Omega-Y', 12, 'Seattle', 6);

-- Insert data into Performed_By table
INSERT INTO performed_by (essn, sno, hours) VALUES
('123456789', 1, 20.5), ('987654321', 2, 30.0), ('456123789', 3, 25.0),
('789456123', 4, 35.0), ('321654987', 5, 40.0), ('159753486', 6, 15.0),
('951357486', 7, 22.0), ('753951486', 8, 18.0), ('852741963', 9, 28.5),
('654852963', 10, 33.0), ('123456789', 2, 10.0), ('987654321', 4, 15.5),
('951357486', 6, 10.0);

-- Updates and Constraints Enable
UPDATE doctor SET superssn = '753951486' WHERE ssn = '951357486';
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";

--1
/*
go
create view display_doctor as
select doctor.ssn, doctor.fname, doctor.lname, doctor.salary, doctor.sno
from doctor
go

select * from display_doctor
*/

/*
create unique clustered index idx 
on  display_doctor(ssn)

select * from display_doctor
*/

--2
/*
go
create view manager_info as 
select s.sname, d.fname, d.lname, s.mgrstartdate
from specialization s join doctor d on s.mgrssn=d.ssn
go

select * from manager_info
*/

--3
/*
go
create view dependent_info as 
select do.lname, de.dependent_name, de.relationship
from doctor do join dependent de on do.ssn=de.essn
go

select * from dependent_info
*/

--5
-- not added the newly inserted row
/*
go
create view high_earner as 
select ssn, fname, salary
from doctor
where salary>60000
go

select * from high_earner
insert into high_earner values('123456789', 'Sajjad', '1000000')
select * from high_earner
*/

--7
/*
go
create procedure update_salary
@d_ssn char(9), @percent float
as
begin 
update doctor
set salary=salary+(salary*@percent)
where ssn=@d_ssn
end
go

exec update_salary @d_ssn='123456789', @percent=0.2
select * from doctor
*/

--8
/*
go
create procedure insert_performed_by
@ssn char(9), @s_no integer, @hours decimal(4, 1)
as 
begin 
insert into performed_by values(@ssn, @s_no, @hours)
end
go

exec insert_performed_by @ssn='123456789', @s_no=3, @hours=12.0

select * from performed_by
*/
