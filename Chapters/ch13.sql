/* ********** SQL FOR MERE MORTALS CHAPTER 13 ********** */
/* ******** GROUPING DATA                     ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** The Group By Clause                      ****/
/* ******************************************** ****/
-- GROUP BY lets us apply aggregate functions by a common grouping factor,
-- instead of by all rows as in the previous chapter

-- Ex. Show me for each entertainment group: the group name, the count of
-- contracts for the group, the total price of all the contracts, the lowest
-- contract price, the highest contract price, and the average price of all the
-- contracts.
SELECT EntStageName,
    COUNT(*) AS NumContracts,
    SUM(ContractPrice) AS TotalPrice,
    MIN(ContractPrice) AS MinPrice,
    MAX(ContractPrice) AS MaxPrice,
    ROUND(AVG(ContractPrice),2) AS AvgPrice
FROM Entertainers
    INNER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntertainerID;

-- Ex. Same query as above, except left outer joined with all entertainers in
-- case some do not have engagements.
-- Note: All aggregate functions ignore nulls, so we would miss null rows unless
-- we did the query something like below.
-- Note: NumContracts using COUNT(*) will be 1, which is wrong!
SELECT EntStageName,
    COUNT(*) AS NumContracts,
    SUM(ContractPrice) AS TotalPrice,
    MIN(ContractPrice) AS MinPrice,
    MAX(ContractPrice) AS MaxPrice,
    ROUND(AVG(ContractPrice),2) AS AvgPrice
FROM Entertainers
    LEFT OUTER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntertainerID;

-- Ex. Same query as above, except excluding null rows when counting contracts
SELECT EntStageName,
    COUNT(Engagements.EntertainerID) AS NumContracts,
    SUM(ContractPrice) AS TotalPrice,
    MIN(ContractPrice) AS MinPrice,
    MAX(ContractPrice) AS MaxPrice,
    ROUND(AVG(ContractPrice),2) AS AvgPrice
FROM Entertainers
    LEFT OUTER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntertainerID;

-- Ex. Show me for each customer the customer first and last names, the count of
-- contracts for the customer, the total price of all the contracts, the lowest
-- contract price, the highest contract price, and the average price of all the
-- contracts.
SELECT Customers.CustLastName,
    Customers.CustFirstName,
    COUNT(*) AS NumContracts,
    SUM(Engagements.ContractPrice) AS TotalPrice,
    MIN(Engagements.ContractPrice) AS MinPrice,
    MAX(Engagements.ContractPrice) AS MaxPrice,
    AVG(Engagements.ContractPrice) AS AvgPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustLastName,
    Customers.CustFirstName;

-- Ex. Same query as above, except including customers withou bookings
SELECT Customers.CustLastName,
    Customers.CustFirstName,
    COUNT(Engagements.CustomerID) AS NumContracts, -- Count IDs to avoid nulls
    SUM(Engagements.ContractPrice) AS TotalPrice,
    MIN(Engagements.ContractPrice) AS MinPrice,
    MAX(Engagements.ContractPrice) AS MaxPrice,
    ROUND(AVG(Engagements.ContractPrice),2) AS AvgPrice
FROM entertainmentagencyexample.Customers
    LEFT OUTER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustLastName,
    Customers.CustFirstName;

-- Ex. Show me for each customer th ecustomer full name, the customer full
-- address, the latest contract date for the customer, and the total price of
-- all the contracts.
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS CustFullName,
    Customers.CustStreetAddress || ', ' ||
        Customers.CustCity || ', ' ||
        Customers.CustState || ', ' ||
        Customers.CustZipCode AS CustomerFullAddress,
    MAX(Engagements.StartDate) AS LatestDate,
    SUM(Engagements.ContractPrice) AS TotalContractPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustLastName,
    Customers.CustFirstName,
    Customers.CustStreetAddress,
    Customers.CustCity, Customers.CustState,
    Customers.CustZipCode;

-- Note: A flaw with grouping explicitly by name is that it groups by exact
-- name, street address, etc. combination. If you only grouped by names, then
-- you are grouping by all customers with first/last name combinations, which
-- does not guarantee uniqueness of the customer. However, this may be useful in
-- a query looking at purchasing characteristics based on customer name.
-- Ex. Same as above, except less academic by using CustomerID to group
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS CustFullName,
    Customers.CustStreetAddress || ', ' ||
        Customers.CustCity || ', ' ||
        Customers.CustState || ', ' ||
        Customers.CustZipCode AS CustomerFullAddress,
    MAX(Engagements.StartDate) AS LatestDate,
    SUM(Engagements.ContractPrice) AS TotalContractPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID;

-- Ex. Display the engagement contract whose price is greater than the sum of
-- all contracts for any other customer.
SELECT CustFirstName, CustLastName,
    ContractPrice,
    StartDate,
    EndDate
FROM entertainmentagencyexample.Customers AS Customers
    INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.ContractPrice > ALL
    (SELECT SUM(ContractPrice)
    FROM Engagements AS E2
    WHERE E2.CustomerID <> Customers.CustomerID
    GROUP BY E2.CustomerID)

-- Using GROUP BY without an aggregate function simulates using DISTINCT
-- Note: Don't use this unless the DBMS solves GROUP BY faster than DISTINCT
-- Ex. Show me the unique city names from the customer table.
SELECT CustCity
FROM Customers
GROUP BY Customers.CustCity;

-- Ex. Same as above, but now you can count how many times the city occurred
SELECT CustCity, COUNT(*) AS CustPerCity
FROM Customers
GROUP BY Customers.CustCity;

/* ******************************************** ****/
/* *** "Some Restrictions Apply"                ****/
/* ******************************************** ****/
-- Note: Adding GROUP BY adds some restrictions to your query
-- * Any number of aggregate functions may be used in SELECT
-- * Aggregate functions may use any columns specified in FROM or WHERE
-- * Expressions that reference columns but do not include aggregate functions
-- must all be specified in GROUP BY
-- * You may not group on expressions

-- Ex. Display the customer ID, customer full name, and the total of all
-- engagement contract prices.
-- Note: This query fails on fully SQL standard compliant DBs. PostGRE runs it!
SELECT Customers.CustomerID,
    Customers.CustFirstName || ', ' ||
    Customers.CustLastName AS CustFullName,
    SUM(Engagements.ContractPrice) AS TotalPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID; -- Must include CustomerID here!

-- Ex. Same query as above,but now fully compliant
SELECT Customers.CustomerID,
    Customers.CustFirstName || ', ' ||
    Customers.CustLastName AS CustFullName,
    SUM(Engagements.ContractPrice) AS TotalPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID, Customers.CustFirstName, Customers.CustLastName;

-- Note: Some DBs, like Oracle or MS Access, require you to exactly duplicate
-- non-aggregate functions.
-- Ex. Same as above, except compatible with Oracle and MS Access, but now no
-- longer fully SQL standard compliant
SELECT Customers.CustomerID,
    Customers.CustFirstName || ', ' ||
    Customers.CustLastName AS CustFullName,
    SUM(Engagements.ContractPrice) AS TotalPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID,
    Customers.CustFirstName || ', ' ||
    Customers.CustLastName;

-- Ex. Show me for each customer in the state of Washington the customer full
-- name, the customer full address, the latest contract date for the customer,
-- and the total price of all the contracts.
-- Note: This query will fail to run because we grouped on an expression.
SELECT Customers.CustLastName || ', ' ||
    Customers.CustFirstName AS CustFullName,
    Customers.CustStreetAddress || ', ' ||
        Customers.CustCity || ', ' ||
        Customers.CustState || ', ' ||
        Customers.CustZipCode AS CustomerFullAddress,
    MAX(Engagements.StartDate) AS LatestDate,
    SUM(Engagements.ContractPrice) AS TotalContractPrice
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
WHERE Customers.CustState = 'WA'
GROUP BY CustomerFullName, -- Error!
    CustomerFullAddress

-- One way to fix the above error is to group by each individual column you plan
-- to include in the query. Another way to solve it is to make the FROM clause
-- generate the calculated columns in an embedded subquery.
-- Ex. Same as above fixing the GROUP BY statement with an embedded subquery
SELECT CE.CustomerFullName,
    CE.CustomerFullAddress,
    MAX(CE.StartDate) AS LatestDate,
    SUM(CE.ContractPrice) AS TotalContractPrice
FROM 
    (SELECT Customers.CustLastName || ', ' ||
        Customers.CustFirstName AS CustomerFullName,
        Customers.CustStreetAddress || ', ' ||
        Customers.CustCity || ', ' ||
        Customers.CustState || ', ' ||
        Customers.CustZipCode AS CustomerFullAddress,
        Engagements.StartDate,
        Engagements.ContractPrice
    FROM entertainmentagencyexample.Customers
        INNER JOIN Engagements
            ON Customers.CustomerID = Engagements.CustomerID
    WHERE Customers.CustState = 'WA') AS CE
GROUP BY CE.CustomerFullName,
    CE.CustomerFullAddress;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Ex. List for each customer and order date the customer full name and the
-- total cost of items ordered on each date.
SELECT CustFirstName || ', ' ||
    CustLastName AS CustFullName,
    ROUND(SUM(QuotedPrice * QuantityOrdered), 2) AS TotalCost
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY CustFirstName, CustLastName, OrderDate;

/* ***** Entertainment Agency Database ***** */
-- Ex. Display each entertainment group ID, entertaiment group number, and the
-- amount of pay for each member based on the total contract price divided by
-- the number of members in the group.
-- Attempt: Forgot to exclude non-active members and include member names
SELECT Entertainers.EntertainerID,
    Entertainers.EntPhoneNumber,
    ROUND(SUM(ContractPrice) /
        (SELECT COUNT(*)
        FROM Entertainer_Members
        WHERE Entertainers.EntertainerID = Entertainer_Members.EntertainerID),2)
    AS PayPerMember
FROM Entertainers
    INNER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntertainerID;

/* Book Answer */
SELECT Entertainers.EntertainerID,
    Entertainers.EntPhoneNumber,
    Members.MbrFirstName, Members.MbrLastName,
    ROUND(SUM(ContractPrice) /
        (SELECT COUNT(*)
        FROM Entertainer_Members
        WHERE Entertainer_Members.Status <> 3
            AND Entertainers.EntertainerID = Entertainer_Members.EntertainerID),2)
    AS PayPerMember
FROM Members
    INNER JOIN Entertainer_Members
    ON Members.MemberID = Entertainer_Members.MemberID
    INNER JOIN Entertainers
    ON Entertainer_Members.EntertainerID = Entertainers.EntertainerID
    INNER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
WHERE Entertainer_Members.Status <> 3
GROUP BY Entertainers.EntertainerID,
    Members.MbrFirstName, Members.MbrLastName
ORDER BY Members.MbrLastName;

/* ***** School Scheduling Database ******** */
-- Ex. For completed classes, list by category and student the category name,
-- the student name, and the student's average grade of all classes taken in
-- that category.
SELECT Categories.CategoryDescription,
    Students.StudLastName || ', ' ||
    Students.StudFirstName AS StudFullName,
    ROUND(AVG(Student_Schedules.Grade)::numeric,2) AS AverageGrade
FROM schoolschedulingexample.Categories AS Categories
    INNER JOIN Subjects
    ON Categories.CategoryID = Subjects.CategoryID
    INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
    INNER JOIN Student_Schedules
    ON Classes.ClassID = Student_Schedules.ClassID
    INNER JOIN Students
    ON Student_Schedules.StudentID = Students.StudentID
    INNER JOIN Student_Class_Status
    ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
GROUP BY Categories.CategoryDescription,
    Students.StudLastName,
    Students.StudFirstName
ORDER BY Categories.CategoryDescription,
    Students.StudLastName,
    Students.StudFirstName;

/* ***** Bowling League Database *********** */
-- Ex. Show me for each tournament and match the tournament ID, the tournament
-- location, the match number, the name of each team, and the total of the
-- handicap score for each team.
-- Attempt: Wide format
SELECT Tournaments.TourneyID,
    Tournaments.TourneyLocation,
    Tourney_Matches.MatchID,
    (SELECT TeamName
    FROM Teams OT
    WHERE OT.TeamID = Tourney_Matches.OddLaneTeamID) OddTeamName,
    (SELECT TeamName
    FROM Teams ET
    WHERE ET.TeamID = Tourney_Matches.EvenLaneTeamID) EvenTeamName,
    (SELECT SUM(HandiCapScore)
    FROM Bowler_Scores
        INNER JOIN Bowlers
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID
        INNER JOIN Teams OT2
        ON Bowlers.TeamID = OT2.TeamID
    WHERE Bowler_Scores.MatchID = Tourney_Matches.MatchID
        AND OT2.TeamID = Tourney_Matches.OddLaneTeamID) TotOddHandicapScore,
    (SELECT SUM(HandiCapScore)
    FROM Bowler_Scores
        INNER JOIN Bowlers
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID
        INNER JOIN Teams ET2
        ON Bowlers.TeamID = ET2.TeamID
    WHERE Bowler_Scores.MatchID = Tourney_Matches.MatchID
        AND ET2.TeamID = Tourney_Matches.EvenLaneTeamID) TotEvenHandicapScore
FROM Tournaments
    INNER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID
    INNER JOIN Bowler_Scores
    ON Tourney_Matches.MatchID = Bowler_Scores.MatchID
GROUP BY Tournaments.TourneyID,
    Tournaments.TourneyLocation,
    Tourney_Matches.MatchID,
    Tourney_Matches.OddLaneTeamID,
    Tourney_Matches.EvenLaneTeamID;

/* Book Answer */
-- The book uses long format answer.
-- Note: The grouping statements allow SQL to take care of the complex table
-- outputted from the big JOIN statements
SELECT Tournaments.TourneyID,
    Tournaments.TourneyLocation,
    Tourney_Matches.MatchID,
    Teams.TeamName,
    SUM(Bowler_Scores.HandicapScore) AS TotHandiCapScore
FROM ((((Tournaments
    INNER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID)
    INNER JOIN Match_Games
    ON Tourney_Matches.MatchID = Match_Games.MatchID)
    INNER JOIN Bowler_Scores
    ON (Match_Games.MatchID = Bowler_Scores.MatchID) AND
    (Match_Games.GameNumber = Bowler_Scores.GameNumber))
    INNER JOIN Bowlers
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID)
    INNER JOIN Teams
    ON Teams.TeamID = Bowlers.TeamID
GROUP BY Tournaments.TourneyID,
Tournaments.TourneyLocation,
Tourney_Matches.MatchID, Teams.TeamName;

-- Ex. Display the highest raw score for each bowler.
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    MAX(Bowler_Scores.RawScore) AS HighScore
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerID;

/* ***** Recipes Database ****************** */
-- Ex. Show me how many recipes exist for each class of ingredient.
-- Note: Ingredients may show up multiple times, so count them per unique recipe
SELECT Ingredient_Classes.IngredientClassDescription,
    COUNT(DISTINCT Recipe_Ingredients.RecipeID) AS NumRecipes
FROM Ingredients
    INNER JOIN Ingredient_Classes
    ON Ingredients.IngredientClassID = Ingredient_Classes.IngredientClassID
    INNER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
GROUP BY Ingredient_Classes.IngredientClassDescription;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. Show me each vendor and the average by vendor of the number of days to
-- deliver products. 10
-- Hint: Use the AVG aggregate function and group on vendor.
SELECT Vendors.VendName,
    ROUND(AVG(Product_Vendors.DaysToDeliver),2) AS AvgDaysToDeliver
FROM Vendors
    INNER JOIN Product_Vendors
    ON Vendors.VendorID = Product_Vendors.VendorID
GROUP BY Vendors.VendName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch13_vendor_avg_delivery';

SELECT vendors.vendname,
    avg(product_vendors.daystodeliver) AS avgdelivery
FROM (vendors
    JOIN product_vendors ON ((vendors.vendorid = product_vendors.vendorid)))
GROUP BY vendors.vendname;

-- 2. Display for each product the product name and the total sales. 38
-- Hint: Use SUM with a calculation of quantity times price and group on product
-- name.
SELECT Products.ProductName,
    SUM(QuotedPrice * QuantityOrdered) AS TotalSales
FROM Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
GROUP BY Products.ProductName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch13_sales_by_product';

SELECT products.productname,
    sum((order_details.quotedprice * (order_details.quantityordered)::numeric))
        AS totalsales
FROM (products
    JOIN order_details
    ON ((products.productnumber = order_details.productnumber)))
GROUP BY products.productname;

-- 3. List all vendors and the count of products sold by each. 10
-- Note: LEFT OUTER JOIN to make sure to not count NULL rows
SELECT Vendors.VendName,
    COUNT(Product_Vendors.VendorID) AS NumProducts
FROM Vendors
    LEFT OUTER JOIN Product_Vendors
    ON Vendors.VendorID = Product_Vendors.VendorID
GROUP BY Vendors.VendName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch13_vendors_product_count_group';

SELECT vendors.vendname,
    count(product_vendors.productnumber) AS countofproductnumber
FROM (vendors
    JOIN product_vendors ON ((vendors.vendorid = product_vendors.vendorid)))
GROUP BY vendors.vendname;

-- 4. Challenge: Now solve problem 3 by using a subquery.
SELECT Vendors.VendName,
    (SELECT COUNT(*)
    FROM Product_Vendors
    WHERE Vendors.VendorID = Product_Vendors.VendorID) AS NumProducts
FROM Vendors;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch13_vendors_product_count_subquery';

SELECT vendors.vendname,
    (SELECT count(*) AS count
     FROM product_vendors
     WHERE (product_vendors.vendorid = vendors.vendorid)) AS vendproductcount
FROM vendors;

/* ***** Entertainment Agency Database ***** */
-- 1. Show each agent's name, the sum of the contract price for the engagements
-- booked, and the agent's total commission. 8
-- Hint: You must multiply the sum of the contract prices by the agent's
-- commission. Be sure to group on the commission rate as well!
SELECT Agents.AgtLastName || ', ' ||
    Agents.AgtFirstName AS AgtFullName,
    SUM(Engagements.ContractPrice) AS TotContractPrice,
    ROUND(SUM(Engagements.ContractPrice * Agents.CommissionRate)::numeric,2)
        AS TotCommission
FROM Agents
    INNER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
GROUP BY Agents.AgtLastName,
    Agents.AgtFirstName,
    Agents.CommissionRate;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch13_agent_sales_and_commissions';

SELECT agents.agtfirstname,
    agents.agtlastname,
    sum(engagements.contractprice) AS sumofcontractprice,
    ((sum(engagements.contractprice))::double precision * agents.commissionrate)
        AS commission
FROM (agents
    JOIN engagements ON ((agents.agentid = engagements.agentid)))
GROUP BY agents.agtfirstname, agents.agtlastname, agents.commissionrate;

/* ***** School Scheduling Database ******** */
-- 1. Display by category the category name and the count of classes offered. 15
-- Hint: Use COUNT and group on category name.
SELECT Categories.CategoryDescription,
    COUNT(Classes.ClassID)
FROM schoolschedulingexample.Categories Categories
    INNER JOIN Subjects
    ON Categories.CategoryID = Subjects.CategoryID
    INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
GROUP BY Categories.CategoryDescription;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch13_category_class_count';

SELECT categories.categorydescription,
    count(*) AS classcount
FROM ((schoolschedulingexample.categories
    JOIN subjects
      ON (((categories.categoryid)::text = (subjects.categoryid)::text)))
    JOIN classes
      ON ((subjects.subjectid = classes.subjectid)))
GROUP BY categories.categorydescription;

-- 2. List each staff member and the count of classes each is scheduled to
-- teach. 22
-- Hint: Use COUNT and group on staff name.
SELECT Staff.StfLastName,
    Staff.StfFirstName,
    COUNT(*)
FROM Staff
    INNER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfLastName,
    Staff.StfFirstName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch13_staff_class_count';

SELECT staff.stffirstname,
    staff.stflastname,
    count(*) AS classcount
FROM (staff
    JOIN faculty_classes ON ((staff.staffid = faculty_classes.staffid)))
GROUP BY staff.stffirstname, staff.stflastname;

-- 3. Challenge: Now solve problem 2 by using a subquery. 27
SELECT Staff.StfLastName,
    Staff.StfFirstName,
    (SELECT COUNT(*)
    FROM Faculty_Classes
    WHERE Staff.StaffID = Faculty_Classes.StaffID)
FROM Staff;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch13_staff_class_count_subquery';

SELECT staff.staffid,
    staff.stffirstname,
    staff.stflastname,
    ( SELECT count(*) AS count
        FROM faculty_classes
        WHERE (faculty_classes.staffid = staff.staffid)) AS classcount
FROM staff;

-- 4. Can you explain why the subquery solution returns five more rows? Is it
-- possible to modify the query in question 2 to return 27 rows? If so, how
-- would you do it?
-- Hint: Think about using an OUTER JOIN.
-- Answer: The INNER JOIN in question 2 eliminates NULL rows, so staff that do
-- not teach are not included. We can modify the query in 2 with an OUTER JOIN
-- to include null rows as follows.
SELECT Staff.StfLastName,
    Staff.StfFirstName,
    COUNT(Faculty_Classes.ClassID)
FROM Staff
    LEFT OUTER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfLastName,
    Staff.StfFirstName;

/* ***** Bowling League Database *********** */
-- 1. Display for each bowler the bowler name and the average the bowler's raw
-- game scores.
-- Hint: Use the AVG aggregate function and group on bowler name.
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    ROUND(AVG(Bowler_Scores.RawScore),2) AS AvgRawScore
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch13_bowler_averages';

SELECT concat(bowlers.bowlerlastname, ', ', bowlers.bowlerfirstname)
        AS bowlerfullname,
    avg(bowler_scores.rawscore) AS avgofrawscore
FROM (bowlers
    JOIN bowler_scores ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
GROUP BY bowlers.bowlerlastname, bowlers.bowlerfirstname;

-- 2. Calculate the current average and handicap for each bowler. 32
-- Hint: This is a "friendly" league, so the handicap is 90 percent of 200 minus
-- the raw average. Be sure to round the raw average and convert it to an
-- integer before subtracting it from 200, and then round and truncate the finl
-- result. Although the SQL standard doesn't define a ROUND function, most
-- commercial database systems provide one. Check your product documentation for
-- details.
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    ROUND(0.9*(200 - ROUND(AVG(Bowler_Scores.RawScore))))::integer AS AvgHandicap
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch13_bowler_average_handicap';

SELECT bowler_scores.bowlerid,
    bowlers.bowlerlastname,
    bowlers.bowlerfirstname,
    sum(bowler_scores.rawscore) AS totalpins,
    count(bowler_scores.rawscore) AS gamesbowled,
    round(avg(bowler_scores.rawscore), 0) AS curavg,
    round((0.9 * ((200)::numeric - round(avg(bowler_scores.rawscore), 0))), 0) AS curhcp
FROM (bowlers
    JOIN bowler_scores ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
GROUP BY bowler_scores.bowlerid, bowlers.bowlerlastname, bowlers.bowlerfirstname;

-- 3. Challenge: "Display the highest raw score for each bowler", but solve it
-- by using a subquery. 32
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    (SELECT MAX(RawScore)
    FROM Bowler_Scores
    WHERE Bowlers.BowlerID = Bowler_Scores.BowlerID) AS HighScore
FROM Bowlers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch13_bowler_high_score_subquery';

SELECT bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    ( SELECT max(bowler_scores.rawscore) AS max
        FROM bowler_scores
        WHERE (bowler_scores.bowlerid = bowlers.bowlerid)) AS highscore
FROM bowlers;

/* ***** Recipes Database ****************** */
-- 1. If I wnat to cook all the recipes in my cookbook, how much of each
-- ingredient must I have on hand? 65
-- Hint: Use SUM and group on ingredient name and measurement description
SELECT Ingredients.IngredientName,
    Measurements.MeasurementDescription,
    SUM(Recipe_Ingredients.Amount) AS TotalAmount
FROM Recipe_Ingredients
    INNER JOIN Measurements
    ON Recipe_Ingredients.MeasureAmountID = Measurements.MeasureAmountID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
GROUP BY Ingredients.IngredientName,
    Measurements.MeasurementDescription;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch13_total_ingredients_needed';

SELECT ingredients.ingredientname,
    measurements.measurementdescription,
    sum(recipe_ingredients.amount) AS sumofamount
FROM (ingredients
    JOIN (measurements
    JOIN recipe_ingredients
        ON ((measurements.measureamountid = recipe_ingredients.measureamountid)))
    ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
GROUP BY ingredients.ingredientname, measurements.measurementdescription;

-- 2. List all meat ingredients and the count of recipes that include each one.
SELECT Ingredients.IngredientName,
    COUNT(*) AS NumRecipes
FROM Ingredients
    INNER JOIN Ingredient_Classes
    ON Ingredients.IngredientClassID = Ingredient_Classes.IngredientClassID
    INNER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE IngredientClassDescription = 'Meat'
GROUP BY Ingredients.IngredientName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch13_meat_ingredient_recipe_count_group';

SELECT ingredient_classes.ingredientclassdescription,
    ingredients.ingredientname,
    count(*) AS recipecount
FROM ((ingredient_classes
JOIN ingredients
    ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
JOIN recipe_ingredients
    ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Meat'::text)
GROUP BY ingredient_classes.ingredientclassdescription, ingredients.ingredientname;

-- 3. Challenge: Now solve problem 2 using a subquery.
SELECT Ingredients.IngredientName,
    (SELECT COUNT(*)
    FROM Recipe_Ingredients
    WHERE Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
FROM Ingredients
    INNER JOIN Ingredient_Classes
    ON Ingredients.IngredientClassID = Ingredient_Classes.IngredientClassID
WHERE IngredientClassDescription = 'Meat';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch13_meat_ingredient_recipe_count_subquery';

SELECT ingredient_classes.ingredientclassdescription,
    ingredients.ingredientname,
    ( SELECT count(*) AS count
           FROM recipe_ingredients
          WHERE (recipe_ingredients.ingredientid = ingredients.ingredientid)) AS recipecount
FROM (ingredient_classes
JOIN ingredients
    ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Meat'::text);

-- 4. Can you explain why the subquery solution returns seven more rows? Is it
-- possible to modify the query in question 2 to return 11 rows? If so, how
-- would you do it?
-- Hint: Think about using an OUTER JOIN.
-- Answer: The INNER JOIN in question 2 eliminates NULL rows, so staff that do
-- not teach are not included. We can modify the query in 2 with an OUTER JOIN
-- to include null rows as follows.
SELECT Ingredients.IngredientName,
    COUNT(Recipe_Ingredients.RecipeID) AS NumRecipes
FROM Ingredients
    INNER JOIN Ingredient_Classes
    ON Ingredients.IngredientClassID = Ingredient_Classes.IngredientClassID
    LEFT OUTER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE IngredientClassDescription = 'Meat'
GROUP BY Ingredients.IngredientName;
