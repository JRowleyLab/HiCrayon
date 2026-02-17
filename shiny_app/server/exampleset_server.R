# URLs to showcase HCT116 three compartments
hic = "https://www.encodeproject.org/files/ENCFF573OPJ/@@download/ENCFF573OPJ.hic"
h3k27ac = "https://www.encodeproject.org/files/ENCFF277XII/@@download/ENCFF277XII.bigWig"
h3k27me3 = "https://www.encodeproject.org/files/ENCFF232QSG/@@download/ENCFF232QSG.bigWig"
h3k9me3 = "https://www.encodeproject.org/files/ENCFF572IBD/@@download/ENCFF572IBD.bigWig"
eigen = "Eigen_chrom_250000.bedgraph"

# Assign examplemode
examBtn <- reactiveVal(FALSE)

# Update reactive value when button is clicked
observeEvent(input$exampleset, {
    examBtn(TRUE)
})


observeEvent(input$encodehictable, {
    examBtn(FALSE)
})

# Update Hi-C variable with URL
observe({ 
    if(examBtn()) {
         hicv$y <- hic
    }
   
})


# Update parameters for selection
observe({
    if(examBtn()) {
        # Update chromosome
        updateSelectizeInput(session, "chr",
        choices = HiCmetadata()$chrs,
        selected = "chr14")

        # Update resolution
        updateSelectizeInput(session, "bin",
            choices = HiCmetadata()$res,
            selected = 250000)

        # Update start coordinate
         updateAutonumericInput(
            session = session, 
            inputId = "start",
            value = 20000000
        )

        # Update stop coordinate
        updateAutonumericInput(
            session = session, 
            inputId = "stop",
            value = 106000000
        )

        # Update colors
        updateColourInput(
          session = session,
          inputId = "colhic1",
          value = "black"
        )

        # Update colors
        updateColourInput(
          session = session,
          inputId = "colhic2",
          value = "white"
        )

        shinyCatch({message("Loading example set")}, prefix = '')
    }
    
})


# Make dynamic ChIP a function to allow
addInputSection <- function(nr, preselectedParams = list()) {
    bw1v$features[[nr]] <- list(NULL, NULL)
    id <- paste0("input", nr)
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
                           value = preselectedParams$label)
          )
      ),
      # Title with a toggle button to collapse/expand the section
      fluidRow(
        column(6,
               h4("Feature 1", style = "margin-bottom: 15px;")
        ),
        column(6,
          selectInput(paste0("filetype", nr), "", 
          choices = c("Bigwig", "Bedgraph", "Bed", "Eigen", "chromHMM"),
          selected = preselectedParams$filetype)
        )
      ),
      
      # File selection button and toggle button
      fluidRow(
        tags$div(id = paste0("bigwigdiv", nr, 1),
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(id = paste0('fileSelectDiv', nr, 1),
                  if (is_lite_mode) {
                    # Replace shinyFilesButton with fileInput
                    fileInput(paste0('bw', nr, 1), 
                      label = '',
                      multiple = FALSE,
                      accept = c('.bw', '.bigwig', '.bigWig'))
                  } else {
                    shinyFilesButton(
                      paste0('bw', nr, 1),
                      label = 'Select bigwig',
                      title = 'Please select a .bigwig/.bw file',
                      multiple = FALSE,
                      style = "width: 100%;"
                    )
                  }
                ),
                tippy_this(
                        elementId = paste0('fileSelectDiv', nr), 
                        tooltip = "<span style='font-size:15px;'>Select .bigwig/ .bw file<span>", 
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
                                value = preselectedParams$url
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
          )
        ),
        tags$div(id = paste0("bedgraphdiv", nr, 1),
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(id = paste0('bedSelectDiv', nr, 1),

                  if (is_lite_mode) {
                      # Replace shinyFilesButton with fileInput
                      fileInput(paste0('bed', nr, 1), 
                      label = '',
                      multiple = FALSE,
                      accept = c('bed', 'bedgraph'))
                  } else {
                      shinyFilesButton(
                        paste0('bed', nr, 1),
                        label = 'Select Bed/ Bedgraph',
                        title = 'Please select a .bedgraph/.bed file',
                        multiple = FALSE,
                        style = "width: 100%;",
                        value = preselectedParams$path
                      )
                  },
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

      fluidRow(
        column(6,
          # Checkbox for co-signaling with a different feature
          checkboxInput(paste0('cosignal', nr), "Separate signals?", value = FALSE),
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
          checkboxInput(paste0("comb", nr),
                        "Combination", value = preselectedParams$combination)
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
        tags$div(id=paste0("trackline", nr),
          # Track Line section
          h5("Track Line"),
          fluidRow(
            column(6,
                  colourInput(paste0("col", nr), 
                              "", 
                              preselectedParams$color)
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
          )
        ),
        tags$div(id=paste0("compcolors", nr),
          h5("Compartment Colors"),
          fluidRow(column(12, colourInput(paste0("compcolA", nr), "A-A interactions", "red"))),
          fluidRow(column(12, colourInput(paste0("compcolB", nr), "B-B interactions", "blue"))),
          fluidRow(column(12, colourInput(paste0("compcolAB", nr), "A-B interactions", "green"))),
        ),
        # Data Range section
        tags$div(id=paste0("datarange", nr),
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
          column(6,
                h4("Feature 2", style = "margin-bottom: 15px;")
          ),
          column(6,
            selectInput(paste0("filetype", nr, 2), "", choices = c("Bigwig", "Bedgraph", "Bed"))
          )
        ),
        # File selection button and toggle button
      fluidRow(
        tags$div(id = paste0("bigwigdiv", nr, 2),
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(id = paste0('fileSelectDiv', nr, 2),
                  if (is_lite_mode) {
                    # Replace shinyFilesButton with fileInput
                    fileInput(paste0('bw', nr, 2), 
                      label = '',
                      multiple = FALSE,
                      accept = c('.bw', '.bigwig', '.bigWig'))
                  } else {
                    shinyFilesButton(
                      paste0('bw', nr, 2),
                      label = 'Select bigwig',
                      title = 'Please select a .bigwig/.bw file',
                      multiple = FALSE,
                      style = "width: 100%;"
                    )
                  }
                ),
                tippy_this(
                        elementId = paste0('fileSelectDiv', nr, 2), 
                        tooltip = "<span style='font-size:15px;'>Select .bigwig/ .bw file<span>", 
                        allowHTML = TRUE,
                        placement = 'right'
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
                    ),                   
                tippy_this(
                        elementId = paste0('loadurlchip', nr, 2), 
                        tooltip = "<span style='font-size:15px;'>Upload URL for .bigwig/ .bw file<span>", 
                        allowHTML = TRUE,
                        placement = 'right'
                    ),
                  )
                ),
          )
        ),
        tags$div(id = paste0("bedgraphdiv", nr, 2),
          column(9,
                # Wrapper div that will hold the "Select Bigwig" button
                tags$div(id = paste0('bedSelectDiv', nr, 2),

                  if (is_lite_mode) {
                      # Replace shinyFilesButton with fileInput
                      fileInput(paste0('bed', nr, 2),
                      label = '',
                      multiple = FALSE,
                      accept = c('bed', 'bedgraph'))
                  } else {
                      shinyFilesButton(
                        paste0('bed', nr, 2),
                        label = 'Select Bed/ Bedgraph',
                        title = 'Please select a .bedgraph/.bed file',
                        multiple = FALSE,
                        style = "width: 100%;"
                      )
                  },
                ),
                tippy_this(
                        elementId = paste0('bedSelectDiv', nr, 2), 
                        tooltip = "<span style='font-size:15px;'>Select local .bedgraph/ .bed file <span>", 
                        allowHTML = TRUE,
                        placement = 'right'
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
observeEvent(input[[paste0('removeBtn',nr)]], {
  isolate({
    bw1v$features[[nr]] <- list(NULL, NULL)
  })
  shiny::removeUI(selector = paste0("#newInput",nr))
  updateCheckboxInput(session, paste0('comb', nr), value = FALSE)
  print(paste0("NULLING: ", nr))
})

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
  observeEvent(input[[paste0("filetype", nr)]], {
    if (input[[paste0("filetype", nr)]] %in% c("Bigwig")) {
      shinyjs::show(paste0("bigwigdiv", nr, 1))    # Toggle the Add URL button
      shinyjs::hide(paste0("bedgraphdiv", nr, 1))
      shinyjs::show(paste0("toggleBtn", nr, 1))

      # update feature2 selectInput to match
      updateSelectInput(session, paste0('filetype', nr, 2), choices = c("Bigwig"))
    } else {
      shinyjs::hide(paste0("bigwigdiv", nr, 1))  # Toggle the Select Bigwig button
      shinyjs::show(paste0("bedgraphdiv", nr, 1))
      shinyjs::hide(paste0("toggleBtn", nr, 1))

      # update feature2 selectInput to match
      updateSelectInput(session, paste0('filetype', nr, 2), choices = c("Bed", "Bedgraph"))      
    }
})


  # Toggle the collapsible section 2 (for feature 2)
  observeEvent(input[[paste0('collapseBtn2', nr)]], {
    shinyjs::toggle(paste0("collapseSection2", nr))  # Toggle the collapsible section
  })


# When chromHMM or Eigen are selected
# Remove option to do separate signal AND combination.
observeEvent({
  input[[paste0('filetype', nr)]]
}, {
  if (input[[paste0('filetype', nr)]] %in% c("Eigen", "chromHMM")) {

      # Hide feature 2 and combination, unchecking both when Eigen/ chromHMM
      shinyjs::hide(paste0("cosignal", nr))  
      shinyjs::hide(paste0("toggleFeature2", nr))  
      updateCheckboxInput(session, paste0('cosignal', nr), value = FALSE)

      shinyjs::hide(paste0("comb", nr))  
      updateCheckboxInput(session, paste0('comb', nr), value = FALSE)
    } else {
      shinyjs::show(paste0("cosignal", nr))  
      shinyjs::show(paste0("comb", nr)) 
    }
})

# Show feature 2 when cosignal button is TRUE
observeEvent({
    input[[paste0('cosignal', nr)]]
  }, {
    cosignal_value <- input[[paste0("cosignal", nr)]]

    if (is.null(cosignal_value)) {
      return()  # Do nothing if any input is NULL
    }

    if (cosignal_value == FALSE) {
      shinyjs::hide(paste0("toggleFeature2", nr))  # Hide the collapsible section
    } else {
      shinyjs::show(paste0("toggleFeature2", nr))  # Show otherwise
    }
  })

observeEvent({
  input[[paste0('filetype', nr)]]
}, {
  if(input[[paste0('filetype', nr)]] == "Eigen"){
    # Hide color selection for A, B, AB
    shinyjs::show(paste0("compcolors", nr))
    shinyjs::hide(paste0("trackline", nr))
    shinyjs::hide(paste0("datarange", nr))
  } else if(input[[paste0('filetype', nr)]] == "chromHMM") {
    shinyjs::hide(paste0("trackline", nr))
    shinyjs::hide(paste0("datarange", nr))
    shinyjs::hide(paste0("compcolors", nr))
    } else {
    # Hide color selection for A, B, AB
    shinyjs::hide(paste0("compcolors", nr))
    shinyjs::show(paste0("trackline", nr))
    shinyjs::show(paste0("datarange", nr))
  }
})

    
  ### Toggle url and local BIGWIG upload
  # Toggle between "Select Bigwig" and URL input + Add URL button
  observeEvent(input[[paste0('toggleBtn', nr, 1)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 1))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 1))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 1))    # Toggle the URL input 
  })


#-------------Feature 2-----------------
### Toggle url and local bigwig upload for FEATURE 2
  # Toggle between "Select Bigwig" and URL input + Add URL button for FEATURE 2
  observeEvent(input[[paste0('toggleBtn', nr, 2)]], {
    shinyjs::toggle(paste0('fileSelectDiv', nr, 2))  # Toggle the Select Bigwig button
    shinyjs::toggle(paste0('urlInputDiv', nr, 2))    # Toggle the Add URL button
    shinyjs::toggle(paste0('textInputDiv', nr, 2))    # Toggle the URL input 
  })


  # When bedgraph is toggled, hide bigwig local and url buttons and
  # show the bedgraph buttons
  observeEvent(input[[paste0("filetype", nr, 2)]], {
    if (input[[paste0("filetype", nr, 2)]] %in% c("Bigwig")) {
      shinyjs::show(paste0("bigwigdiv", nr, 2))    # Toggle the Add URL button
      shinyjs::hide(paste0("bedgraphdiv", nr, 2))
      shinyjs::show(paste0("toggleBtn", nr, 2))
    } else {
      shinyjs::hide(paste0("bigwigdiv", nr, 2))  # Toggle the Select Bigwig button
      shinyjs::show(paste0("bedgraphdiv", nr, 2))
      shinyjs::hide(paste0("toggleBtn", nr, 2))
    }
})

#---File handling---

# BIGWIG FILE HANDLING
  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bw",nr, 1), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))

  # Add file path to reactive variable
  observeEvent(input[[paste0("bw",nr, 1)]], { #
    if (is_lite_mode) {
      # In 'lite_mode', retrieve filepath from client side
      inFile <- input[[paste0("bw",nr, 1)]]
    } else {
      # Retrieve filepath from server side
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 1)]])
    }
    
    if(!rlang::is_empty(inFile$datapath)){
      if(is_lite_mode){
        fname <- inFile$name
      } else {
        fname <- tools::file_path_sans_ext(basename(inFile$datapath))
      }
      bw1v$features[[nr]][[1]] <- inFile$datapath
      # Update text with file name
      updateTextInput(
        session,
        inputId = paste0("n", nr),
        value = fname
        )
    }
  })

  #BEGRAPH file hanlding
  #assign to same list as the bigwigs. Handle the difference in python function.
  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bed",nr, 1), root = c(wd = workingdir), filetypes=c('bed', 'bedgraph'))

  # Add file path to reactive variable
  observeEvent(input[[paste0("bed",nr, 1)]], {
    if (is_lite_mode) {
      # In 'lite_mode', retrieve filepath from client side
      inFile <- input[[paste0("bed",nr, 1)]]
    } else {
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bed",nr, 1)]])
    }

      # GOAL: bw1v -> [1,2,3,4,5] -> [1,2], [1,2], [1,2]...
      # where each is the bigwig path or NULL
      if(!rlang::is_empty(inFile$datapath)){
        if(is_lite_mode){
          fname <- inFile$name
        } else {
          fname <- tools::file_path_sans_ext(basename(inFile$datapath))
        }

        bw1v$features[[nr]][[1]] <- inFile$datapath
        # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = fname
          )
      }

  })


  # Set up file handling for local files for FEATURE 2
    shinyFileChoose(input, paste0("bw",nr, 2), root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))
    # Add file path to reactive variable
    observeEvent(input[[paste0("bw",nr, 2)]], {
      if (is_lite_mode) {
        inFile <- input[[paste0("bw",nr, 2)]]
      } else {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bw",nr, 2)]])
      }

      # Update list by index for feature 2
      if(!rlang::is_empty(inFile$datapath)){
        if(is_lite_mode){
          fname <- inFile$name
        } else {
          fname <- tools::file_path_sans_ext(basename(inFile$datapath))
        }
        bw1v$features[[nr]][[2]] <- inFile$datapath
        # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = paste0("X-axis: ",
            tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]])),
            " x ",
            " Y-axis: ",
            tools::file_path_sans_ext(basename(fname)) 
                )
          )
    }
        
    })


  # FEATURE 2 
  # BEGRAPH file hanlding
  #assign to same list as the bigwigs. Handle the difference in python function.
  # Set up file handling for local files for FEATURE 1
  shinyFileChoose(input, paste0("bed",nr, 2), root = c(wd = workingdir), filetypes=c('bed', 'bedgraph'))

  # Add file path to reactive variable
  observeEvent(input[[paste0("bed",nr, 2)]], {
    if (is_lite_mode) {
      # In 'lite_mode', retrieve filepath from client side
      inFile <- input[[paste0("bed",nr, 2)]]
    } else {
      inFile <- parseFilePaths(roots = c(wd = workingdir), input[[paste0("bed",nr, 2)]])
    }

      # GOAL: bw1v -> [1,2,3,4,5] -> [1,2], [1,2], [1,2]...
      # where each is the bigwig path or NULL
      if(!rlang::is_empty(inFile$datapath)){
        if(is_lite_mode){
          fname <- inFile$name
        } else {
          fname <- tools::file_path_sans_ext(basename(inFile$datapath))
        }

        bw1v$features[[nr]][[2]] <- inFile$datapath
        # Update text with file name
        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = paste0("X-axis: ",
            tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]])),
            " x ",
            " Y-axis: ",
            tools::file_path_sans_ext(basename(fname)) 
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
        #bw1v[[paste0("bw",nr, 1)]] <- input[[paste0('urlchip',nr, 1)]]
        bw1v$features[[nr]][[1]] <- input[[paste0('urlchip',nr, 1)]]

        updateTextInput(
          session,
          inputId = paste0("n", nr),
          value = tools::file_path_sans_ext(basename(bw1v$features[[nr]][[1]]))
          )
    }else{
        shinyCatch({stop(paste0("URL uploaded: ", 
        input[[paste0('urlchip', nr, 1)]],
        " is not valid."
        ))}, prefix = '')
    }
  }) %>% bindEvent(input[[paste0('loadurlchip',nr, 1)]])


  # Check URL when user tries to input bigwig URL for FEATURE 2
  observe({
    isvalid = checkURL(input[[paste0('urlchip', nr, 2)]], list('bigWig', 'bigwig', 'bw'))

    if(isvalid=="Valid"){
        bw1v$features[[nr]][[2]] <- input[[paste0('urlchip',nr, 2)]]

        updateTextInput(
          session,
          inputId = paste0("n", nr, 2),
          value = tools::file_path_sans_ext(basename(bw1v$features[[nr]][[2]]))
          )
    }else{
        shinyCatch({stop(paste0("URL uploaded: ", 
        input[[paste0('urlchip', nr, 2)]],
        " is not valid."
        ))}, prefix = '')
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

  observe({
    # Update all filepaths manually
    if(!is.null(preselectedParams$path)){
      #the eigen
      bw1v$features[[nr]][[1]] <- preselectedParams$path
    } else { #the bigwigs
       bw1v$features[[nr]][[1]] <- preselectedParams$url
    }
  })

}


observe({
    if(examBtn()) {
      updateCheckboxInput(session, "chip1", value = TRUE)

    # remove all input divs prior to exampleset
    for (i in 1:100){
        shiny::removeUI(
    selector = paste0("div#newInput", i)
    )
    }

    # Update the UI to reflect those paths
    addInputSection(1, list(path = NULL, url = h3k27ac, label = "H3K27ac", color = "green", filetype = "Bigwig", combination = TRUE))
    addInputSection(2, list(path = NULL, url = h3k9me3, label = "H3K9me3", color = "purple", filetype = "Bigwig", combination = TRUE))
    addInputSection(3, list(path = NULL, url = h3k27me3, label = "H3K27me3", color = "orange", filetype = "Bigwig", combination = TRUE))
    addInputSection(4, list(path = eigen, url = NULL, label = "Eigen Track", filetype = "Eigen", combination = FALSE))
    }
}) %>% bindEvent(input$exampleset)