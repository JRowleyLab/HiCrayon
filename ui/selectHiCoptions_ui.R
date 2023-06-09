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
                        )
)