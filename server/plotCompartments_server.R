filter_compartments <- reactive({
    validate(need(bedv$y, "Please upload compartments bed file"))

    filterCompartments(
        bedv$y, 
        input$chr, 
        input$start, 
        input$stop)
})  %>% shiny::bindEvent(input$generate_hic)

scale_compartments <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    rgbA <- col2rgb(input$colcompA)
    rgbB <- col2rgb(input$colcompB)

    
    comps <- scaleCompartments(
        disthic = hic_distance(),
        comp_df = filter_compartments(),
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

    m3 = lnerp_matrices(m1, m2)

    return(m3)
}) %>% shiny::bindEvent(input$generate_hic)



comp_plot <- reactive({
    req(hicv$y)
    validate(need(bedv$y, "Please upload compartments bed file"))

    plotCompartments(
        disthic = hic_distance(), 
        comp = filter_compartments(), 
        ABmat = comp_LNERP(),
        colA = input$colcompA,
        colB = input$colcompB
        )
}) %>% shiny::bindEvent(input$generate_hic)