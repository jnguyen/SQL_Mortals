/* ********** SQL FOR MERE MORTALS CHAPTER 19 ********** */
/* ******** Condition Testing                 ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Conditional Expressions (CASE)           ****/
/* ******************************************** ****/
-- The CASE operator is very flexible and is useful for solving problems where
-- you must evaluate based on a condition

/* ******************************************** ****/
/* *** Solving Problems with CASE               ****/
/* ******************************************** ****/

/* ***** School Scheduling Database ******** */
/* *** Solving Problems With Simple CASE *** */
-- Ex. Prepare a list of IDs, student names, and the gender of the student
-- spelled out.
SELECT StudentID, StudFirstName, StudLastName,
    (CASE StudGender
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'Not Specified'
    END) AS Gender
FROM Students

/* Same query from book view */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch19_student_gender';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname,
        CASE students.studgender
            WHEN 'M'::text THEN 'Male'::text
            WHEN 'F'::text THEN 'Female'::text
            ELSE 'Not Specified'::text
        END AS gender
FROM students;

-- Ex. Display for all students the Student ID, first name, last name, the
-- number of classes completed, the total credits, and the grade point average
-- for classes that were completed with a grade of 67 or better.
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName,
    COUNT(SClasses.StudentID) AS NumberCompleted,
    SUM(SClasses.Credits) AS TotalCredits,
    (CASE COUNT(SClasses.StudentID)
        WHEN 0 THEN 0
        ELSE ROUND((SUM(SClasses.Credits * SClasses.Grade) /
            SUM(SClasses.Credits))::numeric, 3)
    END) AS GPA
FROM Students
    LEFT OUTER JOIN
    (SELECT Student_Schedules.StudentID,
        Student_Schedules.Grade,
        Classes.Credits
    FROM Student_Schedules
        INNER JOIN Student_Class_Status
        ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
        INNER JOIN Classes
        ON Student_Schedules.ClassID = Classes.ClassID
    WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
        AND Student_Schedules.Grade >= 67) AS SClasses
    ON Students.StudentID = SClasses.StudentID
GROUP BY Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName;

/* *** Solving Problems With Searched CASE *** */
-- Ex. For all staff members, list staff ID, first name, last name, date hired,
-- and length of service in complete years as of October 1, 2017, sorted by last
-- name and first name.
SELECT StaffID,
    StfFirstName,
    StfLastName,
    date_part('year', DATE '2017-10-01') - date_part('year', DateHired) -
        (CASE
            WHEN date_part('month', DateHired) < 10
                THEN 0
            WHEN date_part('month', DateHired) > 10
                THEN 1
            WHEN date_part('day', DateHired) > 1
                THEN 1
            ELSE 0
        END) AS LengthOfService
FROM Staff
ORDER BY StfLastName, StfFirstName

-- Ex. Create a student mailing list that includes a generated salutation, first
-- name and last name, the street name, and a city, state, and ZIP code field.
SELECT 
    (CASE
        WHEN StudGender = 'M' THEN 'Mr. '
        WHEN StudMaritalStatus = 'S' THEN 'Ms. '
        ELSE 'Mrs. ' 
    END) || StudFirstName || ' ' || StudLastName
        AS NameLine,
    StudStreetAddress AS StreetLine,
    StudCity || ', ' || StudState || ' ' || StudZipCode AS CityLine
FROM Students;

/* *** Using CASE in a WHERE Clause *** */
-- Ex. List all students who are 'Male'.
SELECT StudentID,
    StudFirstName,
    StudLastName,
    'Male' AS Gender
FROM Students
WHERE ('Male' = (CASE StudGender WHEN 'M' THEN 'Male' ELSE 'Nomatch' END));

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- Ex. List all products and display whether the product was sold in December
-- 2017.
SELECT Products.ProductNumber,
    Products.ProductName,
    (CASE
        WHEN Products.ProductNumber IN
            (SELECT Order_Details.ProductNumber
            FROM Order_Details
                INNER JOIN Orders
                ON Orders.OrderNumber = Order_Details.OrderNumber
            WHERE Orders.OrderDate BETWEEN
                DATE '2017-12-01' AND DATE '2017-12-31') 
        THEN 'Ordered'
    ELSE 'Not Ordered' 
    END) AS ProductOrdered
FROM Products;

-- Ex. Display products and a sale rating based on number sold (poor <= 200
-- sales, Average > 200 and <= 500, Good > 500 and <= 1000, Excellent > 1000).
SELECT Products.ProductNumber,
    Products.ProductName,
    (CASE
        WHEN
            (SELECT SUM(QuantityOrdered)
            FROM Order_Details
            WHERE Order_Details.ProductNumber = Products.ProductNumber) <= 200
        THEN 'Poor'
        WHEN
            (SELECT SUM(QuantityOrdered)
            FROM Order_Details
            WHERE Order_Details.ProductNumber = Products.ProductNumber) <= 500
        THEN 'Average'
        WHEN
            (SELECT SUM(QuantityOrdered)
            FROM Order_Details
            WHERE Order_Details.ProductNumber = Products.ProductNumber) <= 1000
        THEN 'Good'
    ELSE 'Excellent'
    END) AS SalesQuality
FROM Products;

/* ***** Entertainment Agency Database ***** */
-- Ex. List entertainers and display whether the entertainer was booked on
-- Christmas 2017 (December 25).
SELECT Entertainers.EntStageName,
    (CASE
        WHEN Entertainers.EntertainerID IN
            (SELECT Engagements.EntertainerID
            FROM Engagements
            WHERE DATE '2017-12-25' BETWEEN StartDate AND EndDate)
        THEN 'Booked'
    ELSE 'Not Booked'
    END) AS BookedOnXmas
FROM Entertainers;

-- Ex. Find customers who like Jazz but not Standards (using Searched CASE in
-- the WHERE clause).
SELECT Cusotmers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName
FROM entertainmentagencyexample.Customers
WHERE (1 =
    (CASE
        WHEN CustomerID NOT IN
            (SELECT CustomerID
            FROM Musical_Preferences
                INNER JOIN Musical_Styles
                ON Musical_Preferences.StyleID = Musical_Styles.StyleID
            WHERE Musical_Styles.StyleName = 'Jazz')
        THEN 0
        WHEN CustomerID IN
            (SELECT CustomerID
            FROM Musical_Preferences
                INNER JOIN Musical_Styles
                ON Musical_Preferences.StyleID = Musical_Styles.StyleID
            WHERE Musical_Styles.StyleName = 'Standards')
        THEN 0
    ELSE 1
    END));

/* ***** School Scheduling Database ******** */
-- Ex. Show what new salaries for full-time faculty would be if you gave a 5
-- percent raise to instructors, a 4 percent raise to associate professors, and
-- a 3.5 raise to professors.
SELECT Staff.StaffID,
    StfFirstName,
    StfLastName,
    Title,
    Status,
    Salary,
    (CASE Title
        WHEN 'Instructor'
            THEN ROUND(Salary * 1.05, 0)
        WHEN 'Associate Professor'
            THEN ROUND(Salary * 1.04, 0)
        WHEN 'Professor'
            THEN ROUND(Salary * 1.035, 0)
        ELSE Salary
    END) AS NewSalary
FROM Staff
    INNER JOIN Faculty
    ON Staff.StaffID = Faculty.StaffID
WHERE Faculty.Status = 'Full Time';

-- Ex. List all the students, the classes for which they enrolled, the grade
-- they received, and a conversion of the grade number to a letter.
SELECT Students.StudentID,
    Students.StudFirstName,
    Students.StudLastName,
    Classes.ClassID,
    Classes.StartDate,
    Subjects.SubjectCode,
    Subjects.SubjectName,
    Student_Schedules.Grade,
    (CASE
        WHEN Grade BETWEEN 97 AND 100 THEN 'A+'
        WHEN Grade BETWEEN 93 AND 100 THEN 'A'
        WHEN Grade BETWEEN 90 AND 100 THEN 'A-'
        WHEN Grade BETWEEN 87 AND 100 THEN 'B+'
        WHEN Grade BETWEEN 83 AND 100 THEN 'B'
        WHEN Grade BETWEEN 80 AND 100 THEN 'B-'
        WHEN Grade BETWEEN 77 AND 100 THEN 'C+'
        WHEN Grade BETWEEN 73 AND 100 THEN 'C'
        WHEN Grade BETWEEN 70 AND 100 THEN 'C-'
        WHEN Grade BETWEEN 67 AND 100 THEN 'D+'
        WHEN Grade BETWEEN 63 AND 100 THEN 'D'
        WHEN Grade BETWEEN 60 AND 100 THEN 'D-'
        ELSE 'F'
    END) AS LetterGrade
FROM Students
    INNER JOIN Student_Schedules
    ON Students.StudentID = Student_Schedules.StudentID
    INNER JOIN Classes
    ON Student_Schedules.ClassID = Classes.ClassID
    INNER JOIN Subjects
    ON Classes.SubjectID = Subjects.SubjectID
    INNER JOIN Student_Class_Status
    ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
WHERE Student_Class_Status.ClassStatusDescription = 'Completed';

/* ***** Bowling League Database *********** */
-- Ex. List Bowlers and display 'fair' (average < 140), 'average' (average >=
-- 140 and < 160), 'good' (average >= 160 and < 185), 'excellent' (average >=
-- 185.)
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    (CASE
        WHEN AVG(Bowler_Scores.RawScore) < 140 THEN 'Fair'
        WHEN AVG(Bowler_Scores.RawScore) < 160 THEN 'Average'
        WHEN AVG(Bowler_Scores.RawScore) < 185 THEN 'Good'
        ELSE 'Excellent'
    END) AS Rating
FROM Bowlers
    INNER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName;

-- Ex. Show all tournaments with either their match details or "Not Played Yet."
SELECT Tournaments.TourneyID,
    Tournaments.TourneyDate,
    Tournaments.TourneyLocation,
    (CASE
        WHEN tourney_matches.matchid IS NULL
            THEN 'Not Played Yet'::text
        ELSE 'Match: ' || (tourney_matches.matchid)::character(1) ||
            '  Lanes: ' || tourney_matches.lanes ||
            '  Odd Lane Team: ' || teams.teamname ||
            '  Even Lane Team: ' || teams_1.teamname
    END) AS matchinfo
FROM Tourney_Matches
    INNER JOIN Teams
    ON Tourney_Matches.OddLaneTeamID = Teams.TeamID
    INNER JOIN Teams AS Teams_1
    ON Tourney_Matches.EvenLaneTeamID = Teams_1.TeamID
    RIGHT OUTER JOIN Tournaments
    ON Tourney_Matches.TourneyID = Tournaments.TourneyID;

/* ******************************************** ****/
/* *** Problems for You to Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
-- 1; Show all customers and display whether they placed an order in the first
-- week of December 2017.December 1, 2017 and December 7, 2017). 28
-- Hint: Use a Searched CASE and the dates 
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    (CASE WHEN Customers.CustomerID IN
        (SELECT Orders.CustomerID
        FROM Orders
        WHERE Orders.OrderDate BETWEEN DATE '2017-12-01' AND DATE '2017-12-07')
        THEN 'Ordered'
    ELSE 'Not Ordered'
    END) AS Ordered
FROM Customers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch19_customers_ordered_firstweek_dec2017';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname,
    CASE
        WHEN (customers.customerid IN
            ( SELECT orders.customerid
           FROM orders
           WHERE ((orders.orderdate >= '2017-12-01'::date)
             AND (orders.orderdate <= '2017-12-07'::date))))
        THEN 'Ordered'::text
        ELSE 'Not Ordered'::text
    END AS orderedfirstweekdec2017
FROM customers;

-- 2. List customers and the state they live in Spelled out. 28
-- Hint: Use a Simple CASE and look for WA, OR, CA, and TX.
SELECT CustomerID,
    CustFirstName,
    CustLastName,
    (CASE CustState
        WHEN 'WA' THEN 'Washington'
        WHEN 'OR' THEN 'Oregon'
        WHEN 'CA' THEN 'California'
        WHEN 'TX' THEN 'Texas'
    END) AS State
FROM Customers;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch19_customers_state_names';

SELECT customers.custfirstname,
    customers.custlastname,
    CASE customers.custstate
        WHEN 'TX'::text THEN 'Texas'::text
        WHEN 'CA'::text THEN 'California'::text
        WHEN 'OR'::text THEN 'Oregon'::text
        WHEN 'WA'::text THEN 'Washington'::text
        ELSE 'Unknown'::text
    END AS custstatename
FROM customers;

-- 3. Display employees and their age as of February 15, 2018. 8
-- Be sure to use the functions to extract Year, Month, and Day portions of a
-- date value that are suported by your database system.
SELECT Employees.EmployeeID,
    Employees.EmpFirstName,
    Employees.EmpLastName,
    date_part('year', DATE '2018-02-15') -
        date_part('year', Employees.EmpBirthDate) -
        (CASE
            WHEN date_part('month', Employees.EmpBirthDate) < 2
                THEN 0
            WHEN date_part('month', Employees.EmpBirthDate) > 2
                THEN 1
            WHEN date_part('day', Employees.EmpBirthDate) > 15
                THEN 1
            ELSE 0
        END) AS EmpAge
FROM Employees;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'salesordersexample'
AND table_name = 'ch19_employee_age_feb152018';

SELECT employees.employeeid,
    employees.empfirstname,
    employees.emplastname,
    ((date_part('year'::text, '2018-02-15'::date) -
            date_part('year'::text, employees.empbirthdate)) - (
            CASE
                WHEN (date_part('month'::text, employees.empbirthdate) < (2)::double precision)
                    THEN 0
                WHEN (date_part('month'::text, employees.empbirthdate) > (2)::double precision)
                    THEN 1
                WHEN (date_part('day'::text, employees.empbirthdate) > (15)::double precision)
                    THEN 1
                ELSE 0
            END)::double precision) AS empage
FROM employees;

/* ***** Entertainment Agency Database ***** */
-- 1. Display Customers and their preferred styles, but change 50's, 60's, 70's,
-- and 80's music to 'Oldies'.  36
-- Hint: Use a Simple CASE expression
SELECT Customers.CustomerID,
    Customers.CustFirstName,
    Customers.CustLastName,
    (CASE Musical_Styles.StyleName
        WHEN '50''s Music'
        THEN 'Oldies'
        WHEN '60''s Music'
        THEN 'Oldies'
        WHEN '70''s Music'
        THEN 'Oldies'
        WHEN '80''s Music'
        THEN 'Oldies'
    ELSE Musical_Styles.StyleName
    END) AS FavoriteStyle
FROM entertainmentagencyexample.Customers
    INNER JOIN Musical_Preferences
    ON Customers.CustomerID = Musical_Preferences.CustomerID
    INNER JOIN Musical_Styles
    ON Musical_Preferences.StyleID = Musical_Styles.StyleID;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch19_customer_styles_oldies';

SELECT customers.customerid,
    customers.custfirstname,
    customers.custlastname,
    CASE musical_styles.stylename
        WHEN '50''s Music'::text THEN 'Oldies'::character varying
        WHEN '60''s Music'::text THEN 'Oldies'::character varying
        WHEN '70''s Music'::text THEN 'Oldies'::character varying
        WHEN '80''s Music'::text THEN 'Oldies'::character varying
        ELSE musical_styles.stylename
    END AS custstyle
FROM ((entertainmentagencyexample.customers
    JOIN musical_preferences
    ON ((customers.customerid = musical_preferences.customerid)))
    JOIN musical_styles
    ON ((musical_preferences.styleid = musical_styles.styleid)));

-- 2. Find Entertainers who play Jazz but not Contemporary musical styles. 1
-- Hint: Use a Searched CASE in the WHERE clause and be careful to think in the
-- negative.
SELECT Entertainers.EntertainerID,
    Entertainers.EntStageName
FROM Entertainers
WHERE (1 =
    (CASE WHEN Entertainers.EntertainerID NOT IN
        (SELECT Entertainer_Styles.EntertainerID
        FROM Entertainer_Styles
            INNER JOIN Musical_Styles
            ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
        WHERE Musical_Styles.StyleName = 'Jazz')
        THEN 0
        WHEN Entertainers.EntertainerID IN
        (SELECT Entertainer_Styles.EntertainerID
        FROM Entertainer_Styles
            INNER JOIN Musical_Styles
            ON Entertainer_Styles.StyleID = Musical_Styles.StyleID
        WHERE Musical_Styles.StyleName = 'Contemporary')
        THEN 0
    ELSE 1
    END));

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'entertainmentagencyexample'
AND table_name = 'ch19_entertainers_jazz_not_contemporary';

SELECT entertainers.entertainerid,
    entertainers.entstagename
FROM entertainers
WHERE (1 =
    CASE
        WHEN (NOT (entertainers.entertainerid IN
            ( SELECT entertainer_styles.entertainerid
           FROM (entertainer_styles
             JOIN musical_styles
             ON ((entertainer_styles.styleid = musical_styles.styleid)))
          WHERE ((musical_styles.stylename)::text = 'Jazz'::text))))
          THEN 0
        WHEN (entertainers.entertainerid IN
            ( SELECT entertainer_styles.entertainerid
           FROM (entertainer_styles
             JOIN musical_styles
             ON ((entertainer_styles.styleid = musical_styles.styleid)))
          WHERE ((musical_styles.stylename)::text = 'Contemporary'::text)))
          THEN 0
        ELSE 1
    END);

/* ***** School Scheduling Database ******** */
-- 1. Display student Marital Status based on a code. 18
-- Hint: Use Simple CASE in the SELECT clause. M = Married, S = Single, D =
-- Divorced, W = Widowed.
SELECT StudentID,
    StudFirstName,
    StudLastName,
    (CASE StudMaritalStatus
        WHEN 'M' THEN 'Married'
        WHEN 'S' THEN 'Single'
        WHEN 'D' THEN 'Divorced'
        WHEN 'W' THEN 'Widowed'
    END)
FROM Students

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch19_student_marital_status';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname,
        CASE students.studmaritalstatus
            WHEN 'M'::text THEN 'Married'::text
            WHEN 'S'::text THEN 'Single'::text
            WHEN 'W'::text THEN 'Widowed'::text
            WHEN 'D'::text THEN 'Divorced'::text
            ELSE 'Not Specified'::text
        END AS gender
FROM students;

-- 2. Calculate student age as of November 15, 2017. 18
-- Be sure to use the functions to extract Year, Month, and Day portions of a
-- date value that are suported by your database system.
SELECT StudentID,
    StudFirstName,
    StudLastName,
    date_part('year', '2017-11-15'::date) -
        date_part('year', StudBirthDate) -
        (CASE
            WHEN date_part('month', StudBirthDate) < 11
                THEN 0
            WHEN date_part('month', StudBirthDate) > 11
                THEN 1
            WHEN date_part('day', StudBirthDate) > 15
                THEN 1
            ELSE 0
        END) AS StudAge
FROM Students;

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'schoolschedulingexample'
AND table_name = 'ch19_student_age_nov15_2017';

SELECT students.studentid,
    students.studfirstname,
    students.studlastname,
    students.studbirthdate,
    ((date_part('year'::text, '2017-11-15'::date) -
            date_part('year'::text, students.studbirthdate)) -
        (CASE
            WHEN (date_part('month'::text, students.studbirthdate) <
                (11)::double precision) THEN 0
            WHEN (date_part('month'::text, students.studbirthdate) >
                (11)::double precision) THEN 1
            WHEN (date_part('day'::text, students.studbirthdate) >
                (15)::double precision) THEN 1
            ELSE 0
        END)::double precision) AS studage
FROM students;

/* ***** Bowling League Database *********** */
-- 1. List all bowlers and calculate their averages using the sum of pins
-- divided by games played, but avoid a divide by zero error. 32
-- Hint: Use a Simple CASE in a query using OUTER JOIN and GROUP BY.
SELECT Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName,
    -- If no matches exist, return 0. Otherwise, calculate average and round.
    (CASE WHEN (COUNT(Bowler_Scores.MatchID) = 0) THEN 0
    ELSE ROUND(SUM(Bowler_Scores.RawScore)::numeric / 
            COUNT(Bowler_Scores.MatchID)::numeric, 0)
    END) AS BowlerAvgScore
FROM Bowlers
    LEFT OUTER JOIN Bowler_Scores
    ON Bowlers.BowlerID = Bowler_Scores.BowlerID
GROUP BY Bowlers.BowlerID,
    Bowlers.BowlerFirstName,
    Bowlers.BowlerLastName
    
/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch19_bowler_averages_avoid_0_games';

SELECT bowlers.bowlerid,
    bowlers.bowlerfirstname,
    bowlers.bowlerlastname,
    count(bowler_scores.matchid) AS gamesbowled,
    sum(bowler_scores.rawscore) AS totalpins,
        CASE count(bowler_scores.matchid)
            WHEN 0 THEN 0
            ELSE ((sum(bowler_scores.rawscore) / count(bowler_scores.matchid)))::integer
        END AS bowleraverage
   FROM (bowlers
     LEFT JOIN bowler_scores
     ON ((bowlers.bowlerid = bowler_scores.bowlerid)))
GROUP BY bowlers.bowlerid, bowlers.bowlerfirstname, bowlers.bowlerlastname;

-- 2. List tournament date, tournament location, match number, teams on the odd
-- and even lanes, game number, and either the winner or 'Match not played.'
-- Hint: Use an outer join between tournaments, tourney matches, and a second
-- copy of teams with a subquery using match games and a third copy of teams to
-- indicate the winning team. Use a Searched Case to decide whether to display
-- "not played" or the match results in the SELECT list.
SELECT Tournaments.TourneyID,
    Tournaments.TourneyDate,
    Tournaments.TourneyLocation,
    Tourney_Matches.MatchID,
    MG2.GameNumber,
    Teams.TeamName AS OddLaneTeam,
    Teams_1.TeamName AS EvenLaneTeam,
    (CASE WHEN (Tourney_Matches.MatchID IS NULL) THEN 'Match Not Played'
    ELSE MG2.TeamName
    END) AS Winner
FROM Tournaments 
    INNER JOIN Tourney_Matches
    ON Tournaments.TourneyID = Tourney_Matches.TourneyID
    INNER JOIN Teams
    ON Tourney_Matches.OddLaneTeamID = Teams.TeamID
    INNER JOIN Teams Teams_1
    ON Tourney_Matches.EvenLaneTeamID = Teams_1.TeamID
    LEFT OUTER JOIN
    (Match_Games
        INNER JOIN Teams Teams_2
        ON Match_Games.WinningTeamID = Teams_2.TeamID) MG2
    ON Tourney_Matches.MatchID = MG2.MatchID

/* Book Answer */
SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'bowlingleagueexample'
AND table_name = 'ch19_all_tourney_matches';

SELECT tournaments.tourneydate,
    tournaments.tourneylocation,
    tourney_matches.lanes,
    tourney_matches.matchid,
    teams.teamname AS oddlaneteam,
    teams_1.teamname AS evenlaneteam,
    gameresults.gamenumber,
        CASE
            WHEN (gameresults.teamname IS NULL) THEN 'Match not played'::character varying
            ELSE gameresults.teamname
        END AS winner
   FROM ((((tournaments
     JOIN tourney_matches ON ((tournaments.tourneyid = tourney_matches.tourneyid)))
     JOIN teams ON ((tourney_matches.oddlaneteamid = teams.teamid)))
     JOIN teams teams_1 ON ((tourney_matches.evenlaneteamid = teams_1.teamid)))
     LEFT JOIN ( SELECT match_games.matchid,
            match_games.gamenumber,
            teams_2.teamname
           FROM (match_games
             JOIN teams teams_2 ON ((match_games.winningteamid = teams_2.teamid)))) gameresults ON ((tourney_matches.matchid = gameresults.matchid)))
  ORDER BY tournaments.tourneydate, tourney_matches.matchid, gameresults.gamenumber;
