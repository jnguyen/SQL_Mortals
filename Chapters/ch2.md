# SQL For Mere Morals 4th Ed

## Chapter 2: Ensuring Your Database Structure Is Sound

### Why Is This Chapter Here?
If your database is not sound, SQL commands will be relatively useless or ineffective. The point of this chapter is to teach the logical design of a sound database.

### Why Worry About Sound Structures?
When a database structure isn't sound
* You'll have problems retrieving seemingly simple information
* It'll be difficult to work with your data
* Adding or deleting columns will be a pain

### Fine-Tuning Columns
#### What's in a Name? (Part One)
Make sure to name a column after what it's supposed to represent. Use the following checklist to test your column names:
* Is the name descriptive and meaningful to your entire organization?
    * Emphasis on entire: no one should be guessing
* Is the column name clear and unambiguous?
    * E.g. PhoneNumber is ambiguous, use HomePhone, WorkPhone, CellPhone, etc. instead
        * Or better yet, make a separate table called phone, have multiple phone numbers per ID, and have a column that codes what kind of phone it is 

Avoid using the same column name. If you have to include a column name that may be repeated but not with the same information, say, City or State, in several tables, such as Vendors or Customers, append the table name to the column. For example:
* City -> VendCity; CustCity
* State -> VendState; CustState
> **Remember**: Make sure that each column in the database has a unique name and that it only appears once in the entire database structure.

Some designers will choose to prefix only generic names, while others will prefix all names. Whatever you do, just be consistent.

Here are some questions to probe your column names:
* Did you use an acronym or abbreviation as a column name?
    * If yes, don't, silly! Use abbreviations sparingly.
    * Only use abbreviations if it unambiguously enhances the column name's meaning
* Did you use a name that implicitly or explicitly identifies more than one character?
    * Any column using *and* or *or* will typically be doing this
    * Column names with a backslash (\\), hyphen (-), or ampersand (&) will give this away

> **Note**: In general, regular names should be used, which start with a letter and can only contain letters, numbers, and underscores.

Try to name your columns in singular form, i.e. with a single word. Of course, adhere to any naming conventions that are present for your specific RDBMS.

#### Smoothing Out the Rough Edges
Test your columns against the checklist to ensure efficiency:
* Make sure the columns represents a specific characteristic of the subject of the table
    * The column should be germane to the table
* Make certain that the column contains only a single value
    * A column that can store several instances of the same type of value is a *multivalued column*, i.e. multiple phone numbers
    * A column that can store two or more distinct values is known as a *multipart column*, i.e. item number with item description
        * Multivalued and multipart columns wreak havoc on your database when trying to edit, sort, or delete data
* Make sure the column does not store the result of a calculation or concatenation
    * Calculated columns are not allowed in a properly designed table
    * When columns are updated, dependent calculated columns are not automatically updated
        * Calculations should be incorporated into a SELECT statement
* Make certain the column appears only once in the entire database
    * You will get inconsistent data if columns are unnecessarily duplicated
        * For example, you update the column in one table, but all other columns remain unupdated!
> **Note**: Some RDMBSs include calculated columns as a feature, but this may take additional resources to keep the values current.

#### Resolving Multipart Columns
You know you have a multipart column issue when you can take any column and break it up into smaller, distinct parts. For example:
* Full names can be broken up into two columns: FirstName, LastName
* Street addresses can be broken up into their parts: Street, City, State, ZipCode, etc.
* Phone numbers may also be multipart

For phone numbers, you might want to break it up into international code, area code, and then the local phone number, since this may aid analyses of demographic data.

Sometimes, multipart columns can be subtle, like having a concatenated product code and number, i.e. "GUIT100" and "AMP100"-- there is a product name and a product number.

#### Resolving Multivalued Columns
Typically, you'll find multivalued columns containing commas, semicolons, or other separator characters to demarcate multivalued data. For example, you might have a column called `Certifications` where a value may be `727, 737, 757, MD80`, with each certification separated by a comma.

Before resolving, understand the relationships of the multivalued rows. For example, there may be a many-to-many relationship requiring a linking table. In the example above, we could use `PilotID` together with `Certifications` in its own table giving a row for every certification. We then take those two columns together as a primary key for a linking table, `Pilot_Certifications`, to resolve the multivalued column.

### Fine-Tuning Tables
Ensuring that tables are properly designed will make sure that multi-table SQL queries don't go awry.
#### What's in a Name? (Part Two)
A table should represent a single subject. If it represents more than one subject, then break it into smaller constituent tables. Use the following checklist to help determine if a table has been named well:
* Is the name unique and descriptive enough to be meaningful to your entire organization?
* Does the name accurately, clearly, and unambiguously identify the subject of the table?
* Does the name contain words that convey physical characteristics?
    * Don't include words like *file*, *record*, and *table* in the table name, as doing so will introduce confusion.
* Did you use an acronym or abbreviation as a table name?
    * If so, change it now!
* Did you use a name that implicitly or explicitly identifies more than one subject?
    * Table names with a backslash (\\), hyphen (-), or ampersand (&) will give this away
    * Deconstruct the table if needed into constituent tables

Use the plural form for a table, so you know that it refers to a *collection of instances*, e.g. `Employees`, `Vendors`.

#### Ensuring a Sound Structure
Use the following checklist to determine that your table structures are sound:
* Make sure that the table represents a single subject.
    * For example, `Doctors_Appointments` would contain appointment time, blood pressure, etc.
* Make certain each table has a primary key.
* Make sure the table does not contain any multipart of multivalued columns.
* Make sure there are no calculated columns in the table.
* Make certain the table is free of any unnecessary duplicate columns.

#### Resolving Unnecessary Duplicate Columns
Remove duplicate columns that can be obtained via SQL queries. For example, you don't need the `StaffFirstName` and `StaffLastName` in the `Classes` table if you already have that information in the `Staff` table.

In general, you want every piece of data to appear once in the database, except for when establishing relationships between tables (i.e. foreign keys). 

Good example: employee example in the book with committee names spread over multiple columns. There is a `Staff` table and a `Classes` table. Since the IDs of staff members can be easily linked to the class IDs, there's no reason to include staff name in both tables. Since the `Staff` table deals with information on staff members, it makes sense to leave StaffFirst and StaffLastName in the `Staff` table.

#### Identification Is The Key
Primary keys ensure that rows are unique and identifiable, so think about them carefully.
* *Simple Primary Key*: single column primary key
* *Composite Primary Key*: multiple column primary key

In general, it's better to use a simple primary key when possible, and reserve composite primary keys for appropriate cases, such as linking tables.

Use this checklist to determine if your primary keys are sound:
* Do the columns uniquely identify each row in the table?
* Does this column or combination of columns contain unique values?
* Will these columns ever contain unknown values?
* Can the value of these columns ever be optional?
* Is this a multipart column?
* Can the value of these columns ever be modified?

Artificial primary keys, such as an incrementing ID number, are an easy way to solve an identifiability issue. Still, make sure to have a routine that checks for potential duplicate names. 

### Establishing Solid Relationships 
There are three primary kinds of relationships.
* **One-to-one**: The primary key in one table is set into the subordinate table, so that every row in one corresponds to exactly one in the other.
* **One-to-many**: Any row of a primary key column can be found many times in a foreign key of another.
* **Many-to-many**: Two tables combine their primary keys in a linking table to resolve the fact that arbitrary number of rows of one can correspond to arbitrary numbers of the other. Each primary key serves as a foreign key.

Note: related columns used to link two tables must be the same data type. The only exception to this rule are primary keys automatically generated by the database system.

Make sure to consult your specific RDBMS for how it handles *referential integrity*, or how to enforce relationships.

#### Establishing a Deletion Rule
A *deletion rule* defines what happens when one row in a primary table is deleted. This rule protects against *orphaned rows*. There are two types.

* **Restrict**: You cannot delete a primary row unless you delete its subordinate rows.
* **Cascade**: Deleting one row deletes all subordinate rows.

A simple question can help you decide: If a row in [name of primary or 'one' side table] is deleted, should related rows in [name of subordinate or 'many' side table] be deleted as well?

#### Setting the Type of Participation
When establishing a relationship between two tables, they have a *type of participation* that determines whether a row must exist in one to exist in the other.
* **Mandatory**: At least one row must exist in this table before you can enter any rows into the other table.
* **Optional**: There is no requirement for any rows to exist in this table before you enter any rows in the other table.

For example: to add staff to a new R&D department, you need to add the department before you can assign staff. So, the relationship between tables `Department` and `Department_Employees` should be optional.

#### Setting the Degree of Participation
Next, you decide to what *degree of participation* the tables have. This is determined by a tuple, where the first number indicates the minimum possible number of related rows, and the second number indicates the maximum number of related rows. For example, (1,12) means a minimum of 1 row and maximum of 12 rows.

For example, you might say that an agent can be related to many entertainers, but entertainers should only be related to one agent at a time.

Usually the "many" side will be infinite, but sometimes there is a business need to limit the rows. For example: only six entertainers per agent. Putting this together:
* Agents (1,1): Only one entertainer per agent
* Entertainer (0,6): An agent may have no entertainers, or up to six.

### Is That All?
While fixing a DB is good, it's better to design it right from the start.

### Summary
Having a sound database ensures everything runs smoothly by avoiding problems with database integrity, identifiability, and so on.

Topics covered:
* Why have a sound database?
* Multipart and multivalued columns
* Fine-tuning columns
* Primary keys
* Solid relationships
    * Type and degree of participation
    * Mandatory or optional
