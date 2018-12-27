/* ********** SQL FOR MERE MORTALS CHAPTER 12 ********** */
/* ******** SIMPLE TOTALS                     ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Aggregate Functions                      ****/
/* ******************************************** ****/
-- The following statement is illegal, because there is no relation between the
-- COUNT output row and any particular LastName.
SELECT LastName, COUNT(*) As CountOfStudents
FROM Students;

-- However, string literals have the same value for all rows, so they are legal
SELECT 'The number of students is: ', COUNT(*) AS CountOfStudents
FROM Students;

/* *** Counting Rows and Values with COUNT **** ****/
-- Note: COUNT(*) will count all rows, even redundant and NULL rows
-- Ex. Show me the total number of employes we have in our company. 8
SELECT COUNT(*) /* count all the rows */
FROM Employees;

-- Count all employees living in Washington. 7
SELECT COUNT(*) AS TotalWashingtonEmployees
FROM Employees
WHERE EmpState = 'WA';

-- Use SUM to add numeric values together.
-- Ex. Calculate a total of all unique wholesale costs for the products we sell.
-- Note: SUM disregards any NULL row
-- Note: PostGRE ROUND only works on numeric functions, use val::numeric to cast
-- the value if need be
SELECT ROUND(SUM(DISTINCT WholesalePrice)::numeric,2) AS SumOfUniqueWholesaleCosts
FROM Product_Vendors;

-- Use AVG to calculate a mean value.
-- Ex. What is the average item total for order 64?
-- Note: AVG disregards any NULL row
SELECT AVG(QuotedPrice * QuantityOrdered) AS AverageItemTotal
FROM Order_Details
WHERE OrderNumber = 64;

-- Combine DISTINCT with AVG to average unique values.
-- Ex. Calculate an average of all unique product prices.
SELECT AVG(DISTINCT RetailPrice) AS UniqueProductPrices
FROM Products;

-- Use MAX to find the largest value.
-- Characters: Returns greatest string by collating sequence.
-- Numbers: Returns largest number.
-- Datetime: Returns latest date in chronological order.
-- Note: DISTINCT doesn't do anything for the MAX function.

-- Ex. What is the largest amount paid on a contract?
SELECT MAX(ContractPrice) AS LargestContractPrice
FROM Engagements;

-- Ex. What was the largest line item total for order 3314?
-- Note: Order number 3314 doesn't actually exist in the DB.
SELECT MAX(QuotedPrice * QuantityOrdered) AS LargestItemTotal
FROM Order_Details
WHERE OrderNumber = 3314;

-- Use MIN to find the smallest value, with similar logic to MAX.
-- Ex. What is the lowest price we charge for a product? 4.99
SELECT MIN(RetailPrice) AS LowestProductPrice
FROM Products;

-- Ex. What is the lowest line item total for order 3314?
-- Note: Order number 3314 doesn't actually exist in the DB.
SELECT MIN(QuotedPrice * QuantityOrdered) AS LowestItemTotal
FROM Order_Details
WHERE OrderNumber = 3314;

-- You can combine multiple aggregate functions in a single SELECT statement.
-- Ex. Show me the earliest and most recent review dates for the employees in
-- the advertising department.
-- Note. This query doesn't actually run, as the columns don't exist.
SELECT MIN(ReviewDate) AS EarliestReviewDate,
    MAX(ReviewDate) AS RecentReviewDate
FROM Employees
WHERE Department = 'Advertising';

-- Ex. how many different products were ordered on order number 553, and what ws
-- the total cost of that order?
SELECT COUNT(DISTINCT ProductNumber) AS TotalProductsPurchased,
    SUM(QuotedPrice * QuantityOrdered) AS OrderAmount
FROM Order_Details
WHERE OrderNumber = 553;

-- Note: You may not embed an aggregate function inside another, except when
-- used as a window function.
-- Note: You may not use a subquery as the argument of an aggregate function.

/* ******************************************** ****/
/* *** Using Aggregate Functions In Filters     ****/
/* ******************************************** ****/
-- You can place aggregate function within a subquery for use as a filter.
-- Goal: Do the same query as below, but dynamically.
-- Ex. List the products that have a retail price less than equal to the overall
-- average retail price.
SELECT ProductName
FROM Products
WHERE RetailPrice <= 196.03;

-- Ex. Same query, but with subquery in place of average value. 36
-- Note: The subquery is always evaluated first, so it will be correct always.
SELECT Products.ProductName
FROM Products
WHERE RetailPrice <= (SELECT AVG(Products_1.RetailPrice)
                      FROM Products Products_1);

-- Ex. List the engagement number and contract price of all engagements that
-- have a contract price larger than the total amount of all contract prices for
-- the entire month of September 2017.
-- Note: query returns nothing because no such contract exists.
SELECT EngagementNumber, ContractPrice
FROM Engagements
WHERE ContractPrice >
    -- Total amount of all contracts in September 2017
    (SELECT SUM(ContractPrice)
    FROM Engagements
    WHERE StartDate BETWEEN '2017-09-01' AND '2017-09-30');


/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- Ex. How many customers do we have in the state of California?
SELECT COUNT(*) AS NumberOfCACustomers
FROM Customers
WHERE CustState = 'CA';

-- Ex. List the product names and numbers that have a quoted price greater than
-- or equal to the overall average retail price in the products table.
SELECT DISTINCT Products.ProductNumber, Products.ProductName
FROM Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Order_Details.QuotedPrice >
    (SELECT AVG(Products_1.RetailPrice)
    FROM Products Products_1);

/* ***** Entertainment Agency Database ***** */
-- Ex. List the engagement number and contract price of contracts that occur on
-- the earliest date.
SELECT EngagementNumber, ContractPrice
FROM Engagements
WHERE StartDate = (SELECT MIN(StartDate) FROM Engagements);

-- Ex. What was the total value of all engagements booked in October 2017?
SELECT SUM(ContractPrice) AS TotalBookedValue
FROM Engagements
WHERE StartDate BETWEEN '2017-10-01' AND '2017-10-31';

/* ***** School Scheduling Database ******** */
-- Ex. What is the largest salary we pay to any staff member?
SELECT MAX(Salary) AS LargestStaffSalary
FROM Staff;

-- Ex. What is the total salary amount paid to our staff in California?
SELECT SUM(Salary) AS TotalCASalary
FROM Staff
WHERE StfState = 'CA';

/* ***** Bowling League Database *********** */
-- Ex. How many tournaments have been played at Red Rooster Lanes?
SELECT COUNT(*) RedRoosterGames
FROM Tournaments
WHERE TourneyLocation = 'Red Rooster Lanes';

-- Ex. List the last name and first name in alphabetical order, of every bowler
-- whose personal average score is greater than or equal to the overall average
-- score.
SELECT DISTINCT BowlerLastName, BowlerFirstName
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
WHERE
    (SELECT AVG(RawScore)
    FROM Bowler_Scores
    WHERE Bowler_Scores.BowlerID = Bowlers.BowlerID) >
        (SELECT AVG(BS2.RawScore)
        FROM Bowler_Scores BS2)
ORDER BY BowlerLastName, BowlerFirstName;

/* ***** Recipes Database ****************** */
-- Ex. How many recipes contain a beef ingredient?
SELECT COUNT(*) NumRecipesWithBeef
FROM Recipes
WHERE Recipes.RecipeID IN
    (SELECT RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef');

-- Ex. How many ingredients are measured by the cup?
SELECT COUNT(*) NumberOfCupIngredients
FROM Ingredients
WHERE MeasureAmountID =
    (SELECT MeasureAmountID
    FROM Measurements
    WHERE MeasurementDescription = 'Cup');

/* Book Answer */
SELECT COUNT(*) AS NumberOfIngredients
FROM Ingredients
    INNER JOIN Measurements
    ON Ingredients.MeasureAmountID = Measurements.MeasureAmountID
WHERE MeasurementDescription = 'Cup';

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- 1. What is the average retail price of a mountain bike? $1321.25
SELECT ROUND(AVG(RetailPrice)::numeric,2) AS AvgPrice
FROM Products
WHERE ProductName LIKE '%Mountain Bike%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch12_average_price_of_a_mountain_bike';

-- ~~ means LIKE, ~~* means ILIKE
SELECT avg(products.retailprice) AS averagecost
FROM products
WHERE ((products.productname)::text ~~ '%Mountain Bike%'::text);

-- 2. What was the date of our most recent order? 2018-03-01
SELECT MAX(OrderDate) AS RecentOrderDate
FROM Orders;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch12_most_recent_order_date';

SELECT max(orders.orderdate) AS mostrecentorderdate
FROM orders;

-- 3. What was the total amount for order number 8? $1492.60
SELECT SUM(QuotedPrice * QuantityOrdered)
FROM Order_Details
WHERE OrderNumber = 8;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch12_total_amount_for_order_number_8';

SELECT sum(((order_details.quantityordered)::numeric *
        order_details.quotedprice)) AS totalorderamount
FROM order_details
WHERE (order_details.ordernumber = 8);

/* ***** Entertainment Agency Database ***** */
-- 1. What is the average salary of a booking agent? $24850.00
SELECT ROUND(AVG(Salary)::numeric,2)
FROM Agents;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch12_average_agent_salary';

SELECT avg(agents.salary) AS averageagentsalary
FROM agents;

-- 2. Show me the engagement numbers for all engagements that have a contract
-- price greater than or equal to the overall average contract price. 43
SELECT EngagementNumber
FROM Engagements
WHERE ContractPrice >=
    (SELECT AVG(ContractPrice)
    FROM Engagements);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch12_contract_price_ge_average_contract_price';

SELECT engagements.engagementnumber
FROM engagements
WHERE (engagements.contractprice >=
    ( SELECT avg(engagements_1.contractprice) AS avg
        FROM engagements engagements_1));

-- 3. How many of our entertainers are based in Bellevue? 3
SELECT COUNT(*) NumEntertainers
FROM Entertainers
WHERE EntCity = 'Bellevue';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch12_number_of_bellevue_entertainers';

SELECT count(*) AS numberofentertainers
FROM entertainers
WHERE ((entertainers.entcity)::text = 'Bellevue'::text);

-- 4. Which engagements occur earliest in October 2017? 3
SELECT EngagementNumber, StartDate, EndDate, CustomerID
FROM Engagements
WHERE StartDate =
    (SELECT MIN(StartDate)
    FROM Engagements
    WHERE StartDate BETWEEN '2017-10-01' AND '2017-10-31');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch12_earliest_october_engagements';

SELECT engagements.engagementnumber,
    engagements.startdate,
    engagements.enddate,
    engagements.customerid
FROM engagements
WHERE (engagements.startdate =
    ( SELECT min(engagements_1.startdate) AS min
        FROM engagements engagements_1
        WHERE ((engagements_1.startdate >= '2017-10-01'::date)
            AND (engagements_1.startdate <= '2017-10-31'::date))));

/* ***** School Scheduling Database ******** */
-- 1. What is the current average class duration? 78.939
SELECT ROUND(AVG(Duration)::numeric,3)
FROM Classes;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch12_average_class_duration';

SELECT avg(classes.duration) AS averageclassduration
FROM classes;

-- 2. List the last name and first name of each staff member who has been with
-- us since the earliest hire date. Alborous, Sam
-- (Hint: You'll have to use a subquery containing an aggregate function that
-- evalutes the Date-Hired column.
SELECT StfLastName, StfFirstName
FROM Staff
WHERE DateHired =
    (SELECT MIN(DateHired)
    FROM Staff);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch12_most_senior_staff_members';

SELECT concat(staff.stflastname, ', ', staff.stffirstname) AS staffmember
FROM staff
WHERE (staff.datehired = ( SELECT min(staff_1.datehired) AS min
        FROM staff staff_1));

-- 3. How many classes are held in room 3346? 10
SELECT COUNT(*) NumClasses
FROM Classes
WHERE ClassRoomID = 3346;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch12_number_of_classes_held_in_room_3346';

SELECT count(*) AS totalnumberofclasses
FROM classes
WHERE (classes.classroomid = 3346);

/* ***** Bowling League Database *********** */
-- 1. What is the largest handicap held by any bowler at the current time? 52
-- Note: We want to calculate 90% of the difference of each bowler's score from
-- 200, and round the final result to an integer.
SELECT ROUND(MAX(0.9*((SELECT (200 - AVG(RawScore)) FROM Bowler_Scores
                WHERE Bowler_Scores.BowlerID = Bowlers.BowlerID))), 0)
FROM Bowlers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch12_current_highest_handicap';

SELECT max(round((((200)::numeric - round(( SELECT avg(bowler_scores.rawscore) AS avg
FROM bowler_scores
WHERE (bowler_scores.bowlerid = bowlers.bowlerid)), 0)) * 0.9), 0)) AS highhandicap
FROM bowlers;

-- 2. Which locations hosted tournaments on the earliest tournament date? Red
SELECT TourneyLocation
FROM Tournaments
WHERE TourneyDate = (SELECT MIN(TourneyDate) FROM Tournaments);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch12_tourney_locations_for_earliest_date';

SELECT tournaments.tourneylocation
FROM tournaments
WHERE (tournaments.tourneydate = ( SELECT min(tournaments_1.tourneydate) AS min
        FROM tournaments tournaments_1));

-- 3. What is the last tournament date we have on our schedule? 2018-08-16
SELECT MAX(TourneyDate)
FROM Tournaments;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch12_last_tourney_date';

SELECT max(tournaments.tourneydate) AS mostrecentdate
FROM tournaments;

/* ***** Recipes Database ****************** */
-- 1. Which recipe requires the most cloves of garlic? Roast beef
-- Hint: You'll need to use INNER JOINs and a subquery to answer this request.
-- Note that the measurement is "cloves" for all recipes, so you don't have to
-- filter for that.
SELECT DISTINCT RecipeTitle, Amount
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
WHERE IngredientName = 'Garlic'
    AND Amount =
    (SELECT MAX(Amount)
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE IngredientName = 'Garlic')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch12_recipe_with_most_cloves_of_garlic';

SELECT DISTINCT recipes.recipetitle
FROM ((recipes
    JOIN recipe_ingredients
        ON ((recipes.recipeid = recipe_ingredients.recipeid)))
    JOIN ingredients
        ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
WHERE (((ingredients.ingredientname)::text = 'Garlic'::text)
    AND (recipe_ingredients.amount =
        ( SELECT max(recipe_ingredients_1.amount) AS max
            FROM (recipe_ingredients recipe_ingredients_1
                JOIN ingredients ingredients_1
                ON ((recipe_ingredients_1.ingredientid = ingredients_1.ingredientid)))
                WHERE ((ingredients_1.ingredientname)::text = 'Garlic'::text))));

-- 2. Count the number of main course recipes. 7
-- Hint: To search on "Main course" recipes requires a JOIN between
-- Recipe_Classes and Recipes, but you can also cheat and just look for
-- RecipeClassID = 1.
-- Cheat method
SELECT COUNT(*) AS NumRecipes
FROM Recipes
WHERE RecipeClassID = 1;

-- Non cheat method
SELECT COUNT(*) AS NumRecipes
FROM Recipes
    INNER JOIN Recipe_Classes
    ON Recipes.RecipeClassID = Recipe_Classes.RecipeClassID
WHERE RecipeClassDescription = 'Main course';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch12_number_of_main_course_recipes';

SELECT DISTINCT count(*) AS numberofrecipes
FROM (recipes
    JOIN recipe_classes
    ON ((recipes.recipeclassid = recipe_classes.recipeclassid)))
WHERE ((recipe_classes.recipeclassdescription)::text = 'Main course'::text);

-- 3. Calculate the total number of teaspoons of salt in all recipes. 8.75
-- Hint: Salt happens to be measured in teaspoons in all recipes, so you don't
-- have to filter for that.
SELECT SUM(Amount) AS TeaspoonsSalt
FROM Recipe_Ingredients
WHERE IngredientID =
    (SELECT IngredientID
    FROM Ingredients
    WHERE IngredientName = 'Salt');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch12_total_salt_used';

SELECT sum(recipe_ingredients.amount) AS totalteaspoons
FROM (recipe_ingredients
    JOIN ingredients
    ON ((recipe_ingredients.ingredientid = ingredients.ingredientid)))
WHERE ((ingredients.ingredientname)::text = 'Salt'::text);
