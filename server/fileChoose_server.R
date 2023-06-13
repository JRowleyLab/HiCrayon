# variable for starting root directory
workingdir = '/Zulu/bnolan/HiC_data/'

## Server side file-selection
shinyFileChoose(input, 'hic', root = c(wd = workingdir))
shinyFileChoose(input, "bw1", root = c(wd = workingdir))
shinyFileChoose(input, "bw2", root = c(wd = workingdir))

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

output$f1_bw1 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$bw1[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$bw1)
    as.character(x$datapath[1])
}
})

output$f1_bw2 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$bw2[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$bw2)
    as.character(x$datapath[1])
}
})

##################################
# Store file paths as reactiveValue
##################################
# hic file handling
hicv <- reactiveValues(y = "NULL")
observeEvent(input$hic, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$hic)
    hicv$y <- inFile$datapath
})

# bw1 file handling
bw1v <- reactiveValues(y = "NULL")
observeEvent(input$bw1, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$bw1)
    bw1v$y <- inFile$datapath
})

# bw2 file handling
bw2v <- reactiveValues(y = "NULL")
observe(
    if (input$chip2) {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$bw2)
        bw2v$y <- inFile$datapath
    }else {
        bw2v$y <- "NULL"
    }
)

observe(
    hicv$type <- file_ext(hicv$y)
)