comp_UI <- div(
  checkboxInput("bedgraph", "Include Compartments"),
          conditionalPanel(
                condition = "input.bedgraph == true",
      fluidRow(
              column(12,
                fileInput("bedg1", "Select Bedgraph", accept = c(".bed", ".bedgraph"), multiple = FALSE)
              ),
            ),
      fluidRow(
          column(5,
                  colourInput("colcompA", "Select colour: Pos", "red"),
                ),
          column(5,
                  colourInput("colcompB", "Select colour: Neg", "blue"),
                )
    )
          )
)