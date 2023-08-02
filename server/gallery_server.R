# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    print('gallery')

    # Initialise with HiC data
    texts <- c("HiC")
    images <- c(paste(hicplot(), ".svg", sep=""))
    hrefs <- c("")

    # Control inclusion through checkbox
    if(input$chip1){
        # Dynamically add chip data
        for(i in seq_along(reactiveValuesToList(bw1v))){
            texts[i+1] <- input[[paste("n", LETTERS[i], sep = "_")]]
            hrefs = append(hrefs, "")
            images[i+1] <- paste(chipplot()[i], ".svg", sep="")
        }
        if(length(combinedchips$chips) > 1){
            combname <- "" 
            for(i in combinedchips$chips){
                combname = paste(combname, input[[paste("n", LETTERS[i], sep = "_")]], sep = " ") 
            }
            combhref = ""
            combimage = paste(chipcombinedplot(), ".svg", sep="")

            texts = append(texts, combname)
            hrefs = append(hrefs, combhref)
            images = append(images, combimage)
        }
    }

    if(input$bedgraph){
        #add begraph to texts, hrefs, images
        texts = append(texts, "Combination")
        hrefs = append(hrefs, "")
        images = append(images, paste(comp_plot(), ".svg", sep=""))
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