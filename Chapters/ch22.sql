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

/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

/* ******************************************** ****/
/* *** Calculating a Row Number                 ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

/* ******************************************** ****/
/* *** Ranking Data                             ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

/* ******************************************** ****/
/* *** Splitting Data Into Quantiles            ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

/* ******************************************** ****/
/* *** Using Windows with Aggregate Functions   ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */

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
