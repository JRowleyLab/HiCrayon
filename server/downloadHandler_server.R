# Place generated files in a zip folder

zipfolder <- reactive({

    req(hicv$y)

    files = c(hic_plot())

    if(input$chip1){ 
        files = files.append(p1plot())
        }
    if(input$chip2){ 
        files = files.append(p2plot())
        files = files.append(p2plot())
        }

    zip(zipfile = 'www/images/imagesZip', files = files)
    zipfile = 'www/images/imagesZip'

    return('www/images/imagesZip')
}) %>% shiny::bindEvent(input$generate_hic, input$downloadtree)



output$downloadtree <- downloadHandler(
            filename <- function(file) { zipfolder() },
            content <- function(file) {
            file.copy(zipfolder(), file)
            }
    )