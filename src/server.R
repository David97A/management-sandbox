function(input, output, session) {
  
  credentials <- getAppUsers()
  
  auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  current_user <- reactive({
    auth$user
  })
  
  current_role <- reactive({
    auth$Role
  })
  
  output$loggedUser <- renderText({
    paste(
      current_user(),
      "-",
      current_role()
    )
  })
  
  #### Section I: Custom Data Replica ####
  
  customReplicaValidation <- reactiveVal()
  
  # Execute the Validation Process.
  
  observeEvent(input$cstmReplValidationBttn, {
    
    req(input$cstmReplInputSchema,
        input$cstmReplInputTable)
    
    assign("sourceDBConnection", 
           dbConnect(RPostgres::Postgres(),
                     host = configParamsSourceConn$host,
                     port = configParamsSourceConn$port,
                     dbname = configParamsSourceConn$dbname, 
                     user = auth$ProductionDBRole))
    
    assign("destinationDBConnection", 
           dbConnect(RPostgres::Postgres(),
                     host = configParamsDestinationConn$host,
                     port = configParamsDestinationConn$port,
                     dbname = configParamsDestinationConn$dbname, 
                     user = auth$SandBoxDBRole))
    
    objectsDDLMatchResolution <- character(0)
    
    # From PostgreSQL Schema Catalog Tables, we get the Table's Metadata in Both Sources to Compare it.
    
    qryGetDDLObject <- sprintf("
	SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale, is_nullable, row_number() over() AS ordinal_position_custom
	FROM information_schema.columns
	WHERE table_schema = '%s' AND table_name = '%s'
	ORDER BY ordinal_position;", input$cstmReplInputSchema, input$cstmReplInputTable)
    
    sourceObjectDDL <- dbGetQuery(sourceDBConnection, qryGetDDLObject) %>% 
      mutate("extension" = case_when(data_type %in% "numeric" ~ str_c("(", as.character(numeric_precision), ",", as.character(numeric_scale),")"),
                                     data_type %in% "character varying" ~ str_c("(", as.character(character_maximum_length),")"),
                                     TRUE ~ "")) %>% 
      select(
        column_name,
        data_type,
        extension,
        is_nullable,
        ordinal_position_custom
      ) %>% 
      rename(
        column_name_sourcetable = column_name,
        data_type_sourcetable = data_type,
        extension_sourcetable = extension,
        is_nullable_sourcetable = is_nullable,
        ordinal_position_sourcetable = ordinal_position_custom
      )
    
    sourceObjectDDL[is.na(sourceObjectDDL$extension_sourcetable), "extension_sourcetable"] <- ""
    
    destinationObjectDDL <- dbGetQuery(destinationDBConnection, qryGetDDLObject) %>% 
      mutate("extension" = case_when(data_type %in% "numeric" ~ str_c("(", as.character(numeric_precision), ",", as.character(numeric_scale),")"),
                                     data_type %in% "character varying" ~ str_c("(", as.character(character_maximum_length),")"),
                                     TRUE ~ "")) %>% 
      select(
        column_name,
        data_type,
        extension,
        is_nullable,
        ordinal_position_custom
      ) %>% 
      rename(
        column_name_destinationtable = column_name,
        data_type_destinationtable = data_type,
        extension_destinationtable = extension,
        is_nullable_destinationtable = is_nullable,
        ordinal_position_destinationtable = ordinal_position_custom
      )
    
    destinationObjectDDL[is.na(destinationObjectDDL$ordinal_position_destinationtable), "ordinal_position_destinationtable"] <- ""
    
    dbDisconnect(sourceDBConnection)
    dbDisconnect(destinationDBConnection)
    
    # Structure Validation Logic
    
    if(nrow(sourceObjectDDL) == 0)
    {
      
      objectsDDLMatchResolution <- "Table Does Not Exists in Source."
      
    } else if(nrow(destinationObjectDDL) == 0)
    {
      
      objectsDDLMatchResolution <- "Table Does Not Exists in Destination."
      
    } else if(nrow(sourceObjectDDL) != nrow(destinationObjectDDL))
    {
      
      objectsDDLMatchResolution <- "Mismatch in Number of Columns Between Tables."
      
    } else {
      
      fields_match_validation <- sourceObjectDDL %>% 
        left_join(destinationObjectDDL,
                  by = c("column_name_sourcetable" = "column_name_destinationtable")) %>% 
        mutate(
          match_datatype_validation = case_when(data_type_sourcetable == data_type_destinationtable & extension_sourcetable == extension_destinationtable ~ 1,
                                                TRUE ~ 0),
          match_position_validation = case_when(ordinal_position_sourcetable == ordinal_position_destinationtable ~ 1,
                                                TRUE ~ 0)
        )
      
      if(sum(fields_match_validation$match_datatype_validation) != nrow(fields_match_validation))
      {
        
        objectsDDLMatchResolution <- "Mismatch in Column's Definition."
        
      } else if(sum(fields_match_validation$match_position_validation) != nrow(fields_match_validation))
      {
        
        objectsDDLMatchResolution <- "Mismatch in Column's Ordinal Position."
        
      } else {
        
        objectsDDLMatchResolution <- "Object's Match Validated."
        
      }
      
    }
    
    customReplicaValidation(objectsDDLMatchResolution)
    
    updateSelectInput(
      session = session,
      inputId = "cstmReplInputSpecDateField",
      choices = sourceObjectDDL$column_name
    )
    
    updateSelectInput(
      session = session,
      inputId = "cstmReplInputIntervalDateField",
      choices = sourceObjectDDL$column_name
    )
    
  })
  
  observeEvent(input$cstmReplValidationBttn, {
    
    req(input$cstmReplInputSchema,
        input$cstmReplInputTable)
    
    objectsDDLMatchMessage <- customReplicaValidation()
    
    if(objectsDDLMatchMessage == "Object's Match Validated.")
    {
      assign("statusVar", "success")
    }else{
      assign("statusVar", "error")
    }
    
    showModal(
      showValidationResult(
        status = statusVar,
        message = objectsDDLMatchMessage,
        details = NULL
      )
    )
    
  })
  
  # If Validation is OK, enable "Execute Replica" Button.
  
  observeEvent(input$cstmReplValidationBttn, {
    
    req(input$cstmReplInputSchema,
        input$cstmReplInputTable)
    
    objectsDDLMatchMessage <- customReplicaValidation()
    
    if(objectsDDLMatchMessage == "Object's Match Validated.")
    {
      
      shinyjs::enable("cstmReplExecutionBttn")
      shinyjs::enable("cstmReplInputTypeReplica")
      
    }else{
      
      shinyjs::disable("botonAccionarTraspaso")
      shinyjs::disable("cstmReplExecutionBttn")
      
    }
    
  })
  
  observeEvent(input$cstmReplExecutionBttn, {
    showModal(
      showReplicationConfirmation(
        schema = input$cstmReplInputSchema,
        table = input$cstmReplInputTable,
        replica_type = input$cstmReplInputTypeReplica
      )
    )
  })
  
  observeEvent(input$confirmReplicaExecution, {
    
    removeModal()
    
    # Replica Logic Based on Type of Replica selection.

    source_conn <- str_c("host=",configParamsSourceConn$host," port=",configParamsSourceConn$port," dbname=",configParamsSourceConn$dbname," user=",auth$ProductionDBRole)
    target_conn <- str_c("host=",configParamsDestinationConn$host," port=",configParamsDestinationConn$port," dbname=",configParamsDestinationConn$dbname," user=",auth$SandBoxDBRole)
    cmd <- character(0)
    qryDeleteActualData <- character(0)
    
    if(input$cstmReplInputTypeReplica == "overwrite")
    {
      
      # Query for Data Deletion.
      
      qryDeleteActualData <- str_c("TRUNCATE TABLE \"", input$cstmReplInputSchema, "\".\"", input$cstmReplInputTable, "\" CASCADE;")

      # psql commands for Data Replica.
      
      cmd <- paste0(
        'psql "', source_conn, '" -c ',
        shQuote(
          paste0(
            'COPY (SELECT * FROM "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '") TO STDOUT'
          )
        ),
        ' | ',
        'psql "', target_conn, '" -c ',
        shQuote(
          paste0(
            'COPY "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '" FROM STDIN'
          )
        )
      )
      
    }
    
    if(input$cstmReplInputTypeReplica == "datespecific")
    {
      
      # Query for Data Deletion
      
      qryDeleteActualData <- str_c("DELETE FROM \"",input$cstmReplInputSchema, "\".\"", input$cstmReplInputTable, "\" WHERE \"", input$cstmReplInputSpecDateField, "\" = '",as.character(input$cstmReplInputSpecDateSelection),"';")

      # psql commands for Data Replica
      
      cmd <- paste0(
        'psql "', source_conn, '" -c ',
        shQuote(
          paste0(
            'COPY (SELECT * FROM "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '" WHERE "', input$cstmReplInputSpecDateField, '" = \'', as.character(input$cstmReplInputSpecDateSelection),'\') TO STDOUT'
          )
        ),
        ' | ',
        'psql "', target_conn, '" -c ',
        shQuote(
          paste0(
            'COPY "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '" FROM STDIN'
          )
        )
      )
      
    }
    
    if(input$cstmReplInputTypeReplica == "dateinterval")
    {
      
      # Query for Data Deletion
      
      qryDeleteActualData <- str_c("DELETE FROM \"",input$cstmReplInputSchema,"\".\"",input$cstmReplInputTable,"\" WHERE \"",input$cstmReplInputIntervalDateField,"\" BETWEEN '",as.character(input$cstmReplInputIntervalDateInitial),"' AND '",as.character(input$cstmReplInputIntervalDateEnd),"';")
      
      # psql commands for Data Replica
      
      cmd <- paste0(
        'psql "', source_conn, '" -c ',
        shQuote(
          paste0(
            'COPY (SELECT * FROM "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '" WHERE "', input$cstmReplInputIntervalDateField, '" BETWEEN \'', as.character(input$cstmReplInputIntervalDateInitial),'\' AND \'',as.character(input$cstmReplInputIntervalDateEnd),'\' ) TO STDOUT'
          )
        ),
        ' | ',
        'psql "', target_conn, '" -c ',
        shQuote(
          paste0(
            'COPY "', input$cstmReplInputSchema, '"."', input$cstmReplInputTable,
            '" FROM STDIN'
          )
        )
      )

    }
    
    ##################
    # Replica Process
    ##################
    
    # 1. Set the initial Time of Replica
    
    start_time <- Sys.time()
    
    # 2. Establish an ODBC Connection to Source DB and Delete the Actual Data
    
    assign("destinationDBConnection", 
           dbConnect(RPostgres::Postgres(), 
                     host = configParamsDestinationConn$host,
                     port = configParamsDestinationConn$port,
                     dbname = configParamsDestinationConn$dbname,
                     user = auth$SandBoxDBRole
           ))
    
    DBI::dbSendQuery(destinationDBConnection, qryDeleteActualData)
    DBI::dbDisconnect(destinationDBConnection)
    
    # 3. Execute the psql customized commands for the Replica with system Function.
    
    result <- system(cmd, intern = TRUE)
    
    # 4. Prepare a Process Summary Based on the Rows Replicated and the Total Exec Time
    
    copy_line <- grep("COPY",result,value = TRUE)
    rowsReplicated <- as.numeric(gsub("COPY ","",copy_line))
    end_time <- Sys.time()
    
    duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)
    
    showModal(
      showReplicationResult(
        schema = input$cstmReplInputSchema,
        table = input$cstmReplInputTable,
        replica_type = input$cstmReplInputTypeReplica,
        records_replicated = rowsReplicated,
        execution_time = paste(duration, "seconds")
      )
    )
    
  })
  
  observeEvent(input$confirmReplicaExecution, {
    shinyjs::disable("cstmReplExecutionBttn")
    shinyjs::disable("cstmReplInputTypeReplica")
  })
  
}