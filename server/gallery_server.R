# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({
    print('gallery')

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(input$chip2){

        if(input$bedgraph){

            texts <- c("HiC", rname$n, bname$n, paste0(rname$n,' + ', bname$n), "Compartments")
            hrefs <- c("","","","","")
            images <- c(
                paste(hicplot(), ".svg", sep=""),
                paste(p1plot(), ".svg", sep=""),
                paste(p2plot(),  ".svg", sep=""),
                paste(p1and2plot(), ".svg", sep=""),
                paste(comp_plot(), ".svg", sep="")
                )

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

        } else{
            texts <- c("HiC", rname$n, bname$n, paste0(rname$n,' + ', bname$n))
            hrefs <- c("","","","")
            images <- c(
                paste(hicplot(), ".svg", sep=""),
                paste(p1plot(), ".svg", sep=""),
                paste(p2plot(),  ".svg", sep=""),
                paste(p1and2plot(), ".svg", sep="")
                )

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
        }

        
    }else if (input$chip1) {

        if(input$bedgraph){
            texts <- c("HiC", rname$n, "Compartments")
            hrefs <- c("","","")
            images <- c(
                paste(hicplot(), ".svg", sep=""),
                paste(p1plot(), ".svg", sep=""),
                paste(compplot(), ".svg", sep="")
            )

            gallery(
                texts = texts,
                hrefs = hrefs,
                images = images,
                #enlarge = TRUE,
                image_frame_size = 4,
                title = "",
                #enlarge_method = "modal",
                style = "height: 100vh;"
                )
        } else{
            texts <- c("HiC", rname$n)
            hrefs <- c("","")
            images <- c(
                paste(hicplot(), ".svg", sep=""),
                paste(p1plot(), ".svg", sep="") 
                )

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
        }

        
    } else {
        if(input$bedgraph){
            texts <- c("HiC", "Compartments")
            hrefs <- c("", "")
            images <- c(
                paste(hicplot(), ".svg", sep=""),
                paste(compplot(), ".svg", sep="")
            )

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
        } else {
            texts <- c("HiC")
            hrefs <- c("")
            images <- c(
                paste(hicplot(), ".svg", sep="")
            )

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
    }
    
}) %>% shiny::bindEvent(input$generate_hic)