
cols <- reactive({
    lapply(seq_along(reactiveValuesToList(bw1v)), function(x){
        div(
        fluidRow(
            # Update in server to the basename minus the suffix
            column(4,
                textInput(paste("n", LETTERS[x], sep="_"), 
                          label = "Name", 
                          value = paste('ChIP', x))
            ),
            column(4,
                colourInput(paste("col", LETTERS[x], sep="_"), 
                            "Select colour", 
                            "blue")
            ),
            column(4,
                checkboxInput(paste("comb", LETTERS[x], sep="_"),
                              "Combination")
                )
    )
    )
    })

})


output$chipUI <- renderUI({cols()})