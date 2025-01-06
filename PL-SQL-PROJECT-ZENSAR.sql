-- Food Delivery Management System

CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Address VARCHAR2(255),
    PhoneNumber VARCHAR2(15)
);

CREATE TABLE Restaurants (
    RestaurantID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Address VARCHAR2(255),
    PhoneNumber VARCHAR2(15)
);

CREATE TABLE DeliveryAgents (
    AgentID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    PhoneNumber VARCHAR2(15),
    Status VARCHAR2(10) DEFAULT 'Available'
);

CREATE TABLE Orders (
    OrderID NUMBER PRIMARY KEY,
    CustomerID NUMBER REFERENCES Customers(CustomerID),
    RestaurantID NUMBER REFERENCES Restaurants(RestaurantID),
    AgentID NUMBER REFERENCES DeliveryAgents(AgentID),
    OrderStatus VARCHAR2(50),
    OrderTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    DeliveryTime TIMESTAMP
);

INSERT INTO Customers VALUES (1, 'Aryan Sable', '01 near sb college Sangamner', '1234567890');
INSERT INTO Customers VALUES (2, 'Amit Patil', '02 Manglapur  ', '9876543210');
INSERT INTO Customers VALUES (3, 'Tejandra Patil', '03 near abc road Sangamner', '5554455112');
INSERT INTO Customers VALUES (4, 'Sujal Sahane', '03 sukewadi Sangmner', '2699412323');
INSERT INTO Customers VALUES (5, 'Yash Patil', '04 near amruteshwar madir Sangmner', '5454221212');
INSERT INTO Customers VALUES (6, 'Kushal Patil', '05 near SMBT Dental College Sangmner', '4556412111');
INSERT INTO Customers VALUES (7, 'Avdhoot Wakale', '06 Amrutvahini college of engineering,Ghulewadi Sangmner', '4155152322');
INSERT INTO Customers VALUES (8, 'Mithanshu Shinde', '07 Gunjalwadi Sangmner', '9114482322');

INSERT INTO Restaurants VALUES (1, 'Hotel Sudhir', 'Near pune-nashik highway', '5687821256');
INSERT INTO Restaurants VALUES (2, 'Hotel Prasad ', 'Near law college', '6556123165');
INSERT INTO Restaurants VALUES (3, 'Dominos Pizza', 'near sahyadri college', '5148584144');
INSERT INTO Restaurants VALUES (4, 'Hotel Padmavati', 'next to malpani lawns', '5557886543');
INSERT INTO Restaurants VALUES (5, 'Hotel Nisarg', 'near SMBT Dental college', '4515122222');


INSERT INTO DeliveryAgents VALUES (1, 'ramesh', '5456451212', 'Available');
INSERT INTO DeliveryAgents VALUES (2, 'sushant', '4454655132', 'Available');
INSERT INTO DeliveryAgents VALUES (3, 'abdul', '8984511254', 'Available');
INSERT INTO DeliveryAgents VALUES (4, 'suresh', '54453321321', 'Available');
INSERT INTO DeliveryAgents VALUES (5, 'suyash', '57453381329', 'Available');

INSERT INTO Orders (OrderID, CustomerID, RestaurantID, OrderStatus) VALUES (1, 1, 1, 'Pending');
INSERT INTO Orders (OrderID, CustomerID, RestaurantID, OrderStatus) VALUES (2, 2, 2, 'Pending');
INSERT INTO Orders (OrderID, CustomerID, RestaurantID, OrderStatus) VALUES (3, 3, 3, 'Pending');
INSERT INTO Orders (OrderID, CustomerID, RestaurantID, OrderStatus) VALUES (4, 4, 4, 'Pending');



SELECT RestaurantID,AVG(EXTRACT(MINUTE FROM (DeliveryTime - OrderTime))) AS AvgDeliveryMinutes
FROM Orders
WHERE DeliveryTime IS NOT NULL
GROUP BY RestaurantID;

CREATE OR REPLACE TRIGGER UpdateOrderStatus
AFTER UPDATE OF DeliveryTime ON Orders
FOR EACH ROW
BEGIN
    IF :NEW.DeliveryTime IS NOT NULL THEN
        UPDATE Orders
        SET OrderStatus = 'Delivered'
        WHERE OrderID = :NEW.OrderID;
    END IF;
END;


CREATE OR REPLACE PROCEDURE AssignDeliveryAgent (
    p_OrderID IN NUMBER
) AS
    v_AgentID NUMBER;
BEGIN
    SELECT AgentID
    INTO v_AgentID
    FROM DeliveryAgents
    WHERE Status = 'Available'
    AND ROWNUM = 1;

    IF v_AgentID IS NOT NULL THEN
        UPDATE Orders
        SET AgentID = v_AgentID,
            OrderStatus = 'Assigned'
        WHERE OrderID = p_OrderID;

        UPDATE DeliveryAgents
        SET Status = 'Busy'
        WHERE AgentID = v_AgentID;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'No available delivery agents.');
    END IF;
END;




BEGIN
    AssignDeliveryAgent(1);
    AssignDeliveryAgent(2);
    AssignDeliveryAgent(3);
    AssignDeliveryAgent(4);
END;

SELECT * FROM Orders;
SELECT * FROM DeliveryAgents;
