chiponeOptionsUI <- div(
        checkboxInput("chip1", "Include ChIP"),
          conditionalPanel(
                condition = "input.chip1 == true",
                textInput("n1", label = "Name"),
              fluidRow(
                column(5,
                  shinyFilesButton(
                    'bw1', 
                    label = 'Select bigwig', 
                    title = 'Please select a .bigwig/.bw file', 
                    multiple=FALSE),
                ),
                column(5,
                  verbatimTextOutput('f1_bw1')
                )
              ),
              checkboxInput("advancedparameters", "Advanced Parameters"),
          conditionalPanel(
                condition = "input.advancedparameters == true",
                fluidRow(
            column(
              6,
              sliderInput("strength",
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
              sliderInput("opacity",
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
              sliderInput("bedalpha",
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
              sliderInput("hicalpha",
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
              fluidRow(
                column(6,
                  checkboxInput("setminmax", "Set Min/Max")
                  ),
              ),
              conditionalPanel(
                condition = "input.setminmax == false",
                fluidRow(
                column(5,
                  shinyFilesButton('p1', label='Select bed', title='Please select a .bed file', multiple=FALSE),
                ),
                column(5,
                  #tags$p("No file selected")
                  verbatimTextOutput('f1_p1')
                )
              ),
              ),
              conditionalPanel(
                condition = "input.setminmax == true",
                fluidRow(
                  column(
                    5,
                    numericInput("min", "Min:", value = 0, min = 0, max = 1)
                  ),
                  column(
                    5,
                    numericInput("max", "Max:", value = .9, min = 0, max = 1)
                  )
                )
              ),
          )
)