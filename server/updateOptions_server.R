# Update dropdown with all possible sequential
# matplotlib colormaps
observe({
    updateSelectizeInput(
        session, "map_colour",
        choices = matplot_colors(),
        selected = "JuiceBoxLike",
        server = TRUE
        )

    updateSelectizeInput(
        session, "chip_cmap",
        choices = matplot_colors(),
        selected = "JuiceBoxLike",
        server = TRUE
        )
})

# ChIP names reactivevalue
chipnames <- reactiveValues()
observe({
    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        if(!is.null(bw1v[[LETTERS[x]]])){
        updateTextInput(
            session,
            inputId = paste("n", LETTERS[x], sep = "_"),
            value = tools::file_path_sans_ext(basename(bw1v[[LETTERS[x]]])
        )
    )
    }

    })
    
})

# Update chromsome list
observe(
    updateSelectizeInput(session, "chr",
        choices = HiCmetadata()$chrs)
)

# Update resolution list
observe(
    updateSelectizeInput(session, "bin",
        choices = HiCmetadata()$res,
        selected = HiCmetadata()$res[1])
)

# Set maximum value for coordinates based on chromosome
idx <- reactive({
    which(input$chr==HiCmetadata()$chrs)
})

observe(
    updateAutonumericInput(
            session = session, 
            inputId = "start",
            options = list(maximumValue = HiCmetadata()$lengths[idx()] )
        )
)


observe(
    updateAutonumericInput(
            session = session, 
            inputId = "stop",
            options = list(maximumValue = HiCmetadata()$lengths[idx()] )
        )
)


observeEvent(input$endofchrom, {
    updateAutonumericInput(
            session = session, 
            inputId = "stop",
            value = HiCmetadata()$lengths[idx()]
        )
})
