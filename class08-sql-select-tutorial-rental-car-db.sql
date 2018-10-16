/* Let's discuss a bit about multitable queries. Suppose that we want to get a list
of car model/year and all service dates; using the syntax we explored last week,
we would construct a query like this: */

SELECT car.model, car.year, servicing.serviceDate FROM car, servicing WHERE
car.id = servicing.carId;

/* If we wanted to sort the result-set chronologically, we would use the
ORDER BY syntax: */

SELECT car.model, car.year, servicing.serviceDate FROM car, servicing WHERE
car.id = servicing.carId ORDER BY servicing.serviceDate;

/* When we are querying across two tables like this by selecting tuples from
each that have matching not null values for two attributes, we are selecting
from the cartesian product of the two sets of rows of the two tables. In the
WHERE clause, we are filtering based in the quality of the referring and
referred attributes of the foreign key relationship between the tables; the
condition that we are using to select the rows for the result-set (in this case
the condition that the two id attributes are equal) is known as the "join
condition". When the query FROM clause specifies the full cross product of
tables (using the comma notation) and we are filtering for rows in which two
columns from two tables are identical, this is called an "equijoin".  The
particular syntax that we are using, with the comma-delimimted list of tables in
the FROM clause and the join condition asserted in the WHERE clause, is called a
"comma equijoin" or a "theta equijoin". It turns out there are two other ways to
do an equijoin in SQL, both of which have advantages in terms of query
simplicity and comprehendability. To illustrate this, let's view all columns of
the two tables: */

SELECT * from car, servicing WHERE car.id = servicing.carId;

/* You can see that the "car.id" and "servicing.carId" columns are identical for
every row in the result-set, i.e., we only see rows that satisfy the join
condition. That is why it is called an "equijoin". Now, there are two other
ways of accomplishing this same restriction on the rows for our query, but that
are specified in the FROM clause of the query rather than in the WHERE
clause. Both make use of a JOIN keyword. First, I'll show you the INNER JOIN
syntax as it is closer to the comma or theta equijoin syntax: */

SELECT * from car INNER JOIN servicing ON car.id = servicing.carId;

/* Let's compare the two queries. Are they the same? */

/* But how do we *know* it's the same query, just because we got the same results? 
   We can use the EXPLAIN EXTENDED SQL command. We'll start with the  */

/* (show slide from Canvas) */

/* Now, there is a third way of expressing an equijoin as a so-called "natural" join.
In SQL, we would do this using the "USING" keyword. But to do a natural join of two
tables with the USING keyword, the referencing and referenced column names for
the foreign key relationship need to be identical. To illustrate this, we'll need
two tables that have a foreign key relationship where the names of the referencing
and referenced columns are identical: */

drop table if exists t2;
drop table if exists t1;
create table t1 (id INT UNSIGNED AUTO_INCREMENT, x CHAR(1), PRIMARY KEY (id));
create table t2 (id INT UNSIGNED, x CHAR(1), PRIMARY KEY (id), 
FOREIGN KEY (id) REFERENCES t1(id));
insert into t1 (x) values ('a');
insert into t1 (x) values ('b');
insert into t1 (x) values ('c');
insert into t2 (id, x) values (1, 'd');
insert into t2 (id, x) values (2, 'e');
insert into t2 (id, x) values (3, 'f');

/* We'll do an equijoin three different ways. First, the theta equijoin: */

SELECT * FROM t1, t2 WHERE t1.id = t2.id;

/* Next, the INNER JOIN syntax */

SELECT * FROM t1 INNER JOIN t2 ON t1.id = t2.id;

/* Next, the "natural join" syntax: */

SELECT * FROM t1 JOIN t2 USING (id);

/* With the NATURAL , do you see how there is only one "id" column in the
result-set?  DO NOT TRY THIS IF YOU HAVE TWO DIFFERENT COLUMN NAMES, it won't
work. */

/* Do they all have the same query plan? */

EXPLAIN EXTENDED SELECT * FROM t1, t2 WHERE t1.id = t2.id;
EXPLAIN EXTENDED SELECT * FROM t1 INNER JOIN t2 ON t1.id = t2.id;
EXPLAIN EXTENDED SELECT * FROM t1 JOIN t2 USING (id);

/* Yes, they do, so performance-wise, they should all be identical in this
case. Because it is both very generally applicable and nicely groups the two
tables that are being joined with the equijoin condition, the INNER JOIN syntax
is preferred from a code readability standpoint. */


/* What if we wanted to make a table of names of people who were either drivers
or customers? */

(SELECT custName AS name FROM customer) UNION (SELECT driverName AS name FROM driver);

/* Note: UNION returns only the distinct rows; if you want to see the
duplication, you would use UNION ALL: */

(SELECT DISTINCT custName AS name FROM customer) UNION ALL (SELECT DISTINCT
driverName AS name FROM driver);

/* In this case, we've included DISTINCT because otherwise we would not see just
the duplication *between* the two tables, but also the duplication *within* the tables */

/* What if we wanted to add a rentalCar row for which the rental was still "in
   progress"?  We could use NULL for the rentalCar.endTime column:  */

INSERT INTO rental (rentalDate, custId) VALUES ('2018-10-16', 1);

INSERT INTO rentalCar (rentalId, carId, driverId, startTime, amountReceived)
VALUES (5, 1, 2, '09:00', 72.37);

/* What if we wanted to find the models of cars for which the rental is currently 
in-progress, as well as the drivers' names? */

/*   First, we'll join the driver, car, and rentalCar tables together using INNER JOINs */

SELECT car.model, driver.driverName FROM ((CAR INNER JOIN rentalCar ON
                                     rentalCar.carId = car.id) INNER JOIN driver
                                     ON driver.id = rentalCar.driverId);

/* Look at the result-set; we see the car model and the driver name, but we
don't know which of these are currently out rented or returned; what column do
we need to add? */

/*   Let's try adding the rentalCar.endTime column: */

SELECT car.model, driver.driverName, rentalCar.endTime FROM ((CAR INNER JOIN
                                     rentalCar ON rentalCar.carId = car.id)
                                     INNER JOIN driver ON driver.id =
                                     rentalCar.driverId);

/*   Which of these is out rented? OK, so we want to filter for that field, right?  Now do we do that?  */

SELECT car.model, driver.driverName, rentalCar.endTime FROM ((CAR INNER JOIN
                                     rentalCar ON rentalCar.carId = car.id)
                                     INNER JOIN driver ON driver.id =
                                     rentalCar.driverId) WHERE rentalCar.endTime
                                     IS NULL;

/*   Is it correct to use = NULL ? Let's try it: */

SELECT car.model, driver.driverName, rentalCar.endTime FROM ((CAR INNER JOIN
                                     rentalCar ON rentalCar.carId = car.id)
                                     INNER JOIN driver ON driver.id =
                                     rentalCar.driverId) WHERE rentalCar.endTime
                                     = NULL;

/*   No, you see that it is not. Because NULL = NULL has state UNKNOWN in SQL: */

/* What if we wanted the same data, but for cars that are *not* currently out rented? */

SELECT car.model, driver.driverName, rentalCar.endTime FROM ((CAR INNER JOIN
                                     rentalCar ON rentalCar.carId = car.id)
                                     INNER JOIN driver ON driver.id =
                                     rentalCar.driverId) WHERE rentalCar.endTime
                                     IS NOT NULL;

/* So you're telling me that any row where the WHERE clause evaluates to UNKNOWN
is not included?  Let's test this... */

/*    How many rows should this return?   */

SELECT COUNT(*) FROM car;
SELECT COUNT(*) FROM car WHERE 1 = 1;
SELECT COUNT(*) FROM car WHERE 1 = 0;
SELECT COUNT(*) FROM car WHERE 1 = NULL;
SELECT COUNT(*) FROM car WHERE 1 = 1 OR 1 = NULL;
SELECT COUNT(*) FROM car WHERE 1 = 1 OR NULL = NULL;
SELECT COUNT(*) FROM car WHERE 1 = 1 AND 1 = NULL;
SELECT COUNT(*) FROM car WHERE 1 = 1 AND NULL = NULL;
SELECT COUNT(*) FROM car WHERE NOT (NULL = NULL);
SELECT COUNT(*) FROM car WHERE NOT (NULL = 1) AND 1 = 1;
SELECT COUNT(*) FROM car WHERE NOT (NULL = 1) OR 1 = 1;
SELECT COUNT(*) FROM car WHERE NULL < 1;
SELECT COUNT(*) FROM car WHERE NULL > 1;
SELECT COUNT(*) FROM car WHERE NULL < 1 AND 1 = 1;
SELECT COUNT(*) FROM car WHERE NULL < NULL OR 1 = 1;

/* Let's get a list of customer IDs for all "high roller" drivers with at least
one rentalCar record that had an amountReceived greater than 80.00; we'll
include the amount received, just so that we can see that the filter worked */

SELECT customer.id, rentalCar.amountReceived FROM (customer INNER JOIN rental ON
customer.id = rental.custId) INNER JOIN rentalCar ON rental.id =
rentalCar.rentalId WHERE rentalCar.amountReceived > 80.0;

/* Suppose that we are working on a promotional mailing list for "hometown"
customers. Boss says that we need to get a list of "hometown" customer IDs that
are from Corvallis *or* the driver is from Corvallis */

/* Hmm, let's start with the customer table, as it is easier since the city and
customer name are in the same table: */

SELECT customer.id, customer.custName AS name FROM customer WHERE city = 'Corvallis, OR'

/* What about driver address?  For that, we have to join customer to rental,
rental to rentalCar, and rentalCar to driver: */

SELECT DISTINCT customer.id, customer.custName AS name FROM ((customer INNER
        JOIN rental ON customer.id = rental.custId) INNER JOIN rentalCar ON
        rental.id = rentalCar.rentalId) INNER JOIN driver on rentalCar.driverId
        = driver.id WHERE driver.address = 'Corvallis, OR'

/* Now, how would we combine these?  We can use a UNION */

(SELECT customer.id, customer.custName AS name FROM customer WHERE city =
'Corvallis, OR') UNION
(SELECT DISTINCT customer.id, customer.custName AS name FROM ((customer INNER
        JOIN rental ON customer.id = rental.custId) INNER JOIN rentalCar ON
        rental.id = rentalCar.rentalId) INNER JOIN driver on rentalCar.driverId
        = driver.id WHERE driver.address = 'Corvallis, OR')

/* The first query returned "Stephen Ramsey", and the second query returned
        "Donald Knuth", and the union combined them */

/* What if we wanted a COUNT of these rows?  We could use a *nested* SQL query,
as shown here: */

SELECT COUNT(*) FROM ((SELECT customer.id, customer.custName AS name FROM
customer WHERE city = 'Corvallis, OR') UNION
(SELECT DISTINCT customer.id, customer.custName AS name FROM ((customer INNER
        JOIN rental ON customer.id = rental.custId) INNER JOIN rentalCar ON
        rental.id = rentalCar.rentalId) INNER JOIN driver on rentalCar.driverId
        = driver.id WHERE driver.address = 'Corvallis, OR')) AS T;

/* But what is the "AS T"? That's to appease MariaDB, which would otherwise give
an error message about a derived table not having an alias */

/* What if we wanted to get all rentalCar records for the Corolla, the Focus, or
the Leaf?  We would use the "IN" keyword with an explicit tuple of car IDs: */

SELECT * FROM rentalCar INNER JOIN car ON rentalCar.carId = car.id WHERE car.id
IN (1, 2, 3);

/* Alternatively, we could use an explicit tuple of the model names: */
SELECT * FROM rentalCar INNER JOIN car ON rentalCar.carId = car.id WHERE car.model
IN ('Toyota Corolla', 'Nissan Leaf', 'Ford Focus');

/* If we *just* wanted the records for a single car, like the Toyota Corolla, we
could use "=" instead: */
SELECT * FROM rentalCar INNER JOIN car ON rentalCar.carId = car.id WHERE
car.model = 'Toyota Corolla';

/* What if we wanted the total dollar amount spent on rentals of Toyota Corollas? */
SELECT SUM(rentalCar.amountReceived) FROM rentalCar INNER JOIN car ON
rentalCar.carId = car.id WHERE car.model = 'Toyota Corolla';

/* What if we wanted the maximum spent? */
SELECT MAX(rentalCar.amountReceived) FROM rentalCar INNER JOIN car ON
rentalCar.carId = car.id WHERE car.model = 'Toyota Corolla';

/* What if we wanted the minimum spent? */
SELECT MIN(rentalCar.amountReceived) FROM rentalCar INNER JOIN car ON
rentalCar.carId = car.id WHERE car.model = 'Toyota Corolla';

/* What if we wanted the average spent? */
SELECT AVG(rentalCar.amountReceived) FROM rentalCar INNER JOIN car ON
rentalCar.carId = car.id WHERE car.model = 'Toyota Corolla';


/* What if we wanted to get the models, years, and IDs of all cars which have
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

/* Now, what does the car table look like?  Let's write a query to find any cars
for which the "lastService" field is incorrect (i.e., corresponding row in
servicing table isn't the date of the last service) */

/* We'll start by doing an equijoin between car and servicing: */

SELECT car.id, car.model, car.year, car.lastService, servicing.serviceDate FROM
car INNER JOIN servicing ON car.id = servicing.carId;

/* but this is not what we want, beacause the Tesla is not showing up; let's make this a LEFT JOIN */

SELECT car.id, car.model, car.year, car.lastService, servicing.serviceDate FROM
car LEFT JOIN servicing ON car.id = servicing.carId;

/* OK now the Tesla appears. Now we need to do a group by carId and then select
the max serviceDate: */

SELECT car.id, car.model, car.year, car.lastService, max(serviceDate) FROM car
LEFT JOIN servicing ON car.id = servicing.carId GROUP BY car.id;

/* Getting closer! Now we just need to select for rows in the aggregated virtual
table such that the max service date is not the same as the last service: */

SELECT car.id, car.model, car.year, car.lastService, max(serviceDate) AS maxServiceDate FROM
car LEFT JOIN servicing ON car.id = servicing.carId GROUP BY car.id HAVING
car.lastService <> maxServiceDate OR maxServiceDate IS NULL;

/* Are NULL values included in an average?  Let's test it */
/*  - start by looking at the state of the table rentalCar: */
SELECT * from rentalCar;

/*  - now do an average on the column "endTime", which contains a NULL */
SELECT AVG(endTime) FROM rentalCar;

/* Does this mean that the NULL was included in the average, or not? */

/* Now let's try COUNT(endTime). Will that include the NULL, do you think? */

SELECT COUNT(endTime) from rentalCar;

/* If we want to compute the number of distinct years for cars: */
SELECT COUNT(*) FROM (SELECT year from car group by year) AS T;

/* But there is an easier way to do this: */
SELECT COUNT(DISTINCT year) FROM car;

/* What if we wanted a simple SQL query to tell us if all the car models in the car
table are unique? It would be nice if we could just use the UNIQUE SQL predicate: */

SELECT CASE UNIQUE (car.model) WHEN TRUE THEN 'yes' ELSE 'no' END AS t FROM car;

/* But MariaDB doesn't seem to support tthe UNIQUE SQL predicate, so we have to use COUNT: */

SELECT CASE COUNT(DISTINCT car.model) WHEN COUNT(model) THEN 'yes' ELSE 'no' END AS t FROM car;

/* What if we wanted to get a count of number of times each person has rented
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

/* What if we wanted to order by the count in decreasing order? */
/*   - we would just add an ORDER BY clause; but we also need to label COUNT(*) */

SELECT customer.custName, car.model, COUNT(*) AS c FROM 
(((customer INNER JOIN rental ON customer.id = rental.custId) 
            INNER JOIN rentalCar ON rentalCar.rentalId = rental.id) 
            INNER JOIN car ON car.id = rentalCar.carId) 
GROUP BY customer.custName, car.model ORDER BY c DESC;

/* What if we wanted to make a new table custRentalCount containing that information? */

CREATE TABLE custRentalCount ( custName VARCHAR(256), model VARCHAR(32), count INT UNSIGNED );
INSERT INTO custRentalCount (custName, model, count)
               SELECT customer.custName, car.model, COUNT(*)
               FROM (((customer INNER JOIN rental ON customer.id = rental.custId)
               INNER JOIN rentalCar ON rentalCar.rentalId = rental.id)
               INNER JOIN car ON car.id = rentalCar.carId)
               GROUP BY customer.custName, car.model;

/* What value would this query produce? */

SELECT COUNT(*) FROM t1, t2;

/* What value would this query produce? */

SELECT COUNT(*) FROM t1 CROSS JOIN t2;

/* If we add a tuple to t2: */

ALTER TABLE t2 DROP FOREIGN KEY t2_ibfk_1;
ALTER TABLE t2 DROP PRIMARY KEY;
ALTER TABLE t2 MODIFY id INT UNSIGNED NULL;
ALTER TABLE t2 ADD FOREIGN KEY (id) REFERENCES t1(id);
INSERT INTO t2 (id, x) VALUES (NULL, 'g');

/* The natural equijoin still works as expected: */

SELECT * FROM t1 JOIN t2 USING (id);

/* But what if we do a LEFT JOIN? */

SELECT * FROM t1 LEFT JOIN t2 USING (id);

/* Note that this is the same as doing this: */

SELECT * FROM t1 LEFT OUTER JOIN t2 USING (id);

/* What if we do a RIGHT JOIN? */

SELECT * FROM t1 RIGHT JOIN t2 USING (id);

/* Note that this is the same as doing this: */

SELECT * FROM t1 RIGHT OUTER JOIN t2 USING (id);

/* What if we drop the PK on table 1, drop the foreign key constraint, and
add a row to t1 like this: */

ALTER TABLE t2 DROP FOREIGN KEY `t2_ibfk_1`;
ALTER TABLE t1 modify id int unsigned;
alter table t1 drop primary key;
ALTER TABLE t1 modify id int unsigned null;
insert into t1 (id, x) values (NULL, 'h');

/* Now what if we do a FULL OUTER JOIN? */

SELECT * FROM t1 FULL OUTER JOIN t2 USING (id);

/* Hmm, we get a syntax error.  This is because MariaDB/MySQL do not support
full outer join. But we can accomplish the same thing using UNION ALL: */

(SELECT * FROM t1 LEFT JOIN t2 USING (id)) UNION ALL
(SELECT * FROM t1 RIGHT JOIN t2 USING (id) WHERE t1.id IS NULL)
