hicplot <- reactive({
    hic_plot(REDMAP = input$map_colour,
             #thresh = input$thresh,
             distnormmat = hic_distance()
             )
}) %>% shiny::bindEvent(input$generate_hic)

#chip1, 255, 0, 0, disthic, "ChIP1", "NULL", .3, 1, 255

p1plot <- reactive({

    req(input$chip1)

    p1_plot <- ChIP_plot(
        disthic = hic_distance(),
        r = 255,
        g = 0,
        b = 0,
        chip = bwlist_ChIP1(),
        chip2 = "NULL",
        hicalpha = input$hicalpha,
        bedalpha = input$bedalpha,
        opacity = input$opacity,
        sample = "ChIP1"
        )

}) %>% shiny::bindEvent(input$generate_hic, input$chip1) 


p2plot <- reactive({

    req(input$chip2)

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        r = 0,  
        g = 0, 
        b = 255,
        chip = bwlist_ChIP2(),
        chip2 = "NULL",
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        opacity = input$opacity2,
        sample = "ChIP2"
        )

}) %>% shiny::bindEvent(input$generate_hic, input$chip2)


p1and2plot <- reactive({

    req(input$chip1)
    # Combine ChIP data from protein 1
    # and protein 2
    #chip, r, g, b, disthic, sample, chip2, hicalpha, opacity

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        r = 0, #distance_ChIP1()$rmat,
        g = 0, #distance_ChIP2()$gmat,
        b = 255, #distance_ChIP2()$bmat,
        chip = bwlist_ChIP1(), #distance_ChIP1()$bwlist_norm,
        chip2 = bwlist_ChIP2(), # distance_ChIP2()$bwlist_norm,
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        opacity = input$opacity2,
        sample = "ChIP_combined"
        )

}) %>% shiny::bindEvent(input$generate_hic) 

# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(input$chip2){
        print(hicplot())

        texts <- c("HiC", "CTCF", "RAD21", "CTCF + RAD21")
        hrefs <- c(hicplot(), p1plot(), p2plot(), p1and2plot())
        images <- c(hicplot(), p1plot(), p2plot(), p1and2plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 3,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    }else if (input$chip1) {
       print(hicplot())

        texts <- c("HiC", "CTCF")
        hrefs <- c(hicplot(), p1plot())
        images <- c(hicplot(), p1plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    } else {
       print(hicplot())

        texts <- c("HiC")
        hrefs <- c(hicplot())
        images <- c(hicplot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    }
    
}) %>% shiny::bindEvent(input$generate_hic)