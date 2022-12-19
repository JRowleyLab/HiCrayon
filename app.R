source("global.R")

reticulate::source_python("test.py")
reticulate::source_python("python/functions.py")

ui <- shinyUI({
  source("ui.R")[1] # [1] prevents "TRUE" from being printed to browser
})
  
# Load in Python functions
#source_python('python_ref.py')

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  source("server.R", local=TRUE)
}

shinyApp(ui, server)