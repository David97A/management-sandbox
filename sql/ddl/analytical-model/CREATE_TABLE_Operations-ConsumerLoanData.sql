-- Table: Operations.LoansDeposits_Fact_ConsumerLoanData

CREATE TABLE IF NOT EXISTS "Operations"."LoansDeposits_Fact_ConsumerLoanData"
(
    "MonthDate" date NOT NULL,
    "ConsumerId" integer NOT NULL,
    "LoanAccountId" integer NOT NULL,
    "LoanOutstandingBalance" numeric(20,6) NOT NULL DEFAULT 0
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "Operations"."LoansDeposits_Fact_ConsumerLoanData"
    OWNER TO postgres;