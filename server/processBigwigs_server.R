# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    logs = list()
    raws = list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        print(paste("Bigwig path: ", bw1v[[LETTERS[x]]]))

        bwlist <- processBigwigs(
            bigwig = bw1v[[LETTERS[x]]],
            binsize = as.integer(input$bin),
            chrom = input$chr,
            start = input$start,
            stop = input$stop,
            log = input$log
            )

        logs[[x]] <<- tuple(bwlist, convert=T)[0]
        raws[[x]] <<- tuple(bwlist, convert=T)[1]

    })

    return(list(
        logs = logs,
        raws = raws
        ))
}) %>% shiny::bindEvent(input$generate_hic, input$chip1)