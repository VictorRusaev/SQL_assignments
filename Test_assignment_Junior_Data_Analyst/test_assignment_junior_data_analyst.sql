USE test_wib_hh;

/*
You have SQL database with following tables:
1) Users(userId, age)
2) Purchases (purchaseId, userId, itemId, date)
3) Items (itemId, price).

Create SQL requests for following purpose:

А) average cost which spent following users:
- users with age between 18 and 25 inclusive
- users with age between 26 and 35 inclusive
B) in which month income from users 35+ is highest
C) which item brings the highest income into the last year turnover
D) top-3 items by income and their proportion from total income for any year
*/

CREATE TABLE users(
userId SERIAL PRIMARY KEY,
age INT NOT NULL
);

CREATE TABLE purchases(
purchaseId SERIAL PRIMARY KEY, 
userId BIGINT UNSIGNED, 
itemId BIGINT UNSIGNED, 
purchaseDate DATE NOT NULL
);

CREATE TABLE items(
itemId SERIAL PRIMARY KEY, 
price FLOAT NOT NULL 
);

INSERT INTO users (age)
VALUES 
(18), (20), (36), (27), (31), (22), (31), (18), (24), (27);

INSERT INTO users (age)
VALUES
(35), (37);

INSERT INTO items(price)
VALUES
(100.50), (250.70), (320.90);
INSERT INTO items(price)
VALUES
(70.40), (540.20);

INSERT INTO purchases(userId, itemId, purchaseDate)
VALUES
(1, 1, '2023-01-12'), (2, 2, '2023-01-12'), (3, 3, '2023-01-12'),
(4, 1, '2023-01-13'), (5, 3, '2023-01-17'), (6, 2, '2022-12-20'),
(7, 2, '2022-11-11'), (8, 1, '2022-11-17'), (9, 3, '2022-12-12'),
(10, 3, '2023-02-10'), (10, 2, '2023-02-28'), (9, 1, '2023-03-14'),
(8, 2, '2023-03-18'), (7, 1, '2023-04-19'), (6, 3, '2023-04-20'),
(5, 1, '2023-05-10'), (4, 2, '2023-05-15'), (3, 3, '2023-05-20'),
(2, 3, '2023-06-11'), (1, 2, '2023-06-19');

INSERT INTO purchases(userId, itemId, purchaseDate)
VALUES
(11, 2, '2023-06-20'), (12, 1, '2023-06-20');
INSERT INTO purchases(userId, itemId, purchaseDate)
VALUES
(12, 4, '2023-06-20'), (11, 5, '2023-06-20');

ALTER TABLE purchases
ADD FOREIGN KEY (userId) REFERENCES users (userId);

ALTER TABLE purchases
ADD FOREIGN KEY (itemId) REFERENCES items (itemId);

/*
А) average cost which spent following users:
- users with age between 18 and 25 inclusive
*/
SELECT MONTHNAME(purchaseDate) as 'Purchase month', ROUND(AVG(price), 2) as 'Average cost'
FROM (SELECT p.userId, i.itemId, age, price, purchaseDate FROM purchases p
LEFT JOIN users u 
ON p.userId = u.userId
LEFT JOIN items i
ON p.itemId = i.itemId) AS full_purchases
WHERE age BETWEEN 18 and 25
GROUP BY MONTHNAME(purchaseDate);

-- users with age between 26 and 35 inclusive
SELECT MONTHNAME(purchaseDate) as 'Purchase month', ROUND(AVG(price), 2) as 'Average cost' 
FROM (SELECT p.userId, i.itemId, age, price, purchaseDate FROM purchases p
LEFT JOIN users u 
ON p.userId = u.userId
LEFT JOIN items i
ON p.itemId = i.itemId) AS full_purchases
WHERE age BETWEEN 26 and 35
GROUP BY MONTHNAME(purchaseDate);

-- B) in which month income from users 35+ is highest
SELECT MONTHNAME(purchaseDate) as 'Purchase month', ROUND(AVG(price), 2) as 'Maximum income'
FROM (SELECT p.userId, i.itemId, age, price, purchaseDate FROM purchases p
LEFT JOIN users u 
ON p.userId = u.userId
LEFT JOIN items i
ON p.itemId = i.itemId) AS full_purchases
WHERE age >= 35
GROUP BY MONTHNAME(purchaseDate);

-- C) which item brings the highest income into the last year turnover

SELECT i.itemId as 'Item', SUM(price) as 'Total income' FROM purchases p
LEFT JOIN items i
ON p.itemId = i.itemId
WHERE YEAR(p.purchaseDate) = 2022
GROUP BY i.itemId
ORDER BY SUM(price) DESC;


-- D) top-3 items by income and their proportion from total income for any year

SELECT *,
	ROUND (Income * 100 / 
    (SELECT SUM(Income) FROM (SELECT i.itemId as 'Item', 
		SUM(ROUND(price, 2)) as 'Income'
	FROM purchases p
	LEFT JOIN items i
	ON p.itemId = i.itemId
	WHERE YEAR(p.purchaseDate) = 2023
	GROUP BY i.itemId) as top_2023), 2) as Percent
FROM 
	(SELECT i.itemId as 'Item', 
	SUM(ROUND(price, 2)) as 'Income'
	FROM purchases p
	LEFT JOIN items i
	ON p.itemId = i.itemId
	WHERE YEAR(p.purchaseDate) = 2023
	GROUP BY i.itemId) as top_2023
GROUP BY Item
ORDER BY Percent DESC
LIMIT 3;

