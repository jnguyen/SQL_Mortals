/* ********** SQL FOR MERE MORTALS CHAPTER 9 *********** */
/* ******** OUTER JOINS                       ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** THE LEFT/RIGHT OUTER JOIN                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
-- Show me all the recipe type and any matching recipes in my database
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle
FROM Recipe_Classes LEFT OUTER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
ORDER BY Recipe_Classes.RecipeClassDescription;

-- List the recipe classes that do not yet have any recipes.
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle
FROM Recipe_Classes LEFT OUTER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
WHERE Recipes.RecipeID IS NULL;

-- Display the recipe classes that do not yet have any recipes.
-- Note: If you use USING, the matching column is 'coalesced', meaning you
-- cannot refer to each column individually, as the columns have effectively
-- merged
SELECT Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes LEFT OUTER JOIN Recipes
    USING (RecipeClassID)
WHERE Recipes.RecipeID IS NULL;

-- Natural JOIN can also achieve the above, though it's generally not
-- advisable, for production since it assumes that the only common columns are
-- linking columns
SELECT Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes
NATURAL LEFT OUTER JOIN Recipes
WHERE Recipes.RecipeID IS NULL;


/* *** Embedding a SELECT statement             ****/
-- An embedded SELECT statement can include anything except an ORDER BY clause

/* ***** Recipes Database ****************** */
-- Get Salads, Soups, and Main courses
SELECT RCFiltered.ClassName, R.RecipeTitle
FROM 
(SELECT RC.RecipeClassID, RC.RecipeClassDescription AS ClassName
FROM Recipe_Classes RC
WHERE RecipeClassDescription = 'Salad'
    OR RecipeClassDescription = 'Soup'
    OR RecipeClassDescription = 'Main course') AS RCFiltered
    LEFT OUTER JOIN Recipes AS R
        ON RCFiltered.RecipeClassID = R.RecipeClassID;

/* *** Embedding JOINs within JOINs             ****/
-- I need all the recipe types, and then the matching recipe names, preparation
-- instructions, ingredient names, ingredient step numbers, ingredient
-- quantities, and ingredient measurements from my recipes database, sorted in
-- step number sequence.
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
    Recipes.Preparation, Ingredients.IngredientName,
    Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
    Measurements.MeasurementDescription
FROM (((Recipe_Classes LEFT OUTER JOIN Recipes
            ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
        INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
        INNER JOIN Measurements
        ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
ORDER BY RecipeTitle, RecipeSeqNo;

-- Alternate solution to above
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
    Recipes.Preparation, Ingredients.IngredientName,
    Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
    Measurements.MeasurementDescription
FROM Recipe_Classes LEFT OUTER JOIN
    (((Recipes INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
        INNER JOIN Measurements
        ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID)
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
ORDER BY RecipeTitle, RecipeSeqNo;

-- Same problem as above, except assuming some recipes don't have ingredients
-- yet
-- Warning: Only use this with a one-to-many relationship!
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
    Recipes.Preparation, Ingredients.IngredientName,
    Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
    Measurements.MeasurementDescription
FROM (((Recipe_Classes LEFT OUTER JOIN Recipes
            ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
        LEFT OUTER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
        INNER JOIN Measurements
        ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
ORDER BY RecipeTitle, RecipeSeqNo;

-- I need all the recipe types, and then all the recipe names and preparation
-- instructions, and then any matching ingredient step numbers, ingredient
-- quantities, and ingredient measurements, and finally all ingredient names
-- from my recipes database, sorted in recipe title and step number sequence.
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
    Recipes.Preparation, Ingredients.IngredientName,
    Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
    Measurements.MeasurementDescription
FROM (((Recipe_Classes LEFT OUTER JOIN Recipes
            ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
        LEFT OUTER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Measurements
        ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID)
        -- Oops! Any nulls from the LEFT are thrown out in the following JOIN
        RIGHT OUTER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
ORDER BY RecipeTitle, RecipeSeqNo;

/* ******************************************** ****/
/* *** THE FULL OUTER JOIN                      ****/
/* ******************************************** ****/
-- I need all the recipe types, and then all the recipe names and preparation
-- instructions, and then any matching ingredient step numbers, ingredient
-- quantities, and ingredient measurements, and finally all ingredient names
-- from my recipes database, sorted in recipe title and step number sequence.
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle,
    Recipes.Preparation, Ingredients.IngredientName,
    Recipe_Ingredients.RecipeSeqNo, Recipe_Ingredients.Amount,
    Measurements.MeasurementDescription
FROM (((Recipe_Classes FULL OUTER JOIN Recipes
            ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
        LEFT OUTER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
        INNER JOIN Measurements
        ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID)
        FULL OUTER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
ORDER BY RecipeTitle, RecipeSeqNo;

/* *** FULL OUTER JOIN on Non-Key Values        ****/
-- Show me all the students and all the teachers and list together those who
-- have the same first name.
SELECT (Students.StudFirstName || ' ' || Students.StudLastName) AS StudFullName,
    (Staff.StfFirstName || ' ' || Staff.StfLastName) AS StfFullName
FROM Students FULL OUTER JOIN Staff
    ON Students.StudFirstName = Staff.StfFirstName;

/* *** UNION JOIN                               ****/
-- A UNION JOIN is a FULL OUTER JOIN with matching rows removed

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Which products have never been ordered?
SELECT p.ProductNumber, p.ProductName
FROM Products p LEFT OUTER JOIN Order_Details o_d
    ON p.ProductNumber = o_d.ProductNumber
WHERE o_d.OrderNumber IS NULL;

-- Display all customers and any orders for bicycles.
SELECT (CustLastName || ' ' || CustFirstName) CustFullName,
    RD.OrderDate, RD.ProductName, RD.QuantityOrdered, RD.QuotedPrice
FROM Customers LEFT OUTER JOIN
    -- Temp table of all bike orders
    (SELECT Orders.CustomerID, Orders.OrderDate, Products.ProductName,
    Order_Details.QuantityOrdered,
    Order_Details.QuotedPrice
    FROM ((Orders INNER JOIN Order_Details
        ON Orders.OrderNumber = Order_Details.OrderNumber)
        INNER JOIN Products
        ON Order_Details.ProductNumber = Products.ProductNumber)
        INNER JOIN Categories
        ON Categories.CategoryID = Products.CategoryID
    WHERE Categories.CategoryDescription = 'Bikes') AS RD
ON Customers.CustomerID = RD.CustomerID;

/* ***** Entertainment Agency Database ***** */
-- List entertainers who have never been booked.
SELECT Entertainers.EntertainerID, Entertainers.EntStageName
FROM Entertainers LEFT OUTER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID
WHERE Engagements.EngagementNumber IS NULL;

-- Show me all the musical styles and customers who prefer those styles.
SELECT Musical_Styles.StyleID, Musical_Styles.StyleName,
    Customers.CustFirstName, Customers.CustLastName
FROM Musical_Styles LEFT OUTER JOIN
    -- Table of customers and their musical preferences
    (Musical_Preferences INNER JOIN entertainmentagencyexample.Customers
        ON Musical_Preferences.CustomerID = Customers.CustomerID)
    ON Musical_Styles.StyleID = Musical_Preferences.StyleID
ORDER BY Musical_Styles.StyleID;

/* ***** School Scheduling Database ******** */
-- List the faculty members not teaching a class.
SELECT Staff.StfLastName, Staff.StfFirstName, Staff.Position
FROM (Faculty INNER JOIN Staff
    ON Faculty.StaffID = Staff.StaffID)
    LEFT OUTER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
WHERE Faculty_Classes.ClassID IS NULL;

-- Display students who have never withdrawn from a class.
SELECT Students.StudLastName || ', ' || Students.StudFirstName AS StudFullName
FROM Students LEFT OUTER JOIN
    -- Table of all student IDs with a withdrawn class
    (SELECT Student_Schedules.StudentID
    FROM Student_Class_Status INNER JOIN Student_Schedules
    ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Withdrew') AS Withdrew
ON Students.StudentID = Withdrew.StudentID
WHERE Withdrew.StudentID IS NULL;

-- Show me all subject categories and any classes for all subjects.
SELECT Categories.CategoryID, Categories.CategoryDescription,
    Subjects.SubjectName, Classes.ClassRoomID, Classes.StartDate,
    Classes.StartTime, Classes.Duration
FROM (schoolschedulingexample.Categories LEFT OUTER JOIN Subjects
    ON Categories.CategoryID = Subjects.CategoryID)
    LEFT OUTER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID;

/* ***** Bowling League Database *********** */
-- Show me tournaments that haven't been played yet.
SELECT Tournaments.TourneyID, Tournaments.TourneyDate,
	Tournaments.TourneyLocation
FROM Tournaments LEFT OUTER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID
WHERE Tourney_Matches.MatchID IS NULL;

-- List all bowlers and any games they bowled over 180.
SELECT Bowlers.BowlerLastName, Bowlers.BowlerFirstName,
    Over180.TourneyDate, Over180.TourneyLocation,
    Over180.MatchID, Over180.GameNumber, Over180.RawScore
FROM Bowlers LEFT OUTER JOIN
    (SELECT 
        Tournaments.TourneyDate,
        Tournaments.TourneyLocation,
        Bowler_Scores.MatchID,
        Bowler_Scores.GameNumber,
        Bowler_Scores.BowlerID,
        Bowler_Scores.RawScore
    FROM (Bowler_Scores INNER JOIN Tourney_Matches
        ON Bowler_Scores.MatchID = Tourney_Matches.MatchID)
        INNER JOIN Tournaments
        ON Tournaments.TourneyID = Tourney_Matches.TourneyID
    WHERE Bowler_Scores.RawScore > 180) AS Over180
ON Bowlers.BowlerID = Over180.BowlerID;

/* ***** Recipes Database ****************** */
-- List ingredients not used in any recipe yet.
SELECT Ingredients.IngredientName
FROM Ingredients
LEFT OUTER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipe_Ingredients.RecipeID IS NULL;

-- I need all the recipe types, and then all the recipe names, and then any
-- matching ingredient step numbers, ingredient quantities, and ingredient
-- measurements, and finally all ingredient names from my recipes database,
-- sorted by recipe class description in descending order, then by recipe title
-- and recipe sequence number.
SELECT recipe_classes.recipeclassdescription,
    recipes.recipetitle,
    ingredients.ingredientname,
    recipe_ingredients.recipeseqno,
    recipe_ingredients.amount,
    measurements.measurementdescription
FROM ((((recipes
     LEFT JOIN recipe_ingredients ON ((recipes.recipeid =
            recipe_ingredients.recipeid)))
     JOIN measurements ON ((measurements.measureamountid =
            recipe_ingredients.measureamountid)))
     FULL JOIN ingredients ON ((ingredients.ingredientid =
            recipe_ingredients.ingredientid)))
     FULL JOIN recipe_classes ON ((recipes.recipeclassid =
            recipe_classes.recipeclassid)))
  ORDER BY recipe_classes.recipeclassdescription DESC, recipes.recipetitle,
recipe_ingredients.recipeseqno;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Show me customers who never ordered a helmet.
-- (Hint: This is another request where you must first build an INNER JOIN to
-- find all orders containing helmets and then do an OUTER JOIN with
-- customers
-- Note: DISTINCT is not here because you should only have one NULL row per
-- Customere that never ordered a helmet
SELECT Customers.CustLastName, Customers.CustFirstName,
    Bikes.OrderNumber
FROM (SELECT o.CustomerID, o_d.OrderNumber, o_d.ProductNumber, p.ProductName
    FROM Orders o INNER JOIN Order_Details o_d 
        ON o.OrderNumber = o_d.OrderNumber
    INNER JOIN Products p
        ON o_d.ProductNumber = p.ProductNumber
    WHERE p.ProductName LIKE '%Helmet%') Bikes
RIGHT OUTER JOIN
    Customers
ON Bikes.CustomerID = Customers.CustomerID
WHERE Bikes.OrderNumber IS NULL;

-- 2. Display customers who have no sales rep (employees) in the same ZIP code.
-- Idea: Outer join on zip code, and select any customers who have missing
-- employeeid rows
-- Note: Using SELECT Table.* selects everything from Table only
SELECT Customers.CustLastName, Customers.CustFirstName, Employees.*
FROM Customers LEFT OUTER JOIN Employees
    ON Customers.CustZipCode = Employees.EmpZipCode
WHERE Employees.EmployeeID IS NULL;

-- 3. List all products and the dates for any orders.
-- Note: Not all products will have orders, so we use an OUTER JOIN here
SELECT DISTINCT p.ProductNumber, p.ProductName, o.OrderDate
FROM Products p LEFT OUTER JOIN Order_Details o_d
    ON p.ProductNumber = o_d.ProductNumber
    LEFT OUTER JOIN Orders o
    ON o_d.OrderNumber = o.OrderNumber
WHERE o.OrderNumber IS NULL
ORDER BY p.ProductNumber;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch09_all_products_any_order_dates';
 SELECT products.productnumber,
    products.productname,
    od.orderdate
   FROM (products
     LEFT JOIN ( SELECT DISTINCT order_details.productnumber,
            orders.orderdate
           FROM (orders
             JOIN order_details ON ((orders.ordernumber =
                    order_details.ordernumber)))) od ON ((products.productnumber
            = od.productnumber)));

/* ***** Entertainment Agency Database ***** */
-- 1. Display agents who haven't booked an entertainer.
SELECT Agents.AgtLastName, Agents.AgtFirstName
FROM Agents LEFT OUTER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
WHERE Engagements.AgentID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch09_agents_no_contracts';

SELECT agents.agentid,
agents.agtfirstname,
agents.agtlastname
FROM (agents
    LEFT JOIN engagements ON ((agents.agentid = engagements.agentid)))
WHERE (engagements.engagementnumber IS NULL);

-- 2. List customers with no bookings.
SELECT Customers.CustomerID, Customers.CustLastName, Customers.CustFirstName
FROM entertainmentagencyexample.Customers LEFT OUTER JOIN Engagements
    ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.EngagementNumber IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch09_customers_no_bookings';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname
   FROM (entertainmentagencyexample.customers
     LEFT JOIN engagements ON ((customers.customerid = engagements.customerid)))
  WHERE (engagements.engagementnumber IS NULL);

-- 3. List all entertainers and any engagements they have booked.
SELECT Entertainers.EntStageName, Engagements.*
FROM Entertainers LEFT OUTER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements.EntertainerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch09_all_entertainers_and_any_engagements';

SELECT entertainers.entertainerid,
    entertainers.entstagename,
    engagements.engagementnumber,
    engagements.startdate,
    engagements.customerid
FROM (entertainers
    LEFT JOIN engagements
    ON ((entertainers.entertainerid = engagements.entertainerid)));

/* ***** School Scheduling Database ******** */
-- 1. Show me classes that have no students enrolled.
SELECT Subjects.SubjectName, Enrolled.ClassRoomID,
    Enrolled.Duration, Enrolled.StartTime
FROM Subjects INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
    LEFT OUTER JOIN
        (SELECT Student_Schedules.ClassID
        FROM Student_Schedules INNER JOIN Student_Class_Status
            ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
        WHERE Student_Class_Status.ClassStatusDescription = 'Enrolled') Enrolled
    ON Classes.ClassID = Enrolled.ClassID
WHERE Enrolled.ClassID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch09_classes_no_students_enrolled';

SELECT subjects.subjectname,
   classes.classroomid,
   classes.starttime,
   classes.duration
FROM ((subjects
    JOIN classes ON ((subjects.subjectid = classes.subjectid)))
    LEFT JOIN ( SELECT student_schedules.classid
          FROM (student_class_status
            JOIN student_schedules ON ((student_class_status.classstatus =
                    student_schedules.classstatus)))
         WHERE ((student_class_status.classstatusdescription)::text =
            'Enrolled'::text)) enrolled ON ((classes.classid =
            enrolled.classid)))
WHERE (enrolled.classid IS NULL);

-- 2. Display subjects with no faculty assigned.
SELECT Subjects.SubjectCode, Subjects.SubjectName
FROM Subjects LEFT OUTER JOIN Faculty_Subjects
    ON Subjects.SubjectID = Faculty_Subjects.SubjectID
WHERE Faculty_Subjects.SubjectID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch09_subjects_no_faculty';

SELECT subjects.subjectid,
    subjects.subjectcode,
    subjects.subjectname
   FROM (subjects
     LEFT JOIN faculty_subjects ON ((subjects.subjectid =
            faculty_subjects.subjectid)))
  WHERE (faculty_subjects.staffid IS NULL);
-- 3. List students not currently enrolled in any classes. 2
SELECT Students.StudLastName, Students.StudFirstName
FROM Students LEFT OUTER JOIN
    (SELECT Student_Schedules.StudentID
    FROM Student_Class_Status INNER JOIN Student_Schedules
    ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
    WHERE Student_Class_Status.ClassStatusDescription = 'Enrolled') Enrolled
    ON Students.StudentID = Enrolled.StudentID
WHERE Enrolled.StudentID IS NULL;

-- 4. Display all faculty and the classes they are scheduled to teach. 135
SELECT s.StfLastName, s.StfFirstName,
    sched.SubjectName,
    sched.ClassID,
    sched.ClassRoomID,
    sched.StartTime,
    sched.Duration
FROM (Staff s
    LEFT OUTER JOIN ( SELECT Faculty_Classes.StaffID,
                Subjects.SubjectName,
                Classes.ClassID,
                Classes.ClassRoomID,
                Classes.StartTime,
                Classes.Duration
                FROM Subjects JOIN Classes
                    ON Subjects.SubjectID = Classes.SubjectID
                    JOIN Faculty_Classes
                    ON Classes.ClassID = Faculty_Classes.ClassID ) sched
    ON s.StaffID = sched.StaffID);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch09_all_faculty_and_any_classes';

SELECT concat(staff.stflastname, ', ', staff.stffirstname) AS staffname,
   sched.subjectname,
   sched.classid,
   sched.classroomid,
   sched.starttime,
   sched.duration
FROM (staff
    LEFT JOIN ( SELECT faculty_classes.staffid,
           subjects.subjectname,
           classes.classid,
           classes.classroomid,
           classes.starttime,
           classes.duration
          FROM (subjects
            JOIN (classes
            JOIN faculty_classes ON ((classes.classid =
                    faculty_classes.classid))) ON ((subjects.subjectid =
                classes.subjectid)))) sched ON ((staff.staffid =
        sched.staffid)));

/* ***** Bowling League Database *********** */
-- 1. Display matches with no game data. 1
SELECT t_m.*
FROM Tourney_Matches t_m LEFT OUTER JOIN Match_Games m_g
    ON t_m.MatchID = m_g.MatchID
WHERE m_g.MatchID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch09_matches_not_played_yet';

SELECT tourney_matches.matchid,
   tourney_matches.tourneyid,
   teams.teamname AS oddlaneteam,
   teams_1.teamname AS evenlaneteam
  FROM (teams teams_1 JOIN
        (teams
        JOIN (tourney_matches
            LEFT JOIN match_games
            ON ((tourney_matches.matchid = match_games.matchid)))
        ON ((teams.teamid = tourney_matches.oddlaneteamid)))
    ON ((teams_1.teamid = tourney_matches.evenlaneteamid)))
 WHERE (match_games.matchid IS NULL);

-- 2. Display all tournaments and any matches that have been played. 174
SELECT t.TourneyDate, t.TourneyLocation, Games.*
FROM Tournaments t LEFT OUTER JOIN
    ( SELECT t_m.*, m_g.GameNumber, m_g.WinningTeamID 
    FROM Tourney_Matches t_m INNER JOIN Match_Games m_g
        ON t_m.MatchID = m_g.MatchID ) Games
    ON t.TourneyID = Games.TourneyID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch09_all_tourneys_match_results';

 SELECT tournaments.tourneyid,
    tournaments.tourneydate,
    tournaments.tourneylocation,
    tm.matchid,
    tm.gamenumber,
    tm.winner
   FROM (tournaments
     LEFT JOIN ( SELECT tourney_matches.tourneyid,
            tourney_matches.matchid,
            match_games.gamenumber,
            teams.teamname AS winner
           FROM (tourney_matches
             JOIN (teams
             JOIN match_games ON ((teams.teamid = match_games.winningteamid)))
        ON ((tourney_matches.matchid = match_games.matchid)))) tm ON
        ((tournaments.tourneyid = tm.tourneyid)))
  ORDER BY tournaments.tourneyid;

/* ***** Recipes Database ****************** */

-- 1. Display missing types of recipes. 1
SELECT r_c.*
FROM Recipe_Classes r_c LEFT OUTER JOIN Recipes r
    ON r_c.RecipeClassID = r.RecipeClassID
WHERE r.RecipeClassID IS NULL;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch09_recipe_classes_no_recipes';

SELECT recipe_classes.recipeclassdescription
FROM (recipe_classes
    LEFT JOIN recipes ON ((recipe_classes.recipeclassid =
            recipes.recipeclassid)))
WHERE (recipes.recipeid IS NULL);

-- 2. Show me all ingredients and any recipes they're used in. 108
SELECT i.IngredientName, RecipeTitle
FROM Ingredients i LEFT OUTER JOIN 
    (SELECT Recipe_Ingredients.IngredientID, Recipes.RecipeTitle
    FROM Recipes INNER JOIN Recipe_Ingredients
        ON Recipes.RecipeID = Recipe_Ingredients.RecipeID) RecipeIngreds
    ON i.IngredientID = RecipeIngreds.IngredientID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch09_all_ingredients_any_recipes';

SELECT ingredients.ingredientname,
   r.recipeid,
   r.recipetitle
  FROM (ingredients
    LEFT JOIN ( SELECT DISTINCT recipes.recipeid,
           recipes.recipetitle,
           recipe_ingredients.ingredientid
          FROM (recipes
            JOIN recipe_ingredients ON ((recipes.recipeid =
                    recipe_ingredients.recipeid)))) r ON
    ((ingredients.ingredientid = r.ingredientid)));

-- 3. List the salad, soup, and main course categories and any recipes. 9
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle
FROM Recipe_Classes LEFT OUTER JOIN Recipes
    ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
    WHERE Recipe_Classes.RecipeClassDescription SIMILAR TO 
        'Main course|Soup|Salad';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch09_salad_soup_main_courses';

SELECT rcfiltered.classname,
   r.recipetitle
  FROM (( SELECT rc.recipeclassid,
           rc.recipeclassdescription AS classname
          FROM recipe_classes rc
         WHERE (((rc.recipeclassdescription)::text = 'Salad'::text) OR
           ((rc.recipeclassdescription)::text = 'Soup'::text) OR
           ((rc.recipeclassdescription)::text = 'Main course'::text)))
   rcfiltered
LEFT JOIN recipes r ON ((rcfiltered.recipeclassid = r.recipeclassid)));

-- 4. Display all recipe classes and any recipes. 16
SELECT r_c.RecipeClassDescription, r.RecipeTitle
FROM Recipe_Classes r_c LEFT OUTER JOIN Recipes r
    ON r_c.RecipeClassID = r.RecipeClassID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch09_all_recipeclasses_and_matching_recipes';

SELECT recipe_classes.recipeclassdescription,
   recipes.recipetitle
  FROM (recipe_classes
    LEFT JOIN recipes ON ((recipe_classes.recipeclassid =
            recipes.recipeclassid)));
