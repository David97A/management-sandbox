app_ui <- bslib::page_fluid(
  
  theme = bslib::bs_theme(
    version = 5,
    primary = "#1f5fcf",
    success = "#00a86b",
    base_font = bslib::font_google("Inter")
  ),
  
  useShinyjs(),
  useSweetAlert(),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sandbox-management-style.css")
  ),
  
  # UI Design
  
  #### Custom Data Replication ####
  
  div(
    class = "top-banner",
    h1("Sandbox Data Management System"),
    p("Data Replication & Management Hub"),
    
    div(
      class = "user-info",
      icon("user"),
      textOutput("loggedUser")
    )
    
  ),
  
  div(
    class = "replication-card",
    
    div(
      class = "replication-title",
      icon("database"),
      "Custom Data Replication"
    ),
    
    div(
      class = "replication-subtitle",
      "Configure and Execute custom Data Replication Processes."
    ),
    
    fluidRow(
      column(width = 8,
             shiny::selectInput(
               inputId = "cstmReplInputSchema",
               label = tagList(
                 icon("database"),
                 " Schema Name"
               ),
               choices = c("Operations", "Sales", "Compliance", "BusinessSupport"),
               multiple = FALSE
             ))),
    
    fluidRow(
      column(width = 8,
             shiny::textInput(
               inputId = "cstmReplInputTable",
               label = tagList(
                 icon("table"),
                 " Table Name"
               )
             ))),
    
    div(
      class = "validation-panel",
      
      fluidRow(
        column(
          8,
          h4(
            icon("shield-alt"),
            " Validate Structure Before Replication"
          ),
          p("Check table structure, constraints and metadata.")
        ),
        column(
          4,
          actionButton(
            "cstmReplValidationBttn",
            label = tagList(
              icon("shield-alt"),
              " Validate Structure"
            )
          )
        )
      )
    ),
    
    fluidRow(
      
      column(width = 8,
             disabled(
               shiny::selectInput(
                 inputId = "cstmReplInputTypeReplica",
                 label = tagList(
                   icon("arrows-rotate"),
                   " Replication Type"
                 ),
                 choices = c("Whole Data Replica" = "overwrite",
                             "Date - Specific Replica" = "datespecific",
                             "Date - Interval Replica" = "dateinterval")
               )
             )
      )
    ),
    
    fluidRow(
      conditionalPanel(
        condition = "input.cstmReplInputTypeReplica == 'datespecific'",
        column(width = 2,
               selectInput(
                 inputId = "cstmReplInputSpecDateField",
                 label = "Date Column for Data Replica",
                 choices = ""
               )),
        column(width = 2,
               dateInput(
                 inputId = "cstmReplInputSpecDateSelection",
                 label = "Data Replication Date",
                 format = "yyyy-mm-dd"
               ))
      ),
      conditionalPanel(
        condition = "input.cstmReplInputTypeReplica == 'dateinterval'",
        column(width = 2,
               selectInput(
                 inputId = "cstmReplInputIntervalDateField",
                 label = "Date Column for Data Replica",
                 choices = ""
               )),
        column(width = 2,
               dateInput(
                 inputId = "cstmReplInputIntervalDateInitial",
                 label = "Data Replication Initial Date",
                 format = "yyyy-mm-dd"
               )),
        column(width = 2,
               dateInput(
                 inputId = "cstmReplInputIntervalDateEnd",
                 label = "Data Replication End Date",
                 format = "yyyy-mm-dd"
               ))
      )
    ),
    
    div(
      class = "execution-panel",
      
      fluidRow(
        column(width = 8,
               h4(
                 icon("rocket"),
                 "Execute Data Replica"
               ),
               p("Start the replication process using the selected options.")
        ),
        column(
          4,
          disabled(
            actionButton(
              "cstmReplExecutionBttn",
              label = tagList(
                icon("play"),
                " Execute Data Replica"
              )
            )
          )
        )
      )
    )
  )
)

secure_app(app_ui)