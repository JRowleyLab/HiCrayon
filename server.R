
# variable for starting root directory
workingdir = '/Zulu/bnolan/HiC_data'

## Server side file-selection
shinyFileChoose(input, 'hic', root = c(wd = workingdir))
shinyFileChoose(input, "p1", root = c(wd = workingdir))
shinyFileChoose(input, "bw1", root = c(wd = workingdir))
shinyFileChoose(input, "p2", root = c(wd = workingdir))
shinyFileChoose(input, "bw2", root = c(wd = workingdir))

###############################
## display path for shinyFileChoose
###############################

## print path to textbox with verbatimTextOutput
output$f1_hic <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$hic[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$hic)
    as.character(x$datapath[1])
}
})

output$f1_bw1 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$bw1[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$bw1)
    as.character(x$datapath[1])
}
})

output$f1_p1 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$p1[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$p1)
    as.character(x$datapath[1])
}
})

output$f1_bw2 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$bw2[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$bw2)
    as.character(x$datapath[1])
}
})

output$f1_p2 <- renderPrint({
    #cat("text")
    #print(input$hic)
if (is.integer(input$p2[1])) {
    cat("No file has been selected")
} else {
    x <- parseFilePaths(roots = c(wd = workingdir), input$p2)
    as.character(x$datapath[1])
}
})

# hic file handling
hicv <- reactiveValues(y = "NULL")
observeEvent(input$hic, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$hic)
    hicv$y <- inFile$datapath
})
# p1 file handling
p1v <- reactiveValues(y = "NULL")
observe({
    if(!input$setminmax){
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$p1)
        p1v$y <- inFile$datapath
    }else {
        p1v$y <- "NULL"
    }
})

# bw1 file handling
bw1v <- reactiveValues(y = "NULL")
observeEvent(input$bw1, {
    inFile <- parseFilePaths(roots = c(wd = workingdir), input$bw1)
    bw1v$y <- inFile$datapath
})

# p2 file handling
p2v <- reactiveValues(y = "NULL")
observe({
    if(!input$setminmax2){
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$p2)
        p2v$y <- inFile$datapath
    }else{
        p2v$y <- "NULL"
    }
})
# bw2 file handling
bw2v <- reactiveValues(y = "NULL")
observe(
    if (input$chip2) {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$bw2)
        bw2v$y <- inFile$datapath
    }else {
        bw2v$y <- "NULL"
    }
)

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
) 

# bluename reactivevalue
bname <- reactiveValues(n = "NULL")
observe(
    if (!input$chip2) {
        bname$n <- "NULL"
    } else {
        bname$n <- input$n2
    }
)

##################
# Based on the conditional button input$yes,
# run HiCmatrix. how to do this
######################

HiCmatrix <- reactive({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    matrix <- readHiCasNumpy(
        hicfile = hicv$y,
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = input$bin
    )

    return(matrix)
}) %>% shiny::bindEvent(input$generate_hic)



# ################################################
# ################################################
# # WORK IN PROGRESS;
# # TO CATCH SEGMENTATION FAULTS BY OFFERING
# # MODAL POPUP IF MATRIX SIZE IS TOO BIG
# matsize <- reactiveValues()

# observe({
#     matsize$size <- (input$stop - input$start) / input$bin
# })

# observeEvent(input$yes, {
#     removeModal()
#   })

# observe({
#     # is matrix too big?
#     if( matsize$size > 1200 ){
#         showModal(modalDialog(
#         title = "WARNING",
#         "MATRIX SIZE IS LARGE:
#         POTENTIAL SEGMENTATION FAULT.
#         (the app will crash and must be 
#         refreshed).
        
#         Do you want to proceed?",
#         easyClose = TRUE,
#         footer = tagList(
#           actionButton("yes", "Yes"),
#           modalButton("No")
#         )
#         ))
#     } 
# }) %>% bindEvent(input$generate_hic)
# ################################################
# ################################################


# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP1 <- reactive({

    validate(need(bw1v$y!="NULL", "Please upload a bigwig file"))

    bwlist <- processBigwigs(
        bigwig = bw1v$y,
        binsize = input$bin,
        chrom = input$chr,
        start = input$start,
        stop = input$stop
        )

    return(bwlist)
}) %>% shiny::bindEvent(input$generate_hic)


# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist_ChIP2 <- reactive({

    validate(need(bw2v$y!="NULL", "Please upload a bigwig file"))

    bwlist <- processBigwigs(
        bigwig = bw2v$y,
        binsize = input$bin,
        chrom = input$chr,
        start = input$start,
        stop = input$stop
        )

    return(bwlist)
}) %>% shiny::bindEvent(input$generate_hic)

minmax_ChIP1 <- reactive({

    print(minmax$min)
    print(minmax$max)

    validate(need(minmax$min!="NULL", "Please enter values for min/max or upload a bed file"))
    validate(need(minmax$max!="NULL", "Please enter values for min/max or upload a bed file"))

    validate(need(p1v$y!="NULL", "Please enter values for min/max or upload a bed file"))

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

    print(minmax2$min)
    print(minmax2$max)

    validate(need(minmax2$min!="NULL", "Please enter values for min/max or upload a bed file"))
    validate(need(minmax2$max!="NULL", "Please enter values for min/max or upload a bed file"))

    validate(need(p2v$y!="NULL", "Please enter values for min/max or upload a bed file"))

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

# Calulate ...
distance_ChIP1 <- reactive({

    validate(need(minmax$min!="NULL", "Please enter values for min/max or upload a bed file"))
    validate(need(minmax$max!="NULL", "Please enter values for min/max or upload a bed file"))


    distObject <- distanceMat(
             hicnumpy=HiCmatrix(),
             mymin=minmax$min,
             mymax=minmax$max,
             bwlist=bwlist_ChIP1(),
             #thresh=input$thresh,
             strength=input$strength,
             sample = "ChIP1"
             )

    rmat <- tuple(distObject, convert=T)[0]
    gmat <- tuple(distObject, convert=T)[1]
    bmat <- tuple(distObject, convert=T)[2]
    bwlist_norm <- tuple(distObject, convert=T)[3]

    return(list(
        rmat=rmat,
        gmat=gmat,
        bmat=bmat,
        bwlist_norm=bwlist_norm
    ))
}) %>% shiny::bindEvent(input$generate_hic)

distance_ChIP2 <- reactive({

    validate(need(minmax2$min!="NULL", "Please enter values for min/max or upload a bed file"))
    validate(need(minmax2$max!="NULL", "Please enter values for min/max or upload a bed file"))


    distObject <- distanceMat(
             hicnumpy=HiCmatrix(),
             mymin=minmax2$min,
             mymax=minmax2$max,
             bwlist=bwlist_ChIP2(),
             #thresh=input$thresh,
             strength=input$strength2,
             sample = "ChIP2"
             )

    rmat <- tuple(distObject, convert=T)[0]
    gmat <- tuple(distObject, convert=T)[1]
    bmat <- tuple(distObject, convert=T)[2]
    bwlist_norm <- tuple(distObject, convert=T)[3]

    return(list(
        rmat=rmat,
        gmat=gmat,
        bmat=bmat,
        bwlist_norm=bwlist_norm
    ))
}) %>% shiny::bindEvent(input$generate_hic)


hic_distance <- reactive({
    distnormmat <- distanceMatHiC(
                    hicnumpy = HiCmatrix()
                   # thresh = input$thresh
                )

    return(distnormmat)

}) %>% shiny::bindEvent(input$generate_hic)


hicplot <- reactive({
    hic_plot(REDMAP = input$map_colour,
             #thresh = input$thresh,
             distnormmat = hic_distance()
             )
}) %>% shiny::bindEvent(input$generate_hic)


p1plot <- reactive({
    p1_plot <- ChIP_plot(
        hicmatrix = hic_distance(),
        rmat = distance_ChIP1()$rmat,
        gmat = distance_ChIP1()$gmat,
        bmat = distance_ChIP1()$bmat,
        bwlist = distance_ChIP1()$bwlist_norm,
        bwlist2 = "NULL",
        hicalpha = input$hicalpha,
        bedalpha = input$bedalpha,
        #thresh = input$thresh2,
        opacity = input$opacity,
        sample = "ChIP1"
        )

}) %>% shiny::bindEvent(input$generate_hic) 


p2plot <- reactive({
    p2_plot <- ChIP_plot(
        hicmatrix = hic_distance(),
        rmat = distance_ChIP2()$rmat,
        gmat = distance_ChIP2()$gmat,
        bmat = distance_ChIP2()$bmat,
        bwlist = distance_ChIP2()$bwlist_norm,
        bwlist2 = "NULL",
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        #thresh = input$thresh2,
        opacity = input$opacity2,
        sample = "ChIP2"
        )

}) %>% shiny::bindEvent(input$generate_hic) 


p1and2plot <- reactive({
    # Combine ChIP data from protein 1
    # and protein 2
    p2_plot <- ChIP_plot(
        hicmatrix = hic_distance(),
        rmat = distance_ChIP1()$rmat,
        gmat = distance_ChIP2()$gmat,
        bmat = distance_ChIP2()$bmat,
        bwlist = distance_ChIP1()$bwlist_norm,
        bwlist2 = distance_ChIP2()$bwlist_norm,
        hicalpha = input$hicalpha2,
        bedalpha = input$bedalpha2,
        #thresh = input$thresh2,
        opacity = input$opacity2,
        sample = "ChIP_combined"
        )

}) %>% shiny::bindEvent(input$generate_hic) 

# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({

    validate(need(hicv$y!="NULL", "Please upload a HiC file"))

    if(input$chip2){
        print(hicplot())

        texts <- c("HiC", "CTCF", "RAD21", "CTCF + RAD21")
        hrefs <- c(hicplot(), p1plot(), p2plot(), p1and2plot())
        images <- c(hicplot(), p1plot(), p2plot(), p1and2plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    }else if (input$chip1) {
       print(hicplot())

        texts <- c("HiC", "CTCF")
        hrefs <- c(hicplot(), p1plot())
        images <- c(hicplot(), p1plot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    } else {
       print(hicplot())

        texts <- c("HiC")
        hrefs <- c(hicplot())
        images <- c(hicplot())

        gallery(
            texts = texts,
            hrefs = hrefs,
            images = images,
            enlarge = TRUE,
            image_frame_size = 6,
            title = "",
            enlarge_method = "modal",
            style = "height: 100vh;"
            )
    }
    
}) %>% shiny::bindEvent(input$generate_hic)


# Update dropdown with all possible sequential
# matplotlib colormaps
observe({
    updateSelectizeInput(
        session, "map_colour",
        choices = matplot_colors(),
        selected = "YlOrRd",
        server = TRUE
        )

    updateSelectizeInput(
        session, "p1_cmap",
        choices = matplot_colors(),
        selected = "gray",
        server = TRUE
        )
})

