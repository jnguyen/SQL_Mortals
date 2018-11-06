/* ********** SQL FOR MERE MORTALS CHAPTER 7 *********** */
/* ******** Thinking In Sets                  ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Header                                   ****/
/* ******************************************** ****/
/* ***** Sales Orders Database ************* */
-- Show me all orders with both bikes and helmets.
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (1, 2, 6, 11)
INTERSECT
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (10, 25, 26);

-- Show me all orders with bikes but not helmets
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (1, 2, 6, 11)
EXCEPT
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (10, 25, 26);

-- Show me all orders with helmets but not bikes
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (10, 25, 26)
EXCEPT
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (1, 2, 6, 11);

-- Show me all orders with helmets and bikes
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (10, 25, 26);
UNION
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (1, 2, 6, 11)

-- Note: you don't actually need a UNION above
SELECT DISTINCT OrderNumber
FROM Order_Details
WHERE ProductNumber IN (1, 2, 6, 10, 11, 25, 26);
