# Dynamic UI add/ remove Bigwig upload
# elements

# bw1 file handling
bw1v <- reactiveValues()
minmaxargs <- reactiveValues()

observeEvent(input$addBtn, {
    nr <- input$addBtn
    id <- paste0("input",input$addBtn)
insertUI(
    selector = '#inputList',
    ui = div(
      style = "border:1px solid black; margin:10px; padding:10px; border-radius: 5px;",
      id = paste0("newInput", nr),
      
      # Title with a toggle button to collapse/expand the section
      fluidRow(
        column(10,
               h4("Feature 1", style = "margin-bottom: 15px;")
        ),
        column(2,
               actionButton(paste0('collapseBtn', nr), label = "", icon = icon("angle-double-down"), style = "width: 100%;")
        )
      ),
      
      # File selection button and toggle button
      fluidRow(
        column(9,
               # Wrapper div that will hold the "Select Bigwig" button
               tags$div(
                 shinyFilesButton(
                   paste0('bw', nr),
                   label = 'Select bigwig',
                   title = 'Please select a .bigwig/.bw file',
                   multiple = FALSE,
                   style = "width: 100%;"
                 ),
                 id = paste0('fileSelectDiv', nr)
               ),
               
               # Wrapper div that will hold the URL input and Add URL button (initially hidden)
               tags$div(
                 fluidRow(
                   column(9,
                          tags$div(
                            textInput(
                              paste0('urlchip', nr),
                              label = NULL,
                              placeholder = "https://<file.bigwig>"
                            ),
                            style = "width: 100%; display:none;",
                            id = paste0('textInputDiv', nr)
                          )
                   ),
                   column(3,
                          actionButton(paste0('loadurlchip', nr), label = "", icon = icon("check"), style = "width: 100%;"),
                          id = paste0('urlInputDiv', nr),
                          style = "display:none;"  # Initially hidden
                   )
                 )
               ),
               # Checkbox for co-signaling with a different feature
               checkboxInput(paste0('cosignal', nr), "Co-signal with a different feature?", value = FALSE),
        ),
        column(3,
               # The toggle button always stays visible, so it's outside the toggleable divs
               actionButton(paste0('toggleBtn', nr), label = "", style = "width:100%;", icon = icon("exchange-alt"))
        )
      ),
      
      # Collapsible Section
      tags$div(
        id = paste0("collapseSection", nr),
        style = "display: none;",  # Initially hidden
        
        # Label, Colour, and Checkbox Inputs
        fluidRow(
          column(4,
                 textInput(paste0("n", nr), 
                           label = "Label", 
                           value = "bigwig")
          ),
          column(4,
                 colourInput(paste0("col", nr), 
                             "Select colour", 
                             "blue")
          ),
          column(4,
                 checkboxInput(paste0("comb", nr),
                               "Combination")
          )
        ),
        
        # Numeric inputs for Min and Max
        fluidRow(
          column(6,
                 numericInput(paste0("minargs", nr), "Min", value = NULL)
          ),
          column(6,
                 numericInput(paste0("maxargs", nr), "Max", value = NULL)
          )
        )
      ),
      
      # Remove Button (remains visible outside the collapsible section)
      fluidRow(
        column(12,
               actionButton(paste0('removeBtn', nr), 'Remove', style = "width:100%;")
        )
      )
    )
  )


########################
# CO-SIGNAL



##################


# Toggle the collapsible section when collapse button is clicked
  observeEvent(input[[paste0('collapseBtn', nr)]], {
    shinyjs::toggle(paste0("collapseSection", nr))  # Toggle the collapsible section
  })

    
  ### Toggle url and local bigwig upload
    # Toggle between "Select Bigwig" and URL input + Add URL button
  observeEvent(input[[paste0('toggleBtn', nr)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr))    # Toggle the URL input 
  })

    observeEvent(input[[paste0('removeBtn',nr)]],{
        # Remove div
        # TODO: remove bigwig from system too
      shiny::removeUI(
        selector = paste0("#newInput",nr)
      )
      # NULL the filepath
      bw1v[[paste0("bw",nr)]] <- NULL
      #print(str(reactiveValuesToList(bw1v)))
    })

    # Set up file handling for local files
    shinyFileChoose(input, paste0("bw",nr), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
    # Add file path to reactive variable
    observeEvent(input[[paste0("bw",nr)]], {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr)]])
        bw1v[[paste0("bw",nr)]] <- inFile$datapath
        # Update text with file name
         updateTextInput(
            session,
            inputId = paste0("n", nr),
            value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw",nr)]]))
            )
    }) 

    observe({
      isvalid = checkURL(input[[paste0('urlchip',nr)]], list('bigWig', 'bigwig', 'bw'))

      if(isvalid=="Valid"){
          bw1v[[paste0("bw",nr)]] <- input[[paste0('urlchip',nr)]]

          updateTextInput(
            session,
            inputId = paste0("n", nr),
            value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw",nr)]]))
            )
      }else{
          #make this an actual error message
          print("URL not valid: ERROR MESSAGE")
      }
    }) %>% bindEvent(input[[paste0('loadurlchip',nr)]])

    observe({
      minmaxlist <- list(
        as.double(input[[paste0("minargs",nr)]]),
        as.double(input[[paste0("maxargs",nr)]])
        )
      minmaxargs[[paste0("mm",nr)]] <- minmaxlist
    })

    # # Update chip-seq min values if nan
    #   observe({
    #     print(chipalpha()$minmax[[nr]])
    #     if(!is.null(chipalpha()$minmax[[nr]])){

    #         minvalue = chipalpha()$minmax[[nr]][[1]]

    #         updateNumericInput(
    #           session = session,
    #           inputId = paste0("minargs",nr),
    #           value = minvalue)
    #     }
    #   }) %>% bindEvent(input$generate_hic)

    #   # Update chip-seq max values if nan
    #   observe({
    #     if(!is.null(chipalpha()$minmax[[nr]])){
    #       maxvalue = chipalpha()$minmax[[nr]][[2]]
          
    #       updateNumericInput(
    #           session = session,
    #           inputId = paste0("maxargs",nr),
    #           value = maxvalue)
    #     }
    #   }) %>% bindEvent(input$generate_hic)
  })