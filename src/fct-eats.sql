-- Create tables and Restrictions

CREATE TABLE Menus( menuName VARCHAR2(30),
                    restaurantName VARCHAR(30),
                    price NUMBER(3,2) );

ALTER TABLE Menus ADD CONSTRAINT pk_menus PRIMARY KEY (menuName, restaurantName);
ALTER TABLE Menus ADD CONSTRAINT unique_menus UNIQUE (menuName);
ALTER TABLE Menus ADD CONSTRAINT fk_menus FOREIGN KEY (restaurantName) REFERENCES Restaurant(restaurantName);
ALTER TABLE Menus ADD CONSTRAINT null_menus NOT NULL (restaurantName, price);
ALTER TABLE Menus ADD CONSTRAINT positive_price CHECK (price >= 0);

CREATE TABLE Order( orderID INTEGER,
                    clientEmail VARCHAR2(254),
                    courierEmail VARCHAR2(254),
                    tip NUMBER(3,2),
                    status VARCHAR2(10) );

ALTER TABLE Order ADD CONSTRAINT pk_order PRIMARY KEY(orderID);
ALTER TABLE Order ADD CONSTRAINT unique_orderID UNIQUE (orderID);
ALTER TABLE Order ADD CONSTRAINT fk_order1 FOREIGN KEY(clientEmail) REFERENCES Clients(clientEmail);
ALTER TABLE Order ADD CONSTRAINT fk_order2 FOREIGN KEY(courierEmail) REFERENCES Couriers(courierEmail);
ALTER TABLE Order ADD CONSTRAINT positive_tip CHECK(tip >= 0);
ALTER TABLE Order ADD CONSTRAINT valid_status CHECK(status IN("received", "processing", "en route"));
ALTER TABLE oRDER ADD CONSTRAINT null_order NOT NULL (clientEmail, courierEmail, tip, status);

CREATE TABLE Vehicles( regNumber CHAR(6),
                        vehicleType TEXT,
                        courierEmail VARCHAR2(254) );

ALTER TABLE Vehicles ADD CONSTRAINT pk_vehicles PRIMARY KEY (regNumber);
ALTER TABLE Vehicles ADD CONSTRAINT fk_vehicles FOREIGN KEY (courierEmail) REFERENCES Couriers(courierEmail);
ALTER TABLE Vehicles ADD CONSTRAINT null_vehicles NOT NULL (vehicleType, courierEmail);

CREATE TABLE Restaurant( restaurantName TEXT,
                            deliveryFee NUMBER(2,2),
                            city TEXT,
                            street TEXT,
                            houseNumber TEXT );

ALTER TABLE Restaurant ADD CONSTRAINT pk_restaurant PRIMARY KEY (restaurantName);
ALTER TABLE Restaurant ADD CONSTRAINT unique_restaurantName UNIQUE (restaurantName);
ALTER TABLE Restaurant ADD CONSTRAINT fk_restaurant FOREIGN KEY (city, street, houseNumber) REFERENCES Address(city, street, houseNumber);
ALTER TABLE Restaurant ADD CONSTRAINT null_restaurant NOT NULL (deliveryFee, city, street, houseNumber);
ALTER TABLE Restaurant ADD CONSTRAINT positive_deliveryFee CHECK (deliveryFee >= 0);

CREATE TABLE Discounts( code TEXT,
                        percentage NUMBER(3,2) );

ALTER TABLE Discounts ADD CONSTRAINT pk_discounts PRIMARY KEY (code);
ALTER TABLE Discounts ADD CONSTRAINT null_discounts NOT NULL (percentage);
ALTER TABLE Discounts ADD CONSTRAINT positive_percentage CHECK (percentage >= 0); 

-- Triggers

-- Functions and Views

-- Insertions