# Analytical Databases Set Up

## Initial Configuration for the Analytical Instances

As we are working on the idea of three separate PostgreSQL instances (two for the Analytical Databses and one for the Application Database), we'll need to configure three ODBC connections for the application. If you want to try the functionality of the app in you local environment, you can download and install three PostgreSQL versions from the [official site](https://www.postgresql.org/download/) and assign each version a different port or use [Docker's PostgreSQL Image](https://hub.docker.com/_/postgres) to configure three different containers.

## Creation of the DB Objects.

- [Analytical Model DDL Scripts](sql/ddl/analytical-model)
- [Analytical Model DML Scripts](sql/dml/analytical-model)

Once we have our PostgreSQL analytical instances running, we proceed to create the Analytical Data Models following the next instructions:

1. Create the Database with the CREATE_DB_bot-datacenter.sql script, in each analytical instance.
2. Change the connection to the new databases to create the Schemas with the CREATE_SCHEMAS.sql script.
3. For each instance, run the following scripts to create the Tables:
  - For the creation of the Data Model in the "Production" environment, run the CREATE_TABLES_AnalyticalModel_Production.sql script.
  - For the creation of the Data Model in the "Sandbox" environment, run the CREATE_TABLES_AnalyticalModel_Sandbox.sql script. For the Sandbox Model, Foreign key constraints are intentionally omitted in the Fact Tables since we may constantly overwrite information in the Dimension Tables (deleting everything and inserting the new information), causing dependency errors.
4. Connected to the Production instance, insert the dummy data using the SAMPLE_DATA_INSERTION_Production.sql script, located in the dml/analytical-model folder.

## Privileges Configuration.

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