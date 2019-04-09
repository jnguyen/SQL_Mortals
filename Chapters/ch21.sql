/* ********** SQL FOR MERE MORTALS CHAPTER 21 ********** */
/* ******** Performing Complex Calculations On Groups ** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Grouping in Sub-Group                    ****/
/* ******************************************** ****/
-- Ex. Summarize students by state, gender, and marital status
SELECT Students.StudState,
    Students.StudGender,
    Students.StudMaritalStatus,
    COUNT(*) AS Number
FROM Students
GROUP BY Students.StudState,
    Students.StudGender,
    Students.StudMaritalStatus;

-- Ex. The above query, but with marginal counts
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch21_students_state_gender_maritalstatus_count_cube_no_nulls';

SELECT
       CASE
           WHEN (GROUPING(students.studstate) = 0) THEN students.studstate
           ELSE 'AnyState'::character varying
       END AS state,
       CASE
           WHEN (GROUPING(students.studgender) = 0) THEN students.studgender
           ELSE 'Any Gender'::character varying
       END AS gender,
       CASE
           WHEN (GROUPING(students.studmaritalstatus) = 0) THEN students.studmaritalstatus
           ELSE 'Any Status'::character varying
       END AS maritalstatus,
   count(*) AS number
  FROM students
 GROUP BY CUBE(students.studstate, students.studgender, students.studmaritalstatus)
 ORDER BY
       CASE
           WHEN (GROUPING(students.studstate) = 0) THEN students.studstate
           ELSE 'AnyState'::character varying
       END,
       CASE
           WHEN (GROUPING(students.studgender) = 0) THEN students.studgender
           ELSE 'Any Gender'::character varying
       END,
       CASE
           WHEN (GROUPING(students.studmaritalstatus) = 0) THEN students.studmaritalstatus
           ELSE 'Any Status'::character varying
       END;

/* ******************************************** ****/
/* *** Getting Totals in a Hierarchy Using ROLLUP **/
/* ******************************************** ****/
-- Ex. Show me the count for all unique combinations of student state, student
-- gender, and student marital status. summarized for each combination of state
-- and gender and the total by state.
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY ROLLUP (StudState, StudGender, StudMaritalStatus);

-- Ex. Show me the count for all unique combinations of student state, student
-- gender, and student marital status, summarized for each combination of state
-- and gender and the total by state. Show ‘Any State,’ ‘Any Gender,’ or ‘Any
-- Status’ for the subtotaled rows.
SELECT
    (CASE WHEN GROUPING(StudState) = 0
        THEN StudState
    ELSE 'Any State' END) AS State,
    (CASE WHEN GROUPING(StudGender) = 0
        THEN StudGender
    ELSE 'Any Gender' END) AS Gender,
    (CASE WHEN GROUPING(StudMaritalStatus) = 0
        THEN StudMaritalStatus
    ELSE 'Any Status' END) AS MaritalStatus,
    COUNT(*) AS Number 
FROM Students
GROUP BY ROLLUP (StudState, StudGender, StudMaritalStatus);

-- Ex. Show me the count for all unique combinations of student marital status,
-- student gender, and student state, summarized for each combination of marital
-- status with gender and a total by marital status.
SELECT StudMaritalStatus, StudGender, StudState, COUNT(*) AS Number
FROM Students
GROUP BY ROLLUP (StudMaritalStatus, StudGender, StudState);

/* ******************************************** ****/
/* *** Getting Totals on Combinations Using CUBE ***/
/* ******************************************** ****/
/* *** Creating Totals on Combinations Using CUBE *** */
-- Ex. Show me the count for all combinations of student state, student gender,
-- and student marital status, with summarized sets for each combination of
-- state, gender, and marital status, for each combination of state and gender,
-- state and marital status, gender and marital status, and for each state,
-- gender, and marital status on its own.
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY CUBE(StudState, StudGender, StudMaritalStatus);


-- Note: Since CUBE produces all subsets, changing the order of the columns will
-- not change the results at all.
-- Ex. Show me the count for all combinations of student marital status,
-- student gender, and student state, with summarized sets for each combination
-- of marital status, gender, and state, for each combination of state and
-- gender, state and marital status, gender and marital status, and for each
-- state, gender, and marital status on its own.
SELECT StudMaritalStatus, StudGender, StudState, COUNT(*) AS Number
FROM Students
GROUP BY CUBE(StudMaritalStatus, StudGender, StudState);


/* ******************************************** ****/
/* * Creating a Union of Totals with GROUPING SETS */
/* ******************************************** ****/
-- Ex. Show me the count for all combinations of student state, student gender,
-- and student marital status, with subtotals for each of student state, student
-- gender, and student marital status.
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY GROUPING SETS
(StudState, StudGender, StudMaritalStatus);

-- Ex. The above query is equivalent to the following:
SELECT NULL AS StudState, NULL AS StudGender,
    StudMaritalStatus, Count(*) AS Number
FROM Students
GROUP BY StudMaritalStatus
UNION
SELECT NULL, StudGender, NULL, Count(*)
FROM Students
GROUP BY StudGender
UNION
SELECT StudState, NULL, NULL, Count(*)
FROM Students
GROUP BY StudState;

-- Ex. Show me the count for all combinations of student state, student gender,
-- and student marital status, with subtotals for student state, for the
-- combination of student state and student gender and for the combination of
-- student state and student marital status, but no grand total by student
-- state, student gender, and student marital status.
SELECT StudState, StudGender, StudMaritalStatus,
    COUNT(*) AS Number
FROM Students
GROUP BY GROUPING SETS
(StudState,
(StudState,StudGender),
(StudState,StudMaritalStatus));


/* ******************************************** ****/
/* *** Variations on Grouping Techniques        ****/
/* ******************************************** ****/
-- Ex. Show me the count for all combinations of student state, student gender,
-- and student marital status. Summarize by student state and by the combination
-- of student state and student marital status.
SELECT StudState, StudGender, StudMaritalStatus,
    COUNT(*) AS Number
FROM Students
GROUP BY GROUPING SETS (StudState,
(StudGender,StudMaritalStatus));


-- Ex. Show me the count for all combinations of student state, student gender,
-- and student marital status, with subtotals for each state and for each
-- combination of gender and marital status.
SELECT StudState, StudGender, StudMaritalStatus,
    COUNT(*) AS Number
FROM Students
GROUP BY StudState,
    ROLLUP (StudMaritalStatus, StudGender);

-- Ex. Same query as above except using CUBE
SELECT StudState, StudGender, StudMaritalStatus,
    COUNT(*) AS Number
FROM Students
GROUP BY StudState,
    CUBE (StudMaritalStatus, StudGender)
ORDER BY StudState, StudGender, StudMaritalStatus;


/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ************ EXAMPLES USING ROLLUP ************ */
/* ***** Sales Orders Database ************* */
-- Ex. For each category of product, show me, by state, the count of orders and
-- how much revenue the customers have generated. Give me a subtotal for each
-- category plus a grand total. 31
SELECT Categories.CategoryDescription,
    Customers.CustState,
    COUNT(DISTINCT Orders.OrderNumber) AS NumOrders,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) AS Revenue
FROM Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
    INNER JOIN Orders
    ON Orders.OrderNumber = Order_Details.OrderNumber
    INNER JOIN Customers
    ON Orders.CustomerID = Customers.CustomerID
GROUP BY ROLLUP (CategoryDescription, CustState);


/* ***** School Scheduling Database ******** */
-- Ex. Show me how many sessions are scheduled for each classroom over the next
-- two semesters. Give me subtotals by building, by classroom, by semester, and
-- by subject, plus a grand total. 212
SELECT BuildingCode, ClassRoomID, SemesterNo, SubjectCode,
    COUNT(*) AS NumberOfSessions
FROM ch20_class_schedule_calendar
GROUP BY ROLLUP(BuildingCode, ClassRoomID, SemesterNo, SubjectCode);

/* ************ EXAMPLES USING CUBE ************** */

/* ***** Bowling League Database *********** */
-- Ex. I want to know the average handicap score for each bowler by team and
-- city. Give me subtotals for each combination of team and city, for each team,
-- for each city, plus a grand total. 44
SELECT Teams.TeamName,
    Bowlers.BowlerCity,
    ROUND(AVG(Bowler_Scores.HandicapScore),0) AS AvgHandicap
FROM Bowlers
    INNER JOIN Teams
    ON Bowlers.TeamID = Teams.TeamID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY CUBE(Teams.TeamName, Bowlers.BowlerCity);

/* ***** Sales Orders Database ************* */
-- Ex. For each category of product, show me, by state, how much quantity the
-- vendors have on hand. Give me subtotals for each category, for each state,
-- plus a grand total. 39
SELECT Categories.CategoryDescription,
    Vendors.VendState,
    SUM(Products.QuantityOnHand) AS QuantityOnHand
FROM Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Product_Vendors
    ON Products.ProductNumber = Product_Vendors.ProductNumber
    INNER JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY CUBE(Categories.CategoryDescription, Vendors.VendState);

/* ************ EXAMPLES USING GROUPING SETS ***** */
/* ***** Bowling League Database *********** */
-- Ex. Show me how many games each bowler has participated in, summarized by
-- both team and city. 18
SELECT Teams.TeamName,
    Bowlers.BowlerCity,
    COUNT(*) AS GamesBowled
FROM Bowlers
    INNER JOIN Teams
    ON Bowlers.TeamID = Teams.TeamID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY GROUPING SETS(Teams.TeamName, Bowlers.BowlerCity);

/* ***** Entertainment Agency Database ***** */
-- Ex. Show me counts of our customers summarized by both style and zip code. 27
SELECT Customers.CustZipCode,
    Musical_Styles.StyleName,
    COUNT(*) AS NumCustomers
FROM entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
    ON Customers.CustomerID = Musical_Preferences.CustomerID
    INNER JOIN Musical_Styles
    ON Musical_Preferences.StyleID = Musical_Styles.StyleID
GROUP BY GROUPING SETS(Customers.CustZipCode, Musical_Styles.StyleName);

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/

/* ***** Bowling League Database *********** */
-- 1. “Show me how many bowlers live in each city. Give me totals for each
-- combination of Team and City, for each Team, for each City plus a grand
-- total.”
-- You can find my solution in CH21_Team_City_Count_CUBE (44 rows).
SELECT Bowlers.BowlerCity,
    Teams.TeamName,
    COUNT(*) AS NumBowlers
FROM Bowlers
    INNER JOIN Teams
    ON Bowlers.TeamID = Teams.TeamID
GROUP BY CUBE(Bowlers.BowlerCity, Teams.TeamName)
ORDER BY Teams.TeamName, Bowlers.BowlerCity;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch21_team_city_count_cube';

SELECT t.teamname,
   b.bowlercity,
   count(*) AS bowlers
FROM (bowlers b
    JOIN teams t ON ((t.teamid = b.teamid)))
GROUP BY CUBE(t.teamname, b.bowlercity)
ORDER BY t.teamname, b.bowlercity;

-- 2. “Show me the average raw score for each bowler. Give me totals by Team and
-- by City.”
-- You can find my solution in CH21_Team_City_AverageRawScore_GROUPING_SETS (18
-- rows).
SELECT Teams.TeamName,
    Bowlers.BowlerCity,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    ROUND(AVG(Bowler_Scores.RawScore),0) AS AvgScore
FROM Bowlers
    INNER JOIN Teams
    ON Bowlers.TeamID = Teams.TeamID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY GROUPING SETS
(Teams.TeamName,
Bowlers.BowlerCity,
(Bowlers.BowlerFirstName, Bowlers.BowlerLastName));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch21_team_city_averagerawscore_grouping_sets';

SELECT t.teamname,
    b.bowlercity,
    avg(bs.rawscore) AS avg
FROM ((teams t
    JOIN bowlers b
    ON ((b.teamid = t.teamid)))
    JOIN bowler_scores bs
    ON ((bs.bowlerid = b.bowlerid)))
GROUP BY GROUPING SETS ((t.teamname), (b.bowlercity));

-- 3. “Show me the average handicap score for each bowler. For each team, give
-- me average for each city in which the bowlers live. Also give me the average
-- for each team, and the overall average for the entire league.”
-- You can find my solution in CH21_Team_City_AverageHandicapScore_ROLLUP (34
-- rows).
SELECT Teams.TeamName,
    Bowlers.BowlerCity,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    ROUND(AVG(Bowler_Scores.HandiCapScore),0) AS AvgHandiCap
FROM Bowlers
    INNER JOIN Teams
    ON Bowlers.TeamID = Teams.TeamID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY ROLLUP
(Teams.TeamName, Bowlers.BowlerCity,
    (Bowlers.BowlerFirstName, Bowlers.BowlerLastName));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch21_team_city_averagehandicapscore_rollup';

SELECT t.teamname,
    b.bowlercity,
    avg(bs.handicapscore) AS avghandicap
FROM ((teams t
     JOIN bowlers b ON ((b.teamid = t.teamid)))
     JOIN bowler_scores bs ON ((bs.bowlerid = b.bowlerid)))
GROUP BY ROLLUP(t.teamname, b.bowlercity);

/* ***** Entertainment Agency Database ***** */
-- 1. “For each city where our entertainers live, show me how many different
-- musical styles are represented. Give me totals for each combination of City
-- and Style, for each City plus a grand total.”
-- You can find my solution in CH21_EntertainerCity_Style_ROLLUP (36 rows).
SELECT Entertainers.EntCity,
    Musical_Styles.StyleName,
    COUNT(Entertainer_Styles.StyleID) AS NumStyles
FROM Entertainers
    INNER JOIN Entertainer_Styles
    ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
    INNER JOIN Musical_Styles
    ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
GROUP BY ROLLUP(Entertainers.EntCity, Musical_Styles.StyleName);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch21_entertainercity_style_rollup';

SELECT entertainers.entcity,
    musical_styles.stylename,
    count(*) AS count
FROM ((entertainers
    JOIN entertainer_styles
    ON ((entertainer_styles.entertainerid = entertainers.entertainerid)))
    JOIN musical_styles
    ON ((musical_styles.styleid = entertainer_styles.styleid)))
GROUP BY ROLLUP(entertainers.entcity, musical_styles.stylename);

-- 2. “For each city where our customers live, show me how many different
-- musical styles they’re interested in. Give me total counts by city, total
-- counts by style and total counts for each combination of city and style.”
-- You can find my solution in CH21_CustomerCity_Style_GROUPING_SETS (60 rows).
SELECT Customers.CustCity,
    Musical_Styles.StyleName,
    COUNT(Musical_Preferences.CustomerID) AS NumStyles
FROM entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
    ON Customers.CustomerID = Musical_Preferences.CustomerID
    INNER JOIN Musical_Styles
    ON Musical_Preferences.StyleID = Musical_Styles.StyleID
GROUP BY GROUPING SETS
(CustCity, StyleName, (CustCity, StyleName));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch21_customercity_style_grouping_sets';

SELECT customers.custcity,
    musical_styles.stylename,
    count(*) AS count
FROM ((customers
    JOIN musical_preferences
    ON ((musical_preferences.customerid = customers.customerid)))
    JOIN musical_styles
    ON ((musical_styles.styleid = musical_preferences.styleid)))
GROUP BY GROUPING SETS
((customers.custcity), (musical_styles.stylename),
    (customers.custcity, musical_styles.stylename));

-- 3. “Give me an analysis of all the bookings we’ve had. I want to see the
-- number of bookings and the total charge broken down by the city the agent
-- lives in, the city the customer lives in, and the combination of the two.”
-- You can find my solution in
-- CH21_AgentCity_CustomerCity_Count_Charge_GROUPING_SETS (34 rows).
SELECT Agents.AgtCity,
    Customers.CustCity,
    COUNT(*) AS NumBookings,
    SUM(Engagements.ContractPrice) AS TotalCharge
FROM Agents
    INNER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
    INNER JOIN entertainmentagencyexample.Customers
    ON Engagements.CustomerID = Customers.CustomerID
GROUP BY GROUPING SETS
(Agents.AgtCity, Customers.CustCity, (Agents.AgtCity, Customers.CustCity));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch21_agentcity_customercity_count_charge_grouping_sets';

SELECT a.agtcity,
    c.custcity,
    count(*) AS numengagements,
    sum(e.contractprice) AS charge
FROM ((engagements e
    JOIN customers c
    ON ((c.customerid = e.customerid)))
    JOIN agents a
    ON ((a.agentid = e.agentid)))
GROUP BY GROUPING SETS ((a.agtcity), (c.custcity), (a.agtcity, c.custcity));

/* ***** Recipes Database ****************** */
-- 1. “I want to know how many recipes there are in each of the recipe classes
-- in my cookbook, plus an overall total of all the recipes regardless of recipe
-- class. Make sure to include any recipe classes that don’t have any recipes in
-- them.”
-- You can find my solution in CH21_RecipeClass_Recipe_Counts_ROLLUP (8 rows).
SELECT Recipe_Classes.RecipeClassDescription,
    COUNT(Recipes.RecipeID) AS NumRecipes
FROM Recipe_Classes
    LEFT OUTER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
GROUP BY ROLLUP (Recipe_Classes.RecipeClassDescription);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch21_recipeclass_recipe_counts_rollup';

-- Note: GROUPING() returns the grouping level in order from the left, when used
-- with ROLLUP. So, GROUPING(...) = 0 means everything, and GROUPING(...) = 1
-- means the first level, i.e. recipeclassdescription
SELECT
        CASE
            WHEN (GROUPING(recipe_classes.recipeclassdescription) = 0) THEN recipe_classes.recipeclassdescription
            ELSE 'Total Recipes All Classes'::character varying
        END AS recipeclass,
    count(recipes.recipeid) AS totalrecipes
   FROM (recipe_classes
     LEFT JOIN recipes ON ((recipes.recipeclassid = recipe_classes.recipeclassid)))
  GROUP BY ROLLUP(recipe_classes.recipeclassdescription);

-- 2. “I want to know the relationship between RecipeClasses and
-- IngredientClasses. For each recipe class, show me how many different
-- ingredient classes are represented, and for each ingredient class, show me
-- how many different recipe classes are represented.”
-- You can find my solution in CH21_RecipeClass_IngredClass_Counts_GROUPING_SETS
-- (25 rows).
SELECT Recipe_Classes.RecipeClassDescription,
    Ingredient_Classes.IngredientClassDescription,
    COUNT(Recipes.RecipeID) AS NumClasses
FROM Recipe_Classes
    INNER JOIN Recipes
    ON Recipes.RecipeClassID = Recipe_Classes.RecipeClassID
    INNER JOIN Recipe_Ingredients
    ON Recipe_Ingredients.RecipeID = Recipes.RecipeID
    INNER JOIN Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    INNER JOIN Ingredient_Classes
    ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID
GROUP BY GROUPING SETS (Recipe_Classes.RecipeClassDescription,
    Ingredient_Classes.IngredientClassDescription);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch21_recipeclass_ingredientclass_counts';

SELECT
        CASE
            WHEN (GROUPING(recipe_classes.recipeclassdescription) = 0) THEN recipe_classes.recipeclassdescription
            ELSE 'Total Recipes All Classes'::character varying
        END AS recipeclass,
        CASE
            WHEN (GROUPING(ingredient_classes.ingredientclassdescription) = 0) THEN ingredient_classes.ingredientclassdescription
            ELSE 'All Ingredient Classes'::character varying
        END AS ingredientclass,
    count(recipes.recipeid) AS totalrecipes
   FROM ((((recipe_classes
     JOIN recipes ON ((recipes.recipeclassid = recipe_classes.recipeclassid)))
     JOIN recipe_ingredients ON ((recipe_ingredients.recipeid = recipes.recipeid)))
     JOIN ingredients ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
     JOIN ingredient_classes ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
  GROUP BY GROUPING SETS ((recipe_classes.recipeclassdescription), (ingredient_classes.ingredientclassdescription));

-- 3. “I want to know even more about the relationship between RecipeClasses and
-- IngredientClasses. Show me how many recipes there are in each combination of
-- recipe class and ingredient class. Also show me how many recipes there are in
-- each ingredient class regardless of the recipe class, how many recipes there
-- are in each recipe class regardless of the ingredient class, and how many
-- recipes there are in total.”
-- You can find my solution in ch21_recipeclass_ingredientclass_cube (61 rows).
SELECT Recipe_Classes.RecipeClassDescription,
    Ingredient_Classes.IngredientClassDescription,
    COUNT(Recipes.RecipeID) AS NumClasses
FROM Recipe_Classes
    INNER JOIN Recipes
    ON Recipes.RecipeClassID = Recipe_Classes.RecipeClassID
    INNER JOIN Recipe_Ingredients
    ON Recipe_Ingredients.RecipeID = Recipes.RecipeID
    INNER JOIN Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    INNER JOIN Ingredient_Classes
    ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID
GROUP BY CUBE (Recipe_Classes.RecipeClassDescription,
    Ingredient_Classes.IngredientClassDescription);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch21_recipeclass_ingredientclass_cube';

 SELECT
        CASE
            WHEN (GROUPING(recipe_classes.recipeclassdescription) = 0) THEN recipe_classes.recipeclassdescription
            ELSE 'Total Recipes All Classes'::character varying
        END AS recipeclass,
        CASE
            WHEN (GROUPING(ingredient_classes.ingredientclassdescription) = 0) THEN ingredient_classes.ingredientclassdescription
            ELSE 'All Ingredient Classes'::character varying
        END AS ingredientclass,
    count(recipes.recipeid) AS totalrecipes
   FROM ((((recipe_classes
     JOIN recipes ON ((recipes.recipeclassid = recipe_classes.recipeclassid)))
     JOIN recipe_ingredients ON ((recipe_ingredients.recipeid = recipes.recipeid)))
     JOIN ingredients ON ((ingredients.ingredientid = recipe_ingredients.ingredientid)))
     JOIN ingredient_classes ON ((ingredient_classes.ingredientclassid = ingredients.ingredientclassid)))
  GROUP BY CUBE(recipe_classes.recipeclassdescription, ingredient_classes.ingredientclassdescription);

/* ***** Sales Orders Database ************* */
-- 1. “For each category of product, show me, by state, how much revenue the
-- customers have generated. Give me subtotals for each state, for each
-- category, plus a grand total.”
-- You can find my solution in CH21_ProductCategory_CustomerState_Revenue_CUBE
-- (35 rows).
SELECT Categories.CategoryDescription,
    Customers.CustState,
    ROUND(SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered),2)
        AS Revenue
FROM Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
    INNER JOIN Orders
    ON Order_Details.OrderNumber = Orders.OrderNumber
    INNER JOIN Customers
    ON Orders.CustomerID = Customers.CustomerID
GROUP BY CUBE (Categories.CategoryDescription, Customers.CustState);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch21_productcategory_customerstate_revenue_cube';

SELECT pc.categorydescription,
    c.custstate,
    sum((od.quotedprice * (od.quantityordered)::numeric)) AS revenue
FROM ((((orders o
     JOIN order_details od ON ((od.ordernumber = o.ordernumber)))
     JOIN customers c ON ((c.customerid = o.customerid)))
     JOIN products p ON ((p.productnumber = od.productnumber)))
     JOIN categories pc ON ((pc.categoryid = p.categoryid)))
GROUP BY CUBE(pc.categorydescription, c.custstate);

-- 2. “For each category of product, show me, by state, how much quantity the
-- vendors have on hand. Give me subtotals for each state within a category,
-- plus a grand total.”
-- You can find my solution in CH21_ProductCategory_VendorState_QOH_ROLLUP (33
-- rows).
SELECT Categories.CategoryDescription,
    Vendors.VendState,
    SUM(QuantityOnHand) AS Quantity
FROM Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Product_Vendors
    ON Products.ProductNumber = Product_Vendors.ProductNumber
    INNER JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY ROLLUP (Categories.CategoryDescription, Vendors.VendState)
ORDER BY Categories.CategoryDescription, Vendors.VendState;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch21_productcategory_vendorstate_qoh_rollup';

SELECT pc.categorydescription,
    v.vendstate,
    sum(p.quantityonhand) AS qoh
FROM (((products p
     JOIN categories pc ON ((pc.categoryid = p.categoryid)))
     JOIN product_vendors pv ON ((pv.productnumber = p.productnumber)))
     JOIN vendors v ON ((v.vendorid = pv.vendorid)))
GROUP BY ROLLUP(pc.categorydescription, v.vendstate);

-- 3. “For each of our vendors, let me know how many products they supply in
-- each category. I want to see this broken down by state. For each state, show
-- me the number of products in each category. Show me the number of products
-- for all categories and a grand total as well.” Note that the counts will not
-- represent the number of different products that are sold!
-- You can find my solution in CH21_VendorState_Category_Count_ROLLUP (43 rows).
SELECT Vendors.VendState,
    Categories.CategoryDescription,
    COUNT(*) AS NumProducts
FROM Categories
    LEFT OUTER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Product_Vendors
    ON Products.ProductNumber = Product_Vendors.ProductNumber
    INNER JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY ROLLUP (Vendors.VendState, Categories.CategoryDescription)
ORDER BY Vendors.VendState, Categories.CategoryDescription;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch21_vendorstate_category_count_rollup';

-- Note: The book solution as is was wrong, because it self-joins
-- product_vendors onto itself
SELECT v.vendstate,
    c.categorydescription,
    count(*) AS products
FROM (((vendors v
     JOIN product_vendors pv ON ((pv.vendorid = pv.vendorid)))
     JOIN products p ON ((p.productnumber = pv.productnumber)))
     JOIN categories c ON ((c.categoryid = p.categoryid)))
GROUP BY ROLLUP(v.vendstate, c.categorydescription);

/* ***** School Scheduling Database ******** */
-- 1. “Summarize the number of class sessions scheduled, showing semester,
-- building, classroom, and subject. Give me subtotals for each semester, for
-- each combination of building and classroom and for each subject.”
-- You can find my solution in
-- CH21_Semester_Building_ClassRoom_Subject_Count_GROUPING_SETS (82 rows).
SELECT SemesterNo,
    BuildingCode,
    ClassRoomID,
    SubjectCode,
    COUNT(*) AS NumClasses
FROM ch20_class_schedule_calendar
GROUP BY GROUPING SETS (SemesterNo,
    (BuildingCode, ClassroomID),
    SubjectCode);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch21_semester_building_classroom_subject_count_grouping_sets';

SELECT ch20_class_schedule_calendar.semesterno,
    ch20_class_schedule_calendar.buildingcode,
    ch20_class_schedule_calendar.classroomid,
    ch20_class_schedule_calendar.subjectcode,
    count(*) AS numberofsessions
FROM ch20_class_schedule_calendar
GROUP BY GROUPING SETS ((ch20_class_schedule_calendar.semesterno),
    (ch20_class_schedule_calendar.buildingcode,
        ch20_class_schedule_calendar.classroomid),
    (ch20_class_schedule_calendar.subjectcode));

-- 2. “For each department, show me the number of courses that could be offered,
-- and whether they’re taught by a Professor, an Associate Professor, or an
-- Instructor. Give me total courses per department and total courses overall as
-- well.”
-- Note that the number of courses returned will be greater than the number of
-- courses offered by the school because some courses could be taught by more
-- than instructors.
-- You can find my solution in CH21_Department_Title_Count_ROLLUP (20 rows).
SELECT Departments.DeptName,
    Faculty.Title,
    COUNT(*) AS NumOfferableCourses
FROM Staff
    INNER JOIN Faculty
    ON Staff.StaffID = Faculty.StaffID
    INNER JOIN Faculty_Subjects
    ON Staff.StaffID = Faculty_Subjects.StaffID
    INNER JOIN Subjects
    ON Faculty_Subjects.SubjectID = Subjects.SubjectID
    INNER JOIN schoolschedulingexample.Categories
    ON Subjects.CategoryID = Categories.CategoryID
    INNER JOIN Departments
    ON Categories.DepartmentID = Departments.DepartmentID
GROUP BY ROLLUP (Departments.DeptName, Faculty.Title);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch21_department_title_count_rollup';

-- 3. “I want to know how many courses our students have been in contact with.
-- Give me totals by whether they completed the course, are currently enrolled
-- in it or withdrew.  I’d also like to see this broken down by student major.
-- May as well give me the total courses completed, enrolled and withdrawn while
-- you’re at it. Don’t worry about splitting it up by semester.”
-- You can find my solution in CH21_Major_ClassStatus_Count_GROUPING_SETS (26
-- rows).
SELECT Majors.Major,
    Student_Class_Status.ClassStatusDescription,
    COUNT(*) AS NumClasses 
FROM Majors
    INNER JOIN Students
    ON MAjors.MajorID = Students.StudMajor
    INNER JOIN Student_Schedules
    ON Students.StudentID = Student_Schedules.StudentID
    INNER JOIN Student_Class_Status
    ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
GROUP BY GROUPING SETS (Student_Class_Status.ClassStatusDescription,
    Majors.Major,
    (Student_Class_Status.ClassStatusDescription, Majors.Major));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch21_major_classstatus_count_grouping_sets';

-- Note: The book does an unnecessary join on Classes, since all we care about
-- is the ClassIDs that are associated with Student_Schedules
SELECT m.major,
    scs.classstatusdescription,
    count(*) AS courses
FROM ((((majors m
     JOIN students s ON ((m.majorid = s.studmajor)))
     JOIN student_schedules ss ON ((ss.studentid = s.studentid)))
     JOIN student_class_status scs ON ((scs.classstatus = ss.classstatus)))
     JOIN classes c ON ((c.classid = ss.classid)))
GROUP BY GROUPING SETS ((m.major), (scs.classstatusdescription), (m.major,
        scs.classstatusdescription));
