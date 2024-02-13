# Dynamic UI add/ remove Bigwig upload
# elements

# bw1 file handling
bw1v <- reactiveValues()
minmaxargs <- reactiveValues()
#TODO: if examBtn increment it by 3
observeEvent(input$addBtn, {
    nr <- input$addBtn
    id <- paste0("input",input$addBtn)
    insertUI(
      selector = '#inputList',
      ui=#box(
      div(
        style = "border:1px solid black; margin:10px;",
        #width=12,
        id = paste0("newInput",nr),
        fluidRow(
            # column(3,
            #     fileInput(paste0('bw', nr), 
            #     "Select Bigwig", accept = c(".bw", ".bigwig"),
            #      multiple = FALSE)
            # ),
            column(6,
                textInput(
                    paste0('urlchip',nr),
                    label="",
                    placeholder = "https://<file.bigwig>")
            ),
            column(2,
                actionButton(paste0('loadurlchip',nr), label = "Add URL"))
          ),
        fluidRow(
            # Update in server to the basename minus the suffix
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
        fluidRow(
          column(6,
            numericInput(paste0("minargs",nr), "Min", value = "")
            ),
          column(6,
            numericInput(paste0("maxargs",nr), "Max", value = "")
            )
        ),
        actionButton(paste0('removeBtn',nr), 'Remove')
      )
    )
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