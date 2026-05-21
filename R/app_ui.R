#' Application UI
#'
#' Assembles the top-level UI for the datfloish Shiny application.
#'
#' @param interval_ms Poll interval in milliseconds, forwarded to
#'   [mod_value_boxes_ui()] to label the Checks box. Default `5000`.
#'
#' @return A `bslib` page object suitable for passing to [shiny::shinyApp()].
#' @export
app_ui <- function(interval_ms = 5000) {
  page_sidebar(
    title = "Sales Dashboard \u2014 reactivePoll Demo",
    sidebar = sidebar(
      width = 300,
      card(
        card_header("Add a Sale"),
        mod_add_sale_ui("add_sale")
      )
    ),
    mod_value_boxes_ui("stats", interval_ms = interval_ms),
    card(
      card_header("Sales Data"),
      mod_sales_table_ui("sales")
    )
  )
}
