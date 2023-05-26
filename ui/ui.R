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
          style = "overflow-y:scroll; height: 60vh; max-height: 60vh; position:relative;",
          # upload HiC file and all options for displaying
          # the HiC map
          selectHiCoptionsUI,
          # Upload bigwig and/or peaks file to
          # overlay ChIP-seq data on HiC map
          chiponeOptionsUI,
          # Upload bigwig and/or peaks file to
          # overlay ChIP-seq data on HiC map
          chiptwoOptionsUI,
          # Button to generate HiC image
          generateHiCbuttonUI,
            )
        ),
        ########################################
        # Main
        ########################################
        mainPanel(
          tags$head(
            tags$style(
              "body {overflow-y: hidden;}"
            )
          ),
          width = 9,
            galleryUI,
        ),
      ),
    )
  )
)
