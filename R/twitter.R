#' Login on Twitter
#'
#' @param x session
#' @param username username
#' @param password password
#' @importFrom crayon silver red
#' @importFrom rlang abort
#' @export
login_twitter <- function(x, username = NA_character_, password = NA_character_) {
  if (is.null(x)) {
    return(invisible(NULL))
  }

  if (is.na(username) | is.na(password)) {
    return(invisible(NULL))
  }
  x$session$setImplicitWaitTimeout(milliseconds = 10000)
  tryCatch({
    if (x$session$getCurrentUrl() != "https://twitter.com/login") {
      cat(crayon::silver("Se est\u00E1 redirigiendo el navegador a la url: https://twitter.com/login ...\n"))
      x$session$navigate("https://twitter.com/login")
    }

    email.input <- x$session$findElement(using = "xpath", value = ".//div[@class = 'clearfix field']/input[@name = 'session[username_or_email]']")
    password.input <- x$session$findElement(using = "xpath", value = ".//div[@class = 'clearfix field']/input[@type = 'password']")
    submit <- x$session$findElement(using = "xpath", value = ".//button[@type = 'submit']")

    email.input$sendKeysToElement(list(username))
    password.input$sendKeysToElement(list(password))
    submit$clickElement()

    if (x$session$getCurrentUrl() == "https://twitter.com/") {
      cat(crayon::silver(paste0("Se inici\u00F3 sesi\u00F3n en https://twitter.com/ con el usuario ", username, "\n")))
    } else {
      rlang::abort("\u2716 Se produjo un error al inciar sesi\u00F3n en www.twitter.com \n")
    }
  })
}

#' Get Twitter posts
#'
#' @param x session
#' @param page_id page_id
#' @param n n of posts
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_attr html_text
#' @importFrom lubridate as_datetime
#' @importFrom stringr str_extract
#' @importFrom tibble tibble
#' @export
get_tw_posts <- function(x, page_id = NA_character_, n = NA_integer_) {
  out <- tryCatch({
    page_url <- paste0("https://twitter.com/", page_id)
    navigate(x = x, url = page_url)

    scroll_n(x = x, xpath = ".//li[@class = 'js-stream-item stream-item stream-item
']", n)

    page <- xml2::read_html(x$session$getPageSource()[[1]])
    posts <- page %>% rvest::html_nodes(xpath = ".//li[@class = 'js-stream-item stream-item stream-item
']")

    post_id <- page %>% rvest::html_nodes(xpath = ".//li[@class = 'js-stream-item stream-item stream-item
']") %>% rvest::html_attr("data-item-id")

    text <- posts %>% rvest::html_nodes(xpath = ".//div[@class = 'js-tweet-text-container']/p") %>% rvest::html_text()

    date_time <- posts %>%
      rvest::html_node(xpath = ".//span[@class = '_timestamp js-short-timestamp js-relative-timestamp'] | .//span[@class = '_timestamp js-short-timestamp ']") %>%
      rvest::html_attr("data-time") %>%
      as.numeric() %>%
      lubridate::as_datetime()


    replies <- page %>%
      rvest::html_nodes(xpath = ".//div[@class = 'ProfileTweet-actionList js-actions']/div[1]") %>%
      rvest::html_text() %>%
      stringr::str_extract("\\d+") %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)

    retweets <- page %>%
      rvest::html_nodes(xpath = ".//div[@class = 'ProfileTweet-actionList js-actions']/div[2]") %>%
      rvest::html_text() %>%
      stringr::str_extract("\\d+") %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)

    likes <- page %>%
      rvest::html_nodes(xpath = ".//div[@class = 'ProfileTweet-actionList js-actions']/div[3]") %>%
      rvest::html_text() %>%
      stringr::str_extract("\\d+") %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)

    df <- tibble::tibble(page_id, post_id, text, replies, retweets, likes, date_time)
    return(df)
  })
  return(out)
}

