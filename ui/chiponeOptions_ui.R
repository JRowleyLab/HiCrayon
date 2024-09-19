chiponeOptionsUI <- div(
        checkboxInput("chip1", "Include Features"),
        #shinyBS::bsTooltip(id = "chip1", title ="Include ChIP features in the visualization panel. If unchecked, data won't be lost. Simply recheck the box to include the ChIP features again."),
          tippy_this(
              elementId = "chip1", 
              tooltip = "<span style='font-size:15px;'>Include ChIP features in the visualization panel. If unchecked, data won't be lost. Simply recheck the box to include the ChIP features again.<span>", 
              allowHTML = TRUE,
              placement = 'right'
          ),
          conditionalPanel(
                condition = "input.chip1 == true",
              fluidRow(
                actionBttn("addBtn", "Add", 
                  style = "minimal", 
                  color = "default", 
                  size = "sm"),
                ),

          tippy_this(
              elementId = "addBtn", 
              tooltip = "<span style='font-size:15px;'>Add another ChIP feature. Each will appear in a separate panel, unless 'combination' is checked. See expand button on each feature.<span>", 
              allowHTML = TRUE,
              placement = 'right'
          ),
                tags$div(id='inputList'),
                # Dynamic ChIP UI
                #uiOutput("chipUI"),
              checkboxInput("advancedparameters", "Advanced Parameters"),
              
          tippy_this(
              elementId = "advancedparameters", 
              tooltip = "<span style='font-size:15px;'>Applies to all ChIP features<span>", 
              allowHTML = TRUE,
              placement = 'right'
          ),

          conditionalPanel(
                condition = "input.advancedparameters == true",
          fluidRow(
            column(
              6,
              sliderInput("bedalpha",
                        label = "Bed Alpha",
                        min = 0,
                        max = 1,
                        value = 1,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  ),
                                
          tippy_this(
              elementId = "bedalpha", 
              tooltip = "<span style='font-size:15px;'>Transparency value for ChIP features<span>", 
              allowHTML = TRUE,
              placement = 'right'
          ),

            column(
              6,
              sliderInput("hicalpha",
                        label = "HiC Alpha",
                        min = 0,
                        max = 1,
                        value = .5,
                        step = .05,
                        round = FALSE,
                        ticks = TRUE
                        )
                  ),
                                       
          tippy_this(
              elementId = "hicalpha", 
              tooltip = "<span style='font-size:15px;'>Transparency value for Hi-C map<span>", 
              allowHTML = TRUE,
              placement = 'right'
          ),
          ),
              ),
          )
)