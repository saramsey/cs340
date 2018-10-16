/* How would we show the table structure of the `car` table? */

/*   if we are in the mysql client or SQL Pro: */

    DESCRIBE car;
    
/*   if we are in phpMyAdmin: */

    SHOW CREATE TABLE car;

/* What if we want to list all of the columns for all of the rows in the `car` table? */

    SELECT * FROM car;

/* What if we want to list only the car IDs and the model columns? */

    SELECT id, model FROM car;

/* What if we want to count the number of rows in the cars table? */

   SELECT COUNT(*) FROM car;
   
/* What if we want to list all of the cars sorted by the date they were last serviced? */

   SELECT * FROM car ORDER BY lastService;

/* What if we want to list all of the cars sorted by the price in descending order? */

   SELECT * FROM car ORDER BY price DESC;

/* What if we want to list only the cars whose price was under 40k? */

   SELECT * FROM car WHERE price < 40000.0;
   
/* What if we want to list only the unique model years of cars whose price was under 40k? */

   SELECT DISTINCT year FROM car WHERE price < 40000.0;

/* What if we want to list the count of cars from each model year? */

   SELECT year, COUNT(*) FROM car GROUP BY year;

/* What if we want to get the minimum car price? */

   SELECT min(price) FROM car;

/* What if we want to get the maximum car price for the 2018 model year? */

   SELECT max(price) FROM car WHERE year = 2018;

/* What if we wanted a list of all customers and the dates they have rented cars? */

   SELECT customer.custName, rental.rentalDate FROM customer, rental WHERE rental.custId = customer.id;

/* What if we wanted a count of the number of times each customer has rented a car? */

   SELECT customer.custName, COUNT(*) FROM customer, rental WHERE rental.custId = customer.id GROUP BY customer.custName;

/* What if we wanted that same information but sorted by count in decreasing order? */

   SELECT customer.custName, COUNT(*) FROM customer, rental WHERE rental.custId = customer.id GROUP BY customer.custName ORDER BY customer.custName DESC;
   
/* What if we want to get the unique pairs of names of all customers and the models of cars that they rented? */

   SELECT DISTINCT customer.custName, car.model FROM car, customer, rental, rentalCar WHERE customer.id = rental.custId AND rentalCar.rentalId = rental.id AND car.id = rentalCar.carId;

/* What if we wanted to also get a count of number of times each person has rented each type of car? */

   SELECT customer.custName, car.model, COUNT(*) FROM car, customer, rental, rentalCar WHERE customer.id = rental.custId AND rentalCar.rentalId = rental.id AND car.id = rentalCar.carId GROUP BY customer.custName, car.model;

/* What if we wanted to make a new table custRentalCount containing that information? */

   CREATE TABLE custRentalCount ( custName VARCHAR(256), model VARCHAR(32), count INT UNSIGNED );
   INSERT INTO custRentalCount (custName, model, count)  SELECT customer.custName, car.model, COUNT(*) FROM car, customer, rental, rentalCar WHERE customer.id = rental.custId AND rentalCar.rentalId = rental.id AND car.id = rentalCar.carId GROUP BY customer.custName, car.model;

/* What if we wanted to make a table of names of people who were either drivers or customers? */

   (SELECT DISTINCT custName AS name FROM customer) UNION (SELECT DISTINCT driverName AS name FROM driver);
 
