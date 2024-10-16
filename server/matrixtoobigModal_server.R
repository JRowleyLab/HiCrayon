side_length <- reactive({
    req(hicv$y!="NULL")
    (as.integer(input$stop) - as.integer(input$start)) / as.integer(input$bin)
  })

# Reactive value to track confirmation
confirmed <- reactiveVal(FALSE)

modalText <- reactive({
    HTML(paste0("
    The matrix size chosen is:<br>",
    "START: ", input$start,"<br>",
    "STOP: ", input$stop,"<br>",
    "RESOLUTION: ", input$bin,"<br>",
    "MATRIX side length: (", input$stop, "-", input$start, ") / ", input$bin, " = ", side_length(),"<br>",
    "The recommended matrix side length is LESS THAN 2,000.<br>
    The application will take a long time to generate a large matrix.<br>
    You cannot cancel during processing. <p>
    Do you wish to continue?
    "))
})

# Function to create the modal dialog
big_matrix_modal <- reactive({
    modalDialog(
    title = "Warning: Large Matrix",
    modalText(),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_generate", "GENERATE")
    ),
    easyClose = FALSE
)
})

  # Observe when the user clicks the "Generate" button
  observeEvent(input$generate_hic, {
    confirmed(FALSE)  # Reset the confirmation flag to ensure a clean start
    if (side_length() > 2000) {
      # Show the modal if the matrix size is too large
      showModal(big_matrix_modal())
    } else {
      # Directly proceed if the matrix size is acceptable
      shinyCatch({message(paste0("Loading Hi-C with matrix size: ", side_length(), "*", side_length()))}, prefix = '')
      # If the matrix is small enough, directly set confirmation and proceed
      confirmed(TRUE)
    }
  })

  # Observe when the user confirms by clicking the "GENERATE" button in the modal
  observeEvent(input$confirm_generate, {
    # If the matrix is small enough, directly set confirmation and proceed
    confirmed(TRUE)
    # Close the modal and proceed with generation
    removeModal()
    shinyCatch({message(paste0("Loading Hi-C with matrix side length: ", side_length()))}, prefix = '')
  })

  observe({
    print(confirmed())
  })