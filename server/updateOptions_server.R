# Linear interpolate CMAP for HiC
hic_color <- reactive({
    matplot_color(
        gradient = list(
            input$colhic1,
            input$colhic2
            )
    )
})

# Update chromsome and resolution list
observe({
    updateSelectizeInput(session, "chr",
        choices = HiCmetadata()$chrs)

    # get middle resolution
    middle_index <- floor(length(HiCmetadata()$res) / 2) + 1

    updateSelectizeInput(session, "bin",
        choices = HiCmetadata()$res,
        selected = HiCmetadata()$res[middle_index])
    shinyCatch({message("Hi-C Loaded")}, prefix = '')


    tippy_this(
        elementId = "chr", 
        tooltip = "<span style='font-size:15px;'>Select chromosome. Values populate automatically when Hi-C successfully loads.<span>", 
        allowHTML = TRUE,
        placement = 'right'
    )
})

#shinyCatch({message(paste(encodehic[selected, "Experiment"], "Hi-C Loading"))}, prefix = '') put in somewehere here

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
