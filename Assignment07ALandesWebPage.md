##### Anya Landes
##### March 4, 2021
##### IT FDN 130 A
##### Assignment 7

# SQL Functions

## Introduction 

In this assignment, I will explain when user defined functions (UDF) are useful, as well as the different types that can be utilized within SQL. 

## SQL UDF
UDFs are useful when a SQL user is trying to perform an action within SQL multiple times. By defining a new function, executing functions is quicker than writing out code to execute multiple functions and it makes the code easier to read by another user. 

## Scalar Function 
Scalar functions are a UDF that returns a singular value, such as the weight of produce purchased at a supermarket. In Figure 1, the format for creating a scalar function is shown (SQL Server Scalar Functions, https://www.sqlservertutorial.net/sql-server-user-defined-functions/sql-server-scalar-functions/) (External Link). 

![Figure 1](https://github.com/itsanyamarie/DBFoundations-Module07/blob/main/ScalarUDFImage.jpg)

###### Figure 1: Scalar Function Example

## Multi-Statement Function
Next, a multi-statement function returns rows within a table. As seen in Figure 2, the table structure is defined by the user within the function. This function benefits the user by allowing the user to make modifications a complicated resulting table (SQL Server multi-statement table-valued functions, https://www.sqlshack.com/sql-server-multi-statement-table-valued-functions/) (External Link).

![Figure 2](https://github.com/itsanyamarie/DBFoundations-Module07/blob/main/ScalarUDFImage.jpg)

###### Figure 2: Multi-Statement Function Example

## Inline Function 
Lastly, “an inline function returns a table object based on a single SELECT statement that is contained within a return clause” (SQL Server User Defined Function Overview, https://www.mssqltips.com/sqlservertip/6176/sql-server-user-defined-function-overview/ ) (External Link). In Figure 3, an inline table-valued function, GetAuthorsByState, was created with an input, @state, that returns a table showing an author’s first name and last name when the input variable equals a state. This example showcases how the function is using an input variable and comparing it to a column in the Authors dataset (User-Defined Functions, https://sqlhints.com/tag/inline-table-valued-user-defined-function/) (External Link).

![Figure 3](https://github.com/itsanyamarie/DBFoundations-Module07/blob/main/InlineUDF.jpg)

###### Figure 3: Inline Function Example
 
## Summary
In conclusion, a UDF allows a SQL user to create functions so that they may repeat actions within their code more quickly. There are three different types of UDFs that can be used pending the motivation of the user: scalar, inline, multi-statement. 
