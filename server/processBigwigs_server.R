# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    logs = list(list())
    raws = list(list())

    lapply(seq_along(bw1v$features), function(x){
        # bw1v$features[[nr]][[1]]
        # If "different signals" checked TRUE
        if(f2v[[as.character(x)]]){
            req(!is.null(bw1v$features[[x]][[2]]))
            feature1 = bw1v$features[[x]][[1]]
            feature2 = bw1v$features[[x]][[2]]
            wigs = list(feature1, feature2)
        }else{
            feature1 = bw1v$features[[x]][[1]]
            wigs = list(feature1)
        }
        
        for(i in seq_along(wigs)){
            req(bw1v$features[[x]][[1]])
            bwlist <- processBigwigs(
                bigwig = wigs[[i]],
                binsize = as.integer(input$bin),
                chrom = input$chr,
                start = input$start,
                stop = input$stop
            )

        logs[[x]][[i]] <<- tuple(bwlist, convert=T)[0]
        raws[[x]][[i]] <<- tuple(bwlist, convert=T)[1]
        #print(logs[[1]][[1]])
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

    lapply(seq_along(bw1v$features), function(x){

        if(!is.null(bw1v$features[[x]][[1]])){

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)
            #min and max values chosen by user. No input is ""
            # Feature 2
            minarg1 <- minmaxargs$nums[[x]][[1]][[1]]
            maxarg1 <- minmaxargs$nums[[x]][[1]][[2]]
            # Feature 2
            minarg2 <- minmaxargs$nums[[x]][[2]][[1]]
            maxarg2 <- minmaxargs$nums[[x]][[2]][[2]]

            m1 <- calcAlphaMatrix(
                chip1=bwlist_ChIP1()$logs[[x]],
                chip2=, 
                f2=f2v[[as.character(x)]],
                disthic=hic_distance(),
                showchic=input$chipscale,
                r=rgb[1],
                g=rgb[2],
                b=rgb[3],
                minarg1=minarg1,
                maxarg1=maxarg1,
                minarg2=minarg2,
                maxarg2=maxarg1
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