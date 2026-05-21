test_that("mod_add_sale_server() inserts a row into the database", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))
  seed_db(db_path = db)

  shiny::testServer(
    mod_add_sale_server,
    args = list(db_path = db),
    {
      session$setInputs(product = "Gizmo Pro", amount = 99.99, add = 1)

      con <- DBI::dbConnect(RSQLite::SQLite(), db)
      on.exit(DBI::dbDisconnect(con), add = TRUE)

      rows <- DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM sales")$n
      expect_equal(rows, 11L)

      # Use id DESC (AUTOINCREMENT) to reliably identify the most-recent insert,
      # avoiding ties when seed and insert timestamps share the same second.
      last <- DBI::dbGetQuery(
        con,
        "SELECT product, amount FROM sales ORDER BY id DESC LIMIT 1"
      )
      expect_equal(last$product, "Gizmo Pro")
      expect_equal(last$amount,  99.99)
    }
  )
})

test_that("mod_add_sale_server() records the correct timestamp", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))
  seed_db(db_path = db)

  before <- format(Sys.time() - 2, "%Y-%m-%d %H:%M:%S")

  shiny::testServer(
    mod_add_sale_server,
    args = list(db_path = db),
    {
      session$setInputs(product = "Widget A", amount = 10.00, add = 1)
    }
  )

  after <- format(Sys.time() + 2, "%Y-%m-%d %H:%M:%S")

  con <- DBI::dbConnect(RSQLite::SQLite(), db)
  on.exit(DBI::dbDisconnect(con))

  ts <- DBI::dbGetQuery(
    con,
    "SELECT updated_at FROM sales ORDER BY id DESC LIMIT 1"
  )$updated_at

  expect_gte(ts, before)
  expect_lte(ts, after)
})
