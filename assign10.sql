-- DIMENSION TABLE FOR THE CUSTOMER:
---------------------------------------------
CREATE TABLE reporting_schema.dim_customer(
	customer_id INTEGER, 
	first_name TEXT,
	last_name TEXT
);
INSERT INTO reporting_schema.dim_customer(customer_id, first_name, last_name)
SELECT 
	customer_id, 
	first_name, 
	last_name
FROM public.customer

-- FACTS TABLE FOR THE RENTALS ACTION:
--------------------------------------
CREATE TABLE reporting_schema.fct_rentals(
	rental_id INT, 
	customer_id INT, 
	rental_date DATE, 
	return_date DATE, 
	rental_fee NUMERIC
);
INSERT INTO reporting_schema.fct_rentals(rental_id, customer_id, rental_date, return_date, rental_fee)

SELECT 
	se_rental.rental_id, 
	se_rental.customer_id, 
	se_rental.rental_date, 
	se_rental.return_date, 
	se_payment.amount as rental_fee
FROM public.rental as se_rental
INNER JOIN public.payment as se_payment
	ON se_rental.rental_id = se_payment.rental_id 

-- AGGREGATE TABLE 
------------------
CREATE TABLE reporting_schema.agg_customer(
	customer_id INT PRIMARY KEY,
	total_movies_rented INT, 
	total_paid NUMERIC,
	average_rental_duration FLOAT
);
INSERT INTO reporting_schema.agg_customer(customer_id, total_movies_rented, total_paid, average_rental_duration)
SELECT
	se_rental.customer_id,
	COUNT(se_rental.rental_id) as total_movies_rented, 
	SUM(se_payment.amount) AS total_paid,
	ROUND(AVG(EXTRACT(DAY FROM return_date - rental_date)*24 
			  + EXTRACT(HOUR FROM return_date - rental_date)), 2) AS average_rental_duration
	FROM public.rental as se_rental
	INNER JOIN public.payment as se_payment
	ON se_rental.customer_id = se_payment.customer_id
	GROUP BY
		se_rental.customer_id