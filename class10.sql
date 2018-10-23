/* Can I see an example of implicit casting in MariaDB? */
select 'a' = 0;

/* Can I see an example of explicit casting in MariaDB? */
select cast('1' as signed integer);

/* What is MariaDB's behavior for an improper implicit cast? */
/*  - first we'll create table with a single integer column */
create table testtable ( id INT );
/*  - now try to insert a string; does the operation complete?  */
insert into testtable (id) SELECT 'a' IN(0);
/*  - what is the table state after the insert? */
select * from testtable;

/* Example SQL statement that could run very slowly on MariaDB due to a cast on a column join */
SELECT s.*, f.* FROM notifications s INNER JOIN notifications_fields f ON s.sid
= f.sid LEFT JOIN term_node t ON f.field = 'tid' AND f.value = CAST(t.tid AS CHA
R) WHERE s.uid = 2 AND event_type = 'node' AND ((f.field = 'nid' AND f.value =
'62394') OR (f.field = 'type' AND f.value = 'program_producer') OR (f.field =
'author' AND f.value = '2') OR (t.nid = 62394))

/* Example SQL statements that return the same results but one will use an
index and one will not */
/* - set up the table with two columns */
create table t (a VARCHAR(10), INDEX idx_a (a), b VARCHAR(10));
insert into t values ('1', 'x'), ('2', 'y'), ('3', 'z'), ('4', 'w'), ('5', 'q');

/* - This query uses the index */
explain select * from t where a = '3';

/* - This query contains an implicit cast that defeats use of the index: */
explain select * from t where a = 3;

/* How do I add a column to an existing table? */
ALTER TABLE car ADD COLUMN newcol INT;

/* How do I remove a column from an existing table? */
ALTER TABLE car DROP COLUMN newcol;

/* How do I modify a column in an existing table? */
ALTER TABLE car MODIFY price DECIMAL(9,2);

/* Suppose we are asked to generate a list of employees that are making more
than 40k and that are from "big" departments (> 5 employees in the department).
E&N recommend using a query with a WITH statement: */
WITH (BIGDEPTS (Dno) AS (SELECT (Dno FROM employee group by Dno HAVING COUNT(*)
> 5) SELECT Dno, COUNT(*) FROM employee WHERE salary > 40000 AND Dno IN BIGDEPTS
GROUP BY Dno;

/* MariaDB 10.1.22 doesn't have WITH. Can you do it using a nested SELECT
statement without a WITH? */
select Dno,count(*) from employee where salary>40000 and Dno in (select Dno from
employee group by Dno having count(*) > 5) group by Dno;

/* Can we rewrite a non-recursive CTE query as an ugly nested SELECT query? */

/*   - first need to set up the table */
drop table if exists employees;
create table employees (name VARCHAR(256), country VARCHAR(256), dept VARCHAR(64));
insert into employees values ('Tim Berners-Lee', 'Switzerland', 'Development'),
('Ole-Johan Dahl', 'Norway', 'Development'), ('Robin Milner', 'UK', 'Development'),
('Frances Allen', 'USA', 'Development'), ('Support Person', 'USA', 'Support'),
('Support Person 2', 'UK', 'Support');

/* Here is the nested SELECT query to replace the CTE query: */
select * from (select * from employees where dept in ('Development', 'Support'))
AS E1 where not exists (select 1 from (select * from employees where dept in
('Development', 'Support')) as E2 where E2.country=E1.country and E2.name <>
E1.name);

/* VIEW exercise:  in the rental car database, here is a SELECT query that returns
the number of times each customer rented each type of car */
SELECT customer.custName, car.model, COUNT(*) AS c FROM ((car INNER JOIN rentalCar ON
rentalCar.carId = car.id) INNER JOIN rental ON rentalCar.rentalId = rental.id)
INNER JOIN customer ON rental.custId = customer.id GROUP BY customer.custName,
car.model ORDER BY c DESC;

/* - How would you define a view called RentalFrequencyReport based on this SQL
query from the rental car database? */
CREATE VIEW RentalFrequencyReport AS SELECT customer.custName, car.model,
COUNT(*) AS c FROM ((car INNER JOIN rentalCar ON rentalCar.carId = car.id) INNER
JOIN rental ON rentalCar.rentalId = rental.id) INNER JOIN customer ON
rental.custId = customer.id GROUP BY customer.custName, car.model ORDER BY c
DESC;

/* - How would you query the View that you just created? */
SELECT * FROM RentalFrequencyReport;

/* - Is this view updatable, based on the MariaDB criteria for a View to be updatable? */

/* - How would you get MariaDB to tell you if a View is updatable? */
SELECT TABLE_NAME, IS_UPDATABLE FROM INFORMATION_SCHEMA.VIEWS WHERE
TABLE_SCHEMA='cs340';

/* How do I update all rows of a table at once, using a single SQL statement? */

/* - We'll demonstrate by updating the "lastService" column in the "car" table */

/* - First, we'll construct a query that will return carID and the
max(serviceDate), for each car */
select carID, max(serviceDate) as maxServiceDate from servicing group by carID;

/* - Next, we need to make a virtual table joining the car table and the result of
our previous query; we'll do this using a nested query. Since we will be turning
this into an UPDATE query (and thus not having the usual column-list that you
would have in the outer select statement) we can just select "*" here */
select * from car INNER JOIN (select carID, max(serviceDate) as maxServiceDate
from servicing group by carID) as temptable;

/* - Next, we need to do the update on this joined table, since the two columns
that we want (car.lastService and temptable.maxServiceDate) are both in it */
update car inner join (select servicing.carId, max(servicing.serviceDate) as
svcdate from servicing group by servicing.carId) as testsvc on car.id =
testsvc.carId set car.testsvc = testsvc.svcdate;

/* How can we define a trigger that will run the above SQL query whenever a new
row is added to the servicing table? */
create trigger update_car_last_service after insert on servicing for each row
update car inner join (select servicing.carId, max(servicing.serviceDate) as
svcdate from servicing group by servicing.carId) as testsvc on car.id =
testsvc.carId set car.testsvc = testsvc.svcdate;

/* - To see the trigger: */
show triggers;

/* - Now let's test the trigger by running this insert into the servicing table: */
insert into servicing (id, garageid, carId, serviceDate) values (9, 1, 4,
'2018-10-23')

/* - Let's look at the car table and see if the trigger worked */
select * from car where car.id=4;

/* - And to delete the trigger, you would use a DROP TRIGGER statement: */
drop trigger update_car_last_service;

/* - How would you get the row in a table in which a column has the max value? */
/*   You'd use a nested query, like this: */
select * from rentalCar where amountReceived = (select max(amountReceived) from
rentalCar);

/* - As an alternative, you could use the MySQL-specific LIMIT keyword: */
select * from rentalCar order by amountReceived DESC LIMIT 1;

/* Use a trigger to prevent a viollation of a semantic constraint */
/* Example: date for insert into servicing must be the latest date for the car */

/* - get the max servicing.id for each car, as table t1 */
select max(id) as sid, carId from servicing group by carId;

/* - get the servicing id of the max date for each car, as table t2 */
select id as sid from servicing INNER JOIN (select carId, max(serviceDate) as
msd from servicing group by carId) as t2 on servicing.carId = t2.carId AND
servicing.serviceDate = t2.msd;

/* - join them together to a single query, there should be no rows returned */
select t1.sid from (select max(id) as sid, carId from servicing group by carId)
as t1 LEFT JOIN (select id as sid from servicing INNER JOIN (select carId,
max(serviceDate) as msd from servicing group by carId) as t2 on servicing.carId
= t2.carId AND servicing.serviceDate = t2.msd) AS t3 ON t1.sid=t3.sid WHERE
t3.sid IS NULL;

/* - turn it into a boolean condition using EXISTS */
select exists( select t1.sid from (select max(id) as sid, carId from servicing
group by carId) as t1 LEFT JOIN (select id as sid from servicing INNER JOIN
(select carId, max(serviceDate) as msd from servicing group by carId) as t2 on
servicing.carId = t2.carId AND servicing.serviceDate = t2.msd) AS t3 ON
t1.sid=t3.sid WHERE t3.sid IS NULL );

/* - define a trigger */
#START TRIGGER
DELIMITER //
CREATE TRIGGER insert_servicing BEFORE INSERT ON servicing 
FOR EACH ROW 
BEGIN
    IF EXISTS( SELECT t1.sid from (select max(id) as sid, carId from
	servicing group by carId) as t1 LEFT JOIN (select id as sid from
	servicing INNER JOIN (select carId, max(serviceDate) as msd from
	servicing group by carId) as t2 on servicing.carId = t2.carId AND
	servicing.serviceDate = t2.msd) AS t3 ON t1.sid=t3.sid WHERE t3.sid IS
	NULL ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'error on insert into servicing'; 
    END IF;
END//
DELIMITER ;
#END TRIGGER

/* - test it out by doing a constraint-violating insert into servicing */
insert into servicing (garageId, carId, serviceDate) values (1, 4, '2018-10-22');


/* The following is an example of particularly bad database design; it is for
the COMPANY database */

create table EMP_LOCS ( Ename VARCHAR(30), Plocation VARCHAR(20), PRIMARY KEY (Ename, Plocation) );

create table EMP_PROJ1 ( Ssn DEC(9,0), Pnumber INT UNSIGNED, Hours DEC(4,1),
Pname VARCHAR(20), Plocation VARCHAR(20), PRIMARY KEY (Ssn, Pnumber));

insert into EMP_LOCS values ('Smith, John B.', 'Bellaire'),
                            ('Smith, John B.', 'Sugerland'),
                            ('Narayan, Ramesh K.', 'Houston'),
                            ('English, Joyce A.', 'Bellaire'),
                            ('English, Joyce A.', 'Sugerland'),
                            ('Wong, Franklin T.', 'Sugerland'),
                            ('Wong, Franklin T.', 'Houston'),
                            ('Wong, Franklin T.', 'Stafford'),
                            ('Zelaya, Alicia J.', 'Stafford'),
                            ('Jabba, Ahmad V.', 'Stafford'),
                            ('Wallace, Jennifer S.', 'Stafford'),
                            ('Wallace, Jennifer S.', 'Houston'),
                            ('Borg, James E.', 'Houston');
                            
insert into EMP_PROJ1 values ( 123456789, 1, 32.5, 'ProductX', 'Bellaire' ),
                             ( 123456789, 2, 7.5, 'ProductY', 'Sugerland' ),
                             ( 666884444, 3, 40.0, 'ProductZ', 'Houston' ),
                             ( 453453453, 1, 20.0, 'ProductX', 'Bellaire' ),
                             ( 453453453, 2, 20.0, 'ProductY', 'Sugerland' ),
                             ( 333445555, 2, 10.0, 'ProductY', 'Sugerland' ),
                             ( 333445555, 3, 10.0, 'ProductZ', 'Houston' ),
                             ( 333445555, 10, 10.0, 'Computerization', 'Stafford' ),
                             ( 333445555, 20, 10.0, 'Reorganization', 'Houston' ),
                             ( 999887777, 30, 30.0, 'Newbenefits', 'Stafford' ),
                             ( 999887777, 10, 10.0, 'Computerization', 'Stafford' ),
                             ( 987987987, 10, 35.0, 'Computerization', 'Stafford' ),
                             ( 987987987, 30, 5.0, 'Newbenefits', 'Stafford' ),
                             ( 987654321, 30, 20.0, 'Newbenefits', 'Stafford' ),
                             ( 987654321, 20, NULL, 'Reorganization', 'Houston' );
                             
/* - what happens if we do a natural join on EMP_LOCS and EMP_PROJ1? */
select * from EMP_LOCS JOIN EMP_PROJ1 USING (Plocation);
