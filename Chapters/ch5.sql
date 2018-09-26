/* ********** SQL FOR MERE MORTALS CHAPTER 5 *********** */
/* ******** GETTING MORE THAN SIMPLE COLUMNS  ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Using Expressions in a Select Clause     ****/
/* ******************************************** ****/
-- Show me a current list of our employees and their phone numbers.
SELECT (EmpFirstName || ' ' || EmpLastName) AS Name, EmpPhoneNumber
FROM salesordersexample.employees;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
SET search_path = salesordersexample, "$user", public;

-- What is the inventory value of each product?
SELECT ProductName,
(RetailPrice * QuantityOnHand) InventoryValue
FROM Products;

-- How many days elapsed between the order date and the ship date for each
-- order?
/* Note: DATE - DATE casts as an INT */
SELECT OrderNumber, OrderDate, ShipDate, (ShipDate - OrderDate) Days_Elapsed
FROM Orders;

/* ***** Entertainment Agency Database ***** */
SET search_path = entertainmentagencyexample, "$user", public;

-- How long is each engagement due to run?
SELECT EngagementNumber, StartDate, EndDate, 
    CAST(((EndDate - StartDate) + 1) AS CHARACTER) || ' day(s)' Days
FROM Engagements;

-- What is the net amount for each of our contracts?
SELECT EngagementNumber, ContractPrice, ContractPrice * 0.12 AS OurFee,
    ContractPrice - (ContractPrice * 0.12) AS NetAmount
FROM Engagements;
FROM table;

/* ***** School Scheduling Database ******** */
SET search_path = schoolschedulingexample, "$user", public;

-- List how many complete years each staff member has been with the school as of
-- October 1, 2017, and sort the result by last name and first name."
SELECT (StfFirstName || ' ' || StfLastName) AS Name, DateHired,
    CAST(('2017-10-01' - DateHired) / 365 AS INTEGER) AS Years
FROM Staff;

-- Show me a list of staff members, their salaries, and a proposed 7 percent
-- bonus for each staff member.
SELECT (StfLastName || ', ' || StfFirstName) AS StaffName, Salary,
    (Salary * 0.07) AS Salary7PcRaise
FROM Staff;

/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
