# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    logs = list()
    raws = list()

    print("n")

    lapply(seq_along(bw1v$features), function(x){
        # bw1v$features[[nr]][[1]]
        # Different signals checked?
        #if(f2v[[as.character(x)]]){
            feature1 = bw1v$features[[x]][1]
            feature2 = bw1v$features[[x]][1]
        
            if(!is.null(bw1v$features[[x]][[1]])){
                bwlist <- processBigwigs(
                    bigwig = bw1v$features[[x]][[1]],
                    binsize = as.integer(input$bin),
                    chrom = input$chr,
                    start = input$start,
                    stop = input$stop
                )
                print("done")
            logs[[x]] <<- tuple(bwlist, convert=T)[0]
            raws[[x]] <<- tuple(bwlist, convert=T)[1]
            }
        #}
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

    lapply(seq_along(bw1v$features), function(x){

        if(!is.null(bw1v$features[[x]][[1]])){

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)
            #min and max values chosen by user. No input is ""
            minarg <- minmaxargs$nums[[x]][[1]][[1]]
            maxarg <- minmaxargs$nums[[x]][[1]][[2]]
            print(minarg)
            print(maxarg)

            m1 <- calcAlphaMatrix(
                bwlist_ChIP1()$logs[[x]],
                hic_distance(),
                input$chipscale,
                rgb[1], 
                rgb[2], 
                rgb[3],
                minarg=minarg,#minarg,
                maxarg=maxarg #maxarg
                )
            

            # global variable to allow accessing of value 
            # outside lapply function
            chipalphas[[x]] <<- tuple(m1, convert=T)[0]
            chipclipped[[x]] <<- tuple(m1, convert=T)[1]
            minmaxclip[[x]] <<- tuple(m1, convert=T)[2]

            #FEATURE 1
            # Update chip-seq min values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("minargs",x, 1),
                    value = minmaxclip[[x]][[1]])

            # Update chip-seq max values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("maxargs",x, 1),
                    value = minmaxclip[[x]][[2]])

            #FEATURE 2
            # Update chip-seq min values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("minargs",x, 2),
                    value = minmaxclip[[x]][[1]])

            # Update chip-seq max values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("maxargs",x, 2),
                    value = minmaxclip[[x]][[2]])

        }
    })

    return(list(
        chipalphas = chipalphas,
        chipclipped = chipclipped,
        minmaxclip = minmaxclip
    ))
}) 