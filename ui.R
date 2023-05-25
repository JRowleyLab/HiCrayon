# Define UI
ui <- fluidPage(

  # Import CSS stylesheet
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  useShinyjs(),
  # Navbar structure for UI
  navbarPage(title = "HiC Crayon",
    id="HiC Crayon",
    # Black n White theme
    theme = shinytheme("cosmo"),
    # Label for main tab (shows on button)
    tabPanel("Visualize",
      fluid = TRUE, icon = icon("globe-americas"),

      # Sidebar layout with a input and output definitions
      sidebarLayout(
        div(class="sidebar",
        sidebarPanel(
          width = 3,
          style = "overflow-y:scroll; height: 400px; max-height: 400px; position:relative;",
          #titlePanel("Choose Parameters"),
          fluidRow(
            column(4,
              shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
            ),
            column(8,
              verbatimTextOutput('f1_hic')
            )
          ),
          fluidRow(
            column(4,
              selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="NONE")
            ),
            # column(4,
            #   sliderInput("thresh",
            #             label = "",
            #             min = 0,
            #             max = 10,
            #             value = 2,
            #             step = .1,
            #             round = FALSE,
            #             ticks = TRUE)
            #             ),
            # column(4,
            #   sliderInput("thresh2",
            #             label = "HiC-2 Thresh",
            #             min = 0,
            #             max = 10,
            #             value = 2,
            #             step = .1,
            #             round = FALSE,
            #             ticks = TRUE)
            #             )
            column(6,
              selectizeInput(
                "map_colour", 
                "HiC Color", 
                choices = "",
                selected = "YlOrRd"
              )
            )
          ),
          # Dropdown to select colour scheme for HiC Map
          # fluidRow(
          #   column(6,
          #     selectizeInput(
          #       "map_colour", 
          #       "HiC Color", 
          #       choices = "",
          #       selected = "YlOrRd"
          #     )
          #   ),
          #   column(6,
          #     selectizeInput(
          #       "p1_cmap", 
          #       "HiC (Dark) Color", 
          #       choices = "",
          #       selected = "gray"
          #     )
          #   )
          # ),
            fluidRow(
              column(6,
                textInput("chr", "Chr:", value="chr1")
              ),
              column(6,
              numericInput("bin", "Bin Size:", 
                value = 5000, 
                min = 5000, 
                max = 1000000)
              ),
              column(
                6,
                numericInput("start", "Start:",
                value = 68500000, 
                min = 0, 
                max = 1000000000),
              ),
              column(6,
                numericInput("stop", "Stop:",
                value = 69000000, 
                min = 0, 
                max = 1000000000)
              )
          ),
          checkboxInput("chip1", "Include ChIP"),
          conditionalPanel(
                condition = "input.chip1 == true",
                textInput("n1", label = "Name"),
              fluidRow(
                column(5,
                  shinyFilesButton('bw1', label='Select bigwig', title='Please select a .bigwig/.bw file', multiple=FALSE),
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
          ),
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
                column(5,
                checkboxInput("setminmax2", "Set Min/Max")
              ),
                conditionalPanel(
                  condition = "input.setminmax2 == false",
                  fluidRow(
                  column(5,
                    shinyFilesButton('p2', label='Select bed', title='Please select a .bed file', multiple=FALSE),
                  ),
                  column(5,
                    verbatimTextOutput('f1_p2')
                  )
                ),
                ),
                conditionalPanel(
                  condition = "input.setminmax2 == true",
                  fluidRow(
                    column(
                      5,
                      numericInput("min2", "Min:", value = 0, min = 0, max = 1)
                    ),
                    column(5,
                      ofset = 3,
                      numericInput("max2", "Max:", value = .9, min = 0, max = 1)
                    )
                  )
                ),
                
              ),
              # Button to generate HiC image
                fluidRow(
                  column(12,
                  tags$div(style="position: fixed; bottom: 45vh;",
                        actionBttn(
                          inputId = "generate_hic",
                          label = "Generate HiC!",
                          color = "success",
                          style = "material-flat",
                          icon = icon("sliders"),
                          block = TRUE)
                  )
                )
                )
            )
        ),
        ########################################
        # Main
        ########################################

        mainPanel(
          width = 9,
                fluidRow(
                  column(12,
                    uiOutput("gallery"),
                    #######################
                    # weird behaviour where when uiOutput is
                    # updated, the HTML below is removed
                    # from webpage. Below HTML needed for
                    # modal to work after 1st time.
                    #######################
                    tags$div(HTML('
                      <div id="sps-gallery-modal" class="gallery-modal" onclick="galModalClose()">
                        <span class="gallery-modal-close"></span>
                        <img id="sps-gallery-modal-content" class="gallery-modal-content"/>
                      <div class="gallery-caption"></div>
                    ')
                    )
                    )
                  ),
        ),
      ),
    )
  )
)
