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
* Did you use a name that implicitly or explictly identifies more than one character?
    * Any column using *and* or *or* will typically be doing this
    * Column names with a backslash (\\), hyphen (-), or ampersand (&) will give this away

> In general, regular names should be used, which start with a letter and can only contain letters, numbers, and underscores.
