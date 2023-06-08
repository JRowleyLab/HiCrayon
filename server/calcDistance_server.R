hic_distance <- reactive({
    distnormmat <- distanceMatHiC(
                    hicnumpy = HiCmatrix()
                )
    return(distnormmat)

}) %>% shiny::bindEvent(input$generate_hic)