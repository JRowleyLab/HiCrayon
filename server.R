## Dynamically show/hide 'bigwig 2 tab'
observeEvent(input$bw2check, {
    if (isTRUE(input$bw2check)) {
        shiny::showTab(
            inputId = "parameters",
            target = "Bigwig 2"
        )
    } else {
        shiny::hideTab(
            inputId = "parameters",
            target = "Bigwig 2"
        )
    }
})

output$dub <- renderText({
    x <- double(input$thresh)
    print(x)
})


HiCmatrix <- reactive({
    matrix <- readHiCasNumpy(
        hicfile = input$hic,
        chrom = input$hic,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = input$binsize
    )

    return(matrix)
})


reactive({
    processBigwigs(
        bigwig = input$bw1,
        min = input$min1,
        max = input$max1,
        peaks = input$p1,
        binsize = input$binsize,
        chrom = input$chrom,
        start = input$start,
        stop = input$stop,
        bigwig2 = input$bw2,
        min2 = input$min2,
        max2 = input$max2,
        peaks2 = input$p2
    )
})
