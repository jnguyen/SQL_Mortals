/* ********** SQL FOR MERE MORTALS CHAPTER 11 ********** */
/* ******** Subqueries                        ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** What is a Subquery?                      ****/
/* ******************************************** ****/
/* *** Row Subquery *************************** ****/
-- Ex. Use a compound part identifier as row comparison using row value
-- constructor and row subquery. Most DBMSs as of 2018 don't support this.
SELECT SKUClass, SKUNumber, ProductName
FROM Products
WHERE
    (SKUClass, SKUNumber) >= ('DSK', 9775);

-- Ex. Substitute SELECT statement returning single row of 2 columns for
-- comparison
SELECT SKUClass, SKUNumber, ProductName
FROM Products
WHERE (SKUClass > 'DSK') OR ((SKUClass = 'DSK') AND (SKUNumber >= 9775))

/* ******************************************** ****/
/* *** Subqueries As Column Expressions         ****/
/* ******************************************** ****/
/* *** Row Subquery *************************** ****/
-- Can compare a row constructor to essentially a tuple
-- Ex: List all parts with combined identifier DSK09775 or higher
SELECT SKUClass, SKUNumber, ProductName
FROM Products
WHERE (SKUClass, SKUNumber) >= ('DSK', 9775)

-- ** Subqueries as column expressions ** --
-- Show me all the orders shipped on October 3, 2017, and each order’s related
-- customer last name
SELECT Orders.OrderNumber, Orders.OrderDate,
Orders.ShipDate,
	-- Scalar subquery: for each order ID, select the customer
	(SELECT Customers.CustLastName
	FROM Customers
	WHERE Customers.CustomerID =
	 Orders.CustomerID)
FROM Orders
WHERE Orders.ShipDate = '2017-10-03'

-- Exactly the same query above, solved in a more understood join
SELECT Orders.OrderNumber, Orders.OrderDate,
Orders.ShipDate, Customers.CustLastName
FROM Customers
INNER JOIN Orders
ON Customers.CustomerID = Orders.OrderID
WHERE Orders.ShipDate = '2017-10-03'

-- Use COUNT to count non-null rolls of a specified column
-- Ex. List all the customer names and a count of the orders they placed.
SELECT Customers.CustFirstName,
Customers.CustLastName,
	-- Subquery: count number of rows in table of orders for each customer
	(SELECT COUNT(*)
	FROM Orders
	WHERE Orders.CustomerID =
	 Customers.CustomerID)
	AS CountOfOrders
FROM Customers

-- Use MAX to find the largest row in a column
-- Show me a list of customers and the last date on which they placed an order.
SELECT Customers.CustFirstName,
Customers.CustLastName,
	-- Subquery: MAX date of a customer's order is the latest order
	(SELECT MAX(OrderDate)
	FROM Orders
	WHERE Orders.CustomerID =
	 Customers.CustomerID) AS LastOrderDate
FROM Customers

-- **Subqueries as filters** --
-- Ex. List customers and all the details from their last order.
SELECT Customers.CustFirstName,
Customers.CustLastName, Orders.OrderNumber,
Orders.OrderDate,
Order_Details.ProductNumber,
Products.ProductName,
Order_Details.QuantityOrdered
FROM ((Customers
INNER JOIN Orders
  ON Customers.CustomerID = Orders.CustomerID)
INNER JOIN Order_Details
  ON Orders OrderNumber =
Order_Details.OrderNumber)
INNER JOIN Products
  ON Products.ProductNumber =
Order_Details.ProductNumber
	-- The LHS Orders table will usually be identified as the subquery Orders,
	-- not the original Orders from the database
WHERE Orders.OrderDate =
(SELECT MAX(OrderDate)
FROM Orders AS O2
WHERE O2.CustomerID = Customers.CustomerID)

-- Special Predicate Keywords For Subqueries
-- You can specify the RHS set for IN using a subquery
-- List all my recipes that have a seafood ingredient.
SELECT RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN
	-- Select all recipe IDs that have seafood ingredients
(SELECT RecipeID
FROM Recipe_Ingredients
WHERE Recipe_Ingredients.IngredientID IN
(SELECT IngredientID
FROM Ingredients
INNER JOIN Ingredient_Classes
ON Ingredients.IngredientClassID =
 Ingredient_Classes.IngredientClassID
WHERE
Ingredient_Classes.IngredientClassDescription
= 'Seafood'))

-- We could replace the INNER JOIN with another nested subquery, but it's hard
-- to read. Mora: Don't use more subqueries than you need.
(SELECT IngredientID
FROM Ingredients
WHERE Ingredients.IngredientClassID IN
(SELECT IngredientClassID
FROM Ingredient_Classes
WHERE
Ingredient_Classes.IngredientClassDescription
= 'Seafood'))

-- Same subquery, using a single IN and complex JOIN, for readability
SELECT RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN
(SELECT RecipeID
FROM (Recipe_Ingredients
INNER JOIN Ingredients
 ON Recipe_Ingredients.IngredientID =
Ingredients.IngredientID)
INNER JOIN Ingredient_Classes
 ON Ingredients.IngredientClassID =
Ingredient_Classes.IngredientClassID
WHERE
Ingredient_Classes.IngredientClassDescription
= 'Seafood')

-- If you don't use a subquery, you will get duplicate rows a recipe contains
-- more than one seafood ingredient. You could use DISTINCT, but then if you use
-- a view, then the table is impossible to update.
SELECT RecipeTitle
FROM ((Recipes
INNER JOIN Recipe_Ingredients
  ON Recipes.RecipeID =
Recipe_Ingredients.RecipeID)
INNER JOIN Ingredients
  ON Recipe_Ingredients.IngredientID =
Ingredients.IngredientID)
INNER JOIN Ingredient_Classes
  ON Ingredients.IngredientClassID =
Ingredient_Classes.IngredientClassID
WHERE
Ingredient_Classes.IngredientClassDescription
= 'Seafood'

-- Subqueries have the advantage of filtering complex requests.
-- Ex. List recipes and all ingredients for each recipe for recipes that have a 
-- seafood ingredient.
SELECT Recipes.RecipeTitle,
Ingredients.IngredientName
	-- Need to join recipes to ingredients to get proper ingredient list
FROM (Recipes
INNER JOIN Recipe_Ingredients
  ON Recipes.RecipeID =
Recipe_Ingredients.RecipeID)
INNER JOIN Ingredients
  ON Ingredients.IngredientID =
Recipe_Ingredients.IngredientID
	-- Then, use IN to find any recipe IDs with seafood in them, like above
WHERE Recipes.RecipeID IN
(SELECT RecipeID
FROM (Recipe_Ingredients
INNER JOIN Ingredients
  ON Recipe_Ingredients.IngredientID =
Ingredients.IngredientID)
INNER JOIN Ingredient_Classes
  ON Ingredients.IngredientClassID =
Ingredient_Classes.IngredientClassID
WHERE
Ingredient_Classes.IngredientClassDescription
= 'Seafood')


/* *** Quantified: ALL, SOME, and ANY ********* ****/
-- NOTE: <> SOME and <> ANY are the same, and is true when the left does not
-- equal at least one of the returned rows on the RHS.
-- NOTE: When there are no rows on the RHS, ALL is always TRUE, and SOME is
-- always FALSE

-- Ex. Show me the recipes that have beef or garlic.
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN
    -- Subquery to select RecipeIDs that with beef or garlic as an ingredient
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
    WHERE Recipe_Ingredients.IngredientID = ANY
        -- Subquery that returns the ingredient IDs of beef and garlic
        (SELECT Ingredients.IngredientID
        FROM Ingredients
        WHERE Ingredients.IngredientName
        IN ('Beef', 'Garlic')));

-- Ex. Find all accessories that are priced greater than any clothing item.
-- Select all accessories
SELECT Products.ProductName,
    Products.RetailPrice
FROM Products
    INNER JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
WHERE Categories.CategoryDescription = 'Accessories'
-- Filter accessories that have retail prices greater than the price of any
-- cothing item, i.e. the item must have a price greater than all clothing items
    AND Products.RetailPrice > ALL
        (SELECT Products.RetailPrice
        FROM Products
            INNER JOIN Categories
            ON Products.CategoryID = Categories.CategoryID
        WHERE Categories.CategoryDescription = 'Clothing');

/* *** Existence: EXISTS ********************** ****/
-- Ex. Find all customers who ordered a bicycle.
-- NOTE: Since we don't care what's returned by the subquery, we use *
SELECT Customers.CustomerID, Customers.CustFirstName, Customers.CustLastName
FROM Customers
WHERE EXISTS
    -- Subquery: All orders from each customer that was also a bicycle
    (SELECT *
    FROM (Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber)
        INNER JOIN Products
        ON Products.ProductNumber = Order_Details.ProductNumber
    WHERE Products.CategoryID = 2
        AND Orders.CustomerID = Customers.CustomerID);

-- Ex. INNER JOIN version of the same query, which is not updatable (DISTINCT)
SELECT DISTINCT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM (((customers
 JOIN orders ON ((customers.customerid = orders.customerid)))
 JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
 JOIN products ON ((products.productnumber = order_details.productnumber)))
WHERE (products.categoryid = 2);

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* *** Subqueries in Expressions ************** ****/
/* ***** Sales Orders Database ************* */
-- Ex. List vendors and a count of the products they sell to us.
SELECT VendName,
    (SELECT COUNT(*)
    FROM Product_Vendors
    WHERE Product_Vendors.VendorID = Vendors.VendorID) AS VendProductCount
FROM Vendors;

/* ***** Entertainment Agency Database ***** */
-- Ex. Display all customers and the date of the last booking each made.
SELECT CustLastName, CustFirstName,
    (SELECT MAX(StartDate)
    FROM Engagements
    WHERE Customers.CustomerID = Engagements.CustomerID) AS LastBooking
FROM entertainmentagencyexample.Customers;

/* ***** School Scheduling Database ******** */
-- Ex. Display all subjects and the count of classes for each subject on Monday.
SELECT SubjectName,
    (SELECT COUNT(*)
    FROM Classes
    WHERE Classes.SubjectID = Subjects.SubjectID
        AND MondaySchedule = 1) AS MondayClassCount
FROM Subjects;

/* ***** Bowling League Database *********** */
-- Ex. Display the bowlers and the highest game each bowled.
SELECT BowlerLastName, BowlerFirstName,
    (SELECT MAX(RawScore)
    FROM Bowler_Scores
    WHERE Bowler_Scores.BowlerID = Bowlers.BowlerID) HighScore
FROM Bowlers;

/* ***** Recipes Database ****************** */
-- Ex. List all the meats and the count of recipes each appears in.
SELECT Ingredient_Classes.IngredientClassDescription,
    Ingredients.IngredientName,
    (SELECT COUNT(*)
    FROM Recipe_Ingredients
    WHERE Recipe_Ingredients.IngredientID = Ingredients.IngredientID)
        AS NumRecipes
FROM Ingredient_Classes
    INNER JOIN Ingredients
        ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID
WHERE Ingredient_Classes.IngredientClassDescription = 'Meat';

/* *** Subqueries in Filters ****************** ****/
/* ***** Sales Orders Database ************* */
-- Ex. Display customers who ordered clothing or accessories.
SELECT CustomerID, CustLastName, CustFirstName
FROM Customers
WHERE CustomerID = ANY
    (SELECT Orders.CustomerID
    FROM ((Orders
                INNER JOIN Order_Details
                ON Orders.OrderNumber = Order_Details.OrderNumber)
                INNER JOIN Products
                ON Order_Details.ProductNumber = Products.ProductNumber)
                INNER JOIN Categories
                ON Products.CategoryID = Categories.CategoryID
            WHERE Categories.CategoryDescription = 'Clothing'
                OR Categories.CategoryDescription = 'Accessories');

-- Ex. Display customers who ordered clothing or accessories (IN solution)
-- Note: Pretty much the same solution as above
SELECT CustomerID, CustLastName, CustFirstName
FROM Customers
WHERE CustomerID IN 
    (SELECT Orders.CustomerID
    FROM ((Orders
                INNER JOIN Order_Details
                ON Orders.OrderNumber = Order_Details.OrderNumber)
                INNER JOIN Products
                ON Order_Details.ProductNumber = Products.ProductNumber)
                INNER JOIN Categories
                ON Products.CategoryID = Categories.CategoryID
            WHERE Categories.CategoryDescription = 'Clothing'
                OR Categories.CategoryDescription = 'Accessories');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch11_customers_clothing_or_accessories_in';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM customers
WHERE (customers.customerid IN ( SELECT orders.customerid
  FROM (((orders
     JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
     JOIN products ON ((products.productnumber = order_details.productnumber)))
     JOIN categories ON ((categories.categoryid = products.categoryid)))
  WHERE (((categories.categorydescription)::text = 'Clothing'::text)
    OR ((categories.categorydescription)::text = 'Accessories'::text))));

-- Ex. Display customers who ordered clothing or accessories (EXISTS solution)
-- Note: Need to correlate Orders and Customers with AND so the outer query
--       returns a CustomerID row if a row exists in the inner subquery
SELECT CustomerID, CustLastName, CustFirstName
FROM Customers
WHERE EXISTS
    (SELECT Orders.CustomerID
    FROM ((Orders
                INNER JOIN Order_Details
                ON Orders.OrderNumber = Order_Details.OrderNumber)
                INNER JOIN Products
                ON Order_Details.ProductNumber = Products.ProductNumber)
                INNER JOIN Categories
                ON Products.CategoryID = Categories.CategoryID
    WHERE (Categories.CategoryDescription = 'Clothing'
                OR Categories.CategoryDescription = 'Accessories')
            AND Orders.CustomerID = Customers.CustomerID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch11_customers_clothing_or_accessories_exists';

SELECT customers.customerid,
   customers.custfirstname,
   customers.custlastname
FROM customers
WHERE (EXISTS ( SELECT orders.ordernumber,
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
           products.categoryid,
           categories.categoryid,
           categories.categorydescription
          FROM (((orders
            JOIN order_details
                ON ((orders.ordernumber = order_details.ordernumber)))
            JOIN products
                ON ((products.productnumber = order_details.productnumber)))
            JOIN categories
                ON ((categories.categoryid = products.categoryid)))
         WHERE ((((categories.categorydescription)::text = 'Clothing'::text)
            OR ((categories.categorydescription)::text = 'Accessories'::text))
            AND (customers.customerid = orders.customerid))));

/* ***** Entertainment Agency Database ***** */
-- Ex. List the entertainers who played engagements for customer Berg.
SELECT EntStagename
FROM Entertainers
WHERE EntertainerID = ANY
    (SELECT EntertainerID
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID = Customers.CustomerID
    WHERE CustLastName = 'Berg');

-- Ex. List the entertainers who played engagements for customer Berg (EXISTS)
-- Note: EXISTS query needs to match EntertainerID with the outer table to work
SELECT EntStageName
FROM Entertainers
WHERE EXISTS
    (SELECT *
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID = Customers.CustomerID
    WHERE CustLastName = 'Berg'
        AND Engagements.EntertainerID = Entertainers.EntertainerID);

-- Ex. List the entertainers who played engagements for customer Berg (IN)
SELECT EntStagename
FROM Entertainers
WHERE EntertainerID IN
    (SELECT EntertainerID
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID = Customers.CustomerID
    WHERE CustLastName = 'Berg');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch11_entertainers_berg_in';

SELECT entertainers.entertainerid,
   entertainers.entstagename
FROM entertainers
WHERE (entertainers.entertainerid IN ( SELECT engagements.entertainerid
    FROM (entertainmentagencyexample.customers
    JOIN engagements ON ((customers.customerid = engagements.customerid)))
    WHERE ((customers.custlastname)::text = 'Berg'::text)));

/* ***** School Scheduling Database ******** */
-- Ex. Display studnets who have never withdrawn from a class.
SELECT StudentID, StudLastName, StudFirstName
FROM Students
WHERE Students.StudentID <> ANY
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE ClassStatusDescription = 'Withdrew');

SELECT StudentID, StudLastName, StudFirstName
FROM Students
WHERE Students.StudentID NOT IN
    (SELECT Student_Schedules.StudentID
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE ClassStatusDescription = 'Withdrew');

-- Ex. Display students who have never withdrawn from a class. (OUTER JOIN)
SELECT Students.StudentID, Students.StudLastName, Students.StudFirstName
FROM Students
    LEFT OUTER JOIN
        (SELECT StudentID
        FROM Student_Schedules
            INNER JOIN Student_Class_Status
            ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
        WHERE ClassStatusDescription = 'Withdrew') AS Withdrew
    ON Students.StudentID = Withdrew.StudentID
WHERE Withdrew.StudentID IS NULL;

/* ***** Bowling League Database *********** */
-- Ex. Display team captains with a handicap score higher than all other members
-- on their team.
SELECT Teams.TeamName, Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    Bowler_Scores.HandiCapScore
FROM (Bowlers
    INNER JOIN Teams
        ON Bowlers.BowlerID = Teams.CaptainID)
    INNER JOIN Bowler_Scores
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID
-- Note: Logic is if team captain has any score higher than rest of teams'
-- This query may possibly return multiple handicap scores are higher than rest
-- of the teams' handicap scores
-- LHS: List of all team captain's handicap scores
WHERE Bowler_Scores.HandiCapScore > ALL
-- RHS: List of all team captain's members' handicap scores
(SELECT BS2.HandiCapScore
FROM Bowlers AS B2
    INNER JOIN Bowler_Scores AS BS2
        ON B2.BowlerID = BS2.BowlerID
WHERE B2.BowlerID <> Bowlers.BowlerID
    AND B2.TeamID = Bowlers.TeamID);

/* ***** Recipes Database ****************** */
-- Ex. Display all the ingredients for recipes that contain carrots.
SELECT Recipes.RecipeTitle, Ingredients.IngredientName
FROM Recipes
    INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
WHERE R.RecipeID IN
    -- Recipe IDs where carrot is an ingredient
    (SELECT Recipe_Ingredients.RecipeID 
    FROM Ingredients
        LEFT OUTER JOIN Recipe_Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE IngredientName = 'Carrot')

/* Book Answer */
SELECT Recipes.RecipeTitle,
    Ingredients.IngredientName
FROM (Recipes
    INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
    INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipes.RecipeID IN
(SELECT Recipe_Ingredients.RecipeID
FROM Ingredients
    INNER JOIN Recipe_Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Ingredients.IngredientName ILIKE 'carrot')

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. Display products and the latest date each product was ordered. 40
-- (Hint: Use the MAX aggregate function.)
SELECT Products.ProductName,
    (SELECT MAX(OrderDate)
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
    WHERE Order_Details.ProductNumber = Products.ProductNumber) AS Last_Ordered
FROM Products;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch11_products_last_date';

SELECT products.productnumber,
   products.productname,
   ( SELECT max(orders.orderdate) AS max
    FROM (orders
      JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
    WHERE (order_details.productnumber = products.productnumber)) AS lastorder
FROM products;

-- 2. List customers who ordered bikes. 23
-- (Hint: Build a filter using IN.)
SELECT CustLastName, CustFirstName
FROM Customers
WHERE CustomerID IN
    -- All customer IDs who ordered bikes
    (SELECT CustomerID
    FROM Orders
        INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber
    WHERE CategoryID =
        -- Get category ID corresponding to bikes
        (SELECT CategoryID
        FROM Categories
        WHERE CategoryDescription = 'Bikes'));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch11_customers_ordered_bikes_in';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM customers
WHERE (customers.customerid IN ( SELECT orders.customerid
    FROM (((orders
    JOIN order_details ON ((orders.ordernumber = order_details.ordernumber)))
    JOIN products ON ((products.productnumber = order_details.productnumber)))
    JOIN categories ON ((categories.categoryid = products.categoryid)))
    WHERE ((categories.categorydescription)::text = 'Bikes'::text)));

-- 3. What products have never been ordered? 2
-- (Hint. Build a filter using NOT IN.)
SELECT Products.ProductName
FROM Products
WHERE Products.ProductNumber NOT IN
    -- All product numbers that have order details
    (SELECT ProductNumber
    FROM Order_Details);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch11_products_not_ordered';

SELECT products.productname
FROM products
WHERE (NOT (products.productnumber IN
        ( SELECT order_details.productnumber
          FROM order_details)));

/* ***** Entertainment Agency Database ***** */
-- 1. Show me all entertainers and the count of each entertainer's engagements.
-- Hint: Use the COUNT aggregate function. 13
SELECT Entertainers.EntStageName,
    (SELECT COUNT(*)
    FROM Engagements
    WHERE Entertainers.EntertainerID = Engagements.EntertainerID)
FROM Entertainers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch11_entertainer_engagement_count';

SELECT entertainers.entstagename,
   ( SELECT count(*) AS count
    FROM engagements
    WHERE (engagements.entertainerid = entertainers.entertainerid))
        AS engagecount
FROM entertainers;

-- 2. List customers who have booked entertainers who play country or country
-- rock. 13
-- Hint: Build a filter using IN.
-- Try number 1: uses DISTINCT, but not updatable as a result
SELECT DISTINCT CustLastName, CustFirstName
FROM entertainmentagencyexample.Customers
    INNER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.EntertainerID IN
    (SELECT EntertainerID
    FROM Entertainer_Styles
    WHERE StyleID IN
        (SELECT StyleID
        FROM Musical_Styles
        WHERE StyleName LIKE '%Country%'));

-- Try number 2: uses subqueries purely, but hard to read
SELECT CustLastName, CustFirstName
FROM entertainmentagencyexample.Customers
WHERE CustomerID IN
    (SELECT CustomerID
    FROM Engagements
    WHERE EntertainerID IN
        (SELECT EntertainerID
        FROM Entertainer_Styles
        WHERE StyleID IN
            (SELECT StyleID
            FROM Musical_Styles
            WHERE StyleName LIKE '%Country%')));

-- Try number 3: combines subqueries and INNER JOIN for readability
SELECT CustLastName, CustFirstName
FROM entertainmentagencyexample.Customers
WHERE CustomerID IN
    -- List of customer IDs (not distinct) that booked a country entertainer
    (SELECT CustomerID
    FROM Engagements
        INNER JOIN Entertainer_Styles
        ON Engagements.EntertainerID = Entertainer_Styles.EntertainerID
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
    WHERE StyleName LIKE '%Country%');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch11_customers_who_like_country';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
FROM entertainmentagencyexample.customers
WHERE (customers.customerid IN
    ( SELECT engagements.customerid
    FROM (((musical_styles
    JOIN entertainer_styles
    ON ((musical_styles.styleid = entertainer_styles.styleid)))
    JOIN entertainers
    ON ((entertainers.entertainerid = entertainer_styles.entertainerid)))
    JOIN engagements
    ON ((entertainers.entertainerid = engagements.entertainerid)))
    WHERE (((musical_styles.stylename)::text = 'Country'::text)
        OR ((musical_styles.stylename)::text = 'Country Rock'::text))));

-- 3. Find the entertainers who played engagements for customers Berg or
-- Hallmark. 8
-- Hint: Build a filter using = SOME.
SELECT EntStageName
FROM Entertainers
WHERE EntertainerID = SOME
    (SELECT EntertainerID
    FROM Engagements
        INNER JOIN entertainmentagencyexample.Customers
        ON entertainmentagencyexample.Customers.CustomerID =
            Engagements.CustomerID
    WHERE CustLastName SIMILAR TO 'Berg|Hallmark');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch11_entertainers_berg_or_hallmark_some';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE (entertainers.entertainerid IN ( SELECT engagements.entertainerid
    FROM (entertainmentagencyexample.customers
    JOIN engagements
    ON ((customers.customerid = engagements.customerid)))
    WHERE (((customers.custlastname)::text = 'Berg'::text)
        OR ((customers.custlastname)::text = 'Hallmark'::text))));

-- 4. Display agents who haven't booked an entertainer. 1
-- Hint: Build a filter using NOT IN.
SELECT AgtLastName, AgtFirstName
FROM Agents
WHERE AgentID NOT IN
    (SELECT AgentID
    FROM Engagements);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch11_bad_agents';

SELECT agents.agentid,
    agents.agtfirstname,
    agents.agtlastname
FROM agents
WHERE (NOT (agents.agentid IN ( SELECT engagements.agentid
   FROM engagements)));

/* ***** School Scheduling Database ******** */
-- 1. List all staff members and the count of classes each teaches. 27
-- Hint: Use the COUNT aggregate function.
SELECT StfLastName, StfFirstName,
    (SELECT COUNT(*)
    FROM Faculty_Classes
    WHERE Staff.StaffID = Faculty_Classes.StaffID) AS ClassCount
FROM Staff;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch11_staff_class_count';

SELECT staff.staffid,
    staff.stffirstname,
    staff.stflastname,
    ( SELECT count(*) AS count
          FROM faculty_classes
          WHERE (faculty_classes.staffid = staff.staffid)) AS classcount
FROM staff;

-- 2. Display students enrolled in a class on Tuesday. 18
-- Hint: Build a filter using IN.
SELECT StudLastName, StudFirstName
FROM Students
WHERE Students.StudentID IN
    (SELECT StudentID
    FROM Classes
        INNER JOIN Student_Schedules
        ON Classes.ClassID = Student_Schedules.ClassID
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
    WHERE TuesdaySchedule = 1
        AND ClassStatusDescription = 'Enrolled');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch11_students_in_class_tuesdays';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname
FROM students
WHERE (students.studentid IN ( SELECT student_schedules.studentid
    FROM (student_schedules
    JOIN classes ON ((student_schedules.classid = classes.classid)))
    WHERE (classes.tuesdayschedule = 1)));

-- 3. List the subjects taught on Wednesday. 34
-- Hint: Build a filter using IN.
SELECT SubjectID, SubjectCode, SubjectName
FROM Subjects
WHERE Subjects.SubjectID IN
    (SELECT SubjectID
    FROM Classes
    WHERE WednesdaySchedule = 1);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch11_subjects_on_wednesday';

SELECT categories.categorydescription,
    subjects.subjectid,
    subjects.subjectcode,
    subjects.subjectname
FROM (schoolschedulingexample.categories
    JOIN subjects
    ON (((categories.categoryid)::text = (subjects.categoryid)::text)))
WHERE (subjects.subjectid IN ( SELECT classes.subjectid
    FROM classes
    WHERE (classes.wednesdayschedule = 1)));

/* ***** Bowling League Database *********** */
-- 1. Show me all the bowlers and a count of games each bowled. 32
-- Hint: Use the COUNT aggregate function.
SELECT Bowlers.BowlerID, Bowlers.BowlerLastName, Bowlers.BowlerFirstName,
    (SELECT COUNT(*)
    FROM Bowler_Scores
    WHERE Bowler_Scores.BowlerID = Bowlers.BowlerID) Number_of_games
FROM Bowlers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch11_bowlers_and_count_games';

SELECT bowlers.bowlerfirstname,
   bowlers.bowlerlastname,
   ( SELECT count(*) AS count
          FROM bowler_scores
         WHERE (bowler_scores.bowlerid = bowlers.bowlerid)) AS games
FROM bowlers;

-- 2. List all the bowlers who have a raw score that's less than all of the
-- other bowlers on the same team. 3
-- Hint: Build a filter using < ALL. Also use DISTINCT in case a bowler has
-- multiple games with the same low score.
SELECT DISTINCT Teams.TeamName,
    Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    Bowler_Scores.RawScore
FROM (Bowlers
    INNER JOIN Teams
        ON Bowlers.TeamID = Teams.TeamID
    INNER JOIN Bowler_Scores
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID)
WHERE Bowler_Scores.RawScore < ALL
    (SELECT BS2.RawScore
    FROM Bowlers AS B2
        INNER JOIN Bowler_Scores AS BS2
            ON B2.BowlerID = BS2.BowlerID
    WHERE B2.BowlerID <> Bowlers.BowlerID
        AND B2.TeamID = Bowlers.TeamID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch11_bowlers_low_score';

SELECT DISTINCT bowlers.bowlerid,
    bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    bowler_scores.rawscore
FROM (bowlers
    JOIN bowler_scores ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
WHERE (bowler_scores.rawscore < ALL ( SELECT bs2.rawscore
    FROM (bowlers b2
    JOIN bowler_scores bs2 ON ((b2.bowlerid = bs2.bowlerid)))
    WHERE ((b2.bowlerid <> bowlers.bowlerid)
        AND (b2.teamid = bowlers.teamid))));

/* ***** Recipes Database ****************** */
-- 1. Show me the types of recipes and the count of recipes in each type. 7
-- Hint: Use the COUNT aggregate function.
SELECT RecipeClassID, RecipeClassDescription,
    (SELECT COUNT(*)
    FROM Recipes
    WHERE Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
FROM Recipe_Classes;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch11_count_of_recipe_types';

SELECT recipe_classes.recipeclassid,
    recipe_classes.recipeclassdescription,
    ( SELECT count(*) AS count
   FROM recipes
   WHERE (recipes.recipeclassid = recipe_classes.recipeclassid)) AS recipecount
FROM recipe_classes;

-- 2. List the ingredients that are used in some recipes where the measurement
-- amount in the recipe is not the default measurement amount. 21
-- Hint: Build a filter using <> SOME.
SELECT IngredientName
FROM Ingredients
WHERE Ingredients.MeasureAmountID <> SOME
    (SELECT MeasureAmountID
    FROM Recipe_Ingredients
    WHERE Recipe_Ingredients.IngredientID = Ingredients.IngredientID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch11_ingredients_using_nonstandard_measure';

SELECT ingredients.ingredientid,
    ingredients.ingredientname,
    ingredients.measureamountid
FROM ingredients
WHERE (ingredients.measureamountid <> ANY
    ( SELECT recipe_ingredients.measureamountid
    FROM recipe_ingredients
    WHERE (recipe_ingredients.ingredientid = ingredients.ingredientid)));
