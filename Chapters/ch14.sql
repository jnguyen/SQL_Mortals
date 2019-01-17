/* ********** SQL FOR MERE MORTALS CHAPTER 14 *********** */
/* ******** Filtering Grouped Data            ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** A New Meaning of "Focus Groups"          ****/
/* ******************************************** ****/
-- Ex. Show me the entertainer groups that play in a jazz style and hae more
-- than three members.
-- Note: Incorrect way to solve if you forgot to use HAVING, won't run because
-- any columns referenced in WHERE must be in the FROM clause as well
SELECT Entertainers.EntStageName,
    COUNT(*) AS CountOfMembers
FROM Entertainers
    INNER JOIN Entertainer_Members
    ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID
WHERE Entertainers.EntertainerID IN
    (SELECT Entertainer_Styles.EntertainerID
    FROM Entertainer_Styles
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE Musical_Styles.StyleName = 'Jazz')
    AND COUNT(*) > 3
GROUP BY Entertainers.EntStageName;

-- Ex. Same query as above, except corrected to use HAVING
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName,
    COUNT(Entertainer_Members.EntertainerID) AS CountOfMembers
FROM Entertainers
    INNER JOIN Entertainer_Members
    ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID
    INNER JOIN Entertainer_Styles
    ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
    INNER JOIN Musical_Styles
    ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
WHERE Musical_Styles.StyleName = 'Jazz'
GROUP BY Entertainers.EntertainerID,
    Entertainers.EntStageName
HAVING COUNT(Entertainer_Members.EntertainerID) > 3;

/* ******************************************** ****/
/* *** Where You Filter Makes a Difference      ****/
/* ******************************************** ****/
-- Sometimes, you can put a predicate in either WHERE or HAVING
-- WHERE will filter _before_ grouping, whereas HAVING filters _After_

-- Ex. Show me the states on the west coast of the United States where the total
-- of the orders is greater than $1 million.
-- Note: Solved using HAVING, where we GROUP BY customer state. Doing this asks
-- the DB to calculate quantities for _every_ state before filtering,
-- which is inefficient.
SELECT Customers.CustState,
    SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) AS SumOfOrders
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY Customers.CustState
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) > 1000000
    AND CustState IN ('WA', 'OR', 'CA');

-- Ex. Same query as above, except using FILTER to increase query efficiency by
-- only performing calculation for states that we are interested in
SELECT Customers.CustState,
    SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) AS SumOfOrders
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
WHERE CustState IN ('WA', 'OR', 'CA')
GROUP BY Customers.CustState
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) > 1000000;

-- HAVING COUNT trap: for "less than queries", be careful of including 0 or not

-- Ex. Show me the subject categories that have fewer than three full professors
-- teaching that subject.
-- Note: This query excludes all subjects where there are 0 professors
SELECT Categories.CategoryDescription,
    COUNT(Faculty_Categories.StaffID) AS ProfCount
FROM schoolschedulingexample.Categories
    INNER JOIN Faculty_Categories
    ON Categories.CategoryID = Faculty_Categories.CategoryID
    INNER JOIN Faculty
    ON Faculty.StaffID = Faculty_Categories.StaffID
WHERE Faculty.Title = 'Professor'
GROUP BY Categories.CategoryDescription
HAVING COUNT(Faculty_Categories.StaffID) < 3;

-- Ex. Count the number of category rows to check for empty subjects
-- Note: There are no biology professors.
SELECT COUNT(Faculty.StaffID) AS BiologyProfessors
FROM Faculty
    INNER JOIN Faculty_Categories
    ON Faculty.StaffID = Faculty_Categories.StaffID
    INNER JOIN schoolschedulingexample.Categories
    ON Categories.CategoryID = Faculty_Categories.CategoryID
WHERE Categories.CategoryDescription = 'Biology'
    AND Faculty.Title = 'Professor';

-- Ex. Subject categories with <3 professors teaching the subject, with 0 counts
-- Note: Solved with a subquery
SELECT Categories.CategoryDescription,
    (SELECT COUNT(Faculty.StaffID)
    FROM Faculty
        INNER JOIN Faculty_Categories
        ON Faculty.StaffID = Faculty_Categories.StaffID
        INNER JOIN schoolschedulingexample.Categories AS C2
        ON C2.CategoryID = Faculty_Categories.CategoryID
    WHERE C2.CategoryID = Categories.CategoryID
        AND Faculty.Title = 'Professor') AS ProfCount
FROM schoolschedulingexample.Categories
WHERE 
    (SELECT COUNT(Faculty.StaffID)
    FROM Faculty
        INNER JOIN Faculty_Categories
        ON Faculty.StaffID = Faculty_Categories.StaffID
        INNER JOIN schoolschedulingexample.Categories AS C2
        ON C2.CategoryID = Faculty_Categories.CategoryID
    WHERE C2.CategoryID = Categories.CategoryID
        AND Faculty.Title = 'Professor') < 3;

/* ******************************************** ****/
/* *** Uses for HAVING                          ****/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- Ex. List for each customer and order date the customer's full name and the
-- total cost of items ordered that is greater than $1,000.
SELECT Customers.CustLastName || ', ' ||
    Customers.CustFirstName AS CustFullName,
    Orders.OrderDate,
    SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) AS SumOfOrders
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY Customers.CustLastName,
    Customers.CustFirstName,
    Orders.OrderDate
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) > 1000;

/* ***** Entertainment Agency Database ***** */
-- Ex. Which agents booked more than $3,000 worth of business in December 2017?
SELECT Agents.AgtFirstName || ', ' ||
    Agents.AgtLastName AS AgtFullName,
    SUM(Engagements.ContractPrice) AS TotalBooked
FROM Agents
    INNER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
WHERE StartDate BETWEEN '2017-12-01' AND '2017-12-31'
GROUP BY Agents.AgtFirstName || ', ' ||
    Agents.AgtLastName
HAVING SUM(Engagements.ContractPrice) > 3000;

/* ***** School Scheduling Database ******** */
-- Ex. For completed classes, list by category and student the category name,
-- the student name, and the student's average grade of all classes taken in
-- that category for those students who have an average higher than 90.
SELECT Categories.CategoryDescription,
    Students.StudLastName,
    Students.StudFirstName,
    ROUND(AVG(Student_Schedules.Grade)::numeric,0) AS AvgGrade
FROM schoolschedulingexample.Categories
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
HAVING AVG(Student_Schedules.Grade) > 90;

-- Ex. List each staff member and the count of classes each is scheduled to
-- teach for those staff members who teach at least one but fewer than three
-- classes.
SELECT Staff.StfLastName,
    Staff.StfFirstName,
    COUNT(*) AS NumClasses
FROM Staff
    INNER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfLastName,
    Staff.StfFirstName
HAVING COUNT(*) < 3;

/* ***** Bowling League Database *********** */
-- Ex. List the bowlers whose highest raw scores are more than 20 pins higher
-- than their current averages.
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    MAX(Bowler_Scores.RawScore) HighScore,
    AVG(Bowler_Scores.RawScore) AvgScore
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName
HAVING MAX(Bowler_Scores.RawScore) > AVG(Bowler_Scores.RawScore) + 20;

/* ***** Recipes Database ****************** */
-- Ex. List the recipes that contain both beef and garlic.
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Ingredients
        INNER JOIN Recipe_Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef'
        OR Ingredients.IngredientName = 'Garlic'
    GROUP BY Recipe_Ingredients.RecipeID
    HAVING COUNT(Recipe_Ingredients.RecipeID) = 2)

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- 1. Show me each vendor and the average by vendor of the number of days to
-- deliver products that are greater than the average delivery days for all
-- vendors. 5
-- (Hint: You need a subquery to fetch the average delivery time for all
-- vendors.)
SELECT Vendors.VendorID,
    Vendors.VendName,
    ROUND(AVG(Product_Vendors.DaysToDeliver)::numeric,0) AS AvgDaysToDeliver
FROM Vendors
    INNER JOIN Product_Vendors
    ON Vendors.VendorID = Product_Vendors.VendorID
GROUP BY Vendors.VendorID,
    Vendors.VendName
HAVING AVG(Product_Vendors.DaysToDeliver) >
    (SELECT AVG(DaysToDeliver)
    FROM Product_Vendors);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch14_vendor_avg_delivery_gt_overall_avg';

SELECT vendors.vendname,
    avg(product_vendors.daystodeliver) AS avgdelivery
FROM (vendors
    JOIN product_vendors
    ON ((vendors.vendorid = product_vendors.vendorid)))
GROUP BY vendors.vendname
HAVING (avg(product_vendors.daystodeliver) >
    ( SELECT avg(product_vendors_1.daystodeliver) AS avg
       FROM product_vendors product_vendors_1));

-- 2. Display for each product the product name and the total sales that is
-- greater than the average sales for all products in that category. 13
-- Hint: To calculate the comparison value, you must first SUM the sales for
-- each product within a category and then AVG those sums by category.
-- Similar to book answer
SELECT Products.ProductName,
    SUM(Order_Details.QuantityOrdered *
        Order_Details.QuotedPrice) AS TotalSales
FROM Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
GROUP BY Products.ProductNumber,
    Products.CategoryID
HAVING SUM(Order_Details.QuantityOrdered *
           Order_Details.QuotedPrice) >
    -- Calculate all the totals and average within category only
    (SELECT AVG(s.SumSales)
    FROM ( SELECT P2.CategoryID,
             SUM(OD2.QuantityOrdered * OD2.QuotedPrice) AS SumSales
           FROM Order_Details OD2
               INNER JOIN Products P2
               ON P2.ProductNumber = OD2.ProductNumber
           GROUP BY P2.CategoryID, P2.ProductName ) s
    WHERE s.CategoryID = Products.CategoryID
    GROUP BY s.CategoryID);

-- Alternate solution
SELECT Products.ProductName,
    SUM(Order_Details.QuantityOrdered *
        Order_Details.QuotedPrice) AS TotalSales
FROM Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
GROUP BY Products.ProductNumber,
    Products.CategoryID
HAVING SUM(Order_Details.QuantityOrdered *
           Order_Details.QuotedPrice) >
    -- Calculate the sums for each product in the category and then average
    (SELECT AVG(s.SumSales)
    FROM ( SELECT SUM(OD2.QuantityOrdered * OD2.QuotedPrice) AS SumSales
           FROM Order_Details OD2
               INNER JOIN Products P2
               ON P2.ProductNumber = OD2.ProductNumber
           WHERE P2.CategoryID = Products.CategoryID
           GROUP BY P2.ProductName) s)

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch14_sales_by_product_gt_category_avg';

SELECT products.productname,
    sum((order_details.quotedprice *
        (order_details.quantityordered)::numeric)) AS totalsales
FROM (products
JOIN order_details
    ON ((products.productnumber = order_details.productnumber)))
GROUP BY products.categoryid, products.productname
HAVING (sum((order_details.quotedprice *
            (order_details.quantityordered)::numeric)) >
    ( SELECT avg(s.sumcategory) AS avg
       FROM ( SELECT p2.categoryid,
                sum((od2.quotedprice *
                    (od2.quantityordered)::numeric)) AS sumcategory
               FROM (products p2
                 JOIN order_details od2
                   ON ((p2.productnumber = od2.productnumber)))
              GROUP BY p2.categoryid, p2.productnumber) s
      WHERE (s.categoryid = products.categoryid)
      GROUP BY s.categoryid));

-- 3. How many orders are for only one product? 1
-- Hint: You need to use an inner query in the FROM clause that lists the order
-- numbers for orders having only one row and then COUNT those rows in the outer
-- SELECT clause.
SELECT COUNT(*)
FROM (SELECT COUNT(*)
      FROM Order_Details
      GROUP BY OrderNumber
      HAVING COUNT(*) = 1) SingleProductOrders;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch14_single_item_order_count';

-- 133
SELECT count(*) AS singleitemordercount
FROM ( SELECT order_details.ordernumber
       FROM order_details
       GROUP BY order_details.ordernumber
       HAVING (count(*) = 1)) singleorders;

/* ***** Entertainment Agency Database ***** */
-- 1. Show me the entertainers who have more than two overlapped bookings. 1
-- Hint: Use a subquery to find those entertainers with overlapped bookings
-- HAVING a COUNT greater than 2. Remember that in Chapter 6, I showed you how
-- to compare for overlapping ranges efficiently.
-- Idea: Self-join to get duplicated dates, and take all rows where the second
-- start date or end date is between the first start date and end date, and make
-- sure that they are for the same entertainer, but not the same engagement
SELECT Entertainers.EntStageName
FROM Engagements E1
    INNER JOIN Engagements E2
    ON ((E2.EndDate BETWEEN E1.StartDate AND E1.EndDate) OR
        (E2.StartDate BETWEEN E1.StartDate AND E1.EndDate))
        AND (E1.EngagementNumber != E2.EngagementNumber)
        AND (E1.EntertainerID = E2.EntertainerID)
    INNER JOIN Entertainers
    ON E1.EntertainerID = Entertainers.EntertainerID
GROUP BY Entertainers.EntStageName
HAVING COUNT(*) > 2;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch14_entertainers_morethan_2_overlap';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE (entertainers.entertainerid IN
    ( SELECT e1.entertainerid
        FROM (engagements e1
            JOIN engagements e2
            ON ((e1.entertainerid = e2.entertainerid)))
        WHERE ((e1.engagementnumber <> e2.engagementnumber)
            AND (e1.startdate <= e2.enddate) AND (e1.enddate >= e2.startdate))
        GROUP BY e1.entertainerid
        HAVING (count(*) > 2)));

-- 2. Show each agent's name, the sum of the contract price for the engagements
-- booked, and the agent's total commission for agents whose total commission is
-- more than $1,000. 4
-- Hint: Use hte similar problem from Chapter 13 and add a HAVING clause.
SELECT Agents.AgtFirstName || ' ' ||
    Agents.AgtLastName AS AgtFullName,
    SUM(Engagements.ContractPrice) AS TotalBooked,
    ROUND(SUM(Engagements.ContractPrice) *
              Agents.CommissionRate::numeric,2) AS TotalComission
FROM Agents
    INNER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
GROUP BY Agents.AgtFirstName,
    Agents.AgtLastName,
    Agents.CommissionRate
HAVING SUM(Engagements.ContractPrice) * Agents.CommissionRate > 1000;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch14_agent_sales_big_commissions';

SELECT agents.agtfirstname,
    agents.agtlastname,
    sum(engagements.contractprice) AS sumofcontractprice,
    ((sum(engagements.contractprice))::double precision * agents.commissionrate)
        AS commission
FROM (agents
JOIN engagements
    ON ((agents.agentid = engagements.agentid)))
GROUP BY agents.agtfirstname, agents.agtlastname, agents.commissionrate
HAVING (((sum(engagements.contractprice))::double precision *
        agents.commissionrate) > (1000)::double precision);

/* ***** School Scheduling Database ******** */
-- 1. Display by category the category name and the count of classes offered for
-- those categories that have three or more classes. 14
-- Hint: JOIN categories to subjects and then to classes. COUNT the rows and add
-- a HAVING clause to get the final result.
SELECT Categories.CategoryDescription,
    COUNT(*) NumClasses
FROM schoolschedulingexample.Categories
    INNER JOIN Subjects
    ON Categories.CategoryID = Subjects.CategoryID
    INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
GROUP BY Categories.CategoryDescription
HAVING COUNT(*) >= 3
ORDER BY Categories.CategoryDescription;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch14_category_class_count_3_or_more';

SELECT categories.categorydescription,
    count(*) AS classcount
FROM ((schoolschedulingexample.categories
    JOIN subjects
    ON (((categories.categoryid)::text = (subjects.categoryid)::text)))
    JOIN classes
    ON ((subjects.subjectid = classes.subjectid)))
GROUP BY categories.categorydescription
HAVING (count(*) > 3);

-- 2. List each staff member and the count of classes each is scheduled to
-- teach fewer than three classes. 7
-- Hint: This is a HAVING COUNT zero trap! Use subqueries instead.
SELECT Staff.StfFirstName,
    Staff.StfLastName,
    (SELECT COUNT(*)
    FROM Faculty_Classes
    WHERE Faculty_Classes.StaffID = Staff.StaffID) c 
FROM Staff
GROUP BY Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
HAVING (SELECT COUNT(*)
    FROM Faculty_Classes
    WHERE Faculty_Classes.StaffID = Staff.StaffID) < 3;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch14_staff_teaching_lessthan_3';

SELECT concat(staff.stflastname, ', ', staff.stffirstname) AS staffname,
( SELECT count(s2.staffid) AS count
  FROM (staff s2
  JOIN faculty_classes ON ((s2.staffid = faculty_classes.staffid)))
  WHERE (s2.staffid = staff.staffid)) AS staffclasscount
FROM staff
WHERE (( SELECT count(s3.staffid) AS count
       FROM (staff s3
         JOIN faculty_classes
         ON ((s3.staffid = faculty_classes.staffid)))
       WHERE (s3.staffid = staff.staffid)) < 3);

-- 3. Show me the subject categories that have fewer than three full professors
-- teaching that subject. 16
-- Hint: Consider using OUTER JOIN and a subquery in the FROM clause.
-- Idea: Retrieve all categoryID rows with staff members in them, and then right
-- outer join onto all categories and count the number of "staff" rows
SELECT Categories.CategoryDescription,
    COUNT(FC.CategoryID) AS ProfCount
FROM 
    -- Subquery returns one row for each unique staff member in category
    (SELECT Categories.CategoryID
    FROM Faculty
        INNER JOIN Faculty_Categories
        ON Faculty.StaffID = Faculty_Categories.StaffID
        INNER JOIN schoolschedulingexample.Categories
        ON Categories.CategoryID = Faculty_Categories.CategoryID
    WHERE Faculty.Title = 'Professor') FC
    -- Right outer join to list all categories together
    RIGHT OUTER JOIN schoolschedulingexample.Categories
    ON Categories.CategoryID = FC.CategoryID
GROUP BY Categories.CategoryDescription
HAVING COUNT(FC.CategoryID) < 3;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch14_subjects_fewer_3_professors_join_right';

SELECT categories.categorydescription,
    count(fcp.staffid) AS profcount
FROM (schoolschedulingexample.categories
    LEFT JOIN ( SELECT faculty_categories.categoryid,
                    faculty_categories.staffid
                FROM (faculty_categories
                    JOIN faculty
                    ON ((faculty_categories.staffid = faculty.staffid)))
                WHERE ((faculty.title)::text = 'Professor'::text)) fcp
    ON (((categories.categoryid)::text = (fcp.categoryid)::text)))
GROUP BY categories.categorydescription
HAVING (count(fcp.staffid) < 3);

-- 4. Count the classes taught by every staff member.
-- Hint: This really isn't a HAVING problem, but you might be tempted to solve
-- it incorrectly using a GROUP BY using COUNT(*)
-- Using GROUP BY and OUTER JOIN to ensure all staff are listed and counted
SELECT Staff.StfFirstName,
    Staff.StfLastName,
    COUNT(Faculty_Classes.StaffID) AS ClassCount
FROM Staff
    LEFT OUTER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfFirstName,
    Staff.StfLastName;

-- Using a subquery
SELECT Staff.StfFirstName,
    Staff.StfLastName,
    (SELECT COUNT(*)
    FROM Faculty_Classes
    WHERE Faculty_Classes.StaffID = Staff.StaffID) AS ClassCount
FROM Staff;

/* Book Answer */
-- "Right answer"
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch14_staff_class_count_grouped_right';

SELECT staff.stffirstname,
    staff.stflastname,
    count(faculty_classes.staffid) AS classcount
FROM (staff
    LEFT JOIN faculty_classes
    ON ((staff.staffid = faculty_classes.staffid)))
GROUP BY staff.stffirstname, staff.stflastname;

-- "Wrong answer"
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch14_staff_class_count_grouped_wrong';

-- This is wrong because staff with no rows in faculty classes will be excluded
-- because of inner join
SELECT staff.stffirstname,
    staff.stflastname,
    count(*) AS classcount
FROM (staff
    JOIN faculty_classes
    ON ((staff.staffid = faculty_classes.staffid)))
GROUP BY staff.stffirstname, staff.stflastname;

/* ***** Bowling League Database *********** */
-- 1. Do any team captains have a raw score that is higher than any other member
-- of the team? 0
-- Hint: You find out the top raw score for captains by JOINing teams to bowlers
-- on captain ID and then to bowler scores. Use a HAVING clause to compare the
-- MAX value for all other members from a subquery.
SELECT Bowlers.BowlerFirstName CptFirstName,
    Bowlers.BowlerLastName CptLastName,
    MAX(Bowler_Scores.RawScore) HighScore
FROM Teams
    INNER JOIN Bowlers
    ON Teams.CaptainID = Bowlers.BowlerID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    Teams.TeamID
HAVING MAX(Bowler_Scores.RawScore) > ALL
    (SELECT MAX(BS2.RawScore)
    FROM Bowler_Scores BS2
        INNER JOIN Bowlers B2
        ON BS2.BowlerID = BS2.BowlerID
    WHERE B2.TeamID = Teams.TeamID AND
       B2.BowlerID <> Bowlers.BowlerID );

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch14_captains_who_are_hotshots';

SELECT teams.teamid,
    bowlers.bowlerid,
    bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    max(bowler_scores.rawscore) AS maxofrawscore
FROM ((bowlers
    JOIN bowler_scores
    ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
    JOIN teams
    ON ((bowlers.bowlerid = teams.captainid)))
GROUP BY teams.teamid, bowlers.bowlerid, bowlers.bowlerfirstname, bowlers.bowlerlastname
HAVING (max(bowler_scores.rawscore) >
 ( SELECT max(bowler_scores_1.rawscore) AS max
   FROM ((teams t2
       JOIN bowlers b2
       ON ((t2.teamid = b2.teamid)))
       JOIN bowler_scores bowler_scores_1
       ON ((b2.bowlerid = bowler_scores_1.bowlerid)))
  WHERE ((t2.teamid = teams.teamid) AND (b2.bowlerid <> bowlers.bowlerid))));

-- 2. Display for each bowler the bowler name and the average of the bowler's
-- raw game scores for bowlers whose average is greater than 155. 17
-- Hint: You need a simple HAVING clause comparing the AVG to a numeric literal.
SELECT Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    AVG(Bowler_Scores.RawScore) AS AvgScore
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
HAVING AVG(Bowler_Scores.RawScore) > 155;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch14_good_bowlers';

SELECT bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    avg(bowler_scores.rawscore) AS avgscore
FROM (bowlers
    JOIN bowler_scores
    ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
GROUP BY bowlers.bowlerfirstname, bowlers.bowlerlastname
HAVING (avg(bowler_scores.rawscore) > (155)::numeric);

-- 3. List the last name and first name of every bowler whose average raw score
-- is greater than or euqal to the overall average score. 17
-- Hint: I showed you how to solve this in Chapter 12 in the "Sample Statements"
-- section with a subquery in a WHERE clause. Now solve it using HAVING!
SELECT Bowlers.BowlerLastName,
    Bowlers.BowlerFirstName,
    AVG(Bowler_Scores.RawScore) AvgScore
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
HAVING AVG(Bowler_Scores.RawScore) >
    (SELECT AVG(BS2.RawScore)
    FROM Bowler_Scores BS2);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch14_better_than_overall_average_having';

SELECT bowlers.bowlerlastname,
    bowlers.bowlerfirstname
FROM (bowlers
JOIN bowler_scores ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
GROUP BY bowlers.bowlerlastname, bowlers.bowlerfirstname
HAVING (avg(bowler_scores.rawscore) >=
    ( SELECT avg(bowler_scores_1.rawscore) AS avg
      FROM bowler_scores bowler_scores_1));

/* ***** Recipes Database ****************** */
-- 1. Sum the amount of salt by recipe class, and display those recipe classes
-- that require more than three teaspoons. 1
-- Hint: This requires a complex JOIN of five tables to filter out salt and
-- teaspoon, SUM the result, and then eliminate recipe classes that use more
-- than three teaspoons.
SELECT Recipe_Classes.RecipeClassDescription,
    SUM(Recipe_Ingredients.Amount) TspSalt
FROM Recipe_Classes
    INNER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    INNER JOIN Measurements
    ON Ingredients.MeasureAmountID = Measurements.MeasureAmountID
WHERE Ingredients.IngredientName = 'Salt' AND
    Measurements.MeasurementDescription = 'Teaspoon'
GROUP BY Recipe_Classes.RecipeClassDescription
HAVING SUM(Recipe_Ingredients.Amount) > 3;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch14_recipe_classes_lots_of_salt';

SELECT recipe_classes.recipeclassdescription,
    ingredients.ingredientname,
    sum(recipe_ingredients.amount) AS sumofsaltteaspoons
FROM ((((recipe_classes
    JOIN recipes
    ON ((recipe_classes.recipeclassid = recipes.recipeclassid)))
    JOIN recipe_ingredients
    ON ((recipes.recipeid = recipe_ingredients.recipeid)))
    JOIN ingredients
    ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
    JOIN measurements
    ON ((measurements.measureamountid = recipe_ingredients.measureamountid)))
WHERE (((ingredients.ingredientname)::text = 'Salt'::text)
    AND ((measurements.measurementdescription)::text = 'Teaspoon'::text))
GROUP BY recipe_classes.recipeclassdescription, ingredients.ingredientname
HAVING (sum(recipe_ingredients.amount) > (3)::double precision);

-- 2. For what class of recipe do I have two or more recipes? 4
-- Hint: JOIN recipe classes with recipes, count the result, and keep the ones
-- with two or more with a HAVING clause.
SELECT Recipe_Classes.RecipeClassDescription,
    COUNT(Recipes.RecipeID) NumRecipes
FROM Recipe_Classes
    INNER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
GROUP BY Recipe_Classes.RecipeClassDescription
HAVING COUNT(Recipes.RecipeID) >= 2;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch14_recipe_classes_two_or_more';

SELECT recipe_classes.recipeclassdescription,
   count(recipes.recipeid) AS countofrecipeid
FROM (recipe_classes
    JOIN recipes
    ON ((recipe_classes.recipeclassid = recipes.recipeclassid)))
GROUP BY recipe_classes.recipeclassdescription
HAVING (count(recipes.recipeid) >= 2);
