-- Drops

DROP TABLE Ratings CASCADE CONSTRAINTS;
DROP TABLE Has_Discount CASCADE CONSTRAINTS;
DROP TABLE Ordered_Food CASCADE CONSTRAINTS;
DROP TABLE Has_Categories CASCADE CONSTRAINTS;
DROP TABLE Used_Discount CASCADE CONSTRAINTS;
DROP TABLE Address CASCADE CONSTRAINTS;
DROP TABLE Users CASCADE CONSTRAINTS;
DROP TABLE Clients CASCADE CONSTRAINTS;
DROP TABLE Couriers CASCADE CONSTRAINTS;
DROP TABLE Categories CASCADE CONSTRAINTS;
DROP TABLE Menus CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP TABLE Vehicles CASCADE CONSTRAINTS;
DROP TABLE Restaurants CASCADE CONSTRAINTS;
DROP TABLE Discounts CASCADE CONSTRAINTS;

-- Create tables and Restrictions

-- Ratings table
CREATE TABLE Ratings (
	stars NUMBER(1),
	compliment VARCHAR2(100),
	orderId NUMBER(20)
);

-- Has_Discount table
CREATE TABLE Has_Discount (
	email VARCHAR2(256),
	code VARCHAR2(30),
	discountUsed NUMBER(1)
);

-- Ordered_Food table
CREATE TABLE Ordered_Food (
	menuName VARCHAR2(50),
	restaurantID NUMBER(20),
	orderId NUMBER(20)
);

-- Has_Categories table
CREATE TABLE Has_Categories (
	categoryName VARCHAR2(50),
	restaurantID NUMBER(20)
);

-- Used_Discount table
CREATE TABLE Used_Discount (
	code VARCHAR2(30),
	orderId NUMBER(20)
);

-- Address table
CREATE TABLE Address (
	city VARCHAR2(50),
	street VARCHAR2(50),
	houseNumber VARCHAR2(10)
);

-- Users table
CREATE TABLE Users (
	firstName VARCHAR2(30),
	lastName VARCHAR2(30),
	email VARCHAR2 (256),
	phoneNumber NUMBER (9, 0),
	city VARCHAR2(50),
	street VARCHAR2(50),
	houseNumber VARCHAR2(10)
);

-- Clients table
CREATE TABLE Clients (
	email VARCHAR2 (256),
	paymentMethod VARCHAR2(5)
);

-- Couriers table
CREATE TABLE Couriers (
	email VARCHAR2 (256),
	driverLicense VARCHAR2 (12),
	NIB VARCHAR2 (22)
);

-- Categories table
CREATE TABLE Categories (
	categoryName VARCHAR2 (30)
);

-- Menus table
CREATE TABLE Menus ( 
	menuName VARCHAR2(30),
	restaurantID NUMBER(20),
	price NUMBER(38,2) 
);

-- Orders table
CREATE TABLE Orders ( 
	orderID NUMBER(20),
	clientEmail VARCHAR2 (254),
	courierEmail VARCHAR2 (254),
	tip NUMBER (3,2),
	status VARCHAR2 (10),
	restaurantID NUMBER(20)
);

-- Vehicles table
CREATE TABLE Vehicles (
	regNumber CHAR(6),
	vehicleType VARCHAR2(50),
	courierEmail VARCHAR2(254) 
);

-- Restaurants table
CREATE TABLE Restaurants ( 
	restaurantName VARCHAR2(50),
	restaurantID NUMBER(20),
	deliveryFee NUMBER (38,2),
	city VARCHAR2(50),
	street VARCHAR2(50),
	houseNumber VARCHAR2(10)
);

-- Discounts table
CREATE TABLE Discounts ( 
	code VARCHAR2(30),
	percentage NUMBER (3) 
);

ALTER TABLE Address ADD CONSTRAINT pk_address PRIMARY KEY (city, street, houseNumber);

ALTER TABLE Users ADD CONSTRAINT pk_user PRIMARY KEY (email); 
ALTER TABLE Users ADD CONSTRAINT fk_address FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Users MODIFY (phoneNumber NOT NULL, city NOT NULL, street NOT NULL, houseNumber NOT NULL, firstName NOT NULL, lastName NOT NULL);
ALTER TABLE Users ADD CONSTRAINT unique_phoneNumber UNIQUE (phoneNumber);

ALTER TABLE Couriers ADD CONSTRAINT pk_courier PRIMARY KEY (email);
ALTER TABLE Couriers ADD CONSTRAINT fk_courier FOREIGN KEY (email) REFERENCES Users (email);
ALTER TABLE Couriers MODIFY (driverLicense NOT NULL, NIB NOT NULL);
ALTER TABLE Couriers ADD CONSTRAINT unique_couriers UNIQUE (driverLicense, NIB);

ALTER TABLE Clients ADD CONSTRAINT pk_client PRIMARY KEY (email);
ALTER TABLE Clients ADD CONSTRAINT fk_client FOREIGN KEY (email) REFERENCES Users (email); 
ALTER TABLE Clients ADD CONSTRAINT valid_payment CHECK (paymentMethod IN ('card', 'cash'));

ALTER TABLE Restaurants ADD CONSTRAINT pk_restaurant PRIMARY KEY (restaurantID);
ALTER TABLE Restaurants ADD CONSTRAINT fk_restaurant FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Restaurants MODIFY (restaurantName NOT NULL, deliveryFee NOT NULL, city NOT NULL, street NOT NULL, houseNumber NOT NULL);
ALTER TABLE Restaurants ADD CONSTRAINT valid_deliveryFee CHECK (deliveryFee >= 0);

ALTER TABLE Orders ADD CONSTRAINT pk_order PRIMARY KEY (orderID);
ALTER TABLE Orders ADD CONSTRAINT un_restaurantID UNIQUE (restaurantID);
ALTER TABLE Orders ADD CONSTRAINT valid_orderID CHECK (orderID >= 0);
ALTER TABLE Orders ADD CONSTRAINT fk_order1 FOREIGN KEY (clientEmail) REFERENCES Clients (email);
ALTER TABLE Orders ADD CONSTRAINT fk_order2 FOREIGN KEY (courierEmail) REFERENCES Couriers (email);
ALTER TABLE Orders ADD CONSTRAINT fk_order3 FOREIGN KEY (restaurantID) REFERENCES Restaurants (restaurantID);
ALTER TABLE Orders ADD CONSTRAINT valid_tip CHECK (tip >= 0);
ALTER TABLE Orders ADD CONSTRAINT valid_status CHECK (status IN ('received', 'processing', 'en route'));
ALTER TABLE Orders MODIFY (clientEmail NOT NULL, courierEmail NOT NULL, tip NOT NULL, status NOT NULL, restaurantID NOT NULL);

ALTER TABLE Discounts ADD CONSTRAINT pk_discounts PRIMARY KEY (code);
ALTER TABLE Discounts MODIFY (percentage NOT NULL);
ALTER TABLE Discounts ADD CONSTRAINT valid_percentage CHECK (percentage BETWEEN 0 AND 100); 

ALTER TABLE Ratings ADD CONSTRAINT valid_stars CHECK (stars BETWEEN 1 AND 5);
ALTER TABLE Ratings ADD CONSTRAINT pk_ratings PRIMARY KEY (compliment);
ALTER TABLE Ratings ADD CONSTRAINT fk_ratings FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Vehicles ADD CONSTRAINT pk_vehicles PRIMARY KEY (regNumber);
ALTER TABLE Vehicles ADD CONSTRAINT fk_vehicles FOREIGN KEY (courierEmail) REFERENCES Couriers (email);
ALTER TABLE Vehicles ADD CONSTRAINT valid_type CHECK (vehicleType IN ('motorcycle', 'car', 'bike'));
ALTER TABLE Vehicles MODIFY (vehicleType NOT NULL, courierEmail NOT NULL);

ALTER TABLE Menus ADD CONSTRAINT pk_menus PRIMARY KEY (menuName, restaurantID);
ALTER TABLE Menus ADD CONSTRAINT fk_menus FOREIGN KEY (restaurantID) REFERENCES Restaurants (restaurantID);
ALTER TABLE Menus MODIFY (price NOT NULL);
ALTER TABLE Menus ADD CONSTRAINT positive_price CHECK (price >= 0);

ALTER TABLE Categories ADD CONSTRAINT pk_category PRIMARY KEY (categoryName);

ALTER TABLE Used_Discount ADD CONSTRAINT fk_code FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Used_Discount ADD CONSTRAINT fk_orderId FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Categories ADD CONSTRAINT fk_categoryName FOREIGN KEY (categoryName) REFERENCES Categories (categoryName);
ALTER TABLE Has_Categories ADD CONSTRAINT fk_restaurantID FOREIGN KEY (restaurantID) REFERENCES Restaurants (restaurantID);

ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food1 FOREIGN KEY (menuName, restaurantID) REFERENCES Menus (menuName, restaurantID);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food2 FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount1 FOREIGN KEY (email) REFERENCES Clients (email);
ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount2 FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Has_Discount ADD CONSTRAINT discountState_possibilities CHECK (discountUsed IN (0, 1));
ALTER TABLE Has_Discount MODIFY discountUsed DEFAULT 0;

-- Sequences

-- Sequence for the order ID's
CREATE SEQUENCE seq_order_id 
START WITH 1
INCREMENT BY 1;

-- Sequence for the restaurant ID's
CREATE SEQUENCE seq_restaurant_id
START WITH 1
INCREMENT BY 1;

-- Triggers

-- Automatically insert new order id from seq.
CREATE OR REPLACE TRIGGER insert_order_id
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE
	new_order_id NUMBER (20);
BEGIN
	SELECT seq_order_id.nextval INTO new_order_id 
		FROM dual;
	:new.orderID := new_order_id;
END;
/

-- Ensuring that a Courier isn't taking orders outside their city
CREATE OR REPLACE TRIGGER courier_city_order
BEFORE INSERT ON Orders
FOR EACH ROW 
DECLARE
	restaurant_city VARCHAR2 (50);
	courier_city VARCHAR2 (50);
BEGIN
	SELECT city INTO restaurant_city
	FROM Restaurants INNER JOIN Orders USING (restaurantID)
	WHERE orderID = :new.orderID;

	SELECT city INTO courier_city
	FROM Couriers INNER JOIN Users USING (email)
	WHERE email = :new.courierEmail;

	IF (courier_city <> restaurant_city)
		THEN Raise_Application_Error (-20001, 'Couriers must deliver in their city.');
	END IF;
END;
/

-- Ensure that a Courier can only do one delivery at a time
CREATE OR REPLACE TRIGGER courier_deliveries
BEFORE INSERT ON Orders
FOR EACH ROW 
DECLARE
	unfinished_orders INTEGER;
BEGIN

		SELECT COUNT(*) INTO unfinished_orders
		FROM Orders
		WHERE courierEmail = :new.courierEmail AND status <> 'received';

	IF (unfinished_orders > 0)

		THEN Raise_Application_Error (-20002, 'A Courier can only deliver one order at a time.');

	END IF;
END;
/

--- Update User Discount Status to Used after insert on Used Discount ---
CREATE OR REPLACE TRIGGER change_discount_status
AFTER INSERT ON Used_Discount
FOR EACH ROW
DECLARE
	client_email VARCHAR2 (256);
BEGIN
	SELECT clientEmail INTO client_email
	FROM Orders
	WHERE orderID = :new.orderID;

	UPDATE Has_Discount
	SET discountUsed = 1
	WHERE email = client_email AND Has_Discount.code = :new.code; 
END;
/

--- Ensuring that no orders have customers and restaurants from diff cities ---
CREATE OR REPLACE TRIGGER placing_order
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE 
	clientCity VARCHAR2 (50);
	restaurantCity VARCHAR2 (50); 
BEGIN
  SELECT city INTO restaurantCity
  FROM Restaurants
  WHERE Restaurants.restaurantID = :new.restaurantID;

  SELECT city INTO clientCity
  FROM Orders INNER JOIN Users ON (Orders.clientEmail = Users.email)
  WHERE Orders.orderID = :new.orderId;

  IF (clientCity <> restaurantCity)

  	THEN Raise_Application_Error (-20069, 'Restaurant unavailable.');

  END IF;
END;
/

--- Ensuring that an Order can only have one associated Discount. ---
CREATE OR REPLACE TRIGGER discount_usage_limit
BEFORE INSERT ON Used_Discount
FOR EACH ROW
DECLARE
	order_discounts INTEGER;
BEGIN
    SELECT COUNT (*) INTO order_discounts 
	FROM Used_Discount
	WHERE orderID = :new.orderID;

	IF (order_discounts > 0)

    	THEN Raise_Application_Error (-20420, 'Limit of discounts per order exceeded.');

    END IF;
END;
/

--- Ensuring that an Order does not include Menus from several different restaurants ---
CREATE OR REPLACE TRIGGER order_restaurant_limit
BEFORE INSERT ON Ordered_Food
FOR EACH ROW
DECLARE
	total_restaurants NUMBER;
	same_restaurants NUMBER;
BEGIN
	-- Total of restaurants in this order (will always be 0 or 1) ---
	SELECT COUNT(DISTINCT restaurantID) INTO total_restaurants
	FROM Ordered_Food
	WHERE Ordered_Food.orderId = :new.orderId;

	-- Total of restaurants in this order that are the same as the newly inserted one (0 or 1) --
	SELECT COUNT (DISTINCT restaurantID) INTO same_restaurants
	FROM Ordered_Food
	WHERE Ordered_Food.orderId = :new.orderId AND Ordered_Food.restaurantID = :new.restaurantID;

	-- Ensures that if there is already a restaurant in this order, it cannot be different than the new one --
	IF ((total_restaurants = 1) AND (same_restaurants = 0))

		THEN Raise_Application_Error (-20690, 'You can only order from one restaurant at a time.');

	END IF;
END;
/

--- Ensures that no discount is used twice on the same order ---
CREATE OR REPLACE TRIGGER discount_in_use
BEFORE INSERT ON Used_Discount
FOR EACH ROW
DECLARE
	discount_in_order INTEGER;
BEGIN 

	-- Counts the number of times the new discount has been used in the given order --
	SELECT COUNT (*) INTO discount_in_order
	FROM Used_Discount
	WHERE Used_Discount.orderID = :new.orderID AND Used_Discount.code = :new.code;

	IF (discount_in_order = 1)
		THEN Raise_Application_Error (-20609, 'This discount has been applied to your order already.');
	END IF;
END;
/

-- Add address before insert on User
CREATE OR REPLACE TRIGGER add_address_user
BEFORE INSERT ON Users
FOR EACH ROW 
DECLARE number_equal_addresses NUMBER;
BEGIN
	SELECT COUNT (*) INTO number_equal_addresses
		FROM Address
		WHERE city = :new.city AND street = :new.street AND houseNumber = :new.houseNumber;
	IF (number_equal_addresses = 0)
		THEN INSERT INTO Address VALUES (:new.city, :new.street, :new.houseNumber);
	END IF;
END;
/

-- Add address before insert on Restaurant
CREATE OR REPLACE TRIGGER add_address_restaurant
BEFORE INSERT ON Restaurants
FOR EACH ROW
DECLARE number_equal_addresses NUMBER;
BEGIN
	SELECT COUNT (*) INTO number_equal_addresses
		FROM Address
		WHERE city = :new.city AND street = :new.street AND houseNumber = :new.houseNumber;
	IF (number_equal_addresses = 0)
		THEN INSERT INTO Address VALUES (:new.city, :new.street, :new.houseNumber);
	END IF;
END; 
/

-- Functions and Procedures

-- Procedure used to insert restaurants
CREATE OR REPLACE PROCEDURE insert_restaurant (
	restaurant_name IN VARCHAR2,
	delivery_fee IN NUMBER,
	city IN VARCHAR2,
	street IN VARCHAR2,
	houseNumber IN NUMBER,
	category_name IN VARCHAR2) AS
	category_count NUMBER;
	restaurant_id NUMBER;
BEGIN
	restaurant_id := seq_restaurant_id.nextval;
	
	SELECT COUNT (*) INTO category_count
	FROM Categories
	WHERE categoryName = category_name;

	IF (category_count = 0)
		THEN Raise_Application_Error (-20001, 'The specified category does not exist.'); 
	END IF;

	INSERT INTO Restaurants VALUES (restaurant_name, restaurant_id, delivery_fee, city, street, houseNumber);
	INSERT INTO Has_Categories VALUES (category_name, restaurant_id);
END;
/

-- Add a discount to a client
CREATE OR REPLACE PROCEDURE add_discount_client (
	discount_code IN NUMBER,
	client_email IN VARCHAR2
)
AS
BEGIN
	INSERT INTO Has_Discount VALUES (client_email, discount_code, 0);
END;
/

-- Procedure used to insert clients
CREATE OR REPLACE PROCEDURE insert_client (
	client_firstName in VARCHAR2,
	client_lastName in VARCHAR2,
	client_email IN VARCHAR2,
	client_phone IN NUMBER,
	client_city IN VARCHAR2,
	client_street IN VARCHAR2,
	client_house IN VARCHAR2,
	client_paymentMethod IN VARCHAR2) AS
	user_count NUMBER;
BEGIN
	SELECT COUNT (*) INTO user_count
	FROM Users
	WHERE email = client_email;

	IF (user_count = 0) THEN
		INSERT INTO Users VALUES (client_email, client_phone, client_city, 
                                client_street, client_house, client_firstName, client_lastName);
	END IF;

	INSERT INTO Clients VALUES (client_email, client_paymentMethod);
END;
/

-- Procedure used to insert couriers
CREATE OR REPLACE PROCEDURE insert_courier (
	courier_firstName IN VARCHAR2,
	courier_lastName IN VARCHAR2,
	courier_email IN VARCHAR2,
	courier_phone IN NUMBER,
	courier_city IN VARCHAR2,
	courier_street IN VARCHAR2,
	courier_house IN VARCHAR2,
	courier_driverLicense IN VARCHAR2,
	courier_NIB IN VARCHAR2) AS
	user_count NUMBER;
BEGIN 
	SELECT COUNT (*) INTO user_count
	FROM Users 
	WHERE email = courier_email;

	IF (user_count = 0) THEN
		INSERT INTO Users VALUES (courier_email, courier_phone, courier_city, 
                                courier_street, courier_house, courier_firstName, courier_lastName);
	END IF;

	INSERT INTO Couriers VALUES (courier_email, courier_driverLicense, courier_NIB);
END;
/

-- Views

-- View the 10 couriers with the highest ratings
CREATE OR REPLACE VIEW highest_rated_couriers AS 
	SELECT Couriers.email, firstName, lastName, AVG(stars) AS avg_rating
	FROM Couriers INNER JOIN Orders ON(Couriers.email = Orders.courierEmail) -- gets us the orders of each courier --
					INNER JOIN Ratings USING(orderID) -- gets us the rating of each order --
											INNER JOIN Users ON(Couriers.email = Users.email) -- gets us the courier's name --
	WHERE Orders.status = 'received' AND ROWNUM <= 10
	GROUP BY Couriers.email, firstName, lastName
	ORDER BY AVG(stars);

-- View used for client report
CREATE OR REPLACE VIEW client_information AS
SELECT *
FROM Clients INNER JOIN Users USING (email)
ORDER BY firstName;

-- View used for courier report
CREATE OR REPLACE VIEW courier_information AS
SELECT *
FROM Couriers INNER JOIN Users USING (email)
ORDER BY firstName;

-- Insertions

-- Pre-defined Categories
INSERT INTO Categories VALUES ('Pizza');
INSERT INTO Categories VALUES ('Hamburger');
INSERT INTO Categories VALUES ('Sushi');
INSERT INTO Categories VALUES ('Asian');
INSERT INTO Categories VALUES ('Chinese');
INSERT INTO Categories VALUES ('Italian');
INSERT INTO Categories VALUES ('Pasta');
INSERT INTO Categories VALUES ('Indian');
INSERT INTO Categories VALUES ('Vietnamese');