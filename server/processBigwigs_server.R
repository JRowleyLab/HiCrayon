# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({
    # Need at least one chip uploaded.
    # validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    # Create nested lists
    logs <- lapply(1:length(bw1v$features), function(i) lapply(1:2, function(j) "NULL" ))
    raws <- lapply(1:length(bw1v$features), function(i) lapply(1:2, function(j) "NULL" ))
    iseigen <- vector("list", length(bw1v$features))  # Initialize as a flat list
    
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

            for(i in seq_along(wigs)){

                bwlist <- processBigwigs(
                    bigwig = wigs[[i]],
                    binsize = as.integer(input$bin),
                    chrom = input$chr,
                    start = input$start,
                    stop = input$stop,
                    num = paste0(x,i),
                    userinfo = userinfo
                )
                if(tuple(bwlist, convert=T)[0]=="OOO"){
                    "Error: The entries are out of order or have illegal values. Please check and try again."
                    shinyCatch({stop(paste0("Error: The entries in ", wigs[[i]] ," are out of order or have illegal values. Please check and try again."))}, 
                        prefix = '',
                        blocking_level = "error")
                }
            logs[[x]][[i]] <<- tuple(bwlist, convert=T)[0]
            raws[[x]][[i]] <<- tuple(bwlist, convert=T)[1]
            # iseigen[[x]] <<- tuple(bwlist, convert=T)[2]
            # Check the length of the tuple before accessing the third element
            result_tuple <- tuple(bwlist, convert=T)
            # This needs to check if python is returning a 3 tuple (thruple i guess) 
            # Not sure why. It should always be 3.
            if(length(result_tuple) > 2){
                iseigen[[x]] <<- result_tuple[2]  # Flat list, one element per feature
            }
        }
    }
    })

    return(list(
        logs = logs,
        raws = raws,
        iseigen = iseigen
        ))
})

chipalpha <- reactive({

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
            
            # If a compartment file (ie. bedgraph + values<0).
            # Perform A, B and AB calculations automatically and 
            # overlay all.
            # Think about changing to an actual boolean not string
            if(bwlist_ChIP1()$iseigen[x]=="TRUE"){
                # wigs will always be feature1=eigen, feature2=NULL
                # split feature1 into: A, B
                twolists = splitListintoTwo(
                    bedg = paste0("tmp",x,"1.bw"),
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
                    r=255,
                    g=0,
                    b=0
                    )
                Bmat <- calcAlphaMatrix(
                    chiplist= list(negative, "NULL"),
                    minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                    f2=FALSE,
                    disthic=hic_distance(),
                    showhic=input$chipscale,
                    r=0,
                    g=0,
                    b=255
                    )

                ABmat <- calcAlphaMatrix(
                    chiplist=list(positive, negative),
                    minmaxlist = minmaxlist, #[1][[1]][[2]] [2][[1]][[2]]
                    f2=TRUE,
                    disthic=hic_distance(),
                    showhic=input$chipscale,
                    r=0,
                    g=255,
                    b=0
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
                chipclipped[[x]] <<- tuple(Amat, convert=T)[1]
                minmaxclip[[x]] <<- as.list(tuple(Amat, convert=T)[2])


            }else {

                # Calculate the alpha matrix. Bread and Butter of HiCrayon.
                # m[i,j] = s[i] * s[j]
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