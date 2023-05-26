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