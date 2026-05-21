#' Application Server
#'
#' Returns the server function for the datfloish Shiny application.
#'
#' @param db_path Path to the SQLite database file. Defaults to the bundled
#'   `sales.db` in `inst/extdata/` via [base::system.file()].
#' @param interval_ms Poll interval in milliseconds. Default `5000`.
#'
#' @return A Shiny server function suitable for passing to [shiny::shinyApp()].
#' @export
app_server <- function(
    db_path = system.file("extdata", "sales.db", package = "datfloish"),
    interval_ms = 5000) {
  function(input, output, session) {
    poll_stats <- mod_sales_table_server("sales",
      db_path     = db_path,
      interval_ms = interval_ms
    )

    mod_add_sale_server("add_sale", db_path = db_path)

    mod_value_boxes_server("stats", stats = poll_stats)
  }
}
