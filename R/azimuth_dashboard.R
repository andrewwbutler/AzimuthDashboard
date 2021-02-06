#' @include ui.R
#'
NULL

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Launch Command
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#' Launch the dashboard app
#'
#' @param config json file with googlesheet config info
#'
#' @return None, launches the Shiny app
#'
#' @importFrom shiny runApp shinyApp
#' @importFrom jsonlite read_json

#' @importFrom withr with_options
#'
#' @export
#'
AzimuthDashboardApp <- function(config = NULL) {
  opts <- list()
  # Add options set through config file
  if (!is.null(x = config)) {
    opts <- c(opts, read_json(path = config, simplifyVector = TRUE))
  }
  with_options(
    new = opts,
    code = runApp(appDir = shinyApp(ui = AzimuthDashboardUI, server = AzimuthDashboardServer))
  )
  return(invisible(x = NULL))
}
