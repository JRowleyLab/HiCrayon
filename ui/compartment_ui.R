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
          column(12,
                  colourInput("colcompA", "A compartment", "red"),
                ),
          column(12,
                  colourInput("colcompB", "B compartment", "blue"),
                ),
          column(12,
                  colourInput("colcompAB", "A-B compartment", "green"),
                )
    )
          )
)