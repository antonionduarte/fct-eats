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

DROP SEQUENCE seq_order_id;
DROP SEQUENCE seq_restaurant_id;

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
	restaurantID NUMBER(20),
	orderDate DATE
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
ALTER TABLE Restaurants ADD CONSTRAINT un_restaurantName UNIQUE (restaurantName);

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

-- Ensuring that a Courier isn't taking orders outside their city
CREATE OR REPLACE TRIGGER courier_city_order
BEFORE INSERT ON Orders
FOR EACH ROW 
DECLARE
	restaurant_city VARCHAR2 (50);
	courier_city VARCHAR2 (50);
BEGIN
	SELECT city INTO courier_city
	FROM Couriers INNER JOIN Users USING (email)
	WHERE email = :new.courierEmail;

	SELECT city INTO restaurant_city
	FROM Restaurants
	WHERE restaurantID = :new.restaurantID;

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
  FROM Users
  WHERE email = :new.clientEmail;

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

-- Ensure we can't add food to a closed order or a order that's already en route.
CREATE OR REPLACE TRIGGER ensure_order_open
BEFORE INSERT ON Ordered_Food
FOR EACH ROW
DECLARE order_state VARCHAR2 (10);
BEGIN
	SELECT status INTO order_state FROM Orders WHERE orderID = :new.orderID;

	IF (order_state = 'received')
		THEN Raise_Application_Error (-20002, 'You can not add food to an already finished order');
	END IF; 

	IF (order_state = 'en route')
		THEN Raise_Application_Error (-20003, 'You can not add food to an order that is already en route');
	END IF;
END;
/

-- Functions and Procedures

-- Function to get a restaurant's ID with the name
CREATE OR REPLACE FUNCTION get_restaurant_ID (restaurant_name IN VARCHAR2)
RETURN NUMBER
IS 
	restaurant_ID NUMBER;
BEGIN 
	SELECT restaurantID INTO restaurant_ID
	FROM Restaurants
	WHERE Restaurants.restaurantName = restaurant_name;
	
	RETURN (restaurant_ID);
END;
/

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

-- This procedure is exclusively used in the script to add the initial restaurants
CREATE OR REPLACE PROCEDURE add_restaurant_from_script (
	restaurant_name IN VARCHAR2,
	delivery_fee IN NUMBER,
	city IN VARCHAR2,
	street IN VARCHAR2,
	houseNumber IN NUMBER,
	category_name IN VARCHAR2,
	menu_name IN VARCHAR2,
	menu_price IN NUMBER)
	AS
		restaurant_id NUMBER;
	BEGIN 
		restaurant_id := seq_restaurant_id.nextval;

		INSERT INTO Restaurants VALUES (restaurant_name, restaurant_id, delivery_fee, city, street, houseNumber);
		INSERT INTO Has_Categories VALUES (category_name, restaurant_id);
		INSERT INTO Menus VALUES (menu_name, restaurant_id, menu_price);
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
		INSERT INTO Users VALUES (client_firstName, client_lastName, client_email, client_phone, client_city, 
                                client_street, client_house);
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
		INSERT INTO Users VALUES (courier_lastName, courier_firstName, courier_email, courier_phone, courier_city, 
                                courier_street, courier_house);
	END IF;

	INSERT INTO Couriers VALUES (courier_email, courier_driverLicense, courier_NIB);
END;
/

-- Procedure to add Orders
CREATE OR REPLACE PROCEDURE insert_order (
	order_id IN NUMBER,
	client_email IN VARCHAR2,
	courier_email IN VARCHAR2,
	tip IN NUMBER,
	restaurant_id IN NUMBER,
	menu_name IN VARCHAR2,
	discount_code IN VARCHAR2
) AS
BEGIN
	order_id

	INSERT INTO Orders VALUES (order_id, client_email, courier_email, tip, 'processing', restaurant_id, SYSDATE);

	INSERT INTO Ordered_Food VALUES (menu_name, restaurant_id, order_id);

	IF discount_code IS NOT NULL
		THEN INSERT INTO Used_Discount VALUES (discount_code, order_id);
	END IF;
END;
/

-- Procedure to update Orders
CREATE OR REPLACE PROCEDURE update_order (
	order_id IN NUMBER,
	newStatus IN VARCHAR2
) AS
BEGIN
  UPDATE Orders 
  SET status = newStatus
  WHERE orderID = order_id;
END;
/

-- Function to calculate total cost of Order
CREATE OR REPLACE FUNCTION order_cost (
	order_id IN NUMBER
)
RETURN NUMBER
IS
	CURSOR menus_price IS SELECT price 
	FROM Ordered_Food INNER JOIN Menus USING (menuName, restaurantID)
	WHERE orderID = order_id;

	menu_price NUMBER (38, 2);
	total_cost NUMBER (38, 2);
	discount_percentage NUMBER (3);
	discount_code VARCHAR2 (30);
	order_tip NUMBER (38, 2);
BEGIN
	total_cost := 0.00;

	FOR mp IN menus_price LOOP
		total_cost := total_cost + mp.price;
	END LOOP;
    
	SELECT code INTO discount_code FROM Used_Discount INNER JOIN Orders USING (orderID);
	
	IF discount_code IS NOT NULL 		
		THEN SELECT percentage INTO discount_percentage FROM Discounts WHERE code = discount_code;
 		total_cost := total_cost - (total_cost * (discount_percentage / 100));
	END IF;

	SELECT tip INTO order_tip FROM Orders WHERE orderID = order_id;
	
	IF order_tip IS NOT NULL
		THEN total_cost := total_cost + order_tip;
	END IF;
	
	RETURN total_cost;
END;
/

-- Views

-- NOTE: In some of the views in the script
-- there is given a specific argument e.g. available_restaraunt = 'Lisbon'
-- but in the APEX implementation we substitute that argument with
-- the one received in a Text Field.

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

-- View for Orders
CREATE OR REPLACE VIEW view_orders AS
SELECT
orderID AS ID,
status AS Status,
order_client.firstName AS Client,
order_courier.firstName AS Courier,
order_restaurant.restaurantName AS Restaurant,
tip AS Tip,
order_discount.code AS DiscountCode
FROM Orders INNER JOIN Users order_client ON (clientEmail = order_client.email)
            INNER JOIN Users order_courier ON (courierEmail = order_courier.email)
						INNER JOIN Restaurants order_restaurant USING (restaurantID)
						LEFT JOIN Used_Discount order_discount USING (orderID);

-- View for Add Menu
CREATE OR REPLACE VIEW add_menu_available AS
SELECT *
FROM Menus;

-- View the restaurants available for a certain user
CREATE OR REPLACE VIEW available_restaurant AS
	SELECT restaurantName
	FROM Clients INNER JOIN Users ON (Clients.email = Users.email) 
                    INNER JOIN Restaurants ON (Users.city = Restaurants.city)
	WHERE Clients.email = 'abc@gmail.com';

-- View the menu from a certain restaurant that has been ordered the most 
CREATE OR REPLACE VIEW most_ordered_menus AS
	SELECT Menus.menuName, COUNT(*) AS number_of_orders
	FROM Restaurants INNER JOIN Menus ON (Restaurants.restaurantID = Menus.restaurantID) 
						INNER JOIN Ordered_Food ON (Ordered_Food.menuName = Menus.menuName AND Ordered_Food.restaurantID = Restaurants.restaurantID)
	WHERE Restaurants.restaurantID = 85 AND ROWNUM <= 1
	GROUP BY Menus.menuName;

-- View the restaurant with the most orders
CREATE OR REPLACE VIEW most_relevant_restaurants AS
	SELECT Restaurants.restaurantID, Restaurants.restaurantName, COUNT(*) AS number_of_orders
	FROM Restaurants INNER JOIN Orders ON (Restaurants.restaurantID = Orders.restaurantID)
	WHERE Orders.status = 'received' AND ROWNUM <= 1
	GROUP BY Restaurants.restaurantID, Restaurants.restaurantName;

-- View the restaurant available for a customer within a certain category
CREATE OR REPLACE VIEW restaurants_within_category AS
	SELECT restaurantName
	FROM Clients INNER JOIN Users USING (email) 
					INNER JOIN Restaurants USING (city)
						INNER JOIN Has_Categories USING (restaurantID)
	WHERE email = 'abc@gmail.com' AND categoryName = 'Sushi';

-- View the restaurants with the highest rating within a certain city
CREATE OR REPLACE VIEW best_restaurant AS
	SELECT Restaurants.restaurantID, Restaurants.restaurantName, AVG(Ratings.stars) AS restaurant_rating
	FROM Restaurants INNER JOIN Orders ON(Restaurants.restaurantID = Orders.restaurantID)
						INNER JOIN Ratings ON (Orders.orderID = Ratings.orderID)
	WHERE Restaurants.city = 'Lisbon' AND ROWNUM <=1
	GROUP BY Restaurants.restaurantID, Restaurants.restaurantName
	ORDER BY restaurant_rating;

-- View the lowest delivery fee
CREATE OR REPLACE VIEW restaurant_lowest_fee AS
	SELECT restaurantName
	FROM Restaurants
	WHERE deliveryFee = (
			SELECT Min (deliveryFee) FROM Restaurants WHERE city = 'Lisbon'
	)
	AND city = 'Lisbon';

-- View the 2 most popular categories
CREATE OR REPLACE VIEW most_popular_category AS 
	SELECT categoryName, COUNT(*) AS restaurants_in_category
	FROM Has_Categories INNER JOIN Restaurants ON (Has_Categories.restaurantID = Restaurants.restaurantID)
	WHERE ROWNUM = 1
	GROUP BY Has_Categories.categoryName;

CREATE OR REPLACE VIEW second_most_popular_category AS 
	SELECT categoryName, COUNT(*) AS restaurants_in_category
	FROM Has_Categories INNER JOIN Restaurants ON (Has_Categories.restaurantID = Restaurants.restaurantID)
	WHERE ROWNUM = 2
	GROUP BY Has_Categories.categoryName;
	

-- View the cities with restaurants of the 2 most popular categories
CREATE OR REPLACE VIEW cities_with AS (
	(
		SELECT Restaurants.city
		FROM Restaurants INNER JOIN Has_Categories ON (Has_Categories.restaurantID = Restaurants.restaurantID)
							INNER JOIN most_popular_category ON (Has_Categories.categoryName = two_most_popular_categories.categoryName)
	)
	INTERSECT
	(
		SELECT Restaurants.city
		FROM Restaurants INNER JOIN Has_Categories ON (Has_Categories.restaurantID = Restaurants.restaurantID)
							INNER JOIN second_most_popular_category ON (Has_Categories.categoryName = two_most_popular_categories.categoryName)
	)
)

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

-- Some restaurants
BEGIN
	add_restaurant_from_script('McDonalds', 1, 'Lisbon', 'Rua', '12', 'Hamburger', 'Big Tasty', 6);
	add_restaurant_from_script('Burger King', 5, 'Lisbon', 'Outra Rua', '62', 'Hamburger', 'Whopper', 7);
	add_restaurant_from_script('Sushi King', 2, 'Almada', 'Rua Outra', '15', 'Sushi', 'Salmon Sushi', 10);
	add_restaurant_from_script('Talking Trees', 2, 'Lisbon', 'Rua LAP', '1', 'Vietnamese', 'Pho', 8);
	add_restaurant_from_script('Tandori', 4, 'Lisbon', 'Rua BD', '44', 'Indian', 'Curry', 8);
	add_restaurant_from_script('Pasta La Vista', 4, 'Lisbon', 'Rua PEE', '90', 'Pasta', 'Bolognese', 10);
	add_restaurant_from_script('Spaghetto', 3, 'Lisbon', 'Rua TC', '7', 'Italian', 'Carbonara', 10);
	add_restaurant_from_script('Wok Noodles', 4, 'Lisbon', 'Rua AM2', '5', 'Chinese', 'Pequin Duck', 6);
END;
/

-- Some Couriers
BEGIN
	insert_courier('Tai', 'Lopez', 'tai@mail.com', 420420421, 'Lisbon', 'Travessa da Cidade', '12', '919235A', 'PT12318231');
	insert_courier('Elon', 'Musk', 'musk@mail.com', 420420422, 'Lisbon', 'Travessa da Cidade', '12', '919235A', 'PT12318232');
	insert_courier('Ash', 'Ketchum', 'ash@mail.com', 420420423, 'Almada', 'Travessa da Cidade', '12', '919235A', 'PT52318231');
	insert_courier('Logan', 'Paul', 'lp@mail.com', 420420424, 'Almada', 'Travessa da Cidade', '12', '919235A', 'PT62318231');
	insert_courier('Nick', 'Crompton', 'nick@mail.com', 420420425, 'Setúbal', 'Travessa da Cidade', '12', '919235A', 'PT72318231');
	insert_courier('Artur', 'Morgano', 'am@mail.com', 420420426, 'Setúbal', 'Travessa da Cidade', '12', '919235A', 'PT17318231');
	insert_courier('Tony', 'Spark', 'spark@mail.com', 420420427, 'New York', 'Travessa da Cidade', '12', '919235A', 'PT82318231');
	insert_courier('John', 'Martstan', 'johnmars@mail.com', 420420428, 'Lisbon', 'Travessa da Cidade', '12', '919235A', 'PT12918231');
END;
/

-- Some Clients
BEGIN
	insert_client('Gabriela', 'Costa', 'gabriela@mail.com', 421421421, 'Lisbon', 'Outra Travessa', '21', 'card');
	insert_client('Artur', 'Dias', 'amd@mail.com', 422422421, 'Almada', 'Travessinha', '22B','card');
	insert_client('David', 'Semedo', 'david@mail.com', 423421421, 'Lisbon', 'Rua Grande', '23C','cash');
	insert_client('Gonçalo', 'Virginia', 'goncalo@mail.com', 424421421, 'Lisbon', 'Rua Pequena', '8', 'card');
	insert_client('Tony', 'Duarte', 'tony@mail.com', 421521421, 'Lisbon', 'Rua Média', '1', 'card');
	insert_client('Carlos', 'Damasio', 'carlos@mail.com', 421621421, 'Almada', 'Rua do Papel', '2', 'card');
	insert_client('Matthias', 'Knorr', 'matthias@mail.com', 421721421, 'Lisbon', 'Rua Interessante', '9', 'card');
	insert_client('John', 'Wick', 'babayaga@mail.com', 421821421, 'New York', 'Central Park', '4', 'card');
	insert_client('Miguel', 'Real', 'mr@mail.com', 421921421, 'Setúbal', 'Rua do Choco Frito', '78', 'card');
	insert_client('Eren', 'Jaeger', 'ejaeger@mail.com', 421021421, 'Setúbal', 'Mais Choco Frito', '99', 'cash');
END;
/

-- Some Menus
INSERT INTO Menus VALUES ('Sashimi', get_restaurant_ID('Sushi King'), 10);
INSERT INTO Menus VALUES ('Sushi roll', get_restaurant_ID('Sushi King'), 7);
INSERT INTO Menus VALUES ('Burger', get_restaurant_ID('McDonalds'), 1);
INSERT INTO Menus VALUES ('Pho ga', get_restaurant_ID('Talking Trees'), 15);
INSERT INTO Menus VALUES ('Tikka masala', get_restaurant_ID('Tandori'), 13);
INSERT INTO Menus VALUES ('Pasta', get_restaurant_ID('Pasta La Vista'), 20);
INSERT INTO Menus VALUES ('Lasagna', get_restaurant_ID('Spaghetto'), 8);
INSERT INTO Menus VALUES ('Stir fry', get_restaurant_ID('Wok Noodles'), 10);

-- Some Discounts
INSERT INTO Discounts VALUES ('koJbqIsyYVf2ZPvptNkR', 30);
INSERT INTO Discounts VALUES ('YmXudLqKqFuo2gVx7T3E', 10);
INSERT INTO Discounts VALUES ('C6vmreSZh7d32ng2YXim', 20);
INSERT INTO Discounts VALUES ('hWDUgM5nxV8EqZSG8BTJ', 10);
INSERT INTO Discounts VALUES ('FOROuUrbc7IqukfEYm0m', 5);

-- Give users discounts
BEGIN 
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'gabriela@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'amd@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'david@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'goncalo@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'tony@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'carlos@mail.com');
	add_discount_client('koJbqIsyYVf2ZPvptNkR', 'matthias@mail.com');
END;
/

-- Some Orders
BEGIN
  insert_order(seq_order_id.nextval, 'gabriela@mail.com', 'tai@mail.com', 12, get_restaurant_ID('Burger King'), 'Whopper', 'koJbqIsyYVf2ZPvptNkR');
  insert_order(seq_order_id.nextval, 'gabriela@mail.com', 'musk@mail.com', 0, get_restaurant_ID('Talking Trees'), 'Pho ga', );
  insert_order(seq_order_id.nextval, 'amd@mail.com', 'lp@mail.com', 5, get_restaurant_ID('Sushi King'), 'Sashimi', 'koJbqIsyYVf2ZPvptNkR');
  insert_order(seq_order_id.nextval, 'david@mail.com', 'johnmars@mail.com', 1, get_restaurant_ID('Tandori'), 'Curry', 'koJbqIsyYVf2ZPvptNkR');
  insert_order(seq_order_id.nextval, 'goncalo@mail.com', 'tai@mail.com', 6, get_restaurant_ID('Wok Noodles'), 'Stir fry', 'koJbqIsyYVf2ZPvptNkR');
  insert_order(seq_order_id.nextval, 'goncalo@mail.com', 'musk@mail.com', 9, get_restaurant_ID('Burger King'), 'Whopper', );
  insert_order(seq_order_id.nextval, 'goncalo@mail.com', 'johnmars@mail.com', 10, get_restaurant_ID('Burger King'), 'Whopper', );
  insert_order(seq_order_id.nextval, 'carlos@mail.com', 'ash@mail.com', 17, get_restaurant_ID('Sushi King'), 'Sashimi', 'koJbqIsyYVf2ZPvptNkR');
  insert_order(seq_order_id.nextval, 'gabriela@mail.com', 'tai@mail.com', 3, get_restaurant_ID('Wok Noodles'), 'Stir fry', );
  insert_order(seq_order_id.nextval, 'tony@mail.com', 'tai@mail.com', 21, get_restaurant_ID('Burger King'), 'Whopper', 'koJbqIsyYVf2ZPvptNkR');
END;
/

-- Updating some of the orders
BEGIN 
	update_order(1, 'received');
	update_order(2, 'received');
	update_order(4, 'received');
	update_order(5, 'received');
	update_order(7, 'received');
END;
/


-- Adding ratings to orders
INSERT INTO Ratings VALUES (4, 'Nice', 1);
INSERT INTO Ratings VALUES (1, 'Awful', 2);
INSERT INTO Ratings VALUES (5, 'Fantastic', 4);
INSERT INTO Ratings VALUES (4, 'Great food', 5);
INSERT INTO Ratings VALUES (2, 'Meh', 7);