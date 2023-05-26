source("global.R")

reticulate::source_python("python/functions.py")

ui <- shinyUI({
  source("ui/ui.R")[1] # [1] prevents "TRUE" from being printed to browser
})
  
server <- function(input, output, session) {
  source("server/fileChoose_server.R", local=TRUE)
  source("server/calcDistance_server.R", local=TRUE)
  source("server/minmax_server.R", local=TRUE)
  source("server/processBigwigs_server.R", local=TRUE)
  source("server/plotting_server.R", local=TRUE)
  source("server/readHiCmatrix_server.R", local=TRUE)
  source("server/updateOptions_server.R", local=TRUE)
}

shinyApp(ui, server)
