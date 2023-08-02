hicplot <- reactive({
    hic_plot(cmap = input$map_colour,
             distnormmat = hic_distance(),
             chrom = input$chr,
             bin = input$bin, 
             start = input$start,
             stop = input$stop,
             norm = input$norm
             )
}) %>% shiny::bindEvent(input$generate_hic)


chipalpha <- reactive({

    req(input$chip1)

    chipalphas <- list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        col <- input[[paste("col", LETTERS[[x]], sep="_")]]
        rgb <- col2rgb(col)

        m1 <- calcAlphaMatrix(
            bwlist_ChIP1()$logs[[x]],
            hic_distance(),
            input$chipscale,
            rgb[1], 
            rgb[2], 
            rgb[3])

        chipalphas[[x]] <<- m1
    })

    return(chipalphas)
}) %>% shiny::bindEvent(input$generate_hic, input$chip1) 

chipplot <- reactive({

    req(input$chip1)

    images <- c()
    track <- list()
    col <- list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        
        # Overwrite the colour and track for single chips
        col[1] <- input[[paste("col", LETTERS[[x]], sep="_")]]
        print(col)

        if(input$log==TRUE){
            track[[1]] <- bwlist_ChIP1()$logs[[x]]
        }else {
            track[[1]] <- bwlist_ChIP1()$raws[[x]]
        }

        p1_plot <- ChIP_plot(
            disthic = hic_distance(),
            col1 = col,
            mat = chipalpha()[[x]],
            chip = track,
            disthic_cmap = input$chip_cmap,
            hicalpha = input$hicalpha,
            bedalpha = input$bedalpha,
            sample = paste("ChIP", x, sep=""),
            chrom = input$chr,
            bin = input$bin, 
            start = input$start,
            stop = input$stop,
            norm = input$norm,
            name = input[[paste("n", LETTERS[x], sep="_")]]
            )

        images[x] <<- p1_plot
    })

    return(images)

}) %>% shiny::bindEvent(input$generate_hic, input$chip1) 



combinedchips <- reactiveValues()
observeEvent(input$generate_hic, {
    chipstocombine <- c()
    print('observing chips')
    # Combine ChIPs that are selected for
    # combination from checkbox
    for(i in seq_along(reactiveValuesToList(bw1v))){
        if(input[[paste("comb", LETTERS[i], sep = "_")]] == TRUE){
            chipstocombine = append(chipstocombine, i)
        }
    }
    combinedchips$chips <- chipstocombine
})


chipcombinedplot <- reactive({

    req(input$chip1)

    chipstocombine <- combinedchips$chips

    req(length(chipstocombine)>1)

    # Combine ChIP data from protein 1
    # and protein 2
    #chip, r, g, b, disthic, sample, chip2, hicalpha, opacity
    print(paste('plotting combined:', chipstocombine))

    # first two chips
    m1 <- chipalpha()[[chipstocombine[1]]]
    m2 <- chipalpha()[[chipstocombine[2]]]

    i <- 2

    #combine m1 + m2 lnerp.
    # then iterate through rest of m's
    # and lnerp with result from previous

    while(i <= length(chipstocombine)){

        m3 <- lnerp_matrices(m1, m2)

        if(i < length(chipstocombine)){
            # update matrices
            m1 <- m3
            m2 <- chipalpha()[[chipstocombine[i+1]]]
        }

        # update counter
        i <- i + 1

    }

    # bigwig tracks
    tracks <- list()
    cols <- c()
    names <- list()

    # Create lists of info for combination plot
    for(x in seq_along(chipstocombine)){
        if(input$log==TRUE){
            tracks[[x]] <- bwlist_ChIP1()$logs[[chipstocombine[x]]]
        }else{
            tracks[[x]] <- bwlist_ChIP1()$raws[[chipstocombine[x]]]
        }
        cols <- append(cols, input[[paste("col", LETTERS[[chipstocombine[x]]], sep="_")]])
        names <- append(names, input[[paste("n", LETTERS[[chipstocombine[x]]], sep="_")]])
    }

    ChIP_plot(
        disthic = hic_distance(),
        col1 = cols,
        mat = m3,
        chip = tracks,
        disthic_cmap = input$chip_cmap,
        hicalpha = input$hicalpha,
        bedalpha = input$bedalpha,
        sample = "ChIP_combined",
        chrom = input$chr,
        bin = input$bin, 
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        name = names
        )

}) %>% shiny::bindEvent(input$generate_hic) 