-- Role Configuration.

-- Source DB (Only Read Access)

-- 1. Create a Role for the user with read access to the source database.

CREATE ROLE user_name WITH LOGIN PASSWORD 'password';

-- 2. Grant the role read access to the source database.

GRANT CONNECT ON DATABASE "bot-datacenter" TO user_name;

-- 3. Grant the role read access to the schema containing the tables.

GRANT USAGE ON SCHEMA "Operations" TO user_name;

-- 4. Grant the role read access to the specific table.

GRANT SELECT ON TABLE "Operations"."LoansDeposits_Fact_ConsumerLoanData" TO user_name;


-- Destination DB (Read/Write Access)

-- 1. Create a Role for the user with read/write access to the destination database.

CREATE ROLE user_name WITH LOGIN PASSWORD 'password';

-- 2. Grant the role read/write access to the destination database.

GRANT CONNECT ON DATABASE "bot-datacenter" TO user_name;

-- 3. Grant the role read/write access to the schema containing the tables.

GRANT USAGE ON SCHEMA "Operations" TO user_name;

-- 4. Grant the role read/write access to the specific table.

GRANT SELECT, INSERT, TRUNCATE, UPDATE, DELETE ON TABLE "Operations"."LoansDeposits_Fact_ConsumerLoanData" TO user_name;