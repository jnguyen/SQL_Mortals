/* ********** SQL FOR MERE MORTALS CHAPTER 5 *********** */
/* ******** GETTING MORE THAN SIMPLE COLUMNS  ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Using Expressions in a Select Clause     ****/
/* ******************************************** ****/
-- Show me a current list of our employees and their phone numbers.
SELECT (EmpFirstName || ' ' || EmpLastName) AS Name, EmpPhoneNumber
FROM employees;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */

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

-- How long is each engagement due to run?
SELECT EngagementNumber, StartDate, EndDate, 
    CAST(((EndDate - StartDate) + 1) AS CHARACTER) || ' day(s)' Days
FROM Engagements;

-- What is the net amount for each of our contracts?
SELECT EngagementNumber, ContractPrice, ContractPrice * 0.12 AS OurFee,
    ContractPrice - (ContractPrice * 0.12) AS NetAmount
FROM Engagements;

/* ***** School Scheduling Database ******** */

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
-- Display a list of all bowlers and addresses formatted suitably for a mailing
-- list, sorted by ZIP Code.
SELECT (BowlerFirstName || ' ' || BowlerLastName) AS FullName, BowlerAddress,
    (BowlerCity || ', ' || BowlerState || ', ' || BowlerZip) AS CityStateZip
FROM bowlers
ORDER BY BowlerZip;

-- What was the point spread between a bowler's handicap and raw score for each
-- match and game played?
SELECT BowlerID, MatchID, GameNumber, HandiCapScore, RawScore,
    (HandiCapScore - RawScore) AS Spread
FROM bowler_scores
ORDER BY BowlerID, MatchID, GameNumber;


/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. What if we adjusted each product price by reducing it 5 percent?
SELECT ProductNumber, RetailPrice, (RetailPrice * 0.95) Reduced5PcRetailPrice
FROM products;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch05_adjusted_wholesale_prices';

SELECT product_vendors.productnumber,
    product_vendors.wholesaleprice,
    (product_vendors.wholesaleprice - (product_vendors.wholesaleprice * 0.05)) AS newprice
FROM product_vendors;

-- 2. Show me a list of orders made by each customer in descending date order.
-- (Hint: You might need to order b more than one column for the information to
-- display properly.)
SELECT CustomerID, OrderNumber, OrderDate
FROM Orders
ORDER BY CustomerID ASC, OrderDate DESC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch05_orders_by_customer_and_date';

SELECT orders.customerid,
    orders.orderdate,
    orders.ordernumber
FROM orders
ORDER BY orders.customerid, orders.orderdate DESC, orders.ordernumber;

-- 3. Compile a complete list of vendor names and addresses in vendor name
-- order.
SELECT VendName, VendStreetAddress, 
    (VendCity || ', ' || VendState || ', ' || VendZipCode) AS VendCityStateZip,
    VendPhoneNumber
FROM vendors
ORDER BY VendName ASC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch05_vendor_addresses';

SELECT vendors.vendname,
    concat(vendors.vendstreetaddress, ', ', vendors.vendcity, '  ', 
        vendors.vendstate, '  ', vendors.vendzipcode) AS vendcompleteaddress,
    vendors.vendphonenumber
FROM vendors
ORDER BY vendors.vendname;

/* ***** Entertainment Agency Database ***** */
-- 1. Give me the names of all our customers by city.
-- (Hint: You'll have to use an ORDER BY clause on one of the columns.)
SELECT (CustFirstName || ', ' || CustLastName) AS FullName, CustCity
FROM Customers
ORDER BY CustCity, CustLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch05_customers_by_city';

SELECT customers.custcity AS city,
    concat(customers.custlastname, ', ', customers.custfirstname) AS customer
FROM entertainmentagencyexample.customers
ORDER BY customers.custcity, (concat(customers.custlastname, ', ', 
        customers.custfirstname));

-- 2. List all entertainers and their Web sites.
SELECT EntertainerID, EntStageName, EntWebPage
FROM Entertainers
ORDER BY EntertainerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch05_entertainer_web_sites';

SELECT entertainers.entstagename AS entertainer,
    concat('Web site: ', entertainers.entwebpage) AS drop_by
FROM entertainers;

-- 3. Show the date of each agent's first six-month performance review.
-- (Hint: You'll need to use date arithmetic to answer this request. Be sure to
-- refer to appendix C.)
-- Note: PostGre casts date + interval calculations to timestamps, so we need to
-- CAST back to a DATE time to preserve formatting
SELECT AgentID, AgtLastName, AgtFirstName, DateHired,
    CAST(DateHired + '1 month'::interval * 6 AS DATE) AS SixMonthReviewDate
FROM agents
ORDER BY AgentID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch05_first_performance_review';

SELECT concat(agents.agtlastname, ', ', agents.agtfirstname) AS agent,
    agents.datehired,
    (agents.datehired + 180) AS firstreview
FROM agents
ORDER BY (concat(agents.agtlastname, ', ', agents.agtfirstname));

/* ***** School Scheduling Database ******** */
-- 1. Give me a list of staff members, and show them in descending order of
-- salary.
SELECT (StfLastName || ', ' || StfFirstName) AS StaffName, Salary
FROM staff
ORDER BY Salary DESC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch05_staff_list_by_salary';

SELECT staff.salary,
    concat(staff.stflastname, ', ', staff.stffirstname) AS staffmember
FROM staff
ORDER BY staff.salary DESC, 
    (concat(staff.stflastname, ', ', staff.stffirstname));

-- 2. Can you give me a staff member phone list?
SELECT (StfLastName || ', ' || StfFirstName) AS StaffName,
    ( '(' || StfAreaCode || ') ' || StfPhoneNumber ) AS StfPhone
FROM staff
ORDER BY StaffName ASC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch05_staff_member_phone_list';

SELECT concat(staff.stflastname, ', ', staff.stffirstname) AS staffmember,
    concat('(', staff.stfareacode, ') ', staff.stfphonenumber) AS phone
FROM staff
ORDER BY (concat(staff.stflastname, ', ', staff.stffirstname));

-- 3. List the names of all our students, and order them by the cities they live
-- in.
SELECT StudCity, (StudLastName || ', ' || StudFirstName) AS StudFullName
FROM Students
ORDER BY StudCity, StudFullName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch05_students_by_city';

SELECT students.studcity,
    concat(students.studlastname, ', ', students.studfirstname) AS student
FROM students
ORDER BY students.studcity, (concat(students.studlastname, ', ', students.studfirstname));

/* ***** Bowling League Database *********** */

-- 1. Show next year's tournament date for each tournament location.
-- (Hint: Add 364 days to get the same day of the week, and be sure to refer to
-- Appendix C.
SELECT TourneyLocation, (TourneyDate + 364) AS TourneyNextDate
FROM tournaments
ORDER BY TourneyLocation;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch05_next_years_tourney_dates';

SELECT tournaments.tourneylocation,
    tournaments.tourneydate,
    (tournaments.tourneydate + 364) AS nextyeartourneydate
FROM tournaments
ORDER BY tournaments.tourneylocation;

-- 2. List the name and phone number for each member of the league.
SELECT (BowlerLastName || ', ' || BowlerFirstName) AS BowlerFullName,
    BowlerPhoneNumber
FROM bowlers
ORDER BY BowlerFullName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch05_phone_list';

SELECT concat(bowlers.bowlerlastname, ', ', bowlers.bowlerfirstname) AS bowler,
    bowlers.bowlerphonenumber AS phone
FROM bowlers
ORDER BY (concat(bowlers.bowlerlastname, ', ', bowlers.bowlerfirstname));

-- 3. Give me a listing of each team's lineup.
-- (Hint: Base this query on the Bowlers table.)
SELECT TeamID, (BowlerLastName || ', ' || BowlerFirstName) AS BowlerFullName
FROM bowlers
ORDER BY TeamID, BowlerFullName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch05_team_lineups';

SELECT bowlers.teamid,
    concat(bowlers.bowlerlastname, ', ', bowlers.bowlerfirstname) AS bowler
FROM bowlers
ORDER BY bowlers.teamid, (concat(bowlers.bowlerlastname, ', ',
        bowlers.bowlerfirstname));
