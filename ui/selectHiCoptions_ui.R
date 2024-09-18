selectHiCoptionsUI <- div(fluidRow(
                            column(12,
                            #shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            tippy_this(
                                elementId = "hic", 
                                tooltip = "<span style='font-size:20px;'>Local .hic file (juicer)<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            actionButton("encodehictable", "ENCODE HiC Datasets")
                            ),
                            ),
                            fluidRow(
                                column(8,
                                    textInput('urlhic',
                                    label="",
                                    placeholder = "https://www.encode.com/xyz.hic")
                                ),
                                #shinyBS::bsTooltip(id = "urlhic", title = "URL for a .hic file. Can be obtained from ENCODE or GEO. Ensure URL ends in .hic"),
                                tippy_this(
                                    elementId = "urlhic", 
                                    tooltip = "<span style='font-size:20px;'>URL for a .hic file. Can be obtained from ENCODE or GEO. Ensure URL ends in .hic<span>", 
                                    allowHTML = TRUE,
                                    placement = 'right'
                                ),
                                column(4,
                                    actionButton('loadurlhic', label = "Load URL")
                                )
                            ),
                            shinyBS::bsTooltip(id = "loadurlhic", title = "Attempts to load URL .hic file. Checks if the URL is valid."),
                            fluidRow(
                                column(6,
                                    colourInput("colhic1", 
                                                "Select colour", 
                                                "white")
                                ),
                                shinyBS::bsTooltip(id = "colhic1", title = "Low interactions color for Hi-C contacts"),
                                column(6,
                                    colourInput("colhic2",
                                                "Select colour", 
                                                "red")
                                )
                            ),
                            shinyBS::bsTooltip(id = "colhic2", title = "High interactions color for Hi-C contacts"),
                            fluidRow(
                                column(4,
                                selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="NONE")
                                ),
                            ),
                            shinyBS::bsTooltip(id = "norm", title ="Select Normalization scheme for Hi-C map"),
                            fluidRow(
                            column(6,
                                selectizeInput("chr", "Chr:", choices="")
                            ),
                            shinyBS::bsTooltip(id = "chr", title ="Select chromosome. Values populate automatically when Hi-C successfully loads."),
                            column(6,
                                selectizeInput("bin", "Resolution:", choices="")
                            ),
                            shinyBS::bsTooltip(id = "bin", title ="Select resolution size. Values populate automatically when Hi-C successfully loads."),
                            column(
                                6,
                                shinyWidgets::autonumericInput("start", "Start:",
                                    value = 40000000, 
                                    minimumValue = 0, 
                                    maximumValue = 50000000,
                                    allowDecimalPadding = FALSE),
                            ),
                            shinyBS::bsTooltip(id = "start", title ="Start coordinate"),
                            #shinyBS::bsTooltip(id = "start", title ="Select resolution size"),
                            column(6,
                                shinyWidgets::autonumericInput("stop", "Stop:",
                                    value = 69000000, 
                                    minimumValue = 0, 
                                    maximumValue = 1000000000,
                                    allowDecimalPadding = FALSE),
                                actionButton("endofchrom", "Chr end")
                            ),
                            shinyBS::bsTooltip(id = "stop", title ="Stop coordinate. Limited by the end coordinate on selected chromosome"),
                            shinyBS::bsTooltip(id = "endofchrom", title ="Update stop coordinate to the end coordinate on selected chromosome"),
                        ),
                        checkboxInput("hicoptions", "Options"),
                        shinyBS::bsTooltip(id = "hicoptions", title ="Advanced Hi-C visualization options"),
                        conditionalPanel(
                            condition = "input.hicoptions == true",
                                fluidRow(
                                    # column(4,
                                    #     checkboxInput("log", "Log Scale", value=FALSE)
                                    # ),
                                    # column(4,
                                    #     checkboxInput("chipscale", "Scale ChIP w/ HiC", value=TRUE)
                                    # ),
                                    column(6,
                                        checkboxInput("disthic", "Distance normalize HiC", value=TRUE)
                                    ),
                                    shinyBS::bsTooltip(id = "disthic", title ="Distance-Normalize interactions. (observed/expected)"),
                                    column(6,
                                        numericInput("thresh", "HiC Threshold", min=0, max=30, value=2)
                                    ),
                                    shinyBS::bsTooltip(id = "thresh", title ="Color value range for interactions. Distance-Normalized: 2. Normal: Value depends on sequencing depth, experiment!")
                                )
                        )
)
