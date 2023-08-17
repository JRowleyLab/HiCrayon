
# cols <- reactive({
#     lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
#         div(
#         fluidRow(
#             # Update in server to the basename minus the suffix
#             column(4,
#                 textInput(paste("n", LETTERS[x], sep="_"), 
#                           label = "Name", 
#                           value = paste('ChIP', x))
#             ),
#             column(4,
#                 colourInput(paste("col", LETTERS[x], sep="_"), 
#                             "Select colour", 
#                             "blue")
#             ),
#             column(4,
#                 checkboxInput(paste("comb", LETTERS[x], sep="_"),
#                               "Combination")
#                 )
#     )
#     )
#     })

# })


# output$chipUI <- renderUI({cols()})


# Dynamic UI add/ remove Bigwig upload
# elements

observeEvent(input$addBtn, {
    nr <- input$addBtn
    id <- paste0("input",input$addBtn)
    insertUI(
      selector = '#inputList',
      ui=div(
        id = paste0("newInput",nr),
        fluidRow(
            column(3,
                shinyFilesButton(
                paste0('bw', nr), 
                label = 'Select bigwig', 
                title = 'Please select a .bigwig/.bw file', 
                multiple=FALSE),
            ),
            column(8,
                textInput(
                    paste0('urlchip',nr),
                    label="",
                    placeholder = "https://<file.bigwig>")
            )
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
  })