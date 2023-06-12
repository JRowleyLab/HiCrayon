


HiCmetadata <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))
    print("starting")

    hicfile = hicv$y
    metadata = getHiCmetadata(hicfile)

    chrs = tuple(metadata, convert = T)[0]
    res = tuple(metadata, convert = T)[1]

    print("metadata done")

    return(list(
        chrs = chrs,
        res = res
        ))
})

##################
# Based on the conditional button input$yes,
# run HiCmatrix. how to do this
######################
HiCmatrix <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    matrix <- readHiCasNumpy(
        hicfile = hicv$y,
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = as.integer(input$bin)
    )

    return(matrix)
}) %>% shiny::bindEvent(input$generate_hic)
