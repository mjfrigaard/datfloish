#' Launch the datfloish Shiny Application
#'
#' Convenience wrapper around [shiny::shinyApp()] that wires together
#' [app_ui()] and [app_server()]. Run [seed_db()] first if the database
#' does not yet exist.
#'
#' @param db_path Path to the SQLite database file. Defaults to the bundled
#'   `sales.db` in `inst/extdata/` via [base::system.file()].
#' @param interval_ms Poll interval in milliseconds passed to
#'   [mod_sales_table_server()] and [mod_value_boxes_ui()]. Default `5000`.
#' @param ... Additional arguments passed to [shiny::shinyApp()].
#'
#' @return A Shiny app object (invisibly when run interactively).
#' @export
#'
#' @examples
#' \dontrun{
#' launch_app()   # launch the app using the bundled sales.db
#' }
launch_app <- function(
    db_path = system.file("extdata", "sales.db", package = "datfloish"),
    interval_ms = 5000,
    ...) {
  shinyApp(
    ui     = app_ui(interval_ms = interval_ms),
    server = app_server(db_path = db_path, interval_ms = interval_ms),
    ...
  )
}
