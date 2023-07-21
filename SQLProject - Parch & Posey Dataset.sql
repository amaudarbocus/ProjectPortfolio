SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC
LIMIT 100;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id
LIMIT 100;

SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords');

SELECT *
FROM accounts
WHERE name NOT LIKE 'C%';

SELECT *
FROM accounts
WHERE name NOT LIKE '%one%';

SELECT *
FROM accounts
WHERE name NOT LIKE '%s';

SELECT name
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
	AND (primary_poc LIKE ('%ana%') OR primary_poc LIKE ('%Ana%') AND primary_poc NOT LIKE ('%eana%'));
	
	
SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w 
JOIN accounts a
	ON w.account_id = a.id
WHERE a.name = 'Walmart';


SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
	ON s.region_id = r.id
JOIN accounts a
	ON a.sales_rep_id = s.id
ORDER BY a.name;


SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
JOIN sales_reps s
	ON a.sales_rep_id = s.id
JOIN region r
	ON r.id = s.region_id;


SELECT r.name AS regionName, s.name AS salesRepsName, a.name as accountName
FROM accounts a
JOIN sales_reps s
	ON a.sales_rep_id = s.id
JOIN region r 
	ON (s.region_id = r.id AND r.name = 'Midwest')
ORDER BY a.name;

SELECT r.name AS regionName, s.name AS salesRepsName, a.name as accountName
FROM accounts a
JOIN sales_reps s
	ON (a.sales_rep_id = s.id AND s.name LIKE 'K%')
JOIN region r 
	ON (s.region_id = r.id AND r.name = 'Midwest')
ORDER BY a.name;


SELECT r.name AS regionName, s.name AS salesRepsName, a.name as accountName
FROM accounts a
JOIN sales_reps s
	ON (a.sales_rep_id = s.id AND s.name LIKE '% K%')
JOIN region r 
	ON (s.region_id = r.id AND r.name = 'Midwest')
ORDER BY a.name;

SELECT r.name as regionName, a.name as accountName, o.total_amt_usd/(o.total + 0.01) AS unitPrice
FROM orders o
JOIN accounts a
	ON (o.account_id = a.id AND o.standard_qty > 100)
JOIN sales_reps s
 ON a.sales_rep_id = s.id
JOIN region r
	ON s.region_id = r.id;
	


SELECT r.name as regionName, a.name as accountName, o.total_amt_usd/(o.total + 0.01) AS unitPrice
FROM orders o
JOIN accounts a
	ON (o.account_id = a.id AND o.standard_qty > 100 AND o.poster_qty > 50)
JOIN sales_reps s
 ON a.sales_rep_id = s.id
JOIN region r
	ON s.region_id = r.id
ORDER BY unitPrice;

SELECT r.name as regionName, a.name as accountName, o.total_amt_usd/(o.total + 0.01) AS unitPrice
FROM orders o
JOIN accounts a
	ON (o.account_id = a.id AND o.standard_qty > 100 AND o.poster_qty > 50)
JOIN sales_reps s
 ON a.sales_rep_id = s.id
JOIN region r
	ON s.region_id = r.id
ORDER BY unitPrice DESC;

SELECT DISTINCT a.name as accountName, w.channel
FROM web_events w
JOIN accounts a
	ON (w.account_id = a.id AND a.id = 1001);

	
	
SELECT o.occurred_at, a.name AS accountName, o.total AS orderTotal, o.total_amt_usd as OrderTotalAmtUsd
FROM orders o
JOIN accounts a
	ON (o.account_id = a.id AND (o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'))
ORDER BY o.occurred_at DESC;


SELECT SUM(poster_qty) AS total_poster_qty
FROM orders;

SELECT SUM(standard_qty) AS total_standard_qty
FROM orders;

SELECT SUM(total_amt_usd) AS total_total_amt_usd
FROM orders;

SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss_amt 
FROM orders

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_unit_price
FROM orders;

SELECT MIN(occurred_at)
FROM orders;

SELECT occurred_at
FROM orders 
ORDER BY occurred_at
LIMIT 1;

SELECT MAX(occurred_at)
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss, 
        AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd, 
        AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders;


SELECT a.name AS accName, AVG(standard_qty) avgStandardQty, AVG(gloss_qty) avgGlossQty, AVG(poster_qty) avgPosterQty
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
GROUP BY accName;

SELECT a.name AS accName, AVG(standard_amt_usd) avgStandardAmt, AVG(gloss_amt_usd) avgGlossAmt, AVG(poster_amt_usd) avgPosterAmt
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
GROUP BY accName;

SELECT s.name AS salesRep, w.channel, COUNT(*) AS numOfOccurrences
FROM web_events w
JOIN accounts a
	ON w.account_id = a.id
JOIN sales_reps s
	ON a.sales_rep_id = s.id
GROUP BY salesRep, channel
ORDER BY numOfOccurrences DESC;


SELECT r.name AS regionName, w.channel, COUNT(*) AS numOfOccurrences
FROM web_events w
JOIN accounts a
	ON w.account_id = a.id
JOIN sales_reps s
	ON a.sales_rep_id = s.id
JOIN region r
	ON r.id = s.region_id
GROUP BY regionName, channel
ORDER BY numOfOccurrences DESC;

SELECT DISTINCT a.name AS accName, r.name AS regionName, COUNT(*) as countRegionPerAcc
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
JOIN sales_reps s
	ON s.id = a.sales_rep_id
JOIN region r
	ON s.region_id = r.id
GROUP BY accName, regionName;