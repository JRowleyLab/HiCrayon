# URLs to showcase HCT116 three compartments
hic = "https://www.encodeproject.org/files/ENCFF573OPJ/@@download/ENCFF573OPJ.hic"
h3k27ac = "https://www.encodeproject.org/files/ENCFF277XII/@@download/ENCFF277XII.bigWig"
h3k27me3 = "https://www.encodeproject.org/files/ENCFF232QSG/@@download/ENCFF232QSG.bigWig"
h3k9me3 = "https://www.encodeproject.org/files/ENCFF572IBD/@@download/ENCFF572IBD.bigWig"

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
        selected = HiCmetadata()$chrs[14])

        # Update resolution
        updateSelectizeInput(session, "bin",
            choices = HiCmetadata()$res,
            selected = HiCmetadata()$res[4])

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

    id <- paste0("input", nr)
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
                    label = "URL",
                    value=preselectedParams$url)
            ),
            #column(2,
            #    actionButton(paste0('loadurlchip',nr), label = "Add URL"))
          ),
        fluidRow(
            # Update in server to the basename minus the suffix
            column(4,
                textInput(paste0("n", nr), 
                          label = "Label", 
                          value = preselectedParams$label)
            ),
            column(4,
                colourInput(paste0("col", nr), 
                            "Select colour", 
                           preselectedParams$color)
            ),
            column(4,
                checkboxInput(paste0("comb", nr),
                              "Combination", value = TRUE)
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
      #isvalid = checkURL(input[[paste0('urlchip',nr)]], list('bigWig', 'bigwig', 'bw'))

      #if(isvalid=="Valid"){
     if(examBtn()){
        bw1v[[paste0("bw",nr)]] <- input[[paste0('urlchip',nr)]]

        updateTextInput(
            session,
            inputId = paste0("n", nr),
            value = preselectedParams$label
        )
     } 
    }) 

    observe({
      minmaxlist <- list(
        as.double(input[[paste0("minargs",nr)]]),
        as.double(input[[paste0("maxargs",nr)]])
        )
      minmaxargs[[paste0("mm",nr)]] <- minmaxlist
    })
}

observe({
  #reset hic if encode button clicked

})

observe({
    if(examBtn()) {

      updateCheckboxInput(session, "chip1", value = TRUE)

    # remove all input divs prior to exampleset
    for (i in 1:100){
          shiny::removeUI(
      selector = paste0("div#newInput", i)
      )
    }

        
        # NULL the filepath
        #bw1v <- NULL # [[paste0("bw",nr)]]
        #print(str(reactiveValuesToList(bw1v)))

        addInputSection(1, list(url = h3k27ac, label = "H3K27ac", color = "green"))
        addInputSection(2, list(url = h3k9me3, label = "H3K9me3", color = "purple"))
        addInputSection(3, list(url = h3k27me3, label = "H3K27me3", color = "orange"))
    }
})