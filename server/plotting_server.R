hicplot <- reactive({

    patt <- str_glue(
            "HiC_{input$chr}_{input$start}_{input$stop}_{input$bin}_norm-{input$norm}_"
            )

    pngpath <- tempfile(
        pattern = patt,
        fileext = ".png",
        tmpdir = userinfo)

    svgpath <- tempfile(
        pattern = patt,
        fileext = ".svg",
        tmpdir = userinfo)

    path <- hic_plot(
        cmap = hic_color(),
        distnormmat = hic_distance(),
        filepathpng = pngpath,
        filepathsvg = svgpath)

    pngout <- tuple(path, convert = T)[0]
    svgout <- tuple(path, convert = T)[1]

    return(list(
        png = pngout,
        svg = svgout
    ))
}) 


chipplot <- reactive({

    req(input$chip1)

    images <- c()
    tracks <- list(list())
    col <- list()
    trackcol <- list()
    linewidth <- list()

    lapply(seq_along(bw1v$features), function(x){

        if(!is.null(bw1v$features[[x]][[1]])){
        
            # Overwrite the colour and track for single chips
            col[1] <- input[[paste0("col", x)]]
            #track color
            trackcol[1] <- input[[paste0("trackcol", x)]]
            linewidth[1] <- input[[paste0("linewidth", x)]]
                        
            # Value clipped bigwig track with raw values
            # Feature 1
            tracks[[1]][[1]] <- chipalpha()$chipclipped[[x]][[1]]
            tracks[[1]][[2]] <- NULL
            # Feature 2
            if(f2v[[as.character(x)]]){
                req(!is.null(bw1v$features[[x]][[2]]))
                tracks[[1]][[2]] <- chipalpha()$chipclipped[[x]][[2]]
            }

                
            # List of min/max values [[1,2]].
            minmaxlist <- list(minmaxargs$nums[[x]][[1]], minmaxargs$nums[[x]][[2]])

            patt <- str_glue(
            "ChIP_{input[[paste0('n',x)]]}_{input$chr}_{input$start}_{input$stop}_{input$bin}_norm-{input$norm}_"
            )

            pngpath <- tempfile(
                pattern = patt,
                fileext = ".png",
                tmpdir = userinfo)

            svgpath <- tempfile(
                pattern = patt,
                fileext = ".svg",
                tmpdir = userinfo)

            p1_plot <- ChIP_plot(
                disthic = hic_distance(),
                col1 = col,
                trackcol = trackcol,
                linewidth = linewidth,
                mat = chipalpha()$chipalphas[[x]],
                chip = tracks,
                #f2 = f2v[[as.character(x)]],
                disthic_cmap = hic_color(),
                hicalpha = input$hicalpha,
                bedalpha = input$bedalpha,
                filepathpng = pngpath,
                filepathsvg = svgpath
                #minmaxs = minmaxlist #[[1,2]] #not used.
                )

            pngimage <- tuple(p1_plot, convert = T)[0]
            svgimage <- tuple(p1_plot, convert = T)[1]

            images[[x]] <<- list(png = pngimage, svg = svgimage)
        }
    
    })

    return(images)
}) 



combinedchips <- reactiveValues()
observeEvent(confirmed(), {
    req(input$chip1)
    
    chipstocombine <- c()
    # Combine ChIPs that are selected for
    # combination from checkbox
    for(i in seq_along(bw1v$features)){

        if(!is.null(bw1v$features[[i]][[1]])){

            if(input[[paste0("comb", i)]] == TRUE){
                chipstocombine = append(chipstocombine, i)
            }
        }
        combinedchips$chips <- chipstocombine
    }
})


chipcombinedplot <- reactive({

    req(input$chip1)

    chipstocombine <- combinedchips$chips

    req(length(chipstocombine)>1)

    # Combine ChIP data from protein 1
    # and protein 2
    #chip, r, g, b, disthic, sample, chip2, hicalpha, opacity

    #this doesn't seem to work when you skip a chip for
    # combination
    allchips <- list()
    counter = 1
    for(x in seq_along(chipstocombine)){
        allchips[[counter]] <- chipalpha()$chipalphas[[chipstocombine[x]]]
        counter = counter + 1
    }
    m3 <- lnerp_matrices(allchips)
    # bigwig tracks
    tracks <- list()
    cols <- c()
    trackcols <- c()
    linewidth <- list()
    names <- list()
    # List of min/max values [[1,2]].
    #minmaxlist_list <- list()

    counter = 1
    # Create lists of info for combination plot
    for(x in seq_along(chipstocombine)){

        tracks[[counter]] <- list()

        # Tracks for feature 1 and feature 2
        tracks[[counter]][[1]] <- chipalpha()$chipclipped[[chipstocombine[x]]][[1]]
        tracks[[counter]][[2]] <- NULL
        
        if(f2v[[as.character(x)]]){
            req(!is.null(bw1v$features[[x]][[2]]))
            tracks[[counter]][[2]] <- chipalpha()$chipclipped[[chipstocombine[x]]][[2]]
        }
        
        cols <- append(cols, input[[paste0("col", chipstocombine[x])]])
        trackcols <- append(trackcols, input[[paste0("trackcol", chipstocombine[x])]])
        linewidth[1] <- input[[paste0("linewidth", x)]]
    
        names <- append(names, input[[paste0("n", chipstocombine[x])]])
        # List of min/max values [[1,2]].
        #minmaxlist_list <- append(minmaxlist_list, list(minmaxargs$nums[[x]][[1]]) )
        counter = counter + 1
    }

    patt <- str_glue(
    "ChIP_{paste0(names, collapse = '_')}_{input$chr}_{input$start}_{input$stop}_{input$bin}_norm-{input$norm}_"
    )

    pngpath <- tempfile(
        pattern = patt,
        fileext = ".png",
        tmpdir = userinfo)

    svgpath <- tempfile(
        pattern = patt,
        fileext = ".svg",
        tmpdir = userinfo)

    chipcomb <- ChIP_plot(
            disthic = hic_distance(),
            #f2 = FALSE, #f2v[[as.character(x)]],
            col1 = cols,
            trackcol = trackcols, # just takes the last one
            linewidth = linewidth,
            mat = m3,
            chip = tracks,
            disthic_cmap = hic_color(),
            hicalpha = input$hicalpha,
            bedalpha = input$bedalpha,
            filepathpng = pngpath,
            filepathsvg = svgpath
            )

    chippng <- tuple(chipcomb, convert = T)[0]
    chipsvg <- tuple(chipcomb, convert = T)[1]

    return(list(
        png = chippng,
        svg = chipsvg
    ))
}) 