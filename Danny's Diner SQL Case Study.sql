/* --------------------
   Case Study Questions - SREEKALA MENON
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	S.CUSTOMER_ID, 
    SUM(M.PRICE) AS TOTAL_AMOUNT
FROM dannys_diner.SALES S
INNER JOIN dannys_diner.MENU M
USING (PRODUCT_ID)
GROUP BY S.CUSTOMER_ID
ORDER BY S.CUSTOMER_ID;

-- 2. How many days has each customer visited the restaurant?

SELECT 
	CUSTOMER_ID,
	COUNT(DISTINCT ORDER_DATE)
FROM dannys_diner.SALES
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;

-- 3. What was the first item from the menu purchased by each customer?

WITH ITEM AS(
  	SELECT
		CUSTOMER_ID,
    	PRODUCT_ID,
    	ORDER_DATE,
    	DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS RN
	FROM dannys_diner.SALES
  	)
    
SELECT 
	I.CUSTOMER_ID,
    I.PRODUCT_ID,
    M.PRODUCT_NAME
FROM ITEM I
INNER JOIN dannys_diner.MENU M
USING(PRODUCT_ID)
WHERE RN =1
GROUP BY I.CUSTOMER_ID, I.PRODUCT_ID, M.PRODUCT_NAME
ORDER BY I.CUSTOMER_ID
;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	PRODUCT_ID, 
    COUNT(PRODUCT_ID) AS CNT
FROM dannys_diner.SALES
GROUP BY PRODUCT_ID
ORDER BY CNT DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

WITH PRODUCTS AS(  
          SELECT 
              CUSTOMER_ID, 
              PRODUCT_ID, 
              COUNT(PRODUCT_ID),
              RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY COUNT(PRODUCT_ID) DESC) AS RNK
          FROM dannys_diner.SALES
          GROUP BY CUSTOMER_ID, PRODUCT_ID
			)
            
SELECT 
	P.CUSTOMER_ID, 
    ARRAY_AGG(P.PRODUCT_ID) AS PRODUCT_ID,
    ARRAY_AGG(M.PRODUCT_NAME) AS PRODUCTS
FROM PRODUCTS P
INNER JOIN dannys_diner.MENU M 
USING(PRODUCT_ID)
WHERE RNK =1
GROUP BY P.CUSTOMER_ID
ORDER BY P.CUSTOMER_ID;

-- 6. Which item was purchased first by the customer after they became a member?

WITH ORDERS AS(
              SELECT
                  S.CUSTOMER_ID, 
                  S.PRODUCT_ID, 
                  S.ORDER_DATE, 
                  M.JOIN_DATE,
                  ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RN
              FROM dannys_diner.SALES S
              INNER JOIN dannys_diner.MEMBERS M
              USING(CUSTOMER_ID)
              WHERE S.ORDER_DATE >= M.JOIN_DATE
              )
              
SELECT 
	O.CUSTOMER_ID,
    O.PRODUCT_ID,
    M.PRODUCT_NAME
FROM ORDERS O
INNER JOIN dannys_diner.MENU M
USING(PRODUCT_ID)
WHERE RN =1
ORDER BY CUSTOMER_ID;

-- 7. Which item was purchased just before the customer became a member?

WITH ORDERS AS(
              SELECT
                  S.CUSTOMER_ID, 
                  S.PRODUCT_ID, 
                  S.ORDER_DATE, 
                  M.JOIN_DATE,
                  ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY S.ORDER_DATE DESC) AS RN
              FROM dannys_diner.SALES S
              INNER JOIN dannys_diner.MEMBERS M
              USING(CUSTOMER_ID)
              WHERE S.ORDER_DATE < M.JOIN_DATE
              )
              
SELECT 
	O.CUSTOMER_ID,
    O.PRODUCT_ID,
    M.PRODUCT_NAME
FROM ORDERS O
INNER JOIN dannys_diner.MENU M
USING(PRODUCT_ID)
WHERE RN =1
ORDER BY CUSTOMER_ID;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
	M.CUSTOMER_ID, 
    COUNT(S.PRODUCT_ID) AS TOTAL_ITEMS_PURCHASED,
    SUM(ME.PRICE) AS TOTAL_AMOUNT_SPENT
FROM dannys_diner.MEMBERS M
INNER JOIN dannys_diner.SALES S
USING(CUSTOMER_ID)
INNER JOIN dannys_diner.MENU ME
USING(PRODUCT_ID)
WHERE S.ORDER_DATE < M.JOIN_DATE
GROUP BY M.CUSTOMER_ID
ORDER BY M.CUSTOMER_ID
;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
	S.CUSTOMER_ID,
    --- SUSHI GETS PRICE*20 POINT AND OTHERS GET PRICE*10
    SUM(CASE WHEN PRODUCT_ID =1 THEN M.PRICE*20 ELSE M.PRICE*10 END) AS POINTS
FROM dannys_diner.SALES S
INNER JOIN dannys_diner.MENU M
USING(PRODUCT_ID)
GROUP BY S.CUSTOMER_ID
ORDER BY S.CUSTOMER_ID;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    S.CUSTOMER_ID, 
    SUM(CASE WHEN (S.PRODUCT_ID = 1 OR S.ORDER_DATE BETWEEN ME.JOIN_DATE AND ME.JOIN_DATE+7) THEN M.PRICE*20 ELSE M.PRICE*10 END) AS POINTS
FROM dannys_diner.SALES S
INNER JOIN dannys_diner.MENU M
USING(PRODUCT_ID)
INNER JOIN dannys_diner.MEMBERS ME
ON S.CUSTOMER_ID = ME.CUSTOMER_ID
WHERE S.ORDER_DATE BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY S.CUSTOMER_ID;


