chiptwoOptionsUI <- div(
            conditionalPanel(
                condition = "input.chip1 == true",
                checkboxInput("chip2", "Include second ChIP"),
          ),
          conditionalPanel(
                condition = "input.chip2 == true",
                fluidRow(
                column(5,
                  textInput("n2", label = "Name"),
                ),
                column(5,
                  colourInput("colchip2", "Select colour", "black"),
                )
              ),
              fluidRow(
                column(5,
                  shinyFilesButton('bw2', label='Select bigwig', title='Please select a .bigwig/.bw file', multiple=FALSE),
                ),
                column(5,
                  verbatimTextOutput('f1_bw2')
                )
              ),
              checkboxInput("advancedparameters2", "Advanced Parameters"),
          conditionalPanel(
                condition = "input.advancedparameters2 == true",
          fluidRow(
            column(
              6,
              sliderInput("bedalpha2",
                        label = "Bed Alpha",
                        min = 0,
                        max = 1,
                        value = 1,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  ),
            column(
              6,
              sliderInput("hicalpha2",
                        label = "HiC Alpha",
                        min = 0,
                        max = 1,
                        value = .5,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  )
          ),
              ),
          )
)