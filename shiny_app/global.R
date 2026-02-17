suppressPackageStartupMessages(library(reticulate))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinyjs))
suppressPackageStartupMessages(library(shinyBS))
suppressPackageStartupMessages(library(shinycssloaders))
suppressPackageStartupMessages(library(shinyWidgets))
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(shinyFiles))
suppressPackageStartupMessages(library(spsComps))
suppressPackageStartupMessages(library(colourpicker))
suppressPackageStartupMessages(library(tools))
suppressPackageStartupMessages(library(zip))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(BH))
suppressPackageStartupMessages(library(DT))
suppressPackageStartupMessages(library(eulerr))
suppressPackageStartupMessages(library(tippy))


# load encode hic data
encodehic <- read.table("hic.txt", header=T, sep="\t")

# light_mode
is_lite_mode <- FALSE  # Default

if (exists("lite_mode_arg") && lite_mode_arg == TRUE) {
  is_lite_mode <- TRUE
  print("Running HiCrayon on Lite mode")
} else {
   print("Running HiCrayon on Regular mode")
}

# Maximum upload capacity restriction on lite mode
if (is_lite_mode) {
   options(shiny.maxRequestSize=50*1024^2) # 50mb file upload
} else {
   options(shiny.maxRequestSize=10000*1024^2) #10 gigabytes file upload
}
