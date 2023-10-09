####################################
# dynamically create euler plot
####################################
outputLegend <- function(colors){
    # Given a vector of colors selected for 
    # combination, return a venn diagram of 
    # rgb linear interpolation color intersects
    #list of colour combination
    generate_color_combinations <- function(colors) {
    combinations <- c()
    colcomb <- c()
    for (i in 1:length(colors)) {
        if(i==1){
            combinations <- c(combinations, unlist(combn(colors, i, simplify = FALSE)))
        }else {
        combination <- combn(colors, i, simplify = FALSE)
        for(num in 1:length(combination)) {
            #print(combination[num])
            combinations <- c(combinations, paste(unlist(combination[num]), collapse = "&"))
        }
        }
    }
    return(combinations)
    }


    combinations <- generate_color_combinations(colors)

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
    names(vals) <- combinations
    plot(euler(vals), fill = fills)
}

