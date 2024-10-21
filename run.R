# run.R
args <- commandArgs(trailingOnly = TRUE)

# Default values
light_mode_arg <- FALSE
port <- 3838  # Default Shiny port

# Check if 'light-mode' argument is passed
print(args)
if ("--light-mode" %in% args) {
  light_mode_arg <- TRUE
} else {
  light_mode_arg <- FALSE
}

# Look for the --port argument
if ("--port" %in% args) {
  port_index <- match("--port", args) + 1
  if (!is.na(port_index) && port_index <= length(args)) {
    port <- as.numeric(args[port_index])
  }
}

# Run the Shiny app
shiny::runApp('app.R', launch.browser = F, port = port)