galleryUI <- fluidRow(
                  column(12,
                    uiOutput("gallery") %>% withSpinner(type = 2, color.background = "white", color = "black"),
                    #######################
                    # weird behaviour where when uiOutput is
                    # updated, the HTML below is removed
                    # from webpage. Below HTML needed for
                    # modal to work after 1st time.
                    #######################
                    tags$div(HTML('
                      <div id="sps-gallery-modal" class="gallery-modal" onclick="galModalClose()">
                        <span class="gallery-modal-close"></span>
                        <img id="sps-gallery-modal-content" class="gallery-modal-content"/>
                      <div class="gallery-caption"></div>
                    ')
                    )
                    )
                 )