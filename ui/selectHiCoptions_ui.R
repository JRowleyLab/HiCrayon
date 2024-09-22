selectHiCoptionsUI <- div(fluidRow(
                            column(12,
                            #shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            shinyFilesButton('hic', label='Select HiC', title='Please select a .hic file', multiple=FALSE),
                            tippy_this(
                                elementId = "hic", 
                                tooltip = "<span style='font-size:15px;'>Local .hic file (juicer)<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            actionButton("encodehictable", "ENCODE HiC Datasets"),
                            tippy_this(
                                elementId = "encodehictable", 
                                tooltip = "<span style='font-size:15px;'>Load a Hi-C map from the ENCODE database of Hi-C maps. Takes longer than a local Hi-C map.<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            )
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
                                    tooltip = "<span style='font-size:15px;'>URL for a .hic file. Can be obtained from ENCODE or GEO. Ensure URL ends in .hic<span>", 
                                    allowHTML = TRUE,
                                    placement = 'right'
                                ),
                                column(4,
                                    actionButton('loadurlhic', label = "Load URL")
                                )
                            ),
                            #shinyBS::bsTooltip(id = "loadurlhic", title = "Attempts to load URL .hic file. Checks if the URL is valid."),
                            tippy_this(
                                elementId = "loadurlhic", 
                                tooltip = "<span style='font-size:15px;'>Attempts to load URL .hic file. Checks if the URL is valid.<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            fluidRow(
                                column(6,
                                    colourInput("colhic1", 
                                                "Select colour", 
                                                "white")
                                ),
                                #shinyBS::bsTooltip(id = "colhic1", title = "Low interactions color for Hi-C contacts"),
                                
                            tippy_this(
                                elementId = "colhic1", 
                                tooltip = "<span style='font-size:15px;'>Low interactions color for Hi-C contacts<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                                column(6,
                                    colourInput("colhic2",
                                                "Select colour", 
                                                "red")
                                )
                            ),
                            #shinyBS::bsTooltip(id = "colhic2", title = "High interactions color for Hi-C contacts"),
                                
                            tippy_this(
                                elementId = "colhic2", 
                                tooltip = "<span style='font-size:15px;'>High interactions color for Hi-C contacts<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            fluidRow(
                                column(4,
                                selectizeInput("norm", label="Normalization", choices=c("VC", "VC_SQRT", "KR", "NONE"), selected="NONE")
                                ),
                            ),
                            #shinyBS::bsTooltip(id = "norm", title ="Select Normalization scheme for Hi-C map"),
                               
                            tippy_this(
                                elementId = "norm", 
                                tooltip = "<span style='font-size:15px;'>Select Normalization scheme for Hi-C map<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            fluidRow(
                            column(6,
                                div(id = "chrwrapper",
                                    selectizeInput("chr", "Chr:", choices="")
                                )
                            ),
                            #shinyBS::bsTooltip(id = "chr", title ="Select chromosome. Values populate automatically when Hi-C successfully loads."),
                            
                            tippy_this(
                                elementId = "chrwrapper", 
                                tooltip = "<span style='font-size:15px;'>Select chromosome. Values populate automatically when Hi-C successfully loads.<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            column(6,
                            div(id = "binwrapper",
                                selectizeInput("bin", "Resolution:", choices="")
                            )
                            ),
                            #shinyBS::bsTooltip(id = "bin", title ="Select resolution size. Values populate automatically when Hi-C successfully loads."),
                            
                            tippy_this(
                                elementId = "binwrapper", 
                                tooltip = "<span style='font-size:15px;'>Select resolution size. Values populate automatically when Hi-C successfully loads.<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            column(
                                6,
                                shinyWidgets::autonumericInput("start", "Start:",
                                    value = 40000000, 
                                    minimumValue = 0, 
                                    maximumValue = 50000000,
                                    allowDecimalPadding = FALSE),
                            ),
                            #shinyBS::bsTooltip(id = "start", title ="Start coordinate"),
                              
                            tippy_this(
                                elementId = "start", 
                                tooltip = "<span style='font-size:15px;'>Start coordinate<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            column(6,
                                shinyWidgets::autonumericInput("stop", "Stop:",
                                    value = 42000000, 
                                    minimumValue = 0, 
                                    maximumValue = 1000000000,
                                    allowDecimalPadding = FALSE),
                                actionButton("endofchrom", "Chr end")
                            ),
                            #shinyBS::bsTooltip(id = "stop", title ="Stop coordinate. Limited by the end coordinate on selected chromosome"),
                              
                            tippy_this(
                                elementId = "stop", 
                                tooltip = "<span style='font-size:15px;'>Stop coordinate. Limited by the end coordinate on selected chromosome<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                            #shinyBS::bsTooltip(id = "endofchrom", title ="Update stop coordinate to the end coordinate on selected chromosome"),
                             
                            tippy_this(
                                elementId = "endofchrom", 
                                tooltip = "<span style='font-size:15px;'>Update stop coordinate to the end coordinate on selected chromosome<span>", 
                                allowHTML = TRUE,
                                placement = 'right'
                            ),
                        ),
                        checkboxInput("hicoptions", "Options"),
                        #shinyBS::bsTooltip(id = "hicoptions", title ="Advanced Hi-C visualization options"),
                        tippy_this(
                            elementId = "hicoptions", 
                            tooltip = "<span style='font-size:15px;'>Advanced Hi-C visualization options<span>", 
                            allowHTML = TRUE,
                            placement = 'right'
                        ),
                        conditionalPanel(
                            condition = "input.hicoptions == true",
                                fluidRow(
                                    # column(4,
                                    #     checkboxInput("log", "Log Scale", value=FALSE)
                                    # ),
                                    column(3,
                                        checkboxInput("chipscale", "Scale ChIP w/ HiC", value=TRUE)
                                    ),
                                    column(3,
                                        checkboxInput("disthic", "Distance normalize HiC", value=TRUE)
                                    ),
                                    #shinyBS::bsTooltip(id = "disthic", title ="Distance-Normalize interactions. (observed/expected)"),
                                    tippy_this(
                                        elementId = "disthic", 
                                        tooltip = "<span style='font-size:15px;'>Distance-Normalize interactions. (observed/expected)<span>", 
                                        allowHTML = TRUE,
                                        placement = 'right'
                                    ),
                                    column(3,
                                        numericInput("thresh", "HiC Threshold", min=0, max=30, value=2)
                                    ),
                                    #shinyBS::bsTooltip(id = "thresh", title ="Color value range for interactions. Distance-Normalized: 2. Normal: Value depends on sequencing depth")
                                    tippy_this(
                                        elementId = "thresh", 
                                        tooltip = "<span style='font-size:15px;'>Color value range for interactions. Distance-Normalized: 2. Normal: Value depends on sequencing depth<span>", 
                                        allowHTML = TRUE,
                                        placement = 'right'
                                    ),
                                )
                        )
)
