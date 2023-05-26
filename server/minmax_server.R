# min max reactivevalue (global variable)
minmax <- reactiveValues()
observe(
    if (input$setminmax){
        minmax$min = as.numeric(input$min)
        minmax$max = as.numeric(input$max)
    }else if (!input$setminmax) {
        minmax$min = minmax_ChIP1()$min
        minmax$max = minmax_ChIP1()$max
    }
) %>% bindEvent(input$generate_hic, ignoreInit = TRUE)

# min max2 reactivevalue (global variable)
minmax2 <- reactiveValues()
observe(
    if (input$setminmax2) {
        minmax2$min=as.numeric(input$min2)
        minmax2$max=as.numeric(input$max2)
    }else if (!input$setminmax2) {
        minmax2$min = minmax_ChIP2()$min
        minmax2$max = minmax_ChIP2()$max
    }
) %>% bindEvent(input$generate_hic, ignoreInit = TRUE)

minmax_ChIP1 <- reactive({

    req(input$chip1)

    validate(need(!rlang::is_empty(p1v$y) & !input$setminmax, "Please enter values for min/max or upload a bed file"))

    minmaxObject <- calc_peak_minmax(
        bigwig = bw1v$y,
        peaks = p1v$y,
        binsize = input$bin)

    min <- tuple(minmaxObject, convert = T)[0]
    max <- tuple(minmaxObject, convert = T)[1]

    return(list(
        min = min,
        max = max
    ))
}) %>% shiny::bindEvent(input$generate_hic, input$chip1)

minmax_ChIP2 <- reactive({

    req(input$chip2)

    validate(need(!rlang::is_empty(p2v$y) & !input$setminmax2, "Please enter values for min/max or upload a bed file"))

    minmaxObject <- calc_peak_minmax(
        bigwig = bw2v$y,
        peaks = p2v$y,
        binsize = input$bin)

    min <- tuple(minmaxObject, convert = T)[0]
    max <- tuple(minmaxObject, convert = T)[1]

    return(list(
        min = min,
        max = max
    ))
}) %>% shiny::bindEvent(input$generate_hic, input$chip2)
