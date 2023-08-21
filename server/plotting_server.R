hicplot <- reactive({
    hic_plot(cmap = input$map_colour,
             distnormmat = hic_distance(),
             chrom = input$chr,
             bin = input$bin, 
             start = input$start,
             stop = input$stop,
             norm = input$norm
             )
}) 


chipalpha <- reactive({

    req(input$chip1)

    chipalphas <- list()

    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){

        if(!is.null(bw1v[[paste0("bw",x)]])){

            col <- input[[paste0("col", x)]]
            rgb <- col2rgb(col)

            m1 <- calcAlphaMatrix(
                bwlist_ChIP1()$logs[[x]],
                hic_distance(),
                input$chipscale,
                rgb[1], 
                rgb[2], 
                rgb[3])

            chipalphas[[x]] <<- m1
        }
    })

    return(chipalphas)
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
                sample = paste0("ChIP", x, sep=""),
                chrom = input$chr,
                bin = input$bin, 
                start = input$start,
                stop = input$stop,
                norm = input$norm,
                name = input[[paste0("n", x)]]
                )

            images[x] <<- p1_plot
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
    allchips <- lapply(chipstocombine, function(x){
        chipalpha()[[chipstocombine[x]]]
    })

    print(chipstocombine)
    m3 <- lnerp_matrices(allchips)

    # bigwig tracks
    tracks <- list()
    cols <- c()
    names <- list()

    # Create lists of info for combination plot
    for(x in seq_along(chipstocombine)){
        if(input$log==TRUE){
            tracks <- append(tracks, bwlist_ChIP1()$logs[[chipstocombine[x]]])
        }else{
            tracks <- append(tracks, bwlist_ChIP1()$raws[[chipstocombine[x]]])
        }
        cols <- append(cols, input[[paste0("col", chipstocombine[x])]])
        names <- append(names, input[[paste0("n", chipstocombine[x])]])
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

}) 