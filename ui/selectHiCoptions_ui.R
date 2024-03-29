selectHiCoptionsUI <- div(fluidRow(
                            column(12,
                            #shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            actionButton("encodehictable", "ENCODE HiC Datasets")
                            ),
                            ),
                            fluidRow(
                                column(8,
                                    textInput('urlhic',
                                    label="",
                                    placeholder = "https://www.encode.com/xyz.hic")
                                ),
                                column(4,
                                    actionButton('loadurlhic', label = "Load URL")
                                )
                            ),
                            fluidRow(
                                column(6,
                                    colourInput("colhic1", 
                                                "Select colour", 
                                                "white")
                                ),
                                column(6,
                                    colourInput("colhic2",
                                                "Select colour", 
                                                "red")
                                )
                            ),
                            fluidRow(
                                column(4,
                                selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="NONE")
                                ),
                            ),
                            fluidRow(
                            column(6,
                                selectizeInput("chr", "Chr:", choices="")
                            ),
                            column(6,
                                selectizeInput("bin", "Resolution:", choices="")
                            ),
                            column(
                                6,
                                shinyWidgets::autonumericInput("start", "Start:",
                                    value = 68500000, 
                                    minimumValue = 0, 
                                    maximumValue = 1000000000,
                                    allowDecimalPadding = FALSE),
                            ),
                            column(6,
                                shinyWidgets::autonumericInput("stop", "Stop:",
                                    value = 69000000, 
                                    minimumValue = 0, 
                                    maximumValue = 1000000000,
                                    allowDecimalPadding = FALSE),
                                actionButton("endofchrom", "Chr end")
                            )
                        ),
                        checkboxInput("hicoptions", "Options"),
                        conditionalPanel(
                            condition = "input.hicoptions == true",
                                fluidRow(
                                    column(4,
                                        checkboxInput("log", "Log Scale", value=FALSE)
                                    ),
                                    column(4,
                                        checkboxInput("chipscale", "Scale ChIP w/ HiC", value=TRUE)
                                    ),
                                    column(4,
                                        checkboxInput("disthic", "Distance normalize HiC", value=TRUE)
                                    ),
                                    column(12,
                                        numericInput("thresh", "HiC Threshold", min=0, max=30, value=2)
                                    )
                                )
                        )
)