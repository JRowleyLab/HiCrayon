# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({
    print('gallery')

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(input$chip2){

        print(hicplot())

        texts <- c("HiC", rname$n, bname$n, paste0(rname$n,' + ', bname$n))
        hrefs <- c("","","","")
        images <- c(hicplot(), p1plot(), p2plot(), p1and2plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            #enlarge = TRUE,
            image_frame_size = 3,
            title = "",
            #enlarge_method = "modal",
            style = "height: 100vh;"
            )
    }else if (input$chip1) {
       print(hicplot())

        texts <- c("HiC", rname$n)
        #hrefs <- c(hicplot(), p1plot())
        hrefs <- c("","")
        images <- c(hicplot(), p1plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            #enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            #enlarge_method = "modal",
            style = "height: 100vh;"
            )
    } else if (input$bedgraph) {
        print(hicplot())

        texts <- c("HiC", "Compartments")
        hrefs <- c("", "")
        images <- c(hicplot(), comp_plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            image_frame_size = 6,
            title = "",
            style = "height: 100vh;"
            )
    } else {
       print(hicplot())

        texts <- c("HiC")
        hrefs <- c("")
        images <- c(hicplot())

        gallery(
            texts = texts,
            hrefs = hrefs,#hrefs,
            images = images,
            #enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            #enlarge_method = "modal",
            style = "height: 100vh;"
            )

    }
    
}) %>% shiny::bindEvent(input$generate_hic)