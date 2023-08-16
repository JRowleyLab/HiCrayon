filter_compartments <- reactive({
    validate(need(bedv$y, "Please upload compartments bed file"))

    compsdf <- filterCompartments(
        bedv$y, 
        input$chr, 
        input$start, 
        input$stop)

    # Check binsize of bedgraph
    boolean <- checkBedBinsize(compsdf, as.integer(input$bin))
    validate(need(
        boolean==TRUE, 
        "Bedgraph binsize does not match selected binsize"))

    return(compsdf)

})  %>% shiny::bindEvent(input$generate_hic)


addbins_compartments <- reactive({
    print("adding empty bins")
    #add in addemptybins section
    addEmptyBins(df = filter_compartments(),
                 chrom = input$chr,
                 start = input$start,
                 stop = input$stop,
                 binsize = as.integer(input$bin))
}) %>% shiny::bindEvent(input$generate_hic)

scale_compartments <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    rgbA <- col2rgb(input$colcompA)
    rgbB <- col2rgb(input$colcompB)

    
    comps <- scaleCompartments(
        disthic = hic_distance(),
        #comp_df = filter_compartments(),
        comp_df = addbins_compartments(),
        Acol = rgbA,
        Bcol = rgbB
        )

     Amatrix = tuple(comps, convert = T)[0]
     Bmatrix = tuple(comps, convert = T)[1]

     return(list(
        Amatrix = Amatrix,
        Bmatrix = Bmatrix
     ))

}) %>% shiny::bindEvent(input$generate_hic)


comp_LNERP <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))
    m1 <- scale_compartments()$Amatrix
    m2 <- scale_compartments()$Bmatrix

    m3 = lnerp_matrices(list(m1, m2))

    return(m3)
}) %>% shiny::bindEvent(input$generate_hic)



comp_plot <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    plotCompartments(
        disthic = hic_distance(), 
        #comp = filter_compartments(),
        comp = addbins_compartments(),
        ABmat = comp_LNERP(),
        colA = input$colcompA,
        colB = input$colcompB,
        chrom = input$chr,
        start = input$start,
        stop = input$stop
        )
}) %>% shiny::bindEvent(input$generate_hic)