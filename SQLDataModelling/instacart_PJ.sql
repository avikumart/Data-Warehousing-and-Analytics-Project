CREATE DATABASE instacart;
USE instacart;
CREATE TABLE CUSTOMERS (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    CustomerEmail VARCHAR(255) UNIQUE,
    Age INT,
    is_verified BIT,
    BirthDay INT,
    BirthMonth INT,
    BirthYear INT
);


CREATE TABLE CATEGORIES (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100),
    CategoryDescription TEXT,
    ImageUrl VARCHAR(255)
);


CREATE TABLE ADDRESSES (
    AddressID INT PRIMARY KEY,
    PinCode VARCHAR(20),
    Num_street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);


CREATE TABLE SHOPPERS (
    DeliveryAgentID INT PRIMARY KEY,
    Name VARCHAR(100),
    Contact VARCHAR(50),
    CurrentLocation VARCHAR(255),
    DeliveryMode VARCHAR(50),
    Email VARCHAR(255) UNIQUE
);


CREATE TABLE PHONENUMBER (
    PhoneID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    PhoneNumber VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);


CREATE TABLE CART (
    CartID INT PRIMARY KEY,
    Cart_Status VARCHAR(50),
    Timestamp DATETIME,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);

CREATE TABLE PRODUCTS (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(255),
    Description TEXT,
    Price DECIMAL(10, 2),
    CategoryID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORIES(CategoryID)
);


CREATE TABLE STORES (
    StoreID INT PRIMARY KEY,
    Location VARCHAR(255),
    StoreName VARCHAR(100),
    StoreDescription TEXT,
    AddressID INT NOT NULL,
    FOREIGN KEY (AddressID) REFERENCES ADDRESSES(AddressID)
);

CREATE TABLE CUSTOMERADDRESS (
    CustomerID INT NOT NULL,
    AddressID INT NOT NULL,
    PRIMARY KEY (CustomerID, AddressID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (AddressID) REFERENCES ADDRESSES(AddressID)
);


CREATE TABLE PRODUCTDETAILS (
    ProductID INT PRIMARY KEY,
    ProductWeight DECIMAL(10, 2),
    ProductHeight DECIMAL(10, 2),
    ProductLength DECIMAL(10, 2),
    ProductDiameter DECIMAL(10, 2),
    ProductInventory INT,
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);


CREATE TABLE PRODUCTSTORE (
    ProductID INT NOT NULL,
    StoreID INT NOT NULL,
    PRIMARY KEY (ProductID, StoreID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID),
    FOREIGN KEY (StoreID) REFERENCES STORES(StoreID)
);


CREATE TABLE REVIEWS (
    ReviewID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT,
    Comments TEXT,
    Timestamp DATETIME,
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);


CREATE TABLE CARTITEMS (
    CartItemID INT PRIMARY KEY,
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    Timestamp DATETIME,
    FOREIGN KEY (CartID) REFERENCES CART(CartID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);


CREATE TABLE PAYMENTS (
    PaymentID INT PRIMARY KEY,
    Amount DECIMAL(10, 2),
    Currency VARCHAR(10),
    PaymentDay INT,
    PaymentMonth INT,
    PaymentYear INT,
    Quantity INT,
    ModeOfPayment VARCHAR(50),
    PaymentMethod VARCHAR(50),
    OrderID INT -- Foreign Key will be added *after* ORDERS table is created
);


CREATE TABLE DELIVERIES (
    DeliveryID INT PRIMARY KEY,
    Actual_Delivery_Time DATETIME,
    Estimated_Delivery_Time DATETIME,
    DeliveryDate DATETIME,
    DeliveryMonth INT,
    DeliveryYear INT,
    DeliveryInstructions TEXT,
    DeliveryAddress VARCHAR(255),
    Delivery_Status VARCHAR(50),
    AddressID INT NOT NULL,
    OrderID INT, -- Foreign Key will be added *after* ORDERS table is created
    FOREIGN KEY (AddressID) REFERENCES ADDRESSES(AddressID)
);


CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY,
    OrderDay INT,
    OrderMonth INT,
    OrderYear INT,
    OrderStatus VARCHAR(50),
    CreatedAt DATETIME,
    PaymentID INT NOT NULL,
    DeliveryID INT NOT NULL,
    CustomerID INT NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES PAYMENTS(PaymentID),
    FOREIGN KEY (DeliveryID) REFERENCES DELIVERIES(DeliveryID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);


CREATE TABLE CUSTOMERCARTPAY (
    CustomerID INT NOT NULL,
    PaymentID INT NOT NULL,
    CartID INT NOT NULL,
    PRIMARY KEY (CustomerID, PaymentID, CartID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (PaymentID) REFERENCES PAYMENTS(PaymentID),
    FOREIGN KEY (CartID) REFERENCES CART(CartID)
);


CREATE TABLE DELIVERYSHOPPER (
    DeliveryID INT NOT NULL,
    DeliveryAgentID INT NOT NULL,
    PRIMARY KEY (DeliveryID, DeliveryAgentID),
    FOREIGN KEY (DeliveryID) REFERENCES DELIVERIES(DeliveryID),
    FOREIGN KEY (DeliveryAgentID) REFERENCES SHOPPERS(DeliveryAgentID)
);


CREATE TABLE ORDERITEMS (
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);



INSERT INTO ADDRESSES (AddressID, PinCode, Num_street, City, State, Country) VALUES
(1, '85004', '1234 N Central Ave', 'Phoenix', 'AZ', 'USA'),
(2, '85282', '800 E Southern Ave', 'Tempe', 'AZ', 'USA'),
(3, '85254', '6501 E Greenway Pkwy', 'Scottsdale', 'AZ', 'USA'),
(4, '85210', '456 S Center St', 'Mesa', 'AZ', 'USA'),
(5, '85301', '5800 W Glenn Dr', 'Glendale', 'AZ', 'USA'),
(6, '85286', '2700 E Germann Rd', 'Chandler', 'AZ', 'USA'),
(7, '85234', '2502 E Guadalupe Rd', 'Gilbert', 'AZ', 'USA'),
(8, '85345', '8350 N 83rd Ave', 'Peoria', 'AZ', 'USA'),
(9, '85374', '16000 N Civic Center Plaza', 'Surprise', 'AZ', 'USA'),
(10, '85719', '1020 E University Blvd', 'Tucson', 'AZ', 'USA');


INSERT INTO CUSTOMERS (CustomerID, FirstName, LastName, CustomerEmail, Age, is_verified, BirthDay, BirthMonth, BirthYear) VALUES
(1, 'Asha', 'Rao', 'asha.rao@example.com', 29, 1, 12, 5, 1996),
(2, 'Vishnu', 'Panyam', 'vishnu.p@example.com', 32, 1, 3, 9, 1993),
(3, 'Emily', 'Chen', 'emily.c@example.com', 27, 1, 15, 7, 1998),
(4, 'Miguel', 'Santos', 'miguel.s@example.com', 40, 1, 8, 2, 1985),
(5, 'Sara', 'Nair', 'sara.nair@example.com', 23, 1, 10, 10, 2002),
(6, 'Reena', 'Singh', 'reena.singh@example.com', 28, 0, 7, 5, 1997),
(7, 'Tom', 'Lee', 'tom.lee@example.com', 34, 1, 21, 4, 1991),
(8, 'Priya', 'Sharma', 'priya.sharma@example.com', 30, 1, 3, 1, 1995),
(9, 'David', 'Miller', 'david.miller@example.com', 31, 1, 14, 12, 1993),
(10, 'Angela', 'Kaur', 'angela.kaur@example.com', 26, 0, 2, 6, 1999);

INSERT INTO CATEGORIES (CategoryID, CategoryName, CategoryDescription, ImageUrl) VALUES
(1, 'Electronics', 'Phones, laptops, gadgets', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=400&q=80'),
(2, 'Home & Kitchen', 'Appliances and kitchenware', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80'),
(3, 'Fitness', 'Sports & fitness gear', 'https://images.unsplash.com/photo-1519864604355-6f8e795e8af8?auto=format&fit=crop&w=400&q=80'),
(4, 'Grocery', 'Daily groceries', 'https://images.unsplash.com/photo-1464306076886-debede13a44b?auto=format&fit=crop&w=400&q=80'),
(5, 'Books', 'Popular books', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80'),
(6, 'Clothing', 'Apparel and fashion', 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=400&q=80'),
(7, 'Toys', 'Kids toys and games', 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=400&q=80'),
(8, 'Beauty', 'Beauty & personal care', 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=400&q=80'),
(9, 'Automotive', 'Car accessories', 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80'),
(10, 'Stationery', 'Office and school supplies', 'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=400&q=80');


INSERT INTO SHOPPERS (DeliveryAgentID, Name, Contact, CurrentLocation, DeliveryMode, Email) VALUES
(1, 'Alex Rider', '+1-602-555-2001', 'Phoenix, AZ', 'CAR', 'alex.rider@example.com'),
(2, 'Priya Nair', '+1-480-555-2002', 'Tempe, AZ', 'BIKE', 'priya.nair@example.com'),
(3, 'Rajesh Kumar', '+1-623-555-2010', 'Scottsdale, AZ', 'VAN', 'rajesh.kumar@example.in'),
(4, 'Sara Johnson', '+1-480-555-3003', 'Mesa, AZ', 'BIKE', 'sara.johnson@example.com'),
(5, 'Mohit Singh', '+1-602-555-4004', 'Glendale, AZ', 'CAR', 'mohit.singh@example.in'),
(6, 'Linda Davis', '+1-480-555-4004', 'Chandler, AZ', 'VAN', 'linda.davis@example.com'),
(7, 'Kumar Patel', '+1-623-555-5005', 'Gilbert, AZ', 'CAR', 'kumar.patel@example.in'),
(8, 'Emma Wilson', '+1-480-555-6006', 'Peoria, AZ', 'BIKE', 'emma.wilson@example.com'),
(9, 'Akash Sharma', '+1-520-555-7007', 'Tucson, AZ', 'BIKE', 'akash.sharma@example.in'),
(10, 'Jasmine Lee', '+1-480-555-8008', 'Surprise, AZ', 'CAR', 'jasmine.lee@example.com');



INSERT INTO STORES (StoreID, Location, StoreName, StoreDescription, AddressID) VALUES
(1, 'Phoenix, AZ', 'BayTech Electronics', 'Downtown electronics hub', 1),
(2, 'Tempe, AZ', 'SmartMart', 'Your one-stop shop', 2),
(3, 'Scottsdale, AZ', 'Gotham Fitness', 'All things fitness', 3),
(4, 'Mesa, AZ', 'Daily Grains', 'Fresh groceries daily', 4),
(5, 'Glendale, AZ', 'FabReads', 'Books and more', 5),
(6, 'Chandler, AZ', 'Fashion House', 'Latest trends', 6),
(7, 'Gilbert, AZ', 'ToyLand', 'Toys for kids', 7),
(8, 'Peoria, AZ', 'Glow Beauty', 'Beauty products', 8),
(9, 'Surprise, AZ', 'AutoZone', 'Car accessories', 9),
(10, 'Tucson, AZ', 'Stationery Hub', 'Office supplies', 10);


INSERT INTO PRODUCTS (ProductID, Name, Description, Price, CategoryID) VALUES
(1, 'Smartphone X', '128GB OLED display', 699, 1),
(2, 'Laptop Pro', '14-inch ultrabook', 1099, 1),
(3, 'Air Fryer', '5L compact air fryer', 129.99, 2),
(4, 'Yoga Mat', 'Non-slip, 6mm thick', 29.99, 3),
(5, 'Organic Rice', '5kg organic basmati', 13.99, 4),
(6, 'Running Shoes', 'Breathable running shoes', 59.99, 3),
(7, 'Classic Novel', 'Bestselling classic', 9.99, 5),
(8, 'T-shirt', '100% cotton', 12.99, 6),
(9, 'Remote Car', 'Battery toy car', 22.99, 7),
(10, 'Face Wash', 'Aloe-based cleanser', 8.99, 8);

INSERT INTO PRODUCTDETAILS (ProductID, ProductWeight, ProductHeight, ProductLength, ProductDiameter, ProductInventory) VALUES
(1, 0.18, 14.7, 7.2, 13, 100),
(2, 1.35, 1.6, 31, 8, 50),
(3, 4.2, 28, 30, 17, 80),
(4, 0.9, 21, 21, 21, 200),
(5, 2.5, 13, 25, 17.8, 150),
(6, 1, 24, 21.5, 18.5, 120),
(7, 0.3, 21.5, 35.6, 20, 90),
(8, 0.2, 17.3, 40, 15.5, 200),
(9, 0.7, 8, 32.5, 8, 80),
(10, 0.4, 12.5, 27, 11, 150);


INSERT INTO PHONENUMBER (PhoneID, CustomerID, PhoneNumber) VALUES
(1, 1, '+1-415-555-1001'),
(2, 2, '+1-415-555-1002'),
(3, 3, '+1-415-555-1003'),
(4, 4, '+1-415-555-1004'),
(5, 5, '+1-415-555-1005'),
(6, 6, '+91-99999-11111'),
(7, 7, '+1-415-555-1006'),
(8, 8, '+1-415-555-1125'),
(9, 9, '+44-7700-900900'),
(10, 10, '+91-80000-22222');


INSERT INTO CUSTOMERADDRESS (CustomerID, AddressID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);


INSERT INTO CART (CartID, Cart_Status, Timestamp, CustomerID) VALUES
(1, 'OPEN', '2025-11-10 00:48:08', 1),
(2, 'CHECKED_OUT', '2025-11-06 00:32:08', 2),
(3, 'OPEN', '2025-11-07 00:38:10', 3),
(4, 'ABANDONED', '2025-11-08 00:41:08', 4),
(5, 'EXPIRED', '2025-11-03 01:12:45', 5),
(6, 'OPEN', '2025-11-10 01:22:08', 6),
(7, 'CHECKED_OUT', '2025-11-11 01:03:23', 7),
(8, 'OPEN', '2025-11-12 00:46:49', 8),
(9, 'ABANDONED', '2025-11-28 01:25:12', 9),
(10, 'OPEN', '2025-11-14 01:10:42', 10);

INSERT INTO PRODUCTSTORE (ProductID, StoreID) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 3),
(6, 3),
(5, 4),
(7, 5),
(8, 6),
(9, 7),
(10, 8);


INSERT INTO REVIEWS (ReviewID, ProductID, CustomerID, Rating, Comments, Timestamp) VALUES
(1, 1, 1, 5, 'Amazing phone!', '2025-11-10 00:48:08'),
(2, 2, 2, 4, 'Great laptop for work', '2025-11-16 00:22:08'),
(3, 3, 3, 4, 'Cooks well, easy to use', '2025-11-27 00:28:10'),
(4, 4, 4, 5, 'Perfect for workouts', '2025-11-28 00:31:08'),
(5, 5, 5, 3, 'Good rice but price high', '2025-11-23 01:12:45'),
(6, 6, 6, 5, 'Very comfortable shoes', '2025-11-20 01:22:08'),
(7, 7, 7, 4, 'Loved the story!', '2025-11-11 01:03:23'),
(8, 8, 8, 3, 'Nice fabric', '2025-11-22 00:36:49'),
(9, 9, 9, 5, 'Fun toy for kids', '2025-11-28 01:25:12'),
(10, 10, 10, 4, 'Soothing face wash', '2025-11-14 01:10:42');


INSERT INTO CARTITEMS (CartItemID, CartID, ProductID, Quantity, UnitPrice, Timestamp) VALUES
(1, 1, 1, 1, 699, '2025-11-05 00:48:08'),
(2, 1, 4, 2, 29.99, '2025-11-06 00:32:08'),
(3, 2, 2, 1, 1099, '2025-11-07 00:38:08'),
(4, 2, 6, 1, 59.99, '2025-11-08 00:41:08'),
(5, 3, 3, 1, 129.99, '2025-11-09 01:12:08'),
(6, 4, 5, 5, 13.99, '2025-11-10 01:22:08'),
(7, 5, 7, 1, 9.99, '2025-11-11 01:03:08'),
(8, 6, 8, 3, 12.99, '2025-11-12 00:46:08'),
(9, 7, 9, 1, 22.99, '2025-11-13 01:25:08'),
(10, 8, 10, 4, 8.99, '2025-11-14 01:10:08');


INSERT INTO PAYMENTS (PaymentID, Amount, Currency, PaymentDay, PaymentMonth, PaymentYear, Quantity, ModeOfPayment, PaymentMethod, OrderID) VALUES
(1, 1428.99, 'USD', 28, 10, 2025, 2, 'ONLINE', 'VISA', 1),
(2, 59.98, 'USD', 29, 10, 2025, 2, 'ONLINE', 'AMEX', 2),
(3, 699, 'USD', 30, 10, 2025, 1, 'ONLINE', 'PayPal', 3),
(4, 41.97, 'USD', 25, 10, 2025, 3, 'COD', 'Cash', 4),
(5, 9.99, 'USD', 27, 10, 2025, 1, 'ONLINE', 'VISA', 5),
(6, 25.98, 'USD', 26, 10, 2025, 2, 'COD', 'Cash', 6),
(7, 22.99, 'USD', 24, 10, 2025, 1, 'ONLINE', 'UPI', 7),
(8, 44.95, 'USD', 23, 10, 2025, 5, 'ONLINE', 'Visa', 8),
(9, 59.99, 'USD', 22, 10, 2025, 1, 'ONLINE', 'Mastercard', 9),
(10, 71.92, 'USD', 21, 10, 2025, 8, 'COD', 'Cash', 10);


INSERT INTO DELIVERIES (DeliveryID, Actual_Delivery_Time, Estimated_Delivery_Time, DeliveryDate, DeliveryMonth, DeliveryYear, DeliveryInstructions,
    DeliveryAddress, Delivery_Status, OrderID, AddressID) VALUES
(1, NULL, '2025-11-02 17:00:00', '2025-11-02', 11, 2025, 'Leave at front desk', '123 Main St, Phoenix, AZ', 'PENDING', 1, 1),
(2, NULL, '2025-11-03 12:00:00', '2025-11-03', 11, 2025, 'Call on arrival', '1 Infinite Loop, Tempe, AZ', 'OUT_FOR_DELIVERY', 2, 2),
(3, NULL, '2025-11-04 18:00:00', '2025-11-04', 11, 2025, 'Ring the bell twice', '77 5th Ave, Scottsdale, AZ', 'PENDING', 3, 3),
(4, '2025-11-05 09:45:00', '2025-11-05 10:00:00', '2025-11-05', 11, 2025, 'Leave with neighbor', 'MG Road 12, Mesa, AZ', 'DELIVERED', 4, 4),
(5, NULL, '2025-11-06 16:00:00', '2025-11-06', 11, 2025, 'Back door', 'Marine Drive, Glendale, AZ', 'FAILED', 5, 5),
(6, NULL, '2025-11-07 13:00:00', '2025-11-07', 11, 2025, 'Call before delivery', 'Anna Nagar, Chandler, AZ', 'OUT_FOR_DELIVERY', 6, 6),
(7, NULL, '2025-11-08 09:00:00', '2025-11-08', 11, 2025, 'Leave at reception', 'Fraser Road, Gilbert, AZ', 'RETURNED', 7, 7),
(8, '2025-11-09 17:50:00', '2025-11-09 18:00:00', '2025-11-09', 11, 2025, 'Hand over personally', 'Connaught Place, Peoria, AZ', 'DELIVERED', 8, 8),
(9, NULL, '2025-11-10 20:00:00', '2025-11-10', 11, 2025, 'Ring bell thrice', 'Park Street, Surprise, AZ', 'PENDING', 9, 9),
(10, NULL, '2025-11-11 11:00:00', '2025-11-11', 11, 2025, 'Call on arrival', 'Abids Road, Tucson, AZ', 'PENDING', 10, 10);


INSERT INTO ORDERS (OrderID, OrderDay, OrderMonth, OrderYear, OrderStatus, CustomerID, CreatedAt, PaymentID, DeliveryID
) VALUES
(1, 28, 10, 2025, 'PAID', 2, '2025-11-05 12:27:08', 1, 1),
(2, 29, 10, 2025, 'SHIPPED', 3, '2025-11-05 12:27:08', 2, 2),
(3, 30, 10, 2025, 'PENDING', 1, '2025-11-05 12:27:08', 3, 3),
(4, 25, 10, 2025, 'DELIVERED', 4, '2025-11-05 12:27:08', 4, 4),
(5, 27, 10, 2025, 'CANCELLED', 5, '2025-11-05 12:27:08', 5, 5),
(6, 26, 10, 2025, 'PAID', 6, '2025-11-05 12:27:08', 6, 6),
(7, 24, 10, 2025, 'REFUNDED', 7, '2025-11-05 12:27:08', 7, 7),
(8, 23, 10, 2025, 'PAID', 8, '2025-11-05 12:27:08', 8, 8),
(9, 22, 10, 2025, 'SHIPPED', 9, '2025-11-05 12:27:08', 9, 9),
(10, 21, 10, 2025, 'PENDING', 10, '2025-11-05 12:27:08', 10, 10);


INSERT INTO ORDERITEMS (OrderItemID, OrderID, ProductID, Quantity) VALUES
(1, 1, 2, 1),
(2, 1, 3, 1),
(3, 2, 4, 2),
(4, 3, 1, 1),
(5, 4, 5, 3),
(6, 5, 7, 1),
(7, 6, 8, 2),
(8, 7, 9, 1),
(9, 8, 10, 5),
(10, 9, 6, 1);


INSERT INTO CUSTOMERCARTPAY (CustomerID, PaymentID, CartID) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10);


INSERT INTO DELIVERYSHOPPER (DeliveryID, DeliveryAgentID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);