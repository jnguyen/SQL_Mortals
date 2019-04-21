/* ********** SQL FOR MERE MORTALS CHAPTER 22 ********** */
/* ******** Partitioning Data Into Windows    ********** */
/* ***************************************************** */

/* ******************************************** *********/
/* *** What You Can Do with a "Window" into Your Data ***/
/* ******************************************** *********/

/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
-- Ex. Get number of preferences for each customer. Note that the information
-- which generated the aggregated rows is lost.
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    COUNT(*) AS Preferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CustFirstName, C.CustLastName;

-- Ex. We could add in the style names using a subquery to combine the counts
-- with the name of each style.
SELECT Customers.CustomerID,
    CustFirstName || ' ' || CustLastName AS Customer,
    Musical_Styles.StyleName,
    (SELECT COUNT(*)
    FROM Musical_Preferences
    WHERE Musical_Preferences.CustomerID = Customers.CustomerID) AS Preferences
FROM entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
    ON Customers.CustomerID = Musical_Preferences.CustomerID
    INNER JOIN Musical_Styles
    ON Musical_Styles.StyleID = Musical_Preferences.StyleID;

-- Ex. We can also use a window paritioning by customer ID
-- Note: OVER tells the database to save the data used to aggregate.
-- Note: PARTITION BY tells the databse to count, or group by, customer ID
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (
        PARTITION BY C.CustomerID
    ) AS Preferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- Ex. For each customer, show me the musical preference styles they've
-- selected. Show me a running total of the number of styles selected for all
-- the customers.
-- Note: ORDER BY sorts the IDs ASC by default to perform the running total
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (
        ORDER BY C.CustomerID
    ) AS Preferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- You can use more than one window function for each aggregate function.
-- Ex. For each customer, show me the musical preference styles they've
-- selected. Show me both the total for each customer plus a running total of
-- the number of styles selected for all the customers.
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (
        PARTITION BY C.CustomerID
        ORDER BY C.CustomerID
    ) AS CustomerPreferences,
    COUNT(*) OVER (
        ORDER BY C.CustomerID
    ) AS TotalPreferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- ORDER BY within a window function affects how rows are returned.
-- Ex. For each customer, show me the musical preferences they've selected. Show
-- me both the total for ea ch customer plus a running total of the number of
-- styles selected for all the customers. I want to see the customers sorted by
-- name.
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (
        PARTITION BY C.CustomerID
        ORDER BY C.CustLastName, C.CustFirstName
    ) AS CustomerPreferences,
    COUNT(*) OVER (
        ORDER BY C.CustLastName, C.CustFirstName
    ) AS TotalPreferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- Ensure that any ORDER BY clauses are consistent with PARTITION BY clauses, or
-- you will get confusing results.
-- Ex. For each customer, show me the musical preference styles they've
-- selected. Show me both the total for each customer plus a running total of
-- the number of styles selected for all the cusomers. I want to see the styles
-- sorted by name.
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (
        PARTITION BY C.CustomerID
        ORDER BY MS.StyleName
    ) AS CustomerPreferences,
    COUNT(*) OVER (
        ORDER BY MS.StyleName
    ) AS TotalPreferences
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- Running OVER(), i.e. without an argument, returns a grand total. This is
-- useful if you don't want to use GROUP BY
SELECT C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER () AS NumRows
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS
    ON MS.StyleID = MP.StyleID;

-- ROWS (or RANGE) can further limit rows in a partition with respect to the
-- current row.

-- Ex. For each city where we have customers, show me the customer and the number
-- of musical preference styles they've selected. Also give me a running total
-- by city, both for each customer in the city as well as for the city
-- overall.
SELECT C.CustCity,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    SUM(COUNT(*)) OVER (
        ORDER BY C.CustCity
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) TotalUsingRows,
    SUM(COUNT(*)) OVER (
        ORDER BY C.CustCity
          RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) TotalUsingRange
FROM entertainmentagencyexample.Customers AS C
    INNER JOIN Musical_Preferences AS MP
    ON MP.CustomerID = C.CustomerID
GROUP BY C.CustCity, C.CustFirstName, C.CustLastName;

/* ******************************************** ****/
/* *** Calculating a Row Number                 ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
--Ex. Assign a number for each customer. Show me their CustomerID, their name
--and their state. Return the customers in alphabetic order. 
SELECT ROW_NUMBER() OVER(
           ORDER BY CustLastName, CustFirstName
       ) AS RowNumber,
    C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS CustomerName,
    C.CustState
FROM Customers AS C;

-- Since ROW_NUMBER() is a window function, we can use OVER() to partition the
-- table
-- Ex. Assign a number for each customer within their state. Show me their
-- CustomerID, their name, and their state. Return the customers in alphabetic
-- order.
SELECT ROW_NUMBER() OVER(
           PARTITION BY CustState
           ORDER BY CustLastName, CustFirstName
       ) AS RowNumber,
    C.CustomerID,
    C.CustFirstName || ' ' || C.CustLastName AS CustomerName,
    C.CustState
FROM Customers AS C;

/* ******************************************** ****/
/* *** Ranking Data                             ****/
/* ******************************************** ****/

/* ***** School Scheduling Database ******** */
-- Ex. List all students who have completed English courses and rank them by the
-- grade that they received.
SELECT Su.SubjectID,
    St.StudFirstName,
    St.StudLastName,
    Su.SubjectName,
    SS.Grade,
    RANK() OVER (
        ORDER BY SS.Grade DESC
    ) AS Rank
FROM Students AS St
    INNER JOIN Student_Schedules AS SS
    ON St.StudentID = SS.StudentID
    INNER JOIN Classes AS C
    ON SS.ClassID = C.ClassID
    INNER JOIN Subjects AS Su
    ON C.SubjectID = Su.SubjectID
WHERE SS.ClassStatus = 2
    AND Su.CategoryID = 'ENG';

/* ***** Bowling League Database *********** */

-- RANK() has gaps when ties are given, DENSE_RANK() always returns
-- consecutive ranks and have no gaps, and PERCENT_RANK() returns the percentile
-- rank relative to the total number of rows.
-- Ex. List all the bowlers in the league, ranking them by their average
-- handicapped scores. Show all three of RANK(), DENSE_RANK(), and
-- PERCENT_RANK() to show the difference. (Remember that bowling scores are
-- reported as rounded integer values.)
SELECT B.BowlerID,
    B.BowlerFirstName || ' ' || B.BowlerLastName AS BowlerName,
    ROUND(AVG(BS.HandiCapScore), 0) AS AvgHandicap,
    RANK () OVER (
        ORDER BY ROUND(AVG(BS.HandiCapScore), 0) DESC
    ) AS Rank,
    DENSE_RANK () OVER (
        ORDER BY ROUND(AVG(BS.HandiCapScore), 0) DESC
    ) AS DenseRank,
    PERCENT_RANK () OVER (
        ORDER BY ROUND(AVG(BS.HandiCapScore), 0) DESC
    ) AS PercentRank
FROM Bowlers AS B
    INNER JOIN Bowler_Scores AS BS
    ON B.BowlerID = BS.BowlerID
GROUP BY B.BowlerID, B.BowlerFirstName, B.BowlerLastName;

/* ******************************************** ****/
/* *** Splitting Data Into Quantiles            ****/
/* ******************************************** ****/

/* ***** School Scheduling Database ******** */
-- Ex. List all students who have completed English courses, rank them by the
-- grades they received, and indicate the Quintile into which they fell.
-- Note: The NTILE() function breaks the table into a specified number of
-- groups equally. When groups cannot be equally broken up, larger groups come
-- before smaller groups. So here, 18 rows split into 5 groups: 4,4,4,3,3
SELECT Su.SubjectID,
    St.StudFirstName,
    St.StudLastName,
    SS.ClassStatus,
    SS.Grade,
    Su.CategoryID,
    Su.SubjectName,
    RANK() OVER (ORDER BY SS.Grade DESC) AS Rank,
    NTILE(5) OVER (ORDER BY SS.Grade DESC) AS Quintile
FROM Students AS St
    INNER JOIN Student_Schedules AS SS
    ON St.StudentID = SS.StudentID
    INNER JOIN Classes AS C
    ON SS.ClassID = C.ClassID
    INNER JOIN Subjects AS Su
    ON C.SubjectID = Su.SubjectID
WHERE SS.ClassStatus = 2
    AND Su.CategoryID = 'ENG';

/* ******************************************** ****/
/* *** Using Windows with Aggregate Functions   ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- Both ROWS and RANGE predicates limit the data on which the aggregate
-- functions work. Using ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW with
-- COUNT(*) counts the rows "in front" of the current row, i.e. ROW_NUMBER(),
-- but RANGE gives a running total by RANGE.
-- Ex. Give a count of how many detail lines are associated with each order
-- placed. I want to see the order number, the product purchased and a count of
-- how many items are on the invoice. I'd also like to see how many small detail
-- lines there are in total.
SELECT O.OrderNumber AS OrderNo,
    P.ProductName,
    COUNT(*) OVER (
        PARTITION BY O.OrderNumber
    ) AS Total,
    COUNT(*) OVER (
        ORDER BY O.OrderNumber
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS TotalUsingRows,
    COUNT(*) OVER (
        ORDER BY O.OrderNumber
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS TotalUsingRange
FROM Orders AS O
    INNER JOIN Order_Details AS OD
    ON O.OrderNumber = OD.OrderNumber
    INNER JOIN Products AS P
    ON P.ProductNumber = OD.ProductNumber;

-- Ex. List all orders placed, including the customer name, the order number,
-- the quantity ordered, the quoted price, and the total price per order.
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    O.OrderNumber AS Order,
    P.ProductName,
    OD.QuantityOrdered AS Quantity,
    OD.QuotedPrice AS Price,
    SUM(OD.QuotedPrice) OVER (
        PARTITION BY O.OrderNumber
    ) AS OrderTotal
FROM Orders AS O
    INNER JOIN Order_Details AS OD
    ON O.OrderNumber = OD.OrderNumber
    INNER JOIN Customers AS C
    ON O.CustomerID = C.CustomerID
    INNER JOIN Products AS P
    ON P.ProductNumber = OD.ProductNumber;

-- Ex. List all engagements booked, showing the customer, the start date, the
-- contract price, and the sum of the current row plus the row before and after.
-- Also, show the sum of the current row plus the row before and after
-- partitioned by customer.
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    E.StartDate,
    E.ContractPrice,
    SUM(E.ContractPrice) OVER (
        ORDER BY C.CustLastName, C.CustFirstName
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS SumOf3,
    SUM(E.ContractPrice) OVER (
        PARTITION BY C.CustLastName, C.CustFirstName
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS PartitionedSumOf3
FROM Engagements AS E
    INNER JOIN entertainmentagencyexample.Customers AS C
    ON C.CustomerID = E.CustomerID;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* *** Examples Using ROW_NUMBER *** */
/* ***** Entertainment Agency Database ***** */
-- Ex. I'd like a list of all the engagements. Show me the start date for each
-- engagement, the name of the customer, and the entertainer. Number the
-- engagements overall, plus number the engagements within each start date. 111
SELECT ROW_NUMBER() OVER (
        ORDER BY E.StartDate
    ) AS row_overall,
    ROW_NUMBER() OVER (
        PARTITION BY E.StartDate
        ORDER BY E.StartDate
    ) AS row_within_sd,
    E.StartDate,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    Ent.EntStageName
FROM Engagements E
    INNER JOIN entertainmentagencyexample.Customers C
    ON E.CustomerID = C.CustomerID
    INNER JOIN Entertainers Ent
    ON E.EntertainerID = Ent.EntertainerID;

/* ***** Recipes Database ****************** */
-- Ex. I'd like a numbered list of all the recipes. Number the recipes overall,
-- plus number each recipe within its recipe class. Sort the lists
-- alphabetically by recipe name within recipe class. Don't forget to include
-- any recipe classes that don't have any recipes in them. 16
SELECT ROW_NUMBER() OVER (
        ORDER BY RC.RecipeClassDescription, R.RecipeTitle
    ) AS Overall_Number,
    RC.RecipeClassDescription,
    ROW_NUMBER() OVER (
        PARTITION BY RC.RecipeClassDescription
        ORDER BY R.RecipeTitle
    ) AS Number_In_Class,
    R.RecipeTitle
FROM Recipe_Classes RC
    LEFT OUTER JOIN Recipes R
    ON RC.RecipeClassID = R.RecipeClassID;

/* *** Examples Using RANK, DENSE_RANK, and PERCENT_RANK *** */
/* ***** Sales Orders Database ************* */
-- Ex. Rank all employees by the number of orders with which they're associated.
-- 8
SELECT E.EmployeeID,
    E.EmpFirstName || ' ' || E.EmpLastName AS Employee,
    RANK() OVER (
        ORDER BY COUNT(DISTINCT O.OrderNumber) DESC
    ) AS Rank,
    COUNT(DISTINCT O.OrderNumber) AS num_orders
FROM Employees E
    INNER JOIN Orders O
    ON E.EmployeeID = O.EmployeeID
    INNER JOIN Order_Details OD
    ON OD.OrderNumber = O.OrderNumber
GROUP BY E.EmployeeID, E.EmpFirstName, E.EmpLastName;

/* ***** School Scheduling Database ******** */
-- Ex. Rank the staff by how long they've been with us as of January 1, 2018. I
-- don't want to see any gaps in the rank numbers. 27
-- Note: For some reason the book solution forgot to change the CASE statement,
-- so it actually subtracts the wrong date.
SELECT Stf.StfFirstName || ' ' || Stf.StfLastName AS Staff,
    FLOOR((date '2018-01-01' - DateHired)/365.24) AS YearsHired,
    date_part('year', '2018-01-01'::date) -
        date_part('year', Stf.DateHired) -
        (CASE
            WHEN date_part('month', Stf.DateHired) > 1 THEN 1
            WHEN date_part('day', Stf.DateHired) > 1 THEN 1
            ELSE 0
        END) AS YearsHiredCase,
    DENSE_RANK() OVER (
        ORDER BY FLOOR((date '2018-01-01' - DateHired)/365.24) DESC
    ) AS Rank
FROM Staff Stf;

/* *** Examples Using NTILE *** */
/* ***** Bowling League Database *********** */
-- Ex. Rank all the teams from best to worst based on the average handicap score
-- of all the players. Arrange the teams into four quartiles. 8
-- Since the differences are so small, the DBMS will just sort by average
-- handicap score and then arbitarily quartile labels
SELECT T.TeamName,
    ROUND(AVG(BS.HandiCapScore), 0) AS AvgHandiCap,
    NTILE(4) OVER (
        ORDER BY ROUND(AVG(HandiCapScore), 0) DESC
    ) AS Quartile
FROM Teams T
    INNER JOIN Bowlers B
    ON T.TeamID = B.TeamID
    INNER JOIN Bowler_Scores BS
    ON B.BowlerID = BS.BowlerID
GROUP BY T.TeamName;

/* ***** Entertainment Agency Database ***** */
-- Ex. Rank all the entertainers based on the number of engagements booked for
-- each. Arrange the entertainers into three groups. Remember to include any
-- entertainers who haven't been booked for any engagements. 13
SELECT Ent.EntStageName,
    COUNT(Eng.EntertainerID) AS num_booked,
    NTILE(3) OVER (
        ORDER BY COUNT(Eng.EntertainerID) DESC
    ) AS Rank
FROM Entertainers Ent
    LEFT JOIN Engagements Eng
    ON Ent.EntertainerID = Eng.EntertainerID
GROUP BY Ent.EntStageName;

/* *** Examples Using Aggregate Functions *** */
/* ***** Bowling League Database *********** */
-- Ex. For each team, show me the details of all the games bowled by the team
-- captains. Include the date and location for each tournament, their handicap
-- score, whether or not they won the game. Include counts for how many games
-- they won and their average handicap score. 420
SELECT Teams.TeamName,
    B.BowlerFirstName || ' ' || B.BowlerLastName AS Captain,
    T.TourneyDate,
    T.TourneyLocation,
    BS.HandiCapScore,
    CASE BS.WonGame
        WHEN 1 THEN 'Won'
        ELSE 'Lost'
    END AS WonGame,
    SUM(BS.WonGame::integer) OVER (
        PARTITION BY Teams.TeamName
    ) AS TotalWins,
    AVG(BS.HandiCapScore) OVER (
        PARTITION BY Teams.TeamName
    ) AS AvgHandiCap
FROM Teams
    INNER JOIN Bowlers B
    ON B.BowlerID = Teams.CaptainID
    INNER JOIN Bowler_Scores BS
    ON B.BowlerID = BS.BowlerID
    INNER JOIN Match_Games MG
    ON BS.MatchID = MG.MatchID AND MG.GameNumber = BS.GameNumber
    INNER JOIN Tourney_Matches TM
    ON MG.MatchID = TM.MatchID
    INNER JOIN Tournaments T
    ON TM.TourneyID = T.TourneyID;

/* ***** Sales Orders Database ************* */
-- Ex. For each order, give me a list of the customer, the product, and the
-- quantity ordered. Give me the total quantity of products for each order. As
-- well, for every group of three products on the invoice, show me their total
-- and the highest and lowest value. 3973
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    O.OrderNumber,
    P.ProductName,
    OD.QuantityOrdered,
    SUM(OD.QuantityOrdered) OVER (
        ORDER BY O.OrderNumber
    ) AS TotalQuantity,
    SUM(OD.QuantityOrdered) OVER (
        PARTITION BY O.OrderNumber
        ORDER BY O.OrderNumber
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Quantity3,
    MIN(OD.QuantityOrdered) OVER (
        PARTITION BY O.OrderNumber
        ORDER BY O.OrderNumber
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Minimum3,
    MAX(OD.QuantityOrdered) OVER (
        PARTITION BY O.OrderNumber
        ORDER BY O.OrderNumber
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Maximum3
FROM Customers C
    INNER JOIN Orders O
    ON C.CustomerID = O.CustomerID
    INNER JOIN Order_Details OD
    ON O.OrderNumber = OD.OrderNumber
    INNER JOIN Products P
    ON OD.ProductNumber = P.ProductNumber;

/* ***** School Scheduling Database ******** */
-- Ex. For each subject, give me the highest mark that's been received. Also,
-- show me the highest mark that's been received for each category of subjects,
-- as well as the highest mark that's been received overall. 14
SELECT DISTINCT Categories.CategoryDescription,
    Subjects.SubjectCode,
    Subjects.SubjectName,
    MAX(SS.Grade) OVER (
        PARTITION BY Subjects.SubjectID
    ) AS SubjectMax,
    MAX(SS.Grade) OVER (
        PARTITION BY Categories.CategoryID
    ) AS CategoryMax,
    MAX(SS.Grade) OVER() AS OverallMax
FROM schoolschedulingexample.Categories
    INNER JOIN Subjects
    ON Categories.CategoryID = Subjects.CategoryID
    INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
    INNER JOIN Student_Schedules SS
    ON Classes.ClassID = SS.ClassID
WHERE SS.ClassStatus = 2
ORDER BY Categories.CategoryDescription, Subjects.SubjectCode;

/* ******************************************** ****/
/* *** Problems for You to Solve                ****/
/* ******************************************** ****/
/* ***** Bowling League Database *********** */
-- 1.“Divide the teams into quartiles based on the best raw score bowled by any
-- member of the team.”You can find my solution in
-- ch22_team_quartiles_best_rawscore (8 rows).
SELECT Teams.TeamName,
    MAX(Bowler_Scores.RawScore) AS best_score,
    NTILE(4) OVER(
        ORDER BY MAX(Bowler_Scores.RawScore) DESC
    ) AS Quartile
FROM Teams
    INNER JOIN Bowlers
    ON Teams.TeamID = Bowlers.TeamID
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Teams.TeamName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch22_team_quartiles_best_rawscore';

SELECT teams.teamname,                                                    
    max(bowler_scores.rawscore) AS bestrawscore,                           
    ntile(4) OVER (ORDER BY (max(bowler_scores.rawscore)) DESC) AS quartile
FROM ((teams                                                            
    JOIN bowlers
    ON ((bowlers.teamid = teams.teamid)))                    
    JOIN bowler_scores
    ON ((bowler_scores.bowlerid = bowlers.bowlerid)))  
GROUP BY teams.teamname;

-- 2. “Give me a list of all of the bowlers in the league. Number the bowlers
-- overall, plus number them within their teams, sorting their names by LastName
-- then FirstName. ”You can find my solution in ch22_bowler_numbers (32 rows).
SELECT ROW_NUMBER() OVER(
        ORDER BY B.BowlerLastName, B.BowlerFirstName
    ) AS num_overall,
    ROW_NUMBER() OVER (
        PARTITION BY Teams.TeamName
        ORDER BY B.BowlerLastName, B.BowlerFirstName
    ) AS num_within_team,
    Teams.TeamName,
    B.BowlerLastName,
    B.BowlerFirstName
FROM Bowlers B
    INNER JOIN Teams
    ON B.TeamID = Teams.TeamID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch22_bowler_numbers';

SELECT teams.teamname,                                                            
     (((bowlers.bowlerfirstname)::text || ' '::text) ||
        (bowlers.bowlerlastname)::text) AS bowler,                         
     row_number() OVER(
        ORDER BY bowlers.bowlerlastname, bowlers.bowlerfirstname
    ) AS overallnumber,                        
     row_number() OVER(
        PARTITION BY teams.teamname
        ORDER BY bowlers.bowlerlastname, bowlers.bowlerfirstname) AS teamnumber
    FROM (teams                                                                     
      JOIN bowlers ON ((bowlers.teamid = teams.teamid)));

-- 3. “Rank all of the bowlers in the league by their average handicap score.
-- Show me the “standard” ranking, but also show me the ranking with no
-- gaps.”You can find my solution in ch22_bowler_ranks (32 rows).
-- Note: My solution uses rounding for handicap scores but the book doesn't
SELECT B.BowlerFirstName || ' ' || B.BowlerLastName AS Bowler,
    ROUND(AVG(BS.HandiCapScore)) AS AvgHandiCap,
    RANK() OVER (
        ORDER BY ROUND(AVG(BS.HandiCapScore)) DESC
    ) AS Rank,
    DENSE_RANK() OVER (
        ORDER BY ROUND(AVG(BS.HandiCapScore)) DESC
    ) AS Rank_No_Gaps
FROM Bowlers B
    INNER JOIN Bowler_Scores BS
    ON B.BowlerID = BS.BowlerID
GROUP BY B.BowlerFirstName, B.BowlerLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch22_bowler_ranks';

SELECT teams.teamname,                                                                          
   (((bowlers.bowlerfirstname)::text || ' '::text) || (bowlers.bowlerlastname)::text) AS bowler,
   avg(bowler_scores.handicapscore) AS avghandicapscore,                                        
   rank() OVER (ORDER BY (avg(bowler_scores.handicapscore)) DESC) AS bowlerrank,                
   dense_rank() OVER (ORDER BY (avg(bowler_scores.handicapscore)) DESC) AS bowlerdenserank      
FROM ((bowler_scores                                                                          
    JOIN bowlers ON ((bowlers.bowlerid = bowler_scores.bowlerid)))                              
    JOIN teams ON ((teams.teamid = bowlers.teamid)))                                            
GROUP BY teams.teamname, bowlers.bowlerfirstname, bowlers.bowlerlastname;

/* ***** Entertainment Agency Database ***** */
-- 1. “Rank all the agents based on the total dollars associated with the
-- engagements that they’ve booked. Make sure to include any agents that haven’t
-- booked any acts.”You can find my solution in ch22_agent_ranks (9 rows).
SELECT Agents.AgtFirstName || ' ' || Agents.AgtLastName AS Agent,
    SUM(CASE
        WHEN Engagements.ContractPrice IS NULL THEN 0::double precision
        ELSE Engagements.ContractPrice
    END) AS TotalDollars,
    RANK() OVER (
        ORDER BY
            SUM(CASE
                WHEN Engagements.ContractPrice IS NULL THEN 0::double precision
                ELSE Engagements.ContractPrice
            END) DESC
    ) AS Rank
FROM Agents
    LEFT OUTER JOIN Engagements
    ON Agents.AgentID = Engagements.AgentID
GROUP BY Agents.AgtFirstName, Agents.AgtLastName;

/* Book Answer */
-- Note: For some reason the book orders the agents by total engagements rather
-- than by dollars.
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch22_agent_ranks';

SELECT agents.agentid,                                                                 
   (((agents.agtfirstname)::text || ' '::text) || (agents.agtlastname)::text) AS agent,
   count(engagements.engagementnumber) AS gigs,                                        
   rank() OVER (ORDER BY (count(engagements.engagementnumber)) DESC) AS agentrank      
FROM (agents                                                                         
    LEFT JOIN engagements ON ((engagements.agentid = agents.agentid)))                 
GROUP BY agents.agentid, agents.agtfirstname, agents.agtlastname;

-- 2. “Give me a list of all of the engagements our entertainers are booked for.
-- Show me the entertainer’s stage name, the customer’s name, and the start date
-- for each engagements, as well as the total number of engagements booked for
-- each entertainer.”You can find my solution in ch22_entertainer_engagements
-- (111 rows).
SELECT Engagements.EngagementNumber,
    Entertainers.EntStageName,
    C.CustFirstName || ' ' || C.CustLastName AS Customer,
    Engagements.StartDate,
    COUNT(Engagements.EngagementNumber) OVER (
        PARTITION BY Entertainers.EntertainerID
    ) AS TotalEntBookings
FROM Engagements
    INNER JOIN entertainmentagencyexample.Customers C
    ON Engagements.CustomerID = C.CustomerID
    INNER JOIN Entertainers
    ON Engagements.EntertainerID = Entertainers.EntertainerID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch22_entertainer_engagements';

SELECT entertainers.entstagename,                                                                   
 (((customers.custfirstname)::text || ' '::text) || (customers.custlastname)::text) AS customer,  
 engagements.startdate,                                                                           
 count(engagements.engagementnumber) OVER (PARTITION BY entertainers.entertainerid) AS gigs       
FROM ((entertainers                                                                               
  LEFT JOIN engagements ON ((engagements.entertainerid = entertainers.entertainerid)))            
  JOIN entertainmentagencyexample.customers ON ((customers.customerid = engagements.customerid)));

-- 3. “Give me a list of all of the Entertainers and their members. Number each
-- member within a group.”You can find my solution in ch22_entertainer_lists (40
-- rows).
SELECT Entertainers.EntStageName,
    Members.MbrFirstName || ' ' || Members.MbrLastName AS Member,
    ROW_NUMBER() OVER(
        PARTITION BY Entertainers.EntertainerID
    ) AS Number
FROM Entertainers
    INNER JOIN Entertainer_Members
    ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID
    INNER JOIN Members
    ON Entertainer_Members.MemberID = Members.MemberID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch22_entertainer_lists';

SELECT entertainers.entstagename,                                                                                                
   row_number() OVER (PARTITION BY entertainers.entstagename ORDER BY members.mbrlastname, members.mbrfirstname) AS membernumber,
   (((members.mbrfirstname)::text || ' '::text) || (members.mbrlastname)::text) AS member                                        
  FROM ((entertainers                                                                                                            
    JOIN entertainer_members ON ((entertainer_members.entertainerid = entertainers.entertainerid)))                              
    JOIN members ON ((members.memberid = entertainer_members.memberid)));

/* ***** Recipes Database ****************** */
-- 1. “Give me a list of all of the recipes I've got. For each recipe, I want to
-- see all of the ingredients in the recipe, plus a count of how many different
-- ingredients there are.”You can find my solution in
-- ch22_recipe_ingredient_counts (88 rows).
SELECT Recipes.RecipeTitle,
    Ingredients.IngredientName,
    COUNT(*) OVER (
        PARTITION BY Recipes.RecipeID
    ) AS NumIngredients
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID;

-- For fun: the same query but using a correlated subquery
SELECT Recipes.RecipeTitle,
    Ingredients.IngredientName,
    (SELECT COUNT(*)
    FROM Recipe_Ingredients
    WHERE Recipe_Ingredients.RecipeID = Recipes.RecipeID) AS NumIngredients
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch22_recipe_ingredient_counts';

SELECT r.recipetitle,                                           
   i.ingredientname,                                            
   count(*) OVER (PARTITION BY r.recipetitle) AS ingredientcount
  FROM ((recipes r                                              
    JOIN recipe_ingredients ri ON ((ri.recipeid = r.recipeid))) 
    JOIN ingredients i ON ((i.ingredientid = ri.ingredientid)));

-- 2. “I’d like a list of all the different ingredients, with each recipe that
-- contains that ingredient. While you’re at it, give me a count of how many
-- recipes there are that use each ingredient.”You can find my solution in
-- ch22_ingredient_recipe_counts (88 rows).
SELECT Ingredients.IngredientName,
    Recipes.RecipeTitle,
    COUNT(*) OVER (
        PARTITION BY Ingredients.IngredientName
    ) AS RecipeCount
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch22_ingredient_recipe_counts';

SELECT i.ingredientname,                                        
   r.recipetitle,                                               
   count(*) OVER (PARTITION BY i.ingredientname) AS recipecount 
  FROM ((recipes r                                              
    JOIN recipe_ingredients ri ON ((ri.recipeid = r.recipeid))) 
    JOIN ingredients i ON ((i.ingredientid = ri.ingredientid)));

-- 3. “I want a numbered list of all of the ingredients. Number the ingredients
-- overall, plus number each ingredient within its ingredient class. Sort the
-- lists alphabetically by ingredient within ingredient class. Don’t forget to
-- include any ingredient classes that don’t have any ingredients in them.”You
-- can find my solution in ch22_ingredients_by_ingredient_class (83 rows,
-- including four classes with no ingredients in them).
SELECT Ingredient_Classes.IngredientClassDescription,
    Ingredients.IngredientName,
    ROW_NUMBER() OVER(
        ORDER BY Ingredient_Classes.IngredientClassDescription,
            Ingredients.IngredientName
    ) AS NumOverall,
    ROW_NUMBER() OVER(
        PARTITION BY Ingredient_Classes.IngredientClassDescription
        ORDER BY Ingredients.IngredientName
    ) AS NumClass
FROM Ingredient_Classes
    LEFT OUTER JOIN Ingredients
    ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'recipesexample'
AND table_name = 'ch22_ingredients_by_ingredient_class';

SELECT row_number() OVER (ORDER BY ic.ingredientclassdescription, i.ingredientname) AS overallnumber,        
   ic.ingredientclassdescription,                                                                            
   row_number() OVER (PARTITION BY ic.ingredientclassdescription ORDER BY i.ingredientname) AS numberinclass,
   i.ingredientname                                                                                          
  FROM (ingredient_classes ic                                                                                
    LEFT JOIN ingredients i ON ((i.ingredientclassid = ic.ingredientclassid)));

/* ***** Sales Orders Database ************* */
-- 1. “Show totals for each invoice, ranking them from highest purchase value to
-- lowest.”You can find my solution in ch22_order_totals_rankedbyinvoicetotal
-- (933 rows).
-- Note: My query deals with total price by quantity, not just the quoted prices
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    Order_Details.OrderNumber,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) AS Total,
    RANK() OVER (
        ORDER BY SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered)
            DESC
    ) AS Rank
FROM Customers C
    INNER JOIN Orders
    ON C.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY C.CustFirstName, C.CustLastName, Order_Details.OrderNumber;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch22_order_totals_rankedbyinvoicetotal';

SELECT (((c.custfirstname)::text || ' '::text) || (c.custlastname)::text) AS customer,
   o.ordernumber,                                                                     
   sum(od.quantityordered) AS totalquantity,                                          
   sum(od.quotedprice) AS totalprice,                                                 
   rank() OVER (ORDER BY (sum(od.quotedprice)) DESC) AS rank                          
  FROM (((orders o                                                                    
    JOIN order_details od ON ((od.ordernumber = o.ordernumber)))                      
    JOIN customers c ON ((c.customerid = o.customerid)))                              
    JOIN products p ON ((p.productnumber = od.productnumber)))                        
 GROUP BY c.custfirstname, c.custlastname, o.ordernumber;

-- 2. “Produce a list of each category and the total purchase price of all
-- products in each category. Include a column showing the total purchase price
-- regardless of category as well.”You can find my solution in ch22_sales_totals
-- (6 rows).
SELECT DISTINCT Categories.CategoryDescription,
    SUM(OD.QuotedPrice) OVER (
        PARTITION BY Categories.CategoryID
    ) AS total_within_cat,
    SUM(OD.QuotedPrice) OVER () AS total_overall
FROM Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    INNER JOIN Order_Details OD
    ON OD.ProductNumber = Products.ProductNumber
    INNER JOIN Orders
    ON OD.OrderNumber = Orders.OrderNumber;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch22_sales_totals';

SELECT DISTINCT c.categorydescription,                                           
   sum(od.quotedprice) OVER () AS totalsales,                                    
   sum(od.quotedprice) OVER (PARTITION BY c.categorydescription) AS categorysales
  FROM (((orders o                                                               
    JOIN order_details od ON ((od.ordernumber = o.ordernumber)))                 
    JOIN products p ON ((p.productnumber = od.productnumber)))                   
    JOIN categories c ON ((c.categoryid = p.categoryid)));

-- How would you write this differently if you knew there were categories that
-- had no sales in them? (The sample database does have sales in each category,
-- but you can always add a new category with no sales to see whether your
-- query works!) My solution is ch22_sales_totals_handle_nulls. If you
-- didn't add a new category, it would return the same as ch22_sales_totals (6
-- rows).  If you did add a new category, it would return seven rows.
-- Idea: Use an outer join and SUM over a CASE WHEN that sets NULL sales to 0
SELECT DISTINCT Categories.CategoryDescription,
    SUM(CASE WHEN OD.QuotedPrice IS NULL THEN 0 ELSE OD.QuotedPrice END) OVER (
        PARTITION BY Categories.CategoryID
    ) AS total_within_cat,
    SUM(CASE WHEN OD.QuotedPrice IS NULL THEN 0 ELSE OD.QuotedPrice END) OVER ()
        AS total_overall
FROM Categories
    LEFT JOIN Products
    ON Categories.CategoryID = Products.CategoryID
    LEFT JOIN Order_Details OD
    ON OD.ProductNumber = Products.ProductNumber
    LEFT JOIN Orders
    ON OD.OrderNumber = Orders.OrderNumber;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch22_sales_totals_handle_nulls';

SELECT DISTINCT c.categorydescription,                                                                   
   sum(od.quotedprice) OVER () AS totalsales,                                                            
   COALESCE(sum(od.quotedprice) OVER (PARTITION BY c.categorydescription), (0)::numeric) AS categorysales
  FROM (((categories c                                                                                   
    LEFT JOIN products p ON ((p.categoryid = c.categoryid)))                                             
    LEFT JOIN order_details od ON ((od.productnumber = p.productnumber)))                                
    LEFT JOIN orders o ON ((o.ordernumber = od.ordernumber)));

-- 3. “Rank each customer by the number of orders which they’ve placed. Be sure
-- to include customers that haven’t placed any orders yet.”You can find my
-- solution in ch22_customer_orders_counts_ranked (28 rows, including Jeffrey
-- Tirekicker having placed no orders).
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    COUNT(Orders.CustomerID) num_orders,
    RANK() OVER (
        ORDER BY COUNT(Orders.CustomerID) DESC
    ) AS Rank
FROM Customers C
    LEFT OUTER JOIN Orders
    ON C.CustomerID = Orders.CustomerID
GROUP BY C.CustomerID, C.CustFirstName, C.CustLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch22_customer_orders_counts_ranked';

SELECT c.customerid,                                                              
   (((c.custfirstname)::text || ' '::text) || (c.custlastname)::text) AS customer,
   count(DISTINCT o.ordernumber) AS ordersreceived,                               
   rank() OVER (ORDER BY (count(DISTINCT o.ordernumber)) DESC) AS rank            
  FROM (customers c                                                               
    LEFT JOIN orders o ON ((o.customerid = c.customerid)))                        
 GROUP BY c.customerid, c.custfirstname, c.custlastname;

/* ***** School Scheduling Database ******** */
-- 1. “Rank the students in terms of the number of classes they’ve
-- completed.”You can find my solution in ch22_student_class_totals_rank (18
-- rows). (Pretty homogenous class, isn’t it?)
SELECT St.StudFirstName || ' ' || St.StudLastName AS Student,
    COUNT(*) AS classes_completed,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS Rank
FROM Students St
    INNER JOIN Student_Schedules SS
    ON St.StudentID = SS.StudentID
WHERE SS.ClassStatus = 2
GROUP BY St.StudFirstName, St.StudLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch22_student_class_totals_rank';

SELECT students.studentid,                                                                     
   (((students.studfirstname)::text || ' '::text) || (students.studlastname)::text) AS student,
   count(*) AS classcount,                                                                     
   rank() OVER (ORDER BY (count(*)) DESC) AS rank                                              
  FROM (students                                                                               
    JOIN student_schedules ON ((student_schedules.studentid = students.studentid)))            
WHERE (student_schedules.classstatus = 2)                                                     
GROUP BY students.studentid, students.studfirstname, students.studlastname;

-- 2. “Rank the faculty in terms of the number of classes they’re teaching.”You
-- can find my solution in ch22_staff_class_totals_rank (22 rows).
SELECT Staff.StfFirstName || ' ' || Staff.StfLastName AS Staff,
    COUNT(Faculty_Classes.ClassID) AS classes_teaching,
    RANK() OVER (ORDER BY COUNT(Faculty_Classes.ClassID) DESC) AS Rank
FROM Staff
    INNER JOIN Faculty_Classes
    ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfFirstName, Staff.StfLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch22_staff_class_totals_rank';

SELECT staff.staffid,                                                                
   (((staff.stffirstname)::text || ' '::text) || (staff.stflastname)::text) AS staff,
   count(*) AS classcount,                                                           
   rank() OVER (ORDER BY (count(*)) DESC) AS rank                                    
  FROM ((staff                                                                       
    JOIN faculty ON ((faculty.staffid = staff.staffid)))                             
    JOIN faculty_classes ON ((faculty_classes.staffid = faculty.staffid)))           
 GROUP BY staff.staffid, staff.stffirstname, staff.stflastname;

-- 3. “Arrange the students into 3 groups depending on their average grade for
-- each of the classes they’ve completed.”You can find my solution in
-- ch22_student_averagegrade_groups (18 rows).
SELECT St.StudFirstName || ' ' || St.StudLastName AS Student,
    AVG(SS.Grade) AS avg_grade,
    NTILE(3) OVER(ORDER BY AVG(SS.Grade) DESC) AS Group
FROM Students St
    INNER JOIN Student_Schedules SS
    ON St.StudentID = SS.StudentID
WHERE SS.ClassStatus = 2
GROUP BY St.StudFirstName, St.StudLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch22_student_averagegrade_groups';

SELECT students.studentid,                                                                     
   (((students.studfirstname)::text || ' '::text) || (students.studlastname)::text) AS student,
   avg(student_schedules.grade) AS averagegrade,                                               
   ntile(3) OVER (ORDER BY (avg(student_schedules.grade)) DESC) AS rank                        
  FROM (students                                                                               
    JOIN student_schedules ON ((student_schedules.studentid = students.studentid)))            
 WHERE (student_schedules.classstatus = 2)                                                     
 GROUP BY students.studentid, students.studfirstname, students.studlastname;

-- 4. “For each student, give me a list of each course he or she has completed
-- and the mark he or she got in that course. Show me their overall average for
-- all the completed courses, plus, for every group of three courses, show me
-- their average and the highest and lowest marks of the three highest marks
-- that have been received.” You can find my solution in ch22_marks_min_max (68
-- rows).
SELECT St.StudFirstName || ' ' || St.StudLastName AS Student,
    Su.SubjectName,
    SS.Grade,
    AVG(SS.Grade) OVER(PARTITION BY St.StudentID) AS overall_avg,
    AVG(SS.Grade) OVER(
        PARTITION BY St.StudentID
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Average3,
    MIN(SS.Grade) OVER(
        PARTITION BY St.StudentID
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Minimum3,
    MAX(SS.Grade) OVER(
        PARTITION BY St.StudentID
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS Maximum3
FROM Students St
    INNER JOIN Student_Schedules SS
    ON St.StudentID = SS.StudentID
    INNER JOIN Classes Cl
    ON SS.ClassID = Cl.ClassID
    INNER JOIN Subjects Su
    ON Cl.SubjectID = Su.SubjectID
WHERE SS.ClassStatus = 2;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch22_marks_min_max';

SELECT (((st.studfirstname)::text || ' '::text) || (st.studlastname)::text) AS student,                                                                               
   su.subjectname,                                                                                                                                                    
   ss.grade,                                                                                                                                                          
   avg(ss.grade) OVER(
     PARTITION BY st.studlastname, st.studfirstname
     ORDER BY st.studlastname, st.studfirstname
   ) AS average,                                                                                    
   min(ss.grade) OVER(
     PARTITION BY st.studlastname, st.studfirstname
     ORDER BY st.studlastname, st.studfirstname
     ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS minimum,
   max(ss.grade) OVER(
     PARTITION BY st.studlastname, st.studfirstname
     ORDER BY st.studlastname, st.studfirstname
     ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS maximum 
  FROM (((students st                                                                                                                                                 
    JOIN student_schedules ss ON ((ss.studentid = st.studentid)))                                                                                                     
    JOIN classes c ON ((c.classid = ss.classid)))                                                                                                                     
    JOIN subjects su ON ((su.subjectid = c.subjectid)))                                                                                                               
 WHERE (ss.classstatus = 2);
