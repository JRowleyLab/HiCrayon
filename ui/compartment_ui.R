comp_UI <- div(
  checkboxInput("bedgraph", "Include Compartments"),
          conditionalPanel(
                condition = "input.bedgraph == true",
    fluidRow(
                column(5,
                  shinyFilesButton(
                    'bedg1', 
                    label = 'Select bedGraph', 
                    title = 'Please select a .bedgraph/.bed file', 
                    multiple=FALSE),
                ),
                column(5,
                  verbatimTextOutput('f1_bedg1')
                )
              )
          )
)