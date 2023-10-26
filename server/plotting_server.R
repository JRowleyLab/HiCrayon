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
        filepathsvg = svgpath
             )

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
    track <- list()
    col <- list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){

        if(!is.null(bw1v[[paste0("bw",x)]])){
        
            # Overwrite the colour and track for single chips
            col[1] <- input[[paste0("col", x)]]
            
            # Value clipped bigwig track with raw values
            track[[1]] <- chipalpha()$chipclipped[[x]]

            # List of min/max values [[1,2]]. TODO: Ensure it's not [1,2]
            minmaxlist <- minmaxargs[[paste0("mm",x)]]
            print("plot:")
            print(minmaxlist)


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
                mat = chipalpha()$chipalphas[[x]],
                chip = track,
                disthic_cmap = hic_color(),
                hicalpha = input$hicalpha,
                bedalpha = input$bedalpha,
                filepathpng = pngpath,
                filepathsvg = svgpath,
                minmaxs = minmaxlist #[[1,2]]
                )

            pngimage <- tuple(p1_plot, convert = T)[0]
            svgimage <- tuple(p1_plot, convert = T)[1]

            images[[x]] <<- list(png = pngimage, svg = svgimage)
        }
    })

    return(images)
}) 



combinedchips <- reactiveValues()
observeEvent(input$generate_hic, {
    chipstocombine <- c()
    # Combine ChIPs that are selected for
    # combination from checkbox
    for(i in seq_along(reactiveValuesToList(bw1v))){

        if(!is.null(bw1v[[paste0("bw",i)]])){

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
        allchips[[counter]] <- chipalpha()[[chipstocombine[x]]]
        counter = counter + 1
    }

    m3 <- lnerp_matrices(allchips)

    # bigwig tracks
    tracks <- list()
    cols <- c()
    names <- list()

    counter = 1
    # Create lists of info for combination plot
    for(x in seq_along(chipstocombine)){
        if(input$log==TRUE){
            tracks[[counter]] <- bwlist_ChIP1()$logs[[chipstocombine[x]]]
        }else{
            tracks[[counter]] <- bwlist_ChIP1()$raws[[chipstocombine[x]]]
        }
        cols <- append(cols, input[[paste0("col", chipstocombine[x])]])
        names <- append(names, input[[paste0("n", chipstocombine[x])]])

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
            col1 = cols,
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