selectHiCoptionsUI <- div(fluidRow(
                            column(4,
                            shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            ),
                            column(8,
                            verbatimTextOutput('f1_hic')
                            ) ),
                            fluidRow(
                                column(4,
                                selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="NONE")
                                ),
                                column(4,
                                selectizeInput(
                                    "map_colour", 
                                    "HiC Color", 
                                    choices = "",
                                    selected = "JuiceBoxLike"
                                )
                                ),
                                column(4,
                                selectizeInput(
                                    "chip_cmap", 
                                    "HiC Color (ChIP)", 
                                    choices = "",
                                    selected = "JuiceBoxLike"
                                )
                                )
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
                                    allowDecimalPadding = FALSE)
                            )
                        ),
                        fluidRow(
                            column(3,
                                checkboxInput("log", "Log Scale")
                            ),
                            column(3,
                                checkboxInput("chipscale", "Scale ChIP w/ HiC")
                            )
                        )
)