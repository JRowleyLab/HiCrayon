chiptwoOptionsUI <- div(
            conditionalPanel(
                condition = "input.chip1 == true",
                checkboxInput("chip2", "Include second ChIP"),
          ),
          conditionalPanel(
                condition = "input.chip2 == true",
                textInput("n2", label = "Name"),
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
              sliderInput("strength2",
                        label = "Bed Strength",
                        min = 0,
                        max = 2,
                        value = 1,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  ),
            column(
              6,
              sliderInput("opacity2",
                        label = "Opacity",
                        min = 0,
                        max = 255,
                        value = 255,
                        step = 1,
                        round = FALSE,
                        ticks = TRUE
                        )
                  ),
          ),
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
                        value = .3,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  )
          ),
              ),
          )
)