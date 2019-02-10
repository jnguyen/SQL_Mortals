/* ********** SQL FOR MERE MORTALS CHAPTER 20 ********** */
/* ******** Using Unlinked Data and "Driver" Tables **** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** What Is Unlinked Data?                   ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Explicit CROSS JOIN, i.e. unlinked tables
SELECT Customers.CustLastName,
    Products.ProductName
FROM Customers CROSS JOIN Products;

-- SQL Standard 2016 lets you separate CROSS JOINed tables using commas
SELECT Customers.CustLastName,
    Products.ProductName
FROM Customers, Products;

/* ******************************************** ****/
/* *** Solving Problems with Unlinked Data      ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Ex. Produce a list of all customer names and address and all products that we
-- sell and indicate the products the customer has already purchased.
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    Customers.CustStreetAddress,
    Customers.CustCity,
    Customers.CustState,
    Customers.CustZipCode,
    Categories.CategoryDescription,
    Products.ProductNumber,
    Products.ProductName,
    Products.RetailPrice,
    (CASE
        WHEN Customers.CustomerID IN
            (SELECT Orders.CustomerID
            FROM Orders
                INNER JOIN Order_Details
                ON Orders.OrderNumber = Order_Details.OrderNumber
            WHERE Order_Details.ProductNumber = Products.ProductNumber)
        THEN 'You purchased this!'
    ELSE ' '
    END) AS ProductOrdered
FROM Customers,
    (Categories
    INNER JOIN Products
    ON Categories.CategoryID = Products.CategoryID)
ORDER BY Customers.CustomerID,
    Categories.CategoryDescription,
    Products.ProductNumber;
-- The FROM clause above is the same as below
-- FROM Customers CROSS JOIN
--     Categories
--     INNER JOIN Products
--     ON Categories.CategoryID = Products.CategoryID

/* ******************************************** ****/
/* *** Solving Problems Using "Driver" Tables   ****/
/* ******************************************** ****/
-- Driver tables are also known as tally tables, and are useful auxiliary tables
-- convenient to drive results or calculations

/* ***** School Scheduling Database ******** */
-- Ex. List all students, the classes for which they enrolled, the grade they
-- received, and a conversion of the grade number to a letter.
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName,
    Classes.ClassID,
    Classes.StartDate,
    Subjects.SubjectCode,
    Subjects.SubjectName,
    Student_Schedules.Grade,
    ztblLetterGrades.LetterGrade
FROM ztblLetterGrades,
    (Students
    INNER JOIN Student_Schedules
    ON Students.StudentID = Student_Schedules.StudentID
    INNER JOIN Classes
    ON Student_Schedules.ClassID = Classes.ClassID
    INNER JOIN Subjects
    ON Classes.SubjectID = Subjects.SubjectID
    INNER JOIN Student_Class_Status
    ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus)
WHERE (Student_Class_Status.ClassStatusDescription = 'Completed')
    AND (Student_Schedules.Grade
        BETWEEN ztblLetterGrades.LowGradePoint AND ztblLetterGrades.HighGradePoint);

/* ***** Sales Orders Database ************* */
-- Ex. Show product sales for each product for all months, listing the months as
-- columns.
SELECT Products.ProductName,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.January) AS January,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.February) AS February,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.March) AS March,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.April) AS April,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.May) AS May,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.June) AS June,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.July) AS July,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.August) AS August,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.September) AS September,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.October) AS October,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.November) AS November,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered *
        ztblMonths.December) AS December
FROM ztblMonths,
    (Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
    INNER JOIN Orders
    ON Orders.OrderNumber = Order_Details.OrderNumber)
WHERE Orders.OrderDate BETWEEN ztblMonths.MonthStart AND ztblMonths.MonthEnd
GROUP BY Products.ProductName;

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/
/* *** Examples Using Unlinked Tables *** */
/* ***** Sales Orders Database ************* */
-- Ex. List all employees and customers who live in the same state and indicate
-- whether the customer has ever placed an order with the employee.
SELECT Employees.EmpFirstName,
    Employees.EmpLastName, 
    Customers.CustFirstName,
    Customers.CustLastName,
    Customers.CustAreaCode,
    Customers.CustPhoneNumber,
    (CASE WHEN Customers.CustomerID IN
        (SELECT Orders.CustomerID
        FROM Orders
        WHERE Orders.EmployeeID = Employees.EmployeeID)
        THEN 'Ordered From you'
    ELSE ' '
    END) AS CustStatus
FROM Employees, Customers
WHERE Employees.EmpState = Customers.CustState;

/* ***** Entertainment Agency Database ***** */
-- Ex. List all customer preferences and the count of first, second, and third
-- preferences.
-- Idea: Generate preferences for each customer ID, then CROSS JOIN with
-- Musical_Styles, and filter the rows to include only preferred values, and
-- then finally count the number of rows for each preference.
SELECT Musical_Styles.StyleID,
    Musical_Styles.StyleName,
    COUNT(RankedPreferences.FirstStyle) AS FirstPreference,
    COUNT(RankedPreferences.SecondStyle) AS SecondPreference,
    COUNT(RankedPreferences.ThirdStyle) AS ThirdPreference
FROM Musical_Styles,
    -- For each customer, create three columns of preferences
    (SELECT (CASE WHEN Musical_Preferences.PreferenceSeq = 1
                THEN Musical_Preferences.StyleID
            ELSE Null END) AS FirstStyle,
        (CASE WHEN Musical_Preferences.PreferenceSeq = 2
            THEN Musical_Preferences.StyleID
        ELSE Null END) AS SecondStyle,
        (CASE WHEN Musical_Preferences.PreferenceSeq = 3
            THEN Musical_Preferences.StyleID
        ELSE Null END) AS ThirdStyle
    FROM Musical_Preferences) AS RankedPreferences
-- Vital! Without this, we would overcount (# customers) times due to CROSS JOIN
WHERE Musical_Styles.StyleID = RankedPreferences.FirstStyle OR
    Musical_Styles.StyleID = RankedPreferences.SecondStyle OR
    Musical_Styles.StyleID = RankedPreferences.ThirdStyle
GROUP BY Musical_Styles.StyleID, Musical_Styles.StyleName
-- Do not include styles that are preferred by none
HAVING COUNT(FirstStyle) > 0 OR
    COUNT(SecondStyle) > 0 OR
    COUNT(ThirdStyle) > 0
ORDER BY FirstPreference DESC,
    SecondPreference DESC,
    ThirdPreference DESC,
    StyleID;

/* ***** School Scheduling Database ******** */
-- Ex. List all students who have completed English courses and rank them by
-- Quintile on the grades they received.
-- Note: This query assumes students only took one English course.
SELECT S1.SubjectID,
    S1.StudFirstName,
    S1.ClassStatus,
    S1.Grade,
    S1.CategoryID,
    S1.SubjectName,
    S1.RankInCategory,
    StudCount.NumStudents,
    (CASE
        WHEN RankInCategory <= 0.2 * NumStudents
            THEN 'First'
        WHEN RankInCategory <= 0.4 * NumStudents
            THEN 'Second'
        WHEN RankInCategory <= 0.6 * NumStudents
            THEN 'Third'
        WHEN RankInCategory <= 0.8 * NumStudents
            THEN 'Fourth'
        ELSE 'Fifth'
    END) AS Quintile
FROM (SELECT Subjects.SubjectID,
    Students.StudFirstName,
    Student_Schedules.ClassStatus,
    Student_Schedules.Grade,
    Subjects.CategoryID,
    Subjects.SubjectName,
        -- Correlated subquery to get student rank within category by counting
        -- rows. Note that this will return ties ordered by lowest rank (i.e.
            -- 1,2,3,5,5,6...), which fortunately is not a problem in this data.
        (SELECT COUNT(*)
        FROM Classes
            INNER JOIN Student_Schedules AS SS2
            ON Classes.ClassID = SS2.ClassID
            INNER JOIN Subjects AS S3
            ON S3.SubjectID = Classes.SubjectID
        WHERE S3.CategoryID = 'ENG'
            AND SS2.Grade >= Student_Schedules.Grade) AS RankInCategory
    FROM Subjects
        INNER JOIN Classes
        ON Subjects.SubjectID = Classes.SubjectID
        INNER JOIN Student_Schedules
        ON Student_Schedules.ClassID = Classes.ClassID
        INNER JOIN Students
        ON Students.StudentID = Student_Schedules.StudentID
    WHERE Student_Schedules.ClassStatus = 2
        AND Subjects.CategoryID = 'ENG') AS S1,
    -- CROSS JOIN
    (SELECT COUNT(*) AS NumStudents
    FROM Classes AS C2
        INNER JOIN Student_Schedules AS SS3
        ON C2.ClassID = SS3.ClassID
        INNER JOIN Subjects AS S2
        ON S2.SubjectID = C2.SubjectID
    WHERE SS3.ClassStatus = 2
        AND S2.CategoryID = 'ENG') AS StudCount
ORDER BY S1.Grade DESC;

/* ***** Bowling League Database *********** */
-- Ex. List all potential matches between teams without duplicating any team
-- pairing.
SELECT Teams.TeamID Team1ID,
    Teams.TeamName Team1Name,
    Teams_1.TeamID Team2ID,
    Teams_1.TeamName Team2Name
FROM Teams, Teams Teams_1
WHERE Teams.TeamID < Teams_1.TeamID
ORDER BY Teams.TeamID, Teams_1.TeamID

-- You can also achieve the above query with an inner join, which is more
-- efficient.
SELECT Teams.TeamID Team1ID,
    Teams.TeamName Team1Name,
    Teams_1.TeamID Team2ID,
    Teams_1.TeamName Team2Name
FROM Teams
    INNER JOIN Teams Teams_1
    ON Teams.TeamID < Teams_1.TeamID
ORDER BY Teams.TeamID, Teams_1.TeamID


/* *** Examples Using Unlinked Tables *** */

/* ***** Sales Orders Database ************* */
-- Ex. The warehouse manager has asked you to print an identification label for
-- each item in stock.
-- Idea: CROSS JOIN up to the maximum number you have in stock and filter to the
-- correct stock number using a WHERE filter
SELECT ztblSeqNumbers.Sequence,
    Products.ProductNumber,
    Products.ProductName
FROM ztblSeqNumbers,
    Products
WHERE ztblSeqNumbers.Sequence <= Products.QuantityOnHand
ORDER BY Products.ProductNumber, ztblSeqNumbers.Sequence;

-- PostgreSQL also has generate_series for this purpose
SELECT nums.Sequence,
    Products.ProductNumber,
    Products.ProductName
FROM (SELECT generate_series(1,60) AS Sequence) nums,
    Products
WHERE nums.Sequence <= Products.QuantityOnHand
ORDER BY Products.ProductNumber, nums.Sequence;

/* ***** Entertainment Agency Database ***** */
-- Ex. Produce a booking calendar that lists for all weeks in January 2018 any
-- engagement during that week.
SELECT ztblWeeks.WeekStart,
    ztblWeeks.WeekEnd,
    Entertainers.EntertainerID,
    Entertainers.EntStageName,
    Customers.CustFirstName,
    Customers.CustLastName,
    Engagements.StartDate,
    Engagements.EndDate
FROM ztblWeeks,
    (entertainmentagencyexample.Customers
        INNER JOIN Engagements
        ON Customers.CustomerID = Engagements.CustomerID
        INNER JOIN Entertainers
        ON Entertainers.EntertainerID = Engagements.EntertainerID)
WHERE ztblWeeks.WeekStart <= '2018-01-31'
    AND ztblWeeks.WeekEnd >= '2018-01-01'
    AND Engagements.StartDate <= ztblWeeks.WeekEnd
    AND Engagements.EndDate >= ztblWeeks.WeekStart;

/* ***** School Scheduling Database ******** */
-- Ex. Display a list of classes by semester, date, and subject.
-- Note: The CASE WHEN tests for <> 0 because TRUE is -1 or 1 depending on DBMS
SELECT ztblSemesterDays.SemesterNo,
    ztblSemesterDays.SemDate,
    Classes.StartTime,
    ztblSemesterDays.SemDayName,
    Subjects.SubjectCode,
    Subjects.SubjectName,
    Class_Rooms.BuildingCode,
    Class_Rooms.ClassRoomID
FROM ztblSemesterDays,
    (Subjects
        INNER JOIN Classes
        ON Subjects.SubjectID = Classes.SubjectID
        INNER JOIN Class_Rooms
        ON Class_Rooms.ClassRoomID = Classes.ClassRoomID)
    WHERE Classes.SemesterNumber = ztblSemesterDays.SemesterNo
        AND Classes.StartDate <= ztblSemesterDays.SemDate
        -- Match correct days
        AND 1 =
        (CASE WHEN ztblSemesterDays.SemDayName = 'Monday'
            AND Classes.MondaySchedule <> 0
            THEN 1
        WHEN ztblSemesterDays.SemDayName = 'Tuesday'
            AND Classes.TuesdaySchedule <> 0
            THEN 1
        WHEN ztblSemesterDays.SemDayName = 'Wednesday'
            AND Classes.WednesdaySchedule <> 0
            THEN 1
        WHEN ztblSemesterDays.SemDayName = 'Thursday'
            AND Classes.ThursdaySchedule <> 0
            THEN 1
        WHEN ztblSemesterDays.SemDayName = 'Friday'
            AND Classes.FridaySchedule <> 0
            THEN 1
        WHEN ztblSemesterDays.SemDayName = 'Saturday'
            AND Classes.SaturdaySchedule <> 0
            THEN 1
        ELSE 0
        END)
ORDER BY ztblSemesterDays.SemesterNo,
    ztblSemesterDays.SemDate,
    Subjects.SubjectCode,
    Class_Rooms.BuildingCode,
    Class_Rooms.ClassRoomID,
    Classes.StartTime;

/* ***** Bowling League Database *********** */
-- Ex. Print a bowler mailing list, but skip the first three labels on the first
-- page that have already been used.
SELECT ' ' AS BowlerLastName,
    ' ' AS BowlerFirstName,
    ' ' AS BowlerAddress,
    ' ' AS BowlerCity,
    ' ' AS BowlerState,
    ' ' AS BowlerZip
FROM ztblSkipLabels
WHERE ztblSkipLabels.LabelCount <= 3
UNION ALL -- Must use UNION ALL or else will return only 1 unique blank label
SELECT BowlerLastName,
    BowlerFirstName,
    BowlerAddress,
    BowlerCity,
    BowlerState,
    BowlerZip
FROM Bowlers
ORDER BY BowlerZip, BowlerLastName;

/* ******************************************** ****/
/* *** Problems For You To Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- 1. “List months and the total sales by products for each month.” 253
-- (Hint: Use the ztblMonths driver table I provided.) 
SELECT ztblMonths.MonthYear,
    Products.ProductName,
    SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) TotalSales
FROM ztblMonths,
    Products
    INNER JOIN Order_Details
    ON Products.ProductNumber = Order_Details.ProductNumber
    INNER JOIN Orders
    ON Orders.OrderNumber = Order_Details.OrderNumber
WHERE Orders.OrderDate BETWEEN ztblMonths.MonthStart AND ztblMonths.MonthEnd
GROUP BY ztblMonths.MonthYear,
    Products.ProductName
ORDER BY ztblMonths.MonthYear,
    Products.ProductName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_product_sales_bymonth';

SELECT ztblmonths.monthyear,
    products.productname,
    sum(((order_details.quantityordered)::numeric *
            order_details.quotedprice)) AS sales
FROM ztblmonths,
    ((products
     JOIN order_details
     ON ((products.productnumber = order_details.productnumber)))
     JOIN orders
     ON ((orders.ordernumber = order_details.ordernumber)))
WHERE ((orders.orderdate >= ztblmonths.monthstart)
    AND (orders.orderdate <= ztblmonths.monthend))
GROUP BY ztblmonths.monthyear, products.productname
ORDER BY ztblmonths.monthyear, products.productname;

-- 2. “Produce a customer mailing list, but skip the five labels already used on
-- the first page of the labels.” 
-- (Hint: Use the ztblSeqNumbers driver table I provided.) 
SELECT ' ' AS CustFirstName,
   ' ' AS CustLastName,
   ' ' AS CustStreetAddress,
   ' ' AS CustCity,
   ' ' AS CustState,
   ' ' AS CustZipCode
FROM ztblSeqNumbers
WHERE Sequence <= 5
UNION ALL
SELECT CustFirstName,
    CustLastName,
    CustStreetAddress,
    CustCity,
    CustState,
    CustZipCode
FROM Customers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_customer_mailing_skip_5';

SELECT ' '::character varying AS custfirstname,
    ' '::character varying AS custlastname,
    ' '::character varying AS custstreenaddress,
    ' '::character varying AS custcity,
    ' '::character varying AS custstate,
    ' '::character varying AS custzipcode
FROM ztblseqnumbers
WHERE (ztblseqnumbers.sequence <= 5)
UNION ALL
SELECT customers.custfirstname,
    customers.custlastname,
    customers.custstreetaddress AS custstreenaddress,
    customers.custcity,
    customers.custstate,
    customers.custzipcode
FROM customers
ORDER BY 6, 2;

-- 3. “The sales manager wants to send out 10% discount coupons for customers who
-- made large purchases in December 2017. Use the ztblPurchaseCoupons table to
-- determine how many coupons each customer gets based on the total purchases for
-- the month.” 
-- (Hint: You need to CROSS JOIN the driver table with the Customers table joined
-- with a subquery that calculates the total spend for each customer.) 
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    SUM(Order_Details.QuantityOrdered *
        Order_Details.QuotedPrice) AS TotPurchased,
    ztblPurchaseCoupons.NumCoupons
FROM Customers
    INNER JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
    INNER JOIN Order_Details
    ON Orders.OrderNumber = Order_Details.OrderNumber,
    ztblPurchaseCoupons
WHERE (Orders.OrderDate BETWEEN '12-01-2017' AND '12-31-2017')
GROUP BY Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    ztblPurchaseCoupons.NumCoupons,
    ztblPurchaseCoupons.lowspend,
    ztblPurchaseCoupons.highspend
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice)
    BETWEEN ztblPurchaseCoupons.lowspend AND ztblPurchaseCoupons.highspend
    
/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_customer_dec_2017_order_coupons';

SELECT ztblpurchasecoupons.numcoupons,
    custdecordertotal.customerid,
    customers.custfirstname,
    customers.custlastname,
    customers.custstreetaddress,
    customers.custcity,
    customers.custstate,
    customers.custzipcode,
    custdecordertotal.purchase
FROM ztblpurchasecoupons,
    (customers
    JOIN ( SELECT orders.customerid,
            sum((order_details.quotedprice *
                    (order_details.quantityordered)::numeric)) AS purchase
           FROM (orders
             JOIN order_details
            ON ((orders.ordernumber = order_details.ordernumber)))
           WHERE ((orders.orderdate >= '2017-12-01'::date)
               AND (orders.orderdate <= '2017-12-31'::date))
          GROUP BY orders.customerid) custdecordertotal
    ON ((customers.customerid = custdecordertotal.customerid)))
WHERE ((custdecordertotal.purchase >= ztblpurchasecoupons.lowspend)
    AND (custdecordertotal.purchase <= ztblpurchasecoupons.highspend));

-- 4. “Using the solution to #3 above, print out one 10% off coupon based on the
-- number of coupons each customer earned.” 
-- (Hint: Use the ztblSeqNumbers driver table that I provided with the query in the
-- above problem.) 
SELECT custdecordertotal.customerid,
    customers.custfirstname,
    customers.custlastname,
    customers.custstreetaddress,
    customers.custcity,
    customers.custstate,
    customers.custzipcode
FROM ztblpurchasecoupons,
    (customers
    JOIN ( SELECT orders.customerid,
            sum((order_details.quotedprice *
                    (order_details.quantityordered)::numeric)) AS purchase
           FROM (orders
             JOIN order_details
            ON ((orders.ordernumber = order_details.ordernumber)))
           WHERE ((orders.orderdate >= '2017-12-01'::date)
               AND (orders.orderdate <= '2017-12-31'::date))
          GROUP BY orders.customerid) custdecordertotal
    ON ((customers.customerid = custdecordertotal.customerid))),
    ztblSeqNumbers
WHERE ((custdecordertotal.purchase >= ztblpurchasecoupons.lowspend)
    AND (custdecordertotal.purchase <= ztblpurchasecoupons.highspend))
    AND ztblSeqNumbers.Sequence <= ztblPurchaseCoupons.NumCoupons;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_customer_discount_coupons_print';

-- 5. “Display all months in 2017 and 2018, all products, and the total sales (if
-- any) registered for the product in the month.” 
-- (Hint: Use a CROSS JOIN between the ztblMonths driver table and the Products
-- table and use a subquery to fetch the product sales for each product and
-- month.) 
SELECT ztblMonths.MonthYear,
    Products.ProductName,
    (SELECT SUM(Order_Details.QuantityOrdered *
                Order_Details.QuotedPrice) AS TotalSales
    FROM Order_Details
        INNER JOIN Orders
        ON Orders.OrderNumber = Order_Details.OrderNumber
    WHERE Order_Details.ProductNumber = Products.ProductNumber
        AND Orders.OrderDate
            BETWEEN ztblMonths.MonthStart AND ztblMonths.MonthEnd)
FROM ztblMonths,
    Products
WHERE (ztblMonths.YearNumber BETWEEN 2017 AND 2018)
ORDER BY Products.ProductName,
    ztblMonths.YearNumber,
    ztblMonths.MonthNumber;
    

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_product_sales_all_months_2017_2018';

SELECT ztblmonths.monthyear,
    products.productname,
    ( SELECT sum(((order_details.quantityordered)::numeric *
                   order_details.quotedprice)) AS svalue
           FROM ((products p2
             JOIN order_details
             ON ((p2.productnumber = order_details.productnumber)))
             JOIN orders
             ON ((orders.ordernumber = order_details.ordernumber)))
          WHERE (((orders.orderdate >= ztblmonths.monthstart)
            AND (orders.orderdate <= ztblmonths.monthend))
            AND (p2.productnumber = products.productnumber))) AS sales
FROM ztblmonths,
    products
WHERE ((ztblmonths.yearnumber >= 2017) AND (ztblmonths.yearnumber <= 2018));

-- 6. “Display all products and categorize them from Affordable to Expensive.” 
-- (Hint: Use a CROSS JOIN with ztblPriceRanges.)
SELECT Products.ProductName,
    Products.RetailPrice,
    ztblPriceRanges.PriceCategory
FROM Products,
    ztblPriceRanges
WHERE Products.RetailPrice BETWEEN ztblPriceRanges.lowprice
    AND ztblPriceRanges.highprice

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch20_product_price_ranges';

SELECT ztblpriceranges.pricecategory,
    products.productname,
    products.retailprice
FROM ztblpriceranges,
    products
WHERE ((products.retailprice >= ztblpriceranges.lowprice)
    AND (products.retailprice <= ztblpriceranges.highprice));

/* ***** Entertainment Agency Database ***** */

-- 1. “List all agents and any entertainers who haven’t had a booking since
-- February 1, 2018, including any contact information and style names.”
-- (Hint: Use a CROSS JOIN between Agents and Entertainers and use NOT IN on a
-- subquery in the WHERE clause to find entertainers not booked since February
-- 1, 2018.) 
-- You can find the solution in CH20_Agents_Entertainers_Unbooked_Feb1_2018 (162 rows).
SELECT Agents.AgentID,
    Agents.AgtFirstName,
    Agents.AgtLastName,
    Entertainers.EntertainerID,
    Entertainers.EntStageName,
    Musical_Styles.StyleName
FROM Agents,
    Entertainers
        INNER JOIN Entertainer_Styles
        ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID 
        INNER JOIN Musical_Styles
        ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
WHERE Entertainers.EntertainerID NOT IN
    (SELECT Engagements.EntertainerID
    FROM Engagements
    WHERE Engagements.StartDate <= '2018-02-01'
        AND Engagements.EndDate >= '2018-02-01');

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_agents_entertainers_unbooked_feb1_2018';

SELECT agents.agentid,
    agents.agtfirstname,
    agents.agtlastname,
    agents.agtstreetaddress,
    agents.agtcity,
    agents.agtstate,
    agents.agtzipcode,
    entertainers.entertainerid,
    entertainers.entstagename,
    entertainers.entphonenumber,
    musical_styles.stylename
   FROM agents,
    ((entertainers
     JOIN entertainer_styles
     ON ((entertainers.entertainerid = entertainer_styles.entertainerid)))
     JOIN musical_styles
     ON ((musical_styles.styleid = entertainer_styles.styleid)))
  WHERE (NOT (entertainers.entertainerid IN
        ( SELECT engagements.entertainerid
          FROM engagements
          WHERE ((engagements.enddate >= '2018-02-01'::date)
            AND (engagements.startdate <= '2018-02-01'::date)))))
ORDER BY agents.agentid, entertainers.entertainerid;

-- 2. “Show all entertainer styles and the count of the first, second, and third
-- strengths.” 
-- (Hint: This is similar to the CH20_Customer_Style_Preference_Rankings query I
-- showed you earlier. Use a CROSS JOIN of the Musical_Styles table with a
-- subquery that “pivots” the strengths into three columns, then count the
-- columns.) 
-- You can find the solution in CH20_Entertainer_Style_Strength_Rankings (17 rows).
SELECT Musical_Styles.StyleID,
    Musical_Styles.StyleName,
    COUNT(RankedStrengths.FirstStyle) AS FirstStrength,
    COUNT(RankedStrengths.SecondStyle) AS SecondStrength,
    COUNT(RankedStrengths.ThirdStyle) AS ThirdStrength
FROM Musical_Styles,
    -- Each row is a StyleID in either first, second, or third strength column
    -- Transposing the data this way lets us count the rows for each column
    (SELECT (CASE WHEN Entertainer_Styles.StyleStrength = 1
                THEN Entertainer_Styles.StyleID
            ELSE NULL END) AS FirstStyle,
            (CASE WHEN Entertainer_Styles.StyleStrength = 2
                THEN Entertainer_Styles.StyleID
            ELSE NULL END) AS SecondStyle,
            (CASE WHEN Entertainer_Styles.StyleStrength = 3
                THEN Entertainer_Styles.StyleID
            ELSE NULL END) AS ThirdStyle 
    FROM Entertainer_Styles) AS RankedStrengths
WHERE Musical_Styles.StyleID = RankedStrengths.FirstStyle OR
    Musical_Styles.StyleID = RankedStrengths.SecondStyle OR
    Musical_Styles.StyleID = RankedStrengths.ThirdStyle
GROUP BY Musical_Styles.StyleID,
    Musical_Styles.StyleName
HAVING COUNT(FirstStyle) > 0 
    OR COUNT(SecondStyle) > 0
    OR COUNT(ThirdStyle) > 0
ORDER BY FirstStrength DESC,
    SecondStrength DESC,
    ThirdStrength DESC,
    StyleID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_entertainer_style_strength_rankings';

SELECT musical_styles.styleid,
    musical_styles.stylename,
    count(rankedpreferences.firststyle) AS firststrength,
    count(rankedpreferences.secondstyle) AS secondstrength,
    count(rankedpreferences.thirdstyle) AS thirdstrength
   FROM musical_styles,
    ( SELECT
        CASE
            WHEN (entertainer_styles.stylestrength = 1)
                THEN entertainer_styles.styleid
            ELSE NULL::integer
        END AS firststyle,
        CASE
            WHEN (entertainer_styles.stylestrength = 2)
                THEN entertainer_styles.styleid
            ELSE NULL::integer
        END AS secondstyle,
        CASE
            WHEN (entertainer_styles.stylestrength = 3)
                THEN entertainer_styles.styleid
            ELSE NULL::integer
        END AS thirdstyle
      FROM entertainer_styles) rankedpreferences
WHERE ((musical_styles.styleid = rankedpreferences.firststyle)
    OR (musical_styles.styleid = rankedpreferences.secondstyle)
    OR (musical_styles.styleid = rankedpreferences.thirdstyle))
  GROUP BY musical_styles.styleid, musical_styles.stylename
HAVING ((count(rankedpreferences.firststyle) > 0)
    OR (count(rankedpreferences.secondstyle) > 0)
    OR (count(rankedpreferences.thirdstyle) > 0))
ORDER BY (count(rankedpreferences.firststyle)) DESC,
    (count(rankedpreferences.secondstyle)) DESC,
    (count(rankedpreferences.thirdstyle)) DESC,
    musical_styles.styleid;

-- 3. “Display customers and their first, second, and third-ranked preferences
-- along with entertainers and their first, second, and third-ranked strengths,
-- then match customers to entertainers when the first or second preference matches
-- the first or second strength.” 
-- (Hint: Create a query on musical styles and customers and pivot the first,
-- second, and third strengths using a CASE expression. You will need to use
-- MAX and GROUP BY because the pivot will return Null values for some of the
-- positions. Do the same with entertainers and musical styles, then CROSS JOIN
-- the two subqueries and return the rows where the preferences and strengths
-- match in the first two positions.)
-- You can find the solution in
-- CH20_Customers_Match_Entertainers_FirstSecond_PrefStrength (6 rows).
-- Note: The problem is misworded in the original text: it should be when first
-- AND second preferences match up
SELECT ES.EntertainerID,
    ES.EntStageName,
    CS.CustomerID,
    CS.CustFirstName,
    CS.CustLastName,
    (SELECT Musical_Styles.StyleName
    FROM Musical_Styles
    WHERE Musical_Styles.StyleID = ES.FirstStyle) AS FirstStyle
FROM
    -- Entertainer Strengths
    (SELECT Entertainers.EntertainerID,
        Entertainers.EntStageName,
        MAX(RankedStrengths.FirstStyle) AS FirstStyle,
        MAX(RankedStrengths.SecondStyle) AS SecondStyle,
        MAX(RankedStrengths.ThirdStyle) AS ThirdStyle
    FROM Entertainers
        RIGHT OUTER JOIN
        (SELECT Entertainer_Styles.EntertainerID,
                (CASE WHEN Entertainer_Styles.StyleStrength = 1
                    THEN Entertainer_Styles.StyleID
                ELSE NULL END) AS FirstStyle,
                (CASE WHEN Entertainer_Styles.StyleStrength = 2
                    THEN Entertainer_Styles.StyleID
                ELSE NULL END) AS SecondStyle,
                (CASE WHEN Entertainer_Styles.StyleStrength = 3
                    THEN Entertainer_Styles.StyleID
                ELSE NULL END) AS ThirdStyle 
        FROM Entertainer_Styles) AS RankedStrengths
        ON Entertainers.EntertainerID = RankedStrengths.EntertainerID
    GROUP BY Entertainers.EntertainerID,
        Entertainers.EntStageName)
        AS ES,
    -- Customer Preferences
    (SELECT Customers.CustomerID,
        Customers.CustFirstName,
        Customers.CustLastName,
        MAX(RankedPreferences.FirstStyle) AS FirstStyle,
        MAX(RankedPreferences.SecondStyle) AS SecondStyle,
        MAX(RankedPreferences.ThirdStyle) AS ThirdStyle
    FROM entertainmentagencyexample.Customers
        RIGHT OUTER JOIN
        (SELECT Musical_Preferences.CustomerID,
                (CASE WHEN Musical_Preferences.PreferenceSeq = 1
                    THEN Musical_Preferences.StyleID
                ELSE Null END) AS FirstStyle,
            (CASE WHEN Musical_Preferences.PreferenceSeq = 2
                THEN Musical_Preferences.StyleID
            ELSE Null END) AS SecondStyle,
            (CASE WHEN Musical_Preferences.PreferenceSeq = 3
                THEN Musical_Preferences.StyleID
            ELSE Null END) AS ThirdStyle
        FROM Musical_Preferences) AS RankedPreferences
        ON Customers.CustomerID = RankedPreferences.CustomerID
    GROUP BY Customers.CustomerID,
        Customers.CustFirstName,
        Customers.CustLastName)
        AS CS
WHERE (ES.FirstStyle = CS.FirstStyle) AND
    (ES.SecondStyle = CS.SecondStyle)
ORDER BY ES.EntStageName,
    CS.CustFirstName,
    CS.CustLastName;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_customers_match_entertainers_firstsecond_prefstrength';

SELECT rankedpreferences.customerid,
    rankedpreferences.custfirstname,
    rankedpreferences.custlastname,
    rankedstrengths.entertainerid,
    rankedstrengths.entstagename,
    rankedpreferences.firstpreference,
    rankedpreferences.secondpreference,
    rankedpreferences.thirdpreference,
    rankedstrengths.firststrength,
    rankedstrengths.secondstrength,
    rankedstrengths.thirdstrength
   FROM ( SELECT customers.customerid,
            customers.custfirstname,
            customers.custlastname,
            max(
                CASE
                    WHEN (musical_preferences.preferenceseq = 1) THEN musical_preferences.styleid
                    ELSE NULL::integer
                END) AS firstpreference,
            max(
                CASE
                    WHEN (musical_preferences.preferenceseq = 2) THEN musical_preferences.styleid
                    ELSE NULL::integer
                END) AS secondpreference,
            max(
                CASE
                    WHEN (musical_preferences.preferenceseq = 3) THEN musical_preferences.styleid
                    ELSE NULL::integer
                END) AS thirdpreference
           FROM (musical_preferences
             JOIN entertainmentagencyexample.customers ON ((musical_preferences.customerid = customers.customerid)))
          GROUP BY customers.customerid, customers.custfirstname, customers.custlastname) rankedpreferences,
    ( SELECT entertainers.entertainerid,
            entertainers.entstagename,
            max(
                CASE
                    WHEN (entertainer_styles.stylestrength = 1) THEN entertainer_styles.styleid
                    ELSE NULL::integer
                END) AS firststrength,
            max(
                CASE
                    WHEN (entertainer_styles.stylestrength = 2) THEN entertainer_styles.styleid
                    ELSE NULL::integer
                END) AS secondstrength,
            max(
                CASE
                    WHEN (entertainer_styles.stylestrength = 3) THEN entertainer_styles.styleid
                    ELSE NULL::integer
                END) AS thirdstrength
           FROM (entertainer_styles
             JOIN entertainers ON ((entertainer_styles.entertainerid = entertainers.entertainerid)))
          GROUP BY entertainers.entertainerid, entertainers.entstagename) rankedstrengths
  WHERE (((rankedpreferences.firstpreference = rankedstrengths.firststrength) AND (rankedpreferences.secondpreference = rankedstrengths.secondstrength)) OR ((rankedpreferences.secondpreference = rankedstrengths.firststrength) AND (rankedpreferences.firstpreference = rankedstrengths.secondstrength)));

-- 4. “List all months across and calculate each entertainer’s income per month.” 
-- (Hint: Use the ztblMonths driver table to pivot the amounts per month and use
-- SUM to total the amounts per entertainer.) 
-- You can find the solution in CH20_Entertainer_BookingAmount_ByMonth (12 rows).
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName,
    SUM(Engagements.ContractPrice * ztblMonths.January) AS January,
    SUM(Engagements.ContractPrice * ztblMonths.February) AS February,
    SUM(Engagements.ContractPrice * ztblMonths.March) AS March,
    SUM(Engagements.ContractPrice * ztblMonths.April) AS April,
    SUM(Engagements.ContractPrice * ztblMonths.May) AS May,
    SUM(Engagements.ContractPrice * ztblMonths.June) AS June,
    SUM(Engagements.ContractPrice * ztblMonths.July) AS July,
    SUM(Engagements.ContractPrice * ztblMonths.August) AS August,
    SUM(Engagements.ContractPrice * ztblMonths.September) AS September,
    SUM(Engagements.ContractPrice * ztblMonths.October) AS October,
    SUM(Engagements.ContractPrice * ztblMonths.November) AS November,
    SUM(Engagements.ContractPrice * ztblMonths.December) AS December
FROM ztblMonths,
    Entertainers
    INNER JOIN Engagements
    ON Entertainers.EntertainerID = Engagements. EntertainerID
WHERE Engagements.StartDate
        BETWEEN ztblMonths.MonthStart AND ztblMonths.MonthEnd
GROUP BY Entertainers.EntertainerID,
    Entertainers.EntStageName;
    
/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_entertainer_bookingamount_bymonth';

SELECT entertainers.entstagename,
    sum((engagements.contractprice * (ztblmonths.january)::numeric)) AS january,
    sum((engagements.contractprice * (ztblmonths.february)::numeric)) AS february,
    sum((engagements.contractprice * (ztblmonths.march)::numeric)) AS march,
    sum((engagements.contractprice * (ztblmonths.april)::numeric)) AS april,
    sum((engagements.contractprice * (ztblmonths.may)::numeric)) AS may,
    sum((engagements.contractprice * (ztblmonths.june)::numeric)) AS june,
    sum((engagements.contractprice * (ztblmonths.july)::numeric)) AS july,
    sum((engagements.contractprice * (ztblmonths.august)::numeric)) AS august,
    sum((engagements.contractprice * (ztblmonths.september)::numeric)) AS september,
    sum((engagements.contractprice * (ztblmonths.october)::numeric)) AS october,
    sum((engagements.contractprice * (ztblmonths.november)::numeric)) AS november,
    sum((engagements.contractprice * (ztblmonths.december)::numeric)) AS december
FROM entertainmentagencyexample.ztblmonths,
    (entertainers
     JOIN engagements
     ON ((entertainers.entertainerid = engagements.entertainerid)))
WHERE ((engagements.startdate >= ztblmonths.monthstart)
    AND (engagements.startdate <= ztblmonths.monthend))
GROUP BY entertainers.entstagename;

-- 5. “Display all dates in December 2017 and any entertainers booked on those
-- days.” 
-- (Hint: Build a subquery using a CROSS JOIN between the ztblDays driver table and
-- a JOIN on entertainers and engagements, then LEFT JOIN that with ztblDays
-- again to get all dates.) 
-- You can find the solution in CH20_All_December_Days_Any_Bookings (79 rows).
SELECT ztblDays.DateField,
    ZE.EntStageName
FROM ztblDays
    LEFT OUTER JOIN
    -- Subquery to get Entertainers
    (SELECT ztblDays.DateField,
        Entertainers.EntStageName
    FROM ztblDays,
        Entertainers
        INNER JOIN Engagements
        ON Entertainers.EntertainerID = Engagements.EntertainerID
    WHERE (ztblDays.DateField
             BETWEEN Engagements.StartDate AND Engagements.EndDate)) AS ZE
    ON ztblDays.DateField = ZE.DateField
WHERE (ztblDays.DateField
           BETWEEN '2017-12-01'::date AND '2017-12-31'::date);

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_all_december_days_any_bookings';

SELECT ztbldays.datefield,
    bd.entertainerid,
    bd.entstagename
FROM (ztbldays
     LEFT JOIN ( SELECT ztbldays_1.datefield,
            entertainers.entertainerid,
            entertainers.entstagename
           FROM ztbldays ztbldays_1,
            (entertainers
             JOIN engagements ON ((entertainers.entertainerid = engagements.entertainerid)))
          WHERE ((ztbldays_1.datefield >= engagements.startdate) AND (ztbldays_1.datefield <= engagements.enddate) AND ((ztbldays_1.datefield >= '2017-12-01'::date) AND (ztbldays_1.datefield <= '2017-12-31'::date)))) bd ON ((ztbldays.datefield = bd.datefield)))
  WHERE ((ztbldays.datefield >= '2017-12-01'::date) AND (ztbldays.datefield <= '2017-12-31'::date));

-- 6. “Produce a customer mailing list, but skip the four labels already used on
-- the first page of labels.” 
-- You can find the solution in CH20_Customer_Mailing_Skip_4 (19 rows).
SELECT ' ' AS CustFirstName,
       ' ' AS CustLastName,
       ' ' AS CustStreetAddress,
       ' ' AS CustCity,
       ' ' AS CustState,
       ' ' AS CustZipCode,
       ' ' AS CustPhoneNumber
FROM ztblSkipLabels
WHERE ztblSkipLabels.LabelCount <= 4
UNION ALL
SELECT Customers.CustFirstName,
    Customers.CustLastName,
    Customers.CustStreetAddress,
    Customers.CustCity,
    Customers.CustState,
    Customers.CustZipCode,
    Customers.CustPhoneNumber
FROM entertainmentagencyexample.Customers

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch20_customer_mailing_skip_4';

SELECT ' '::character varying AS custfirstname,
    ' '::character varying AS custlastname,
    ' '::character varying AS custstreenaddress,
    ' '::character varying AS custcity,
    ' '::character varying AS custstate,
    ' '::character varying AS custzipcode
FROM ztblskiplabels
WHERE (ztblskiplabels.labelcount <= 4)
UNION ALL
SELECT customers.custfirstname,
    customers.custlastname,
    customers.custstreetaddress AS custstreenaddress,
    customers.custcity,
    customers.custstate,
    customers.custzipcode
FROM entertainmentagencyexample.customers
ORDER BY 6, 2;

/* ***** School Scheduling Database ******** */

-- 1. “List all students and the classes they could take, excluding the subjects
-- enrolled or already completed. Be sure to list any subject prerequisite.”
-- (Hint: Do a CROSS JOIN between students and subjects joined with classes, and
-- use a subquery to eliminate classes found in the student schedules table for
-- the current student where the class status in the student schedules table is
-- not 1 (enrolled) or 2 (completed).)
-- You can find the solution in CH20_Students_Additional_Courses (1,894 rows).
SELECT Students.StudFirstName,
    Students.StudLastName,
    Subjects.*
FROM Students,
    Subjects
    INNER JOIN Classes
    ON Subjects.SubjectID = Classes.SubjectID
WHERE Subjects.SubjectID NOT IN
    (SELECT S2.SubjectID
    FROM Subjects S2
        INNER JOIN Classes
        ON S2.SubjectID = Classes.SubjectID
        INNER JOIN Student_Schedules
        ON Classes.ClassID = Student_Schedules.ClassID
    WHERE (Student_Schedules.ClassStatus = 1
        OR Student_Schedules.ClassStatus = 2)
        AND Student_Schedules.StudentID = Students.StudentID
        );

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch20_students_additional_courses';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname,
    subjects.subjectid,
    subjects.categoryid,
    subjects.subjectcode,
    subjects.subjectname,
    subjects.subjectprereq
FROM students,
    (subjects
     JOIN classes ON ((subjects.subjectid = classes.subjectid)))
WHERE (NOT (subjects.subjectid IN ( SELECT su2.subjectid
           FROM ((subjects su2
             JOIN classes classes_1
             ON ((su2.subjectid = classes_1.subjectid)))
             JOIN student_schedules
             ON ((classes_1.classid = student_schedules.classid)))
          WHERE ((student_schedules.studentid = students.studentid)
            AND (student_schedules.classstatus = ANY (ARRAY[1, 2]))))))
  ORDER BY students.studentid, subjects.subjectid;

-- 2. “Display a count of students by gender and marital status by state of
-- residence in columns across.” 
-- (Hint: Use the ztblGenderMatrix and ztblMaritalStatusMatrix driver tables to
-- pivot your values.) 
-- You can find the solution in CH20_Student_Crosstab_Gender_MaritalStatus (4 rows).
SELECT Students.StudState,
    SUM(ztblGenderMatrix.male * ztblMaritalStatusMatrix.Married) AS
        MaleMarried,
    SUM(ztblGenderMatrix.male * ztblMaritalStatusMatrix.Single) AS
        MaleSingle,
    SUM(ztblGenderMatrix.male * ztblMaritalStatusMatrix.Divorced) AS
        MaleDivorced,
    SUM(ztblGenderMatrix.male * ztblMaritalStatusMatrix.Widowed) AS
        MaleWidowed,
    SUM(ztblGenderMatrix.Female * ztblMaritalStatusMatrix.Married) AS
        FemaleMarried,
    SUM(ztblGenderMatrix.Female * ztblMaritalStatusMatrix.Single) AS
        FemaleSingle,
    SUM(ztblGenderMatrix.Female * ztblMaritalStatusMatrix.Divorced) AS
        FemaleDivorced,
    SUM(ztblGenderMatrix.Female * ztblMaritalStatusMatrix.Widowed) AS
        FemaleWidowed,
    SUM(ztblGenderMatrix.Male) AS MaleTotal,
    SUM(ztblGenderMatrix.Female) AS FemaleTotal,
    COUNT(*) AS StateTotal
FROM Students,
    ztblGenderMatrix,
    ztblMaritalStatusMatrix
WHERE Students.StudMaritalStatus = ztblMaritalStatusMatrix.MaritalStatus AND
    Students.StudGender = ztblGenderMatrix.Gender
GROUP BY Students.StudState;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch20_student_crosstab_gender_maritalstatus';

SELECT students.studstate,
    sum((ztblgendermatrix.male * ztblmaritalstatusmatrix.married)) AS marriedmale,
    sum((ztblgendermatrix.male * ztblmaritalstatusmatrix.single)) AS singlemale,
    sum((ztblgendermatrix.male * ztblmaritalstatusmatrix.widowed)) AS widowedmale,
    sum((ztblgendermatrix.male * ztblmaritalstatusmatrix.divorced)) AS divorcedmale,
    sum((ztblgendermatrix.female * ztblmaritalstatusmatrix.married)) AS marriedfemale,
    sum((ztblgendermatrix.female * ztblmaritalstatusmatrix.single)) AS singlefemale,
    sum((ztblgendermatrix.female * ztblmaritalstatusmatrix.widowed)) AS widowedfemale,
    sum((ztblgendermatrix.female * ztblmaritalstatusmatrix.divorced)) AS divorcedfemale,
    sum(((((ztblgendermatrix.male * ztblmaritalstatusmatrix.married) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.single)) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.widowed)) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.divorced))) AS statemaletotal,
    sum(((((ztblgendermatrix.female * ztblmaritalstatusmatrix.married) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.single)) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.widowed)) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.divorced))) AS statefemaletotal,
    sum((((((ztblgendermatrix.male * ztblmaritalstatusmatrix.married) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.single)) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.widowed)) + (ztblgendermatrix.male * ztblmaritalstatusmatrix.divorced)) + ((((ztblgendermatrix.female * ztblmaritalstatusmatrix.married) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.single)) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.widowed)) + (ztblgendermatrix.female * ztblmaritalstatusmatrix.divorced)))) AS statetotal
   FROM ((students
     JOIN ztblmaritalstatusmatrix ON (((students.studmaritalstatus)::text = (ztblmaritalstatusmatrix.maritalstatus)::text)))
     JOIN ztblgendermatrix ON (((students.studgender)::text = (ztblgendermatrix.gender)::text)))
  GROUP BY students.studstate;

-- 3. “Calculate an average proficiency rating for all teaching staff across the
-- subjects they teach and show an overall rating based on the values found in the
-- ztblProfRatings driver table.” 
-- You can find the solution in CH20_Staff_Proficiency_Ratings (24 rows).
SELECT Staff.StfFirstName,
    Staff.StfLastName,
    ztblProfRatings.ProfRatingDesc
FROM ztblProfRatings,
    Faculty_Subjects
    INNER JOIN Staff
    ON Faculty_Subjects.StaffID = Staff.StaffID
GROUP BY Staff.StfFirstName,
    Staff.StfLastName,
    ztblProfRatings.ProfRatingDesc,
    ztblProfRatings.ProfRatingLow,
    ztblProfRatings.ProfRatingHigh
HAVING AVG(Faculty_Subjects.ProficiencyRating)
    BETWEEN ztblProfRatings.ProfRatingLow AND ztblProfRatings.ProfRatingHigh;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch20_staff_proficiency_ratings';

SELECT stfratings.staffid,
    stfratings.stffirstname,
    stfratings.stflastname,
    stfratings.title,
    stfratings.avgrating,
    ztblprofratings.profratingdesc
FROM (ztblprofratings
CROSS JOIN ( SELECT staff.staffid,
       staff.stffirstname,
       staff.stflastname,
       faculty.title,
       avg(faculty_subjects.proficiencyrating) AS avgrating
       FROM ((staff
         JOIN faculty
         ON ((staff.staffid = faculty.staffid)))
         JOIN faculty_subjects
         ON ((faculty.staffid = faculty_subjects.staffid)))
      GROUP BY staff.staffid, staff.stffirstname, staff.stflastname,
                  faculty.title) stfratings)
WHERE ((stfratings.avgrating >= ztblprofratings.profratinglow)
    AND (stfratings.avgrating <= ztblprofratings.profratinghigh));

-- 4. “Create a mailing list for students, but skip the first two labels already
-- used on the first page.” 
-- You can find the solution in CH20_Student_Mailing_Skip_2 (20 rows).
SELECT ' ' AS StudFirstName,
       ' ' AS StudLastName,
       ' ' AS StudStreetAddress,
       ' ' AS StudCity,
       ' ' AS StudState,
       ' ' AS StudZipCode
FROM (SELECT generate_series(1,2)) ztblLabelsToSkip
UNION ALL
SELECT
    Students.StudFirstName,
    Students.StudLastName,
    Students.StudStreetAddress,
    Students.StudCity,
    Students.StudState,
    Students.StudZipCode
FROM Students;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch20_student_mailing_skip_2' ;

 SELECT ' '::character varying AS studfirstname,
    ' '::character varying AS studlastname,
    ' '::character varying AS studstreetaddress,
    ' '::character varying AS studcity,
    ' '::character varying AS studstate,
    ' '::character varying AS studzipcode
   FROM schoolschedulingexample.ztblseqnumbers
  WHERE (ztblseqnumbers.sequence <= 2)
UNION ALL
 SELECT students.studfirstname,
    students.studlastname,
    students.studstreetaddress,
    students.studcity,
    students.studstate,
    students.studzipcode
   FROM students
  ORDER BY 6, 2;

/* ***** Bowling League Database *********** */

-- 1. “Show bowlers and a rating of their raw score averages based on the values
-- found in the ztblBowlerRatings driver table.” 
-- You can find the solution in CH20_Bowler_Ratings (32 rows).
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    ROUND(AVG(Bowler_Scores.RawScore),0) BowlerAvgScore,
    ztblBowlerRatings.BowlerRating
FROM ztblBowlerRatings,
    Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    ztblBowlerRatings.BowlerRating,
    ztblBowlerRatings.BowlerLowAvg,
    ztblBowlerRatings.BowlerHighAvg
HAVING AVG(Bowler_Scores.RawScore)
    BETWEEN ztblBowlerRatings.BowlerLowAvg AND ztblBowlerRatings.BowlerHighAvg;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch20_bowler_ratings';

SELECT bscores.bowlerid,
    bscores.bowlerlastname,
    bscores.bowlerfirstname,
    bscores.bowleraverage,
    ztblbowlerratings.bowlerrating
FROM ztblbowlerratings,
    ( SELECT bowlers.bowlerid,
          bowlers.bowlerlastname,
          bowlers.bowlerfirstname,
            (avg(bowler_scores.rawscore))::integer AS bowleraverage
           FROM (bowlers
             JOIN bowler_scores
             ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
          GROUP BY bowlers.bowlerid, bowlers.bowlerlastname,
            bowlers.bowlerfirstname) bscores
WHERE ((bscores.bowleraverage >= ztblbowlerratings.bowlerlowavg)
    AND (bscores.bowleraverage <= ztblbowlerratings.bowlerhighavg));

-- 2. “List all weeks from September through December 2017 and the location of any
-- tournament scheduled for those weeks.” 
-- You can find the solution in CH20_Tournament_Week_Schedule_2017 (19 rows).
SELECT ztblWeeks.WeekStart,
    ztblWeeks.WeekEnd,
    TourneyWeeks.TourneyID,
    TourneyWeeks.TourneyDate,
    TourneyWeeks.TourneyLocation
FROM ztblWeeks
    LEFT OUTER JOIN
(SELECT ztblWeeks.WeekStart,
    ztblWeeks.WeekEnd,
    Tournaments.*
FROM ztblWeeks, Tournaments
WHERE (ztblWeeks.WeekEnd >= '2017-09-01'
        AND ztblWeeks.WeekStart <= '2018-01-01') AND
    Tournaments.TourneyDate BETWEEN ztblWeeks.WeekStart AND ztblWeeks.WeekEnd)
        AS TourneyWeeks
    ON ztblWeeks.WeekStart = TourneyWeeks.WeekStart AND
        ztblWeeks.WeekEnd = TourneyWeeks.WeekEnd
WHERE ztblWeeks.WeekEnd >= '2017-09-01'
        AND ztblWeeks.WeekStart <= '2018-01-01'
ORDER BY 1,2;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch20_tournament_week_schedule_2017';
