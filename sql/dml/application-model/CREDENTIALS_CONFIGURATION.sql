-- Configuration of Credentials.

-- 1. Insert the values of your credentiasl in the User's Table.

INSERT INTO "AdminManagement"."Sandbox_App_Users"
("Username", "Password_hash", "Role", "Active", "SandBoxDBRole", "ProductionDBRole")
VALUES 
('user_name_login_app', 'user_pwd_login_app', 'ADMIN', true, 'user_name_destination_db', 'user_name_source_db');

-- 2. Update the password value, using the function pgp_sym_encrypt, to encrypt the password value.

UPDATE "AdminManagement"."Sandbox_App_Users"
SET "Password_hash" = pgp_sym_encrypt(b."Password_hash", 'public-password', 'compress-algo=1, cipher-algo=aes256')
FROM "AdminManagement"."Sandbox_App_Users" b
WHERE "AdminManagement"."Sandbox_App_Users"."Username" = 'user_name_login_app';