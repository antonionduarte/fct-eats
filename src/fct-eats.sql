-- Create tables and Restrictions

-- Address table
CREATE TABLE Address (
	city TEXT,
	street TEXT,
	houseNumber NUMBER (3,0)
)

ALTER TABLE Address ADD CONSTRAINT pk_address PRIMARY KEY (city, street, houseNumber);
ALTER TABLE Address ADD CONSTRAINT null_address NOT NULL (city, street, houseNumber);

-- Users table
CREATE TABLE Users (
	email VARCHAR2 (256),
	phoneNumber NUMBER (9, 0),
	city TEXT,
	street TEXT NOT,
	houseNumber NUMBER (3, 0)
);

ALTER TABLE ADD CONSTRAINT unique_city UNIQUE (city, street, houseNumber);
ALTER TABLE Users ADD CONSTRAINT pk_user PRIMARY KEY (email); 
ALTER TABLE Users ADD CONSTRAINT fk_city FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Users ADD CONSTRAINT null_user NOT NULL (email, phoneNumber, city, street, houseNumber);

-- Clients table
CREATE TABLE Clients (
	email VARCHAR2 (256),
	paymentMethod TEXT
);

ALTER TABLE Clients ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE Clients ADD CONSTRAINT pk_client PRIMARY KEY (email);
ALTER TABLE Clients ADD CONSTRAINT fk_client FOREIGN KEY (email) REFERENCES Users (email); 
ALTER TABLE Clients ADD CONSTRAINT null_client NOT NULL (email, paymentMethod)

-- Couriers table
CREATE TABLE Couriers (
	email VARCHAR2 (256),
	driverLicense VARCHAR2 (12),
	NIB VARCHAR2 (22)
);

ALTER TABLE Couriers ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE Couriers ADD CONSTRAINT pk_courier PRIMARY KEY (email);
ALTER TABLE Couriers ADD CONSTRAINT fk_courier FOREIGN KEY (email) REFERENCES Users (email);
ALTER TABLE Couriers ADD CONSTRAINT null_courier NOT NULL (email, driverLicense, NIB)

-- Categories table
CREATE TABLE Categories (
	categoryName VARCHAR2 (30)
);

ALTER TABLE Categories ADD CONSTRAINT pk_category PRIMARY KEY (categoryName);
ALTER TABLE Categories ADD CONSTRAINT null_category NOT NULL (categoryName); 

-- Menus table
CREATE TABLE Menus ( 
	menuName VARCHAR2(30),
	restaurantName VARCHAR(30),
	price NUMBER(3,2) 
);

ALTER TABLE Menus ADD CONSTRAINT pk_menus PRIMARY KEY (menuName, restaurantName);
ALTER TABLE Menus ADD CONSTRAINT unique_menus UNIQUE (menuName);
ALTER TABLE Menus ADD CONSTRAINT fk_menus FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Menus ADD CONSTRAINT null_menus NOT NULL (restaurantName, price);
ALTER TABLE Menus ADD CONSTRAINT positive_price CHECK (price >= 0);

-- Orders table
CREATE TABLE Orders ( 
	orderID INTEGER,
	clientEmail VARCHAR2 (254),
	courierEmail VARCHAR2 (254),
	tip NUMBER (3,2),
	status VARCHAR2 (10) 
);

ALTER TABLE Orders ADD CONSTRAINT pk_order PRIMARY KEY (orderID);
ALTER TABLE Orders ADD CONSTRAINT unique_orderID UNIQUE (orderID);
ALTER TABLE Orders ADD CONSTRAINT positive_orderID CHECK (orderID >= 0);
ALTER TABLE Orders ADD CONSTRAINT fk_order1 FOREIGN KEY (clientEmail) REFERENCES Clients (clientEmail);
ALTER TABLE Orders ADD CONSTRAINT fk_order2 FOREIGN KEY (courierEmail) REFERENCES Couriers (courierEmail);
ALTER TABLE Orders ADD CONSTRAINT positive_tip CHECK (tip >= 0);
ALTER TABLE Orders ADD CONSTRAINT valid_status CHECK (status IN ("received", "processing", "en route"));
ALTER TABLE Orders ADD CONSTRAINT null_order NOT NULL (clientEmail, courierEmail, tip, status);

-- Vehicles table
CREATE TABLE Vehicles (
	regNumber CHAR(6),
	vehicleType TEXT,
	courierEmail VARCHAR2(254) 
);

ALTER TABLE Vehicles ADD CONSTRAINT pk_vehicles PRIMARY KEY (regNumber);
ALTER TABLE Vehicles ADD CONSTRAINT fk_vehicles FOREIGN KEY (courierEmail) REFERENCES Couriers (courierEmail);
ALTER TABLE Vehicles ADD CONSTRAINT null_vehicles NOT NULL (vehicleType, courierEmail);

-- Restaurants table
CREATE TABLE Restaurants ( 
	restaurantName TEXT,
	deliveryFee NUMBER (2,2),
	city TEXT,
	street TEXT,
	houseNumber TEXT
);

ALTER TABLE Restaurants ADD CONSTRAINT pk_restaurant PRIMARY KEY (restaurantName);
ALTER TABLE Restaurants ADD CONSTRAINT unique_restaurantName UNIQUE (restaurantName);
ALTER TABLE Restaurants ADD CONSTRAINT fk_restaurant FOREIGN KEY (city, street, houseNumber) REFERENCES Address (city, street, houseNumber);
ALTER TABLE Restaurants ADD CONSTRAINT null_restaurant NOT NULL (deliveryFee, city, street, houseNumber);
ALTER TABLE Restaurants ADD CONSTRAINT positive_deliveryFee CHECK (deliveryFee >= 0);

-- Discounts table
CREATE TABLE Discounts ( 
	code TEXT,
	percentage NUMBER (3,2) 
);

ALTER TABLE Discounts ADD CONSTRAINT pk_discounts PRIMARY KEY (code);
ALTER TABLE Discounts ADD CONSTRAINT null_discounts NOT NULL (percentage);
ALTER TABLE Discounts ADD CONSTRAINT positive_percentage CHECK (percentage >= 0); 

-- Triggers

-- Functions and Views

-- Insertions