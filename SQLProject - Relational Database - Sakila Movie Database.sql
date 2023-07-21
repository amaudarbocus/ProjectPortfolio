SELECT CONCAT(a.first_name, a.last_name) AS full_name, title, description,length
FROM film f
JOIN film_actor
	ON f.film_id = film_actor.film_id
JOIN actor a 
	ON a.actor_id = film_actor.actor_id;

/*
Question 1: Write a query that creates a table with 4 columns: actor's full name, 
film title, length of movie, and a column name "filmlen_groups" that classifies 
movies based on their length. Filmlen_groups should include 4 categories: 
1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.
*/

SELECT  full_name, 
		filmtitle,
		filmlen,
		CASE WHEN filmlen <= 60 THEN '1 hour or less'
		WHEN filmlen > 60 AND filmlen <= 120 THEN 'Between 1-2 hours'
		WHEN filmlen > 120 AND filmlen <= 180 THEN 'Between 2-3 hours'
		ELSE 'More than 3 hours' END AS filmlen_groups

FROM 
	(SELECT a.first_name,
			a.last_name,
			a.first_name || ' ' || a.last_name AS full_name,
			f.title filmtitle
			f.length filmlen
	FROM film_actor fa
	JOIN actor a
	ON fa.actor_id = a.actor_id
	JOIN film f
	ON f.film_id = fa.film_id
	) t1;

/*
Question 2: Write a query you to create a count of movies in each of the 
4 filmlen_groups: 1 hour or less, Between 1-2 hours, Between 2-3 hours, 
More than 3 hours.
*/

SELECT  DISTINCT(filmlen_groups),
		COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat

(SELECT  title,
	length,
	CASE when length <=60 THEN '1 hour or less'
	WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
	WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
	ELSE 'More than 3 hours' END AS filmlen_groups
FROM film) t1

ORDER BY filmlen_groups;

/*
PROJECT starts here.
Question set 1
Question 1
*/

SELECT film_title, category_name, COUNT(*) 
FROM

(SELECT f.film_id, f.title AS film_title, c.name AS category_name
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id) t1

JOIN inventory i
ON i.film_id = t1.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY film_title, category_name
ORDER BY category_name, film_title;

/*
Question 2
*/



SELECT title, name, rental_duration,
		NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM 

(SELECT f.title AS title, c.name AS name, rental_duration
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id) t1

WHERE name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');


/*
Question 3
*/

SELECT name, standard_quartile, COUNT(*)
FROM


(SELECT title, name, rental_duration,
		NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM 

(SELECT f.title AS title, c.name AS name, rental_duration
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id) t1

WHERE name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t2

GROUP BY 1,2
ORDER BY 1,2;

/* Question set 2
Question 1
*/
SELECT  t1.rental_month,
		t1.rental_year,
		t1.store_id,
		COUNT(*) AS count_rentals

FROM

(SELECT  DATE_PART('month', rental_date) AS rental_month,
		DATE_PART('year', rental_date) AS rental_year,
		sto.store_id,
		r.rental_id
FROM store sto
JOIN staff sta
ON sto.store_id = sta.store_id
JOIN rental r
ON sta.staff_id = r.staff_id
ORDER BY rental_date) t1

GROUP BY 1,2,3
ORDER BY 4 DESC;

/*
Question 2
*/

SELECT  DATE_TRUNC('month', payment_date) AS pay_mon,
		first_name || ' ' || last_name AS fullname,
		COUNT(*) AS pay_countpermon,
		SUM(amount) AS pay_amount
FROM

((SELECT t1.customer_id, SUM(amount) AS total_amount_paid
FROM 
(SELECT p.payment_id, p.customer_id, p.amount, p.payment_date
FROM payment p
WHERE DATE_PART('year',payment_date) = 2007) t1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)t2

JOIN 

(SELECT p.payment_id, p.customer_id, p.amount,p.payment_date, c.first_name,c.last_name
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
WHERE DATE_PART('year',payment_date) = 2007
)t3

ON t2.customer_id = t3.customer_id)t4

GROUP BY 1,2
ORDER BY 2,1;

/*
Question 3
*/
SELECT LEAD(pay_amount) OVER (PARTITION BY fullname ORDER BY payment_date) - pay_amount AS lead_difference
FROM 

(SELECT  DATE_TRUNC('month', payment_date),
		first_name || ' ' || last_name AS fullname,
		COUNT(*) AS pay_countpermon,
		SUM(amount) AS pay_amount,
FROM

((SELECT t1.customer_id, SUM(amount) AS total_amount_paid
FROM 
(SELECT p.payment_id, p.customer_id, p.amount, p.payment_date
FROM payment p
WHERE DATE_PART('year',payment_date) = 2007) t1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)t2

JOIN 

(SELECT p.payment_id, p.customer_id, p.amount,p.payment_date, c.first_name,c.last_name
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
WHERE DATE_PART('year',payment_date) = 2007
)t3

ON t2.customer_id = t3.customer_id)t4

GROUP BY 1,2
ORDER BY 2,1)t5;