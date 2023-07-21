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

# ChIP names reactivevalue
chipnames <- reactiveValues()
observe({
    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        if(!is.null(bw1v[[LETTERS[x]]])){
        updateTextInput(
            session,
            inputId = paste("n", LETTERS[x], sep = "_"),
            value = tools::file_path_sans_ext(basename(bw1v[[LETTERS[x]]])
        )
    )
    }

    })
    
})

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