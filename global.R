library(reticulate)
library(dplyr)
library(shiny)
library(shinyjs)
library(shinyBS)
library(shinycssloaders)
library(shinyWidgets)
library(shinydashboard)
library(shinyFiles)
library(spsComps)
library(colourpicker)
library(tools)
library(zip)
library(stringr)
library(BH)
library(DT)
library(eulerr)
library(tippy)

# load encode hic data
encodehic <- read.table("hic.txt", header=T, sep="\t")

# light_mode
is_lite_mode <- FALSE  # Default

if (exists("lite_mode_arg") && lite_mode_arg == TRUE) {
  is_lite_mode <- TRUE
}

# Maximum upload capacity restriction on lite mode
if (is_lite_mode) {
   options(shiny.maxRequestSize=100*1024^2) # 100mb file upload
} else {
   options(shiny.maxRequestSize=10000*1024^2) #10 gigabytes file upload
}
