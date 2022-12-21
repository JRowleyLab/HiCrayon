source("global.R")

reticulate::source_python("test.py")
reticulate::source_python("python/functions.py")

ui <- shinyUI({
  source("ui.R")[1] # [1] prevents "TRUE" from being printed to browser
})
  
server <- function(input, output, session) {
  source("server.R", local=TRUE)
}

shinyApp(ui, server)
