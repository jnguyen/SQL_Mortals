/* ********** SQL FOR MERE MORTALS CHAPTER 10 ********** */
/* ******** UNIONS                            ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** What is a union?                         ****/
/* ******************************************** ****/
-- TIP: If you are sure duplicates aren't possible, always use UNION ALL for
-- better performance.

/* ******************************************** ****/
/* *** Writing Requests With UNION              ****/
/* ******************************************** ****/
/* *** Using Simple SELECT Statements           ****/
-- TIP: UNION CORRESPONDING is an upcoming feature to only use columns of same
-- name when performing the UNION operation

-- Ex. Build a single mailing list that consists of the name, address, city,
-- state, and ZIP Code for customers and the name, address, city, state, and ZIP
-- Code for vendors
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS MailingName,
    Customers.CustStreetAddress, Customers.CustCity, Customers.CustState,
    Customers.CustZipCode
FROM Customers
    UNION
SELECT Vendors.VendName,
    Vendors.VendStreetAddress, Vendors.VendCity, Vendors.VendState,
    Vendors.VendZipCode
FROM Vendors;

/* *** Combining Complex SELECT Statements      ****/
-- Ex. List customers and the bikes they ordered combined with vendors and the
-- bikes they sell
-- Note: UNION will eliminate distinct rows, so adding DISTINCT will only slow
-- down the speed of the request by having the DB eliminate duplicates twice.
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS FullName,
    Products.ProductName, 'Customer' AS RowID
FROM ((Customers INNER JOIN Orders
        ON Customers.CustomerID = Orders.CustomerID)
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber)
    INNER JOIN Products
    ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName LIKE '%Bike%'
UNION
SELECT Vendors.VendName, Products.ProductName, 'Vendor' AS RowID
FROM (Vendors
    INNER JOIN Product_Vendors
    ON Vendors.VendorID = Product_Vendors.VendorID)
    INNER JOIN Products
    ON Products.ProductNumber = Product_Vendors.ProductNumber
WHERE Products.ProductName LIKE '%Bike%';

-- Ex. Create a single mailing list for customers, employees, and vendors.
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS MailingName,
    Customers.CustStreetAddress, Customers.CustCity, Customers.CustState,
    Customers.CustZipCode
FROM Customers
UNION
SELECT Employees.EmpFirstName || ' ' || Employees.EmpLastName AS EmpFullName,
    Employees.EmpStreetAddress, Employees.EmpCity, Employees.EmpState,
    Employees.EmpZipCode
FROM Employees
UNION
SELECT Vendors.VendName, Vendors.VendStreetAddress, Vendors.VendCity,
    Vendors.VendState, Vendors.VendZipCode
FROM Vendors;

-- Ex. You can explicitly sort the result set of the UNIOn by placing an ORDER
-- BY statement at the very end of the UNION
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS MailingName,
    Customers.CustStreetAddress, Customers.CustCity, Customers.CustState,
    Customers.CustZipCode
FROM Customers
UNION
SELECT Employees.EmpFirstName || ' ' || Employees.EmpLastName AS EmpFullName,
    Employees.EmpStreetAddress, Employees.EmpCity, Employees.EmpState,
    Employees.EmpZipCode
FROM Employees
UNION
SELECT Vendors.VendName, Vendors.VendStreetAddress, Vendors.VendCity,
    Vendors.VendState, Vendors.VendZipCode
FROM Vendors
ORDER BY CustZipCode;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Show me all the customer and employee names and addresses, including any
-- duplicates, sorted by ZIP Code 
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS MailingName,
    Customers.CustStreetAddress, Customers.CustCity, Customers.CustState,
    Customers.CustZipCode
FROM Customers
UNION ALL
SELECT Employees.EmpFirstName || ' ' || Employees.EmpLastName AS EmpFullName,
    Employees.EmpStreetAddress, Employees.EmpCity, Employees.EmpState,
    Employees.EmpZipCode
FROM Employees
ORDER BY CustZipCode;

-- List all the customers who ordered a bicycle with all the customers who
-- ordered a helmet.
SELECT CustLastName, CustFirstName, 'Bike' AS ProdType
FROM Customers INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
    INNER JOIN Products
    ON Order_Details.ProductNumber = Products.ProductNumber
WHERE ProductName LIKE '%Bike%'
UNION
SELECT CustLastName, CustFirstName, 'Helmet' AS ProdType
FROM Customers INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
    INNER JOIN Products
    ON Order_Details.ProductNumber = Products.ProductNumber
WHERE ProductName LIKE '%Helmet%';

-- Same statement as above, solved with a much faster complex WHERE statement
SELECT DISTINCT Customers.CustFirstName, Customers.CustLastName
FROM ((Customers INNER JOIN Orders
        ON Customers.CustomerID = Orders.CustomerID)
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber)
    INNER JOIN Products
    ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName LIKE '%Bike%'
    OR Products.ProductName LIKE '%Helmet%';

/* ***** Entertainment Agency Database ***** */
-- Create a list that combines agents and entertainers.
SELECT AgtFirstName || ' ' || AgtLastName AS FullName, 'Agent' AS Type
FROM Agents
UNION
SELECT EntStageName, 'Entertainer' AS Type
FROM Entertainers;

/* ***** School Scheduling Database ******** */
-- Show me the students who have a grade of 85 or better in Art together with
-- the faculty members who teach Art and have a proficiency rating of 9 or
-- better.
SELECT Students.StudFirstName AS FirstName, Students.StudLastName AS LastName,
    Student_Schedules.Grade AS Score, 'Student' AS Type
FROM (((Students INNER JOIN Student_Schedules
            ON Students.StudentID = Student_Schedules.StudentID)
        INNER JOIN Student_Class_Status
            ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus)
        INNER JOIN Classes
            ON Classes.ClassID = Student_Schedules.ClassID)
        INNER JOIN Subjects
            ON Subjects.SubjectID = Classes.SubjectID
WHERE Student_Class_Status.ClassStatusDescription = 'Completed' 
    AND Student_Schedules.Grade >= 85
    AND Subjects.CategoryID = 'ART'
UNION
SELECT Staff.StfFirstName, Staff.StfLastName,
    Faculty_Subjects.ProficiencyRating AS Score, 'Faculty' AS Type
FROM (Staff INNER JOIN Faculty_Subjects
        ON Staff.StaffID = Faculty_Subjects.StaffID)
    INNER JOIN Subjects
        ON Subjects.SubjectID = Faculty_Subjects.SubjectID
WHERE Faculty_Subjects.ProficiencyRating > 8
    AND Subjects.CategoryID = 'ART'

/* ***** Bowling League Database *********** */
-- List the tourney matches, team names, and team captains for the teams
-- starting on the odd lane together with the tourney matches, team names, and
-- team captains for the teams starting on the even lane, and sort by tournament
-- date and match number.
SELECT TourneyDate, TourneyLocation, Tourney_Matches.MatchID, TeamName,
    BowlerFirstName || ' ' || BowlerLastName AS CaptainName, 'Odd' AS Lane
FROM Tournaments INNER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID
    INNER JOIN Teams
    ON Tourney_Matches.OddLaneTeamID = Teams.TeamID
    INNER JOIN Bowlers
    ON Teams.CaptainID = Bowlers.BowlerID
UNION ALL
SELECT TourneyDate, TourneyLocation, Tourney_Matches.MatchID, TeamName,
    BowlerFirstName || ' ' || BowlerLastName AS CaptainName, 'Even' AS Lane
FROM Tournaments INNER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID
    INNER JOIN Teams
    ON Tourney_Matches.EvenLaneTeamID = Teams.TeamID
    INNER JOIN Bowlers
    ON Teams.CaptainID = Bowlers.BowlerID
ORDER BY TourneyDate, MatchID;

/* ***** Recipes Database ****************** */
-- Create an index list of all the recipe classes, recipe titles, and
-- ingredients
SELECT Recipe_Classes.RecipeClassDescription AS IndexName,
    'Recipe Class' AS Type
FROM Recipe_Classes
UNION
SELECT Recipes.RecipeTitle, 'Recipe' AS Type
FROM Recipes
UNION
SELECT Ingredients.IngredientName, 'Ingredient' AS Type
FROM Ingredients;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. List all the cusomers who ordered a helmet together with the vendors who
-- provide helmets. 91
-- Customers who ordered helmets
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS Name,
    Products.ProductName, 'Customer' AS Role
FROM Customers INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
    INNER JOIN Products
    ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName LIKE '%Helmet%'
UNION
-- Vendors who provide helmets
SELECT Vendors.VendName, Products.ProductName, 'Vendor' AS Role
FROM Vendors INNER JOIN Product_Vendors
    ON Vendors.VendorID = Product_Vendors.VendorID
    INNER JOIN Products
    ON Product_Vendors.ProductNumber = Products.ProductNumber
WHERE Products.ProductName LIKE '%Helmet%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch10_customer_helmets_vendor_helmets';

SELECT concat(customers.custlastname, ', ', customers.custfirstname) AS fullname,
   products.productname,
   'Customer'::text AS rowid
FROM (((customers
    JOIN orders ON ((customers.customerid = orders.customerid)))
    JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
    JOIN products ON ((products.productnumber = order_details.productnumber)))
WHERE ((products.productname)::text ~~ '%Helmet%'::text)
UNION
SELECT vendors.vendname AS fullname,
   products.productname,
   'Vendor'::text AS rowid
FROM ((vendors
    JOIN product_vendors ON ((vendors.vendorid = product_vendors.vendorid)))
    JOIN products ON ((products.productnumber = product_vendors.productnumber)))
WHERE ((products.productname)::text ~~ '%Helmet%'::text);

/* ***** Entertainment Agency Database ***** */
-- 1. Display a combined list of customers and entertainers. 28
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS Name,
    'Customer' AS rowid
FROM entertainmentagencyexample.Customers
UNION ALL
SELECT EntStageName, 'Entertainer' AS rowid
FROM Entertainers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch10_customers_union_entertainers';

SELECT concat(customers.custlastname, ', ', customers.custfirstname) AS name,
   'Customer'::text AS type
  FROM entertainmentagencyexample.customers
UNION
SELECT entertainers.entstagename AS name,
   'Entertainer'::text AS type
  FROM entertainers;

-- 2. Produce a list of customers who like contemporary music together with a
-- list of entertainers who play contemporary music. 5
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS Name,
    'Customer' AS rowid
FROM entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
      ON entertainmentagencyexample.Customers.CustomerID =
            Musical_Preferences.CustomerID
    INNER JOIN Musical_Styles
        ON Musical_Preferences.StyleID = Musical_Styles.StyleID
WHERE Musical_Styles.StyleName = 'Contemporary'
UNION ALL
SELECT EntStageName, 'Entertainer' AS rowid
FROM Entertainers
    INNER JOIN Entertainer_Styles
        ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
    INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
WHERE Musical_Styles.StyleName = 'Contemporary';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch10_customers_entertainers_contemporary';

SELECT concat(customers.custfirstname, ' ', customers.custlastname) AS name,
    'Customer'::text AS type
FROM (musical_styles
    JOIN (entertainmentagencyexample.customers
    JOIN musical_preferences ON ((customers.customerid =
            musical_preferences.customerid))) ON ((musical_styles.styleid =
        musical_preferences.styleid)))
WHERE ((musical_styles.stylename)::text = 'Contemporary'::text)
UNION
SELECT entertainers.entstagename AS name,
   'Entertainer'::text AS type
FROM (musical_styles
    JOIN (entertainers
    JOIN entertainer_styles ON ((entertainers.entertainerid =
            entertainer_styles.entertainerid))) ON ((musical_styles.styleid =
        entertainer_styles.styleid)))
WHERE ((musical_styles.stylename)::text = 'Contemporary'::text);

/* ***** School Scheduling Database ******** */
-- 1. Create a mailing list for students and staff, sorted by ZIP Code. 45
SELECT Students.StudFirstName || ', ' || Students.StudLastName AS FullName,
    Students.StudStreetAddress AS Address, Students.StudCity AS City,
    Students.StudState AS State, Students.StudZipCode AS ZipCode
FROM Students
UNION ALL
SELECT Staff.StfFirstName || ', ' || Staff.StfLastName AS FullName,
    Staff.StfStreetAddress, Staff.StfCity, Staff.StfState,
    Staff.StfZipCode
FROM Staff
ORDER BY 5;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch10_student_staff_mailing_list';

SELECT concat(students.studfirstname, ' ', students.studlastname) AS name,
   students.studstreetaddress,
   students.studcity,
   students.studstate,
   students.studzipcode
FROM students
UNION
SELECT concat(staff.stffirstname, ' ', staff.stflastname) AS name,
   staff.stfstreetaddress AS studstreetaddress,
   staff.stfcity AS studcity,
   staff.stfstate AS studstate,
   staff.stfzipcode AS studzipcode
FROM staff
ORDER BY 5;

/* ***** Bowling League Database *********** */
-- 1. Find the bolers who had a raw score of 165 or better at Thunderbird Lanes
-- combined with bowlers who had a raw score of 150 or better at Bolero Lanes.
-- 129 (134 if counting 165 and 150), using UNION:
SELECT Bowlers.BowlerFirstName, Bowlers.BowlerLastName, Bowler_Scores.RawScore,
    Tournaments.TourneyLocation
FROM Bowlers
    INNER JOIN Bowler_Scores ON Bowlers.BowlerID = Bowler_Scores.BowlerID
    INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
    INNER JOIN Tournaments ON Tourney_Matches.TourneyID = Tournaments.TourneyID
WHERE Tournaments.TourneyLocation LIKE 'Thunderbird%'
    AND Bowler_Scores.RawScore >= 165
UNION
SELECT Bowlers.BowlerFirstName, Bowlers.BowlerLastName, Bowler_Scores.RawScore,
    Tournaments.TourneyLocation
FROM Bowlers
    INNER JOIN Bowler_Scores ON Bowlers.BowlerID = Bowler_Scores.BowlerID
    INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
    INNER JOIN Tournaments ON Tourney_Matches.TourneyID = Tournaments.TourneyID
WHERE Tournaments.TourneyLocation LIKE 'Bolero%'
    AND Bowler_Scores.RawScore >= 150;

-- 135, using WHERE (or 140, if counting 150 and 165)
SELECT Bowlers.BowlerFirstName, Bowlers.BowlerLastName, Bowler_Scores.RawScore,
    Tournaments.TourneyLocation
FROM Bowlers
    INNER JOIN Bowler_Scores ON Bowlers.BowlerID = Bowler_Scores.BowlerID
    INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
    INNER JOIN Tournaments ON Tourney_Matches.TourneyID = Tournaments.TourneyID
WHERE (Tournaments.TourneyLocation LIKE 'Thunderbird%' AND
    Bowler_Scores.RawScore >= 165) OR
    (Tournaments.TourneyLocation LIKE 'Bolero%' AND
    Bowler_Scores.RawScore >= 150)

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch10_good_bowlers_tbird_bolero_union';

SELECT tournaments.tourneylocation,
   bowlers.bowlerlastname,
   bowlers.bowlerfirstname,
   bowler_scores.rawscore
FROM (bowlers
    JOIN ((tournaments
    JOIN tourney_matches ON ((tournaments.tourneyid =
            tourney_matches.tourneyid)))
    JOIN bowler_scores ON ((tourney_matches.matchid = bowler_scores.matchid)))
        ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
WHERE (((tournaments.tourneylocation)::text = 'Thunderbird Lanes'::text) AND
    (bowler_scores.rawscore > 165))
UNION
SELECT tournaments.tourneylocation,
   bowlers.bowlerlastname,
   bowlers.bowlerfirstname,
   bowler_scores.rawscore
FROM (bowlers
    JOIN ((tournaments
    JOIN tourney_matches ON ((tournaments.tourneyid =
            tourney_matches.tourneyid)))
    JOIN bowler_scores ON ((tourney_matches.matchid = bowler_scores.matchid)))
        ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
WHERE (((tournaments.tourneylocation)::text = 'Bolero Lanes'::text) AND
    (bowler_scores.rawscore > 150));

SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch10_good_bowlers_tbird_bolero_where';

SELECT tournaments.tourneylocation,
   bowlers.bowlerlastname,
   bowlers.bowlerfirstname,
   bowler_scores.rawscore
FROM (tournaments
    JOIN (bowlers
    JOIN (tourney_matches
    JOIN bowler_scores
        ON ((tourney_matches.matchid = bowler_scores.matchid)))
        ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
        ON ((tournaments.tourneyid = tourney_matches.tourneyid)))
WHERE ((((tournaments.tourneylocation)::text = 'Thunderbird Lanes'::text) AND
        (bowler_scores.rawscore > 165)) OR (((tournaments.tourneylocation)::text
            = 'Bolero Lanes'::text) AND (bowler_scores.rawscore > 150)));

-- 2. Can you explain why the row counts are different in the previous solution
-- queries?

-- Answer: The query using UNION eliminates duplicate rows, meaning that we only
-- include bowlers once if they scored 165 at Thunderbird or 150 at Bolero.
-- Using UNION ALL will include bowlers twice if they manage to do both.
-- Similarly, we could add the DISTINCT keyword to make the second query with
-- WHERE exactly like the first query with UNION.

/* ***** Recipes Database ****************** */
-- 1. Display a list of all ingredients and their default measurement amounts
-- together with ingredients used in recipes and the measurement amount for each
-- recipe. 144
SELECT Ingredients.IngredientName, Measurements.MeasurementDescription AS
    Measurement, 'Ingredient' AS Type
FROM Ingredients
    INNER JOIN Measurements
        ON Ingredients.MeasureAmountID = Measurements.MeasureAmountID
UNION
SELECT Ingredients.IngredientName, Measurements.MeasurementDescription AS
    Measurement, 'Recipe' AS Type
FROM Ingredients
    INNER JOIN Recipe_Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    INNER JOIN Recipes
        ON Recipe_Ingredients.RecipeID = Recipes.RecipeID
    INNER JOIN Measurements
        ON Recipe_Ingredients.MeasureAmountID = Measurements.MeasureAmountID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch10_ingredient_recipe_measurements';

SELECT ingredients.ingredientname,
   measurements.measurementdescription,
   'Ingredient'::text AS type
FROM (measurements
    JOIN ingredients ON ((measurements.measureamountid =
            ingredients.measureamountid)))
UNION
SELECT ingredients.ingredientname,
   measurements.measurementdescription,
   'Recipe'::text AS type
FROM ((measurements
    JOIN recipe_ingredients ON ((measurements.measureamountid =
            recipe_ingredients.measureamountid)))
    JOIN ingredients ON ((ingredients.ingredientid =
            recipe_ingredients.ingredientid)));
