filter_compartments <- reactive({
    validate(need(bedv$y, "Please upload compartments bed file"))

    compsdf <- filterCompartments(
        bedv$y, 
        input$chr, 
        input$start, 
        input$stop)

    validate(need(nrow(compsdf)>2, "No bedgraph data for the selected region"))
    # Check binsize of bedgraph
    boolean <- checkBedBinsize(compsdf, as.integer(input$bin))
    validate(need(
        boolean==TRUE, 
        "Bedgraph binsize does not match selected binsize"))

    return(compsdf)

})  

addbins_compartments <- reactive({
    #add in addemptybins section
    addEmptyBins(df = filter_compartments(),
                 chrom = input$chr,
                 start = input$start,
                 stop = input$stop,
                 binsize = as.integer(input$bin))
}) 

scale_compartments <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    rgbA <- col2rgb(input$colcompA)
    rgbB <- col2rgb(input$colcompB)
    rgbAB <- col2rgb(input$colcompAB)

    
    comps <- scaleCompartments(
        disthic = hic_distance(),
        comp_df = addbins_compartments(),
        Acol = rgbA,
        Bcol = rgbB,
        ABcol = rgbAB
        )

     Amatrix = tuple(comps, convert = T)[0]
     Bmatrix = tuple(comps, convert = T)[1]
     ABmatrix = tuple(comps, convert = T)[2]

     return(list(
        Amatrix = Amatrix,
        Bmatrix = Bmatrix,
        ABmatrix = ABmatrix
     ))

}) 


comp_LNERP <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))
    m1 <- scale_compartments()$Amatrix
    m2 <- scale_compartments()$Bmatrix
    m12 <- scale_compartments()$ABmatrix


    m3 = lnerp_matrices(list(m1, m2, m12))

    return(m3)
}) 



comp_plot <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    patt <- str_glue(
    "Compartment_{input$chr}_{input$start}_{input$stop}_{input$bin}_norm-{input$norm}_"
    )

    pngpath <- tempfile(
        pattern = patt,
        fileext = ".png",
        tmpdir = userinfo)

    svgpath <- tempfile(
        pattern = patt,
        fileext = ".svg",
        tmpdir = userinfo)

    plotcomps <- plotCompartments(
            disthic = hic_distance(), 
            comp = addbins_compartments(),
            ABmat = comp_LNERP(),
            colA = input$colcompA,
            colB = input$colcompB,
            filepathpng = pngpath, 
            filepathsvg = svgpath
            )
    comppng <- tuple(plotcomps, convert = T)[0]
    compsvg <- tuple(plotcomps, convert = T)[1]

    return(list(
        png = comppng,
        svg = compsvg
    ))
}) 