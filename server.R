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

# Take HiC file from user and output a HiC Matrix using straw
HiCmatrix <- reactive({
    #validate(need(input$hic!="NULL", "Please upload a HiC file"))

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


bwlists <- reactive({

    objectBigWig <- processBigwigs(
            bigwig = bw1v$y,
            min = minmax$min,
            max = minmax$max,
            peaks = p1v$y,
            binsize = input$bin,
            chrom = input$chr,
            start = input$start,
            stop = input$stop,
            bigwig2 = bw2v$y,
            min2 = minmax2$min,
            max2 = minmax2$max,
            peaks2 = p2v$y
        )

    redbwlist <- tuple(objectBigWig, convert=T)[0]
    redbwmax <- tuple(objectBigWig, convert=T)[1]
    redbwmin <- tuple(objectBigWig, convert=T)[2]
    bluebwlist <- tuple(objectBigWig, convert=T)[3]
    bluebwmax <- tuple(objectBigWig, convert=T)[4]
    bluebwmin <- tuple(objectBigWig, convert=T)[5]

    return(list(redbwlist=redbwlist,
                redbwmax=redbwmax,
                redbwmin=redbwmin,
                bluebwlist=bluebwlist,
                bluebwmax=bluebwmax,
                bluebwmin=bluebwmin
                ))
}) %>% shiny::bindEvent(input$run)


# distance <- reactive({
#     distObject <- distanceMat(hicnumpy=HiCmatrix(), 
#              redbwlist=bwlists()$redbwlist, 
#              redbwmax=bwlists()$redbwmax, 
#              redbwmin=bwlists()$redbwmin, 
#              bluebwlist=bwlists()$bluebwlist, 
#              bluebwmax=bwlists()$bluebwmax, 
#              bluebwmin=bwlists()$bluebwmin,
#              thresh=input$thresh)

#     rmat <- tuple(distObject, convert=T)[0]
#     gmat <- tuple(distObject, convert=T)[1]
#     bmat <- tuple(distObject, convert=T)[2]
#     distnormmat <- tuple(distObject, convert=T)[3]
#     rmat2 <- tuple(distObject, convert=T)[4]
#     gmat2 <- tuple(distObject, convert=T)[5]
#     bmat2 <- tuple(distObject, convert=T)[6]
#     redlist <- tuple(distObject, convert=T)[7]
#     bluelist <- tuple(distObject, convert=T)[8]

#     return(list(
#         rmat=rmat,
#         gmat=gmat,
#         bmat=bmat,
#         distnormmat=distnormmat,
#         rmat2=rmat2,
#         gmat2=gmat2,
#         bmat2=bmat2,
#         redlist=redlist,
#         bluelist=bluelist
#     ))
# }) %>% shiny::bindEvent(input$run)


hic_distance <- reactive({
    distnormmat <- distanceMatHiC(
                    hicnumpy = HiCmatrix(),
                    thresh = input$thresh
                )

    return(distnormmat)

}) %>% shiny::bindEvent(input$generate_hic)

# finalPlot <- reactive({
#     #validate(need(HiCmatrix(), "Please Select parameters and select run"))

#     objectPlot <- plotting(rmat=distance()$rmat,
#              gmat=distance()$gmat,
#              bmat=distance()$bmat,
#              distnormmat=distance()$distnormmat,
#              chrom=input$chr,
#              start=input$start,
#              stop=input$stop,
#              rmat2=distance()$rmat2,
#              gmat2=distance()$gmat2,
#              bmat2=distance()$bmat2,
#              redname=input$n1,
#              bluename=bname$n,
#              thresh=input$thresh,
#              redbwmin=bwlists()$redbwmin,
#              redbwmax=bwlists()$redbwmax,
#              bluebwmin=bwlists()$bluebwmin,
#              bluebwmax=bwlists()$bluebwmax,
#              redlist=distance()$redlist,
#              bluelist=distance()$bluelist,
#              overlayoff=input$HiC_check
#              )

#         #redbwmin,redbwmax,bluebwmin,bluebwmax
#         redbwmin <- tuple(objectPlot, convert=T)[0]
#         redbwmax <- tuple(objectPlot, convert=T)[1]
#         bluebwmin <- tuple(objectPlot, convert=T)[2]
#         bluebwmax <- tuple(objectPlot, convert=T)[3]
        

#     return(list(
#         redbwmin=redbwmin,
#         redbwmax=redbwmax,
#         bluebwmin=bluebwmin,
#         bluebwmax=bluebwmax
#     ))
# }) %>% shiny::bindEvent(input$run, input$HiC_check)

# output$colinfo <- renderText({
#     paste(finalPlot())
# }) 


hicplot <- reactive({
    hic_plot(REDMAP = input$map_colour,
             figname = "HiC.svg",
             thresh = input$thresh,
             distnormmat = hic_distance()
             )
}) %>% shiny::bindEvent(input$generate_hic, input$HiC_check)

output$matPlot <- renderImage({

    #### Validation and Error handling

    validate(need(input$hic, "Please upload a HiC file"))

    # validate(need(input$bw1, "Please upload a bigwig file"))
    # if(input$setminmax){
    #     validate(
    #         need(input$min, "Please select a minimum value"),
    #         need(input$max, "Please select a maximum value")
    #         )
    # }else{
    #     validate(need(input$p1, "Please upload a .bed file"))
    # }
    
    # If user selected a second bigwig file checkbox
    # if(input$bw2check){
    #     validate(need(input$bw2!="NULL", "Please upload a bigwig file"))
    #     validate(need(input$p2!="NULL", "Please upload a .bed file"))

    #     if(input$setminmax2){
    #     validate(
    #         need(input$min2, "Please select a minimum value"),
    #         need(input$max2, "Please select a maximum value")
    #         )
    # }else{
    #     validate(need(input$p1, "Please upload a .bed file"))
    # }
# }

hicplot()

    # HiC only SVG image
    list(src = "HiC.svg",
         contentType = "image/svg+xml",
         width = "100%",
         height = "200%"
         )
}, deleteFile = FALSE) %>% shiny::bindEvent(input$generate_hic, input$HiC_check)