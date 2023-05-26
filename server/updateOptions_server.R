# Update dropdown with all possible sequential
# matplotlib colormaps
observe({
    updateSelectizeInput(
        session, "map_colour",
        choices = matplot_colors(),
        selected = "YlOrRd",
        server = TRUE
        )
})

# bluename reactivevalue
bname <- reactiveValues(n = "NULL")
observe(
    if (!input$chip2) {
        bname$n <- "NULL"
    } else {
        bname$n <- input$n2
    }
)