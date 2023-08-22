# Place generated files in a zip folder

zipfolder <- reactive({

    req(hicv$y)

    zipfile = paste0(userinfo, "/imagesZip.zip")

    files = c()

    files = append(files, hicplot()$svg)
    files = append(files, hicplot()$png)

    # Control inclusion through checkbox
    if(input$chip1){
        # Dynamically add chip data
        for(i in seq_along(reactiveValuesToList(bw1v))){

          if(!is.null(bw1v[[paste0("bw",i)]])){
            files = append(
              files, chipplot()[[i]]$svg
              )
            files = append(
              files, chipplot()[[i]]$png
              )
          }
        }
        if(length(combinedchips$chips) > 1){
            combname <- "" 
              files = append(
                files, chipcombinedplot()$svg
              )
              files = append(
                files, chipcombinedplot()$png
              )
        }
    }

    if(input$bedgraph){
      files = append(
                files, comp_plot()$svg
              )
      files = append(
                files, comp_plot()$png
              )
    }

    zip(zipfile = zipfile, files = files, mode = "cherry-pick")

    return(zipfile)
}) 



output$downloadtree <- downloadHandler(

  filename = function() {
    paste("HiCrayonImages.zip")
  },

  content = function(file) {
    file.copy(zipfolder(), file)
  },
  contentType = "application/zip"
) 


observeEvent(input$generate_hic, {
    if (input$generate_hic)
      shinyjs::show("downloadtree")
    else
      shinyjs::hide("downloadtree")
  })