generateHiCbuttonUI <- fluidRow(
                            column(12,
                            tags$div(style="position: fixed; bottom: 5vh;",
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