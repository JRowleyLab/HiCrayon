# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({
    req(hicv$y)
    # Need at least one chip uploaded.
    # validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    # Create nested lists
    logs <- lapply(1:length(bw1v$features), function(i) list(list()))
    raws <- lapply(1:length(bw1v$features), function(i) list(list()))
    HMMcols <- lapply(1:length(bw1v$features), function(i) lapply(1, function(j) "NULL" ))

    
    lapply(seq_along(bw1v$features), function(x){

        feature1 = "NULL"
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

            if(input[[paste0("filetype", x)]] %in% c("chromHMM", "Eigen")){
                wigs = list(feature1)
            }

            for(i in seq_along(wigs)){

                # if chromHMM, expect two outputs:
                if(input[[paste0("filetype", x)]] %in% c("chromHMM")){

                    # prepare bigwigs from any input
                    bwprep <- prepareBigwigs(
                        input = wigs[[i]],
                        binsize = as.integer(input$bin),
                        num = paste0(x,i),
                        userinfo = userinfo,
                        filetype = input[[paste0("filetype", x)]]
                    )

                    print("states completed")

                    # list containing 15+ bigwig paths
                    # each one a different chromHMM state
                    bwstatepaths <- tuple(bwprep, convert=T)[0]
                    # the color associated with each state
                    bwstatecols <- tuple(bwprep, convert=T)[1]

                    HMMcols[[x]] <<- bwstatecols


                    print(bwstatepaths)
                    print(bwstatecols)

                    # state names as they come out of chromHMM
                    # (with '/' replaced with '_')
                    # Update UI with these states and a checkbox beside all
                    # include only selected ones.
                    # maybe use the index of the name to remove em from the paths.
                    state_names <- state <- sub(".*_([^_]+)\\.bigwig$", "\\1", bwstatepaths)

                    for(j in seq_along(bwstatepaths)){
                        bwlist <- processBigwigs(
                            bigwig = bwstatepaths[[j]],
                            binsize = as.integer(input$bin),
                            chrom = input$chr,
                            start = input$start,
                            stop = input$stop
                            )

                        logs[[x]][[1]][[j]] <<- tuple(bwlist, convert=T)[0]
                        raws[[x]][[1]][[j]] <<- tuple(bwlist, convert=T)[1]
                    }
                    
                    print("done")


                } else {
                    # prepare bigwigs from any input
                    bwprep <- prepareBigwigs(
                        input = wigs[[i]],
                        binsize = as.integer(input$bin),
                        num = paste0(x,i),
                        userinfo = userinfo,
                        filetype = input[[paste0("filetype", x)]]
                    )

                    bwpath <- tuple(bwprep, convert=T)[0]

                    # generate value lists (log and raw)
                    bwlist <- processBigwigs(
                        bigwig = bwpath,
                        binsize = as.integer(input$bin),
                        chrom = input$chr,
                        start = input$start,
                        stop = input$stop
                        )

                    if(tuple(bwlist, convert=T)[0]=="OOO"){
                        "Error: The entries are out of order or have illegal values. Please check and try again."
                        shinyCatch({stop(paste0("Error: The entries in ", wigs[[i]] ," are out of order or have illegal values. Please check and try again."))}, 
                            prefix = '',
                            blocking_level = "error")
                    }

                    logs[[x]][[i]] <<- tuple(bwlist, convert=T)[0]
                    raws[[x]][[i]] <<- tuple(bwlist, convert=T)[1]
                }
        }
    }
    })

    return(list(
        logs = logs,
        raws = raws,
        HMMcols = HMMcols
        ))
}) %>% shiny::bindEvent(confirmed())

chipalpha <- reactive({
    
    req(hicv$y)
    req(input$chip1)

    chipalphas <- list()
    chipclipped <- list()
    minmaxclip <- list()

    lapply(seq_along(bw1v$features), function(x){

        if(!is.null(bw1v$features[[x]][[1]])){

            if(logv[[paste0(x, 1)]]){
                feature1 = bwlist_ChIP1()$logs[[x]][[1]]
            }else{
                feature1 = bwlist_ChIP1()$raws[[x]][[1]]
            }

            # Norm Tracks
            #feature1 = bwlist_ChIP1()$raws[[x]][[1]]
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
                feature2 = bwlist_ChIP1()$raws[[x]][[2]]
                if(logv[[paste0(x, 2)]]){
                    feature2 = bwlist_ChIP1()$logs[[x]][[2]]
                }else{
                    feature2 = bwlist_ChIP1()$raws[[x]][[2]]
                }
                # Minmax
                #min and max values chosen by user. No input is ""
                # Feature 2
                minarg2 <- minmaxargs$nums[[x]][[2]][[1]]
                maxarg2 <- minmaxargs$nums[[x]][[2]][[2]]
                minmaxs2 = list(minarg2, maxarg2)
            }
            # minmax Lists
            minmaxlist = list(minmaxs1, minmaxs2)

            # Feature lists
            wigs = list(feature1, feature2)

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)
            
            # If an eigenvector bedgraph:
            # Perform A, B and AB calculations automatically and 
            # overlay all.
            if(input[[paste0("filetype", x)]] %in% c("Eigen")){

                Acolrgb = col2rgb(input[[paste0("compcolA", x)]])
                Bcolrgb = col2rgb(input[[paste0("compcolB", x)]])
                ABcolrgb = col2rgb(input[[paste0("compcolAB", x)]])

                # wigs will always be feature1=eigen, feature2=NULL
                # split feature1 into: A, B
                twolists = splitListintoTwo(
                    bedg = paste0(userinfo,"/bed",x,"1.bigwig"),
                    binsize = as.integer(input$bin),
                    chrom = input$chr,
                    start = input$start,
                    stop = input$stop
                    )
                positive = tuple(twolists, convert=T)[0]
                negative = tuple(twolists, convert=T)[1]

                Amat <- calcAlphaMatrix(
                    chiplist= list(positive, "NULL"),
                    minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                    f2=FALSE,
                    disthic=hic_distance(),
                    showhic=input$chipscale,
                    r=Acolrgb[1],
                    g=Acolrgb[2],
                    b=Acolrgb[3]
                    )
                Bmat <- calcAlphaMatrix(
                    chiplist= list(negative, "NULL"),
                    minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                    f2=FALSE,
                    disthic=hic_distance(),
                    showhic=input$chipscale,
                    r=Bcolrgb[1],
                    g=Bcolrgb[2],
                    b=Bcolrgb[3]
                    )

                ABmat <- calcAlphaMatrix(
                    chiplist=list(positive, negative),
                    minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                    f2=TRUE,
                    disthic=hic_distance(),
                    showhic=input$chipscale,
                    r=ABcolrgb[1],
                    g=ABcolrgb[2],
                    b=ABcolrgb[3]
                    )

                mat1 = tuple(Amat, convert=T)[0]
                mat2 = tuple(Bmat, convert=T)[0]
                mat3 = tuple(ABmat, convert=T)[0]

                matrices = list(mat1, mat2, mat3)

                COMPmat <- lnerp_matrices(matrices)

                # chipclipped: Find a way to clip raws and stitch them back together. 
                chipalphas[[x]] <<- COMPmat

                # Both clipped and minmax need to be adjusted with stitched.
                # CURRENTLY it's just taking the A compartment value.
                Atrack = tuple(Amat, convert=T)[1]
                Btrack = tuple(Bmat, convert=T)[1]
                chipclipped[[x]] <<- list(Atrack, Btrack)
                minmaxclip[[x]] <<- as.list(tuple(Amat, convert=T)[2])

            } else if (input[[paste0("filetype", x)]] %in% c("chromHMM")) {
                # combine all 15 ish bigwigs into matrix.

                # Take colors from HMMcols
                state_cols = bwlist_ChIP1()$HMMcols[[x]]
                print("state_col")
                print(state_cols)

                # wigs will always be feature1=eigen, feature2=NULL


                stateWigs = bwlist_ChIP1()$raws[[x]][[1]]

                #print(stateWigs[[1]])

                matrices = list()
                counter = 1

                for(j in seq_along(stateWigs)){
                    print(j)
                    state_matrix <- calcAlphaMatrix(
                        chiplist= list(stateWigs[[j]], "NULL"),
                        minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                        f2=FALSE,
                        disthic=hic_distance(),
                        showhic=input$chipscale,
                        r=state_cols[[j]][1],
                        g=state_cols[[j]][2],
                        b=state_cols[[j]][3]
                        )
                    
                    mat1 = tuple(state_matrix, convert=T)[0]

                    matrices[[counter]] <- mat1
                    counter = counter + 1
                }

                COMPmat <- lnerp_matrices(matrices)

                # chipclipped: Find a way to clip raws and stitch them back together. 
                chipalphas[[x]] <<- COMPmat
                chipclipped[[x]] <<- stateWigs
                minmaxclip[[x]] <<- as.list(tuple(state_matrix, convert=T)[2])

            } else {
                # Regular mode, handles bigwigs, bed and bedgraphs
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

                #minmaxclip[[x]] <<- as.list(tuple(m1, convert=T)[2])
                # Enter the minmax values for feature 1
                # [[window]][[feature]][[minORmax]]
                minmaxclip[[x]] <<- list()
                minmaxclip[[x]][[1]] <<- as.list(tuple(m1, convert=T)[2][[1]])
                if(f2v[[as.character(x)]]){
                    minmaxclip[[x]][[2]] <<- as.list(tuple(m1, convert=T)[2][[2]])
                }
            }

            # UPDATING MIN MAX VALUES
            #FEATURE 1
            # Update chip-seq min values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("minargs", x, 1),
                    value = minmaxclip[[x]][[1]][[1]]
                    )

            # Update chip-seq max values if nan
            updateNumericInput(
                    session = session,
                    inputId = paste0("maxargs", x, 1),
                    value = minmaxclip[[x]][[1]][[2]]
                    )

            if(f2v[[as.character(x)]]){
                #FEATURE 2
                # Update chip-seq min values if nan
                updateNumericInput(
                        session = session,
                        inputId = paste0("minargs",x, 2),
                        value = minmaxclip[[x]][[2]][[1]]
                )

                # Update chip-seq max values if nan
                updateNumericInput(
                        session = session,
                        inputId = paste0("maxargs",x, 2),
                        value = minmaxclip[[x]][[2]][[2]]
                )
            }
        }
    })

    return(list(
        chipalphas = chipalphas,
        chipclipped = chipclipped,
        minmaxclip = minmaxclip
    ))
}) 