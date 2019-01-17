/* ********** SQL FOR MERE MORTALS CHAPTER 18 ********** */
/* ******** Introduction to Solving Tough Problems ***** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** Finding Out the "NOT" Case               ****/
/* ******************************************** ****/
-- Using OUTER JOIN
-- Ex. List ingredients not used in any reicpe yet.
SELECT Ingredients.IngredientName
FROM Ingredients
    LEFT OUTER JOIN Recipe_Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipe_Ingredients.RecipeID IS NULL;

--- Solving 3 "NOT" conditions at the same time
-- OUTER JOIN + subquery
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot'))
        AS RBeefCarrotOnion
    ON Recipes.RecipeID = RBeefCarrotOnion.RecipeID
WHERE RBeefCarrotOnion.RecipeID IS NULL;

-- NOT IN
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Beef')
    AND Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Onion')
    AND Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName = 'Carrot')

-- NOT IN, more elegant
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
-- Note: Nice and efficient because subquery only run once
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID NOT IN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot'));

-- NOT EXISTS
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
-- Note: Inefficient because subquery ran for each row
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
WHERE NOT EXISTS
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')
        AND Recipe_Ingredients.RecipeID = Recipes.RecipeID);

-- Using GROUP BY/HAVING
-- Ex. Find the recipes that have neither beef, nor onions, nor carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS RIBOC
    ON Recipes.RecipeID = RIBOC.RecipeID
WHERE RIBOC.RecipeID IS NULL
GROUP BY Recipes.RecipeID, Recipes.RecipeTitle
HAVING COUNT(RIBOC.RecipeID) = 0;

-- Ex. Find the recipes that have butter but have neither beef, nor onion, nor
-- carrots.
SELECT Recipes.RecipeID,
    Recipes.RecipeTitle
FROM Recipes
    INNER JOIN Recipe_Ingredients
    ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
    INNER JOIN Ingredients
    ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    LEFT OUTER JOIN
    (SELECT Recipe_Ingredients.RecipeID
    FROM Recipe_Ingredients
        INNER JOIN Ingredients
        ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
    WHERE Ingredients.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS RIBOC
    ON Recipes.RecipeID = RIBOC.RecipeID
WHERE Ingredients.IngredientName = 'Butter'
    AND RIBOC.RecipeID IS NULL
    GROUP BY Recipes.RecipeID, Recipes.RecipeTitle
HAVING COUNT(RIBOC.RecipeID) = 0;

/* ******************************************** ****/
/* *** Finding Multiple Match in the Same Tables ***/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Sample Statements                        ****/
/* ******************************************** ****/

/* ******************************************** ****/
/* *** Problems for You to Solve                ****/
/* ******************************************** ****/

/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
