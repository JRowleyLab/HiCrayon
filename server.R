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
    if (input$bw2check) {
        inFile <- parseFilePaths(roots = c(wd = workingdir), input$bw2)
        bw2v$y <- inFile$datapath
    }else {
        bw2v$y <- "NULL"
    }
)

# min max reactivevalue (global variable)
minmax <- reactiveValues(min = "NULL", max = "NULL")
observe(
    if (input$setminmax){
        minmax$min=as.numeric(input$min)
        minmax$max=as.numeric(input$max)
    }else {
        minmax$min="NULL"
        minmax$min="NULL"
    }
)

# min max2 reactivevalue (global variable)
minmax2 <- reactiveValues(min = "NULL", max = "NULL")
observe(
    if (input$setminmax2) {
        minmax2$min=as.numeric(input$min2)
        minmax2$max=as.numeric(input$max2)
    }else {
        minmax2$min="NULL"
        minmax2$min="NULL"
    }
)

# bluename reactivevalue
bname <- reactiveValues(n = "NULL")
observe(
    if (!input$bw2check) {
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
    matrix <- readHiCasNumpy(
        hicfile = hicv$y,
        chrom = input$chr,
        start = input$start,
        stop = input$stop,
        norm = input$norm,
        binsize = input$bin
    )

    return(matrix)
}) %>% shiny::bindEvent(input$HiC_check,
                        input$generate_hic)



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
# }) %>% bindEvent(input$generate_hic, input$HiC_check)
# ################################################
# ################################################


# Step through bigwig file and
# record bigwig value for each
# binsize across selected genomic
# region
bwlist <- reactive({
    bwlist <- processBigwigs(
        bigwig = bw1v$y,
        binsize = input$bin,
        chrom = input$chr,
        start = input$start,
        stop = input$stop
        )

    return(bwlist)
}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check) # %>% shiny::bindEvent(input$run)


# Calulate ...
distance <- reactive({
    distObject <- distanceMat(
             hicnumpy=HiCmatrix(),
             mymin=input$min,
             mymax=input$max,
             bwlist=bwlist(),
             thresh=input$thresh
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
}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check) # %>% shiny::bindEvent(input$run)


hic_distance <- reactive({
    distnormmat <- distanceMatHiC(
                    hicnumpy = HiCmatrix(),
                    thresh = input$thresh
                )

    return(distnormmat)

}) %>% shiny::bindEvent(input$generate_hic)


hicplot <- reactive({
    hic_plot(REDMAP = input$map_colour,
             thresh = input$thresh,
             distnormmat = hic_distance()
             )
}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check)




p1plot <- reactive({
    p1_plot <- p1_plot(
        hicmatrix = hic_distance(),
        rmat = distance()$rmat,
        gmat = distance()$gmat,
        bmat = distance()$bmat,
        bwlist = distance()$bwlist_norm,
        cmap = input$p1_cmap,
        alpha = input$alpha)

}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check) #%>% shiny::bindEvent(input$run)


# Gallery function  that takes
# local images to display.
# Local images are generated using
# python functions.
output$gallery <- renderUI({

    validate(need(input$hic, "Please upload a HiC file"))

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
        title = "HiCrayon Image Overlay",
        enlarge_method = "modal"
        )
}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check)


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

