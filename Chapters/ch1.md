# SQL For Mere Morals 4th Ed
## Chapter 1: What is Relational?
### Types of Databases
There are two types of operational databases
* Operational Database: used to collect, modify, and maintain data on a day-to-day basis, serving as the backbone for many companies, organizations, and institutions
* Analytical Database: stores and tracks hitorical and time-dependent data, used for tracking trends, viewing statistics over a long period, and projections

### A Brief History Of The Relational Model
This book focuses on the relational model for databases.

#### In the beginning...
* Dr. Edgar F. Codd invented ideas that would lead to relational models for databases
* *Relation* is actually related to a part of set theory, and refers generally to tables

#### Relational Database Systems
* A relational database management system (RDBMS) is a software application used to create, maintain, modify, and manipulate a relational database
* IBM proposed data warehouses, in which organizations could access data stored in any number of nonrelational databases
* William H. Inmon is seen as the father of data warehouses and was instrumental in its evolution 

### Anatomy of A Relational Database
Data are stored in *relations*, seen by users as tables. Each relation is composed of *tuples*, i.e. records or rows, as well as *attributes*, or columns.

#### Tables
Tables always represent a single, specific subject. There is no inherent order to tables in a relational design.
* At least one column, called the *primary key*, ensures uniqueness of each row
