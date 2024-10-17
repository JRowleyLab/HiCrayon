# Dynamic UI add/ remove Bigwig upload
# elements

# bw1 file handling
bw1v <- reactiveValues(features=list(list(NULL, NULL)))

# Include feature 2 list
f2v <- reactiveValues()

# Log reactive values
logv <- reactiveValues()

# Initialize list of lists
minmaxargs <- reactiveValues(nums=list(list(list())))


observeEvent(input$addBtn, {
    nr <- input$addBtn
    # Initialize bigwig path list for features 1,2
    bw1v$features[[nr]] <- list(NULL, NULL)
    id <- paste0("input",input$addBtn)
    ####### Dynamic UI update START #####################
insertUI(
    selector = '#inputList',
    ui = div(
      #style = "border:1px solid black; margin:10px; padding:10px; border-radius: 5px;",
      class = "new-div",
      id = paste0("newInput", nr),
      fluidRow(
        column(12,
                 textInput(paste0("n", nr), 
                           label = "Label", 
                           value = paste0("Panel ", nr))
          )
      ),
      # Title with a toggle button to collapse/expand the section
      fluidRow(
        column(8,
               h4("Feature 1", style = "margin-bottom: 15px;")
        ),
        column(2,
          materialSwitch(inputId = paste0('bedswitch', nr), label = "Bedgraph", value = FALSE)
        ),
      ),
      
      # File selection button and toggle button
      fluidRow(
        div(id = paste0("bigwigdiv", nr, 1),
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
                tippy_this(
                        elementId = paste0('fileSelectDiv', nr), 
                        tooltip = "<span style='font-size:15px;'>Select local .bigwig/ .bw file<span>", 
                        allowHTML = TRUE,
                        placement = 'right'
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
                    ),                   
                tippy_this(
                        elementId = paste0('loadurlchip', nr, 1), 
                        tooltip = "<span style='font-size:15px;'>Upload URL for .bigwig/ .bw file<span>", 
                        allowHTML = TRUE,
                        placement = 'right'
                    ),
                  )
                ),
                fluidRow(
                  column(6,
                    # Checkbox for co-signaling with a different feature
                    checkboxInput(paste0('cosignal', nr), "Separate signals?", value = FALSE),
                    #shinyBS::bsTooltip(id = paste0('cosignal', nr), title ="Visualize interactions between two different chromatin signals (feature 1 vs feature 2). Default behavour is feature 1 vs feature 1."),
                  
                    tippy_this(
                            elementId = paste0('cosignal', nr), 
                            tooltip = "<span style='font-size:15px;'>Visualize interactions between two different chromatin signals (feature 1 vs feature 2). Default behavour is feature 1 vs feature 1.<span>", 
                            allowHTML = TRUE,
                            placement = 'right'
                        ),
                  ),
                  column(3,
                    actionButton(paste0('collapseBtn', nr), label = "", icon = icon("angle-double-down"), style = "width: 100%;"),
                    #shinyBS::bsTooltip(id = paste0('collapseBtn', nr), title ="Open options for color, label and data range"),
                    tippy_this(
                        elementId = paste0('collapseBtn', nr),
                        tooltip = "<span style='font-size:15px;'>Open options for color, label and data range<span>", 
                        allowHTML = TRUE,
                        placement = 'right'
                    )
                  ),
                  column(2,
                    #actionButton(paste0("comb", nr), label = HTML('<span class="icon">+</span>'), class = "toggle-btn")
                    checkboxInput(paste0("comb", nr),
                                  "Combination", value = FALSE)
                              )
              ),
          )
        ),
        div(id = paste0("bedgraphdiv", nr, 1),
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(
                  shinyFilesButton(
                    paste0('bed', nr, 1),
                    label = 'Select bedgraph',
                    title = 'Please select a .bedgraph/.bed file',
                    multiple = FALSE,
                    style = "width: 100%;"
                  ),
                  id = paste0('bedSelectDiv', nr, 1)
                ),
                tippy_this(
                        elementId = paste0('bedSelectDiv', nr), 
                        tooltip = "<span style='font-size:15px;'>Select local .bedgraph/ .bed file <span>", 
                        allowHTML = TRUE,
                        placement = 'right'
                    )
          )
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

        # Track Background section
        h5("Track Background"),
        fluidRow(
          column(4,
                colourInput(paste0("trackcol", nr), 
                            "", 
                            "white")
          )
        ),

        # Track Line section
        h5("Track Line"),
        fluidRow(
          column(6,
                colourInput(paste0("col", nr), 
                            "", 
                            "blue")
          ),
          column(6,
                sliderInput(paste0("linewidth", nr),
                            label = "Width",
                            min = 0,
                            max = 7,
                            value = 1.5,
                            step = 0.5
                )
          )
        ),

        # Data Range section
        h5("Data range"),
        fluidRow(
          column(4,
                numericInput(paste0("minargs", nr, 1), "Min", step = .2, value = NULL)
          ),
          column(4,
                numericInput(paste0("maxargs", nr, 1), "Max", step = .2, value = NULL)
          ),
          column(4,
                checkboxInput(paste0("log", nr, 1),
                              "Log", value = FALSE)
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

      
      #
      fluidRow(
        column(3,
        offset = 6,
            actionButton(paste0('collapseBtn2', nr), label = "", icon = icon("angle-double-down"), style = "width: 100%;"),
            #shinyBS::bsTooltip(id = paste0('collapseBtn', nr), title ="Open options for color, label and data range"),
            tippy_this(
                elementId = paste0('collapseBtn2', nr),
                tooltip = "<span style='font-size:15px;'>Open options for color, label and data range<span>", 
                allowHTML = TRUE,
                placement = 'right'
            )
          )
        )
      ),
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
        ),
        fluidRow(
          column(4,
                 checkboxInput(paste0("log", nr, 2),
                               "Log", value = FALSE)
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
      # bw1v[[paste0("bw",nr, 1)]] <- NULL
      # bw1v[[paste0("bw",nr, 2)]] <- NULL
      bw1v$features[[nr]][[1]] <- NULL
      bw1v$features[[nr]][[2]] <- NULL
    })

  # observe({
  #   key <- as.character(nr)
  #   f2v[[key]] <- FALSE
  #   updateCheckboxInput(session, input[[paste0('cosignal', nr)]], value = FALSE)
  # }) %>% bindEvent(bwlist_ChIP1()$iseigen[nr]=="TRUE")


  observeEvent(input[[paste0('cosignal', nr)]], {
    key <- as.character(nr)
    f2v[[key]] <- input[[paste0('cosignal', nr)]]
  })

  # Toggle the collapsible section when collapse button is clicked
  observeEvent(input[[paste0('collapseBtn', nr)]], {
    shinyjs::toggle(paste0("collapseSection", nr))  # Toggle the collapsible section
  })

  # Toggle the collapsible section with animation
  observeEvent(input[[paste0('collapseBtn', nr)]], {
    shinyjs::toggleClass(id = paste0("collapseSection", nr), class = "expanded")
  })

  # When bedgraph is toggled, hide bigwig local and url buttons and
  # show the bedgraph buttons
  observeEvent(input[[paste0("bedswitch", nr)]], {
    if (input[[paste0("bedswitch", nr)]] == FALSE) {
      shinyjs::show(paste0("bigwigdiv", nr, 1))    # Toggle the Add URL button
      shinyjs::hide(paste0("bedgraphdiv", nr, 1))
      shinyjs::show(paste0("toggleBtn", nr, 1))
    } else {
      shinyjs::hide(paste0("bigwigdiv", nr, 1))  # Toggle the Select Bigwig button
      shinyjs::show(paste0("bedgraphdiv", nr, 1))
      shinyjs::hide(paste0("toggleBtn", nr, 1))
    }
})

  # Toggle the collapsible section 2 (for feature 2)
  observeEvent(input[[paste0('collapseBtn2', nr)]], {
    shinyjs::toggle(paste0("collapseSection2", nr))  # Toggle the collapsible section
  })


# Toggle the collapsible feature 2 section if Co-signal is unchecked
  observeEvent(input[[paste0('cosignal', nr)]], {
    shinyjs::toggle(paste0("toggleFeature2", nr))  # Toggle the collapsible section
  })

    
  ### Toggle url and local BIGWIG upload
  # Toggle between "Select Bigwig" and URL input + Add URL button
  observeEvent(input[[paste0('toggleBtn', nr, 1)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 1))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 1))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 1))    # Toggle the URL input 
  })


  # ### Toggle url and local BEDGRAPH upload
  # # Toggle between "Select Bedgraph" and URL input + Add URL button
  # observeEvent(input[[paste0('toggleBtn', nr, 1)]], {
  #   shinyjs::toggle(paste0('bedSelectDiv', nr, 1))  # Toggle the Select Bigwig button
  #   shinyjs::toggle(paste0('urlInputDivbed', nr, 1))    # Toggle the Add URL button
  #   shinyjs::toggle(paste0('bedtextInputDiv', nr, 1))    # Toggle the URL input 
  # })



#-------------Feature 2-----------------
### Toggle url and local bigwig upload for FEATURE 2
  # Toggle between "Select Bigwig" and URL input + Add URL button for FEATURE 2
  observeEvent(input[[paste0('toggleBtn', nr, 2)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 2))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 2))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 2))    # Toggle the URL input 
  })


#---File handling---

# BIGWIG FILE HANDLING
  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bw",nr, 1), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
  # Add file path to reactive variable
  observeEvent(input[[paste0("bw",nr, 1)]], {
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 1)]])
      #bw1v[[paste0("bw", nr, 1)]] <- inFile$datapath

      # GOAL: bw1v -> [1,2,3,4,5] -> [1,2], [1,2], [1,2]...
      # where each is the bigwig path or NULL
      if(!rlang::is_empty(inFile$datapath)){
        bw1v$features[[nr]][[1]] <- inFile$datapath
        # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]]))
          )
      }
  })

  #BEGRAPH file hanlding
  #assign to same list as the bigwigs. Handle the difference in python function.
  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bed",nr, 1), root = c(wd = workingdir), filetypes=c('bed', 'bedgraph'))
  # Add file path to reactive variable
  observeEvent(input[[paste0("bed",nr, 1)]], {
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bed",nr, 1)]])
      bw1v[[paste0("bw", nr, 1)]] <- inFile$datapath

      # GOAL: bw1v -> [1,2,3,4,5] -> [1,2], [1,2], [1,2]...
      # where each is the bigwig path or NULL
      if(!rlang::is_empty(inFile$datapath)){
        #UNCOMMENT
        bw1v$features[[nr]][[1]] <- inFile$datapath
        # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]]))
          )
      }
  })


  # Set up file handling for local files for FEATURE 2
    shinyFileChoose(input, paste0("bw",nr, 2), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
    # Add file path to reactive variable
    observeEvent(input[[paste0("bw",nr, 2)]], {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 2)]])
        #bw1v[[paste0("bw",nr, 2)]] <- inFile$datapath
        # Update list by index for feature 2
        if(!rlang::is_empty(inFile$datapath)){
          bw1v$features[[nr]][[2]] <- inFile$datapath
          # Update text with file name
          updateTextInput(
            session,
            inputId = paste0("n", nr),
            value = paste0(
              tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]])),
              " x ",
              tools::file_path_sans_ext(basename(bw1v$features[[nr]][[2]])) 
                  )
            )
      }
    })

  observeEvent(input[[paste0("log", nr, 1)]], {
    key <- paste0(nr, 1)
    logv[[key]] <- input[[paste0("log", nr, 1)]]
  })

  observeEvent(input[[paste0("log", nr, 2)]], {
    key <- paste0(nr, 2)
    logv[[key]] <- input[[paste0("log", nr, 2)]]
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
    }
  }) %>% bindEvent(input[[paste0('loadurlchip', nr, 2)]])



  # Ensure minmaxargs$nums is initialized for the current index
    if (length(minmaxargs$nums) < nr) {
        minmaxargs$nums[[nr]] <- list(list(NULL, NULL))
    }


  # Update minmax arguments and store as variable list for FEATURE 1
  observe({
         minmaxlist <- list(
            as.double(input[[paste0("minargs",nr, 1)]]),
            as.double(input[[paste0("maxargs",nr, 1)]])
            )

          minmaxargs$nums[[nr]][[1]] <- minmaxlist
  })

  # Update minmax arguments and store as variable list for FEATURE 2
  observe({
         minmaxlist <- list(
            as.double(input[[paste0("minargs",nr, 2)]]),
            as.double(input[[paste0("maxargs",nr, 2)]])
            )
          minmaxargs$nums[[nr]][[2]] <- minmaxlist
  })

  # Reset minmax arguments if any locus values change
  # chr, res, start, stop, or any input files
  observe({
    print("check")
    updateNumericInput(session, paste0("minargs", nr, 1), "Min", value = NA)
    updateNumericInput(session, paste0("maxargs", nr, 1), "Max", value = NA)
  }) %>% bindEvent(
    input$chr,
    input$start, input$stop, input$bin,
    bw1v[[paste0("bw", nr, 1)]],
    hicv$y, input[[paste0("log", nr, 1)]]
  )


  observe({
    updateNumericInput(session, paste0("minargs", nr, 2), "Min", value = NA)
    updateNumericInput(session, paste0("maxargs", nr, 2), "Max", value = NA)
  }) %>% bindEvent(
    input$chr,
    input$start, input$stop, input$bin,
    bw1v[[paste0("bw", nr, 2)]],
    hicv$y, input[[paste0("log", nr, 2)]]
  )

})