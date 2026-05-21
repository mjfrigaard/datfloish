# Entry point for Shiny Server / Posit Connect deployment.
# The datfloish package must be installed before deploying.
# sales.db is bundled in inst/extdata/ and resolved automatically via
# system.file(). Run datfloish::seed_db() to reset the database if needed.
library(datfloish)

datfloish::launch_app()
