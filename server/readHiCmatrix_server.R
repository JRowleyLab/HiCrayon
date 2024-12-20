# hic file handling
hicv <- reactiveValues()
observeEvent(input$hic, {
    if (is_lite_mode) {
        # In 'lite_mode', retrieve filepath from hic_clientside
        inFile <- input[[paste0('hic')]]
        hicv$y <- inFile$datapath  
    } else {
        # Normal mode, retrieve filepath from file input
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$hic)
        hicv$y <- inFile$datapath 
    }
})

observe({
    isvalid = checkURL(input$urlhic, list('hic'))

    if(isvalid=="Valid"){
        hicv$y <- input$urlhic
    }else{
        shinyCatch({stop(paste("Error: ", input$urlhic, " not valid"))}, prefix = '')
    }
    
}) %>% bindEvent(input$loadurlhic)


HiCmetadata <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    hicfile = hicv$y
    metadata = getHiCmetadata(hicfile)

    chrs = tuple(metadata, convert = T)[0]
    res = tuple(metadata, convert = T)[1]
    lengths = tuple(metadata, convert = T)[2]
    hicdump = tuple(metadata, convert = T)[3]


    return(list(
        chrs = chrs,
        res = res,
        lengths = lengths,
        hicdump = hicdump
        ))
})

##################
# Based on the conditional button input$yes,
# run HiCmatrix
######################
HiCMatrixZoom <- reactive({
    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    hicobject <- hicMatrixZoom(
        hicdump = HiCmetadata()$hicdump, 
        chrom = input$chr,
        norm = input$norm,
        binsize = as.integer(input$bin))
    # reset generate hic button
    confirmed(FALSE)
    return(hicobject)
}) %>% bindEvent(confirmed())


HiCmatrix <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(hicv$type=='hic'){
        matrix <- readHiCasNumpy(
        hicobject = HiCMatrixZoom(),
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = as.integer(input$bin)
    )
    }else if (hicv$type=='mcool') {
       matrix <- readCoolHiC(
        mcool = hicv$y,
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = as.integer(input$bin)
        )
    }

    return(matrix)
}) 
