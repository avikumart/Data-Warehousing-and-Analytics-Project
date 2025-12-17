USE instacart;

# Query 1: List all orders in the DB in order they were created. 
# ------------------------------------------------------------------------------

SELECT * FROM ORDERS
ORDER BY OrderID;

# Query 2: Show the Store details for each product sold
# ------------------------------------------------------------------------------

SELECT ps.ProductID, p.Name AS ProductName, ps.StoreID, s.StoreName, s.Location
FROM PRODUCTSTORE ps JOIN PRODUCTS p USING(ProductID)
	JOIN STORES s USING(StoreID)
ORDER BY ps.StoreID, ps.ProductID;



# Query 3: Show all customers and their last order, including ones that have not ordered. 
# 			To check if there is a delivery complain regarding last order (Refund or Cancel)
# ------------------------------------------------------------------------------
# gets order count of all customers (not related to query)
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(o.OrderID) AS OrderCount
FROM CUSTOMERS c LEFT JOIN ORDERS o USING(CustomerID)
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY c.CustomerID;

# Query that answers the Question
SELECT c.CustomerID, c.FirstName, c.LastName, o.OrderID, o.OrderStatus, o.CreatedAt
FROM CUSTOMERS c LEFT JOIN ORDERS o USING(CustomerID)
WHERE o.CreatedAt = ( SELECT MAX(o2.CreatedAt) FROM ORDERS o2 
						WHERE o2.CustomerID = c.CustomerID )
ORDER BY c.CustomerID;

# Query 4: Find the Order with highest total amount
# ------------------------------------------------------------------------------
SELECT * FROM ORDERS;

SELECT o.OrderID, o.CustomerID, p.Amount, o.OrderStatus
FROM ORDERS o JOIN PAYMENTS p USING(PaymentID)
ORDER BY o.OrderID;

# Query that answers the Question
SELECT o.OrderID, o.CustomerID, p.Amount, o.OrderStatus
FROM ORDERS o JOIN PAYMENTS p USING(PaymentID)
WHERE p.Amount = ( SELECT MAX(Amount) FROM PAYMENTS)
ORDER BY o.OrderID;

# Query 5: List all Customers with reviews
# see number of reviews per customer
SELECT c.CustomerID, c.FirstName, c.LastName, c.CustomerEmail, COUNT(ReviewID) as ReviewCount
FROM CUSTOMERS c LEFT JOIN REVIEWS r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID,c.FirstName,c.LastName,c.CustomerEmail
ORDER BY c.CustomerID;
# Query that answers the question
SELECT c.CustomerID, c.FirstName, c.LastName, c.CustomerEmail, COUNT(reviewID) as ReviewCount
FROM CUSTOMERS c 
WHERE c.CustomerID IN ( SELECT DISTINCT CustomerID FROM REVIEWS)
ORDER BY c.CustomerID; 






# Query 6: For each product, how many times it was added to orders and what is the total number sold. 
# ------------------------------------------------------------------------------
SELECT * FROM ORDERITEMS;
SELECT * FROM ORDERS;

# note that order 10 has a failed order, since there was no item added, hence its in Pending state
# but contains payment and other details 
SELECT oi.OrderID,oi.ProductID,p.Name AS ProductName,oi.Quantity
FROM ORDERITEMS oi JOIN PRODUCTS p USING(ProductID)
WHERE oi.OrderID IN (1, 10);

# Query that answers the question
SELECT p.ProductID, p.Name AS ProductName, 
	COUNT(oi.OrderItemID) AS NumOrderLines, SUM(oi.Quantity) AS TotalUnitsSold
FROM PRODUCTS p LEFT JOIN ORDERITEMS oi USING(ProductID)
GROUP BY p.ProductID, p.Name
ORDER BY p.ProductID;


# Query 7: Find customers who have never created a cart (for further marketing targets)
# ------------------------------------------------------------------------------

SELECT c.CustomerID,c.FirstName,c.LastName,c.CustomerEmail
FROM CUSTOMERS c 
WHERE c.CustomerID NOT IN (SELECT DISTINCT CustomerID FROM CART)
ORDER BY c.CustomerID;

# We do not have such customers yet

# Query 8: Get a list of cities covered by operations of instacart2 based on customer and store locations
# ------------------------------------------------------------------------------
WITH CitySource AS (
	SELECT DISTINCT a.City, 'CUSTOMER_ADDRESS' AS Source
	FROM ADDRESSES a JOIN CUSTOMERADDRESS ca USING(AddressID)
	UNION
	SELECT DISTINCT a.City, 'STORE_ADDRESS' AS Source
	FROM ADDRESSES a JOIN STORES s USING(AddressID)
)
SELECT City FROM CitySource
GROUP BY City
ORDER BY City;

# Query 9: Find shoppers who currently have no deliveries assigned (Capacity planning)
# ------------------------------------------------------------------------------
SELECT * FROM SHOPPERS;

# Query that answers the question
SELECT s.DeliveryAgentID, s.Name, s.Contact, s.CurrentLocation
FROM SHOPPERS s 
WHERE NOT EXISTS ( SELECT 1 FROM DELIVERYSHOPPER ds
				WHERE ds.DeliveryAgentID = s.DeliveryAgentID
)
ORDER BY s.DeliveryAgentID;

# report all our shoppers have deliveries assigned (Full Capacity)

# Query 10: List all orders that have at least one reviewed product 
# ------------------------------------------------------------------------------
SELECT * FROM REVIEWS; # Every customer has a review


# Query that answers the question. 
SELECT DISTINCT o.OrderID, o.CustomerID, o.OrderStatus, o.CreatedAt
FROM ORDERS o
WHERE o.OrderID IN (
    SELECT oi.OrderID FROM ORDERITEMS oi
    JOIN REVIEWS r USING(ProductID)
    WHERE r.Rating IS NOT NULL 
)
ORDER BY o.OrderID;
