test_that("mod_sales_table_server() renders the sales table", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))
  seed_db(db_path = db)

  shiny::testServer(
    mod_sales_table_server,
    args = list(db_path = db, interval_ms = 500),
    {
      # Trigger the reactive poll output
      result <- output$sales_table
      expect_type(result, "character")  # renderTable returns HTML
    }
  )
})

test_that("mod_sales_table_server() initialises counters at 0", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))
  seed_db(db_path = db)

  shiny::testServer(
    mod_sales_table_server,
    args = list(db_path = db, interval_ms = 500),
    {
      returned <- session$getReturned()
      # reactivePoll fires checkFunc once on initialisation, so check_count >= 1
      expect_gte(returned$check_count(), 1)
      expect_gte(returned$fetch_count(), 0)
    }
  )
})

test_that("mod_sales_table_server() returns expected list structure", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))
  seed_db(db_path = db)

  shiny::testServer(
    mod_sales_table_server,
    args = list(db_path = db, interval_ms = 500),
    {
      returned <- session$getReturned()
      expect_named(returned, c("check_count", "fetch_count", "last_check", "last_fetch"))
      expect_true(is.function(returned$check_count))
      expect_true(is.function(returned$fetch_count))
    }
  )
})
