#' Value Boxes Module UI
#'
#' Renders four [bslib::value_box()] elements showing poll statistics:
#' checks performed, fetches performed, time of last check, and time of last
#' fetch. The Checks box also displays the configured poll cadence.
#'
#' @param id Module namespace ID.
#' @param interval_ms Poll interval in milliseconds, used to label the
#'   "Checks Performed" box. Default `5000`.
#'
#' @return A `layout_columns` element containing four value boxes.
#' @export
mod_value_boxes_ui <- function(id, interval_ms = 5000) {
  ns <- NS(id)
  layout_columns(
    col_widths = c(3, 3, 3, 3),
    value_box(
      title = "Checks Performed",
      value = textOutput(ns("check_count")),
      theme = "secondary",
      p(paste("Runs every", interval_ms / 1000, "seconds"))
    ),
    value_box(
      title = "Fetches Performed",
      value = textOutput(ns("fetch_count")),
      theme = "success",
      p("Only when data changes")
    ),
    value_box(
      title = "Last Check",
      value = textOutput(ns("last_check")),
      theme = "secondary"
    ),
    value_box(
      title = "Last Fetch",
      value = textOutput(ns("last_fetch")),
      theme = "success"
    )
  )
}

#' Value Boxes Module Server
#'
#' Renders the four poll-statistic outputs produced by [mod_value_boxes_ui()].
#' Each output is wrapped in a [tryCatch()] so a transient reactive error
#' falls back to `"—"` rather than crashing the session.
#'
#' @param id Module namespace ID.
#' @param stats Named list of `reactiveVal`s returned by
#'   [mod_sales_table_server()]: `check_count`, `fetch_count`, `last_check`,
#'   `last_fetch`.
#'
#' @return Nothing. Called for its side effects.
#' @export
mod_value_boxes_server <- function(id, stats) {
  moduleServer(id, function(input, output, session) {

    output$check_count <- renderText({
      tryCatch(as.character(stats$check_count()), error = \(e) "\u2014")
    })

    output$fetch_count <- renderText({
      tryCatch(as.character(stats$fetch_count()), error = \(e) "\u2014")
    })

    output$last_check <- renderText({
      tryCatch(stats$last_check(), error = \(e) "\u2014")
    })

    output$last_fetch <- renderText({
      tryCatch(stats$last_fetch(), error = \(e) "\u2014")
    })

  })
}
