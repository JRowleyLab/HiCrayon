# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    req(input$chip1)

    validate(need(bw1v$y!="NULL", "Please upload a bigwig file"))

    bwlist <- processBigwigs(
        bigwig = bw1v$y,
        binsize = as.integer(input$bin),
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        log = input$log
        )

    return(bwlist)
}) %>% shiny::bindEvent(input$generate_hic, input$chip1)


# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP2 <- reactive({

    req(input$chip2)

    validate(need(bw2v$y!="NULL", "Please upload a bigwig file"))

    bwlist <- processBigwigs(
        bigwig = bw2v$y,
        binsize = as.integer(input$bin),
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        log = input$log
        )

    return(bwlist)
}) %>% shiny::bindEvent(input$generate_hic, input$chip2)