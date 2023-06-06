# # Calulate ...
# distance_ChIP1 <- reactive({

#     req(input$chip1)

#     validate(need(minmax$min!="NULL", "Please enter values for min/max or upload a bed file"))
#     validate(need(minmax$max!="NULL", "Please enter values for min/max or upload a bed file"))


#     distObject <- distanceMat(
#              hicnumpy=HiCmatrix(),
#              mymin=minmax$min,
#              mymax=minmax$max,
#              bwlist=bwlist_ChIP1(),
#              #thresh=input$thresh,
#              strength=input$strength,
#              sample = "ChIP1"
#              )

#     rmat <- tuple(distObject, convert=T)[0]
#     gmat <- tuple(distObject, convert=T)[1]
#     bmat <- tuple(distObject, convert=T)[2]
#     bwlist_norm <- tuple(distObject, convert=T)[3]

#     return(list(
#         rmat=rmat,
#         gmat=gmat,
#         bmat=bmat,
#         bwlist_norm=bwlist_norm
#     ))
# }) %>% shiny::bindEvent(input$generate_hic, input$chip1)

# distance_ChIP2 <- reactive({

#     req(input$chip2)

#     validate(need(minmax2$min!="NULL", "Please enter values for min/max or upload a bed file"))
#     validate(need(minmax2$max!="NULL", "Please enter values for min/max or upload a bed file"))


#     distObject <- distanceMat(
#              hicnumpy=HiCmatrix(),
#              mymin=minmax2$min,
#              mymax=minmax2$max,
#              bwlist=bwlist_ChIP2(),
#              #thresh=input$thresh,
#              strength=input$strength2,
#              sample = "ChIP2"
#              )

#     rmat <- tuple(distObject, convert=T)[0]
#     gmat <- tuple(distObject, convert=T)[1]
#     bmat <- tuple(distObject, convert=T)[2]
#     bwlist_norm <- tuple(distObject, convert=T)[3]

#     return(list(
#         rmat=rmat,
#         gmat=gmat,
#         bmat=bmat,
#         bwlist_norm=bwlist_norm
#     ))
# }) %>% shiny::bindEvent(input$generate_hic, input$chip2)


hic_distance <- reactive({
    distnormmat <- distanceMatHiC(
                    hicnumpy = HiCmatrix()
                   # thresh = input$thresh
                )

    return(distnormmat)

}) %>% shiny::bindEvent(input$generate_hic)