# variable for starting root directory
# When used by others: TODO: change to root
workingdir = '/'

## Server side file-selection
shinyFileChoose(input, 'hic', root = c(wd = workingdir), filetypes=c('hic'))
shinyFileChoose(input, "bedg1", root = c(wd = workingdir), filetypes=c('bed', 'bedgraph', 'bedpe'))

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

# Update when switch is clicked
# bedgraph file handling
bedv <- reactiveValues()
observeEvent(input$bedg1, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$bedg1)
    bedv$y <- inFile$datapath
})

# Store HiC file type as reactive value
observe(
    hicv$type <- file_ext(hicv$y)
)