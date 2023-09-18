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
    updateSelectizeInput(session, "bin",
        choices = HiCmetadata()$res,
        selected = HiCmetadata()$res[1])
    shinyCatch({message("Hi-C Loaded")}, prefix = '')
})

observeEvent(input$generate_hic, {
    matsize <- (as.integer(input$stop) - as.integer(input$start)) / as.integer(input$bin)
    shinyCatch({message(paste0("Loading Hi-C with matrix size: ", matsize))}, prefix = '')
})

# Encode datatable modal
#modal popup
#encodehictable
output$encodehicoutput = DT::renderDataTable(
    DT::datatable(
        encodehic[, c("Assembly","Biosample","Description", "BioRep","TechRep","Experiment")], 
        options = list(lengthChange = FALSE) 
  )
)

observeEvent(input$encodehictable, {
    showModal(
        modalDialog(
            dataTableOutput("encodehicoutput"),
            title = 'ENCODE HiC Datasets',
            size = "l",
            easyClose = TRUE,
            footer = tagList(
                actionButton("loadhicencode", "Load"),
                modalButton('Close')
        )
        )
    )
})

observeEvent(input$loadhicencode, {
    selected <- input$encodehicoutput_rows_selected
    href <- encodehic[selected, "HREF"]
    dataurl <- paste0("https://www.encodeproject.org/", href)
    hicv$y <- dataurl
    shinyCatch({message(paste(encodehic[selected, "Experiment"], "Hi-C Loading"))}, prefix = '')
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
