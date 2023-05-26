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
        binsize = input$bin
    )

    return(matrix)
}) %>% shiny::bindEvent(input$generate_hic)
