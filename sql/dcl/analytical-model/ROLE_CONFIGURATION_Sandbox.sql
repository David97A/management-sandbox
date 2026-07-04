/**************************
    ROLE CONFIGURATION
***************************/

-- Destination DB (Read/Write Access)

-- 1. Create a Role for the user with read/write access to the destination database.

CREATE ROLE user_name WITH LOGIN PASSWORD 'password';

-- 2. Grant the role read/write access to the destination database.

GRANT CONNECT ON DATABASE "bot-datacenter" TO user_name;

-- 3. Grant the role read/write access to the schema containing the tables.

GRANT USAGE ON SCHEMA "Operations" TO user_name;
GRANT USAGE ON SCHEMA "SalesService" TO user_name;
GRANT USAGE ON SCHEMA "BusinessSupport" TO user_name;

-- 4. Grant the role read/write access to the specific table.

GRANT SELECT, INSERT, TRUNCATE, UPDATE, DELETE ON TABLE  "Operations"."LoansDeposits_Fact_ConsumerLoanData" TO user_name;
GRANT SELECT, INSERT, TRUNCATE, UPDATE, DELETE ON TABLE  "Operations"."Cards_Fact_CreditCardsTransactions" TO user_name;
GRANT SELECT, INSERT, TRUNCATE, UPDATE, DELETE ON TABLE  "SalesService"."CustomerManagement_Dim_CustomersCatalog" TO user_name;
GRANT SELECT, INSERT, TRUNCATE, UPDATE, DELETE ON TABLE  "BusinessSupport"."HumanResources_Dim_EmployeesCatalog" TO user_name;