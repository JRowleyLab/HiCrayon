chiponeOptionsUI <- div(
        checkboxInput("chip1", "Include ChIP"),
          conditionalPanel(
                condition = "input.chip1 == true",
              fluidRow(
                actionBttn("addBtn", "Add", 
                  style = "minimal", 
                  color = "default", 
                  size = "sm"),
                ),
                tags$div(id='inputList'),
                # Dynamic ChIP UI
                #uiOutput("chipUI"),
              checkboxInput("advancedparameters", "Advanced Parameters"),
          conditionalPanel(
                condition = "input.advancedparameters == true",
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