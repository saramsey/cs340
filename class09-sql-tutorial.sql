/* (Q9) What if we wanted to get the models, years, and IDs of all cars which have
more than two service records *or* which have been rented only once? */

/* Let's start by the more than two service records: */
SELECT car.id FROM car INNER JOIN servicing ON car.id = servicing.carId GROUP BY
car.id HAVING COUNT(car.id) > 2;

/* Now let's get the car IDs that have been rented more than twice */
SELECT car.id FROM car INNER JOIN rentalCar ON car.id = rentalCar.carId GROUP BY
car.id HAVING COUNT(car.id) = 1;

/* Now we need to do a final select to get the car models and years: */
SELECT car.id, car.model, car.year FROM car WHERE car.id IN (
SELECT car.id FROM car INNER JOIN servicing ON car.id = servicing.carId GROUP BY
car.id HAVING COUNT(car.id) > 2) OR car.id IN (
SELECT car.id FROM car INNER JOIN rentalCar ON car.id = rentalCar.carId GROUP BY
car.id HAVING COUNT(car.id) = 1);

/* For the next part, we'll add a new row into the car table */
INSERT INTO car (year, model, price, lastService) VALUES (2018, 'Tesla Model X',
100000.0, '2018-10-14');

/* Now, what does the car table look like?  Do a (SELECT * from car) to have a look */
SELECT * from car;

/* note that the "lastServiced" field for the Tesla is incorrect, since there
are no corresponding service records in the "servicing" table */

/* (Q9b) List cars along with whether they have any referencing records in the
servicing table (yes/no); can we do it without an INNER JOIN? */

/* Can do this using COUNT and CASE: */
select car.id, car.model, car.year, (case (select COUNT(*) from servicing where
servicing.carId = car.id) > 0 when TRUE then 'yes' else 'no' end) as
hasBeenServiced from car;

/* Can also do this using EXISTS and CASE: */
select car.id, car.model, car.year, (case exists (select 1 from servicing where
servicing.carId = car.id) when TRUE then 'yes' else 'no' end) as hasBeenServiced
from car;

/* (Q10) Let's write a query to find any cars for which the "lastService" field
is incorrect (i.e., corresponding row in servicing table isn't the date of the
last service) */

/* We'll start by doing an equijoin between car and servicing: */

SELECT car.id, car.model, car.year, car.lastService, servicing.serviceDate FROM
car INNER JOIN servicing ON car.id = servicing.carId;

/* but this is not what we want, beacause the Tesla is not showing up; let's
make this a LEFT JOIN */
SELECT car.id, car.model, car.year, car.lastService, servicing.serviceDate FROM
car LEFT JOIN servicing ON car.id = servicing.carId;

/* OK now the Tesla appears. Now we need to do a group by carId and then select
the max serviceDate: */
SELECT car.id, car.model, car.year, car.lastService, max(serviceDate) FROM car
LEFT JOIN servicing ON car.id = servicing.carId GROUP BY car.id;

/* Getting closer! Now we just need to select for rows in the aggregated virtual
table such that the max service date is not the same as the last service: */
SELECT car.id, car.model, car.year, car.lastService, max(serviceDate) AS
maxServiceDate FROM car LEFT JOIN servicing ON car.id = servicing.carId GROUP BY
car.id HAVING car.lastService <> maxServiceDate OR maxServiceDate IS NULL;

/* (Q11) How do aggregation functions handle NULL? */
/* Are NULL values included in an average?  Let's test it */
/*  - start by looking at the state of the table rentalCar: */
SELECT * from rentalCar;

/*  - now do an average on the column "endTime", which contains a NULL */
SELECT AVG(endTime) FROM rentalCar;

/* Does this mean that the NULL was included in the average, or not? */
/* Now let's try COUNT(endTime). Will that include the NULL, do you think? */
SELECT COUNT(endTime) from rentalCar;

/* (Q12) If we want to compute the number of distinct years for cars: */
SELECT COUNT(*) FROM (SELECT year FROM car GROUP BY year) AS T;

/* If we want to compute the number of distinct years for cars: */
SELECT COUNT(*) FROM (SELECT DISTINCT year FROM car) AS T;

/* But there is an easier way to do this: */
SELECT COUNT(DISTINCT year) FROM car;

/* (Q13) What if we wanted a simple SQL query to tell us if all the car models
in the car table are unique? It would be nice if we could just use the UNIQUE
SQL predicate: */

SELECT CASE UNIQUE (car.model) WHEN TRUE THEN 'yes' ELSE 'no' END AS t FROM car;

/* But MariaDB doesn't seem to support tthe UNIQUE SQL predicate, so we have to
use COUNT: */
SELECT CASE COUNT(DISTINCT car.model) WHEN COUNT(model) THEN 'yes' ELSE 'no' END
AS t FROM car;

/* (Q14) We can use a CASE statement to conditionally update a field: */

/* To illustrate, let's first create a table of "computer_credits" */
drop table if exists computer_credits;

create table computer_credits ( id int unsigned auto_increment, name
varchar(256), user_type set('student', 'faculty'), ncred INT UNSIGNED NULL,
primary key (id) );

insert into computer_credits (user_type, name) values ('faculty', 'Don Knuth'),
('faculty', 'Grace Hopper'), ('student', 'Alice Student'), ('student', 'Bob
Student');

/* Let's suppose that the business rule is that students get 100 credits, and
faculty get 200 credits; can update the table using a CASE statement: */
update computer_credits set ncred = (case when user_type='student' then 100 else
200 end);

/* (Q15) What if we wanted to get a count of number of times each person has rented
each type of car? */
SELECT customer.custName, car.model, COUNT(*) FROM car, customer, rental,
rentalCar WHERE customer.id = rental.custId AND rentalCar.rentalId = rental.id
AND car.id = rentalCar.carId GROUP BY customer.custName, car.model;

/* What if we wanted to use INNER JOIN syntax for the same query? */

SELECT customer.custName, car.model, COUNT(*) FROM 
(((customer INNER JOIN rental ON customer.id = rental.custId) 
            INNER JOIN rentalCar ON rentalCar.rentalId = rental.id) 
            INNER JOIN car ON car.id = rentalCar.carId) 
GROUP BY customer.custName, car.model;

/* (Q15b) What if we wanted to order by the count in decreasing order? */
/*   - we would just add an ORDER BY clause; but we also need to label COUNT(*) */

SELECT customer.custName, car.model, COUNT(*) AS c FROM 
(((customer INNER JOIN rental ON customer.id = rental.custId) 
            INNER JOIN rentalCar ON rentalCar.rentalId = rental.id) 
            INNER JOIN car ON car.id = rentalCar.carId) 
GROUP BY customer.custName, car.model ORDER BY c DESC;

/* What if we wanted to make a new table custRentalCount containing that
information? */

CREATE TABLE custRentalCount ( custName VARCHAR(256), model VARCHAR(32), count
INT UNSIGNED );

INSERT INTO custRentalCount (custName, model, count)
               SELECT customer.custName, car.model, COUNT(*)
               FROM (((customer INNER JOIN rental ON customer.id = rental.custId)
               INNER JOIN rentalCar ON rentalCar.rentalId = rental.id)
               INNER JOIN car ON car.id = rentalCar.carId)
               GROUP BY customer.custName, car.model;

/* What value would this query produce? */
SELECT COUNT(*) from t1;

/* What value would this query produce? */
SELECT COUNT(*) from t2;

/* What value would this query produce? */
SELECT COUNT(*) FROM t1, t2;

/* What value would this query produce? */
SELECT COUNT(*) FROM t1 CROSS JOIN t2;

/* If we add a tuple to t2 with id NULL... */
ALTER TABLE t2 DROP FOREIGN KEY t2_ibfk_1;
ALTER TABLE t2 DROP PRIMARY KEY;
ALTER TABLE t2 MODIFY id INT UNSIGNED NULL;
ALTER TABLE t2 ADD FOREIGN KEY (id) REFERENCES t1(id);
INSERT INTO t2 (id, x) VALUES (NULL, 'g');

/* What will the natural equijoin return? */
SELECT * FROM t1 JOIN t2 USING (id);

/* What will the left join return? */
SELECT * FROM t1 LEFT JOIN t2 USING (id);

/* Will this return the same result? */
SELECT * FROM t1 LEFT OUTER JOIN t2 USING (id);

/* What if we do a RIGHT JOIN? */
SELECT * FROM t1 RIGHT JOIN t2 USING (id);

/* Will this return the same result? */
SELECT * FROM t1 RIGHT OUTER JOIN t2 USING (id);

/* What if we drop the PK on table 1, drop the foreign key constraint, and
add a row to t1 like this: */

ALTER TABLE t2 DROP FOREIGN KEY `t2_ibfk_1`;
ALTER TABLE t1 modify id int unsigned;
ALTER TABLE t1 drop primary key;
ALTER TABLE t1 modify id int unsigned null;
INSERT INTO t1 (id, x) values (NULL, 'h');
ALTER TABLE t1 add constraint uid unique (id);
ALTER TABLE t2 add constraint fid foreign key (id) references t1(id);

/* Now what if we do a FULL OUTER JOIN? */
SELECT * FROM t1 FULL OUTER JOIN t2 USING (id);

/* Hmm, we get a syntax error.  This is because MariaDB/MySQL do not support
full outer join. */

/* (Q16) How can we do an OUTER JOIN in MariaDB/MySQL? */

/* We can do an OUTER JOIN using a UNION ALL, like this: */
(SELECT * FROM t1 LEFT JOIN t2 USING (id)) UNION ALL
(SELECT * FROM t1 RIGHT JOIN t2 USING (id) WHERE t1.id IS NULL)

/* (Q17) Is it permissible to do an equijoin on two non-key columns? */

/* To test this idea, let's update t1 so that there is a common joining value
'd' in the 'x' column */
update t1 set x='d' where x='h';

/* Now let's try to do an inner join. Does it work? */
select * from t1 inner join t2 on t1.x = t2.x;

/* (Q18) So would using a "UNION" really give us an outer join? */

/* To test this, let's update t1 so that it has a duplicate row: (primary key is
dropped so we can do this): */
insert into t1 (id, x) values (NULL, 'd');

/* What happens when we run this query?  Is it a true outer join? */
(SELECT * FROM t1 LEFT JOIN t2 USING (id)) UNION
(SELECT * FROM t1 RIGHT JOIN t2 USING (id) WHERE t1.id IS NULL)

/* Compare to the original UNION ALL approach: */
(SELECT * FROM t1 LEFT JOIN t2 USING (id)) UNION ALL
(SELECT * FROM t1 RIGHT JOIN t2 USING (id) WHERE t1.id IS NULL)


/* WITH statement */

/* Let's reconstitute the employee and department tables from class session 6: */
drop table if exists employee;
drop table if exists department;

CREATE TABLE department (
       Dnumber INT UNSIGNED NOT NULL AUTO_INCREMENT,
       PRIMARY KEY (Dnumber)
);       
     
CREATE TABLE employee (
       Eid INT UNSIGNED NOT NULL AUTO_INCREMENT,  /* employee ID */
       Dno INT NOT NULL DEFAULT 1,               /* num. of dept. that they work in */
       salary decimal(9,2),
       PRIMARY KEY (Eid)                          /* designate Eid as primary key */
);     

/* (Q19) Suppose we are asked to generate a list of employees that are making more
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


/* How would you define a view called RentalFrequencyReport based on this SQL
query (Q15) from the rental car database? */

CREATE VIEW RentalFrequencyReport AS SELECT customer.custName, car.model,
COUNT(*) FROM car, customer, rental, rentalCar WHERE customer.id = rental.custId
AND rentalCar.rentalId = rental.id AND car.id = rentalCar.carId GROUP BY
customer.custName, car.model;

SELECT * FROM RentalFrequencyReport;

/* Is this view updatable? */
SELECT TABLE_NAME, IS_UPDATABLE FROM INFORMATION_SCHEMA.VIEWS WHERE
TABLE_SCHEMA='cs340';
