# Dynamic UI add/ remove Bigwig upload
# elements

# bw1 file handling
bw1v <- reactiveValues()
minmaxargs <- reactiveValues()


observeEvent(input$addBtn, {
    nr <- input$addBtn
    id <- paste0("input",input$addBtn)
    ####### Dynamic UI update START #####################
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
                   paste0('bw', nr, 1),
                   label = 'Select bigwig',
                   title = 'Please select a .bigwig/.bw file',
                   multiple = FALSE,
                   style = "width: 100%;"
                 ),
                 id = paste0('fileSelectDiv', nr, 1)
               ),
               
               # Wrapper div that will hold the URL input and Add URL button (initially hidden)
               tags$div(
                 fluidRow(
                   column(9,
                          tags$div(
                            textInput(
                              paste0('urlchip', nr, 1),
                              label = NULL,
                              placeholder = "https://<file.bigwig>"
                            ),
                            style = "width: 100%; display:none;",
                            id = paste0('textInputDiv', nr, 1)
                          )
                   ),
                   column(3,
                          actionButton(paste0('loadurlchip', nr, 1), label = "", icon = icon("check"), style = "width: 100%;"),
                          id = paste0('urlInputDiv', nr, 1),
                          style = "display:none;"  # Initially hidden
                   )
                 )
               ),
               # Checkbox for co-signaling with a different feature
               checkboxInput(paste0('cosignal', nr), "Co-signal with a different feature?", value = FALSE),
        ),
        column(3,
               # The toggle button always stays visible, so it's outside the toggleable divs
               actionButton(paste0('toggleBtn', nr, 1), label = "", style = "width:100%;", icon = icon("exchange-alt"))
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
                 numericInput(paste0("minargs", nr, 1), "Min", value = NULL)
          ),
          column(6,
                 numericInput(paste0("maxargs", nr, 1), "Max", value = NULL)
          )
        )
      ),

      ########################
      # CO-SIGNAL
      # Need to do the nr with 1 and 2 for the features selected. If unchecked, both are feature 1
      # And toggle based on cosignal()
      # If checkbox unchecked, then use feature 1 vs feature 1
      # else feature 1 vs feature 2 (and expand window)
      tags$div(
        id = paste0("toggleFeature2", nr),
        
        #UI
        # Title with a toggle button to collapse/expand the section
        fluidRow(
          column(10,
                h4("Feature 2", style = "margin-bottom: 15px;")
          ),
          column(2,
               actionButton(paste0('collapseBtn2', nr), label = "", icon = icon("angle-double-down"), style = "width: 100%;")
        )
        ),
        
        # File selection button and toggle button
        fluidRow(
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(
                  shinyFilesButton(
                    paste0('bw', nr, 2),
                    label = 'Select bigwig',
                    title = 'Please select a .bigwig/.bw file',
                    multiple = FALSE,
                    style = "width: 100%;"
                  ),
                  id = paste0('fileSelectDiv', nr, 2)
                ),
                
                # Wrapper div that will hold the URL input and Add URL button (initially hidden)
                tags$div(
                  fluidRow(
                    column(9,
                            tags$div(
                              textInput(
                                paste0('urlchip', nr, 2),
                                label = NULL,
                                placeholder = "https://<file.bigwig>"
                              ),
                              style = "width: 100%; display:none;",
                              id = paste0('textInputDiv', nr, 2)
                            )
                    ),
                    column(3,
                            actionButton(paste0('loadurlchip', nr, 2), label = "", icon = icon("check"), style = "width: 100%;"),
                            id = paste0('urlInputDiv', nr, 2),
                            style = "display:none;"  # Initially hidden
                    )
                  )
                )
          ),
          column(3,
                # The toggle button always stays visible, so it's outside the toggleable divs
                actionButton(paste0('toggleBtn', nr, 2), label = "", style = "width:100%;", icon = icon("exchange-alt"))
          )
        ),

      ),


      #
      tags$div(
        id = paste0("collapseSection2", nr),
        style = "display: none;",  # Initially hidden
        # Numeric inputs for Min and Max
        fluidRow(
          column(6,
                 numericInput(paste0("minargs", nr, 2), "Min", value = NULL)
          ),
          column(6,
                 numericInput(paste0("maxargs", nr, 2), "Max", value = NULL)
          )
        )
      ),
      #

      # Break
      br(),

      ########################
      
      # Remove Button (remains visible outside the collapsible section)
      fluidRow(
        column(12,
               actionButton(paste0('removeBtn', nr), 'Remove', style = "width:100%;")
        )
      )
    )
  )
####### Dynamic UI update END #####################


# Remove deletes UI + resets bw paths
observeEvent(input[[paste0('removeBtn',nr)]],{
        # Remove div
        # TODO: remove bigwig from system too
      shiny::removeUI(
        selector = paste0("#newInput",nr)
      )
      # NULL the filepath
      bw1v[[paste0("bw",nr, 1)]] <- NULL
      bw1v[[paste0("bw",nr, 2)]] <- NULL
    })

# Toggle the collapsible section when collapse button is clicked
  observeEvent(input[[paste0('collapseBtn', nr)]], {
    shinyjs::toggle(paste0("collapseSection", nr))  # Toggle the collapsible section
  })

# Toggle the collapsible section 2 (for feature 2)
  observeEvent(input[[paste0('collapseBtn2', nr)]], {
    shinyjs::toggle(paste0("collapseSection2", nr))  # Toggle the collapsible section
  })


# Toggle the collapsible feature 2 section if Co-signal is unchecked
  observeEvent(input[[paste0('cosignal', nr)]], {
    shinyjs::toggle(paste0("toggleFeature2", nr))  # Toggle the collapsible section
  })


    
  ### Toggle url and local bigwig upload
  # Toggle between "Select Bigwig" and URL input + Add URL button
  observeEvent(input[[paste0('toggleBtn', nr, 1)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 1))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 1))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 1))    # Toggle the URL input 
  })

### Toggle url and local bigwig upload for FEATURE 2
  # Toggle between "Select Bigwig" and URL input + Add URL button for FEATURE 2
  observeEvent(input[[paste0('toggleBtn', nr, 2)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 2))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 2))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 2))    # Toggle the URL input 
  })


#############################
# Instead:
# check if 'feature 2' button is clicked
# # Update bigwig path and minmax values for FEATURE 2 based on co-signal check.
# observeEvent(input[[paste0('cosignal',nr)]],{
#   # Mirror Feature 2 to be Feature 1
#   bw1v[[paste0("bw",nr, 2)]] <- bw1v[[paste0("bw",nr, 1)]]
# })
# # If feature 2 is empty, copy bigwig and minmax values from feature 1
# observe({
#   if(rlang::is_empty(bw1v[[paste0('bw', nr, 2)]])){
#     bw1v[[paste0('bw', nr, 2)]] <- bw1v[[paste0('bw', nr, 1)]]
#     minmaxargs[[paste0("mm",nr, 2)]] <- minmaxargs[[paste0("mm",nr, 1)]]
#   }
# })
###############################


  # If co-signal is unchecked, copy following to nr, 2
  # bwpath, minmax
  observeEvent(input[[paste0('cosignal',nr)]],{
    if (!input[[paste0('cosignal',nr)]]) {
      # Mirror values to feature 2 from feature 1
      # bigwig paths
      bw1v[[paste0("bw",nr, 2)]] <- bw1v[[paste0("bw",nr, 1)]]
      # minmax values
      minmaxargs[[paste0("mm",nr, 2)]] <- minmaxargs[[paste0("mm",nr, 1)]]
    }
  })

  observe({
    print("BIGWIG PATHS:")
    print(bw1v)
    print(reactiveValuesToList(bw1v))
    print("MINMAXARGS:")
    print(minmaxargs)
    print(reactiveValuesToList(minmaxargs))
  })

  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bw",nr, 1), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
  # Add file path to reactive variable
  observeEvent(input[[paste0("bw",nr, 1)]], {
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 1)]])
      bw1v[[paste0("bw", nr, 1)]] <- inFile$datapath
      print(bw1v)
      # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr, 1),
          value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw",nr, 1)]]))
          )
  }) 


  # Set up file handling for local files for FEATURE 2
    shinyFileChoose(input, paste0("bw",nr, 2), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
    # Add file path to reactive variable
    observeEvent(input[[paste0("bw",nr, 2)]], {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 2)]])
        bw1v[[paste0("bw",nr, 2)]] <- inFile$datapath
        print(bw1v)
        # Update text with file name
          updateTextInput(
            session,
            inputId = paste0("n", nr, 2),
            value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw",nr, 2)]]))
            )
    })


  # Check URL when user tries to input bigwig URL for FEATURE 1
  observe({
    isvalid = checkURL(input[[paste0('urlchip',nr, 1)]], list('bigWig', 'bigwig', 'bw'))

    if(isvalid=="Valid"){
        bw1v[[paste0("bw",nr, 1)]] <- input[[paste0('urlchip',nr, 1)]]

        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw",nr, 1)]]))
          )
    }else{
        # TODO: make this an actual error message
        print("URL not valid: ERROR MESSAGE")
    }
  }) %>% bindEvent(input[[paste0('loadurlchip',nr, 1)]])


  # Check URL when user tries to input bigwig URL for FEATURE 2
  observe({
    isvalid = checkURL(input[[paste0('urlchip', nr, 2)]], list('bigWig', 'bigwig', 'bw'))

    if(isvalid=="Valid"){
        bw1v[[paste0("bw", nr, 2)]] <- input[[paste0('urlchip', nr, 2)]]

        updateTextInput(
          session,
          inputId = paste0("n", nr, 2),
          value = tools::file_path_sans_ext(basename(bw1v[[paste0("bw", nr, 2)]]))
          )
    }else{
        # TODO: make this an actual error message
        print("URL not valid: ERROR MESSAGE")
    }
  }) %>% bindEvent(input[[paste0('loadurlchip', nr, 2)]])


  # Update minmax arguments and store as variable list for FEATURE 1
  observe({
    minmaxlist <- list(
      as.double(input[[paste0("minargs",nr, 1)]]),
      as.double(input[[paste0("maxargs",nr, 1)]])
      )
    minmaxargs[[paste0("mm",nr, 1)]] <- minmaxlist
  })

  # Update minmax arguments and store as variable list for FEATURE 2
  observe({
    minmaxlist <- list(
      as.double(input[[paste0("minargs", nr, 2)]]),
      as.double(input[[paste0("maxargs", nr, 2)]])
      )
    minmaxargs[[paste0("mm", nr, 2)]] <- minmaxlist
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