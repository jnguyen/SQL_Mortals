/* ********** SQL FOR MERE MORTALS CHAPTER 8 *********** */
/* ******** INNER JOINS                       ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** The INNER JOIN                           ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
-- Basic JOIN syntax
SELECT RecipeTitle, Preparation,
    RecipeClassDescription
FROM Recipe_Classes rc INNER JOIN Recipes r
	ON rc.RecipeClassID = r.RecipeClassID;

-- It's possible to perform inner joins using WHERE
-- Note: SQL Standard syntax allows full definition of source for final result
-- set entirely within FROM. In SQL Standard, WHERE filters out whatever
-- is in the FROM clause.
SELECT Recipes.RecipeTitle, Recipes.Preparation,
    Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes, Recipes
WHERE Recipe_Classes.RecipeClassID = Recipes.RecipeClassID;

-- USING can simplify equality INNER JOINs
SELECT Recipes.RecipeTitle, Recipes.Preparation,
    Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes
INNER JOIN Recipes
USING (RecipeClassID);

-- Correlation names (aka AS)
SELECT R.RecipeTitle, R.Preparation,
    RC.RecipeClassDescription
FROM Recipe_Classes AS RC
  INNER JOIN Recipes AS R
  ON RC.RecipeClassID = R.RecipeClassID;

-- You can INNER JOIN and also filter rows using WHERE
SELECT R.RecipeTitle, R.Preparation,
    RC.RecipeClassDescription
FROM Recipe_Classes AS RC
  INNER JOIN Recipes AS R
  ON RC.RecipeClassID = R.RecipeClassID
WHERE RC.RecipeClassDescription = 'Main course'
  OR RC.RecipeClassDescription = 'Dessert';

-- You can SELECT from a subquery
-- Note: Embedded aliases not supported in Postgres
SELECT R.RecipeTitle, R.Preparation,
  RCFiltered.ClassName
FROM
 (SELECT RecipeClassID, RecipeClassDescription AS ClassName
   FROM Recipe_Classes
   WHERE RecipeClassDescription = 'Main course' OR
     RecipeClassDescription = 'Dessert') RCFiltered
INNER JOIN Recipes R
  ON RCFiltered.RecipeClassID = R.RecipeClassID;

-- Combine multiple INNER JOINs to create more complex queries
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
  Recipes.Preparation, Ingredients.IngredientName,
  Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
  Measurements.MeasurementDescription
FROM (((Recipe_Classes
  INNER JOIN Recipes
  ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
  INNER JOIN Recipe_Ingredients
  ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
  INNER JOIN Ingredients
  ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
  INNER JOIN Measurements
  ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
ORDER BY RecipeTitle, RecipeSeqNo;

-- Sometimes, you'll need to join a linking table despite selecting no columns
-- from that linking table
SELECT Recipes.RecipeTitle, Ingredients.IngredientName
FROM (Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
    INNER JOIN Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID;

/* ******************************************** ****/
/* *** Sample Statements - Two Tables           ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Display all products and their categories.
SELECT c.CategoryDescription, p.ProductName
FROM Products p INNER JOIN Categories c
  ON p.CategoryID = c.CategoryID
ORDER BY CategoryDescription;

/* ***** Entertainment Agency Database ***** */
-- Show me entertainers, the start and end date of their contracts, and the
-- contract price
SELECT ent.EntStageName, eng.StartDate, eng.EndDate, eng.ContractPrice
FROM Entertainers ent INNER JOIN Engagements eng
  ON ent.EntertainerID = eng.EntertainerID;

/* ***** School Scheduling Database ******** */
-- List the subjects taught on Wednesday
-- Use DISTINCT because several class sections
SELECT DISTINCT s.SubjectCode, s.SubjectName, s.SubjectDescription
FROM Subjects s INNER JOIN Classes c
  ON s.SubjectID = c.SubjectID
WHERE c.WednesdaySchedule = 1; /* Can also say = -1 for "integer with all bits"

/* ***** Bowling League Database *********** */
-- Display bowling teams and the name of each captain.
SELECT t.TeamName, b.BowlerLastName AS CaptainLastName,
  b.BowlerFirstName AS CaptainFirstName
FROM Teams t INNER JOIN Bowlers b
  ON t.CaptainID = b.BowlerID;

/* ***** Recipes Database ****************** */
-- Show me the recipes that have beef or garlic.
SELECT DISTINCT r.RecipeTitle
FROM Recipes r INNER JOIN Recipe_Ingredients ri
  ON r.RecipeID = ri.RecipeID
  INNER JOIN Ingredients i
  ON ri.IngredientID = i.IngredientID
WHERE i.IngredientName SIMILAR TO 'Beef|Garlic'

SELECT DISTINCT r.RecipeTitle
FROM Recipes r INNER JOIN Recipe_Ingredients ri
  ON r.RecipeID = ri.RecipeID
  INNER JOIN Ingredients i
  ON ri.IngredientID = i.IngredientID
WHERE i.IngredientName LIKE 'Beef%' OR
    i.IngredientName LIKE 'Garlic%';

/* ******************************************** ****/
/* *** Sample Statements - More Than Two Tables ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Find all the customers who have ever ordered a bicycle helmit.
SELECT DISTINCT CustLastName, CustFirstName
FROM Customers c INNER JOIN Orders o
  ON c.CustomerID = o.CustomerID
  INNER JOIN Order_Details od
  ON o.OrderNumber = od.OrderNumber
  INNER JOIN Products p
  ON od.ProductNumber = p.ProductNumber
WHERE p.ProductName LIKE '%Helmet%';

/* ***** Entertainment Agency Database ***** */
-- Find the entertainers who played engagements for customers Berg or Hallmark.
SELECT DISTINCT ent.EntStageName
FROM Entertainers ent INNER JOIN Engagements eng
  ON ent.EntertainerID = eng.EntertainerID
  INNER JOIN Customers c
  ON eng.CustomerID = c.CustomerID;

-- Note: Must specify schema for customers table since there are multiple tables
-- named customer in the DB
SELECT DISTINCT ent.entstagename
FROM entertainers ent INNER JOIN engagements eng
  ON ent.entertainerid = eng.entertainerid
  INNER JOIN entertainmentagencyexample.customers c
  ON c.customerid = eng.customerid
WHERE c.custlastname SIMILAR TO 'Berg|Hallmark';

-- Book official for PostgreSQL:
SELECT DISTINCT entertainers.entstagename
FROM ((entertainers
     JOIN engagements ON ((entertainers.entertainerid =
            engagements.entertainerid)))
     JOIN entertainmentagencyexample.customers ON ((customers.customerid =
            engagements.customerid)))
WHERE (((customers.custlastname)::text = 'Berg'::text) OR
    ((customers.custlastname)::text = 'Hallmark'::text));

/* ***** Bowling League Database *********** */
-- List all the tournaments, the tournament matches, and the game results.
SELECT t.TourneyID, t.TourneyLocation,
    t_m.MatchID, t_m.Lanes, OddTeams.TeamName OddTeam, 
    EvenTeams.TeamName EvenTeam,
    m_g.GameNumber, Winners.TeamName Winner
FROM Tournaments t INNER JOIN Tourney_Matches t_m
  ON t.TourneyID = t_m.TourneyID
  INNER JOIN Match_Games m_g
  ON t_m.MatchID = m_g.MatchID
  INNER JOIN Teams OddTeams
  ON t_m.OddLaneTeamID = OddTeams.TeamID
  INNER JOIN Teams EvenTeams
  ON t_m.EvenLaneTeamID = EvenTeams.TeamID
  INNER JOIN Teams Winners
  ON m_g.WinningTeamID = Winners.TeamID;

/* ***** Recipes Database ****************** */
-- Show me the main course recipes and list all the ingredients.
SELECT r.RecipeTitle, i.IngredientName, m.MeasurementDescription, r_i.Amount
FROM Recipes r INNER JOIN Recipe_Ingredients r_i
  ON r.RecipeID = r_i.RecipeID
  INNER JOIN Ingredients i
  ON r_i.IngredientID = i.IngredientID
  INNER JOIN Recipe_Classes r_c
  ON r.RecipeClassID = r_c.RecipeClassID
  INNER JOIN Measurements m
  ON r_i.MeasureAmountID = m.MeasureAmountID
WHERE RecipeClassDescription LIKE 'Main course';

/* ******************************************** ****/
/* *** Looking for Matching Values              ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Find all the customers who ordered a bicycle and also ordered a helmet.
-- OR: Find all the customers who ordered a bicycle, then find all the customers
-- who ordered a helmet, and finally list the common customers so that we know
-- who ordered both a bicycle and a helmet.
SELECT CustBikes.CustFirstName, CustBikes.CustLastName
FROM (SELECT DISTINCT Customers.CustomerID, Customers.CustFirstName,
    Customers.CustLastName
    FROM ((Customers INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID)
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber)
    INNER JOIN Products
    ON Products.ProductNumber = Order_Details.ProductNumber
    WHERE Products.ProductName LIKE '%Bike') AS CustBikes
        INNER JOIN
    (SELECT DISTINCT Customers.CustomerID
    FROM ((Customers INNER JOIN Orders
            ON Customers.CustomerID = Orders.CustomerID)
            INNER JOIN Order_Details
            ON Orders.OrderNumber = Order_Details.OrderNumber)
            INNER JOIN Products
            ON Products.ProductNumber = Order_Details.ProductNumber
            WHERE Products.ProductName LIKE '%Helmet') AS CustHelmets
        ON CustBikes.CustomerID = CustHelmets.CustomerID;

/* ***** Entertainment Agency Database ***** */
-- List the entertainers who played engagements for both customers Berg and
-- Hallmark.
-- OR: Find all the entertainers who played an engagement for Berg, then find
-- all the entertainers who played an engagement for Hallmark, and finally list
-- the common entertainers so that we know who played an engagement for both.
SELECT BergEntertainers.EntStageName
FROM (SELECT DISTINCT Entertainers.EntertainerID, Entertainers.EntStageName
    FROM (Entertainers INNER JOIN Engagements
        ON Entertainers.EntertainerID = Engagements.EntertainerID)
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID =
        entertainmentagencyexample.Customers.CustomerID
        WHERE entertainmentagencyexample.Customers.CustLastName = 'Berg') AS
    BergEntertainers
    INNER JOIN
     (SELECT DISTINCT Entertainers.EntertainerID, Entertainers.EntStageName
    FROM (Entertainers INNER JOIN Engagements
        ON Entertainers.EntertainerID = Engagements.EntertainerID)
        INNER JOIN entertainmentagencyexample.Customers
        ON Engagements.CustomerID =
        entertainmentagencyexample.Customers.CustomerID
        WHERE entertainmentagencyexample.Customers.CustLastName = 'Hallmark') AS
    HallmarkEntertainers
    ON BergEntertainers.EntertainerID = HallmarkEntertainers.EntertainerID;

/* ***** School Scheduling Database ******** */
-- Show me the students and teachers who have the same first name.
SELECT (Students.StudFirstName || ' ' || Students.StudLastName) AS StudFullName,
    (Staff.StfFirstName || ' ' || Staff.StfLastName) AS StfFullName
FROM Students INNER JOIN Staff
    ON Students.StudFirstName = Staff.StfFirstName;

/* ***** Bowling League Database *********** */
-- Find the bowlers who had a raw score of 170 or better at both Thunderbird
-- Lanes and Bolero Lanes
-- OR: Find all the bowlers who had a raw score of 170 or better at Thunderbird
-- Lanes, then find all the bowlers who had a raw score of 170 or better at
-- Bolero Lanes, and finally list the common bowlers so that we know who had
-- good scores at both bowling alleys.
SELECT BowlerBolero170.BowlerLastName, BowlerBolero170.BowlerFirstName
FROM (SELECT DISTINCT Bowlers.BowlerID, Bowlers.BowlerLastName,
        Bowlers.BowlerFirstName
    FROM ((Bowlers INNER JOIN Bowler_Scores
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID)
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID)
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Tournaments.TourneyLocation = 'Thunderbird Lanes' AND
        Bowler_Scores.RawScore >= 170) AS BowlerThunder170 
    INNER JOIN
     (SELECT DISTINCT Bowlers.BowlerID, Bowlers.BowlerLastName,
        Bowlers.BowlerFirstName
    FROM ((Bowlers INNER JOIN Bowler_Scores
        ON Bowlers.BowlerID = Bowler_Scores.BowlerID)
        INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID)
        INNER JOIN Tournaments
        ON Tourney_Matches.TourneyID = Tournaments.TourneyID
    WHERE Tournaments.TourneyLocation = 'Bolero Lanes' AND
        Bowler_Scores.RawScore >= 170) AS BowlerBolero170 
    ON BowlerThunder170.BowlerID = BowlerBolero170.BowlerID;

/* ***** Recipes Database ****************** */
-- Display all ingredients for recipes that contain carrots.
SELECT Recipes.RecipeID, Recipes.RecipeTitle, Ingredients.IngredientName
FROM ((Recipes INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
    INNER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Ingredients INNER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Carrot') AS Carrots
    ON Recipes.RecipeID = Carrots.RecipeID;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. List customers and the dates they placed an order, sorted in order date
-- sequence. (Hint The solution requires a JOIN or two tables.)
SELECT c.CustLastName, c.CustFirstName, o.OrderDate
FROM Customers c INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_customers_and_orderdates';

SELECT concat(customers.custfirstname, ' ', customers.custlastname) AS
    customerfullname, orders.orderdate
FROM (customers JOIN orders
    ON ((customers.customerid = orders.customerid)))
ORDER BY orders.orderdate;

-- 2. List employees and the customers for whom they booked an order.
SELECT DISTINCT e.EmpLastName, e.EmpFirstName,
    c.CustLastName, c.CustFirstName
FROM Employees e INNER JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
    INNER JOIN Customers c
    ON o.CustomerID = c.CustomerID
ORDER BY e.EmpLastName, e.EmpFirstName, c.CustLastName, c.CustFirstName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_employees_and_customers';

SELECT DISTINCT concat(employees.empfirstname, ' ', employees.emplastname) AS
    empfullname, concat(customers.custfirstname, ' ', customers.custlastname) AS
    custfullname
FROM ((employees JOIN orders
    ON ((employees.employeeid = orders.employeeid)))
    JOIN customers ON ((customers.customerid = orders.customerid)));

-- 3. Display all orders, the products in each order, and the amount owed for
-- each product, in order number sequence.
SELECT o.OrderNumber, o.OrderDate, p.ProductName, od.QuotedPrice,
    od.QuantityOrdered, (od.QuotedPrice * od.QuantityOrdered) AmountOwed
FROM Orders o INNER JOIN Order_Details od
    ON o.OrderNumber = od.OrderNumber
    INNER JOIN Products p
    ON od.ProductNumber = p.ProductNumber
ORDER BY o.OrderNumber;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_orders_with_products';

SELECT orders.ordernumber AS orderno,
    orders.orderdate,
    order_details.productnumber AS productno,
    products.productname AS product,
    order_details.quotedprice AS price,
    order_details.quantityordered AS qty,
    (order_details.quotedprice * (order_details.quantityordered)::numeric) AS
    amountowed
FROM ((orders JOIN order_details
    ON ((orders.ordernumber = order_details.ordernumber)))
    JOIN products
    ON ((products.productnumber = order_details.productnumber)))
ORDER BY orders.ordernumber;

-- 4. Show me the vendors and the products they supply to us for products that
-- cost less than $100.
SELECT v.VendName, p.ProductName, pv.WholesalePrice
FROM Vendors v INNER JOIN Product_Vendors pv
    ON v.VendorID = pv.VendorID
    INNER JOIN Products p
    ON pv.ProductNumber = p.ProductNumber
WHERE pv.WholesalePrice < 100;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_vendors_and_products_less_than_100';

SELECT vendors.vendname,
    products.productname,
    product_vendors.wholesaleprice
FROM ((vendors
    JOIN product_vendors
    ON ((vendors.vendorid = product_vendors.vendorid)))
    JOIN products
    ON ((products.productnumber = product_vendors.productnumber)))
WHERE (product_vendors.wholesaleprice < (100)::numeric);

-- 5. Show me customers and employees who have the same last name.
SELECT c.CustLastName, c.CustFirstName, e.EmpLastName, e.EmpFirstName
FROM Customers c INNER JOIN Employees e
    ON c.CustLastName = e.EmpLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_customers_employees_same_lastname';

SELECT concat(customers.custfirstname, ' ', customers.custlastname) AS
    custfullname, concat(employees.empfirstname, ' ', employees.emplastname) AS
    empfullname
FROM (customers JOIN employees
    ON (((customers.custlastname)::text = (employees.emplastname)::text)));

-- 6. Show me customers and employees who live in the same city.
SELECT c.CustCity, (c.CustLastName || ', ' || c.CustFirstName) CustFullName,
    e.EmpCity, (e.EmpLastName || ', ' || e.EmpFirstName) EmpFullName
FROM Customers c INNER JOIN Employees e
    ON c.CustCity = e.EmpCity;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch08_customers_employees_same_city';

SELECT customers.custfirstname,
    customers.custlastname,
    employees.empfirstname,
    employees.emplastname,
    employees.empcity
FROM (customers JOIN employees
    ON (((customers.custcity)::text = (employees.empcity)::text)));

/* ***** Entertainment Agency Database ***** */
-- 1. Display agents and the engagement dates they booked, sorted by booking
-- start date.
SELECT (a.AgtLastName || ', ' || a.AgtFirstName) AgtFullName,
    e.StartDate, e.EndDate
FROM Agents a INNER JOIN Engagements e
    ON a.AgentID = e.AgentID
ORDER BY e.StartDate;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch08_agents_booked_dates';

SELECT concat(agents.agtfirstname, ' ', agents.agtlastname) AS agtfullname,
    engagements.startdate
FROM (agents JOIN engagements
    ON ((agents.agentid = engagements.agentid)))
ORDER BY engagements.startdate;

-- 2. List customers and the entertainers they booked.
SELECT DISTINCT (c.CustFirstName || ' ' || c.CustLastName) CustFullName,
    ent.EntStageName
FROM entertainmentagencyexample.Customers c INNER JOIN Engagements eng
    ON c.CustomerID = eng.CustomerID
    INNER JOIN Entertainers ent
    ON eng.EntertainerID = ent.EntertainerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch08_customers_booked_entertainers';

SELECT DISTINCT concat(customers.custfirstname, ' ', customers.custlastname) AS
    custfullname, entertainers.entstagename
FROM ((entertainmentagencyexample.customers JOIN engagements
    ON ((customers.customerid = engagements.customerid)))
    JOIN entertainers
    ON ((entertainers.entertainerid = engagements.entertainerid)));

-- 3. Find the agents and entertainers who live in the same postal code.
SELECT (a.AgtFirstName || ' ' || a.AgtLastName) AgtFullName,
    ent.EntStageName, a.AgtZipCode
FROM Agents a INNER JOIN Entertainers ent
    ON a.AgtZipCode = ent.EntZipCode;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch08_agents_entertainers_same_postal';

SELECT concat(agents.agtfirstname, ' ', agents.agtlastname) AS agtfullname,
    entertainers.entstagename,
    agents.agtzipcode
FROM (agents JOIN entertainers
    ON (((agents.agtzipcode)::text = (entertainers.entzipcode)::text)));

/* ***** School Scheduling Database ******** */
-- 1. Display buildings and all the classrooms in each building.
SELECT b.BuildingName, cl.ClassRoomID
FROM Buildings b INNER JOIN class_rooms cl
    ON b.BuildingCode = cl.BuildingCode;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch08_buildings_classrooms';

SELECT buildings.buildingname,
    class_rooms.classroomid
FROM (buildings JOIN class_rooms
    ON (((buildings.buildingcode)::text = (class_rooms.buildingcode)::text)));

-- 2. List students and all the classes in which they are currently enrolled.
SELECT (s.StudLastName || ' ' || s.StudFirstName) StudFullName,
    sub.SubjectCode, sub.SubjectName
FROM Students s INNER JOIN Student_Schedules ss
    ON s.StudentID = ss.StudentID
    INNER JOIN Classes cl
    ON ss.ClassID = cl.ClassID
    INNER JOIN Subjects sub
    ON cl.SubjectID = sub.SubjectID
WHERE ss.ClassStatus = 1;

-- 3. List the faculty staff and the subject each teaches
SELECT (stf.StfFirstName || ' ' || stf.StfLastName) FacFullName,
    sub.SubjectName
FROM Faculty f INNER JOIN Staff stf
    ON f.StaffID = stf.StaffID
    INNER JOIN Faculty_Subjects f_s
    ON stf.StaffID = f_s.StaffID
    INNER JOIN Subjects sub
    ON f_s.SubjectID = sub.SubjectID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch08_staff_subjects';

SELECT concat(staff.stflastname, ', ', staff.stffirstname) AS stffullname,
    subjects.subjectname
FROM ((staff JOIN faculty_subjects
    ON ((staff.staffid = faculty_subjects.staffid)))
    JOIN subjects
    ON ((subjects.subjectid = faculty_subjects.subjectid)));

-- 4. Show me the students who have a grade of 85 or better in art and who also
-- have a grade of 85 or better in any computer course.
SELECT StudArt85.StudFullName
FROM    (SELECT DISTINCT s.StudentID,
            (s.StudLastName || ' ' || s.StudFirstName) StudFullName
        FROM Students s INNER JOIN Student_Schedules s_s
            ON s.StudentID = s_s.StudentID
            INNER JOIN Classes cl
            ON s_s.ClassID = cl.ClassID
            INNER JOIN Subjects sub
            ON cl.SubjectID = sub.SubjectID
        WHERE s_s.Grade >= 85 AND sub.CategoryID = 'ART') AS StudArt85
    INNER JOIN
        (SELECT DISTINCT s.StudentID
        FROM Students s INNER JOIN Student_Schedules s_s
            ON s.StudentID = s_s.StudentID
            INNER JOIN Classes cl
            ON s_s.ClassID = cl.ClassID
            INNER JOIN Subjects sub
            ON cl.SubjectID = sub.SubjectID
        WHERE s_s.Grade >= 85 AND (sub.CategoryID = 'CSC' OR 
                                    sub.CategoryID = 'CIS')) AS StudComp85
    ON StudArt85.StudentID = StudComp85.StudentID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch08_good_art_cs_students';

SELECT studart.studfullname
FROM (( SELECT DISTINCT students.studentid,
            concat(students.studlastname, ', ', students.studfirstname) AS
            studfullname
   FROM ((((students JOIN student_schedules
    ON ((students.studentid = student_schedules.studentid)))
    JOIN classes
    ON ((classes.classid = student_schedules.classid)))
    JOIN subjects
    ON ((subjects.subjectid = classes.subjectid)))
    JOIN schoolschedulingexample.categories
    ON (((categories.categoryid)::text = (subjects.categoryid)::text)))
          WHERE (((categories.categorydescription)::text = 'Art'::text) AND
            (student_schedules.grade >= (85)::double precision))) studart
     JOIN ( SELECT DISTINCT student_schedules.studentid
       FROM (((student_schedules
         JOIN classes
         ON ((classes.classid = student_schedules.classid)))
         JOIN subjects
         ON ((subjects.subjectid = classes.subjectid)))
         JOIN schoolschedulingexample.categories
         ON (((categories.categoryid)::text = (subjects.categoryid)::text)))
       WHERE (((categories.categorydescription)::text ~~ '%Computer%'::text)
            AND (student_schedules.grade >= (85)::double precision))) studcs
     ON ((studart.studentid = studcs.studentid)));

/* ***** Bowling League Database *********** */
-- 1. List the bowling teams and all the team members.
SELECT t.TeamName,
    (b.BowlerFirstName || ' ' || b.BowlerLastName) BowlerFullName
FROM Bowlers b INNER JOIN Teams t
    ON b.TeamID = t.TeamID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch08_teams_and_bowlers';

SELECT teams.teamname, concat(bowlers.bowlerlastname, ', ',
    bowlers.bowlerfirstname) AS bowlerfullname
FROM (teams JOIN bowlers
    ON ((teams.teamid = bowlers.teamid)));

-- 2. Display the bowlers, the matches they played in, and the bowler game
-- scores.
SELECT b_s.matchid,
    (b.BowlerFirstName || ' ' || b.BowlerLastName) BowlerFullName,
    b_s.GameNumber, b_s.RawScore
FROM Bowlers b INNER JOIN Bowler_Scores b_s
    ON b.BowlerID = b_s.BowlerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch08_bowler_game_scores';

SELECT bowler_scores.matchid,
    teams.teamname,
    concat(bowlers.bowlerfirstname, ' ', bowlers.bowlerlastname) AS
    bowlerfullname,
    bowler_scores.gamenumber,
    bowler_scores.rawscore
FROM ((teams JOIN bowlers
    ON ((teams.teamid = bowlers.teamid)))
    JOIN bowler_scores
    ON ((bowlers.bowlerid = bowler_scores.bowlerid)));

-- 3. Find the bowlers who live in the same ZIP code.
SELECT Bowlers1.BowlerFullName Bowler1,
    Bowlers2.BowlerFullName Bowler2, Bowlers2.BowlerZip
FROM (SELECT BowlerID,
        (BowlerFirstName || ' ' || BowlerLastName) BowlerFullName,
        BowlerZip
        FROM Bowlers) AS Bowlers1
INNER JOIN
    (SELECT BowlerID,
        (BowlerFirstName || ' ' || BowlerLastName) BowlerFullName,
        BowlerZip
        FROM Bowlers) AS Bowlers2
ON Bowlers1.BowlerZip = Bowlers2.BowlerZip AND
    Bowlers1.BowlerID != Bowlers2.BowlerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch08_bowlers_same_zipcode';

SELECT concat(bowlers.bowlerlastname, ', ', bowlers.bowlerfirstname) AS
    firstbowler, bowlers.bowlerzip, concat(bowlers2.bowlerlastname, ', ',
    bowlers2.bowlerfirstname) AS secondbowler
FROM (bowlers JOIN bowlers bowlers2
    ON (((bowlers.bowlerid <> bowlers2.bowlerid)
        AND ((bowlers.bowlerzip)::text = (bowlers2.bowlerzip)::text))));

/* ***** Recipes Database ****************** */
-- 1. List all the recipes for salads.
SELECT r.RecipeTitle, r_c.RecipeClassDescription
FROM Recipes r INNER JOIN Recipe_Classes r_c
    ON r.RecipeClassID = r_c.RecipeClassID
WHERE r_c.RecipeClassDescription LIKE '%Salad%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch08_salads';

SELECT recipes.recipetitle
FROM (recipes JOIN recipe_classes
    ON ((recipes.recipeclassid = recipe_classes.recipeclassid)))
    WHERE ((recipe_classes.recipeclassdescription)::text = 'Salad'::text);

-- 2. List all recipes that contain a dairy ingredient.
SELECT DISTINCT r.RecipeTitle
FROM Recipes r INNER JOIN Recipe_Ingredients r_i
    ON r.RecipeID = r_i.RecipeID
    INNER JOIN Ingredients i
    ON r_i.IngredientID = i.IngredientID
    INNER JOIN Ingredient_Classes i_c
    ON i.IngredientClassID = i_c.IngredientClassID
WHERE i_c.IngredientClassDescription LIKE '%Dairy%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch08_recipes_containing_dairy';

SELECT DISTINCT recipes.recipetitle
FROM (((recipes JOIN recipe_ingredients ON ((recipes.recipeid =
                    recipe_ingredients.recipeid)))
     JOIN ingredients ON ((ingredients.ingredientid =
            recipe_ingredients.ingredientid)))
     JOIN ingredient_classes ON ((ingredient_classes.ingredientclassid =
            ingredients.ingredientclassid)))
  WHERE ((ingredient_classes.ingredientclassdescription)::text = 'Dairy'::text);

-- 3. Find the ingredients that use the same default measurement amount.
SELECT Measurements.MeasurementDescription, Ingredients.IngredientName,
    Ingredients2.IngredientName
FROM Ingredients INNER JOIN Ingredients Ingredients2
    ON (Ingredients.IngredientID <> Ingredients2.IngredientID) AND
        (Ingredients.MeasureAmountID = Ingredients2.MeasureAmountID)
    INNER JOIN
    (SELECT *
    FROM Measurements) Measurements
    ON Ingredients.MeasureAmountID = Measurements.MeasureAmountID
ORDER BY Measurements.MeasurementDescription;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch08_ingredients_same_measure';

SELECT first_ingredient.firstingredientname,
    first_ingredient.measurementdescription,
    second_ingredient.secondingredientname
FROM (( SELECT ingredients.ingredientname AS firstingredientname,
            measurements.measurementdescription
   FROM (ingredients
    JOIN measurements ON ((ingredients.measureamountid =
            measurements.measureamountid)))) first_ingredient
     JOIN ( SELECT ingredients.ingredientname AS secondingredientname,
        measurements.measurementdescription
    FROM (ingredients
        JOIN measurements ON ((ingredients.measureamountid =
                measurements.measureamountid)))) second_ingredient ON
((((first_ingredient.firstingredientname)::text <>
            (second_ingredient.secondingredientname)::text) AND
        ((first_ingredient.measurementdescription)::text =
            (second_ingredient.measurementdescription)::text))));

-- 4. Show me the recipe sthat have beef and garlic.
SELECT BeefRecipes.RecipeTitle
FROM (SELECT r.RecipeID, r.RecipeTitle
    FROM Recipes r INNER JOIN Recipe_Ingredients r_i
        ON r.RecipeID = r_i.RecipeID
        INNER JOIN Ingredients i
        ON r_i.IngredientID = i.IngredientID
    WHERE IngredientName LIKE '%Beef%') BeefRecipes
INNER JOIN
    (SELECT r.RecipeID, r.RecipeTitle
    FROM Recipes r INNER JOIN Recipe_Ingredients r_i
        ON r.RecipeID = r_i.RecipeID
        INNER JOIN Ingredients i
        ON r_i.IngredientID = i.IngredientID
    WHERE IngredientName LIKE '%Garlic%') GarlicRecipes
ON BeefRecipes.RecipeID = GarlicRecipes.RecipeID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch08_beef_and_garlic_recipes';

 SELECT beefrecipes.recipetitle
   FROM (( SELECT recipes.recipeid,
            recipes.recipetitle
           FROM ((recipes
             JOIN recipe_ingredients ON ((recipes.recipeid =
                    recipe_ingredients.recipeid)))
             JOIN ingredients ON ((ingredients.ingredientid =
                    recipe_ingredients.ingredientid)))
          WHERE ((ingredients.ingredientname)::text = 'Beef'::text)) beefrecipes
     JOIN ( SELECT recipe_ingredients.recipeid
           FROM (recipe_ingredients
             JOIN ingredients ON ((ingredients.ingredientid =
                    recipe_ingredients.ingredientid)))
          WHERE ((ingredients.ingredientname)::text = 'Garlic'::text))
    garlicrecipes ON ((beefrecipes.recipeid = garlicrecipes.recipeid)));
