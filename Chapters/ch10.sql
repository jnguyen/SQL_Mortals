/* ********** SQL FOR MERE MORTALS CHAPTER 10 ********** */
/* ******** UNIONS                            ********** */
/* ***************************************************** */

/* ******************************************** ****/
/* *** What is a union?                         ****/
/* ******************************************** ****/
-- TIP: If you are sure duplicates aren't possible, always use UNION ALL for
-- better performance.

/* ******************************************** ****/
/* *** Writing Requests With UNION              ****/
/* ******************************************** ****/
/* *** Using Simple SELECT Statements           ****/
-- TIP: UNION CORRESPONDING is an upcoming feature to only use columns of same
-- name when performing the UNION operation

-- Ex. Buoild a single mailing list that consists of the name, address, city,
-- state, and ZIP Code for customers and the name, address, city, state, and ZIP
-- Code for vendors
SELECT Customers.CustLastName || ', ' || Customers.CustLastName AS MailingName,
    Customers.CustStreetAddress, Customers.CustCity, Customers.CustState,
    Customers.CustZipCode
FROM Customers
    UNION
SELECT Vendors.VendName,
    Vendors.VendStreetAddress, Vendors.VendCity, Vendors.VendState,
    Vendors.VendZipCode
FROM Vendors;

/* ***** Sales Orders Database ************* */
/* ***** Entertainment Agency Database ***** */
/* ***** School Scheduling Database ******** */
/* ***** Bowling League Database *********** */
/* ***** Recipes Database ****************** */
