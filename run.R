# run.R
args <- commandArgs(trailingOnly = TRUE)

# Default values
lite_mode_arg <- FALSE
host <- "127.0.0.1"

# Check if 'light-mode' argument is passed
if ("--lite-mode" %in% args) {
  lite_mode_arg <- TRUE
} else {
  lite_mode_arg <- FALSE
}

# Look for the --port argument
if ("--port" %in% args) {
  port_index <- match("--port", args) + 1
  if (!is.na(port_index) && port_index <= length(args)) {
    port <- as.numeric(args[port_index])
  }
}

# Look for the --host argument
if ("--host" %in% args) {
  host_index <- match("--host", args) + 1
  if (!is.na(host_index) && host_index <= length(args)) {
    host <- args[host_index]
  }
}


# Run the Shiny app
shiny::runApp('app.R', launch.browser = F, port = port, host=host)
