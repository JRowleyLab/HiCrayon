# variable for starting root directory
# When used by others: TODO: change to root
workingdir = '/'

## Server side file-selection
shinyFileChoose(input, 'hic', root = c(wd = workingdir), filetypes=c('hic'))
shinyFileChoose(input, "bedg1", root = c(wd = workingdir), filetypes=c('bed', 'bedgraph'))

# ChIP inputs
#shinyFileChoose(input, "bw1", root = c(wd = workingdir), filetypes=c('bw', 'bigwig'))


###############################
## display path for shinyFileChoose
###############################

## print path to textbox with verbatimTextOutput
output$f1_hic <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$hic[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$hic)
    as.character(x$datapath[1])
}
})


## print path to textbox with verbatimTextOutput
output$f1_bedg1 <- renderPrint({
if (is.integer(input$bedg1[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$bedg1)
    as.character(x$datapath[1])
}
})

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