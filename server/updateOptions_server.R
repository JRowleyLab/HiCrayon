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

# bedgraph file handling
bedv <- reactiveValues()
observeEvent(input$bedg1, {
    inFile <- input$bedg1 
    bedv$y <- inFile$datapath
})

# Store HiC file type as reactive value
observe(
    hicv$type <- file_ext(hicv$y)
)

# User session number as temporary directory
userinfo = paste0("www/user", session$token)

# Create temporary directory for each user
if(!dir.exists(userinfo)){
    dir.create(userinfo)
}

# Delete user temporary directory when session ends
session$onSessionEnded(function() {
    if(dir.exists(userinfo)){
        unlink(userinfo, recursive = TRUE)
    }
})
