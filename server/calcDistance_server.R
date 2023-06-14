hic_distance <- reactive({

    if(input$disthic){
        matrix <- distanceMatHiC(
                    hicnumpy = HiCmatrix()
                )
    }else {
       matrix <- HiCmatrix()
    }
    
    return(matrix)

}) %>% shiny::bindEvent(input$generate_hic)