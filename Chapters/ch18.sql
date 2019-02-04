/* ********** SQL FOR MERE MORTALS CHAPTER 18 ********** */
/* ******** Introduction to Solving Tough Problems ***** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Finding Out the "NOT" Case               ****/
/* ******************************************** ****/
-- Using OUTER JOIN
-- Ex. List ingredients not used in any reicpe yet.
SELECT Ingredients.IngredientName
FROM Ingredients
    LEFT OUTER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipe_Ingredients.RecipeID IS NULL;

--- Solving 3 "NOT" conditions at the same time
-- OUTER JOIN + subquery
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot'))
        AS RBeefCarrotOnion
    ON Recipes.RecipeID = RBeefCarrotOnion.RecipeID
WHERE RBeefCarrotOnion.RecipeID IS NULL;

-- NOT IN
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef')
    AND Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Onion')
    AND Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Carrot')

-- NOT IN, more elegant
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
-- Note: Nice and efficient because subquery only run once
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot'));

-- NOT EXISTS
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
-- Note: Inefficient because subquery ran for each row
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE NOT EXISTS
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')
        AND Recipe_Ingredients.RecipeID = Recipes.RecipeID);

-- Using GROUP BY/HAVING
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS RIBOC
    ON Recipes.RecipeID = RIBOC.RecipeID
WHERE RIBOC.RecipeID IS NULL
GROUP BY Recipes.RecipeID, Recipes.RecipeTitle
HAVING COUNT(RIBOC.RecipeID) = 0;

-- Ex. Find the recipes that have butter but have neither beef, nor onion, nor
-- carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS RIBOC
    ON Recipes.RecipeID = RIBOC.RecipeID
WHERE Ingredients.IngredientName = 'Butter'
    AND RIBOC.RecipeID IS NULL
    GROUP BY Recipes.RecipeID, Recipes.RecipeTitle
HAVING COUNT(RIBOC.RecipeID) = 0;

/* ******************************************** ****/
/* *** Finding Multiple Match in the Same Tables ***/
/* ******************************************** ****/
-- Different ways to match multiple conditions

-- INNER JOIN
-- Ex. List the customers who have booked Carol Peacock Trio, Caroline Coie
-- Cuartet, and Jazz Persuasion.
SELECT DISTINCT CPT.CustomerID,
    CPT.CustFirstName,
    CPT.CustLastName
FROM ((SELECT Customers.CustomerID,
        Customers.CustFirstName,
        Customers.CustLastName
       FROM (entertainmentagencyexample.Customers
           INNER JOIN Engagements
           ON Customers.CustomerID = Engagements.CustomerID)
           INNER JOIN Entertainers
           ON Engagements.EntertainerID = Entertainers.EntertainerID
       WHERE Entertainers.EntStageName = 'Carol Peacock Trio') AS CPT
    INNER JOIN
     (SELECT Customers.CustomerID
      FROM (entertainmentagencyexample.Customers
          INNER JOIN Engagements
          ON Customers.CustomerID = Engagements.CustomerID)
          INNER JOIN Entertainers
          ON Engagements.EntertainerID = Entertainers.EntertainerID
      WHERE Entertainers.EntStageName = 'Caroline Coie Cuartet') AS CCC
    ON CPT.CustomerID = CCC.CustomerID
    INNER JOIN
     (SELECT Customers.CustomerID
      FROM (entertainmentagencyexample.Customers
          INNER JOIN Engagements
          ON Customers.CustomerID = Engagements.CustomerID)
          INNER JOIN Entertainers
          ON Engagements.EntertainerID = Entertainers.EntertainerID
      WHERE Entertainers.EntStageName = 'Jazz Persuasion') AS JP
    ON CCC.CustomerID = JP.CustomerID);

-- IN
-- Query solved wrong: returns customers who booked any combination of the three
-- groups in question.
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
WHERE Customers.CustomerID IN
    (SELECT Customers.CustomerID
    FROM (entertainmentagencyexample.Customers
        INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID)
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName IN
        ('Carol Peacock Trio', 'Caroline Coie Cuartet', 'Jazz Persuasion'));
        
-- Query solved right: with three IN statements joined by AND statements
-- Ex. List the customers who have booked Carol Peacock Trio, Caroline Coie
-- Cuartet, and Jazz Persuasion
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
WHERE Customers.CustomerID IN
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Carol Peacock Trio')
    AND Customers.CustomerID IN
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Caroline Coie Cuartet')
    AND Customers.CustomerID IN
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Jazz Persuasion')

-- EXISTS
-- Ex. List the customers who have booked Carol Peacock Trio, Caroline Coie
-- Cuartet, and Jazz Persuasion.
-- Note: Subquery needs to check for each row (correlated subquery)
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
WHERE EXISTS
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Carol Peacock Trio'
        AND Engagements.CustomerID = Customers.CustomerID)
    AND EXISTS
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Caroline Coie Cuartet'
        AND Engagements.CustomerID = Customers.CustomerID)
    AND EXISTS
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Jazz Persuasion'
        AND Engagements.CustomerID = Customers.CustomerID);

-- GROUP BY/HAVING
-- Ex. Display customers and groups where the musical styles of the group match
-- all the musical styles preferred by the customer.
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Entertainers.EntertainerID,
    Entertainers.EntStageName,
    COUNT(Musical_Preferences.StyleID) AS CountofStyleID
FROM ((entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
    ON Customers.CustomerID = Musical_Preferences.CustomerID)
    INNER JOIN Entertainer_Styles
    ON Musical_Preferences.StyleID = Entertainer_Styles.StyleID)
    INNER JOIN Entertainers
    ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
GROUP BY Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Entertainers.EntertainerID,
    Entertainers.EntStageName
HAVING COUNT(Musical_Preferences.StyleID) = 
    (SELECT COUNT(*)
    FROM Musical_Preferences
    WHERE Musical_Preferences.CustomerID = Customers.CustomerID);

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- Ex. Find all customers who ordered a bicycle and also ordered a helmet.
SELECT DISTINCT Customers.CustomerID,
    Customers.CustLastName,
    Customers.CustFirstName
FROM Customers
WHERE EXISTS
    (SELECT *
    FROM (Orders
          INNER JOIN Order_Details
          ON Orders.OrderNumber = Order_Details.OrderNumber)
          INNER JOIN Products
          ON Products.ProductNumber = Order_Details.ProductNumber
    WHERE Products.ProductName LIKE '%Bike'
        AND Orders.CustomerID = Customers.CustomerID)
    AND EXISTS
    (SELECT *
    FROM (Orders
          INNER JOIN Order_Details
          ON Orders.OrderNumber = Order_Details.OrderNumber)
          INNER JOIN Products
          ON Products.ProductNumber = Order_Details.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet'
        AND Orders.CustomerID = Customers.CustomerID);

-- Ex. Find all the customers who have not ordered either bikes or tires.
SELECT Customers.CustomerID,
    Customers.CustLastName,
    Customers.CustFirstName
FROM Customers
WHERE Customers.CustomerID NOT IN
    -- Customers who ordered bikes
    (SELECT CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.CategoryID = 2)
    AND Customers.CustomerID NOT IN
    -- Customers who ordered tires
    (SELECT CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.CategoryID = 6)

/* ***** Entertainment Agency Database ***** */
-- Ex. List the entertainers who played engagements for customers Berg and
-- Hallmark.
-- Solved with EXISTS
SELECT Entertainers.EntStageName
FROM Entertainers
WHERE EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID = Customers.CustomerID
    WHERE Customers.CustLastName = 'Berg'
        AND Engagements.EntertainerID = Entertainers.EntertainerID)
    AND EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID = Customers.CustomerID
    WHERE Customers.CustLastName = 'Hallmark'
        AND Engagements.EntertainerID = Entertainers.EntertainerID)
        
-- Ex. Display agents who have never booked a Country or Country Rock group.
SELECT Agents.AgentID,
    Agents.AgtFirstName,
    Agents.AgtLastName
FROM Agents
WHERE Agents.AgentID NOT IN
    (SELECT Engagements.AgentID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
        INNER JOIN Entertainer_Styles
        ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE Musical_Styles.StyleName IN ('Country','Country Rock'));

/* ***** School Scheduling Database ******** */
-- Ex. List students who have a grade of 85 or better in both art and computer
-- science.
SELECT Students.StudFirstName,
    Students.StudLastName
FROM Students
WHERE Students.StudentID IN
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Classes
        ON Student_Schedules.ClassID = Classes.ClassID
        INNER JOIN Subjects
        ON Classes.SubjectID = Subjects.SubjectID
        INNER JOIN schoolschedulingexample.Categories
        ON Subjects.CategoryID = Categories.CategoryID
    WHERE Student_Schedules.Grade >= 85
        AND Categories.CategoryDescription = 'Art')
    AND Students.StudentID IN
    -- Note: Not actually computer science; only students available in Computer
    -- Information Systems
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Classes
        ON Student_Schedules.ClassID = Classes.ClassID
        INNER JOIN Subjects
        ON Classes.SubjectID = Subjects.SubjectID
        INNER JOIN schoolschedulingexample.Categories
        ON Subjects.CategoryID = Categories.CategoryID
    WHERE Student_Schedules.Grade >= 85
        AND Categories.CategoryDescription LIKE '%Computer%')

-- Ex. Show me students registered for classes for which they have no completed
-- the prerequisite course. OR:
-- Ex. Show the students and the courses for which they are registered that have
-- prerequisites for which there is not a registration for this student in the
-- prerequisite course (and the student did not withdraw) with a start date of
-- the prerequisite course that is equal to or greater than the current course.
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName,
    Classes.StartDate,
    Subjects.SubjectCode,
    Subjects.SubjectName,
    Subjects.SubjectPreReq
FROM Students
    INNER JOIN Student_Schedules
    ON Students.StudentID = Student_Schedules.StudentID
    INNER JOIN Classes
    ON Classes.ClassID = Student_Schedules.ClassID
    INNER JOIN Subjects
    ON Subjects.SubjectID = Classes.SubjectID
WHERE Subjects.SubjectPreReq NOT IN
    (SELECT Subjects.SubjectCode
    FROM Subjects
        INNER JOIN Classes AS C2
        ON Subjects.SubjectID = C2.SubjectID
        INNER JOIN Student_Schedules
        ON C2.ClassID = Student_Schedules.ClassID
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription <> 'Withdrew'
        AND Student_Schedules.StudentID = Students.StudentID
        AND C2.StartDate <= Classes.StartDate);

/* ***** Bowling League Database *********** */
-- Ex. List the bowlers, the match number, the game number, the handicap score,
-- the tournament data, and the tournament location for bowlers who won a game
-- with a handicap score of 190 or less at Thunderbird Lanes, Totem Lanes, and
-- bolero Lanes.
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    Bowler_Scores.MatchID,
    Bowler_Scores.GameNumber,
    Bowler_Scores.HandiCapScore,
    Tournaments.TourneyDate,
    Tournaments.TourneyLocation
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
    INNER JOIN Tourney_Matches
    ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
    INNER JOIN Tournaments
    ON Tourney_Matches.TourneyID = Tournaments.TourneyID
WHERE Bowler_Scores.HandiCapScore <= 190
    AND (Bowler_Scores.WonGame = 1
    AND Tournaments.TourneyLocation IN
        ('Thunderbird Lanes', 'Totem Lanes', 'Bolero Lanes'))
-- Note: It seems redundant to filter on score, won game, and tourney location
-- twice, but this prevents us from selecting all games from which the bowler
-- has at least one game; we only want the games that bowlers scored 190 or less
-- not a list of all their games
    AND Bowlers.BowlerID IN
    (SELECT Bowler_Scores.BowlerID
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Tournaments.TourneyLocation = 'Bolero Lanes'
        AND Bowler_Scores.WonGame = 1
        AND Bowler_Scores.HandiCapScore <= 190)
    AND Bowlers.BowlerID IN
    (SELECT Bowler_Scores.BowlerID
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Tournaments.TourneyLocation = 'Thunderbird Lanes'
        AND Bowler_Scores.WonGame = 1
        AND Bowler_Scores.HandiCapScore <= 190)
    AND Bowlers.BowlerID IN
    (SELECT Bowler_Scores.BowlerID
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Tournaments.TourneyLocation = 'Totem Lanes'
        AND Bowler_Scores.WonGame = 1
        AND Bowler_Scores.HandiCapScore <= 190)

/* Book "Incorrect" Answer */
-- The below answer selects all bowlers and all their matches that had any game
-- with 190 or less
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch18_bowlers_won_lowscore_tbird_totem_bolero_wrong';

SELECT bowlers.bowlerid,
   bowlers.bowlerfirstname,
   bowlers.bowlerlastname,
   bowler_scores.matchid,
   bowler_scores.gamenumber,
   bowler_scores.handicapscore,
   tournaments.tourneydate,
   tournaments.tourneylocation
FROM (((bowlers
    JOIN bowler_scores
    ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
    JOIN tourney_matches
    ON ((bowler_scores.matchid = tourney_matches.matchid)))
    JOIN tournaments
    ON ((tournaments.tourneyid = tourney_matches.tourneyid)))
WHERE ((bowler_scores.handicapscore <= 190)
    AND (bowler_scores.wongame = 1)
    AND ((tournaments.tourneylocation)::text = ANY
        ((ARRAY['Thunderbird Lanes'::character varying,
                'Totem Lanes'::character varying,
                'Bolero Lanes'::character varying])::text[])));

-- Ex. Show me the bowlers who have not bowled a raw score better than 165 at
-- Thunderbird Lanes and Bolero Lanes.
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
FROM Bowlers
WHERE Bowlers.BowlerID NOT IN
    (SELECT Bowler_Scores.BowlerID
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Bowler_Scores.RawScore > 165
        AND Tournaments.TourneyLocation IN
            ('Thunderbird Lanes', 'Bolero Lanes'));

-- Alternate answer
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
FROM Bowlers
WHERE NOT EXISTS
    (SELECT *
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Bowler_Scores.RawScore > 165
        AND Tournaments.TourneyLocation IN
            ('Thunderbird Lanes', 'Bolero Lanes')
        AND Bowler_Scores.BowlerID = Bowlers.BowlerID);

/* ***** Recipes Database ****************** */
-- Ex. Display the ingredients that are not used in the recipes for Irish Stew,
-- Pollo Picoso, and Roast Beef
SELECT Ingredients.IngredientName
FROM Ingredients
WHERE Ingredients.IngredientID NOT IN
    (SELECT Ingredients.IngredientID
    FROM Ingredients
        INNER JOIN Recipe_Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
        INNER JOIN Recipes
        ON Recipe_Ingredients.RecipeID = Recipes.RecipeID
    WHERE Recipes.RecipeTitle IN ('Irish Stew', 'Pollo Picoso', 'Roast Beef'));
        
-- Ex. List the pairs of recipes where both recipes have at least the same three
-- ingredients.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle,
    R2.RecipeID R2ID,
    R2.RecipeTitle R2Title,
    COUNT(Recipe_Ingredients.RecipeID) AS CountOfRecipeID
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Recipe_Ingredients RI2
    ON Recipe_Ingredients.IngredientID = RI2.IngredientID
    INNER JOIN Recipes R2
    ON RI2.RecipeID = R2.RecipeID
WHERE RI2.RecipeID > Recipes.RecipeID
GROUP BY Recipes.RecipeID, Recipes.RecipeTitle,
    R2.RecipeID, R2.RecipeTitle
HAVING COUNT(Recipe_Ingredients.RecipeID) >= 3;

/* ******************************************** ****/
/* *** Problems for You to Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- 1. Display the customers who have never ordered bikes or tires. 2
-- Bonus: Do not use NOT IN.

-- Using NOT IN
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
WHERE Customers.CustomerID NOT IN
    (SELECT Orders.CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription IN ('Bikes', 'Tires'));

-- Using NOT EXISTS
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
WHERE NOT EXISTS
    (SELECT *
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription IN ('Bikes', 'Tires')
        AND Orders.CustomerID = Customers.CustomerID)

-- Using OUTER JOIN
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
    LEFT OUTER JOIN
    (SELECT Orders.CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription IN ('Bikes', 'Tires')) BikesTires
    ON Customers.CustomerID = BikesTires.CustomerID
WHERE BikesTires.CustomerID IS NULL;

-- Using GROUP BY/HAVING
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
    LEFT OUTER JOIN
    (SELECT Orders.CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription IN ('Bikes', 'Tires')) BikesTires
    ON Customers.CustomerID = BikesTires.CustomerID
GROUP BY Customers.CustFirstName,
    Customers.CustLastName
HAVING COUNT(BikesTires.CustomerID) = 0;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch18_customers_not_bikes_or_tires_notin_1';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM customers
WHERE (NOT (customers.customerid
        IN ( SELECT orders.customerid
             FROM ((orders
                 JOIN order_details
                 ON ((orders.ordernumber = order_details.ordernumber)))
                 JOIN products
                 ON ((order_details.productnumber = products.productnumber)))
             WHERE (products.categoryid = ANY (ARRAY[2, 6])))));

-- 2. List the customers who have purchased a bike but not a helmet. 2
-- Use: EXISTS, NOT EXISTS
-- Bonus: IN, NOT IN

-- Using EXISTs, NOT EXISTS
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
WHERE EXISTS
    (SELECT *
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes'
        AND Customers.CustomerID = Orders.CustomerID)
    AND NOT EXISTS
    (SELECT *
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet%'
        AND Customers.CustomerID = Orders.CustomerID)

-- Using IN, NOT IN
SELECT Customers.CustFirstName,
    Customers.CustLastName
FROM Customers
WHERE Customers.CustomerID IN
    (SELECT Orders.CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes')
    AND Customers.CustomerID NOT IN
    (SELECT Orders.CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet%')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch18_cust_bikes_no_helmets_exists';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM customers
WHERE ((EXISTS ( SELECT orders.ordernumber,
            orders.orderdate,
            orders.shipdate,
            orders.customerid,
            orders.employeeid,
            order_details.ordernumber,
            order_details.productnumber,
            order_details.quotedprice,
            order_details.quantityordered,
            products.productnumber,
            products.productname,
            products.productdescription,
            products.retailprice,
            products.quantityonhand,
            products.categoryid
           FROM ((orders
             JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
             JOIN products ON ((products.productnumber = order_details.productnumber)))
          WHERE ((products.categoryid = 2)
            AND (orders.customerid = customers.customerid))))
            AND (NOT (EXISTS ( SELECT
            orders.ordernumber,
            orders.orderdate,
            orders.shipdate,
            orders.customerid,
            orders.employeeid,
            order_details.ordernumber,
            order_details.productnumber,
            order_details.quotedprice,
            order_details.quantityordered,
            products.productnumber,
            products.productname,
            products.productdescription,
            products.retailprice,
            products.quantityonhand,
            products.categoryid
           FROM ((orders
             JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
             JOIN products ON ((products.productnumber = order_details.productnumber)))
          WHERE (((products.productname)::text ~~ '%Helmet'::text) AND
            (orders.customerid = customers.customerid))))));

-- 3. Show me the customer orders that have a bike but do not have a helmet. 397
-- Use: EXISTs, NOT EXISTS
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Orders.OrderNumber,
    Orders.OrderDate,
    Orders.ShipDate
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
WHERE EXISTS
    -- Orders with a bike
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes'
        AND Order_Details.OrderNumber = Orders.OrderNumber)
    AND NOT EXISTS
    -- Orders with a helmet
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet%'
        AND Order_Details.OrderNumber = Orders.OrderNumber);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch18_orders_bikes_no_helmet_exists';

-- WARNING: The book answer is incorrect as it only searches for products whose
-- names end in "Helmet", case sensitive. Check the next query for proof.
SELECT customers.customerid,
   customers.custfirstname,
   customers.custlastname,
   orders.ordernumber,
   orders.orderdate
FROM (customers
    JOIN orders
    ON ((customers.customerid = orders.customerid)))
WHERE ((EXISTS ( SELECT order_details.ordernumber
           FROM ((order_details
             JOIN products
             ON ((order_details.productnumber = products.productnumber)))
             JOIN categories
             ON ((products.categoryid = categories.categoryid)))
           WHERE (((categories.categorydescription)::text = 'Bikes'::text)
             AND (order_details.ordernumber = orders.ordernumber))))
      AND (NOT (EXISTS ( SELECT order_details.ordernumber,
            order_details.productnumber,
            order_details.quotedprice,
            order_details.quantityordered,
            products.productnumber,
            products.productname,
            products.productdescription,
            products.retailprice,
            products.quantityonhand,
            products.categoryid
           FROM (order_details
             JOIN products
             ON ((order_details.productnumber = products.productnumber)))
          WHERE (((products.productname)::text ~~ '%Helmet'::text)
            AND (order_details.ordernumber = orders.ordernumber))))));

-- Proof that the book answer is actually incorrect
-- List all orders and product names where we search for "Helmet%" vs "%Helmet%"
-- I.e. What orders does the book answer retrieve that my answer doesn't? 
-- Spoiler: The book gets 5 unique customer orders too many that contain a
-- product named "Dog Ear Helmet Mount Mirrors", which contains the word
-- "Helmet" but does not end in it.
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Orders.OrderNumber,
    Orders.OrderDate,
    Orders.ShipDate,
    Products.ProductName
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
    INNER JOIN Products
    ON Order_Details.ProductNumber = Products.ProductNumber
WHERE EXISTS
    -- Orders with a bike
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes'
        AND Order_Details.OrderNumber = Orders.OrderNumber)
    AND NOT EXISTS
    -- Orders with a helmet
    -- Note: This subquery returns all orders containing products whose name
    -- _ends_ in "helmet". This will miss one product whose name _contains_, but
    -- does not _end_ in helmet.
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet'
        AND Order_Details.OrderNumber = Orders.OrderNumber)
    -- Remove all orders that have a product in the bike category but do not
    -- have a product whose name _contains_ the case insensitive word "helmet"
    AND Orders.OrderNumber NOT IN
    -- Repeat of the query, except with products containing the word "helmet"
    (SELECT Orders.OrderNumber
    FROM Customers
        INNER JOIN Orders
        ON Customers.CustomerID = Orders.CustomerID
    WHERE EXISTS
        -- Orders with a bike
        (SELECT *
        FROM Order_Details
            INNER JOIN Products
            ON Order_Details.ProductNumber = Products.ProductNumber
            INNER JOIN Categories
            ON Products.CategoryID = Categories.CategoryID
        WHERE Categories.CategoryDescription = 'Bikes'
            AND Order_Details.OrderNumber = Orders.OrderNumber)
        AND NOT EXISTS
        -- Orders with a helmet
        -- Caution! Do not use LIKE '%Helmet%'
        (SELECT *
        FROM Order_Details
            INNER JOIN Products
            ON Order_Details.ProductNumber = Products.ProductNumber
        WHERE Products.ProductName LIKE '%Helmet%'
            AND Order_Details.OrderNumber = Orders.OrderNumber))

-- 4. Display the customers and their orders that have a bike and a helmet in
-- the same order. 189
-- Same deal as before: book answer misses all orders with "Dog Ear Helmet Mount
-- Mirrors"
-- Use: EXISTS
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Orders.OrderNumber,
    Orders.OrderDate
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
WHERE EXISTS
    -- Orders with a bike
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes'
        AND Order_Details.OrderNumber = Orders.OrderNumber)
    AND EXISTS
    -- Orders with a helmet
    (SELECT *
    FROM Order_Details
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE Products.ProductName LIKE '%Helmet%'
        AND Order_Details.OrderNumber = Orders.OrderNumber);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch18_customers_bikes_and_helmets_same_order';

-- WARNING: This answer is incorrect as it misses 5 orders with "Dog Ear Helmet
-- Mount Mirrors"
SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname,
    orders.ordernumber,
    orders.orderdate
   FROM (customers
     JOIN orders ON ((customers.customerid = orders.customerid)))
  WHERE ((EXISTS ( SELECT o2.ordernumber,
            o2.orderdate,
            o2.shipdate,
            o2.customerid,
            o2.employeeid,
            order_details.ordernumber,
            order_details.productnumber,
            order_details.quotedprice,
            order_details.quantityordered,
            products.productnumber,
            products.productname,
            products.productdescription,
            products.retailprice,
            products.quantityonhand,
            products.categoryid
           FROM ((orders o2
             JOIN order_details
             ON ((o2.ordernumber = order_details.ordernumber)))
             JOIN products
             ON ((products.productnumber = order_details.productnumber)))
          WHERE ((products.categoryid = 2)
            AND (orders.customerid = customers.customerid)
            AND (o2.ordernumber = orders.ordernumber))))
        AND (EXISTS ( SELECT o3.ordernumber,
            o3.orderdate,
            o3.shipdate,
            o3.customerid,
            o3.employeeid,
            order_details.ordernumber,
            order_details.productnumber,
            order_details.quotedprice,
            order_details.quantityordered,
            products.productnumber,
            products.productname,
            products.productdescription,
            products.retailprice,
            products.quantityonhand,
            products.categoryid
           FROM ((orders o3
             JOIN order_details
             ON ((o3.ordernumber = order_details.ordernumber)))
             JOIN products
             ON ((products.productnumber = order_details.productnumber)))
          WHERE (((products.productname)::text ~~ '%Helmet'::text)
            AND (orders.customerid = customers.customerid)
            AND (o3.ordernumber = orders.ordernumber)))));

-- 5. Show the vendors who sell accessories, car racks, and clothing. 3
-- Use: IN
SELECT Vendors.VendorID,
    Vendors.VendName
FROM Vendors
WHERE Vendors.VendorID IN
    (SELECT Vendors.VendorID
    FROM Vendors
        INNER JOIN Product_Vendors
        ON Vendors.VendorID = Product_Vendors.VendorID
        INNER JOIN Products
        ON Product_Vendors.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Accessories')
    AND Vendors.VendorID IN
    (SELECT Vendors.VendorID
    FROM Vendors
        INNER JOIN Product_Vendors
        ON Vendors.VendorID = Product_Vendors.VendorID
        INNER JOIN Products
        ON Product_Vendors.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Car racks')
    AND Vendors.VendorID IN
    (SELECT Vendors.VendorID
    FROM Vendors
        INNER JOIN Product_Vendors
        ON Vendors.VendorID = Product_Vendors.VendorID
        INNER JOIN Products
        ON Product_Vendors.ProductNumber = Products.ProductNumber
        INNER JOIN Categories
        ON Products.CategoryID = Categories.CategoryID
    WHERE Categories.CategoryDescription = 'Clothing')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch18_vendors_accessories_carracks_clothing';

SELECT vendors.vendorid,
    vendors.vendname
FROM vendors
WHERE ((vendors.vendorid IN ( SELECT product_vendors.vendorid
           FROM ((product_vendors
             JOIN products ON ((product_vendors.productnumber = products.productnumber)))
             JOIN categories ON ((products.categoryid = categories.categoryid)))
          WHERE ((categories.categorydescription)::text = 'Accessories'::text))) AND (vendors.vendorid IN ( SELECT product_vendors.vendorid
           FROM ((product_vendors
             JOIN products ON ((product_vendors.productnumber = products.productnumber)))
             JOIN categories ON ((products.categoryid = categories.categoryid)))
          WHERE ((categories.categorydescription)::text = 'Car racks'::text))) AND (vendors.vendorid IN ( SELECT product_vendors.vendorid
           FROM ((product_vendors
             JOIN products ON ((product_vendors.productnumber = products.productnumber)))
             JOIN categories ON ((products.categoryid = categories.categoryid)))
          WHERE ((categories.categorydescription)::text = 'Clothing'::text))));

/* ***** Entertainment Agency Database ***** */
-- 1. List the entertainers who play the Jazz, Rhythm and Blues, and Salsa
-- styles. 1 (Jazz Persuasion)
-- Use IN
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName
FROM Entertainers
WHERE Entertainers.EntertainerID IN
    (SELECT Entertainer_Styles.EntertainerID
    FROM Entertainer_Styles
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE Musical_Styles.StyleName = 'Jazz')
    AND Entertainers.EntertainerID IN
    (SELECT Entertainer_Styles.EntertainerID
    FROM Entertainer_Styles
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE Musical_Styles.StyleName = 'Rhythm and Blues')
    AND Entertainers.EntertainerID IN
    (SELECT Entertainer_Styles.EntertainerID
    FROM Entertainer_Styles
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE Musical_Styles.StyleName = 'Salsa')

-- Extra credit: use GROUP BY/HAVING
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName
FROM Entertainers
    INNER JOIN Entertainer_Styles
    ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
    INNER JOIN Musical_Styles
    ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
WHERE Musical_Styles.StyleName IN ('Jazz', 'Rhythm and Blues', 'Salsa')
GROUP BY Entertainers.EntertainerID,
    Entertainers.EntStageName
HAVING COUNT(Musical_Styles.StyleID) = 3;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_jazz_rhythmblues_salsa_in';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE ((entertainers.entertainerid IN
        ( SELECT entertainer_styles.entertainerid
           FROM (entertainer_styles
             JOIN musical_styles
             ON ((entertainer_styles.styleid = musical_styles.styleid)))
          WHERE ((musical_styles.stylename)::text = 'Jazz'::text)))
            AND (entertainers.entertainerid IN
                ( SELECT entertainer_styles.entertainerid
                  FROM (entertainer_styles
                    JOIN musical_styles
                    ON ((entertainer_styles.styleid = musical_styles.styleid)))
                  WHERE ((musical_styles.stylename)::text = 'Rhythm and Blues'::text)))
            AND (entertainers.entertainerid IN
                ( SELECT entertainer_styles.entertainerid
                   FROM (entertainer_styles
                     JOIN musical_styles
                     ON ((entertainer_styles.styleid = musical_styles.styleid)))
                  WHERE ((musical_styles.stylename)::text = 'Salsa'::text))));

/* Book Answer -- Demonstrating Wrong Answer with IN */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_jazz_rhythmblues_salsa_in_wrong';

-- Query is wrong because this only selects any entertainer with at least one of
-- the three styles (1, 2, or all 3; we want all 3 only).
SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE (entertainers.entertainerid IN
    ( SELECT entertainer_styles.entertainerid
      FROM (entertainer_styles
          JOIN musical_styles
          ON ((entertainer_styles.styleid = musical_styles.styleid)))
      WHERE ((musical_styles.stylename)::text = ANY
        ((ARRAY['Jazz'::character varying,
                'Rhythm and Blues'::character varying,
                'Salsa'::character varying])::text[]))));

/* Book Answer -- Extra credit */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_jazz_rhythmblues_salsa_having';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM ((entertainers
     JOIN entertainer_styles
     ON ((entertainers.entertainerid = entertainer_styles.entertainerid)))
     JOIN musical_styles
     ON ((entertainer_styles.styleid = musical_styles.styleid)))
WHERE ((musical_styles.stylename)::text = ANY
    ((ARRAY['Jazz'::character varying,
            'Rhythm and Blues'::character varying,
            'Salsa'::character varying])::text[]))
GROUP BY entertainers.entertainerid,
    entertainers.entstagename
HAVING (count(*) = 3);

-- 2. Show the entertainers who did not have a booking in the 90 days preceding
-- May 1, 2018. 2
-- Use NOT IN
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName
FROM Entertainers
WHERE Entertainers.EntertainerID NOT IN
    (SELECT Engagements.EntertainerID
    FROM Engagements
    WHERE StartDate BETWEEN (DATE '05-01-2018' - 90) AND ('05-01-2018'));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_not_booked_90days_before_may1_2018';

SELECT entertainers.entertainerid,
    entertainers.entstagename
    FROM entertainers
WHERE (NOT (entertainers.entertainerid IN
        ( SELECT engagements.entertainerid
      FROM engagements
      WHERE (engagements.startdate > ('2018-05-01'::date - 90)))));

-- 3. Display customers who have not booked Topazz or Modern Dance. 6
-- Use NOT IN
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName 
FROM entertainmentagencyexample.Customers
WHERE Customers.CustomerID NOT IN
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Topazz')
    AND Customers.CustomerID NOT IN
    (SELECT Engagements.CustomerID
    FROM Engagements
        INNER JOIN Entertainers
        ON Engagements.EntertainerID = Entertainers.EntertainerID
    WHERE Entertainers.EntStageName = 'Modern Dance');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_customers_not_booked_topazz_or_moderndance';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM entertainmentagencyexample.customers
WHERE ((NOT (customers.customerid IN
    ( SELECT engagements.customerid
      FROM (engagements
          JOIN entertainers
          ON ((engagements.entertainerid = entertainers.entertainerid)))
      WHERE ((entertainers.entstagename)::text = 'Topazz'::text))))
        AND (NOT (customers.customerid IN
    ( SELECT engagements.customerid
       FROM (engagements
         JOIN entertainers
         ON ((engagements.entertainerid = entertainers.entertainerid)))
      WHERE ((entertainers.entstagename)::text = 'Modern Dance'::text)))));

-- 4. List the entertainers who have performed for Hartwig, McCrae, and Rosales.
-- 2
-- Use EXISTS
SELECT Entertainers.EntStageName
FROM Entertainers
WHERE EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Customers.CustomerID = Engagements.CustomerID
    WHERE Customers.CustLastName = 'Hartwig'
        AND Engagements.EntertainerID = Entertainers.EntertainerID)
    AND EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Customers.CustomerID = Engagements.CustomerID
    WHERE Customers.CustLastName = 'McCrae'
        AND Engagements.EntertainerID = Entertainers.EntertainerID)
    AND EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Customers.CustomerID = Engagements.CustomerID
    WHERE Customers.CustLastName = 'Rosales'
        AND Engagements.EntertainerID = Entertainers.EntertainerID)

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_hartwig_mccrae_and_rosales_exists';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE ((EXISTS ( SELECT customers.customerid,
            customers.custfirstname,
            customers.custlastname,
            customers.custstreetaddress,
            customers.custcity,
            customers.custstate,
            customers.custzipcode,
            customers.custphonenumber,
            engagements.engagementnumber,
            engagements.startdate,
            engagements.enddate,
            engagements.starttime,
            engagements.stoptime,
            engagements.contractprice,
            engagements.customerid,
            engagements.agentid,
            engagements.entertainerid
           FROM (entertainmentagencyexample.customers
             JOIN engagements
             ON ((customers.customerid = engagements.customerid)))
          WHERE (((customers.custlastname)::text = 'Hartwig'::text)
            AND (engagements.entertainerid = entertainers.entertainerid))))
        AND (EXISTS ( SELECT customers.customerid,
            customers.custfirstname,
            customers.custlastname,
            customers.custstreetaddress,
            customers.custcity,
            customers.custstate,
            customers.custzipcode,
            customers.custphonenumber,
            engagements.engagementnumber,
            engagements.startdate,
            engagements.enddate,
            engagements.starttime,
            engagements.stoptime,
            engagements.contractprice,
            engagements.customerid,
            engagements.agentid,
            engagements.entertainerid
           FROM (entertainmentagencyexample.customers
             JOIN engagements
             ON ((customers.customerid = engagements.customerid)))
          WHERE (((customers.custlastname)::text = 'McCrae'::text)
            AND (engagements.entertainerid = entertainers.entertainerid))))
        AND (EXISTS ( SELECT customers.customerid,
            customers.custfirstname,
            customers.custlastname,
            customers.custstreetaddress,
            customers.custcity,
            customers.custstate,
            customers.custzipcode,
            customers.custphonenumber,
            engagements.engagementnumber,
            engagements.startdate,
            engagements.enddate,
            engagements.starttime,
            engagements.stoptime,
            engagements.contractprice,
            engagements.customerid,
            engagements.agentid,
            engagements.entertainerid
           FROM (entertainmentagencyexample.customers
             JOIN engagements
             ON ((customers.customerid = engagements.customerid)))
          WHERE (((customers.custlastname)::text = 'Rosales'::text)
            AND (engagements.entertainerid = entertainers.entertainerid)))));


-- 5. Display the customers who have never booked an entertainer. 2
-- Using NOT EXISTS
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
WHERE NOT EXISTS
    (SELECT *
    FROM Engagements
    WHERE Engagements.CustomerID = Customers.CustomerID)

-- Using GROUP BY / HAVING
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
    LEFT OUTER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
HAVING COUNT(Engagements.CustomerID) = 0;
    
-- Using LEFT OUTER JOIN and NULL
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
    LEFT OUTER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.CustomerID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_customers_no_bookings_not_in';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM entertainmentagencyexample.customers
WHERE (NOT (customers.customerid IN
        ( SELECT engagements.customerid
          FROM engagements)));

-- Show the entertainers who have no bookings. 1
-- Using NOT IN
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName
FROM Entertainers
WHERE Entertainers.EntertainerID NOT IN
    (SELECT Engagements.EntertainerID
    FROM Engagements);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch18_entertainers_never_booked_not_in';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE (NOT (entertainers.entertainerid IN
        ( SELECT engagements.entertainerid
          FROM engagements)));

/* ***** School Scheduling Database ******** */
-- 1. Show students who have a grade of 85 or better in both Art and Computer
-- Science. 1
-- Use EXISTS
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
FROM Students
WHERE EXISTS
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Classes
        ON Student_Schedules.ClassID = Classes.ClassID
        INNER JOIN Subjects
        ON Classes.SubjectID = Subjects.SubjectID
        INNER JOIN schoolschedulingexample.Categories
        ON Subjects.CategoryID = Categories.CategoryID
    WHERE Student_Schedules.Grade >= 85
        AND Categories.CategoryDescription = 'Art'
        AND Student_Schedules.StudentID = Students.StudentID)
    AND EXISTS
    -- Note: Not actually computer science; only students available in Computer
    -- Information Systems
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Classes
        ON Student_Schedules.ClassID = Classes.ClassID
        INNER JOIN Subjects
        ON Classes.SubjectID = Subjects.SubjectID
        INNER JOIN schoolschedulingexample.Categories
        ON Subjects.CategoryID = Categories.CategoryID
    WHERE Student_Schedules.Grade >= 85
        AND Categories.CategoryDescription LIKE '%Computer%'
        AND Student_Schedules.StudentID = Students.StudentID)

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_good_art_cs_students_exists';

-- 2. Display the staff members who are teaching classes for which they are not
-- accredited. 4 classes, 2 staff total.
-- The trick is to find rows in the faculty classes that are not in the faculty
-- subjects table.
-- Solution without subqueries (LEFT OUTER JOIN / IS NULL)
-- Note: This solution has 2 duplicate entries because it is counting by class
-- We can fix that by using DISTINCT
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
    -- Match faculty classe subject to faculty subject expertise by class and
    -- staffid: this lets us compare the class's subject to rows in faculty
    -- subjects
    LEFT OUTER JOIN Faculty_Subjects
    ON Classes.SubjectID = Faculty_Subjects.SubjectID
        AND Faculty_Classes.StaffID = Faculty_Subjects.StaffID
WHERE Faculty_Subjects IS NULL;

-- Solution using subqueries
-- We want StaffIDs in Faculty_Classes where the staff teaching the class does
-- not have a row in the faculty subjects with the same subject ID
-- Translation: StaffID is NOT IN Faculty subjects given SubjectID
-- Using NOT IN
-- Note: This solution has 2 duplicate entries because it is counting by class
-- We can fix that by using DISTINCT
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
WHERE Faculty_Classes.StaffID NOT IN
    (SELECT Faculty_Subjects.StaffID
    FROM Faculty_Subjects
    WHERE Faculty_Subjects.SubjectID = Classes.SubjectID)

-- Using NOT EXISTS
-- Note: This solution has 2 duplicate entries because it is counting by class
-- We can fix that by using DISTINCT
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
WHERE NOT EXISTS
    (SELECT *
    FROM Faculty_Subjects
    WHERE Faculty_Subjects.SubjectID = Classes.SubjectID
        AND Faculty_Classes.StaffID = Faculty_Subjects.StaffID)

-- INCORRECT SOLUTION: Using GROUP BY / HAVING
-- The idea of this solution is that staff who have null rows which normally can
-- be counted as COUNT(column). Note that we also can't simply use
-- COUNT(Faculty_Subjects.StaffID) to look for null rows, because that would
-- only find staff who are teaching but are not accredited for any subject-- a
-- strange and definitely incorrect query. Each staff is accredited for at
-- least one subject, which is why we get 0 rows.
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
    -- Match faculty classe subject to faculty subject expertise by class and
    -- staffid: this lets us compare the class's subject to rows in faculty
    -- subjects
    LEFT OUTER JOIN Faculty_Subjects
    ON Classes.SubjectID = Faculty_Subjects.SubjectID
        AND Faculty_Classes.StaffID = Faculty_Subjects.StaffID
GROUP BY Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
HAVING COUNT(Faculty_Subjects.StaffID) = 0;

-- CORRECT GROUP BY/HAVING
-- We can use a CASE WHEN, which is cheating because we haven't seen it yet,
-- since the LEFT OUTER JOIN causes Faculty_Subjects.StaffID to have a mix of
-- actual entries and NULL entries. We use the CASE statement to only count NULL
-- rows, which ensures correctness.
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
    -- Match faculty classe subject to faculty subject expertise by class and
    -- staffid: this lets us compare the class's subject to rows in faculty
    -- subjects
    LEFT OUTER JOIN Faculty_Subjects
    ON Classes.SubjectID = Faculty_Subjects.SubjectID
        AND Faculty_Classes.StaffID = Faculty_Subjects.StaffID
GROUP BY Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
HAVING SUM(CASE WHEN Faculty_Subjects.SubjectID IS NULL THEN 1 END) > 0;

-- ALTERNATE GROUP BY/HAVING
-- Idea: The count of all rows minus the count of Faculty_Subjects.StaffID will
-- return the number of null rows, because COUNT with a specific column will
-- ignore null rows, whereas COUNT(*) or COUNT(1) returns all rows including
-- null rows.
SELECT Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
FROM Faculty_Classes
    INNER JOIN Classes
    ON Faculty_Classes.ClassID = Classes.ClassID
    INNER JOIN Staff
    ON Staff.StaffID = Faculty_Classes.StaffID
    -- Match faculty classe subject to faculty subject expertise by class and
    -- staffid: this lets us compare the class's subject to rows in faculty
    -- subjects
    LEFT OUTER JOIN Faculty_Subjects
    ON Classes.SubjectID = Faculty_Subjects.SubjectID
        AND Faculty_Classes.StaffID = Faculty_Subjects.StaffID
GROUP BY Staff.StaffID,
    Staff.StfFirstName,
    Staff.StfLastName
HAVING COUNT(*) - COUNT(Faculty_Subjects.StaffID) > 0;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_staff_teaching_nonaccredited_classes';

 SELECT staff.staffid,
    staff.stffirstname,
    staff.stflastname,
    classes.classid,
    classes.classroomid,
    classes.startdate,
    classes.subjectid,
    subjects.subjectcode,
    subjects.subjectname
   FROM (((classes
     JOIN faculty_classes ON ((classes.classid = faculty_classes.classid)))
     JOIN subjects ON ((classes.subjectid = subjects.subjectid)))
     JOIN staff ON ((staff.staffid = faculty_classes.staffid)))
  WHERE (NOT (classes.subjectid IN ( SELECT faculty_subjects.subjectid
           FROM faculty_subjects
          WHERE (faculty_subjects.staffid = staff.staffid))));

-- 3. List the students who have passed all completed classes with a grade of 80
-- or better. 3
-- Use GROUP BY / HAVING
-- Idea: LEFT OUTER JOIN onto filtered table of students with grades of 80 or
-- less; then, if any null row exists for the filtered table, this means the
-- student did not have any completed classes with a grade of 80 or less
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName,
    StudSched80.StudentID
FROM Students
    LEFT OUTER JOIN
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
        AND Student_Schedules.Grade < 80) StudSched80
    ON Students.StudentID = StudSched80.StudentID
GROUP BY Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
HAVING COUNT(StudSched80.StudentID) = 0;

-- Simpler GROUP BY/HAVING solution
-- Idea: If the minimum grade of a student is greater than 80 for any completed
-- classes, then the student has grades of 80 or better for all completed
-- classes
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
FROM Students
    INNER JOIN Student_Schedules
    ON Students.StudentID = Student_Schedules.StudentID
    INNER JOIN Student_Class_Status
    ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
GROUP BY Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
HAVING MIN(Student_Schedules.Grade) >= 80;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_students_passed_all_grade_gte_80';

-- Idea for book answer: if the count of classes in a filtered table of 80 or
-- better grades in completed courses is the same as the count of classes of
-- completed classes, then the set of 80 grade or better completed courses is
-- equal to these of all their classes, satisfying the query
SELECT students.studentid,
    students.studfirstname,
    students.studlastname
FROM (students
    JOIN student_schedules
    ON ((students.studentid = student_schedules.studentid)))
WHERE ((student_schedules.grade > (80)::double precision)
    AND (student_schedules.classstatus = 2))
GROUP BY students.studentid,
    students.studfirstname,
    students.studlastname
HAVING (count(students.studentid) =
    ( SELECT count(*) AS count
      FROM student_schedules student_schedules_1
      WHERE ((student_schedules_1.classstatus = 2)
        AND (student_schedules_1.studentid = students.studentid))));

-- 4. Solve the following simple NOT problems.
-- Find classes with no enrolled students. 118
SELECT Classes.ClassID
FROM Classes
WHERE NOT EXISTS
    (SELECT *
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Enrolled'
        AND Classes.ClassID = Student_Schedules.ClassID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_classes_no_students_enrolled_not_in';

SELECT subjects.subjectname,
    classes.classroomid,
    classes.starttime,
    classes.duration
FROM (subjects
    JOIN classes
    ON ((subjects.subjectid = classes.subjectid)))
WHERE (NOT (classes.classid IN
        ( SELECT student_schedules.classid
          FROM (student_schedules
             JOIN student_class_status
             ON ((student_schedules.classstatus = student_class_status.classstatus)))
          WHERE ((student_class_status.classstatusdescription)::text = 'Enrolled'::text))));

-- Display staff members not teaching. 5
SELECT Staff.StaffID,
    Staff.StfLastName,
    Staff.StfLastName
FROM Staff
WHERE NOT EXISTS
    (SELECT *
    FROM Faculty_Classes
    WHERE Faculty_Classes.StaffID = Staff.StaffID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_staff_not_teaching_exists';

SELECT staff.stffirstname,
    staff.stflastname
FROM staff
WHERE (NOT (EXISTS ( SELECT faculty_classes.classid,
            faculty_classes.staffid
          FROM faculty_classes
          WHERE (faculty_classes.staffid = staff.staffid))));

-- Show which students have never withdrawn. 16
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
FROM Students
WHERE Students.StudentID NOT IN
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Withdrew');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_students_never_withdrawn_exists';

SELECT concat(students.studlastname,
              ', ',
              students.studfirstname) AS studfullname
FROM students
WHERE (NOT (EXISTS ( SELECT student_class_status.classstatus,
            student_class_status.classstatusdescription,
            student_schedules.studentid,
            student_schedules.classid,
            student_schedules.classstatus,
            student_schedules.grade
           FROM (student_class_status
             JOIN student_schedules
             ON ((student_class_status.classstatus = student_schedules.classstatus)))
          WHERE (((student_class_status.classstatusdescription)::text = 'Withdrew'::text)
            AND (student_schedules.studentid = students.studentid)))));

-- List the students not currently enrolled. 2
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName
FROM Students
WHERE NOT EXISTS
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Enrolled'
        AND Student_Schedules.StudentID = Students.StudentID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_students_not_currently_enrolled_not_in';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname
FROM students
WHERE (NOT (students.studentid IN
        ( SELECT student_schedules.studentid
          FROM (student_schedules
          JOIN student_class_status
          ON ((student_schedules.classstatus = student_class_status.classstatus)))
          WHERE ((student_class_status.classstatusdescription)::text = 'Enrolled'::text))));

-- Find subjects that have no faculty assigned. 1
SELECT Subjects.SubjectID,
    Subjects.SubjectCode,
    Subjects.SubjectName
FROM Subjects
    LEFT OUTER JOIN Faculty_Subjects
    ON Subjects.SubjectID = Faculty_Subjects.SubjectID
GROUP BY Subjects.SubjectID,
    Subjects.SubjectCode,
    Subjects.SubjectName
HAVING COUNT(Faculty_Subjects.StaffID) = 0;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch18_subjects_no_faculty_not_in';

SELECT subjects.subjectid,
    subjects.subjectcode,
    subjects.subjectname
FROM subjects
WHERE (NOT (subjects.subjectid IN
        ( SELECT faculty_subjects.subjectid
       FROM faculty_subjects)));

/* ***** Bowling League Database *********** */
-- 1. Display the bowlers who have never bowled a raw score greater than 150. 7
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
FROM Bowlers
WHERE NOT EXISTS
    (SELECT *
    FROM Bowler_Scores
    WHERE Bowler_Scores.RawScore > 150
        AND Bowler_Scores.BowlerID = Bowlers.BowlerID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch18_mediocre_bowlers';

SELECT bowlers.bowlerid,
    bowlers.bowlerfirstname,
    bowlers.bowlerlastname
FROM bowlers
WHERE (NOT (EXISTS
        ( SELECT bowler_scores.matchid,
            bowler_scores.gamenumber,
            bowler_scores.bowlerid,
            bowler_scores.rawscore,
            bowler_scores.handicapscore,
            bowler_scores.wongame
           FROM bowler_scores
           WHERE ((bowler_scores.rawscore > 150)
            AND (bowler_scores.bowlerid = bowlers.bowlerid)))));

-- 2. Show the bowlers who have a raw score greater than 170 at both Thunderbird
-- Lanes and Bolero Lanes. 11
-- Use EXISTS
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
FROM Bowlers
WHERE EXISTS
    (SELECT *
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Bowler_Scores.RawScore > 170
        AND Bowler_Scores.BowlerID = Bowlers.BowlerID
        AND Tournaments.TourneyLocation = 'Thunderbird Lanes')
    AND EXISTS
    (SELECT *
    FROM Bowler_Scores
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Bowler_Scores.RawScore > 170
        AND Bowler_Scores.BowlerID = Bowlers.BowlerID
        AND Tournaments.TourneyLocation = 'Bolero Lanes')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch18_good_bowlers_tbird_and_bolero_exists';

SELECT bowlers.bowlerid,
    bowlers.bowlerlastname,
    bowlers.bowlerfirstname
FROM bowlers
WHERE ((EXISTS
        ( SELECT tournaments.tourneyid,
            tournaments.tourneydate,
            tournaments.tourneylocation,
            tourney_matches.matchid,
            tourney_matches.tourneyid,
            tourney_matches.lanes,
            tourney_matches.oddlaneteamid,
            tourney_matches.evenlaneteamid,
            bowler_scores.matchid,
            bowler_scores.gamenumber,
            bowler_scores.bowlerid,
            bowler_scores.rawscore,
            bowler_scores.handicapscore,
            bowler_scores.wongame
           FROM ((tournaments
             JOIN tourney_matches
             ON ((tournaments.tourneyid = tourney_matches.tourneyid)))
             JOIN bowler_scores
             ON ((tourney_matches.matchid = bowler_scores.matchid)))
          WHERE ((bowler_scores.bowlerid = bowlers.bowlerid)
            AND (bowler_scores.rawscore >= 170)
            AND ((tournaments.tourneylocation)::text = 'Thunderbird Lanes'::text))))
    AND (EXISTS ( SELECT tournaments.tourneyid,
            tournaments.tourneydate,
            tournaments.tourneylocation,
            tourney_matches.matchid,
            tourney_matches.tourneyid,
            tourney_matches.lanes,
            tourney_matches.oddlaneteamid,
            tourney_matches.evenlaneteamid,
            bowler_scores.matchid,
            bowler_scores.gamenumber,
            bowler_scores.bowlerid,
            bowler_scores.rawscore,
            bowler_scores.handicapscore,
            bowler_scores.wongame
           FROM ((tournaments
             JOIN tourney_matches
             ON ((tournaments.tourneyid = tourney_matches.tourneyid)))
             JOIN bowler_scores
             ON ((tourney_matches.matchid = bowler_scores.matchid)))
          WHERE ((bowler_scores.bowlerid = bowlers.bowlerid)
            AND (bowler_scores.rawscore >= 170)
            AND ((tournaments.tourneylocation)::text = 'Bolero Lanes'::text)))));

-- 3. List the tournaments that have not yet been played. 6
-- Use NOT IN
SELECT Tournaments.TourneyID,
    Tournaments.TourneyDate,
    Tournaments.TourneyLocation
FROM Tournaments
WHERE Tournaments.TourneyID NOT IN
    (SELECT Tourney_Matches.TourneyID
    FROM Tourney_Matches);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch18_tourney_not_yet_played_not_in';

SELECT tournaments.tourneyid,
    tournaments.tourneydate,
    tournaments.tourneylocation
FROM tournaments
WHERE (NOT (tournaments.tourneyid IN
        ( SELECT tourney_matches.tourneyid
          FROM tourney_matches)));

/* ***** Recipes Database ****************** */
-- 1. Show me the recipes that have beef and garlic. 1
-- Use EXISTS
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE EXISTS
    (SELECT *
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef'
        AND Recipes.RecipeID = Recipe_Ingredients.RecipeID)
    AND EXISTS
    (SELECT *
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Garlic'
        AND Recipes.RecipeID = Recipe_Ingredients.RecipeID)

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_recipes_beef_and_garlic';

 SELECT recipes.recipetitle,
    recipes.preparation
FROM recipes
WHERE ((EXISTS ( SELECT recipe_ingredients.recipeid,
            recipe_ingredients.recipeseqno,
            recipe_ingredients.ingredientid,
            recipe_ingredients.measureamountid,
            recipe_ingredients.amount
           FROM (ingredients
             JOIN recipe_ingredients
             ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
          WHERE (((ingredients.ingredientname)::text = 'Beef'::text)
            AND (recipe_ingredients.recipeid = recipes.recipeid))))
    AND (EXISTS ( SELECT recipe_ingredients.recipeid,
            recipe_ingredients.recipeseqno,
            recipe_ingredients.ingredientid,
            recipe_ingredients.measureamountid,
            recipe_ingredients.amount
           FROM (ingredients
             JOIN recipe_ingredients
             ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
          WHERE (((ingredients.ingredientname)::text = 'Garlic'::text)
            AND (recipe_ingredients.recipeid = recipes.recipeid)))));

-- 2. List the recipes that have beef, onion, and carrot. 1
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef')
    AND Recipes.RecipeID IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Onion')
    AND Recipes.RecipeID IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Carrot')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_recipes_beef_onion_carrot';

SELECT recipes.recipeid,
    recipes.recipetitle
FROM recipes
WHERE ((recipes.recipeid IN
        ( SELECT recipe_ingredients.recipeid
           FROM (recipe_ingredients
             JOIN ingredients
             ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
          WHERE ((ingredients.ingredientname)::text = 'Beef'::text)))
    AND (recipes.recipeid IN
        ( SELECT recipe_ingredients.recipeid
          FROM (recipe_ingredients
             JOIN ingredients
             ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
          WHERE ((ingredients.ingredientname)::text = 'Onion'::text)))
    AND (recipes.recipeid IN
        ( SELECT recipe_ingredients.recipeid
          FROM (recipe_ingredients
             JOIN ingredients
             ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
          WHERE ((ingredients.ingredientname)::text = 'Carrot'::text))));

-- 3. Which recipes use no dairy products (cheese, butter, dairy)? 10
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
        INNER JOIN Ingredient_Classes
        ON Ingredients.IngredientClassID = Ingredient_Classes.IngredientClassID
    WHERE Ingredient_Classes.IngredientClassDescription IN
        ('Dairy', 'Cheese', 'Butter'));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_recipes_no_dairy_right';

SELECT recipes.recipeid,
    recipes.recipetitle
FROM recipes
WHERE ((NOT (recipes.recipeid IN
        ( SELECT recipe_ingredients.recipeid
          FROM ((recipe_ingredients
             JOIN ingredients
             ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
             JOIN ingredient_classes
             ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
          WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Butter'::text))))
        AND (NOT (recipes.recipeid IN
                ( SELECT recipe_ingredients.recipeid
           FROM ((recipe_ingredients
             JOIN ingredients
             ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
             JOIN ingredient_classes
             ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
          WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Cheese'::text))))
      AND (NOT (recipes.recipeid IN
            ( SELECT recipe_ingredients.recipeid
              FROM ((recipe_ingredients
                 JOIN ingredients
                 ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
                 JOIN ingredient_classes
                 ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
          WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Dairy'::text)))));

/* Book Answer -- Demonstrating Wrong Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_recipes_no_dairy_wrong';

-- This solution is wrong because it only gets recipes that have 0 of
-- butter, cheese, and dairy simultaneously. If a recipe contains 1, 2, or 3 of
-- the ingredients, then the recipe is included erroneously.
SELECT DISTINCT recipes.recipeid,
    recipes.recipetitle
FROM (((recipes
    JOIN recipe_ingredients
    ON ((recipes.recipeid = recipe_ingredients.recipeid)))
    JOIN ingredients
    ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
    JOIN ingredient_classes
    ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
WHERE ((ingredient_classes.ingredientclassdescription)::text <> ALL
    ((ARRAY['Butter'::character varying,
            'Cheese'::character varying,
            'Dairy'::character varying])::text[]));

-- 4. Solve both of hte following using NOT IN
-- Display ingredients not used in any recipe. 20
SELECT Ingredients.IngredientID,
    Ingredients.IngredientName
FROM Ingredients
WHERE Ingredients.IngredientID NOT IN
    (SELECT Recipe_Ingredients.IngredientID
    FROM Recipe_Ingredients);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_ingredients_no_recipe';

SELECT ingredients.ingredientname
   FROM ingredients
WHERE (NOT (ingredients.ingredientid IN
        ( SELECT recipe_ingredients.ingredientid
          FROM recipe_ingredients)));

-- Show recipe classes for which there is no recipe. 1
SELECT Recipe_Classes.*
FROM Recipe_Classes
WHERE RecipeClassID NOT IN
    (SELECT Recipes.RecipeClassID
    FROM Recipes);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch18_recipe_classes_no_recipes_not_in';

SELECT recipe_classes.recipeclassdescription
FROM recipe_classes
WHERE (NOT (recipe_classes.recipeclassid IN
        ( SELECT recipes.recipeclassid
          FROM recipes)));
