test_that("seed_db() creates the sales table with correct schema", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))

  n <- seed_db(db_path = db)

  con <- DBI::dbConnect(RSQLite::SQLite(), db)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  expect_true(DBI::dbExistsTable(con, "sales"))

  cols <- DBI::dbListFields(con, "sales")
  expect_setequal(cols, c("id", "product", "amount", "updated_at"))
})

test_that("seed_db() inserts 10 rows and returns row count invisibly", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))

  n <- seed_db(db_path = db)

  expect_equal(n, 10L)

  con <- DBI::dbConnect(RSQLite::SQLite(), db)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  rows <- DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM sales")$n
  expect_equal(rows, 10L)
})

test_that("seed_db() drops and recreates the table on re-run", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))

  seed_db(db_path = db)

  # Add a sentinel row between calls
  con <- DBI::dbConnect(RSQLite::SQLite(), db)
  DBI::dbExecute(
    con,
    "INSERT INTO sales (product, amount, updated_at) VALUES ('Sentinel', 1.00, '2024-01-01 00:00:00')"
  )
  DBI::dbDisconnect(con)

  seed_db(db_path = db)

  con2 <- DBI::dbConnect(RSQLite::SQLite(), db)
  on.exit(DBI::dbDisconnect(con2), add = TRUE)

  rows <- DBI::dbGetQuery(con2, "SELECT COUNT(*) AS n FROM sales")$n
  expect_equal(rows, 10L)
})

test_that("seed_db() seeded rows have required non-NULL fields", {
  db <- tempfile(fileext = ".db")
  on.exit(unlink(db))

  seed_db(db_path = db)

  con <- DBI::dbConnect(RSQLite::SQLite(), db)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  df <- DBI::dbGetQuery(con, "SELECT * FROM sales")

  expect_false(anyNA(df$product))
  expect_false(anyNA(df$amount))
  expect_false(anyNA(df$updated_at))
  expect_true(all(df$amount > 0))
})
