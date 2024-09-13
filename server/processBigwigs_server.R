# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    # Create nested lists
    logs <- lapply(1:length(bw1v$features), function(i) lapply(1:2, function(j) "NULL" ))
    raws <- lapply(1:length(bw1v$features), function(i) lapply(1:2, function(j) "NULL" ))
    
    lapply(seq_along(bw1v$features), function(x){

        
        if(!is.null(bw1v$features[[x]][[1]])){
            # bw1v$features[[nr]][[1]]
            # If "different signals" checked TRUE

            # Norm Tracks
            feature1 = bw1v$features[[x]][[1]]
            feature2 = "NULL"
            
            if(f2v[[as.character(x)]]){
                req(!is.null(bw1v$features[[x]][[2]]))
                feature2 = bw1v$features[[x]][[2]]
            }

            wigs = list(feature1, feature2)
            #print(paste0("wigs: :", wigs))

            for(i in seq_along(wigs)){
                # logs[[x]][[i]] <- "NULL"
                # raws[[x]][[i]] <- "NULL"

                bwlist <- processBigwigs(
                    bigwig = wigs[[i]],
                    binsize = as.integer(input$bin),
                    chrom = input$chr,
                    start = input$start,
                    stop = input$stop
                )
            logs[[x]][[i]] <<- tuple(bwlist, convert=T)[0]
            raws[[x]][[i]] <<- tuple(bwlist, convert=T)[1]
        }
    }
    })

    print(logs)
    print(raws)

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

            # Norm Tracks
            feature1 = bwlist_ChIP1()$logs[[x]][[1]]
            feature2 = "NULL"
            # Minmax
            # Feature 1
            minarg1 <- minmaxargs$nums[[x]][[1]][[1]]
            maxarg1 <- minmaxargs$nums[[x]][[1]][[2]]
            minmaxs1 = list(minarg1, maxarg1)
            minmaxs2 = list("nan", "nan")

            if(f2v[[as.character(x)]]){
                req(!is.null(bw1v$features[[x]][[2]]))
                # Norm Tracks
                feature2 = bwlist_ChIP1()$logs[[x]][[2]]
                # Minmax
                #min and max values chosen by user. No input is ""
                # Feature 2
                minarg2 <- minmaxargs$nums[[x]][[2]][[1]]
                maxarg2 <- minmaxargs$nums[[x]][[2]][[2]]
                minmaxs2 = list(minarg2, maxarg2)
            }
            # minmax Lists
            minmaxlist = list(minmaxs1, minmaxs2)
            print(minmaxlist)

            # Feature lists
            wigs = list(feature1, feature2)
            print(wigs)

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)
            

            m1 <- calcAlphaMatrix(
                chiplist=wigs,
                minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                f2=f2v[[as.character(x)]],
                disthic=hic_distance(),
                showhic=input$chipscale,
                r=rgb[1],
                g=rgb[2],
                b=rgb[3]
                )

            # global variable to allow accessing of value 
            # outside lapply function
            chipalphas[[x]] <<- tuple(m1, convert=T)[0]
            chipclipped[[x]] <<- tuple(m1, convert=T)[1]
            minmaxclip[[x]] <<- tuple(m1, convert=T)[2]
            print(paste0("R:", as.list(minmaxclip[[x]])))

            #FEATURE 1
            # Update chip-seq min values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("minargs",x, 1),
                    value = as.list(minmaxclip[[x]])[1]
                    )

            # Update chip-seq max values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("maxargs",x, 1),
                    value = as.list(minmaxclip[[x]])[2]
                    )

            if(f2v[[as.character(x)]]){
                #FEATURE 2
                # Update chip-seq min values if nan
                updateNumericInput(
                        session = session,
                        inputId = paste0("minargs",x, 2),
                        value = minmaxclip[[x]][1])

                # Update chip-seq max values if nan
                updateNumericInput(
                        session = session,
                        inputId = paste0("maxargs",x, 2),
                        value = minmaxclip[[x]][2])
            }
        }
    })

    return(list(
        chipalphas = chipalphas,
        chipclipped = chipclipped,
        minmaxclip = minmaxclip
    ))
}) 