# Update dropdown with all possible sequential
# matplotlib colormaps
observe({
    updateSelectizeInput(
        session, "map_colour",
        choices = matplot_colors(),
        selected = "JuiceBoxLike",
        server = TRUE
        )

    updateSelectizeInput(
        session, "chip_cmap",
        choices = matplot_colors(),
        selected = "JuiceBoxLike",
        server = TRUE
        )
})

# redname reactivevalue
rname <- reactiveValues(n = "Chip 1")
observe(
    if (!input$chip1) {
        rname$n <- "ChIP 1"
    } else {
        rname$n <- input$n1
    }
)


# bluename reactivevalue
bname <- reactiveValues(n = "ChIP 2")
observe(
    if (!input$chip2) {
        bname$n <- "ChIP 2"
    } else {
        bname$n <- input$n2
    }
)

# Update chromsome list
observe(
    updateSelectizeInput(session, "chr",
        choices = HiCmetadata()$chrs)
)

# Update resolution list
observe(
    updateSelectizeInput(session, "bin",
        choices = HiCmetadata()$res,
        selected = "10000")
)