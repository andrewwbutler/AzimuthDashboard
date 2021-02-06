#' Server function for dashboard
#'
#' @param input,output,session Required Shiny app server parameters
#'
#' @return The shiny server logic
#' @importFrom dplyr filter summarize group_by %>% n
#' @importFrom shiny observeEvent reactiveValues renderPlot
#' @importFrom shinydashboard renderMenu renderValueBox sidebarMenu valueBox
#' @importFrom googlesheets4 gs4_auth gs4_get range_speedread
#' @importFrom cowplot theme_cowplot
#' @importFrom ggplot2 ggplot geom_point geom_line geom_bar geom_text xlab ylab
#' labs theme ylim aes element_text
#'
#' @keywords internal
#'
AzimuthDashboardServer <- function(input, output, session) {
  react.env <- reactiveValues(
    log.data = data.frame()
  )
  ### Data Loading
  observeEvent(
    eventExpr = input$reload,
    handlerExpr = {
      url <- getOption(x = "AzimuthDashboard.app.googlesheet")
      gs4_auth(
        email = getOption(x = "AzimuthDashboard.app.googletokenemail"),
        cache = getOption(x = "AzimuthDashboard.app.googletoken"))
      googlesheet <- gs4_get(ss = url)
      logs <- range_speedread(url, col_names = FALSE)
      # data cleaning
      logs <- logs[logs$X1 == "SUMMARY", ]
      logs[, 1] <- NULL
      colnames(x = logs) <- c("id", "reference", "reference_version", "demo", "cells_uploaded", "cells_mapped", "mapping_time", "date")
      react.env$log.data <- logs
    },
    ignoreNULL = FALSE
  )
  ### Value Boxes
  output$valuebox.totalmapped <- renderValueBox(expr = {
    dat <- react.env$log.data
    if (!input$include.demo) {
      dat <- dat[!dat$demo, ]
    }
    valueBox(
      value = prettyNum(sum(dat$cells_mapped), big.mark = ","),
      subtitle = 'Total Cells Mapped',
      color = 'green'
    )
  })
  output$valuebox.ndset <- renderValueBox(expr = {
    dat <- react.env$log.data
    ndset <- nrow(x = dat[!dat$demo, ])
    if (input$include.demo) {
      ndset <- ndset + dat %>% group_by(reference, demo) %>% filter(demo) %>% summarize(n()) %>% nrow()
    }
    valueBox(
      value = prettyNum(ndset, big.mark = ","),
      subtitle = 'Unique Datasets Mapped',
      color = 'blue'
    )
  })

  ### Plots
  output$cells.per.reference <- renderPlot(expr = {
    dat <- react.env$log.data
    if (!input$include.demo) {
      dat <- dat[!dat$demo, ]
    }
    dat.totals <- dat %>% group_by(reference) %>% summarize(total = sum(cells_mapped))
    ggplot(data = dat.totals, aes(x = reference, y = total, fill = reference)) +
      geom_bar(stat = "identity") +
      geom_text(
        aes(x = reference, y = total, label = prettyNum(total, big.mark = ",")),
        size = 10, vjust = 1
      ) +
      ylab('Cells Mapped') + xlab('') + labs(title = "Cells Mapped per Reference") +
      theme_cowplot() +
      theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
  })
  output$cells.overtime <- renderPlot(expr = {
    dat <- react.env$log.data
    if (!input$include.demo) {
      dat <- dat[!dat$demo, ]
    }
    date.range <- input$dateRange
    dat <- dat %>% filter(date >= date.range[1] & date <= date.range[2]) %>% group_by(date)
    if (input$split.reference) {
      dat <- dat %>% group_by(reference, date)
    }
    dat <- dat %>% summarize(cells_mapped = sum(cells_mapped))
    if (input$check.weekend) {
      dat <- dat[!(weekdays(dat$date) %in% c('Saturday','Sunday')), ]
    }
    total.mapped <- prettyNum(sum(dat$cells_mapped), big.mark = ",")
    if (input$split.reference) {
      plot <- ggplot(data = dat, aes(x = date, y = cells_mapped, color = reference))
    } else {
      plot <- ggplot(data = dat, aes(x = date, y = cells_mapped)) + theme(legend.position = "none")
    }
    plot +
      geom_line() +
      geom_point(size = 3) +
      ylim(c(0, max(dat$cells_mapped))) +
      ylab('Cells Mapped') + xlab('') + labs(title = paste0("Cells Mapped per Day - Total: ", total.mapped)) +
      theme_cowplot() +
      theme(plot.title = element_text(hjust = 0.5))
  })
}
