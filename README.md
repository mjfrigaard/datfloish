
<!-- README.md is generated from README.Rmd. Please edit that file -->

# datfloish

<!-- badges: start -->

<!-- badges: end -->

**datfloish** is a Shiny application package that demonstrates efficient
database polling with
[`shiny::reactivePoll()`](https://shiny.posit.co/r/reference/shiny/latest/reactivePoll.html).
It uses a SQLite backend to illustrate how separating a cheap *check
function* from an expensive *value function* keeps a live dashboard
responsive without hammering the database.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("mjfrigaard/datfloish")
```

## Usage

The bundled `sales.db` database lives in `inst/extdata/` and is resolved
automatically. Launch the app with:

``` r
library(datfloish)

launch_app()
```

To reset the database to its original ten seed rows:

``` r
seed_db()
```

You can also point the app at a custom database file:

``` r
my_db <- tempfile(fileext = ".db")
seed_db(db_path = my_db)
launch_app(db_path = my_db)
```

## How it works

`reactivePoll()` separates polling into two functions:

| Function    | SQL                      | Runs                        | Cost     |
|-------------|--------------------------|-----------------------------|----------|
| `checkFunc` | `SELECT MAX(updated_at)` | Every `interval_ms` ms      | Very low |
| `valueFunc` | `SELECT * FROM sales`    | Only when timestamp changes | Higher   |

Because `valueFunc` only fires when `checkFunc` returns a new value, a
busy app can poll frequently for changes without running expensive
full-table reads on every tick. The dashboard’s **Checks** and
**Fetches** counters make this difference visible in real time.

## App structure

    datfloish/
    ├── R/
    │   ├── app_ui.R            # Top-level UI
    │   ├── app_server.R        # Top-level server
    │   ├── launch_app.R        # Convenience launcher
    │   ├── seed_db.R           # Database initialisation
    │   ├── mod_add_sale.R      # Add Sale module
    │   ├── mod_sales_table.R   # Sales table + polling module
    │   └── mod_value_boxes.R   # Statistics display module
    ├── inst/
    │   ├── app/app.R           # Deployment entry point
    │   └── extdata/
    │       └── sales.db        # Bundled SQLite database
    └── tests/testthat/         # testthat test suite

## Running tests

``` r
# From the package root
devtools::test()
```
