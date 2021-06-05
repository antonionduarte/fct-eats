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
	discountState VARCHAR2(10)
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
	status VARCHAR2 (10) 
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

ALTER TABLE Discounts ADD CONSTRAINT pk_discounts PRIMARY KEY (code);
ALTER TABLE Discounts ADD CONSTRAINT null_discounts NOT NULL (percentage);
ALTER TABLE Discounts ADD CONSTRAINT positive_percentage CHECK (percentage >= 0); 

ALTER TABLE Ratings ADD CONSTRAINT valid_stars CHECK (stars BETWEEN 1 AND 5);
ALTER TABLE Ratings ADD CONSTRAINT pk_ratings PRIMARY KEY (compliment);
ALTER TABLE Ratings ADD CONSTRAINT fk_ratings FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Restaurants ADD CONSTRAINT pk_restaurant PRIMARY KEY (restaurantName);
ALTER TABLE Restaurants ADD CONSTRAINT unique_restaurantName UNIQUE (restaurantName);
ALTER TABLE Restaurants ADD CONSTRAINT fk_restaurant FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Restaurants ADD CONSTRAINT null_restaurant NOT NULL (deliveryFee, city, street, houseNumber);
ALTER TABLE Restaurants ADD CONSTRAINT positive_deliveryFee CHECK (deliveryFee >= 0);

ALTER TABLE Vehicles ADD CONSTRAINT pk_vehicles PRIMARY KEY (regNumber);
ALTER TABLE Vehicles ADD CONSTRAINT fk_vehicles FOREIGN KEY (courierEmail) REFERENCES Couriers (courierEmail);
ALTER TABLE Vehicles ADD CONSTRAINT null_vehicles NOT NULL (vehicleType, courierEmail);

ALTER TABLE Orders ADD CONSTRAINT pk_order PRIMARY KEY (orderID);
ALTER TABLE Orders ADD CONSTRAINT unique_orderID UNIQUE (orderID);
ALTER TABLE Orders ADD CONSTRAINT positive_orderID CHECK (orderID >= 0);
ALTER TABLE Orders ADD CONSTRAINT fk_order1 FOREIGN KEY (clientEmail) REFERENCES Clients (clientEmail);
ALTER TABLE Orders ADD CONSTRAINT fk_order2 FOREIGN KEY (courierEmail) REFERENCES Couriers (courierEmail);
ALTER TABLE Orders ADD CONSTRAINT positive_tip CHECK (tip >= 0);
ALTER TABLE Orders ADD CONSTRAINT valid_status CHECK (status IN ("received", "processing", "en route"));
ALTER TABLE Orders ADD CONSTRAINT null_order NOT NULL (clientEmail, courierEmail, tip, status);

ALTER TABLE Menus ADD CONSTRAINT pk_menus PRIMARY KEY (menuName, restaurantName);
ALTER TABLE Menus ADD CONSTRAINT unique_menus UNIQUE (menuName);
ALTER TABLE Menus ADD CONSTRAINT fk_menus FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Menus ADD CONSTRAINT null_menus NOT NULL (restaurantName, price);
ALTER TABLE Menus ADD CONSTRAINT positive_price CHECK (price >= 0);

ALTER TABLE Categories ADD CONSTRAINT pk_category PRIMARY KEY (categoryName);
ALTER TABLE Categories ADD CONSTRAINT null_category NOT NULL (categoryName); 

ALTER TABLE Couriers ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE Couriers ADD CONSTRAINT pk_courier PRIMARY KEY (email);
ALTER TABLE Couriers ADD CONSTRAINT fk_courier FOREIGN KEY (email) REFERENCES Users (email);
ALTER TABLE Couriers ADD CONSTRAINT null_courier NOT NULL (email, driverLicense, NIB);

ALTER TABLE Clients ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE Clients ADD CONSTRAINT pk_client PRIMARY KEY (email);
ALTER TABLE Clients ADD CONSTRAINT fk_client FOREIGN KEY (email) REFERENCES Users (email); 
ALTER TABLE Clients ADD CONSTRAINT valid_payment CHECK (paymentMethod IN("card", "cash"));
ALTER TABLE Clients ADD CONSTRAINT null_client NOT NULL (email, paymentMethod);

ALTER TABLE ADD CONSTRAINT unique_city UNIQUE (city, street, houseNumber);
ALTER TABLE Users ADD CONSTRAINT pk_user PRIMARY KEY (email); 
ALTER TABLE Users ADD CONSTRAINT fk_city FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Users ADD CONSTRAINT null_user NOT NULL (email, phoneNumber, city, street, houseNumber);

ALTER TABLE Address ADD CONSTRAINT pk_address PRIMARY KEY (city, street, houseNumber);
ALTER TABLE Address ADD CONSTRAINT null_address NOT NULL (city, street, houseNumber);

ALTER TABLE Used_Discount ADD CONSTRAINT fk_code FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Used_Discount ADD CONSTRAINT fk_orderId FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Categories ADD CONSTRAINT fk_categoryName FOREIGN KEY (categoryName) REFERENCES Categories (categoryName);
ALTER TABLE Has_Categories ADD CONSTRAINT fk_restaurantName FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);

ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food1 FOREIGN KEY (menuName) REFERENCES Menus (menuName);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food2 FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_ordered_food3 FOREIGN KEY (orderId) REFERENCES Orders (orderId);

ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount1 FOREIGN KEY (email) REFERENCES Clients (email);
ALTER TABLE Has_Discount ADD CONSTRAINT fk_has_discount2 FOREIGN KEY (code) REFERENCES Discounts (code);

-- Triggers


----IMPORTANT NOTE: WHEN PLACING AN ORDER, WE HAVE TO FIRST INSERT INTO THE ORDERS TABLE, AND THEN INTO ORDERED_FOOD 
---OR THIS TRIGGER WILL NOT WORK---

--- Ensuring that no orders have customers and restaurants from diff cities ---
CREATE TRIGGER placing_order
BEFORE INSERT ON Ordered_Food
DECLARE 
	clientCity VARCHAR2(50);
	restaurantCity VARCHAR2(50); 
BEGIN
  SELECT city INTO restaurantCity
  FROM Restaurants
  WHERE Restaurants.restaurantName = :new.restaurantName;

  SELECT city INTO clientCity
  FROM Order INNER JOIN Users ON (Order.clientEmail = Users.email)
  WHERE Order.orderID = :new.orderId;

  IF (clientCity <> restaurantCity)
  ---THROW APPLICATION ERROR HERE---
  END IF;
END;

--- Ensuring that an Order can only have one associated Discount.
CREATE TRIGGER discount_usage_limit
BEFORE INSERT ON Used_Discount
BEGIN
    IF
        ((SELECT COUNT (*) 
        FROM Used_Discount INNER JOIN Orders USING (orderID)
        WHERE orderID = :new.orderID
        GROUP BY orderID) > 0)
    THEN Raise_Application_Error (-20420, 'Limit of discounts per order exceeded.')
    END IF;
END;

-- Functions and Views

CREATE FUNCTION user_city (userEmail VARCHAR2(256))
RETURN VARCHAR2(50)
IS r VARCHAR2(50);
BEGIN
  SELECT city INTO r
  FROM Users
  WHERE Users.email = userEmail;

  RETURN r;
END;

CREATE FUNCTION available_restaurants (clientCity TEXT)
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

CREATE VIEW available_restaurants AS 
    (SELECT * 
     FROM available_restaurants(user_city("abc@gmail.com")) )

-- Insertions

INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");
INSERT INTO Users VALUES ("aaa@gmail.com", 911111111, "Lisboa", "Rua aaa", "A-01");


