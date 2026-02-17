if (is_lite_mode) {
    max_matrix_size = 500
    recommended_max_matrix_size = 500
} else {
    max_matrix_size = NULL
    recommended_max_matrix_size = 500
}



side_length <- reactive({
    req(hicv$y!="NULL")
    (as.integer(input$stop) - as.integer(input$start)) / as.integer(input$bin)
  })

# Reactive value to track confirmation
confirmed <- reactiveVal(FALSE)

modalText <- reactive({
    if (is_lite_mode) {
        HTML(paste0("
            LITE MODE: The matrix size chosen is:<br>",
            "START: ", input$start,"<br>",
            "STOP: ", input$stop,"<br>",
            "RESOLUTION: ", input$bin,"<br>",
            "MATRIX side length: (", input$stop, "-", input$start, ") / ", input$bin, " = ", side_length(),"<br>",
            "The recommended matrix side length is LESS THAN 500.<br>
            Please select a smaller matrix size and try again.
            Try out the full version (github.com/JRowleylab/HiCrayon) for unrestricted matrix sizes.<p>
            "))
    } else {
       HTML(paste0("
            The matrix size chosen is:<br>",
            "START: ", input$start,"<br>",
            "STOP: ", input$stop,"<br>",
            "RESOLUTION: ", input$bin,"<br>",
            "MATRIX side length: (", input$stop, "-", input$start, ") / ", input$bin, " = ", side_length(),"<br>",
            "The recommended matrix side length is LESS THAN 1,500.<br>
            The application will take a long time to generate a large matrix.<br>
            You cannot cancel during processing. <p>
            Do you wish to continue?
            "))
    }
    
})

# Function to create the modal dialog
big_matrix_modal <- reactive({
    if (is_lite_mode) {
        modalDialog(
            title = "Warning: Exceeded Max Matrix size on Lite version",
            modalText(),
            footer = tagList(
            modalButton("Cancel"),
            ),
            easyClose = FALSE
        )
    } else {
        modalDialog(
            title = "Warning: Large Matrix",
            modalText(),
            footer = tagList(
            modalButton("Cancel"),
            actionButton("confirm_generate", "GENERATE")
            ),
            easyClose = FALSE
        )
    }
})

observeEvent(input$generate_hic, {
    confirmed(FALSE)  # Reset the confirmation flag to ensure a clean start
    
    if (is_lite_mode) {
        if (side_length() > 500) {
            # Show the modal if the matrix size is too large in lite mode
            showModal(big_matrix_modal())
            shinyCatch({
                stop("Error: Hi-C Matrix too large for lite mode.")
            }, prefix = '')
            return()
        }
    } else {
        if (side_length() > 1500) {
            # Show the modal if the matrix size is too large in non-lite mode
            showModal(big_matrix_modal())
            shinyCatch({
                stop("Error: Hi-C Matrix too large for standard mode.")
            }, prefix = '')
            return()
        }
    }
    
    # Coordinate validation checks
    if (is.null(input$start) || is.null(input$stop)) {
        shinyCatch({
            stop("Locus coordinates contain empty value/s. Resetting to default.")
        }, prefix = '')
        return()
    }
    
    if (input$start >= input$stop) {
        shinyCatch({
            stop("Start coordinate must be less than stop coordinate. Resetting to default.")
        }, prefix = '')
        updateNumericInput(session, "start", value = 40000000)
        updateNumericInput(session, "stop", value = 42000000)
        return()
    }
    
    if ((input$stop - input$start) <= as.numeric(input$bin)) {
        shinyCatch({
            stop("Bin size is greater than or equal to the total distance. Resetting to default.")
        }, prefix = '')
        updateNumericInput(session, "start", value = 40000000)
        updateNumericInput(session, "stop", value = 42000000)
        return()
    }
    
    # Adjust stop if not divisible by bin
    remainder <- (input$stop - input$start) %% as.numeric(input$bin)
    if (remainder != 0) {
        new_stop <- input$stop - remainder
        updateNumericInput(session, "stop", value = new_stop)
        
        shinyCatch({
            stop(paste("Adjusted stop to nearest divisible value:", new_stop))
        }, prefix = '')
        return()
    }

    # If all checks pass, set confirmed to TRUE
    shinyCatch({
        message(paste0("Loading Hi-C with matrix size: ", side_length(), "*", side_length()))
    }, prefix = '')
    confirmed(TRUE)
})

  # Observe when the user confirms by clicking the "GENERATE" button in the modal
  observeEvent(input$confirm_generate, {
    # If the matrix is small enough, directly set confirmation and proceed
    confirmed(TRUE)
    # Close the modal and proceed with generation
    removeModal()
    shinyCatch({message(paste0("Loading Hi-C with matrix side length: ", side_length()))}, prefix = '')
  })
