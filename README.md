# management-sandbox
## Shiny Application for Manage Replicas to a Sandbox Environment

Developed using the [Shiny Package](https://shiny.posit.co) (a library which allow us to create Web Applications in R or Python languages) the main purpose of the "management-sandbox" app is to work as a Replication Data Hub to move Data from a Source Production Relational Database to a "mirror" environment called Sandbox.

This repository includes the code files that compose the Shiny Application, it's User Database and an Informational Example Data Base to test the functionalities of the Software.

## Prerequisites

The application was developed using the following software versions:

|Software|Version|
|--------|-------|
| R      | 4.2.2 |
| PostgreSQL| 17.4|

Libraries versions:

|Software|Library|Version|
|--------|-------|-------|
|R|shiny|1.7.4|
|R|shinyjs|2.1.1|
|R|shinymanager|1.0.410|
|R|htmltools|0.5.4|
|R|shinyWidgets|0.9.1|
|R|tidyverse|1.3.2|
|R|DBI|1.3.0|
|R|Shiny|1.4.10|
|PostgreSQL|pgcrypto|1.4|


## Introduction (Use case)

Supposing that we have a Production Environment that hosts an Analytical Database that stores enterprise Data, and a Sandbox Environment that mirrors the Production instance to allow Data teams, such as Data Analysts and Data Scientists, to run "heavy-weight" tests for developing Models and Explorations without competing with the operational processes for computational resources, the "management-sandbox" app offers a solution to manage the data replications needed to maintain the Sandbox ecosystem up to date againts any updates in the information that could occur in Production.

## Architecture

Initially, a 2 tier architecture is proposed for the application, having a PostgreSQL Database (SandboxAppManagement) where we're going to store the information related to user's credentials. This will enable to add a secure layer to the software requesting user name and password to the user who will use the application. The password values for each user will be encrypted using the [pgcrypto](https://www.postgresql.org/docs/current/pgcrypto.html) module, which is a PostgreSQL extension that "provides cryptographic functions".

For the Analytical Ecosystem, it is assumed that the Production and Sandbox databases are located on two different servers, so it would be necessary to ensure the communication between the application and both servers, and a ODBC connection for each database. Also, in each database will be created a Role with different privileges for the operations that the application can execute, ensuring that in the Production database can perform "Read-Only" transactions, meanwhile in the Sandbox environment it's allowed to perform "Read / Write" commands.

![Application Architecture](assets/sandbox-management-hub-architecture.png)

## The "Bank of Trust" example and the Analytical Model

Using the [BIAN Service Domain Landscape](https://bian.org/servicelandscape-12-0-0/views/view_51891.html) and Kimball's Dimensional Aproach [^1] as a reference for Designing our Relational Data Model for a fictitional Banking Institution called "Bank of Trust", we can test our application on the following objects:

### ERD Diagram

![Application Architecture](assets/erd-data-analytical-model.png)

### Data Catalog

*Schemas*

- Operations: Store information related to product fulfillment activities for wholesale and retail Banking, including Loans and Deposits, Cards, Market Operations, etc.
- SalesServices: Store information related to business development, marketing, customer management, cross chanel and sales activities.
- BusinessSupport: Store information related to general business management and support activities that are not specific to Banking, including Human Resoruce Management, Finance, IT Management, Building Equipment, etc.

*Tables*

- CustomersCatalog (Dimension Table): Store the Customers' relevant information, such as Name, Ocuppation, Opening Date for their accounts, etc.
- EmployeesCatalog (Dimension Table): Store the relevant information of the Bank's Employees, such as Names, Status, Start Date, etc.
- ConsumerLoanData (Fact Table): Store the Oustanding Balance at the end of the Month for the Loan Accounts of the Customers in the BoT.
- CreditCardsTransactions (Fact Table): Store the information of the Daily Transactions that are made by the customers specifically for the Credit Card product.

## Initial Configuration

As we are working on the idea of three separate PostgreSQL instances (two for the Analytical Databses and one for the Application Database), we'll need to configure three ODBC connections for the application. If you want to try the functionality of the app in you local environment, you can download and install three PostgreSQL versions from the [official site](https://www.postgresql.org/download/) and assign each version a different port or use [Docker's PostgreSQL Image](https://hub.docker.com/_/postgres) to configure three different containers.

### Analytical Model - Creation.

[Analytical Model DDL Scripts](sql/ddl/analytical-model)

Once we have our PostgreSQL instances running, we proceed to create the Analytical Data Models following this instructions:

1. Create the Database with the CREATE_DB_bot-datacenter.sql script, in each instance.
2. Create the Schemas with the CREATE_SCHEMAS.sql script, in each database.
3. For each instance, run the following scripts to create the Tables:
  - For the creation of the Data Model in the "Production" environment, run the CREATE_TABLES_AnalyticalModel_Production.sql script.
  - For the creation of the Data Model in the "Sandbox" environment, run the CREATE_TABLES_AnalyticalModel_Sandbox.sql script.

### Analytical Model - Privileges Configuration.

[Analytical Model DCL Scripts](sql/dcl/analytical-model)

1. With the ROLE_CONFIGURATION_Production.sql script, use the following line to create the Production Database Role choosing a username and password:

``` SQL
-- 1. Create a Role for the user with read access to the source database.

CREATE ROLE user_name WITH LOGIN PASSWORD 'password';
```

Once you generated the Database Role, run the other commands to give the corresponding "read-only" privileges.

2. With the ROLE_CONFIGURATION_Sandbox.sql script, use the following line to create the Sandbox Database Role choosing a username and password:

``` SQL
-- 1. Create a Role for the user with read/write access to the destination database.

CREATE ROLE user_name WITH LOGIN PASSWORD 'password';
```

Once you generated the Database Role, run the other commands to give the corresponding "read / write" privileges.


## References

[^1]: Kimball, R., & Ross, M. (2002). The data warehouse toolkit (2nd edn). Nashville, TN: John Wiley & Sons.


