# variable for starting root directory
# When used by others: TODO: change to root
workingdir = '/'

## Server side file-selection
shinyFileChoose(input, 'hic', root = c(wd = workingdir), filetypes=c('hic'))
shinyFileChoose(input, "bedg1", root = c(wd = workingdir), filetypes=c('bed', 'bedgraph'))


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