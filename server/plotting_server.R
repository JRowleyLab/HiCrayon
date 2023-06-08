hicplot <- reactive({
    hic_plot(REDMAP = input$map_colour,
             distnormmat = hic_distance()
             )
}) %>% shiny::bindEvent(input$generate_hic)


p1plot <- reactive({

    req(input$chip1)

    m1 <- calcAlphaMatrix(bwlist_ChIP1(), 255, 0, 0)

    p1_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = 'r',
        col2 = "NULL",
        mat = m1,
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

    m2 <- calcAlphaMatrix(bwlist_ChIP2(), 0, 0, 255)

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = "NULL",
        col2 = 'b',
        mat = m2,
        chip = "NULL",
        chip2 = bwlist_ChIP2(),
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        opacity = input$opacity2,
        sample = "ChIP2"
        )

}) %>% shiny::bindEvent(input$generate_hic, input$chip2)


p1and2plot <- reactive({

    req(input$chip1)
    req(input$chip2)
    # Combine ChIP data from protein 1
    # and protein 2
    #chip, r, g, b, disthic, sample, chip2, hicalpha, opacity
    print('plotting combined')

    m1 <- calcAlphaMatrix(bwlist_ChIP1(), 255, 0, 0)
    m2 <- calcAlphaMatrix(bwlist_ChIP2(), 0, 0, 255)
    m3 <- lnerp_matrices(m1, m2)

    p2_plot <- ChIP_plot(
        disthic = hic_distance(),
        col1 = 'r',
        col2 = 'b',
        mat = m3,
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