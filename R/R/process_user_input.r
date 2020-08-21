process_user_input <- function (x) {
  UseMethod("process_user_input", x)
}

process_user_input.default <- function(x, ...) {
  stop(
    deparse(substitute(x)),
    " must be a 'data.frame',",
    " a 'response',",
    " or a 'character' vector containing JSON.",
    call. = FALSE
  )
}

process_user_input.data.frame <- function(x, ...) {
  x
}

process_user_input.character <- function(x, ...) {

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop(
      "The package 'jsonlite' is needed to convert ",
      deparse(substitute(x)),
      " into a data frame.",
      "\n       Either install 'jsonlite' or pass ",
      deparse(substitute(x)),
      " as a 'data.frame' or 'response'.",
      call. = FALSE
    )
  }

  jsonlite::fromJSON(x)

}

process_user_input.response <- function(x, ...) {

  process_user_input(rawToChar(x$content))

}
