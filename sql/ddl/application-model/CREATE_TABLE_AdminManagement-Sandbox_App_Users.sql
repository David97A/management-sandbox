-- Table: AdminManagement.Sandbox_App_Users

CREATE TABLE IF NOT EXISTS "AdminManagement"."Sandbox_App_Users"
(
    "Username" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "Password_hash" text COLLATE pg_catalog."default" NOT NULL,
    "Role" character varying(10) COLLATE pg_catalog."default" NOT NULL,
    "Active" boolean DEFAULT true,
    "SandBoxDBRole" character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT ''::character varying,
    "ProductionDBRole" character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT ''::character varying,
    CONSTRAINT "Sandbox_App_Users_pkey" PRIMARY KEY ("Username")
);