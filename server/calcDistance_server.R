hic_distance <- reactive({

    matrix <- distanceMatHiC(
                hicnumpy = HiCmatrix(),
                thresh = input$thresh,
                distnorm = input$disthic
            )

    return(matrix)

}) %>% shiny::bindEvent(input$generate_hic)