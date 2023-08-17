# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    # Initialise with HiC data
    texts <- c("HiC")
    images <- c(paste0(hicplot(), ".svg"))
    hrefs <- c("")

    # Control inclusion through checkbox
    if(input$chip1){
        # Dynamically add chip data
        for(i in seq_along(reactiveValuesToList(bw1v))){
            texts[i+1] <- input[[paste0("n", i)]]
            hrefs = append(hrefs, "")
            images[i+1] <- paste0(chipplot()[i], ".svg")
        }
        if(length(combinedchips$chips) > 1){
            combname <- "" 
            for(i in combinedchips$chips){
                combname = paste0(combname, input[[paste0("n", i)]]) 
            }
            combhref = ""
            combimage = paste0(chipcombinedplot(), ".svg")

            texts = append(texts, combname)
            hrefs = append(hrefs, combhref)
            images = append(images, combimage)
        }
    }

    if(input$bedgraph){
        #add begraph to texts, hrefs, images
        texts = append(texts, "Combination")
        hrefs = append(hrefs, "")
        images = append(images, paste0(comp_plot(), ".svg"))
    }

    gallery(
        texts = texts,
        hrefs = hrefs,
        images = images,
        image_frame_size = 4,
        title = "",
        style = "height: 100vh;"
        )
    
}) %>% shiny::bindEvent(input$generate_hic)