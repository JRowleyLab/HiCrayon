# Global variables and modules used with R
source("global.R")

# Call separate UI components
source("ui/gallery_ui.R", local = TRUE)
source("ui/selectHiCoptions_ui.R", local = TRUE)
source("ui/chiponeOptions_ui.R", local = TRUE)
source("ui/chiptwoOptions_ui.R", local = TRUE)
source("radiobuttonswithimages.R", local = TRUE)


reticulate::source_python("python/functions.py")

ui <- shinyUI({
  #source("ui/ui.R", local = TRUE)[1]
  source("ui/ui_shinydashboard.R", local = TRUE)[1]
})

server <- function(input, output, session) {
  source("server/fileChoose_server.R", local = TRUE)
  source("server/calcDistance_server.R", local = TRUE)
  source("server/processBigwigs_server.R", local = TRUE)
  source("server/plotting_server.R", local = TRUE)
  source("server/readHiCmatrix_server.R", local = TRUE)
  source("server/updateOptions_server.R", local = TRUE)
  source("server/downloadHandler_server.R", local = TRUE)
}

shinyApp(ui, server)
