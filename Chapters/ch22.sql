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

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

/* ******************************************** ****/
/* *** Problems for You to Solve                ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
