## Dynamically show/hide 'bigwig 2 tab'
observeEvent(input$bw2check, {
    if (isTRUE(input$bw2check)) {
        shiny::showTab(
            inputId = "parameters",
            target = "Bigwig 2"
        )
    } else {
        shiny::hideTab(
            inputId = "parameters",
            target = "Bigwig 2"
        )
    }
})
