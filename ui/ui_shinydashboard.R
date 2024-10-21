## app.R ##
dashboardPage(
  title = "HiCrayon",
  
  dashboardHeader(
    title = tagList(
      tags$a(
        span(
          img(src = "logo/HiCrayon_logo2.png", height = 60, align = "left")
        ),
        href = "https://github.com/JRowleyLab/HiCrayon"
      ),
      
      # Conditionally display "Lite Mode - Restricted upload capacity" if light mode is enabled
      if (is_lite_mode) {
        div(
          style = "color: red; font-weight: bold; padding-left: 20px;", 
          "Lite Mode - Restricted upload capacity"
        )
      }
    ),
    titleWidth = 600
  ),
  dashboardSidebar(
    sidebarMenu(id="sidebartabs",
                menuItem("Visualize", tabName = "Visualize", icon = icon("eye"))
    ),
    collapsed = TRUE,
    disable = TRUE
),
dashboardBody(
    shinyjs::useShinyjs(),
    includeCSS("www/styles.css"),
    # Zoomy zoom
    tags$head(
        tags$script(src = "https://unpkg.com/panzoom@9.4.0/dist/panzoom.min.js"),
  ),
    tabItems(
    # First tab content
    tabItem(tabName = "Visualize",
            fluidRow(width=12,
                    column(width=3,
                            fluidRow(width=12,
                                    box(width=12,title = "Hi-C (2D)",status = "primary", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE,
                                        selectHiCoptionsUI
                                    ), # end box
                                    box(width=12,title = "Features (1D)",status = "success", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE,
                                        chiponeOptionsUI
                                    ), # end box
                                    # box(width=12,title = "Colour Compartments",status = "warning", solidHeader = TRUE,
                                    #     collapsible = TRUE,collapsed = TRUE,
                                    #     comp_UI
                                    # ),
                                    column(width = 12,
                                        actionButton("generate_hic", label="Generate")
                                    ),
                                    br(),
                                    column(width = 12,
                                        shinyjs::hidden(downloadButton(outputId = "downloadtree",label= "Download"))
                                    )
                                    #generateHiCbuttonUI
                            ), #end row
                    ), # end column
                    column(width = 7,
                           galleryUI,
                           tags$script(
                                HTML('panzoom($("#gallery")[0])')
                            )
                           )
            ),
            column(width = 2,
                        plotOutput("colorlegend"))
        )
    ), # /tabItems
    )
)

