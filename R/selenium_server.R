#' Start selenium server
#'
#' @param port Port to run on
#' @param verbose If TRUE, include status messages (if any)
#' @param headless headless
#' @param settings.images settings.images
#' @importFrom wdman selenium
#' @importFrom RSelenium remoteDriver
#' @importFrom crayon green blue
#' @importFrom stringr str_detect
#' @importFrom rlang abort
#' @export
start_server <- function(port = 4567L, headless = T, verbose = FALSE, settings.images = 2L) {
  if (!is.numeric(port)) {
    abort_bad_argument(arg = "port", must = integer(), port)
  }

  if (!is.logical(verbose)) {
    abort_bad_argument(arg = "verbose", must = logical(), not = verbose)
  }

  out <- tryCatch({
    server <- wdman::selenium(port = port, verbose = verbose, chromever = "73.0.3683.68")
    extras <- list(
      chromeOptions = list(
        args = c("--disable-gpu", "--window-size=600,600"),
        prefs = list(
          "profile.default_content_settings.popups" = 0L,
          "profile.managed_default_content_settings.images" = settings.images
        )
      )
    )
    if(headless){
      extras$chromeOptions$args <- c('--headless',extras$chromeOptions$args)
    }
    session <- RSelenium::remoteDriver(
      port = port,
      browserName = "chrome",
      extraCapabilities = extras
    )
    session$open(silent = TRUE)
    cat(crayon::`%+%`(
      crayon::green(" \u2714"),
      paste0(" Se inici\u00F3 con \u00E9xito el servidor de Selenium en el puerto ", port, ".\n")
    ))

    out <- list(
      server = server,
      session = session
    )

    class(out) <- c("scrapeR_session", "list")

    return(out)
  },
  error = function(msg) {
    if (stringr::str_detect(msg$message, "Could not resolve host: www.googleapis.com")) {
      message <- "\u2716 Se requiere de conexi\u00F3n a Internet\n"
      rlang::abort(message)
    }

    if (identical(unname(Sys.which("javac")), "")) {
      message <- "\u2716 Se requiere de JAVA para iniciar el servidor, puede descargarlo de forma gratuita en:\n"
      message <- crayon::`%+%`(message, crayon::blue("https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html\n"))
      message <- crayon::`%+%`(message, "Recuerde reiniciar su equipo despu\u00E9s de la instalaci\u00F3n.\n")
      rlang::abort(message)
    }
    if (stringr::str_detect(msg$message, "port = \\d+ is already in use.")) {
      message <- paste0(
        "\u2716 Error: El servidor de Selenium no se pudo iniciar porque el puesto ",
        port, " ya est\u00E1 en uso, para solucionar esto reinicie su sesi\u00F3n de R.\n"
      )
      rlang::abort(message)
    }
    rlang::abort(paste0("\u2716 ", msg$message))
  }
  )
  return(invisible(out))
}

#' Stop selenium server
#'
#' @param x scrapeR_session
#' @importFrom crayon green
#' @importFrom rlang abort
#' @export
stop_server <- function(x) {
  if (is.null(x)) {
    abort_server_not_found()
  }

  tryCatch({
    x$session$close()
    x$server$stop()
    cat(crayon::`%+%`(crayon::green(" \u2714"), " Se cerr\u00F3 con \u00E9xito el servidor de Selenium.\n"))
    return(NULL)
  },
  error = function(msg) {
    rlang::abort(msg$message)
  }
  )
}

#' navigate
#' @importFrom crayon blue silver %+%
#' @importFrom rlang abort
#' @keywords internal
navigate <- function(x, url = NA_character_, silence = FALSE) {
  if (is.null(x)) {
    abort_server_not_found()
  }

  if (!is.character(url)) {
    abort_bad_argument(arg = "url", must = character(), not = url)
  }

  if (is.na(url)) {
    abort_is_na("url")
  }

  if (!is.logical(silence)) {
    abort_bad_argument(arg = "silence", must = logical(), not = url)
  }

  if (!stringr::str_detect(
    string = url,
    pattern = "http(s)?\\:\\/\\/(www\\.)?(([[:alnum:]]|\\-)+\\.)+\\w{2,3}(\\/.+)?"
  )) {
    error <- paste0("\u2716 La url ", url, " no es valida; la url debe seguir la forma ")
    error <- crayon::`%+%`(error, crayon::blue("https://www.google.com\n"))

    rlang::abort(error)
  }

  tryCatch({
    if (!silence) {
      msg <- paste0("Se est\u00E1 redirigiendo el navegador a la url: ", url, " ...\n")
      msg <- crayon::silver(msg)
      cat(msg)
    }
    suppressMessages(x$session$navigate(url))
  },
  error = function(msg) {
    rlang::abort(paste0("\u2716 No se puede acceder a la direcci\u00F3n ", url, "\n"))
  }
  )
}


#' Load n items
#'
#' @param x scrapeR_session
#' @param xpath xpath expresion
#' @param n n
#' @importFrom progress progress_bar
#' @export
scroll_n <- function(x = NULL, xpath = NA_character_, n = NA_integer_) {
  if (is.null(x)) {
    abort_server_not_found()
  }
  if (is.na(xpath)) {
    abort_is_na("xpath")
  }
  if (is.na(n)) {
    abort_is_na("n")
  }
  if (!is.character(xpath)) {
    abort_bad_argument(arg = "xpath", must = character(), not = xpath)
  }
  if (!is.numeric(n)) {
    abort_bad_argument(arg = "n", must = character(), not = n)
  }

  pb <- progress::progress_bar$new(
    format = paste0("Cargando publicaciones :n_posts/", n, " publicaciones cargadas"),
    clear = FALSE, width = 90, total = Inf
  )

  n_posts <- 0L
  pb$tick(tokens = list(n_posts = n_posts))
  while (n_posts < n) {
    x$session$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    n_posts <- length(x$session$findElements(using = "xpath", value = xpath))
    pb$tick(tokens = list(n_posts = n_posts))
  }
  pb$terminate()
}

#' load more items
#'
#' @param x scrapeR_session
#' @param xpath xpath expresion
#' @export
load_more <- function(x, xpath = NA_character_) {
  if (!is.character(xpath)) {
    abort_bad_argument(arg = "xpath", must = character(), not = xpath)
  }
  if (is.na(xpath)) {
    abort_is_na("xpath")
  }

  x$session$setImplicitWaitTimeout(milliseconds = 3000)
  aux <- 0L
  while (T) {
    btn <- tryCatch({
      suppressMessages(x$session$findElement(using = "xpath", value = xpath))
    },
    error = function(msg) {
      return(NULL)
    }
    )
    if (is.null(btn)) {
      break()
    }

    tryCatch({
      suppressMessages(btn$clickElement())
      aux <- aux + 1
      },
             error = function(msg) {
               return(NULL)
             }
    )
    if(aux > 500L) {
      break()
    }
  }

}

#' Extract email
#'
#' @param text string
#' @param email_services email services
#' @importFrom stringr str_extract str_detect
#' @export
find_emails <- function(text = NA_character_, email_services = c("gmail|yahoo|outlook|hotmail|live")) {
  out <- stringr::str_extract(text, "[[:alnum:]\\.\\-\\_]+@[[:alnum:]]+(\\.\\w{1,3})+")
  out <- out[stringr::str_detect(out, email_services)]
  out <- out[!is.na(out)]
  return(out)
}
