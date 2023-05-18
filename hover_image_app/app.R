# app.R

library(shiny)

# Define UI
ui <- shinyUI(fluidPage(
  titlePanel("Hover Lines Example"),
  sidebarLayout(
    sidebarPanel(
      selectInput("image", "Select Image:", choices = c("HiCrayon.svg"))
    ),
    mainPanel(
      uiOutput("svgOutput")
    )
  )
))

# Define Server
server <- shinyServer(function(input, output, session) {
  # Render SVG image
  output$svgOutput <- renderUI({
    includeHTML(paste0("www/", input$image))
  })

  # Send custom message to create hover lines
  observeEvent(input$image, {
    session$sendCustomMessage(type = "createHoverLines", message = list(svgId = "svgOutput"))
  })
})

# Run the Shiny app
shinyApp(ui = ui, server = server)
