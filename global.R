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
is_light_mode <- FALSE  # Default

if (exists("light_mode_arg") && light_mode_arg == TRUE) {
  is_light_mode <- TRUE
}