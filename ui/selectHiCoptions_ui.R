selectHiCoptionsUI <- div(
    fluidRow(
        column(12, 
            if (is_lite_mode) {
                column(3, 
                    tags$div(id = 'hicdiv', 
                        fileInput('hic', label = 'Select Hi-C', multiple = FALSE, accept = '.hic')
                    )
                )
            } else {
                column(3, 
                    tags$div(id = 'hicdiv', 
                        shinyFilesButton('hic', label = 'Select HiC', title = 'Please select a .hic file', multiple = FALSE)
                    )
                )
            },
            tippy_this(elementId = "hicdiv", tooltip = "<span style='font-size:15px;'>Upload .hic file (juicer)</span>", allowHTML = TRUE, placement = 'right'),
            
            column(3, 
                actionButton("encodehictable", "ENCODE HiC Datasets"),
                tippy_this(elementId = "encodehictable", tooltip = "<span style='font-size:15px;'>Load a Hi-C map from the ENCODE database of Hi-C maps. Takes longer than a local Hi-C map.</span>", allowHTML = TRUE, placement = 'right')
            )
        )
    ),
    
    fluidRow(
        style = "display: flex; align-items: center; gap: 10px;", # Ensures vertical alignment and spacing
        column(8, 
            textInput('urlhic', label = "", placeholder = "https://www.encode.com/xyz.hic")
        ),
        tippy_this(
            elementId = "urlhic", 
            tooltip = "<span style='font-size:15px;'>URL for a .hic file. Can be obtained from ENCODE or GEO. Ensure URL ends in .hic</span>", 
            allowHTML = TRUE, 
            placement = 'right'
        ),
        column(4, 
            actionButton('loadurlhic', label = "Load URL"),
            tippy_this(
                elementId = "loadurlhic", 
                tooltip = "<span style='font-size:15px;'>Attempts to load URL .hic file. Checks if the URL is valid.</span>", 
                allowHTML = TRUE, 
                placement = 'right'
            )
        )
    ),
    
    fluidRow(
        column(6, 
            colourInput("colhic1", "Select colour", "white"),
            tippy_this(elementId = "colhic1", tooltip = "<span style='font-size:15px;'>Low interactions color for Hi-C contacts</span>", allowHTML = TRUE, placement = 'right')
        ),
        
        column(6, 
            colourInput("colhic2", "Select colour", "red"),
            tippy_this(elementId = "colhic2", tooltip = "<span style='font-size:15px;'>High interactions color for Hi-C contacts</span>", allowHTML = TRUE, placement = 'right')
        )
    ),
    
    fluidRow(
        column(4, 
            selectizeInput("norm", label = "Normalization", choices = c("VC", "VC_SQRT", "KR", "NONE"), selected = "NONE"),
            tippy_this(elementId = "norm", tooltip = "<span style='font-size:15px;'>Select Normalization scheme for Hi-C map</span>", allowHTML = TRUE, placement = 'right')
        )
    ),
    
    fluidRow(
        column(6, 
            div(id = "chrwrapper", selectizeInput("chr", "Chr:", choices = "")),
            tippy_this(elementId = "chrwrapper", tooltip = "<span style='font-size:15px;'>Select chromosome. Values populate automatically when Hi-C successfully loads.</span>", allowHTML = TRUE, placement = 'right')
        ),
        
        column(6, 
            div(id = "binwrapper", selectizeInput("bin", "Resolution:", choices = "")),
            tippy_this(elementId = "binwrapper", tooltip = "<span style='font-size:15px;'>Select resolution size. Values populate automatically when Hi-C successfully loads.</span>", allowHTML = TRUE, placement = 'right')
        )
    ),
    
    fluidRow(
        column(6, 
            shinyWidgets::autonumericInput("start", "Start:", value = 40000000, minimumValue = 0, maximumValue = 50000000, allowDecimalPadding = FALSE),
            tippy_this(elementId = "start", tooltip = "<span style='font-size:15px;'>Start coordinate</span>", allowHTML = TRUE, placement = 'right')
        ),
        
        column(6, 
            shinyWidgets::autonumericInput("stop", "Stop:", value = 42000000, minimumValue = 0, maximumValue = 1000000000, allowDecimalPadding = FALSE),
            actionButton("endofchrom", "Chr end"),
            tippy_this(elementId = "stop", tooltip = "<span style='font-size:15px;'>Stop coordinate. Limited by the end coordinate on selected chromosome</span>", allowHTML = TRUE, placement = 'right'),
            tippy_this(elementId = "endofchrom", tooltip = "<span style='font-size:15px;'>Update stop coordinate to the end coordinate on selected chromosome</span>", allowHTML = TRUE, placement = 'right')
        )
    ),
    
    checkboxInput("hicoptions", "Options"),
    tippy_this(elementId = "hicoptions", tooltip = "<span style='font-size:15px;'>Advanced Hi-C visualization options</span>", allowHTML = TRUE, placement = 'right'),
    
    column(12, 
        actionButton("exampleset", "Load Example Setup"),
        tippy_this(elementId = "exampleset", tooltip = "<span style='font-size:15px;'>Load an example showcase with this locus from the HiCrayon paper.</span>", allowHTML = TRUE, placement = 'right')
    ),
    
    conditionalPanel(
        condition = "input.hicoptions == true",
        fluidRow(
            column(3, 
                checkboxInput("chipscale", "Scale ChIP w/ HiC", value = TRUE)
            ),
            
            column(3, 
                checkboxInput("disthic", "Distance normalize HiC", value = TRUE),
                tippy_this(elementId = "disthic", tooltip = "<span style='font-size:15px;'>Distance-Normalize interactions. (observed/expected)</span>", allowHTML = TRUE, placement = 'right')
            ),
            
            column(3, 
                numericInput("thresh", "HiC Threshold", min = 0, max = 30, value = 2),
                tippy_this(elementId = "thresh", tooltip = "<span style='font-size:15px;'>Color value range for interactions. Distance-Normalized: 2. Normal: Value depends on sequencing depth</span>", allowHTML = TRUE, placement = 'right')
            )
        )
    )
)

