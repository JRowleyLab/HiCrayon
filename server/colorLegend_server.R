####################################
# dynamically create euler plot
####################################
outputLegend <- function(colors, labels){
    # Given a vector of colors selected for 
    # combination, return a venn diagram of 
    # rgb linear interpolation color intersects
    #list of colour combination
    generate_color_combinations <- function(colors) {
        combinations <- c()
        for (i in 1:length(colors)) {
            if(i==1){
                combinations <- c(combinations, unlist(combn(colors, i, simplify = FALSE)))
            }else {
            combination <- combn(colors, i, simplify = FALSE)
            for(num in 1:length(combination)) {
                combinations <- c(combinations, paste(unlist(combination[num]), collapse = "&"))
            }
            }
        }
        return(combinations)
    }

    generate_label_combinations <- function(colors) {
        combinations <- c()
        colnums = seq(length(colors))
        for (i in 1:length(colnums)) {
            if(i==1){
                combinations <- c(combinations, unlist(combn(colnums, i, simplify = FALSE)))
            }else {
            combination <- combn(colnums, i, simplify = FALSE)
            for(num in 1:length(combination)) {
                combinations <- c(combinations, paste(unlist(combination[num]), collapse = "&"))
            }
            }
        }
        return(combinations)
    }

    # calculate hex from rgb
    rgb2hex <- function(rgb) rgb(rgb[1], rgb[2], rgb[3], maxColorValue = 255)

    combinations <- generate_color_combinations(colors)
    valnames <- generate_label_combinations(colors)

    fills <- c()
    for(i in 1:length(combinations)){
        cols <- unlist(strsplit(combinations[i], "&"))
        if(length(cols)==1){
            fills <- c(fills, cols)
        }else{
            fills <- c(fills, rgb2hex(rowMeans(col2rgb(cols))))
        }
    }

    vals <- rep(1, length(combinations))
    names(vals) <- valnames
    
    plot(euler(vals), fill = fills, labels = labels)
}

output$colorlegend <- renderPlot({
    # for the combined chips, display 
    # color legend
    chipstocombine <- combinedchips$chips

    req(length(chipstocombine)>1)

    cols <- c()
    names <- c()
    for(x in seq_along(chipstocombine)){
        cols <- append(cols, input[[paste0("col", chipstocombine[x])]])
        names <- append(names, input[[paste0("n", chipstocombine[x])]])
    }

    # make venn diagram of colour combinations
    outputLegend(cols, names)
})