filter_compartments <- reactive({
    req(bedv$y)

    filterCompartments(
        bedv$y, 
        input$chr, 
        input$start, 
        input$stop)
})  %>% shiny::bindEvent(input$generate_hic)


comp_plot <- reactive({
    req(hicv$y)
    req(bedv$y)

    plotCompartments(
        hic_distance(), 
        filter_compartments()
        )
}) %>% shiny::bindEvent(input$generate_hic)