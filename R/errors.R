#' abort_bad_argument
#' @importFrom glue glue
#' @importFrom rlang abort
#' @keywords internal
abort_bad_argument <- function(arg, must, not = NULL) {
  msg <- glue::glue("\u2716 El par\u00E1metro `{arg}` debe ser de tipo {typeof(must)}")
  if (!is.null(not)) {
    not <- typeof(not)
    msg <- glue::glue("{msg}; no {not}.")
  }

  rlang::abort("error_bad_argument",
               message = msg,
               arg = arg,
               must = must,
               not = not
  )
}

#' abort_bad_argument
#' @importFrom glue glue
#' @importFrom rlang abort
#' @keywords internal
abort_is_na <- function(name) {
  msg <- glue::glue("\u2716 El par\u00E1metro `{name}` no debe ser NA.")
  rlang::abort("abort_is_na",
               message = msg,
               arg = name
  )
}

#' abort_bad_argument
#' @importFrom rlang abort
#' @keywords internal
abort_server_not_found <- function() {
  rlang::abort("\u2716 No se encontr\u00F3 un servidor de selenium")
}
