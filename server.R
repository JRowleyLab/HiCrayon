## Dynamically show/hide 'bigwig 2 tab'
observeEvent(input$bigwig2check, {
    if (isTRUE(input$bigwig2check)) {
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
