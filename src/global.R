##############################
# Libraries
##############################

library(shiny)
library(shinyjs)
library(shinymanager)
library(htmltools)
library(bslib)
library(shinyWidgets)
library(tidyverse)
library(DBI)
library(RPostgres)

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
  dbname = "bot-datacenter",
  user = "postgres"
)

############################
# Pop-Up Displays Functions
############################

showValidationResult <- function(
    status = "success",
    message = "",
    details = NULL
) {
  
  icon_name <- switch(
    status,
    success = "check-circle",
    warning = "exclamation-triangle",
    error   = "times-circle",
    "info-circle"
  )
  
  title_color <- switch(
    status,
    success = "#00a86b",
    warning = "#f39c12",
    error   = "#d63031",
    "#1f5fcf"
  )
  
  modalDialog(
    title = tagList(
      icon(icon_name),
      " Validation Result"
    ),
    
    div(
      class = "validation-result",
      tags$h4(
        style = paste0(
          "color:", title_color, ";"
        ),
        message
      ),
      
      if(!is.null(details))
        tags$ul(
          lapply(details, tags$li)
        )
    ),
    
    easyClose = TRUE,
    
    footer = modalButton("Close")
  )
  
}

showReplicationConfirmation <- function(
    schema,
    table,
    replica_type
){
  
  modalDialog(
    title = tagList(
      icon("rocket"),
      " Confirm Data Replication"
    ),
    
    div(
      class = "replication-confirmation",
      h4("Replication Summary"),
      tags$table(
        class = "replication-summary-table",
        tags$tr(
          tags$td("Schema"),
          tags$td(schema)
        ),
        
        tags$tr(
          tags$td("Table"),
          tags$td(table)
        ),
        
        tags$tr(
          tags$td("Type"),
          tags$td(replica_type)
        )
      ),
      
      tags$hr(),
      
      tags$h5(
        icon("triangle-exclamation"),
        " Impact"
      ),
      
      tags$ul(
        tags$li("Existing records may be overwritten."),
        tags$li("The process cannot be automatically reverted."),
        tags$li("Execution time depends on data volume.")
      )
      
    ),
    
    footer = tagList(
      modalButton("Cancel"),
      actionButton(
        "confirmReplicaExecution",
        "Execute Replication",
        icon = icon("play")
      )
      
    ),
    easyClose = FALSE
  )
}

showReplicationResult <- function(
    schema,
    table,
    replica_type,
    records_replicated,
    execution_time
) {
  
  modalDialog(
    
    title = tagList(
      icon("circle-check"),
      "Data Replication Completed"
    ),
    
    div(class = "replication-result",
        
        h4(
          icon("database"),
          "Replication Summary"
        ),
        
        tags$table(
          class = "replication-summary-table",
          
          tags$tr(
            tags$td("Schema"),
            tags$td(schema)
          ),
          
          tags$tr(
            tags$td("Table"),
            tags$td(table)
          ),
          
          tags$tr(
            tags$td("Replication Type"),
            tags$td(replica_type)
          )
        ),
        
        tags$hr(),
        
        div(
          class = "replication-metric-card",
          
          h2(
            format(
              records_replicated,
              big.mark = ","
            )
          ),
          p("Records Replicated")
        ),
        
        div(
          class = "replication-execution-time",
          
          icon("clock"),
          paste("Execution Time: ",
                execution_time
          )
        )
    ),
    
    footer = tagList(
      modalButton("Close")
    ),
    
    easeClose = TRUE
    
  )
  
}

getAppUsers <- function () {
  
  adminAppUsersConnection <- dbConnect(
    RPostgres::Postgres(),
    host = "localhost",
    port = 5433,
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