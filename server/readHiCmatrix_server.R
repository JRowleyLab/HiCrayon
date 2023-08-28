options(shiny.maxRequestSize=10000*1024^2)

# hic file handling
hicv <- reactiveValues()
observeEvent(input$hic, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$hic)
    #file <- input$hic
    hicv$y <- inFile$datapath
})

observe({
    isvalid = checkURL(input$urlhic, list('hic'))

    if(isvalid=="Valid"){
        hicv$y <- input$urlhic
    }else{
        #make this an actual error message
        print("URL not valid: ERROR MESSAGE")
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

HiCMatrixZoom <- reactive({
    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    hicobject <- hicMatrixZoom(
        hicdump = HiCmetadata()$hicdump, 
        chrom = input$chr,
        norm = input$norm,
        binsize = as.integer(input$bin))

     message("Loading Hi-C from URL")

    return(hicobject)
})


##################
# Based on the conditional button input$yes,
# run HiCmatrix. how to do this
######################
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
