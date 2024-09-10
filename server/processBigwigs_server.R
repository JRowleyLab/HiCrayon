# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region

# Just put them in lists, do if checked, do 1 vs 1, if not do 1 vs 2.
# Or go through each
bwlist_ChIP1 <- reactive({

    logs = list()
    raws = list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){

        if(!is.null(bw1v[[paste0("bw",x)]])){
            bwlist <- processBigwigs(
            bigwig = bw1v[[paste0("bw",x)]],
            binsize = as.integer(input$bin),
            chrom = input$chr,
            start = input$start,
            stop = input$stop
            )
        logs[[x]] <<- tuple(bwlist, convert=T)[0]
        raws[[x]] <<- tuple(bwlist, convert=T)[1]
        }
    })

    return(list(
        logs = logs,
        raws = raws
        ))
}) 


chipalpha <- reactive({

    req(input$chip1)

    chipalphas <- list()
    chipclipped <- list()
    minmaxclip <- list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){

        if(!is.null(bw1v[[paste0("bw",x)]])){

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)
            #min and max values chosen by user. No input is ""
            minarg <- minmaxargs[[paste0("mm",x)]][[1]]
            maxarg <- minmaxargs[[paste0("mm",x)]][[2]]

            m1 <- calcAlphaMatrix(
                bwlist_ChIP1()$logs[[x]],
                hic_distance(),
                input$chipscale,
                rgb[1], 
                rgb[2], 
                rgb[3],
                minarg=minarg,
                maxarg=maxarg
                )
            

            # global variable to allow accessing of value 
            # outside lapply function
            chipalphas[[x]] <<- tuple(m1, convert=T)[0]
            chipclipped[[x]] <<- tuple(m1, convert=T)[1]
            minmaxclip[[x]] <<- tuple(m1, convert=T)[2]

            # Update chip-seq min values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("minargs",x),
                    value = minmaxclip[[x]][[1]])

            # Update chip-seq max values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("maxargs",x),
                    value = minmaxclip[[x]][[2]])

        }
    })

    return(list(
        chipalphas = chipalphas,
        chipclipped = chipclipped,
        minmaxclip = minmaxclip
    ))
}) 