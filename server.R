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


## Server side file-selection
shinyFileChoose(input, "hic", root = c(wd = ".."))
shinyFileChoose(input, "p1", root = c(wd = ".."))
shinyFileChoose(input, "bw1", root = c(wd = ".."))
shinyFileChoose(input, "p2", root = c(wd = ".."))
shinyFileChoose(input, "bw2", root = c(wd = ".."))

# hic file handling
hicv <- reactiveValues(y = NULL)
observeEvent(input$hic, {
    inFile <- parseFilePaths(roots = c(wd = ".."), input$hic)
    hicv$y <- inFile$datapath
})
# p1 file handling
p1v <- reactiveValues(y = NULL)
observeEvent(input$p1, {
    inFile <- parseFilePaths(roots = c(wd = ".."), input$p1)
    p1v$y <- inFile$datapath
})
# Bigwig 1 file handling
bw1v <- reactiveValues(y = NULL)
observeEvent(input$bw1, {
    inFile <- parseFilePaths(roots = c(wd = ".."), input$bw1)
    bw1v$y <- inFile$datapath
})
# p2 file handling
p2v <- reactiveValues(y = NULL)
observeEvent(input$p2, {
    inFile <- parseFilePaths(roots = c(wd = ".."), input$p2)
    p2v$y <- inFile$datapath
})
# bw1 file handling
bw2v <- reactiveValues(y = NULL)
observeEvent(input$bw2, {
    inFile <- parseFilePaths(roots = c(wd = ".."), input$bw2)
    bw2v$y <- inFile$datapath
})

#### Functional
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
}) %>% shiny::bindEvent(input$run)


# Functional
bwlists <- reactive({
    objectBigWig <- processBigwigs(
            bigwig = bw1v$y,
            min = "NULL",
            max = "NULL",
            peaks = p1v$y,
            binsize = input$bin,
            chrom = input$chr,
            start = input$start,
            stop = input$stop,
            bigwig2 = bw2v$y,
            min2 = "NULL",
            max2 = "NULL",
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
}) 


distance <- reactive({
    distObject <- distanceMat(hicnumpy=HiCmatrix(), 
             redbwlist=bwlists()$redbwlist, 
             redbwmax=bwlists()$redbwmax, 
             redbwmin=bwlists()$redbwmin, 
             bluebwlist=bwlists()$bluebwlist, 
             bluebwmax=bwlists()$bluebwmax, 
             bluebwmin=bwlists()$bluebwmin,
             thresh=input$thresh)

    rmat <- tuple(distObject, convert=T)[0]
    gmat <- tuple(distObject, convert=T)[1]
    bmat <- tuple(distObject, convert=T)[2]
    distnormmat <- tuple(distObject, convert=T)[3]
    rmat2 <- tuple(distObject, convert=T)[4]
    gmat2 <- tuple(distObject, convert=T)[5]
    bmat2 <- tuple(distObject, convert=T)[6]
    redlist <- tuple(distObject, convert=T)[7]
    bluelist <- tuple(distObject, convert=T)[8]

    return(list(
        rmat=rmat,
        gmat=gmat,
        bmat=bmat,
        distnormmat=distnormmat,
        rmat2=rmat2,
        gmat2=gmat2,
        bmat2=bmat2,
        redlist=redlist,
        bluelist=bluelist
    ))
}) 

finalPlot <- reactive({
    validate(need(HiCmatrix(), "Please Select parameters and select run"))

    objectPlot <- plotting(rmat=distance()$rmat,
             gmat=distance()$gmat,
             bmat=distance()$bmat,
             distnormmat=distance()$distnormmat,
             chrom=input$chr,
             start=input$start,
             stop=input$stop,
             rmat2=distance()$rmat2,
             gmat2=distance()$gmat2,
             bmat2=distance()$bmat2,
             redname=input$n1,
             bluename=input$n2,
             thresh=input$thresh,
             redbwmin=bwlists()$redbwmin,
             redbwmax=bwlists()$redbwmax,
             bluebwmin=bwlists()$bluebwmin,
             bluebwmax=bwlists()$bluebwmax,
             redlist=distance()$redlist,
             bluelist=distance()$bluelist,
             overlayoff=input$HiC_check
             )

    redinfo <- tuple(objectPlot, convert=T)[0]
    blueinfo <- tuple(objectPlot, convert=T)[1]

    return(list(
        redinfo=redinfo,
        blueinfo=blueinfo
    ))
    
}) 

output$colinfo <- renderText({
    paste(finalPlot()$redinfo,"\n",finalPlot()$blueinfo)
})

output$matPlot <- renderImage({
     finalPlot()
     list(src = 'plot.png', width = "100%", height = "100%")
   }, deleteFile = FALSE)

