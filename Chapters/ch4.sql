/* ********** SQL FOR MERE MORTALS CHAPTER 4 *********** */
/* ************ CREATING A SIMPLE QUERY              *** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ****** Sales Orders Database ************ */
-- Select a specific schema
SHOW search_path;
SET search_path = salesordersexample, "$user", public;

-- Show me the names of all our vendors.
SELECT VendName
FROM vendors;

-- What are the names and prices of all products we carry?
SELECT ProductName, RetailPrice
FROM products;

-- Which states do our customers come from?
SELECT DISTINCT CustState
FROM Customers;

-- List all entertainers and the cities they're based in, 
-- and sort the results by city and name in ascending order.
/* *** Entertainment Agency Database ******* */
SET search_path = entertainmentagencyexample, "$user", public;

-- List all entertainers and the cities they're based in, and sort 
-- the results by city and name in ascending order.
SELECT EntStageName, EntCity
FROM entertainers
ORDER BY EntCity ASC, EntStageName ASC;

-- Give me a unique list of engagement dates. I'm not concerned with
-- how many engagements there are per date.
SELECT DISTINCT startdate
FROM engagements;

/* ***** School Scheduling Database ******** */
SET search_path = schoolschedulingexample, "$user", public;

-- Get schema names
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name LIKE '%school%';

-- Get table names in schoolschedulingexample
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'schoolschedulingexample';

-- Can we view complete class information?
SELECT *
FROM classes;

-- Give me a list of the buildings on campus and the number of
-- floors for each building. Sort the list by building in 
-- ascending order. 
SELECT BuildingName, NumberOfFloors
FROM buildings
ORDER BY buildings ASC;

/* ***** Bowling League Database *********** */
SET search_path = bowlingleagueexample, "$user", public;

-- Where are we holding our tournaments?
SELECT DISTINCT TourneyLocation
FROM Tournaments;

-- Give me a list of all tournament dates and locations. I need the
-- dates in descending order and the locations in alphabetical order.
SELECT TourneyDate, TourneyLocation
FROM Tournaments
ORDER BY TourneyDate DESC, TourneyLocation ASC;

/* ***** Recipes Database ****************** */
SET search_path = recipesexample, "$user", public;

-- What types of recipes do we have, and what are the names of the
-- recipes we have for each type? Can you sort the information by 
-- type and recipe name?
SELECT RecipeClassID, RecipeTitle
FROM recipes
ORDER BY RecipeClassID ASC, RecipeTitle ASC;

-- Show me a list of unique recipe class IDs in the recipes table.
SELECT DISTINCT RecipeClassID
FROM recipes
ORDER BY 1 ASC;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
SET search_path = salesordersexample, "$user", public;

-- 1. "Show me all the information on our employees."
/* Attempt */
SELECT *
FROM employees;

/* Book Answer */
-- How to get the book's answer
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch04_employee_information';

SELECT employees.employeeid,
   employees.empfirstname,
   employees.emplastname,
   employees.empstreetaddress,
   employees.empcity,
   employees.empstate,
   employees.empzipcode,
   employees.empareacode,
   employees.empphonenumber,
   employees.empbirthdate
FROM salesordersexample.employees;

-- 2. Show me a list of cities, in alphabetical order, where
-- our vendors are located, and include the names of the vendors
-- we work with in each city.
SELECT vendcity, vendname
FROM vendors
ORDER BY vendcity ASC;

/* Book Answer */
-- How to get the book's answer
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch04_vendor_locations';

SELECT vendors.vendcity,
   vendors.vendname
FROM vendors
ORDER BY vendors.vendcity;

/* ***** Entertainment Agency Database ***** */
SET search_path = entertainmentagencyexample, "$user", public;

-- 1. Give me the names and phone numbers of all our agents, and
-- list them in last name/first name order.
SELECT AgtLastName, AgtFirstName, AgtPhoneNumber
FROM agents
ORDER BY AgtLastName, AgtFirstName;

/* Book Answer */
-- How to get the book's answer
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch04_agent_phone_list';

SELECT agents.agtlastname,
   agents.agtfirstname,
   agents.agtphonenumber
  FROM agents
ORDER BY agents.agtlastname, agents.agtfirstname;

-- 2. Give me the information on all our engagements.
SELECT *
FROM engagements;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch04_engagement_information';

SELECT engagements.engagementnumber,
   engagements.startdate,
   engagements.enddate,
   engagements.starttime,
   engagements.stoptime,
   engagements.contractprice,
   engagements.customerid,
   engagements.agentid,
   engagements.entertainerid
  FROM engagements;
   
-- 3. List all engagements and their associated start dates.
-- Sort the records by date in descending order and by 
-- engagement in ascending order.
SELECT startdate, engagementnumber
FROM engagements
ORDER BY startdate DESC, engagementnumber ASC

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch04_scheduled_engagements';

SELECT engagements.startdate,
   engagements.engagementnumber
  FROM engagements
ORDER BY engagements.startdate DESC, engagements.engagementnumber;

/* ***** School Scheduling Database ******** */
SET search_path = schoolschedulingexample, "$user", public;

-- 1. "Show me a complete list of all the subjects we offer."
SELECT subjectcode, subjectname, subjectdescription
FROM subjects;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch04_subject_list';

SELECT subjects.subjectname
  FROM subjects;

-- 2. "What kinds of titles are associated with our faculty?"
SELECT DISTINCT title
FROM faculty;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch04_faculty_titles';

SELECT DISTINCT faculty.title
  FROM faculty;

-- 3. "List the names and phone numbers of all our staff, and sort them by last
-- name and first name."
SELECT StfLastName, StfFirstName, StfPhoneNumber
FROM staff
ORDER BY StfLastName ASC, StfFirstName ASC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch04_staff_phone_list';

SELECT staff.stflastname,
   staff.stffirstname,
   staff.stfphonenumber
  FROM staff
ORDER BY staff.stflastname, staff.stffirstname;

/* ***** Bowling League Database *********** */
SET search_path = bowlingleagueexample, "$user", public;

-- 1. List all of the teams in alphabetical order.
SELECT teamname
FROM teams
ORDER BY teamname;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch04_team_list';

SELECT teams.teamname
FROM teams
ORDER BY teams.teamname;

-- 2. Show me all the bowling score information for each of our members.
SELECT MatchID, GameNumber, BowlerID, RawScore, HandicapScore, WonGame
FROM bowler_scores;

SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch04_bowler_score_information';

SELECT bowler_scores.matchid,
    bowler_scores.gamenumber,
    bowler_scores.bowlerid,
    bowler_scores.rawscore,
    bowler_scores.handicapscore,
    bowler_scores.wongame
FROM bowler_scores;

-- 3. Show me a list of bowlers and their addresses, and sort it in alphabetical
-- order." 
SELECT BowlerLastName, BowlerFirstName, 
  BowlerAddress, BowlerCity, BowlerState, BowlerZip
FROM bowlers
ORDER BY BowlerLastName, BowlerFirstName;

SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch04_bowler_names_addresses';

SELECT bowlers.bowlerlastname,
    bowlers.bowlerfirstname,
    bowlers.bowleraddress,
    bowlers.bowlercity,
    bowlers.bowlerstate,
    bowlers.bowlerzip
FROM bowlers
ORDER BY bowlers.bowlerlastname, bowlers.bowlerfirstname;

/* ***** Recipes Database ****************** */
SET search_path = recipesexample, "$user", public;

-- 1. Show me a list of all the ingredients we currently keep track of
SELECT DISTINCT IngredientName
FROM Ingredients;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch04_complete_ingredient_list';

SELECT ingredients.ingredientname
FROM ingredients;
-- 2. Show me all the main recipe information, and sort it by the name of the
-- recipe in alphabetical order.
SELECT *
FROM Recipe_Classes; /* Main course recipes = 1 */

SELECT RecipeTitle, Preparation, Notes
FROM Recipes
WHERE RecipeClassID = 1
ORDER BY RecipeTitle ASC;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch04_main_recipe_information';

SELECT recipes.recipeid,
    recipes.recipetitle,
    recipes.recipeclassid,
    recipes.preparation,
    recipes.notes
FROM recipes
ORDER BY recipes.recipetitle;
