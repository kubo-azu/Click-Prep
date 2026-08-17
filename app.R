# 1. Load Libraries
library(shiny)
library(shinyjs)
library(readr)
library(readxl)
library(dplyr)
library(DT)

# 2. Define UI
ui <- fluidPage(
  title = "Click-Prep: Data Preparation Tool for Click-qPCR",
  
  shinyjs::useShinyjs(),
  
  tags$head(
    tags$style(HTML("
      .well { background-color: #f8f9fa; }
      .mapping-box { background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-bottom: 15px; border-left: 4px solid #007bff; }
      .editable-box { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px; border: 1px solid #dee2e6; border-left: 4px solid #28a745; }
      .group-badge { display: inline-block; background-color: #6c757d; color: white; padding: 4px 8px; border-radius: 4px; margin-right: 5px; margin-bottom: 5px; font-size: 13px; }
      .nav-tabs > li > a { font-size: 18px; }
      /* Disable text selection within tables (to prevent accidental selection). */
      .dataTable tbody tr { user-select: none; -webkit-user-select: none; cursor: pointer; }
    "))
  ),
  
  br(),
  
  # Title
  div(style = "display: flex; align-items: center; margin-bottom: 20px;",
      div(
        div(align = "left", style = "font-size: 38px; font-weight: bold; color: #2c3e50; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;",
            "🛟 Click-Prep: Data Preparation Tool for Click-qPCR 🛟"
        ),
        div(
          style = "font-size: 17px; color: #555; margin-top: 10px;",
          "An interactive tool to convert qPCR instrument output files into ",
          tags$a(
            href = "https://kubo-azu.shinyapps.io/Click-qPCR/",
            target = "_blank",
            "Click-qPCR"
          ),
          " input files.",
          tags$br(),
          "Preprint will be available soon."
        ),
        div(style = "text-align: left; margin-top: 10px; font-size: 17px; color: #555;", "🧬 App Version: v1.2.0 🧬"),
        div(align = "left", style = "margin-bottom: 3px;",
            tags$a(href = "https://github.com/kubo-azu/Click-Prep", target = "_blank", icon("github"), style = "font-size: 17px;", "Source code and documentation are available on GitHub"))
      )
  ),
  
  tabsetPanel(
    # Tab 1: Introduction
    tabPanel("Introduction",
             fluidRow(
               column(width = 12,
                      div( 
                        h3(strong("🔰 How to Use This App 🔰"), style = "margin-top: 25px; margin-bottom: 20px;"),
                        p(style = "font-size: 18px; color: #444; margin-top: 10px; margin-bottom: 15px;", 
                          "This tool converts tabular qPCR instrument output into the standardized format required for Click-qPCR analysis."),
                        tags$ol(style = "font-size: 17px; color: #333; line-height: 1.5;",
                                tags$li(strong("Import and Column Mapping: "), "Upload a qPCR instrument output file (.csv, .txt, .tsv, or .xlsx). Use the 'Skip' option to omit instrument-generated metadata rows above the column headers. Then, map the relevant columns to the required 'sample', 'group', 'gene', and 'Cq' fields."),
                                tags$li(strong("Manual Group Assignment: "), "If the instrument output lacks a 'group' column, select '[Assign groups manually]' to define and assign experimental groups within the app."),
                                tags$li(strong("Manual Data Review and Mean Cq Calculation: "), "Visually inspect technical-replicate measurements. Click-Prep does not automatically detect or classify outliers. Exclude selected rows only when justified by predefined quality-control criteria, then calculate mean Cq values and download the resulting dataset."),
                                tags$li(strong("Combine Formatted CSV Files: "), "Combine multiple compatible formatted CSV files, such as mean Cq datasets obtained from different qPCR plates.")
                        ),
                        br(),
                        div(style = "background-color: #f8f9fa; padding: 16px; border-radius: 5px; margin-top: 15px; margin-bottom: 15px; border: 1px solid #ced4da; border-left: 4px solid #6c757d;",
                            h5(strong("🔒 Privacy & Security Policy 🔒"), style = "margin-top: 0; font-size: 18px; color: #343a40;"),
                            tags$ul(style = "font-size: 17px; color: #555; margin-bottom: 0; padding-left: 20px;",
                                    tags$li(strong("Session-Based Processing: "), "Uploaded data are processed within the active application session. Click-Prep does not intentionally write uploaded qPCR data to persistent application storage."),
                                    tags$li(strong("Temporary-File Removal: "), "Temporary files created by Click-Prep are removed when they are no longer required or when the application session ends."),
                                    tags$li(strong("Data Handling: "), "Click-Prep does not intentionally transmit uploaded qPCR data to third parties. Data handling by the hosting platform is subject to the platform provider's applicable policies.")
                            )
                        )
                      )
               )
             )
    ),
    
    # 2nd tab
    tabPanel("Import and Column Mapping",
             br(),
             sidebarLayout(
               sidebarPanel(width = 6,
                            
                            h4("1. Upload Instrument Output", style = "font-weight: bold;"),
                            p("Supported formats: .csv, .txt, .tsv, .xlsx", style = "font-size: 16px;"),
                            fileInput("raw_file", "Choose File", 
                                      accept = c(".csv", ".txt", ".tsv", ".xlsx")),
                            
                            numericInput("skip_rows", "Skip first N rows (metadata):", 
                                         value = 0, min = 0, step = 1),
                            helpText("Increase this number if the file contains instrument-generated metadata above the column headers."),
                            
                            hr(),
                            h4("2. Column Mapping", style = "font-weight: bold;"),
                            p("Map the relevant columns to the required Click-qPCR fields.", style = "font-size: 16px;"),
                            
                            uiOutput("mapping_ui"),
                            uiOutput("manual_group_wrapper"),
                            
                            hr(style = "border-top: 1px solid #ccc;"),
                            div(style = "text-align: left;",
                                actionButton("reset_app", "Start Over / Reset All", icon = icon("sync-alt"), class = "btn-danger", style = "margin-top: 5px; margin-bottom: 10px;")
                            )
               ),
               
               mainPanel(width = 6,
                         h4("🔍 Data Preview 🔍", style =  "margin-top: 25px;"),
                         p("Verify that the headers are correctly recognized. If not, adjust the 'Skip first N rows' value.", style = "font-size: 16px;"),
                         
                         h5(strong("Original Data Preview:"), style = "font-size: 16px;"),
                         DT::dataTableOutput("original_preview"),
                         
                         br(),
                         
                         h5(strong("Formatted Data Preview:"), style = "font-size: 16px;"),
                         p("Ensure there are no missing values in the selected columns.", style = "font-size: 16px;"),
                         DT::dataTableOutput("formatted_preview"),
                         
                         uiOutput("status_msg"),
                         
                         br(), br()
               )
             )
    ),
    
    # 3rd tab
    tabPanel("Manual Data Review and Mean Cq Calculation",
             br(),
             fluidRow(
               column(width = 12,
                      h4("🔬 3. Manual Review of Replicate Measurements 🔬", style = "font-weight: bold;"),
                      p("This table displays replicate-level data. Click-Prep does not automatically detect or classify outliers. Exclude rows only when justified by predefined quality-control criteria.", style = "font-size: 16px;"),
                      
                      uiOutput("cq_review_warning"),
                      
                      DT::dataTableOutput("qc_preview"),
                      
                      div(style = "margin-top: 25px; margin-bottom: 30px; display: flex; align-items: center; gap: 10px;",
                          actionButton("delete_outlier_btn", "Exclude Selected Rows", class = "btn-danger", icon = icon("trash")),
                          actionButton("calc_mean_btn", "Calculate Mean Cq", class = "btn-primary", icon = icon("calculator")),
                          
                          uiOutput("qc_download_ui")
                      ),
                      
                      hr(style = "border-top: 2px solid #eee;"),
                      
                      h4("📊 4. Mean Cq Data Preview 📊", style = "font-weight: bold;"),
                      p("The calculated results will appear here once you click the 'Calculate Mean Cq' button.", style = "font-size: 16px;"),
                      DT::dataTableOutput("mean_preview"),
                      br(),
                      uiOutput("mean_download_ui"),
                      br(), br()
               )
             )
    ),
    
    # 4th tab
    tabPanel("Combine Formatted CSV Files",
             br(),
             sidebarLayout(
               sidebarPanel(width = 6,
                            h4("Upload Compatible CSV Files", style = "font-weight: bold;"),
                            p("Select formatted CSV files with identical columns and compatible data types. Mean Cq datasets are recommended.", style = "font-size: 16px;"),
                            
                            div(style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 4px solid #ffc107; margin-bottom: 15px; font-size: 15px; color: #856404;",
                                strong(icon("exclamation-triangle"), " Important:"), " Do not combine mean Cq datasets with replicate-level datasets. All files must contain exactly the columns sample, group, gene, and Cq."
                            ),
                            
                            fileInput("merge_files", "Choose CSV Files (Upload multiple times to append)", 
                                      multiple = TRUE, 
                                      accept = c(".csv")),
                            
                            uiOutput("accumulated_files_ui"),
                            
                            hr(),
                            uiOutput("merge_download_ui")
               ),
               
               mainPanel(width = 6,
                         h4("⚡️ Merged Data Preview ⚡️", style =  "margin-top: 25px;"),
                         p("Preview of the combined dataset ready for Click-qPCR.", style = "font-size: 16px;"),
                         DT::dataTableOutput("merged_preview")
               )
             )
    )
  )
)

# 3. Define Server
server <- function(input, output, session) {
  
  # Create a specific temp directory for this session's merged files
  merge_temp_dir <- file.path(tempdir(), paste0("merge_", session$token))
  dir.create(merge_temp_dir, showWarnings = FALSE)
  
  session$onSessionEnded(function() {
    unlink(merge_temp_dir, recursive = TRUE)
    rm(list = ls())
    gc()
  })
  
  observeEvent(input$reset_app, {
    session$reload()
  })
  
  raw_data <- reactive({
    req(input$raw_file)
    ext <- tolower(tools::file_ext(input$raw_file$name))
    skip_n <- input$skip_rows
    
    on.exit({
      if (file.exists(input$raw_file$datapath)) {
        unlink(input$raw_file$datapath)
      }
    }, add = TRUE)
    
    tryCatch({
      if (ext == "csv") {
        read_csv(input$raw_file$datapath, skip = skip_n, col_names = TRUE, show_col_types = FALSE)
      } else if (ext %in% c("txt", "tsv")) {
        read_tsv(input$raw_file$datapath, skip = skip_n, col_names = TRUE, show_col_types = FALSE)
      } else if (ext == "xlsx") {
        read_excel(input$raw_file$datapath, skip = skip_n)
      } else {
        stop("Unsupported file type")
      }
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$original_preview <- DT::renderDataTable({
    req(raw_data())
    DT::datatable(
      raw_data(), 
      options = list(
        scrollX = TRUE, 
        scrollY = "450px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$mapping_ui <- renderUI({
    df <- raw_data()
    if (is.null(df) || ncol(df) < 3) {
      return(p(style="color: red;", "The uploaded file must have at least three columns for sample, target, and Cq values. Please check the file and the 'Skip' setting."))
    }
    cols <- colnames(df)
    
    div(class = "mapping-box",
        selectInput("col_sample", "Which column contains sample names?", 
                    choices = c("Select..." = "", cols), selected = ""),
        selectInput("col_group", "Which column contains experimental groups?", 
                    choices = c("Select..." = "", "[Assign groups manually]" = "MANUAL_ASSIGN", cols), 
                    selected = ""),
        selectInput("col_gene", "Which column contains target genes or genomic loci?", 
                    choices = c("Select..." = "", cols), selected = ""),
        selectInput("col_cq", "Which column contains Cq values?", 
                    choices = c("Select..." = "", cols), selected = "")
    )
  })
  
  group_assignment <- reactiveVal(NULL)
  table_redraw_trigger <- reactiveVal(0)
  
  defined_groups <- reactiveVal(character(0))
  
  observeEvent(input$add_group_btn, {
    req(input$new_group_name)
    new_grp <- trimws(input$new_group_name)
    curr_grps <- defined_groups()
    
    if (new_grp != "" && !(new_grp %in% curr_grps)) {
      defined_groups(c(curr_grps, new_grp))
      updateTextInput(session, "new_group_name", value = "")
    }
  })
  
  output$defined_groups_badges <- renderUI({
    grps <- defined_groups()
    if (length(grps) == 0) return(p(style="color: #777; font-size: 13px;", "No groups defined yet."))
    
    badge_list <- lapply(grps, function(g) {
      tags$span(class = "group-badge", g)
    })
    
    div(style = "margin-bottom: 10px;", badge_list)
  })
  
  observe({
    grp <- input$col_group
    smp <- input$col_sample
    req(grp == "MANUAL_ASSIGN", smp != "")
    
    df <- raw_data()
    if (!smp %in% colnames(df)) return()
    
    samps <- unique(df[[smp]])
    samps <- samps[!is.na(samps)]
    if (length(samps) == 0) return()
    
    isolate({
      curr <- group_assignment()
      if (is.null(curr) || !identical(curr$Sample, samps)) {
        group_assignment(data.frame(Sample = samps, Group = "Unassigned", stringsAsFactors = FALSE))
        table_redraw_trigger(table_redraw_trigger() + 1) 
      }
    })
  })
  
  output$manual_group_wrapper <- renderUI({
    grp <- input$col_group
    
    req(grp == "MANUAL_ASSIGN")
    
    div(class = "editable-box",
        h4(strong(icon("users"), "Assign Groups Manually"), style="margin-top:0; color: #28a745;"),
        
        div(style = "background-color: #ffffff; padding: 10px; border-radius: 5px; border: 1px solid #ced4da; margin-bottom: 15px;",
            h5(strong("Step 1: Define your groups")),
            textInput("new_group_name", NULL, placeholder = "e.g., Treatment_X", width = "200px"),
            actionButton("add_group_btn", "Add Group", icon = icon("plus"), class = "btn-default", style = "margin-bottom: 15px;"),
            uiOutput("defined_groups_badges")
        ),
        
        div(style = "background-color: #ffffff; padding: 10px; border-radius: 5px; border: 1px solid #ced4da; margin-bottom: 15px;",
            h5(strong("Step 2: Assign groups to samples")),
            p(style="font-size: 13px; color: #555;", 
              "1. Search & Select samples ", icon("arrow-down"), br(),
              "2. Choose group and Apply."),
            
            DT::dataTableOutput("manual_group_table"),
            
            div(style = "display: flex; gap: 5px; margin-top: 20px; margin-bottom: 15px;",
                actionButton("select_all_btn", "Select All", class = "btn-default btn-sm", icon = icon("check-square")),
                actionButton("clear_sel_btn", "Clear", class = "btn-default btn-sm", icon = icon("square"))
            ),
            
            div(style = "margin-bottom: 10px;",
                strong("Assign to:", style="font-size: 13px; display: block; margin-bottom: 5px;"),
                selectInput("bulk_group_select", label = NULL, choices = defined_groups(), width = "200px")
            ),
            
            actionButton("apply_bulk", "Apply", class = "btn-success", icon = icon("check"), style = "margin-bottom: 15px;")
        )
    )
  })
  
  observeEvent(defined_groups(), {
    updateSelectInput(session, "bulk_group_select", choices = defined_groups())
  })
  
  observeEvent(input$select_all_btn, {
    proxy <- dataTableProxy("manual_group_table")
    selectRows(proxy, input$manual_group_table_rows_all)
  })
  
  observeEvent(input$clear_sel_btn, {
    proxy <- dataTableProxy("manual_group_table")
    selectRows(proxy, NULL)
  })
  
  output$manual_group_table <- DT::renderDataTable({
    table_redraw_trigger() 
    grp_assign <- group_assignment()
    
    if (is.null(grp_assign)) {
      return(DT::datatable(
        data.frame(Sample = character(0), Group = character(0)),
        rownames = FALSE,
        options = list(dom = 't', columnDefs = list(list(className = 'dt-left', targets = "_all")))
      ))
    }
    
    isolate({
      DT::datatable(
        grp_assign,
        selection = 'multiple', 
        options = list(
          dom = 'ft', 
          paging = FALSE, 
          scrollY = "200px",
          columnDefs = list(list(className = 'dt-left', targets = "_all"))
        ), 
        rownames = FALSE
      ) %>% formatStyle(
        'Group',
        backgroundColor = styleEqual("Unassigned", "#ffc107")
      )
    })
  })
  
  observeEvent(input$apply_bulk, {
    req(input$bulk_group_select)
    sel <- input$manual_group_table_rows_selected 
    
    if (length(sel) > 0) {
      curr <- group_assignment()
      curr$Group[sel] <- input$bulk_group_select
      group_assignment(curr)
      
      proxy <- dataTableProxy("manual_group_table")
      replaceData(proxy, curr, resetPaging = FALSE, clearSelection = "none")
      
    } else {
      showNotification("Please select at least one row in the table first.", type = "warning")
    }
  })
  
  formatted_data <- reactive({
    req(raw_data(), input$col_sample, input$col_gene, input$col_cq)
    df <- raw_data()
    
    tryCatch({
      mapped_columns <- c(input$col_sample, input$col_gene, input$col_cq)
      if (input$col_group != "MANUAL_ASSIGN") {
        mapped_columns <- c(mapped_columns, input$col_group)
      }
      if (length(unique(mapped_columns)) != length(mapped_columns)) {
        stop("Each source column must be mapped to only one Click-qPCR field.")
      }
      
      if (input$col_group == "MANUAL_ASSIGN") {
        req(group_assignment())
        res <- df %>%
          select(
            sample = !!sym(input$col_sample),
            gene = !!sym(input$col_gene),
            Cq = !!sym(input$col_cq)
          ) %>%
          left_join(group_assignment(), by = c("sample" = "Sample")) %>%
          rename(group = Group)
      } else {
        req(input$col_group != "")
        res <- df %>%
          select(
            sample = !!sym(input$col_sample),
            group = !!sym(input$col_group),
            gene = !!sym(input$col_gene),
            Cq = !!sym(input$col_cq)
          )
      }
      
      original_cq <- res$Cq
      res$Cq <- suppressWarnings(as.numeric(as.character(original_cq)))
      res <- res %>% select(sample, group, gene, Cq)
      
      missing_identifiers <- is.na(res$sample) | trimws(as.character(res$sample)) == "" |
        is.na(res$group) | trimws(as.character(res$group)) == "" |
        is.na(res$gene) | trimws(as.character(res$gene)) == ""
      
      if (any(missing_identifiers)) {
        stop(paste0(sum(missing_identifiers), " row(s) contain missing sample, group, or gene values."))
      }
      
      return(res)
    }, error = function(e) {
      message <- if (nzchar(conditionMessage(e))) conditionMessage(e) else "Please complete all column mappings."
      showNotification(paste("Unable to format data:", message), type = "error")
      return(NULL)
    })
  })
  
  output$formatted_preview <- DT::renderDataTable({
    df <- formatted_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please complete all column mappings above."), rownames = FALSE, options=list(dom='t')))
    }
    DT::datatable(
      df, 
      options = list(
        scrollX = TRUE, 
        scrollY = "450px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$status_msg <- renderUI({
    req(raw_data())
    
    is_complete <- FALSE
    
    if (isTruthy(input$col_sample) && 
        isTruthy(input$col_gene) && 
        isTruthy(input$col_cq) && 
        isTruthy(input$col_group)) {
      
      is_complete <- TRUE
      
      if (input$col_group == "MANUAL_ASSIGN") {
        grp_assign <- group_assignment()
        if (is.null(grp_assign) || "Unassigned" %in% grp_assign$Group) {
          is_complete <- FALSE
        }
      }
    }
    
    formatted <- if (is_complete) formatted_data() else NULL
    
    if (is_complete && !is.null(formatted)) {
      invalid_cq_count <- sum(is.na(formatted$Cq) | !is.finite(formatted$Cq))
      
      if (invalid_cq_count > 0) {
        return(
          div(style = "margin-top: 20px; padding: 15px; background-color: #fff3cd; border: 1px solid #ffeeba; color: #856404; border-radius: 5px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
              h4(strong(icon("exclamation-triangle"), " Mapping Complete with Cq Warnings")),
              p(style = "font-size: 16px; margin-bottom: 8px;",
                paste0(invalid_cq_count, " row(s) contain missing or nonnumeric Cq values.")),
              p(style = "font-size: 16px; margin-bottom: 15px;",
                "Proceed to Manual Data Review and exclude the affected rows, or click Start Over / Reset All to revise the input file. Mean Cq values cannot be calculated while invalid Cq values remain."),
              downloadButton("download_raw_formatted_csv", "Download Formatted CSV (All Replicates)", class = "btn-warning")
          )
        )
      }
      
      div(style = "margin-top: 20px; padding: 15px; background-color: #d4edda; border-color: #c3e6cb; color: #155724; border-radius: 5px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
          h4(strong(icon("check-circle"), " Mapping Complete!")),
          p(style = "font-size: 16px; margin-bottom: 15px;", 
            "You are ready to go! Please proceed to the ", 
            strong("Manual Data Review and Mean Cq Calculation"), 
            " tab, or download the formatted replicate-level data below."),
          downloadButton("download_raw_formatted_csv", "Download Formatted CSV (All Replicates)", class = "btn-success")
      )
    } else {
      div(style = "margin-top: 20px; padding: 15px; background-color: #fff3cd; border-color: #ffeeba; color: #856404; border-radius: 5px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
          h4(strong(icon("exclamation-circle"), " Action Required")),
          p(style = "font-size: 16px; margin-bottom: 0;", 
            "Please complete all column mappings (and assign groups if manual) to proceed.")
      )
    }
  })
  
  output$download_raw_formatted_csv <- downloadHandler(
    filename = function() {
      paste0("formatted_all_reps_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(formatted_data())
      write.csv(formatted_data(), file, row.names = FALSE, na = "")
    }
  )
  
  # --- Variables and processing for Tab 3: Manual Data Review and Mean Cq Calculation ---
  qc_data <- reactiveVal(NULL)      
  mean_calculated <- reactiveVal(FALSE) 
  
  observeEvent(formatted_data(), {
    qc_data(formatted_data())
    mean_calculated(FALSE)
  })
  
  output$cq_review_warning <- renderUI({
    df <- qc_data()
    req(df)
    invalid_cq_count <- sum(is.na(df$Cq) | !is.finite(df$Cq))
    
    if (invalid_cq_count == 0) return(NULL)
    
    div(style = "margin: 15px 0; padding: 14px; background-color: #fff3cd; border: 1px solid #ffeeba; border-left: 4px solid #ffc107; color: #856404; border-radius: 5px;",
        strong(icon("exclamation-triangle"), paste0(" ", invalid_cq_count, " row(s) require review. ")),
        "Missing or nonnumeric Cq values are displayed as NA. Exclude the affected rows before calculating mean Cq values, or return to the previous tab and click Start Over / Reset All to revise the input file."
    )
  })
  
  output$qc_preview <- DT::renderDataTable({
    df <- qc_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please complete column mapping in the 'Import and Column Mapping' tab first."), rownames = FALSE, options=list(dom='t')))
    }
    
    DT::datatable(
      df, 
      selection = 'multiple', 
      options = list(
        scrollX = TRUE, 
        scrollY = "300px", 
        paging = FALSE, 
        dom = 'ft', 
        order = list(list(0, 'asc'), list(2, 'asc')), 
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$qc_download_ui <- renderUI({
    req(qc_data())
    downloadButton("download_qc_csv", "Download Retained Replicate Data", class = "btn-default")
  })
  
  output$download_qc_csv <- downloadHandler(
    filename = function() {
      paste0("cleaned_all_reps_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(qc_data())
      write.csv(qc_data(), file, row.names = FALSE, na = "")
    }
  )
  
  observeEvent(input$delete_outlier_btn, {
    sel <- input$qc_preview_rows_selected
    if (length(sel) > 0) {
      df <- qc_data()
      df <- df[-sel, ]
      qc_data(df)
      mean_calculated(FALSE) 
      
      proxy <- dataTableProxy("qc_preview")
      selectRows(proxy, NULL) 
    } else {
      showNotification("Please select the rows you want to delete from the table first.", type = "warning")
    }
  })
  
  observeEvent(input$calc_mean_btn, {
    df <- qc_data()
    req(df)
    
    invalid_cq <- is.na(df$Cq) | !is.finite(df$Cq)
    if (any(invalid_cq)) {
      showNotification(
        paste0(
          sum(invalid_cq),
          " row(s) contain missing or invalid Cq values. Exclude these rows or restart with a revised input file before calculating mean Cq values."
        ),
        type = "error",
        duration = NULL
      )
      mean_calculated(FALSE)
      return()
    }
    
    mean_calculated(TRUE)
  })
  
  mean_data <- reactive({
    req(mean_calculated(), qc_data())
    df <- qc_data()
    
    df %>%
      group_by(sample, group, gene) %>%
      summarise(
        Cq = mean(Cq),
        .groups = "drop"
      ) %>%
      select(sample, group, gene, Cq)
  })
  
  output$mean_preview <- DT::renderDataTable({
    if (!mean_calculated()) {
      return(datatable(data.frame(Message = "Please click the 'Calculate Mean Cq' button above."), rownames = FALSE, options=list(dom='t')))
    }
    
    DT::datatable(
      mean_data(), 
      options = list(
        scrollX = TRUE, 
        scrollY = "300px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$mean_download_ui <- renderUI({
    if (!mean_calculated() || is.null(mean_data())) return(NULL)
    
    div(style = "margin-top: 15px;",
        downloadButton("download_mean_csv", "Download Mean Cq Dataset (Ready for Click-qPCR)", class = "btn-success btn-lg")
    )
  })
  
  output$download_mean_csv <- downloadHandler(
    filename = function() {
      paste0("mean_Cq_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(mean_data())
      write.csv(mean_data(), file, row.names = FALSE, na = "")
    }
  )
  
  # --- Tab 4: Combine Formatted CSV Files ---
  accumulated_files <- reactiveVal(character(0))
  accumulated_names <- reactiveVal(character(0))
  
  observeEvent(input$merge_files, {
    req(input$merge_files)
    new_files <- input$merge_files
    
    curr_paths <- accumulated_files()
    curr_names <- accumulated_names()
    
    for (i in 1:nrow(new_files)) {
      # Ignore files with duplicate names in the current list
      if (!(new_files$name[i] %in% curr_names)) {
        dest <- file.path(merge_temp_dir, new_files$name[i])
        file.copy(new_files$datapath[i], dest, overwrite = TRUE)
        curr_paths <- c(curr_paths, dest)
        curr_names <- c(curr_names, new_files$name[i])
      }
    }
    accumulated_files(curr_paths)
    accumulated_names(curr_names)
  })
  
  output$accumulated_files_ui <- renderUI({
    names <- accumulated_names()
    if (length(names) == 0) return(NULL)
    div(style = "margin-bottom: 15px; background-color: #f8f9fa; padding: 10px; border-radius: 5px; border: 1px solid #dee2e6;",
        strong(icon("file-csv"), " Currently loaded files:"),
        tags$ul(style = "padding-left: 20px; font-size: 13px; color: #555; margin-bottom: 0;",
                lapply(names, function(n) tags$li(n)))
    )
  })
  
  observeEvent(input$reset_merge_btn, {
    accumulated_files(character(0))
    accumulated_names(character(0))
    shinyjs::reset("merge_files")
    unlink(list.files(merge_temp_dir, full.names = TRUE))
  })
  
  merged_data <- reactive({
    req(length(accumulated_files()) > 0)
    
    tryCatch({
      files <- accumulated_files()
      required_columns <- c("sample", "group", "gene", "Cq")
      df_list <- lapply(seq_along(files), function(i) {
        df <- read_csv(files[[i]], show_col_types = FALSE)
        if (!identical(names(df), required_columns)) {
          stop(paste0("File '", accumulated_names()[[i]], "' must contain exactly these columns in this order: ", paste(required_columns, collapse = ", "), "."))
        }
        cq_numeric <- suppressWarnings(as.numeric(as.character(df$Cq)))
        if (any(is.na(cq_numeric) | !is.finite(cq_numeric))) {
          stop(paste0("File '", accumulated_names()[[i]], "' contains missing or nonnumeric Cq values."))
        }
        if (any(is.na(df$sample) | trimws(as.character(df$sample)) == "" |
                is.na(df$group) | trimws(as.character(df$group)) == "" |
                is.na(df$gene) | trimws(as.character(df$gene)) == "")) {
          stop(paste0("File '", accumulated_names()[[i]], "' contains missing sample, group, or gene values."))
        }
        df$Cq <- cq_numeric
        df
      })
      
      merged_df <- bind_rows(df_list)
      return(merged_df)
    }, error = function(e) {
      showNotification(paste("Error merging files:", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$merged_preview <- DT::renderDataTable({
    df <- merged_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please upload multiple CSV files to merge."), rownames = FALSE, options=list(dom='t')))
    }
    DT::datatable(
      df, 
      options = list(
        scrollX = TRUE, 
        scrollY = "400px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$merge_download_ui <- renderUI({
    if (!is.null(merged_data()) && length(accumulated_files()) > 0) {
      div(style = "display: flex; gap: 10px; align-items: center;",
          downloadButton("download_merged_csv", "Download Merged CSV", class = "btn-primary btn-lg"),
          actionButton("reset_merge_btn", "Reset Files", icon = icon("trash"), class = "btn-danger")
      )
    } else {
      p(style = "color: #777;", "Download and Reset buttons will appear once files are loaded.")
    }
  })
  
  output$download_merged_csv <- downloadHandler(
    filename = function() {
      paste0("merged_Click-qPCR_input_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(merged_data())
      write.csv(merged_data(), file, row.names = FALSE, na = "")
    }
  )
}

# 4. Run the Application
shinyApp(ui, server)
                            tags$ul(style = "font-size: 17px; color: #555; margin-bottom: 0; padding-left: 20px;",
                                    tags$li(strong("In-Memory Processing: "), "Uploaded files are processed exclusively in the server's active memory for the duration of your current session. No files are permanently stored."),
                                    tags$li(strong("Automatic Data Purge: "), "All temporary files and cached data are automatically and completely destroyed immediately after processing or when you close the browser tab."),
                                    tags$li(strong("Zero Tracking & Sharing: "), "Your input data, analytical conditions, and formatting results remain strictly confidential. No data is collected, logged, or shared with any third parties.")
                            )
                        )
                      )
               )
             )
    ),
    
    # 2nd tab
    tabPanel("File Trimming",
             br(),
             sidebarLayout(
               sidebarPanel(width = 6,
                            
                            h4("1. Upload Raw Data", style = "font-weight: bold;"),
                            p("Supported formats: .csv, .txt, .tsv, .xlsx", style = "font-size: 16px;"),
                            fileInput("raw_file", "Choose File", 
                                      accept = c(".csv", ".txt", ".tsv", ".xlsx")),
                            
                            numericInput("skip_rows", "Skip first N rows (metadata):", 
                                         value = 0, min = 0, step = 1),
                            helpText("Increase this number if your file has machine information at the top before the actual data headers."),
                            
                            hr(),
                            h4("2. Column Mapping", style = "font-weight: bold;"),
                            p("Match your file's columns to the required Click-qPCR format.", style = "font-size: 16px;"),
                            
                            uiOutput("mapping_ui"),
                            uiOutput("manual_group_wrapper"),
                            
                            hr(style = "border-top: 1px solid #ccc;"),
                            div(style = "text-align: left;",
                                actionButton("reset_app", "Start Over / Reset All", icon = icon("sync-alt"), class = "btn-danger", style = "margin-top: 5px; margin-bottom: 10px;")
                            )
               ),
               
               mainPanel(width = 6,
                         h4("🔍 Data Preview 🔍", style =  "margin-top: 25px;"),
                         p("Verify that the headers are correctly recognized. If not, adjust the 'Skip first N rows' value.", style = "font-size: 16px;"),
                         
                         h5(strong("Original Data Preview:"), style = "font-size: 16px;"),
                         DT::dataTableOutput("original_preview"),
                         
                         br(),
                         
                         h5(strong("Trimmed Data Preview:"), style = "font-size: 16px;"),
                         p("Ensure there are no missing values in the selected columns.", style = "font-size: 16px;"),
                         DT::dataTableOutput("formatted_preview"),
                         
                         uiOutput("status_msg"),
                         
                         br(), br()
               )
             )
    ),
    
    # 3rd tab
    tabPanel("Outlier Removal & Mean Cq Calculation",
             br(),
             fluidRow(
               column(width = 12,
                      h4("🔬 3. Manual Outlier Removal 🔬", style = "font-weight: bold;"),
                      p("This table displays all replicate data. This tool does not automatically detect outliers. Please visually inspect your data, click to select any anomalous rows, and press the 'Delete Selected Rows' button.", style = "font-size: 16px;"),
                      
                      DT::dataTableOutput("qc_preview"),
                      
                      div(style = "margin-top: 25px; margin-bottom: 30px; display: flex; align-items: center; gap: 10px;",
                          actionButton("delete_outlier_btn", "Delete Selected Rows", class = "btn-danger", icon = icon("trash")),
                          actionButton("calc_mean_btn", "Calculate Mean Cq", class = "btn-primary", icon = icon("calculator")),
                          
                          uiOutput("qc_download_ui")
                      ),
                      
                      hr(style = "border-top: 2px solid #eee;"),
                      
                      h4("📊 4. Mean Cq Data Preview 📊", style = "font-weight: bold;"),
                      p("The calculated results will appear here once you click the 'Calculate Mean Cq' button.", style = "font-size: 16px;"),
                      DT::dataTableOutput("mean_preview"),
                      br(),
                      uiOutput("mean_download_ui"),
                      br(), br()
               )
             )
    ),
    
    # 4th tab
    tabPanel("Advanced - Input CSV Integration",
             br(),
             sidebarLayout(
               sidebarPanel(width = 6,
                            h4("Upload Multiple CSVs", style = "font-weight: bold;"),
                            p("Select multiple fully formatted CSV files (or Mean Cq CSV files) to merge them into a single dataset.", style = "font-size: 16px;"),
                            
                            div(style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 4px solid #ffc107; margin-bottom: 15px; font-size: 15px; color: #856404;",
                                strong(icon("exclamation-triangle"), " Important:"), " Do not mix different types of CSV files. Generally, 'Mean Cq CSV' files are recommended for this function."
                            ),
                            
                            fileInput("merge_files", "Choose CSV Files (Upload multiple times to append)", 
                                      multiple = TRUE, 
                                      accept = c(".csv")),
                            
                            uiOutput("accumulated_files_ui"),
                            
                            hr(),
                            uiOutput("merge_download_ui")
               ),
               
               mainPanel(width = 6,
                         h4("⚡️ Merged Data Preview ⚡️", style =  "margin-top: 25px;"),
                         p("Preview of the combined dataset ready for Click-qPCR.", style = "font-size: 16px;"),
                         DT::dataTableOutput("merged_preview")
               )
             )
    )
  )
)

# 3. Define Server
server <- function(input, output, session) {
  
  # Create a specific temp directory for this session's merged files
  merge_temp_dir <- file.path(tempdir(), paste0("merge_", session$token))
  dir.create(merge_temp_dir, showWarnings = FALSE)
  
  session$onSessionEnded(function() {
    unlink(merge_temp_dir, recursive = TRUE)
    rm(list = ls())
    gc()
  })
  
  observeEvent(input$reset_app, {
    session$reload()
  })
  
  raw_data <- reactive({
    req(input$raw_file)
    ext <- tools::file_ext(input$raw_file$name)
    skip_n <- input$skip_rows
    
    on.exit({
      if (file.exists(input$raw_file$datapath)) {
        unlink(input$raw_file$datapath)
      }
    }, add = TRUE)
    
    tryCatch({
      if (ext == "csv") {
        read_csv(input$raw_file$datapath, skip = skip_n, col_names = TRUE, show_col_types = FALSE)
      } else if (ext %in% c("txt", "tsv")) {
        read_tsv(input$raw_file$datapath, skip = skip_n, col_names = TRUE, show_col_types = FALSE)
      } else if (ext == "xlsx") {
        read_excel(input$raw_file$datapath, skip = skip_n)
      } else {
        stop("Unsupported file type")
      }
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$original_preview <- DT::renderDataTable({
    req(raw_data())
    DT::datatable(
      raw_data(), 
      options = list(
        scrollX = TRUE, 
        scrollY = "450px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$mapping_ui <- renderUI({
    df <- raw_data()
    if (is.null(df) || ncol(df) < 4) {
      return(p(style="color: red;", "Uploaded file must have at least 4 columns. Please check the file and the 'Skip' setting."))
    }
    cols <- colnames(df)
    
    div(class = "mapping-box",
        selectInput("col_sample", "Which column contains sample names?", 
                    choices = c("Select..." = "", cols), selected = ""),
        selectInput("col_group", "Which column contains group conditions?", 
                    choices = c("Select..." = "", "[Assign groups manually]" = "MANUAL_ASSIGN", cols), 
                    selected = ""),
        selectInput("col_gene", "Which column contains gene targets?", 
                    choices = c("Select..." = "", cols), selected = ""),
        selectInput("col_cq", "Which column contains Cq values?", 
                    choices = c("Select..." = "", cols), selected = "")
    )
  })
  
  group_assignment <- reactiveVal(NULL)
  table_redraw_trigger <- reactiveVal(0)
  
  defined_groups <- reactiveVal(character(0))
  
  observeEvent(input$add_group_btn, {
    req(input$new_group_name)
    new_grp <- trimws(input$new_group_name)
    curr_grps <- defined_groups()
    
    if (new_grp != "" && !(new_grp %in% curr_grps)) {
      defined_groups(c(curr_grps, new_grp))
      updateTextInput(session, "new_group_name", value = "")
    }
  })
  
  output$defined_groups_badges <- renderUI({
    grps <- defined_groups()
    if (length(grps) == 0) return(p(style="color: #777; font-size: 13px;", "No groups defined yet."))
    
    badge_list <- lapply(grps, function(g) {
      tags$span(class = "group-badge", g)
    })
    
    div(style = "margin-bottom: 10px;", badge_list)
  })
  
  observe({
    grp <- input$col_group
    smp <- input$col_sample
    req(grp == "MANUAL_ASSIGN", smp != "")
    
    df <- raw_data()
    if (!smp %in% colnames(df)) return()
    
    samps <- unique(df[[smp]])
    samps <- samps[!is.na(samps)]
    if (length(samps) == 0) return()
    
    isolate({
      curr <- group_assignment()
      if (is.null(curr) || !identical(curr$Sample, samps)) {
        group_assignment(data.frame(Sample = samps, Group = "Unassigned", stringsAsFactors = FALSE))
        table_redraw_trigger(table_redraw_trigger() + 1) 
      }
    })
  })
  
  output$manual_group_wrapper <- renderUI({
    grp <- input$col_group
    
    req(grp == "MANUAL_ASSIGN")
    
    div(class = "editable-box",
        h4(strong(icon("users"), "Assign Groups Manually"), style="margin-top:0; color: #28a745;"),
        
        div(style = "background-color: #ffffff; padding: 10px; border-radius: 5px; border: 1px solid #ced4da; margin-bottom: 15px;",
            h5(strong("Step 1: Define your groups")),
            textInput("new_group_name", NULL, placeholder = "e.g., Treatment_X", width = "200px"),
            actionButton("add_group_btn", "Add Group", icon = icon("plus"), class = "btn-default", style = "margin-bottom: 15px;"),
            uiOutput("defined_groups_badges")
        ),
        
        div(style = "background-color: #ffffff; padding: 10px; border-radius: 5px; border: 1px solid #ced4da; margin-bottom: 15px;",
            h5(strong("Step 2: Assign groups to samples")),
            p(style="font-size: 13px; color: #555;", 
              "1. Search & Select samples ", icon("arrow-down"), br(),
              "2. Choose group and Apply."),
            
            DT::dataTableOutput("manual_group_table"),
            
            div(style = "display: flex; gap: 5px; margin-top: 20px; margin-bottom: 15px;",
                actionButton("select_all_btn", "Select All", class = "btn-default btn-sm", icon = icon("check-square")),
                actionButton("clear_sel_btn", "Clear", class = "btn-default btn-sm", icon = icon("square"))
            ),
            
            div(style = "margin-bottom: 10px;",
                strong("Assign to:", style="font-size: 13px; display: block; margin-bottom: 5px;"),
                selectInput("bulk_group_select", label = NULL, choices = defined_groups(), width = "200px")
            ),
            
            actionButton("apply_bulk", "Apply", class = "btn-success", icon = icon("check"), style = "margin-bottom: 15px;")
        )
    )
  })
  
  observeEvent(defined_groups(), {
    updateSelectInput(session, "bulk_group_select", choices = defined_groups())
  })
  
  observeEvent(input$select_all_btn, {
    proxy <- dataTableProxy("manual_group_table")
    selectRows(proxy, input$manual_group_table_rows_all)
  })
  
  observeEvent(input$clear_sel_btn, {
    proxy <- dataTableProxy("manual_group_table")
    selectRows(proxy, NULL)
  })
  
  output$manual_group_table <- DT::renderDataTable({
    table_redraw_trigger() 
    grp_assign <- group_assignment()
    
    if (is.null(grp_assign)) {
      return(DT::datatable(
        data.frame(Sample = character(0), Group = character(0)),
        rownames = FALSE,
        options = list(dom = 't', columnDefs = list(list(className = 'dt-left', targets = "_all")))
      ))
    }
    
    isolate({
      DT::datatable(
        grp_assign,
        selection = 'multiple', 
        options = list(
          dom = 'ft', 
          paging = FALSE, 
          scrollY = "200px",
          columnDefs = list(list(className = 'dt-left', targets = "_all"))
        ), 
        rownames = FALSE
      ) %>% formatStyle(
        'Group',
        backgroundColor = styleEqual("Unassigned", "#ffc107")
      )
    })
  })
  
  observeEvent(input$apply_bulk, {
    req(input$bulk_group_select)
    sel <- input$manual_group_table_rows_selected 
    
    if (length(sel) > 0) {
      curr <- group_assignment()
      curr$Group[sel] <- input$bulk_group_select
      group_assignment(curr)
      
      proxy <- dataTableProxy("manual_group_table")
      replaceData(proxy, curr, resetPaging = FALSE, clearSelection = "none")
      
    } else {
      showNotification("Please select at least one row in the table first.", type = "warning")
    }
  })
  
  formatted_data <- reactive({
    req(raw_data(), input$col_sample, input$col_gene, input$col_cq)
    df <- raw_data()
    
    tryCatch({
      if (input$col_group == "MANUAL_ASSIGN") {
        req(group_assignment())
        res <- df %>%
          select(
            sample = !!sym(input$col_sample),
            gene = !!sym(input$col_gene),
            Cq = !!sym(input$col_cq)
          ) %>%
          left_join(group_assignment(), by = c("sample" = "Sample")) %>%
          rename(group = Group)
      } else {
        req(input$col_group != "")
        res <- df %>%
          select(
            sample = !!sym(input$col_sample),
            group = !!sym(input$col_group),
            gene = !!sym(input$col_gene),
            Cq = !!sym(input$col_cq)
          )
      }
      
      res$Cq <- suppressWarnings(as.numeric(as.character(res$Cq)))
      res <- res %>% select(sample, group, gene, Cq)
      
      return(res)
    }, error = function(e) {
      showNotification("Error applying column mapping.", type = "error")
      return(NULL)
    })
  })
  
  output$formatted_preview <- DT::renderDataTable({
    df <- formatted_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please complete all column mappings above."), rownames = FALSE, options=list(dom='t')))
    }
    DT::datatable(
      df, 
      options = list(
        scrollX = TRUE, 
        scrollY = "450px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$status_msg <- renderUI({
    req(raw_data())
    
    is_complete <- FALSE
    
    if (isTruthy(input$col_sample) && 
        isTruthy(input$col_gene) && 
        isTruthy(input$col_cq) && 
        isTruthy(input$col_group)) {
      
      is_complete <- TRUE
      
      if (input$col_group == "MANUAL_ASSIGN") {
        grp_assign <- group_assignment()
        if (is.null(grp_assign) || "Unassigned" %in% grp_assign$Group) {
          is_complete <- FALSE
        }
      }
    }
    
    if (is_complete) {
      div(style = "margin-top: 20px; padding: 15px; background-color: #d4edda; border-color: #c3e6cb; color: #155724; border-radius: 5px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
          h4(strong(icon("check-circle"), " Mapping Complete!")),
          p(style = "font-size: 16px; margin-bottom: 15px;", 
            "You are ready to go! Please proceed to the ", 
            strong("Outlier Removal & Mean Cq Calculation"), 
            " tab, or download the raw formatted data below."),
          downloadButton("download_raw_formatted_csv", "Download Formatted CSV (All Reps)", class = "btn-success")
      )
    } else {
      div(style = "margin-top: 20px; padding: 15px; background-color: #fff3cd; border-color: #ffeeba; color: #856404; border-radius: 5px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
          h4(strong(icon("exclamation-circle"), " Action Required")),
          p(style = "font-size: 16px; margin-bottom: 0;", 
            "Please complete all column mappings (and assign groups if manual) to proceed.")
      )
    }
  })
  
  output$download_raw_formatted_csv <- downloadHandler(
    filename = function() {
      paste0("formatted_all_reps_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(formatted_data())
      write.csv(formatted_data(), file, row.names = FALSE, na = "")
    }
  )
  
  # --- Variables and processing for Tab 3: Outlier Removal & Mean Cq Calculation ---
  qc_data <- reactiveVal(NULL)      
  mean_calculated <- reactiveVal(FALSE) 
  
  observeEvent(formatted_data(), {
    qc_data(formatted_data())
    mean_calculated(FALSE)
  })
  
  output$qc_preview <- DT::renderDataTable({
    df <- qc_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please complete column mapping in the 'File Trimming' tab first."), rownames = FALSE, options=list(dom='t')))
    }
    
    DT::datatable(
      df, 
      selection = 'multiple', 
      options = list(
        scrollX = TRUE, 
        scrollY = "300px", 
        paging = FALSE, 
        dom = 'ft', 
        order = list(list(0, 'asc'), list(2, 'asc')), 
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$qc_download_ui <- renderUI({
    req(qc_data())
    downloadButton("download_qc_csv", "Download This CSV", class = "btn-default")
  })
  
  output$download_qc_csv <- downloadHandler(
    filename = function() {
      paste0("cleaned_all_reps_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(qc_data())
      write.csv(qc_data(), file, row.names = FALSE, na = "")
    }
  )
  
  observeEvent(input$delete_outlier_btn, {
    sel <- input$qc_preview_rows_selected
    if (length(sel) > 0) {
      df <- qc_data()
      df <- df[-sel, ]
      qc_data(df)
      mean_calculated(FALSE) 
      
      proxy <- dataTableProxy("qc_preview")
      selectRows(proxy, NULL) 
    } else {
      showNotification("Please select the rows you want to delete from the table first.", type = "warning")
    }
  })
  
  observeEvent(input$calc_mean_btn, {
    req(qc_data())
    mean_calculated(TRUE)
  })
  
  mean_data <- reactive({
    req(mean_calculated(), qc_data())
    df <- qc_data()
    
    df %>%
      group_by(sample, gene) %>%
      summarise(
        group = first(group),
        Cq = mean(Cq, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      select(sample, group, gene, Cq)
  })
  
  output$mean_preview <- DT::renderDataTable({
    if (!mean_calculated()) {
      return(datatable(data.frame(Message = "Please click the 'Calculate Mean Cq' button above."), rownames = FALSE, options=list(dom='t')))
    }
    
    DT::datatable(
      mean_data(), 
      options = list(
        scrollX = TRUE, 
        scrollY = "300px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$mean_download_ui <- renderUI({
    if (!mean_calculated() || is.null(mean_data())) return(NULL)
    
    div(style = "margin-top: 15px;",
        downloadButton("download_mean_csv", "Download Mean Cq CSV (Ready for Click-qPCR)", class = "btn-success btn-lg")
    )
  })
  
  output$download_mean_csv <- downloadHandler(
    filename = function() {
      paste0("mean_Cq_for_Click-qPCR_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(mean_data())
      write.csv(mean_data(), file, row.names = FALSE, na = "")
    }
  )
  
  # --- Tab 4: Input CSV Integration ---
  accumulated_files <- reactiveVal(character(0))
  accumulated_names <- reactiveVal(character(0))
  
  observeEvent(input$merge_files, {
    req(input$merge_files)
    new_files <- input$merge_files
    
    curr_paths <- accumulated_files()
    curr_names <- accumulated_names()
    
    for (i in 1:nrow(new_files)) {
      # Ignore files with duplicate names in the current list
      if (!(new_files$name[i] %in% curr_names)) {
        dest <- file.path(merge_temp_dir, new_files$name[i])
        file.copy(new_files$datapath[i], dest, overwrite = TRUE)
        curr_paths <- c(curr_paths, dest)
        curr_names <- c(curr_names, new_files$name[i])
      }
    }
    accumulated_files(curr_paths)
    accumulated_names(curr_names)
  })
  
  output$accumulated_files_ui <- renderUI({
    names <- accumulated_names()
    if (length(names) == 0) return(NULL)
    div(style = "margin-bottom: 15px; background-color: #f8f9fa; padding: 10px; border-radius: 5px; border: 1px solid #dee2e6;",
        strong(icon("file-csv"), " Currently loaded files:"),
        tags$ul(style = "padding-left: 20px; font-size: 13px; color: #555; margin-bottom: 0;",
                lapply(names, function(n) tags$li(n)))
    )
  })
  
  observeEvent(input$reset_merge_btn, {
    accumulated_files(character(0))
    accumulated_names(character(0))
    shinyjs::reset("merge_files")
    unlink(list.files(merge_temp_dir, full.names = TRUE))
  })
  
  merged_data <- reactive({
    req(length(accumulated_files()) > 0)
    
    tryCatch({
      files <- accumulated_files()
      df_list <- lapply(files, function(f) {
        read_csv(f, show_col_types = FALSE)
      })
      
      merged_df <- bind_rows(df_list)
      return(merged_df)
    }, error = function(e) {
      showNotification(paste("Error merging files:", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$merged_preview <- DT::renderDataTable({
    df <- merged_data()
    if (is.null(df)) {
      return(datatable(data.frame(Message = "Please upload multiple CSV files to merge."), rownames = FALSE, options=list(dom='t')))
    }
    DT::datatable(
      df, 
      options = list(
        scrollX = TRUE, 
        scrollY = "400px", 
        paging = FALSE, 
        dom = 't', 
        ordering = FALSE,
        columnDefs = list(list(className = 'dt-left', targets = "_all"))
      ), 
      rownames = FALSE
    )
  })
  
  output$merge_download_ui <- renderUI({
    if (!is.null(merged_data()) && length(accumulated_files()) > 0) {
      div(style = "display: flex; gap: 10px; align-items: center;",
          downloadButton("download_merged_csv", "Download Merged CSV", class = "btn-primary btn-lg"),
          actionButton("reset_merge_btn", "Reset Files", icon = icon("trash"), class = "btn-danger")
      )
    } else {
      p(style = "color: #777;", "Download and Reset buttons will appear once files are loaded.")
    }
  })
  
  output$download_merged_csv <- downloadHandler(
    filename = function() {
      paste0("merged_Click-qPCR_input_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv")
    },
    content = function(file) {
      req(merged_data())
      write.csv(merged_data(), file, row.names = FALSE, na = "")
    }
  )
}

# 4. Run the Application
shinyApp(ui, server)
