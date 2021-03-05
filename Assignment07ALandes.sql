--*************************************************************************--
-- Title: Assignment07
-- Author: ALandes
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-03-02: ALandes, Question 1 - Added a Select statement to list the product name and unit price from the Products view 
-- 2021-03-02: ALandes, Question 1 - Formatted the unit price using Format to show the price in US dollars
-- 2021-03-02: ALandes, Question 2 - Joined the Products and Category views and built off of code from Question 1
-- 2021-03-03: ALandes, Question 3 - Joined Products and Inventory Views and used Format function to change InventoryDate format 
-- 2021-03-03: ALandes, Question 4 - Used Question 3 code and created a view called vProductInventories
-- 2021-03-03: ALandes, Question 5 - Created a view called vCategoryInventories that joins the Categories, Inventories, and Products views
-- 2021-03-03: ALandes, Question 6 - Created a view called vProductInventoriesWithPreviousMonthCounts
-- 2021-03-03: ALandes, Question 6 - Used an IIF statement that changes January to 0 if true and if false, the entry shows the inventorycount from previous month
-- 2021-03-04: ALandes, Question 7 - Created view called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- 2021-03-04: ALandes, Question 7 - Created CountVsPreviousCountKPI which tests the inventory counts and sets it to 0, 1, or -1 pending on equation
-- 2021-03-04: ALandes, Question 8 - Created UDF fProductInventoriesWithPreviousMonthCountsWithKPIs
-- 2021-03-04: ALandes, Question 8 - UDF checks @CountVsPreviousCountKPI input and checks it against the CountVsPreviousCountKPI from view in Question 7
-- 2021-03-04: ALandes, Question 8 - Added OrderBy statement but couldn't get it to work due to the call for a view "v1" - is this a test? :)
-- 2021-03-04: ALandes, Question 8 - Kept trying to change the OrderBy statement. No errors prior to running the 3 Select statements at the end of the code for Question 8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ALandes')
	 Begin 
	  Alter Database [Assignment07DB_ALandes] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ALandes;
	 End
	Create Database Assignment07DB_ALandes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ALandes;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
/*
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
*/
-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

Select
[ProductName] = P.ProductName,
[UnitPrice] = Format(P.UnitPrice, 'C', 'en-US') 
From vProducts as P
Order By P.ProductName;
Go 

-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

Select
[CategoryName] = C.CategoryName,
[ProductName] = P.ProductName,
[UnitPrice] = Format(P.UnitPrice, 'C', 'en-US') 
    From vCategories as C
    Inner Join vProducts as P
        On C.CategoryID = P.CategoryID
    Order By C.CategoryName, P.ProductName;
Go 

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

Select
[ProductName] = P.ProductName,
[InventoryDate] = Format(I.InventoryDate, 'MMMM, yyyy'), 
[InventoryCount] = I.Count
    From vProducts as P
    Inner Join vInventories as I
        On P.ProductID = I.ProductID
    Order By P.ProductName, I.InventoryDate, I.Count;
Go 

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

Create or Alter View vProductInventories As 
    Select
    [ProductName] = P.ProductName,
    [InventoryDate] = Format(I.InventoryDate, 'MMMM, yyyy'), 
    [InventoryCount] = I.Count
        From vProducts as P
        Inner Join vInventories as I
            On P.ProductID = I.ProductID;
Go  

-- Check that it works: Select * From vProductInventories;
Select * From vProductInventories Order By ProductName, InventoryDate, InventoryCount;
Go

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

Create or Alter View vCategoryInventories As
    Select
    [CategoryName] = C.CategoryName,
    [InventoryDate] = Format(I.InventoryDate, 'MMMM, yyyy'),
    [InventoryCountByCategory] = Sum(I.Count)
        From vCategories as C
   	    Inner Join vProducts as P
		    On C.CategoryID = P.CategoryID
	    Inner Join vInventories as I
		    On P.ProductID = I.ProductID
        Group By CategoryName, InventoryDate;
Go

-- Check that it works: Select * From vCategoryInventories;
Select * From vCategoryInventories Order By CategoryName;
Go

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or January counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

Create or Alter View vProductInventoriesWithPreviousMonthCounts As 
    Select 
    ProductName,
    InventoryDate,
    InventoryCount,
    -- Use a functions to set any null counts or January counts to zero.
    [PreviousMonthCount] = IIF(InventoryDate Like 'January%',0, Lag(InventoryCount) Over (Order By ProductName))
        From vProductInventories;
Go 

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCounts;
Go 

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!

Create or Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs As
    Select 
    ProductName, 
    InventoryDate, 
    InventoryCount, 
    PreviousMonthCount,
    [CountVsPreviousCountKPI] = Case 
        When InventoryCount > PreviousMonthCount Then 1
        When InventoryCount = PreviousMonthCount Then 0
        When InventoryCount < PreviousMonthCount Then -1
        End 
    From vProductInventoriesWithPreviousMonthCounts;
    Go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go 

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

IF OBJECT_ID (N'fProductInventoriesWithPreviousMonthCountsWithKPIs', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs;
Go 

Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI int)
    Returns int 
    As
-- Returns a table with a specific @KPI number from the ProductInventoriesWithPreviousMonthCountsWithKPIs view
        Begin
            Declare @ret int;
            Select 
            @ret = [CountVsPreviousCountKPI]
            From vProductInventoriesWithPreviousMonthCountsWithKPIs
            Where @CountVsPreviousCountKPI = [CountVsPreviousCountKPI]
            Return 
            (
                Select 
                ProductName, 
                InventoryDate, 
                InventoryCount,
                PreviousMonthCount,
                dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(CountVsPreviousCountKPI) As CountVsPreviousCountKPI
                From vProductInventoriesWithPreviousMonthCountsWithKPIs )
        End 
Go 
-- I am trying to get the code to work, but the code is not recognizing the v1
-- I am not sure if this is a test, but I know the code is not working because a 
-- view named v1 was not created. 
Select dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1) Order By Year(Cast(v1.InventoryDate as Date));
Go 

Select dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0) Order By Year(Cast(v1.InventoryDate as Date));
Go 

Select dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1) Order By Year(Cast(v1.InventoryDate as Date));
Go

/***************************************************************************************/