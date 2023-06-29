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


p1plot <- reactive({

    req(input$chip1)

    rgb <- col2rgb(input$colchip1)

    m1 <- calcAlphaMatrix(
        bwlist_ChIP1(),
        hic_distance(),
        input$chipscale,
        rgb[1], 
        rgb[2], 
        rgb[3])

    p1_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = input$colchip1,
        col2 = "NULL",
        mat = m1,
        chip = bwlist_ChIP1(),
        chip2 = "NULL",
        disthic_cmap = input$chip_cmap,
        hicalpha = input$hicalpha,
        bedalpha = input$bedalpha,
        sample = "ChIP1",
        chrom = input$chr,
        bin = input$bin, 
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        name = input$n1
        )

}) %>% shiny::bindEvent(input$generate_hic, input$chip1) 


p2plot <- reactive({

    req(input$chip2)

    rgb <- col2rgb(input$colchip2)

    m2 <- calcAlphaMatrix(
        bwlist_ChIP2(),
        hic_distance(),
        input$chipscale,
        rgb[1],
        rgb[2], 
        rgb[3])

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = "NULL",
        col2 = input$colchip2,
        mat = m2,
        chip = "NULL",
        chip2 = bwlist_ChIP2(),
        disthic_cmap = input$chip_cmap,
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        sample = "ChIP2",
        chrom = input$chr,
        bin = input$bin, 
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        name = input$n2
        )

}) %>% shiny::bindEvent(input$generate_hic, input$chip2)


p1and2plot <- reactive({

    req(input$chip1)
    req(input$chip2)
    # Combine ChIP data from protein 1
    # and protein 2
    #chip, r, g, b, disthic, sample, chip2, hicalpha, opacity
    print('plotting combined')

    rgb <- col2rgb(input$colchip1)
    rgb2 <- col2rgb(input$colchip2)

    m1 <- calcAlphaMatrix(bwlist_ChIP1(), hic_distance(), input$chipscale, rgb[1], rgb[2],rgb[3])
    m2 <- calcAlphaMatrix(bwlist_ChIP2(), hic_distance(), input$chipscale, rgb2[1], rgb2[2],rgb2[3])
    m3 <- lnerp_matrices(m1, m2)

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = input$colchip1,
        col2 = input$colchip2,
        mat = m3,
        chip = bwlist_ChIP1(),
        chip2 = bwlist_ChIP2(),
        disthic_cmap = input$chip_cmap,
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        sample = "ChIP_combined",
        chrom = input$chr,
        bin = input$bin, 
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        name = paste0(input$n1, "-", input$n2)
        )

}) %>% shiny::bindEvent(input$generate_hic) 