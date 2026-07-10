# management-sandbox
## Shiny Application for Manage Replicas to a Sandbox Environment

Developed using the [Shiny Package](https://shiny.posit.co) (a library that enables the creation of Web Applications using R or Python languages) the main purpose of the "management-sandbox" app is to work as a Replication Data Hub to move Data from a Source Production Relational Database to a "mirror" environment called Sandbox.

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

Consider an enterprise architecture composed of a Production Environment and a Sandbox Environment. The Production Environment hosts the organization’s operational database, which supports business reporting, enterprise applications, and day-to-day processes. The Sandbox Environment maintains a synchronized replica of this system, providing Data Analysts, Data Scientists, and other engineering teams with an isolated workspace for computationally intensive experimentation, model development, and data exploration without impacting production performance.

The management-sandbox application automates and manages the replication workflows that synchronize the sandbox with production, ensuring that non-production environments remain current while minimizing operational risk and eliminating resource contention with production workloads.

## Architecture

Initially, the application is designed around a two-tier architecture. The first tier consists of a PostgreSQL database (SandboxAppManagement) that stores user authentication and authorization information. This database provides an additional security layer by requiring users to authenticate before accessing the application. User passwords are securely encrypted using the [pgcrypto](https://www.postgresql.org/docs/current/pgcrypto.html) extension, which provides cryptographic functions for PostgreSQL. The second Tier will contain the source code of the Front-End design, the Back-End logic and the Global assets that the application need to function.

For the analytical ecosystem, it is assumed that the Production and Sandbox databases reside on separate database servers. Consequently, the application must be able to communicate with both servers through independent ODBC connections.

Additionally, a dedicated database role will be created in each environment with privileges aligned to the application’s operational requirements. In the Production environment, the role will be restricted to read-only operations to protect production data. In contrast, the role in the Sandbox environment will be granted read and write privileges, allowing the application to execute data replication and management tasks while maintaining the security and integrity of the Production environment.


![Application Architecture](assets/sandbox-management-hub-architecture.png)

## The "Bank of Trust" example and the Analytical Model

Using the [BIAN Service Domain Landscape](https://bian.org/servicelandscape-12-0-0/views/view_51891.html) and Kimball's Dimensional Aproach [^1] as a reference for Designing our Relational Data Model for a fictional Banking Institution called "Bank of Trust", we can test our application on the following objects:

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

### Initial Configuration for the Analytical Instances

As we are working on the idea of three separate PostgreSQL instances (two for the Analytical Databses and one for the Application Database), we'll need to configure three ODBC connections for the application. If you want to try the functionality of the app in you local environment, you can download and install three PostgreSQL versions from the [official site](https://www.postgresql.org/download/) and assign each version a different port or use [Docker's PostgreSQL Image](https://hub.docker.com/_/postgres) to configure three different containers.

### Creation of the DB Objects.

- [Analytical Model DDL Scripts](sql/ddl/analytical-model)
- [Analytical Model DML Scripts](sql/dml/analytical-model)

Once we have our PostgreSQL analytical instances running, we proceed to create the Analytical Data Models following the next instructions:

1. Create the Database with the CREATE_DB_bot-datacenter.sql script, in each analytical instance.
2. Change the connection to the new databases to create the Schemas with the CREATE_SCHEMAS.sql script.
3. For each instance, run the following scripts to create the Tables:
  - For the creation of the Data Model in the "Production" environment, run the CREATE_TABLES_AnalyticalModel_Production.sql script.
  - For the creation of the Data Model in the "Sandbox" environment, run the CREATE_TABLES_AnalyticalModel_Sandbox.sql script. For the Sandbox Model, we omit the creation of Foreign Keys in the Fact Tables since we may constantly overwrite information in the Dimension Tables (deleting everything and inserting the new information), causing dependency errors.
4. Connected to the Production instance, insert the dummy data using the SAMPLE_DATA_INSERTION_Production.sql script, located in the dml/analytical-model folder.

### Privileges Configuration.

- [Analytical Model DCL Scripts](sql/dcl/analytical-model)

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

## The Application Model.

The application Data Model will store the following relevant information to enable the security functions of the app and the connections to the analytical instances:

- The username that will be requested to log in to the app.
- The password that will be requested to log in to the app (encrypted using pgcrypto).
- The type of role (ADMIN, DEVELOPER, etc).
- A boolean value to indicate if the role is Active (true / false).
- The database role (only the user name) that will be used to connect to the analytical Production instance (the one that was configured with the ROLE_CONFIGURATION_Production.sql script).
- The database role (only the user name) that will be used to connect to the analytical Sandbox instance (the one that was configured with the ROLE_CONFIGURATION_Sandbox.sql script).

We will not include in this table the passwords we configured for the database roles in each analytical instance, since we can store them in the pgpass.conf file. This is a secure strategy that we can follow to avoid declaring our passwords in the application code.

[Application Model DDL Scripts](sql/ddl/application-model)

Once we have our Application's PostgreSQL instance running, we proceed to create its Data Model following the next instructions:

1. Create the Database with the CREATE_DB_SandboxAppManagement.sql script.
2. Change the connection to the new database to create the Schema with the CREATE_SCHEMA_AdminManagement.sql script.
3. Create the Table that will store the credentials information with the CREATE_TABLE_AdminManagement-Sandbox_App_Users.sql script.

### Application Model - Inserting Users Information.

[Application Model DML Scripts](sql/dml/application-model)

1. With the CREDENTIALS_CONFIGURATION.sql script, we're going to create the pgcrypto PostgreSQL extension and insert the user's authentication information. In the next line of the script:

``` SQL
INSERT INTO "AdminManagement"."Sandbox_App_Users"
("Username", "Password_hash", "Role", "Active", "SandBoxDBRole", "ProductionDBRole")
VALUES 
('user_name_login_app', 'user_pwd_login_app', 'ADMIN', true, 'user_name_destination_db', 'user_name_source_db');
```
we have to insert the values corresponding to the user name and pasword that the application will request for the log in to the "Username" and "Password_hash" columns.

2. Update the value in the "Password_hash" column with the next line:

``` SQL
-- 2. Update the password value, using the function pgp_sym_encrypt, to encrypt the password value.

UPDATE "AdminManagement"."Sandbox_App_Users"
SET "Password_hash" = pgp_sym_encrypt(b."Password_hash", 'public-password', 'compress-algo=1, cipher-algo=aes256')
FROM "AdminManagement"."Sandbox_App_Users" b
WHERE "AdminManagement"."Sandbox_App_Users"."Username" = 'user_name_login_app';
```
declaring your user name in at the end of the WHERE clause filter.

### Storing the Database passwords in pgpass.

Depending on whether you're working on a Windows or Linux/macOS Set up, the following steps will guide you through the configuration of the pgpass file to store the passwords of each analytical dabase securily:

#### Windows

1. Press ```Win + R```, type ```%APP DATA%``` and press Enter.
2. Look for a folder named ```postgresql```. If it doesn't exists, create it.
3. Inside that new folder, create a .txt file named ```pgpass.conf```.
4. Open the file in a text editor (Like Notepad) and add a line for each connection with the information of your credentials, following the next format:

``` text
# Connection to Production environment
lochalhost:5432:bot-datacenter:username_production:password_production
# Connection to Sandbox environment
localhost:5433:bot-datacenter:username_sandbox:password_sandbox
```
#### Linux / macOS

1. Open your Terminal and navigate to the home directory:

``` bash
cd ~
```

2. Create and open the pgpass file (it will be hidden)

``` bash
nano .pgpass
```

3. Once open, add a line for each connection with the information of your credentials, following the next format:

``` text
# Connection to Production environment
lochalhost:5432:bot-datacenter:username_production:password_production
# Connection to Sandbox environment
localhost:5433:bot-datacenter:username_sandbox:password_sandbox
```

4. Since Linux and macOS will ignore the pgpass file configuration if its permissions are too broad, we have to run the next command to restrict them:

``` bash
chmod 0600 ~/.pgpass
```

You can test the passwords configuration by connecting to each database using ```psql```:

``` bash
psql -h localhost -p 5432 -d bot-datacenter  -U username_production
```

if it logs in immediately, the pgpass file is working correctly.


## References

[^1]: Kimball, R., & Ross, M. (2002). The data warehouse toolkit (2nd edn). Nashville, TN: John Wiley & Sons.
