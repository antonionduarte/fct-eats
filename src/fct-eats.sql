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

-- Courier table
CREATE TABLE Couriers (
	email VARCHAR2 (256),
	driverLicense VARCHAR2 (12),
	NIB VARCHAR2 (22)
);

ALTER TABLE Couriers ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE Couriers ADD CONSTRAINT pk_courier PRIMARY KEY (email);
ALTER TABLE Couriers ADD CONSTRAINT fk_courier FOREIGN KEY (email) REFERENCES Users(email);
ALTER TABLE Couriers ADD CONSTRAINT null_courier NOT NULL (email, driverLicense, NIB)

-- Category table
CREATE TABLE Categories (
	categoryName VARCHAR2 (30)
);

ALTER TABLE Categories ADD CONSTRAINT pk_category PRIMARY KEY (categoryName);
ALTER TABLE Categories ADD CONSTRAINT null_category NOT NULL (categoryName); 

-- Triggers

-- Functions and Views

-- Insertions