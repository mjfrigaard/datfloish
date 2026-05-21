#' Add Sale Module UI
#'
#' Renders a form for inserting a new row into the `sales` table. Includes a
#' product selector, an amount input, a submit button, and a brief explanatory
#' note about how the submission triggers a [shiny::reactivePoll()] fetch.
#'
#' @param id Module namespace ID.
#'
#' @return A `tagList` containing the form inputs.
#' @export
mod_add_sale_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("product"), "Product",
      choices = c(
        "Widget A", "Widget B", "Gadget X", "Gadget Y", "Doohickey",
        "Thingamajig", "Whatchamacallit", "Gizmo Pro", "Sprocket", "Doodad"
      )
    ),
    numericInput(
      ns("amount"), "Amount ($)",
      value = 99.99, min = 0.01, step = 0.01
    ),
    actionButton(
      ns("add"), "Add Sale",
      class = "btn-primary w-100",
      icon  = icon("plus")
    ),
    hr(),
    p(
      class = "text-muted small",
      "After adding a sale, watch the Fetches counter increment ",
      "while Checks keeps running at its normal cadence."
    )
  )
}

#' Add Sale Module Server
#'
#' Handles the "Add Sale" button. On click, inserts a new row into the `sales`
#' table with the selected product, entered amount, and the current timestamp.
#' Displays a success notification on insert and an error notification if the
#' database write fails.
#'
#' @param id Module namespace ID.
#' @param db_path Path to the SQLite database file.
#'
#' @return Nothing. Called for its side effects.
#' @export
mod_add_sale_server <- function(id, db_path) {
  moduleServer(id, function(input, output, session) {

    observeEvent(input$add, {
      tryCatch({
        con <- dbConnect(SQLite(), db_path)
        on.exit(dbDisconnect(con))
        dbExecute(
          con,
          "INSERT INTO sales (product, amount, updated_at) VALUES (?, ?, ?)",
          params = list(
            input$product,
            input$amount,
            format(Sys.time(), "%Y-%m-%d %H:%M:%S")
          )
        )
        showNotification(
          paste0("Added: ", input$product, " ($", input$amount, ")"),
          type     = "message",
          duration = 3
        )
      },
      error = function(e) {
        showNotification(
          paste("Failed to add sale:", conditionMessage(e)),
          type     = "error",
          duration = 5
        )
      })
    })

  })
}
