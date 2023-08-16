HiCmetadata <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))
    print(hicv$type)

    if(hicv$type=='hic'){
        hicfile = hicv$y
        metadata = getHiCmetadata(hicfile)

        chrs = tuple(metadata, convert = T)[0]
        res = tuple(metadata, convert = T)[1]
        lengths = tuple(metadata, convert = T)[2]
    }else if (hicv$type=='mcool') {
       mcoolfile = hicv$y
       metadata = coolerMetadata(mcoolfile)
       chrs = tuple(metadata, convert = T)[0]
       res = tuple(metadata, convert = T)[1]
    }

    print("metadata done")

    return(list(
        chrs = chrs,
        res = res,
        lengths = lengths
        ))
})

##################
# Based on the conditional button input$yes,
# run HiCmatrix. how to do this
######################
HiCmatrix <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(hicv$type=='hic'){
        matrix <- readHiCasNumpy(
        hicfile = hicv$y,
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
}) %>% shiny::bindEvent(input$generate_hic)
