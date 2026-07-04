/****************************************************************
    DATA INSERTS FOR ANALYTICAL MODEL - PRODUCTION ENVIRONMENT
*****************************************************************/

INSERT INTO "BusinessSupport"."HumanResources_Dim_EmployeesCatalog"
(
    "InformationDate",
    "EmployeeId",
    "EmployeeName",
    "EmployeeLastName",
    "EmployeeBirthDate",
    "EmployeeGender",
    "StartDate",
    "EmployeeStatus",
    "TerminationDate"
)
VALUES
('2025-12-31',1001,'John','Smith','1982-04-15','Male','2015-01-10','Active','1900-01-01'),
('2025-12-31',1002,'Mary','Johnson','1988-09-22','Female','2018-07-16','Active','1900-01-01'),
('2025-12-31',1003,'Robert','Brown','1979-11-03','Male','2012-05-21','Active','1900-01-01'),
('2025-12-31',1004,'Jennifer','Miller','1990-01-30','Female','2020-03-09','Active','1900-01-01'),
('2025-12-31',1005,'David','Wilson','1985-06-17','Male','2016-08-01','Active','1900-01-01');

INSERT INTO "SalesService"."CustomerManagement_Dim_CustomersCatalog"
(
    "InformationDate",
    "CustomerId",
    "CustomerName",
    "CustomerLastName",
    "CustomerBirthDate",
    "CustomerGender",
    "CustomerOccupation",
    "EmployeeId",
    "AccountOpeningDate",
    "CustomerStatus"
)
VALUES
('2025-12-31',20001,'Alice','Garcia','1992-02-15','Female','Engineer',1001,'2020-03-15','Active'),
('2025-12-31',20002,'Michael','Lopez','1985-08-21','Male','Teacher',1001,'2019-06-10','Active'),
('2025-12-31',20003,'Sophia','Martinez','1998-01-12','Female','Doctor',1002,'2022-01-05','Active'),
('2025-12-31',20004,'Daniel','Hernandez','1978-10-18','Male','Lawyer',1003,'2016-11-20','Active'),
('2025-12-31',20005,'Emma','Rodriguez','1994-07-11','Female','Architect',1002,'2021-09-14','Active'),
('2025-12-31',20006,'James','Perez','1989-12-02','Male','Consultant',1004,'2018-04-01','Active'),
('2025-12-31',20007,'Olivia','Sanchez','1996-03-08','Female','Designer',1005,'2023-02-15','Active'),
('2025-12-31',20008,'William','Ramirez','1984-05-30','Male','Accountant',1003,'2017-08-28','Active'),
('2025-12-31',20009,'Isabella','Torres','1991-09-25','Female','Marketing Manager',1004,'2020-10-05','Active'),
('2025-12-31',20010,'Benjamin','Flores','1987-11-14','Male','Software Developer',1005,'2019-01-22','Active');

INSERT INTO "Operations"."LoansDeposits_Fact_ConsumerLoanData"
(
    "InformationDate",
    "CustomerId",
    "LoanAccountId",
    "LoanOutstandingBalance"
)
VALUES
('2025-12-31',20001,300001,15425.50),
('2025-12-31',20002,300002,8500.00),
('2025-12-31',20003,300003,25780.35),
('2025-12-31',20004,300004,103450.90),
('2025-12-31',20005,300005,4200.00),
('2025-12-31',20006,300006,76000.75),
('2025-12-31',20007,300007,18500.25),
('2025-12-31',20008,300008,950.00),
('2025-12-31',20009,300009,32100.80),
('2025-12-31',20010,300010,11890.60);

INSERT INTO "Operations"."Cards_Fact_CreditCardsTransactions"
(
    "TransactionDate",
    "OrderingCustomerId",
    "Amount",
    "IsReversed",
    "ReversedDate",
    "ReceiverCustomerId"
)
VALUES
('2025-12-01 09:15:00',20001,120.50,FALSE,NULL,20002),
('2025-12-01 10:40:00',20002,55.90,FALSE,NULL,20003),
('2025-12-02 14:18:00',20003,890.00,FALSE,NULL,20005),
('2025-12-03 08:30:00',20004,42.35,FALSE,NULL,20001),
('2025-12-03 12:15:00',20005,310.25,FALSE,NULL,20007),
('2025-12-04 09:00:00',20006,700.00,TRUE,'2025-12-05 09:10:00',20008),
('2025-12-04 15:45:00',20007,129.99,FALSE,NULL,20009),
('2025-12-05 16:22:00',20008,560.00,FALSE,NULL,20010),
('2025-12-06 11:08:00',20009,95.50,FALSE,NULL,20004),
('2025-12-06 17:40:00',20010,1100.00,FALSE,NULL,20006),
('2025-12-07 08:20:00',20001,215.80,FALSE,NULL,20009),
('2025-12-07 13:55:00',20002,45.25,FALSE,NULL,20010),
('2025-12-08 18:10:00',20003,999.99,TRUE,'2025-12-08 19:05:00',20006),
('2025-12-09 10:15:00',20004,1500.00,FALSE,NULL,20005),
('2025-12-10 09:30:00',20005,78.45,FALSE,NULL,20002),
('2025-12-11 14:50:00',20006,670.20,FALSE,NULL,20001),
('2025-12-12 16:40:00',20007,320.00,FALSE,NULL,20003),
('2025-12-13 11:15:00',20008,28.99,FALSE,NULL,20007),
('2025-12-14 12:45:00',20009,410.75,FALSE,NULL,20008),
('2025-12-15 19:10:00',20010,60.00,FALSE,NULL,20004);