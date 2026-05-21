#' Sales Table Module UI
#'
#' Places the `tableOutput` element for the sales data table.
#'
#' @param id Module namespace ID.
#'
#' @return A `tableOutput` element.
#' @export
mod_sales_table_ui <- function(id) {
  tableOutput(NS(id, "sales_table"))
}

#' Sales Table Module Server
#'
#' Polls a SQLite database for sales data using [shiny::reactivePoll()].
#' `checkFunc` runs every `interval_ms` milliseconds and fetches the latest
#' `updated_at` timestamp; `valueFunc` only executes when that value changes,
#' keeping expensive queries to a minimum.
#'
#' @param id Module namespace ID.
#' @param db_path Path to the SQLite database file.
#' @param interval_ms Poll interval in milliseconds. Default `5000`.
#'
#' @return A named list of `reactiveVal`s: `check_count`, `fetch_count`,
#'   `last_check`, `last_fetch`. Pass this list to [mod_value_boxes_server()].
#' @export
mod_sales_table_server <- function(id, db_path, interval_ms = 5000) {
  moduleServer(id, function(input, output, session) {

    check_count <- reactiveVal(0)
    fetch_count <- reactiveVal(0)
    last_check  <- reactiveVal("\u2014")
    last_fetch  <- reactiveVal("\u2014")

    # reactivePoll: checkFunc runs every interval_ms milliseconds;
    # valueFunc only runs when checkFunc returns a new value.
    sales_data <- reactivePoll(
      intervalMillis = interval_ms,
      session        = session,

      # cheap: fetch the latest timestamp and update check counter
      checkFunc = function() {
        tryCatch({
          check_count(isolate(check_count()) + 1)
          last_check(format(Sys.time(), "%H:%M:%S"))

          con <- dbConnect(SQLite(), db_path)
          on.exit(dbDisconnect(con))
          if (!dbExistsTable(con, "sales")) return(NA)
          dbGetQuery(con, "SELECT MAX(updated_at) FROM sales")[[1]]
        },
        error = function(e) {
          warning("checkFunc failed: ", conditionMessage(e))
          NA
        })
      },

      # expensive: only runs when checkFunc result changes
      valueFunc = function() {
        tryCatch({
          fetch_count(isolate(fetch_count()) + 1)
          last_fetch(format(Sys.time(), "%H:%M:%S"))

          con <- dbConnect(SQLite(), db_path)
          on.exit(dbDisconnect(con))
          dbGetQuery(con, "SELECT * FROM sales ORDER BY updated_at DESC")
        },
        error = function(e) {
          warning("valueFunc failed: ", conditionMessage(e))
          data.frame(message = paste("Could not load data:", conditionMessage(e)))
        })
      }
    )

    output$sales_table <- renderTable({
      tryCatch(
        sales_data(),
        error = function(e) {
          data.frame(message = paste("Render error:", conditionMessage(e)))
        }
      )
    })

    list(
      check_count = check_count,
      fetch_count = fetch_count,
      last_check  = last_check,
      last_fetch  = last_fetch
    )

  })
}
