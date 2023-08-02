# Place generated files in a zip folder

zipfolder <- reactive({

    req(hicv$y)

    zipfile = "imagesZip.zip"

    #remove existing images zip if exists
    if(file.exists(zipfile)){
        file.remove(zipfile)
    }

    files = c()

    files = append(files, paste("www/", hicplot(), ".svg", sep = "") )
    files = append(files, paste("www/", hicplot(), ".png", sep = "") )

    # Control inclusion through checkbox
    if(input$chip1){
        # Dynamically add chip data
        for(i in seq_along(reactiveValuesToList(bw1v))){
            files = append(
              files, paste("www/", chipplot()[i], ".svg", sep = "")
              )
            files = append(
              files, paste("www/", chipplot()[i], ".png", sep = "")
              )
        }
        if(length(combinedchips$chips) > 1){
            combname <- "" 
              files = append(
                files, paste("www/",chipcombinedplot(), ".svg", sep = "")
              )
              files = append(
                files, paste("www/",chipcombinedplot(), ".png", sep = "")
              )
        }
    }

    if(input$bedgraph){
      files = append(
                files, paste("www/",comp_plot(), ".svg", sep="")
              )
      files = append(
                files, paste("www/",comp_plot(), ".png", sep="")
              )
    }

    print(paste0("FILES: ",files))

    zip(zipfile = zipfile, files = files, mode = "cherry-pick")

    return(zipfile)
}) %>% shiny::bindEvent(input$generate_hic, input$downloadtree)



output$downloadtree <- downloadHandler(

  filename = function() {
    paste(zipfolder())
  },

  content = function(file) {
    file.copy(zipfolder(), file)
  },
  contentType = "application/zip"
) %>% shiny::bindEvent(input$generate_hic, input$downloadtree)


observeEvent(input$generate_hic, {
    if (input$generate_hic)
      shinyjs::show("downloadtree")
    else
      shinyjs::hide("downloadtree")
  })