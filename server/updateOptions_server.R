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
    if(!examBtn()){
         updateSelectizeInput(session, "chr",
            choices = HiCmetadata()$chrs)
        updateSelectizeInput(session, "bin",
            choices = HiCmetadata()$res,
            selected = HiCmetadata()$res[1])
        shinyCatch({message("Hi-C Loaded")}, prefix = '')
    }
   
}) 

#shinyCatch({message(paste(encodehic[selected, "Experiment"], "Hi-C Loading"))}, prefix = '') put in somewehere here

observeEvent(input$generate_hic, {
    matsize <- (as.integer(input$stop) - as.integer(input$start)) / as.integer(input$bin)
    shinyCatch({message(paste0("Loading Hi-C with matrix size: ", matsize))}, prefix = '')
})

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
