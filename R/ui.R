#'
#' @importFrom shiny actionButton checkboxInput fluidRow htmlOutput plotOutput
#' textOutput uiOutput dateRangeInput
#' @importFrom shinydashboard box dashboardBody dashboardHeader dashboardSidebar
#' dashboardPage valueBoxOutput
#'
NULL

AzimuthDashboardUI <-  dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Azimuth Stats"),
  dashboardSidebar(
    actionButton(inputId = "reload", label = "Reload data"),
    checkboxInput(inputId = "include.demo", label = "Include Demo Data", value = TRUE, width = NULL)
  ),
  dashboardBody(
    fluidRow(
      valueBoxOutput(outputId = 'valuebox.totalmapped', width = 3),
      valueBoxOutput(outputId = 'valuebox.ndset', width = 3)
    ),
    plotOutput(outputId = 'cells.per.reference'),
    fluidRow(
      dateRangeInput(
        inputId = 'dateRange',
        label = 'Date range',
        start = Sys.Date() - 7, end = Sys.Date()
      ),
      checkboxInput(inputId = "check.weekend", label = "Exclude Weekends", value = FALSE, width = NULL),
      checkboxInput(inputId = "split.reference", label = "Split By Reference", value = FALSE, width = NULL)

    ),
    plotOutput(outputId = 'cells.overtime')
  )
)
