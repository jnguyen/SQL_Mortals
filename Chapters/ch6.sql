/* ********** SQL FOR MERE MORTALS CHAPTER 6 *********** */
/* ******** Filtering Your Data               ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Defining Search Conditions               ****/
/* ******************************************** ****/
-- One way to get names that start with B using BETWEEN:
-- Note: While unlikely, there's probably no one that has a last name starting
-- with 'Bz', so this is probably fine. Still, it's better to use LIKE "B%"
SELECT StudLastName, StudFirstName, StudPhoneNumber
FROM Students
WHERE StudLastName BETWEEN 'B' AND 'Bz';

-- You can search for a value defined by a BETWEEN range, e.g. a date!
SELECT EngagementNumber, StartDate, EndDate
FROM engagements
WHERE '2017-10-10' BETWEEN StartDate AND EndDate;

-- The IN operator is useful to access set membership
-- E.g. I need to know which bowling lanes sponsored tournaments for the following
-- 2017 dates: September 18, October 9, November 6
SELECT TourneyLocation
FROM Tournaments
WHERE TourneyDate IN ('2017-09-18', '2017-10-09', '2017-11-06');

-- Ex. Which entertainers do we represent in Seattle, Redmond, and Bothell?
SELECT EntStageName
FROM Entertainers
WHERE EntCity IN ('Seattle', 'Redmond', 'Bothell');

-- Use the ESCAPE keyword to define escape chars when using pattern matching
-- Ex. Show me a list of products that have product codes beginning with 'G_00'
-- and ending in a single number or letter. 
-- Note: This doesn't work on the example databases
-- SELECT ProductName, ProductCode
-- FROM Products
-- WHERE ProductCode LIKE 'G\_00_' ESCAPE '\';

-- Recall: NULL values suck >_<. Use IS NULL to find them.
-- Note: This doesn't work on the example database
-- SELECT CustFirstName || ' ' || CustLastName AS Customer
-- FROM Customers
-- WHERE CustCounty IS NULL;

-- The NOT keyword is useful to negate BETWEEN, IN, LIKE, and IS NULL
SELECT OrderNumber, OrderDate
FROM Orders
WHERE OrderDate NOT BETWEEN '2017-10-01' AND '2017-10-31';

-- Ex. Find IDs of all staff who are not professors or associate professors
SELECT StaffID, Title
FROM faculty
WHERE title NOT IN ('Professor', 'Associate Professor');

-- Use AND and OR to combine logical statements
-- Ex. Find customers with last name 'H' based in Seattle
-- Note: This returns zero rows in the example tables
SELECT CustFirstName, CustLastName
FROM customers
WHERE CustCity = 'Seattle' AND CustLastName LIKE 'H%';

-- Ex. Staff members with 425 area code and phone number beginning with 555,
-- along with anyone hired between Oct 1, 2017 and Dec 31, 2017
-- Note: SQL Standard and many DBs give AND precedence over OR and process left
-- to right
SELECT (StfLastName || ' ' || StfFirstName) AS staff,
    ('(' || StfAreaCode || ') ' || StfPhoneNumber) AS StfPhone, DateHired
FROM staff
WHERE (StfAreaCode = '425' AND StfPhoneNumber LIKE '555%') OR
    DateHired BETWEEN '2017-10-01' AND '2017-12-31';

-- You can put a NOT statement after a WHERE statement to negate the search
-- condition
-- Ex. Show me the bowlers who live outside of Bellevue
SELECT BowlerFirstName, BowlerLastName, BowlerCity
FROM bowlers
WHERE NOT BowlerCity = 'Bellevue';

-- If you include two NOT statements, it produces a double negative, or a
-- positive, instead of a warning.
-- Note: This returns no rows because no one has those positions
SELECT StfFirstName, StfLastName, Position
FROM staff
WHERE NOT Position NOT IN ('Teacher', 'Teacher''s Aide');

-- WHERE statements are read left to right, so order generally determines how
-- the search will be carried out.
SELECT CustomerID, OrderDate, ShipDate
FROM Orders
WHERE ShipDate = OrderDate
    AND CustomerID = 1001;

-- Precedence: Arithmetic, Comparisons, NOT, AND. OR
SELECT CustomerID, OrderDate, ShipDate
FROM orders
WHERE CustomerID = 1001 OR ShipDate = OrderDate + 4;

-- Tip: Include only columns you need to fulfill the query, and make the search
-- condition as specific as you can to process the fewest rows possible. In
-- general, you want to put the search condition that excludes the most rows
-- first, as this will improve query efficiency.
-- Ex. This will look at order dates first. In a larger DB, this may be slow!
SELECT CustomerID, OrderDate, ShipDate
FROM orders
WHERE ShipDate = OrderDate AND CustomerID = 1001;

-- Ex. Switching the order is probably faster, because CustomerID is unique
-- thanks to being a primary key. In PostGre, I got 2x as fast!
SELECT CustomerID, OrderDate, ShipDate
FROM orders
WHERE CustomerID = 1001 AND ShipDate = OrderDate;

-- Think about your queries carefully, and you can come up with cool solutions.
-- Ex. Find all engagements that occur between '2017-11-12' and '2017-11-18'
SELECT EngagementNumber, StartDate, EndDate
FROM engagements
WHERE StartDate <= '2017-11-18' AND EndDate >= '2017-11-12';


/* ******************************************** ****/
/* *** Nulls Revisited: A Cautionary Note       ****/
/* ******************************************** ****/
-- Caution: A predicate that evaluates a NULL is never true or false! Instead,
-- they are evaluated to 'Unknown'
-- * True AND Unknown = Unknown
-- * False AND Unknown = False
-- * True OR Unknown = True
-- * False OR Unknown = Unknown

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Show me all the orders for customer number 1001.
SELECT CustomerID, OrderNumber, OrderDate
FROM Orders
WHERE CustomerID = 1001;

-- Show me an alphabetized list of products with names that begin with 'Dog'.
SELECT ProductName
FROM Products
WHERE ProductName LIKE 'Dog%'
ORDER BY ProductName;

/* ***** Entertainment Agency Database ***** */
-- Show me an alphabetical list of entertainers based in Bellevue, Redmond, or
-- Woodinville.
SELECT EntStageName, EntPhoneNumber, EntCity
FROM Entertainers
WHERE EntCity IN ('Bellevue', 'Redmond', 'Woodinville')
ORDER BY EntStageName;

-- Show me all the engagements that run for four days.
SELECT EngagementNumber, StartDate, EndDate,
    (EndDate - StartDate + 1) AS EngagementDays
FROM Engagements
WHERE (EndDate - StartDate + 1) = 4;

/* ***** School Scheduling Database ******** */
-- Show me an alphabetical list of all the staff members and their salaries if
-- they make between $40,000 and $50,000 a year.
SELECT StfLastName, StfFirstName, Salary
FROM Staff
WHERE Salary BETWEEN 40000 AND 50000
ORDER BY StfLastName, StfFirstName;

-- Show me a list of students whose last name is 'Kennedy' or who live in
-- Seattle.
SELECT StudLastName, StudFirstName, StudCity
FROM Students
WHERE StudLastName = 'Kennedy' OR StudCity = 'Seattle';

/* ***** Bowling League Database *********** */
-- List the ID numbers of the teams that won one or more of the first ten
-- matches in Game 3.
SELECT WinningTeamID, MatchID, GameNumber
FROM Match_Games
WHERE GameNumber = 3 AND MatchID BETWEEN 1 AND 10;

-- List the bowlers in teams 3, 4, and 5 whose last names begin with the letter
-- 'H'.
SELECT BowlerLastName, BowlerFirstName, TeamID
FROM Bowlers
WHERE BowlerLastName LIKE 'H%' AND TeamID BETWEEN 3 AND 5
ORDER BY BowlerLastName, BowlerFirstName;

/* ***** Recipes Database ****************** */
-- List the recipes that have no notes
-- Note: (Notes <> '') IS NOT TRUE is equivalent to (Notes = '') IS NOT FALSE
-- and basically checks that the text field Notes is neither NULL nor FALSE,
-- i.e. searches for NULL or empty fields. Works for any char type.
SELECT RecipeTitle, Notes
FROM Recipes
WHERE (Notes <> '') IS NOT TRUE;

-- Show the ingredients that are meats (ingredient class is 2) but that aren't
-- chicken.
SELECT IngredientName, IngredientClassID
FROM Ingredients
WHERE IngredientClassID = 2 AND IngredientName NOT LIKE 'Chicken%';

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- 1. Give me the names of all vendors based in Ballard, Bellevue, and Redmond.
SELECT VendName, VendCity
FROM Vendors
WHERE VendCity IN ('Ballard', 'Bellevue', 'Redmond');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch06_ballard_bellevue_redmond_vendors';

SELECT vendors.vendname,
    vendors.vendcity
FROM vendors
WHERE ((vendors.vendcity)::text = ANY ((ARRAY['Ballard'::character varying,
            'Bellevue'::character varying, 'Redmond'::character
            varying])::text[]))
ORDER BY vendors.vendname;

-- 2. Show me an alphabetized list of products with a retail price of $125.00 or
-- more.
SELECT ProductName, RetailPrice
FROM Products
WHERE RetailPrice >= 125
ORDER BY ProductName, RetailPrice;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch06_products_priced_over_125';

SELECT products.productname,
    products.retailprice
FROM products
WHERE (products.retailprice >= (125)::numeric)
ORDER BY products.productname;

-- 3. Which vendors do we work with that don't have a Web site?
SELECT VendorID, VendName, VendWebPage
FROM Vendors
WHERE (VendWebPage <> '') IS NOT TRUE;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch06_vendors_with_no_website';

SELECT vendors.vendname,
    vendors.vendwebpage
FROM vendors
WHERE (vendors.vendwebpage IS NULL)
ORDER BY vendors.vendname;

/* ***** Entertainment Agency Database ***** */
-- 1. Let me see a list of all engagements that occurred during October 2017.
-- (Hint: You need to solve this problem by testing for values in a range in the
-- table that contain any values in another range--the first and last dates
-- in October.)
SELECT EngagementNumber, StartDate, EndDate
FROM Engagements
WHERE ((StartDate BETWEEN '2017-10-01' AND '2017-10-31') AND
    EndDate < '2017-11-01')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch06_october_2017_engagements';

SELECT engagements.engagementnumber,
    engagements.contractprice,
    engagements.startdate,
    engagements.enddate
FROM engagements
WHERE ((engagements.startdate <= '2017-10-31'::date) AND (engagements.enddate >=
        '2017-10-01'::date));

-- 2. Show me any engagements in October 2017 that start between noon and 5pm.
SELECT EngagementNumber, StartDate, EndDate, StartTime, StopTime
FROM Engagements
WHERE (StartDate BETWEEN '2017-10-01' AND '2017-10-31') AND
    (EndDate < '2017-11-01') AND
    (StartTime BETWEEN '12:00:00' AND '17:00:00')

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch06_october_dates_between_noon_and_five';

SELECT engagements.engagementnumber,
    engagements.startdate,
    engagements.starttime
FROM engagements
WHERE ((engagements.startdate <= '2017-10-31'::date) AND (engagements.enddate >=
        '2017-10-01'::date) AND ((engagements.starttime >= '12:00:00'::time
            without time zone) AND (engagements.starttime <= '17:00:00'::time
            without time zone)));

-- 3. List all the engagements that start and end on the same day.
SELECT EngagementNumber, StartDate, EndDate
FROM Engagements
WHERE StartDate = EndDate;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch06_single_day_engagements';

SELECT engagements.engagementnumber,
    engagements.startdate,
    engagements.enddate
FROM engagements
WHERE (engagements.startdate = engagements.enddate);

/* ***** School Scheduling Database ******** */
-- 1. Show me which staff members use a post office box as their address.
SELECT StfLastName, StfFirstName, StfStreetAddress
FROM staff
WHERE StfStreetAddress LIKE '%Box%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch06_staff_using_poboxes';

SELECT staff.stffirstname,
    staff.stflastname,
    staff.stfstreetaddress
FROM staff
WHERE ((staff.stfstreetaddress)::text ~~ '%Box%'::text) /* ~~ means LIKE */
ORDER BY staff.stffirstname, staff.stflastname;

-- 2. Can you show me which students live outside of the Pacific Northwest?
SELECT StudLastName, StudFirstName, StudState
FROM Students
WHERE StudState NOT IN ('WA', 'OR', 'ID', 'WY', 'MT'); /* Def from google */

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch06_students_residing_outside_pnw';

SELECT concat(students.studlastname, ', ', students.studfirstname) AS
    studentname,
    students.studareacode,
    students.studphonenumber,
    students.studstate
FROM students
WHERE ((students.studstate)::text <> ALL ((ARRAY['ID'::character varying,
            'OR'::character varying, 'WA'::character varying])::text[]));

-- 3. List all subjects that have a subject code starting 'MUS.'
SELECT SubjectID, SubjectCode, SubjectName
FROM Subjects
WHERE SubjectCode LIKE 'MUS%';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch06_subjects_with_mus_in_subjectcode';

SELECT subjects.subjectname,
    subjects.subjectdescription,
    subjects.subjectcode
FROM subjects
WHERE ((subjects.subjectcode)::text ~~ 'MUS%'::text);

-- 4. Produce a list of the ID numbers all the Associate Professors who are
-- employed full time.
SELECT StaffID, Title, Status
FROM Faculty
WHERE Title = 'Associate Professor' AND Status = 'Full Time';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch06_full_time_associate_professors';

SELECT faculty.staffid,
    faculty.title,
    faculty.status
FROM faculty
WHERE (((faculty.title)::text = 'Associate Professor'::text) AND
    ((faculty.status)::text = 'Full Time'::text));

/* ***** Bowling League Database *********** */
-- 1. Give me a list of the tournaments held during September 2017
SELECT TourneyDate, TourneyLocation
FROM Tournaments
WHERE TourneyDate BETWEEN '2017-09-01' AND '2017-09-30';

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch06_september_2017_tournament_schedule';

SELECT tournaments.tourneydate,
    tournaments.tourneylocation
FROM tournaments
WHERE ((tournaments.tourneydate >= '2017-09-01'::date) AND
    (tournaments.tourneydate <= '2017-09-30'::date));

-- 2. What are the tournament schedules for Bolero, Red Rooster, and Thunderbird
-- Lanes?
SELECT TourneyDate, TourneyLocation
FROM Tournaments
WHERE TourneyLocation SIMILAR TO 'Bolero%|Red%|Thunderbird%'
ORDER BY TourneyLocation;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch06_eastside_tournaments';

SELECT tournaments.tourneylocation,
    tournaments.tourneydate
FROM tournaments
WHERE ((tournaments.tourneylocation)::text = ANY ((ARRAY['Red Rooster
            Lanes'::character varying, 'Thunderbird Lanes'::character varying,
            'Bolero Lanes'::character varying])::text[]))
ORDER BY tournaments.tourneylocation, tournaments.tourneydate;

-- 3. List the bowlers who live on the Eastside (you know--Bellevue, Bothell,
-- Duvall, Redmond, and Woodinville) and who are on teams 5, 6, 7, or 8.
-- (Hint: Use IN for the city list and BETWEEN for the team members.)
SELECT TeamID, BowlerLastName, BowlerFirstName, BowlerCity
FROM Bowlers
WHERE (TeamID BETWEEN 5 AND 8) AND
    (BowlerCity IN ('Bellevue', 'Bothell', 'Duvall', 'Redmond', 'Woodinville'));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch06_eastside_bowlers_on_teams_5_through_8';

SELECT bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    bowlers.bowlercity,
    bowlers.teamid
FROM bowlers
WHERE (((bowlers.bowlercity)::text = ANY ((ARRAY['Bellevue'::character varying,
                'Bothell'::character varying, 'Duvall'::character varying,
                'Redmond'::character varying, 'Woodinville'::character
                varying])::text[])) AND ((bowlers.teamid >= 5) AND
        (bowlers.teamid <= 8)))
ORDER BY bowlers.bowlercity, bowlers.bowlerlastname;

/* ***** Recipes Database ****************** */
-- 1. List all recipes that are main courses (recipe class is 1) and that have
-- notes.
SELECT RecipeClassID, RecipeID, RecipeTitle, Notes
FROM Recipes
WHERE (RecipeClassID = 1) AND 
    (Notes > '');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch06_main_courses_with_notes';

SELECT recipes.recipetitle,
    recipes.preparation,
    recipes.notes
FROM recipes
WHERE ((recipes.recipeclassid = 1) AND (recipes.notes IS NOT NULL));

-- 2. Display the first five recipes.
/* PostGres or MySQL */
SELECT RecipeID, RecipeTitle, Notes
FROM Recipes
ORDER BY RecipeID
LIMIT 5;

/* ANSI SQL */
SELECT RecipeID, RecipeTitle, Notes
FROM Recipes
WHERE RecipeID BETWEEN 1 AND 5;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch06_first_5_recipes';

SELECT recipes.recipeid,
    recipes.recipetitle,
    recipes.preparation,
    recipes.notes
FROM recipes
WHERE ((recipes.recipeid >= 1) AND (recipes.recipeid <= 5));
