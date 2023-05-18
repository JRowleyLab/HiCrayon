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
    theme = shinytheme("cosmo"),
    tabPanel("Visualize",
      fluid = TRUE, icon = icon("globe-americas"),

      # Sidebar layout with a input and output definitions
      sidebarLayout(
        div(class="sidebar",
        sidebarPanel(
          titlePanel("Choose Parameters"),
          #fileInput("hic", label = "Upload HiC:", accept = ".hic", multiple = F),
          fluidRow(
            column(5,
              shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
            ),
            column(5,
              #tags$p("No file selected")
              verbatimTextOutput('f1_hic')
            )
          ),
          fluidRow(
            column(5,
              selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="KR")
            ),
            column(5,
              #numericInput("thresh", label="Threshold", value=2),
              sliderInput("thresh",
                        label = "Intensity Threshold",
                        min = 0,
                        max = 10,
                        value = 2,
                        step = .1,
                        round = FALSE,
                        ticks = TRUE)
                        )
          ),
          # Dropdown to select colour scheme for HiC Map
          fluidRow(
            column(6,
              selectizeInput(
                "map_colour", 
                "Colour Scheme", 
                choices = "",
                selected = "YlOrRd"
              )
            )
          ),
                fluidRow(
            column(4,
              ofset = 2,
              textInput("chr", "Chr:", value="chr1")
            ),
            column(
              4,
              numericInput("start", "Start:",
              value = 65000000, 
              min = 0, 
              max = 10000000),
            ),
            column(4,
              ofset = 2,
              numericInput("stop", "Stop:",
              value = 70000000, 
              min = 0, 
              max = 10000000)
            )
          ),
          numericInput("bin", "Bin Size:", 
          value = 5000, 
          min = 5000, 
          max = 50000),
          # Button to generate HiC image
          fluidRow(
            column(3,
              actionButton("generate_hic", label = "Generate HiC")
          )),


          # Turn off overlay for images. Aim is to be able to
          # turn off overlay for each image individually
          # The overlay is handled in the python function.
          fluidRow(
            column(3,
              strong(h4("Overlay Off")),
              checkboxInput(inputId = "HiC_check", label = "HiC"),
              checkboxInput(inputId = "bw_check", label = "Bigwig"),
              conditionalPanel(
                condition = "input.bw2check == true",
                checkboxInput(inputId = "bw_check2", label = "Bigwig 2"),
              )
            )
          ),
          tabsetPanel(
            id = "parameters",
            #### Bigwig Tab 1
            tabPanel(
              "Bigwig",
              textInput("n1", label = "Name"),

              fluidRow(
                column(5,
                  shinyFilesButton('bw1', label='Select bigwig', title='Please select a .bigwig/.bw file', multiple=FALSE),
                ),
                column(5,
                  #tags$p("No file selected")
                  verbatimTextOutput('f1_bw1')
                )
              ),
              conditionalPanel(
                condition = "input.setminmax == false",
                #fileInput("p1", label = "Upload bed:", accept = ".bed", multiple = F),
                #shinyFilesButton('p1', label='Select bed', title='Please select a .bed file', multiple=FALSE),
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
                  column(5,
                    ofset = 3,
                    numericInput("max", "Max:", value = .9, min = 0, max = 1)
                  )
                )
              ),
              checkboxInput("setminmax", "Set Min/Max"),
            ),
            #### Bigwig Tab 2
            tabPanel(
              "Bigwig 2",
              textInput("n2", label = "Name"),
              #fileInput("bw2", label = "Upload bigwig 2:", accept = ".bw", multiple = F),
              #shinyFilesButton('bw2', label='Select bigwig', title='Please select a .bigwig/.bw file', multiple=FALSE),
              fluidRow(
                column(5,
                  shinyFilesButton('bw2', label='Select bigwig', title='Please select a .bigwig/.bw file', multiple=FALSE),
                ),
                column(5,
                  #tags$p("No file selected")
                  verbatimTextOutput('f1_bw2')
                )
              ),
              conditionalPanel(
                condition = "input.setminmax2 == false",
                #fileInput("p2", label = "Upload bed:", accept = ".bed", multiple = F),
                #shinyFilesButton('p2', label='Select bed', title='Please select a .bed file', multiple=FALSE),
                fluidRow(
                column(5,
                  shinyFilesButton('p2', label='Select bed', title='Please select a .bed file', multiple=FALSE),
                ),
                column(5,
                  #tags$p("No file selected")
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
              checkboxInput("setminmax2", "Set Min/Max"),
            )
          ),
          checkboxInput("bw2check", "Second Bigwig?"),
          actionButton("run", label = "Run!")
        )
      ),

        ########################################
        # Main
        ########################################

        mainPanel(
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
                  )
        )
      )
    )
  )
)
