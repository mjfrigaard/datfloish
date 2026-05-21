#' Seed the Sales Database
#'
#' Creates (or re-creates) the `sales` table in a SQLite database and inserts
#' ten sample rows with timestamps spread over the previous ten minutes.
#' Re-running this function drops and recreates the table, providing a clean
#' slate for testing.
#'
#' @param db_path Path to the SQLite database file. Defaults to `NULL`, which
#'   resolves to the bundled `sales.db` in `inst/extdata/`. If that file does
#'   not yet exist (e.g. before the first seed), the path is constructed from
#'   the package root and the directory is created automatically.
#'
#' @return Invisibly returns the number of rows inserted.
#' @export
#'
#' @examples
#' \dontrun{
#' seed_db()                        # re-seed the bundled sales.db
#' seed_db(db_path = tempfile(fileext = ".db"))  # seed a fresh temporary db
#' }
seed_db <- function(db_path = NULL) {
  if (is.null(db_path)) {
    db_path <- system.file("extdata", "sales.db", package = "datfloish")
    if (!nzchar(db_path)) {
      # sales.db doesn't exist yet; construct path into inst/extdata
      extdata_dir <- file.path(system.file(package = "datfloish"), "extdata")
      dir.create(extdata_dir, recursive = TRUE, showWarnings = FALSE)
      db_path <- file.path(extdata_dir, "sales.db")
    }
  }
  con <- dbConnect(SQLite(), db_path)
  on.exit(dbDisconnect(con))

  dbExecute(con, "DROP TABLE IF EXISTS sales")
  dbExecute(con, "
    CREATE TABLE sales (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      product    TEXT    NOT NULL,
      amount     REAL    NOT NULL,
      updated_at TEXT    NOT NULL
    )
  ")

  now <- Sys.time()
  rows <- data.frame(
    product = c(
      "Widget A", "Widget B", "Gadget X", "Gadget Y", "Doohickey",
      "Thingamajig", "Whatchamacallit", "Gizmo Pro", "Sprocket", "Doodad"
    ),
    amount = c(
      120.50, 85.00, 240.75, 310.00,  47.99,
      199.95, 65.49, 425.00,  33.25,  88.80
    ),
    updated_at = format(now - seq(0, 540, by = 60), "%Y-%m-%d %H:%M:%S")
  )

  n <- dbAppendTable(con, "sales", rows)
  message(sprintf("Seeded %d rows into '%s' (table: sales)", nrow(rows), db_path))
  invisible(n)
}
