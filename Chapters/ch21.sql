/* ********** SQL FOR MERE MORTALS CHAPTER 21 ********** */
/* ******** Performing Complex Calculations On Groups ** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Grouping in Sub-Group                    ****/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Extending the GROUP BY Clause            ****/
/* ******************************************** ****/
/* ******************************************** ****/
/* *** Getting Totals in a Hierarchy Using ROLLUP **/
/* ******************************************** ****/

/* ******************************************** ****/
/* * Creating a Union of Totals with GROUPING SETS */
/* ******************************************** ****/
/* ******************************************** ****/
/* *** Variations on Grouping Techniques        ****/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/

/* ***** Bowling League Database *********** */
-- 1. “Show me how many bowlers live in each city. Give me totals for each
-- combination of Team and City, for each Team, for each City plus a grand
-- total.”
-- You can find my solution in CH21_Team_City_Count_CUBE (44 rows).

-- 2. “Show me the average raw score for each bowler. Give me totals by Team and
-- by City.”
-- You can find my solution in CH21_Team_City_AverageRawScore_GROUPING_SETS (18
-- rows).

-- 3. “Show me the average handicap score for each bowler. For each team, give
-- me average for each city in which the bowlers live. Also give me the average
-- for each team, and the overall average for the entire league.”
-- You can find my solution in CH21_Team_City_AverageHandicapScore_ROLLUP (34
-- rows).

/* ***** Entertainment Agency Database ***** */
-- 1. “For each city where our entertainers live, show me how many different
-- musical styles are represented. Give me totals for each combination of City
-- and Style, for each City plus a grand total.”
-- You can find my solution in CH21_EntertainerCity_Style_ROLLUP (36 rows).

-- 2. “For each city where our customers live, show me how many different
-- musical styles they’re interested in. Give me total counts by city, total
-- counts by style and total counts for each combination of city and style.”
-- You can find my solution in CH21_CustomerCity_Style_GROUPING_SETS (18 rows).

-- 3. “Give me an analysis of all the bookings we’ve had. I want to see the
-- number of bookings and the total charge broken down by the city the agent
-- lives in, the city the customer lives in, and the combination of the two.”
-- You can find my solution in
-- CH21_AgentCity_CustomerCity_Count_Charge_GROUPING_SETS (34 rows).

/* ***** Recipes Database ****************** */
-- 1. “I want to know how many recipes there are in each of the recipe classes
-- in my cookbook, plus an overall total of all the recipes regardless of recipe
-- class. Make sure to include any recipe classes that don’t have any recipes in
-- them.”
-- You can find my solution in CH21_RecipeClass_Recipe_Counts_ROLLUP (8 rows).

-- 2. “I want to know the relationship between RecipeClasses and
-- IngredientClasses. For each recipe class, show me how many different
-- ingredient classes are represented, and for each ingredient class, show me
-- how many different recipe classes are represented.”
-- You can find my solution in CH21_RecipeClass_IngredClass_Counts_GROUPING_SETS
-- (25 rows).

-- 3. “I want to know even more about the relationship between RecipeClasses and
-- IngredientClasses. Show me how many recipes there are in each combination of
-- recipe class and ingredient class. Also show me how many recipes there are in
-- each ingredient class regardless of the recipe class, how many recipes there
-- are in each recipe class regardless of the ingredient class, and how many
-- recipes there are in total.”
-- You can find my solution in CH21_RecipeClass_IngredClass_CUBE (61 rows).

/* ***** Sales Orders Database ************* */
-- 1. “For each category of product, show me, by state, how much revenue the
-- customers have generated. Give me subtotals for each state, for each
-- category, plus a grand total.”
-- You can find my solution in CH21_ProductCategory_CustomerState_Revenue_CUBE
-- (35 rows).
-- 2. “For each category of product, show me, by state, how much quantity the
-- vendors have on hand. Give me subtotals for each state within a category,
-- plus a grand total.”
-- You can find my solution in CH21_ProductCategory_VendorState_QOH_ROLLUP (33
-- rows).

-- 3. “For each of our vendors, let me know how many products they supply in
-- each category. I want to see this broken down by state. For each state, show
-- me the number of products in each category. Show me the number of products
-- for all categories and a grand total as well.” Note that the counts will not
-- represent the number of different products that are sold!
-- You can find my solution in CH21_VendorState_Category_Count_ROLLUP (43 rows).

/* ***** School Scheduling Database ******** */
-- 1. “Summarize the number of class sessions scheduled, showing semester,
-- building, classroom, and subject. Give me subtotals for each semester, for
-- each combination of building and classroom and for each subject.”
-- You can find my solution in
-- CH21_Semester_Building_ClassRoom_Subject_Count_GROUPING_SETS (82 rows).

-- 2. “For each department, show me the number of courses that could be offered,
-- and whether they’re taught by a Professor, an Associate Professor, or an
-- Instructor. Give me total courses per department and total courses overall as
-- well.”
-- Note that the number of courses returned will be greater than the number of
-- courses offered by the school because some courses could be taught by more
-- than instructors.
-- You can find my solution in CH21_Department_Title_Count_ ROLLUP (20 rows).

-- 3. “I want to know how many courses our students have been in contact with.
-- Give me totals by whether they completed the course, are currently enrolled
-- in it or withdrew.  I’d also like to see this broken down by student major.
-- May as well give me the total courses completed, enrolled and withdrawn while
-- you’re at it. Don’t worry about splitting it up by semester.”
-- You can find my solution in CH21_Major_ClassStatus_Count_GROUPING_SETS (26
-- rows).
