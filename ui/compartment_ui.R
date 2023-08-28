comp_UI <- div(
  checkboxInput("bedgraph", "Include Compartments"),
          conditionalPanel(
                condition = "input.bedgraph == true",
      fluidRow(
              column(12,
                shinyFilesButton(
                    'bedg1',
                    label = 'Select bedGraph',
                    title = 'Please select a .bedgraph/.bed file',
                    multiple=FALSE),
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