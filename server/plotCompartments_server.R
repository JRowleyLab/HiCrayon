filter_compartments <- reactive({
    req(bedv$y)

    filterCompartments(
        bedv$y, 
        input$chr, 
        input$start, 
        input$stop)
})  %>% shiny::bindEvent(input$generate_hic)

scale_compartments <- reactive({
    req(hicv$y)
    req(bedv$y)
    
    comps <- scaleCompartments(
        disthic = hic_distance(),
        comp_df = filter_compartments(),
        Acol = list(255,0,0),
        Bcol = list(0,0,255)
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
    req(bedv$y)
    m1 <- scale_compartments()$Amatrix
    m2 <- scale_compartments()$Bmatrix

    print(class(m1))
    print(class(m2))

    m3 = lnerp_matrices(m1, m2)

    return(m3)
}) %>% shiny::bindEvent(input$generate_hic)



comp_plot <- reactive({
    req(hicv$y)
    req(bedv$y)

    plotCompartments(
        disthic = hic_distance(), 
        comp = filter_compartments(), 
        ABmat = comp_LNERP()
        )
}) %>% shiny::bindEvent(input$generate_hic)