CREATE DATABASE Project_Trans;
go

Use  Project_Trans;
go



CREATE TABLE Truck (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Plate NVARCHAR(10) UNIQUE NOT NULL,
    Model_B NVARCHAR(20),
    Max_Truck_Weight_F1 INT,
    Max_Weight_F3 INT,
    Truck_Weight_G INT,
    Category_J NVARCHAR(20),
    Power_KW_Q INT
);

CREATE TABLE Trailer (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Plate NVARCHAR(10) UNIQUE NOT NULL,
    Model_B NVARCHAR(20),
    Max_Trailer_Weight_F1 INT,
    Trailer_Weight_G INT,
    Category_J NVARCHAR(15),
    Remarks NVARCHAR(20)
);

CREATE TABLE Locations (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(50),
    City NVARCHAR(50),
    Zip NVARCHAR(10),
    Address NVARCHAR(100),
    Remarks NVARCHAR(100)
);



CREATE TABLE Company_Data (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Location_ID INT NOT NULL,
    Company_Name NVARCHAR(30),
    Tax_Number NVARCHAR(15),
    Bank_Account_Number NVARCHAR(30),
    Remarks NVARCHAR(50),
    CONSTRAINT FK_CompanyData_Location FOREIGN KEY (Location_ID)
        REFERENCES Locations(ID)
);

CREATE TABLE Freight (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Truck_ID INT NOT NULL,
    Trailer_ID INT NULL,
    CONSTRAINT FK_Freight_Truck FOREIGN KEY (Truck_ID)
        REFERENCES Truck(ID),
    CONSTRAINT FK_Freight_Trailer FOREIGN KEY (Trailer_ID)
        REFERENCES Trailer(ID)
);

CREATE TABLE Shipment (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Freight_ID INT NOT NULL,
    Freight_Type NVARCHAR(20),
    Order_Number NVARCHAR(20),
    Reference_Number NVARCHAR(20),
    Shipment_Name NVARCHAR(50),
    Quantity INT,
    Packaging_Type NVARCHAR(20),
    Shipment_Weight INT,
    Shipment_Status NVARCHAR(20),
    Loading_Date DATE,
    Loading_Address_ID INT NOT NULL,
    Unloading_Date DATE,
    Unloading_Location_ID INT NOT NULL,
    CONSTRAINT FK_Shipment_Freight FOREIGN KEY (Freight_ID)
        REFERENCES Freight(ID),
    CONSTRAINT FK_Shipment_LoadingLocation FOREIGN KEY (Loading_Address_ID)
        REFERENCES Locations(ID),
    CONSTRAINT FK_Shipment_UnloadingLocation FOREIGN KEY (Unloading_Location_ID)
        REFERENCES Locations(ID)
);

CREATE TABLE Proceeds (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Company_Data_ID INT NOT NULL,
    Shipment_ID INT NOT NULL,
    Amount DECIMAL(12,2),
    Currency NVARCHAR(4),
    Payment_Date DATE,
    CONSTRAINT FK_Proceeds_Company FOREIGN KEY (Company_Data_ID)
        REFERENCES Company_Data(ID),
    CONSTRAINT FK_Proceeds_Shipment FOREIGN KEY (Shipment_ID)
        REFERENCES Shipment(ID)
);


CREATE TABLE Costs (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Remarks NVARCHAR(40),
    Invoice_Number NVARCHAR(20),
    Amount DECIMAL(12,2),
    Currency NVARCHAR(4),
    Payment_Date DATE,
    Company_Data_ID INT NOT NULL,
    CONSTRAINT FK_Costs_Company FOREIGN KEY (Company_Data_ID)
        REFERENCES Company_Data(ID)
);


CREATE TABLE ProceedsLogtable (
    Insert_date datetime2(0) , 
    Remarks NVARCHAR (15)
);

CREATE TABLE ShipmentLogtable (
    Insert_date datetime2(0) , 
    Remarks NVARCHAR (15)
);
GO

CREATE OR ALTER TRIGGER ProceedsLogtableTrigger on Proceeds AFTER INSERT
AS
BEGIN
	INSERT INTO ProceedsLogtable (Insert_date,Remarks) 
	select GETDATE(), CONCAT (ID, '	-	', Amount) FROM inserted
	END
    SET NOCOUNT ON;
	GO



CREATE OR ALTER TRIGGER ShipmentLogtableTrigger on Shipment AFTER INSERT
	AS
	BEGIN
		INSERT INTO ShipmentLogtable (Insert_date,Remarks) 
		select GETDATE(), CONCAT (ID, '	-	', Freight_ID) FROM inserted
	END
    SET NOCOUNT ON;
	GO


CREATE VIEW  CurrentShipmentStatusView
AS
    SELECT	t.PLATE AS Truck_Plate,Tr.PLATE AS Trailer_Plate, S.Freight_ID,s.id AS Shipment_ID,s.Freight_Type, s.Shipment_Name,s.Quantity,s.Packaging_Type,s.Shipment_Status, loadLoc.Country AS Loading_Country,s.Loading_Date,
    unloadLoc.Country AS Unloading_Country, s.Unloading_Date	FROM Shipment S 
JOIN Locations AS loadLoc 
    ON s.Loading_Address_ID = loadLoc.ID
JOIN Locations AS unloadLoc 
    ON s.Unloading_Location_ID = unloadLoc.ID
JOIN Freight F 
    ON f.ID=s.Freight_ID
JOIN Truck T 
    ON t.ID=f.Truck_ID
JOIN Trailer Tr 
    ON TR.ID=f.Trailer_ID
    WHERE Shipment_Status != 'Scheduled' AND Shipment_Status <>'Unloaded';
GO

CREATE VIEW MonthlyRevenueView
AS
    SELECT  SUM (Amount) Összeg,MONTH(Payment_Date) Hónap  FROM Proceeds
        WHERE YEAR(Payment_Date)= '2025'
        GROUP BY MONTH(payment_date);
    GO


CREATE VIEW TopCustomersView
    AS
    SELECT TOP 10 Company_Name, COUNT(*) DB   FROM Company_Data CD
    JOIN Proceeds P
        ON  CD.ID=P.Company_Data_ID
        GROUP BY Company_Name
    ORDER BY DB DESC;
    GO

    CREATE INDEX FreightTruckID_IX
        ON Freight (Truck_ID);
        GO

 CREATE INDEX FreightTrailerID_IX
        ON Freight (Trailer_ID);
        










