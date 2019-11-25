#' @importFrom webdriver run_phantomjs Session
#' @keywords internal
#'
start_twbot <- function(private){
  private$server <- webdriver::run_phantomjs()
  private$session <- webdriver::Session$new(port = private$server$port)
  private$session$setTimeout(implicit = 10000)
  x <- private$session$getWindow()
  x$setSize(600,200)
  private$session$go("https://twitter.com/login")
  cat(crayon::`%+%`(crayon::green("✔"), " Se inici\u00F3 con éxito el servidor \n"))
}


#' @keywords internal
#'
tw_login <- function(private, username = NA_character_, password = NA_character_){
  user_input = private$session$findElement(xpath =  ".//div[@class = 'clearfix field']/input[@name = 'session[username_or_email]']")
  user_input$clear()
  user_input$sendKeys(username)
  Sys.sleep(3)
  password_input = private$session$findElement(xpath = ".//div[@class = 'clearfix field']/input[@type = 'password']")
  password_input$clear()
  Sys.sleep(3)
  password_input$sendKeys(password)

  submit_btn = private$session$findElement(xpath = ".//button[@type = 'submit']")
  submit_btn$click()
}

tw_get_posts <- function(private, pagename = NA_character_, n = NA_integer_){
  url <- paste0("https://twitter.com/", pagename)
  if(private$session$getUrl() != url) {
    private$session$go(url)
  }
  Sys.sleep(3)
  private$scroll_n(xpath = ".//li[@data-item-type = 'tweet']", n)
  page <- xml2::read_html(private$session$getSource()[[1]])

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

  df <- tibble::tibble(pagename, post_id, text, replies, retweets, likes, date_time)
  return(df)
}




#' Twitter bot
#'
#' Class with function to extract data from twitter posts using webdriver and phantomjs
#'
#'@section Usage:
#'
#'\preformatted{
#'
#' bot_twitter = tw_bot$new()
#' bot_twitter$login(username = <facebook username>, password = <facebook password>)
#' posts = bot_twitter$get_posts(pagename = "OVSICORI_UNA", n = 100)
#'}
#'
#' @section Details:
#' \code{fb_bot$new()} Creates a new fbbot.
#'
#' \code{bot_facebook$login()} Log in to your facebook account.
#'
#' \code{bot_facebook$get_posts} Log in to your facebook account.
#'
#'
#' @importFrom R6 R6Class
#' @export
tw_bot = R6::R6Class(classname = "twbot",
                     public = list(
                       initialize = function(){
                          start_twbot(private)
                       },
                       print = function(...) {
                         cat("<Twitter Bot>")
                       },
                       login = function(username = NA_character_, password = NA_character_){
                         tw_login(private, username, password)
                       },
                       get_posts = function(pagename = NA_character_, n = NA_integer_){
                         tw_get_posts(private, pagename, n)
                       },
                       get_shot = function(){
                         private$session$takeScreenshot()
                       }),
                     private = list(
                        server = NULL,
                        session = NULL,
                        scroll_n = function(xpath = NA_character_, n = NA_integer_) {
                          pb <- progress::progress_bar$new(
                            format = paste0("Loading posts :n_posts/", n),
                            clear = FALSE, width = 90, total = Inf
                          )
                          n_posts <- 0L
                          pb$tick(tokens = list(n_posts = n_posts))
                          while (n_posts < n) {

                            private$session$executeScript("window.scrollTo(0, document.body.scrollHeight)")
                            n_posts <- length(private$session$findElements(xpath = xpath))
                            pb$tick(tokens = list(n_posts = n_posts))
                          }
                          pb$terminate()
                        }
                     ))
