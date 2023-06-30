# Place generated files in a zip folder

zipfolder <- reactive({

    req(hicv$y)

    zipfile = "imagesZip.zip"

    #remove existing images zip if exists
    if(file.exists(zipfile)){
        file.remove(zipfile)
    }

    files = c(paste("www/", hicplot(), sep = ""))

    if(input$chip1){ 
        files = append(files, paste("www/", p1plot(), sep = ""))
        }
    if(input$chip2){ 
        files = append(files, paste("www/", p2plot(), sep = ""))
        files = append(files, paste("www/", p1and2plot(), sep = ""))
        }
    if(input$bedgraph){
      files = append(files, paste("www/", comp_plot(), sep = ""))
    }

    print(files)

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