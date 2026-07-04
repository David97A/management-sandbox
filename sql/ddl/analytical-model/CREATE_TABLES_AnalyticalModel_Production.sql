/****************************************************************
    CREATE TABLES FOR ANALYTICAL MODEL - PRODUCTION ENVIRONMENT
*****************************************************************/

BEGIN;

DROP TABLE IF EXISTS "Operations"."LoansDeposits_Fact_ConsumerLoanData";
CREATE TABLE IF NOT EXISTS "Operations"."LoansDeposits_Fact_ConsumerLoanData"
(
    "InformationDate" date NOT NULL,
    "CustomerId" integer NOT NULL,
    "LoanAccountId" integer NOT NULL,
    "LoanOutstandingBalance" numeric(20, 6) NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS "Operations"."Cards_Fact_CreditCardsTransactions";
CREATE TABLE IF NOT EXISTS "Operations"."Cards_Fact_CreditCardsTransactions"
(
    "TransactionId" bigserial NOT NULL,
    "TransactionDate" timestamp without time zone NOT NULL,
    "OrderingCustomerId" numeric(50) NOT NULL,
    "Amount" numeric(22, 8) NOT NULL,
    "IsReversed" boolean NOT NULL,
    "ReversedDate" timestamp without time zone NULL,
    "ReceiverCustomerId" numeric(50) NOT NULL,
    CONSTRAINT "Cards_Fact_CreditCardsTransactions_PK" PRIMARY KEY ("TransactionId")
);

DROP TABLE IF EXISTS "SalesService"."CustomerManagement_Dim_CustomersCatalog";
CREATE TABLE IF NOT EXISTS "SalesService"."CustomerManagement_Dim_CustomersCatalog"
(
    "InformationDate" date NOT NULL,
    "CustomerId" numeric(50, 0) NOT NULL,
    "CustomerName" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "CustomerLastName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "CustomerBirthDate" date NOT NULL,
    "CustomerGender" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "CustomerOccupation" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "EmployeeId" numeric(50, 0) NOT NULL,
    "AccountOpeningDate" date NOT NULL,
    "CustomerStatus" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "CustomerManagement_Dim_CustomersCatalog_PK" PRIMARY KEY ("CustomerId")
);

DROP TABLE IF EXISTS "BusinessSupport"."HumanResources_Dim_EmployeesCatalog";
CREATE TABLE IF NOT EXISTS "BusinessSupport"."HumanResources_Dim_EmployeesCatalog"
(
    "InformationDate" date NOT NULL,
    "EmployeeId" numeric(50, 0) NOT NULL,
    "EmployeeName" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "EmployeeLastName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "EmployeeBirthDate" date NOT NULL,
    "EmployeeGender" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "StartDate" date NOT NULL,
    "EmployeeStatus" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TerminationDate" date NOT NULL DEFAULT '1900-01-01'::date,
    CONSTRAINT "HumanResources_Dim_EmployeesCatalog_PK" PRIMARY KEY ("EmployeeId")
);

ALTER TABLE IF EXISTS "Operations"."LoansDeposits_Fact_ConsumerLoanData"
    ADD FOREIGN KEY ("CustomerId")
    REFERENCES "SalesService"."CustomerManagement_Dim_CustomersCatalog" ("CustomerId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS "Operations"."Cards_Fact_CreditCardsTransactions"
    ADD FOREIGN KEY ("OrderingCustomerId")
    REFERENCES "SalesService"."CustomerManagement_Dim_CustomersCatalog" ("CustomerId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS "Operations"."Cards_Fact_CreditCardsTransactions"
    ADD FOREIGN KEY ("ReceiverCustomerId")
    REFERENCES "SalesService"."CustomerManagement_Dim_CustomersCatalog" ("CustomerId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS "SalesService"."CustomerManagement_Dim_CustomersCatalog"
    ADD FOREIGN KEY ("EmployeeId")
    REFERENCES "BusinessSupport"."HumanResources_Dim_EmployeesCatalog" ("EmployeeId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

COMMIT;

END;