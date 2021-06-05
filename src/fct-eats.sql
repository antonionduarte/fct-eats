-- Create tables and Restrictions

CREATE TABLE Ratings (
    stars NUMBER(1)
    compliment VARCHAR2(100)
	orderId NUMBER(20)
)

ALTER TABLE Ratings ADD CONSTRAINT valid_stars CHECK (stars BETWEEN 1 AND 5);
ALTER TABLE Ratings ADD CONSTRAINT pk_rating PRIMARY KEY (compliment);
ALTER TABLE Ratings ADD CONSTRAINT fk_rating FOREIGN KEY (orderId) REFERENCES Orders (orderId);

CREATE TABLE Has_Discount (
    email VARCHAR2(256)
    code VARCHAR2(30)
	discountState VARCHAR2(10)
)

ALTER TABLE Has_Discount ADD CONSTRAINT fk_email FOREIGN KEY (email) REFERENCES Clients (email);
ALTER TABLE Has_Discount ADD CONSTRAINT fk_code FOREIGN KEY (code) REFERENCES Discounts (code);

CREATE TABLE Ordered_Food (
	menuName VARCHAR2(50)
	restaurantName VARCHAR2(50)
	orderId NUMBER(20)
)

ALTER TABLE Ordered_Food ADD CONSTRAINT fk_menuName FOREIGN KEY (menuName) REFERENCES Menus (menuName);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_restaurantName FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);
ALTER TABLE Ordered_Food ADD CONSTRAINT fk_orderId FOREIGN KEY (orderId) REFERENCES Orders (orderId);

CREATE TABLE Has_Categories (
    categoryName VARCHAR2(50)
	restaurantName VARCHAR2(50)
)

ALTER TABLE Has_Categories ADD CONSTRAINT fk_categoryName FOREIGN KEY (categoryName) REFERENCES Categories (categoryName);
ALTER TABLE Has_Categories ADD CONSTRAINT fk_restaurantName FOREIGN KEY (restaurantName) REFERENCES Restaurants (restaurantName);

CREATE TABLE Used_Discount (
    code VARCHAR2(30)
	orderId NUMBER(20)
)

ALTER TABLE Used_Discount ADD CONSTRAINT fk_code FOREIGN KEY (code) REFERENCES Discounts (code);
ALTER TABLE Used_Discount ADD CONSTRAINT fk_orderId FOREIGN KEY (orderId) REFERENCES Orders (orderId);

-- Triggers

-- Functions and Views

-- Insertions