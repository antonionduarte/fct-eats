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
	restaurantName VARCHAR2(50),
	orderId NUMBER(20)
);

-- Has_Categories table
CREATE TABLE Has_Categories (
	categoryName VARCHAR2(50),
	restaurantName VARCHAR2(50)
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
	restaurantName VARCHAR(30),
	price NUMBER(3,2) 
);

-- Orders table
CREATE TABLE Orders ( 
	orderID NUMBER(20),
	clientEmail VARCHAR2 (254),
	courierEmail VARCHAR2 (254),
	tip NUMBER (3,2),
	status VARCHAR2 (10),
	restaurantName VARCHAR2(30)
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
	deliveryFee NUMBER (2,2),
	city VARCHAR2(50),
	street VARCHAR2(50),
	houseNumber VARCHAR2(10)
);

-- Discounts table
CREATE TABLE Discounts ( 
	code VARCHAR2(30),
	percentage NUMBER (3,2) 
);

ALTER TABLE Address ADD CONSTRAINT pk_address PRIMARY KEY (city, street, houseNumber);

ALTER TABLE Users ADD CONSTRAINT pk_user PRIMARY KEY (email); 
ALTER TABLE Users ADD CONSTRAINT fk_address FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Users MODIFY (phoneNumber NOT NULL, city NOT NULL, street NOT NULL, houseNumber NOT NULL);
ALTER TABLE Users ADD CONSTRAINT unique_phoneNumber UNIQUE (phoneNumber);

ALTER TABLE Couriers ADD CONSTRAINT pk_courier PRIMARY KEY (email);
ALTER TABLE Couriers ADD CONSTRAINT fk_courier FOREIGN KEY (email) REFERENCES Users (email);
ALTER TABLE Couriers MODIFY (driverLicense NOT NULL, NIB NOT NULL);
ALTER TABLE Couriers ADD CONSTRAINT unique_couriers UNIQUE (driverLicense, NIB);

ALTER TABLE Clients ADD CONSTRAINT pk_client PRIMARY KEY (email);
ALTER TABLE Clients ADD CONSTRAINT fk_client FOREIGN KEY (email) REFERENCES Users (email); 
ALTER TABLE Clients ADD CONSTRAINT valid_payment CHECK (paymentMethod IN ('card', 'cash'));

ALTER TABLE Orders ADD CONSTRAINT pk_order PRIMARY KEY (orderID);
ALTER TABLE Orders ADD CONSTRAINT valid_orderID CHECK (orderID >= 0);
ALTER TABLE Orders ADD CONSTRAINT fk_order1 FOREIGN KEY (clientEmail) REFERENCES Clients (email);
ALTER TABLE Orders ADD CONSTRAINT fk_order2 FOREIGN KEY (courierEmail) REFERENCES Couriers (email);
ALTER TABLE Orders ADD CONSTRAINT fk_order3 FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Orders ADD CONSTRAINT valid_tip CHECK (tip >= 0);
ALTER TABLE Orders ADD CONSTRAINT valid_status CHECK (status IN ('received', 'processing', 'en route'));
ALTER TABLE Orders MODIFY (clientEmail NOT NULL, courierEmail NOT NULL, tip NOT NULL, status NOT NULL);

ALTER TABLE Discounts ADD CONSTRAINT pk_discounts PRIMARY KEY (code);
ALTER TABLE Discounts MODIFY (percentage NOT NULL);
ALTER TABLE Discounts ADD CONSTRAINT valid_percentage CHECK (percentage >= 0); 

ALTER TABLE Ratings ADD CONSTRAINT valid_stars CHECK (stars BETWEEN 1 AND 5);
ALTER TABLE Ratings ADD CONSTRAINT pk_ratings PRIMARY KEY (compliment);
ALTER TABLE Ratings ADD CONSTRAINT fk_ratings FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Restaurants ADD CONSTRAINT pk_restaurant PRIMARY KEY (restaurantName);
ALTER TABLE Restaurants ADD CONSTRAINT fk_restaurant FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Restaurants MODIFY (deliveryFee NOT NULL, city NOT NULL, street NOT NULL, houseNumber NOT NULL);
ALTER TABLE Restaurants ADD CONSTRAINT valid_deliveryFee CHECK (deliveryFee >= 0);

ALTER TABLE Vehicles ADD CONSTRAINT pk_vehicles PRIMARY KEY (regNumber);
ALTER TABLE Vehicles ADD CONSTRAINT fk_vehicles FOREIGN KEY (courierEmail) REFERENCES Couriers (email);
ALTER TABLE Vehicles MODIFY (vehicleType NOT NULL, courierEmail NOT NULL);

ALTER TABLE Menus ADD CONSTRAINT pk_menus PRIMARY KEY (menuName, restaurantName);
ALTER TABLE Menus ADD CONSTRAINT fk_menus FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Menus MODIFY (price NOT NULL);
ALTER TABLE Menus ADD CONSTRAINT positive_price CHECK (price >= 0);

ALTER TABLE Categories ADD CONSTRAINT pk_category PRIMARY KEY (categoryName);

ALTER TABLE Used_Discount ADD CONSTRAINT fk_code FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Used_Discount ADD CONSTRAINT fk_orderId FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Categories ADD CONSTRAINT fk_categoryName FOREIGN KEY (categoryName) REFERENCES Categories (categoryName);
ALTER TABLE Has_Categories ADD CONSTRAINT fk_restaurantName FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);

ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food1 FOREIGN KEY (menuName, restaurantName) REFERENCES Menus (menuName, restaurantName);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food2 FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount1 FOREIGN KEY (email) REFERENCES Clients (email);
ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount2 FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Has_Discount ADD CONSTRAINT discountState_possibilities CHECK (discountUsed IN (0, 1));
ALTER TABLE Has_Discount MODIFY discountUsed DEFAULT 0;

-- Triggers

----IMPORTANT NOTE: WHEN PLACING AN ORDER, WE HAVE TO FIRST INSERT INTO THE ORDERS TABLE, AND THEN INTO ORDERED_FOOD 
---OR THIS TRIGGER WILL NOT WORK---

-- Ensuring that a Courier isn't taking orders outside their city
CREATE OR REPLACE TRIGGER courier_city_order
BEFORE INSERT ON Orders
FOR EACH ROW 
DECLARE
	restaurant_city VARCHAR2 (50);
	courier_city VARCHAR2 (50);
BEGIN
	SELECT city INTO restaurant_city
	FROM Restaurants INNER JOIN Orders USING (restaurantName)
	WHERE orderID = :new.orderID;

	SELECT city INTO courier_city
	FROM Couriers INNER JOIN Users USING (email)
	WHERE email = :new.courierEmail;

	IF (courier_city <> restaurant_city)
		THEN Raise_Application_Error (-20001, 'Couriers must deliver in their city.');
	END IF;
END;

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
  WHERE Restaurants.restaurantName = :new.restaurantName;

  SELECT city INTO clientCity
  FROM Orders INNER JOIN Users ON (Orders.clientEmail = Users.email)
  WHERE Orders.orderID = :new.orderId;

  IF (clientCity <> restaurantCity)

  	THEN Raise_Application_Error (-20069, 'Restaurant unavailable.');

  END IF;
END;

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

	IF ( order_discounts > 0 )

    	THEN Raise_Application_Error (-20420, 'Limit of discounts per order exceeded.');

    END IF;
END;

--- Ensuring that an Order does not include Menus from several different restaurants ---
CREATE OR REPLACE TRIGGER order_restaurant_limit
BEFORE INSERT ON Ordered_Food
FOR EACH ROW
DECLARE
	total_restaurants INTEGER;
	same_restaurants INTEGER;
BEGIN

	-- Total of restaurants in this order (will always be 0 or 1) ---
	SELECT COUNT(DISTINCT restaurantName) INTO total_restaurants
	FROM Ordered_Food
	WHERE Ordered_Food.orderId = :new.orderId;

	-- Total of restaurants in this order that are the same as the newly inserted one (0 or 1) --
	SELECT COUNT (DISTINCT restaurantName) INTO same_restaurants
	FROM Ordered_Food
	WHERE Ordered_Food.orderId = :new.orderId AND Ordered_Food.restaurantName = :new.restaurantName;

	-- Ensures that if there is already a restaurant in this order, it cannot be different than the new one --
	IF ( (total_restaurants = 1) AND (same_restaurants = 0) )

		THEN Raise_Application_Error (-20690, 'You can only order from one restaurant at a time.');

	END IF;
END;

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

-- Functions and Views

CREATE OR REPLACE FUNCTION user_city (userEmail VARCHAR2(256))
RETURN VARCHAR2(50)
IS r VARCHAR2(50);
BEGIN
  SELECT city INTO r
  FROM Users
  WHERE Users.email = userEmail;

  RETURN r;
END;

CREATE OR REPLACE FUNCTION available_restaurants (clientCity TEXT)
RETURN TABLE
IS
r TABLE;
BEGIN
  FOR restaurant IN (SELECT * FROM Restaurants)

  LOOP
		IF (restaurant.city = clientCity)
		INSERT INTO r VALUES restaurant; ---unsure if this works---
		END IF;
  END LOOP;

  RETURN r;

END;

CREATE OR REPLACE VIEW available_restaurants AS 
    (SELECT * 
     FROM available_restaurants(user_city("abc@gmail.com")) )

-- Insertions

INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");