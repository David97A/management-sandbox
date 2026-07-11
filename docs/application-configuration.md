# Application Configuration.

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

## Application Model - Inserting Users Information.

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

## Storing the Database passwords in pgpass.

Depending on whether you're working on a Windows or Linux/macOS Set up, the following steps will guide you through the configuration of the pgpass file to store the passwords of each analytical dabase securily. Also we have to include the password of the ```postgres``` super user for the connection to the Application's Database ```SandBoxAppManagement``` (the one that you choose while installing the PostgreSQL version in your computer or while configuring the Docker container) so we don't have the need to declare it explicitly anywhere in the application code.

### Windows

1. Press ```Win + R```, type ```%APP DATA%``` and press Enter.
2. Look for a folder named ```postgresql```. If it doesn't exists, create it.
3. Inside that new folder, create a .txt file named ```pgpass.conf```.
4. Open the file in a text editor (Like Notepad) and add a line for each connection with the information of your credentials, following the next format:

``` text
# Connection to Production environment
lochalhost:5432:bot-datacenter:username_production:password_production
# Connection to Sandbox environment
localhost:5433:bot-datacenter:username_sandbox:password_sandbox
# Connection to the Application's Database to the postgresql User
localhost:5434:SandboxAppManagement:postgres:postgres_password
```
### Linux / macOS

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
# Connection to the Application's Database to the postgresql User
localhost:5434:SandboxAppManagement:postgres:postgres_password
```

4. Since Linux and macOS will ignore the pgpass file configuration if its permissions are too broad, we have to run the next command to restrict them:

``` bash
chmod 0600 ~/.pgpass
```

You can test the passwords configuration by connecting to each database using ```psql```:

*Production Analytical Database*

``` bash
psql -h localhost -p 5432 -d bot-datacenter  -U username_production
```

*Sandbox Application Database*

``` bash
psql -h localhost -p 5434 -d SandboxAppManagement  -U postgres
```

if it logs in immediately, the pgpass file is working correctly.

## Configuring the Database Connections and Running the Application.

[Application Source Code](src/)

With all the previous requisites satisfied, the only configuration that is left to do is to modify the ```global.r``` to include the details of your Databases connections.

1. The connection parameters to the analytical Databases has to be included in the following lines (the ```configParamsDestinationConn``` has to be completed with the connection parameters to the Sandbox instance, while the ```configParamsSourceConn``` should include the Production instance's parameters):

``` r
#########################
# Connections Parameters
#########################

configParamsDestinationConn <- list(
  host = "localhost",
  port = 5432,
  dbname = "bot-datacenter"
)
configParamsSourceConn <- list(
  host = "localhost",
  port = 5433,
  dbname = "bot-datacenter"
)
```

2. The connection parameters corresponding to the Application's Database has to be included inside the ```getAppUsers``` function, which has the logic to extract the Database Roles' information once the User has been authenticated.

``` r
getAppUsers <- function () {
  
  adminAppUsersConnection <- dbConnect(
    RPostgres::Postgres(),
    host = "localhost",
    port = 5434,
    dbname = "SandBoxAppManagement",
    user = "postgres"
  )
  
  users <- dbGetQuery(adminAppUsersConnection,
                      '
SELECT
  "Username" AS user,
  pgp_sym_decrypt("Password_hash"::bytea, \'public-password\') as password,
  "Role",
  "Active",
  "SandBoxDBRole",
  "ProductionDBRole"
FROM "AdminManagement"."Sandbox_App_Users"
    '
  )
  
  dbDisconnect(adminAppUsersConnection)
  
  users
}
```

With this last changes, the application is ready to be tested. You can run it with the following command (adapting it to your own path):

``` r
library(shiny)

runApp(
  appDir = "/management-sandbox/src", 
  host = "0.0.0.0", 
  port = 5050
)
```
note that, the three source files (```ui.r```, ```server.r```, ```global.r```) need to be allocated in the same folder ```src```, with the css file inside the ```www``` folder.