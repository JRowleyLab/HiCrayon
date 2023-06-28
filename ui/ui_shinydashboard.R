## app.R ##

dashboardPage(title = "HiCrayon",
                    dashboardHeader(title = tags$a(span(img(src="logo/HiCrayon_logo2.png",height=60,align="left")),href="https://github.com/JRowleyLab/HiCrayon"),titleWidth = 600),
dashboardSidebar(
    sidebarMenu(id="sidebartabs",
                menuItem("Visualize", tabName = "Visualize", icon = icon("eye"))
    ),
    collapsed = TRUE,
    disable = TRUE
),
dashboardBody(
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
                            # choose between tabs
                            radioGroupButtons(
                            inputId = "dashboardchooser", label = NULL, 
                            choices = c("Info", "Plot"), 
                            selected = "Plot",
                            justified = TRUE, status = "primary",
                            checkIcon = list(yes = "", no = "")
                            ),
                            
                            fluidRow(width=12,
                                    box(width=12,title = "HiC",status = "primary", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE,
                                        selectHiCoptionsUI
                                    ), # end box
                                    
                                    
                                    box(width=12,title = "ChIP-seq 1",status = "success", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE,
                                        chiponeOptionsUI
                                    ), # end box   
                                    
                                    
                                    box(width=12,title = "ChIP-seq 2",status = "info", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE, 
                                        chiptwoOptionsUI
                                    ),
                                    box(width=12,title = "Colour Compartments",status = "warning", solidHeader = TRUE,
                                        collapsible = TRUE,collapsed = TRUE,
                                        comp_UI
                                    ),
                                    column(width = 12,
                                        actionButton("generate_hic", label="Generate")
                                    )
                                    #generateHiCbuttonUI
                            ), #end row
                    ), # end column
                    column(width = 8,
                           galleryUI,
                           tags$script(
                                HTML('panzoom($("#gallery")[0])')
                            )
                           )
            )
        )
    ), # /tabItems
    )
)

