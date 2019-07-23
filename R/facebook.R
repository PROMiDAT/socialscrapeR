
#' @importFrom webdriver run_phantomjs Session
#' @keywords internal
#'
start_fbbot <- function(private){
  private$server <- webdriver::run_phantomjs()
  private$session <- webdriver::Session$new(port = private$server$port)
  private$session$setTimeout(implicit = 10000)
  private$session$go("https://m.facebook.com")
}

#' @keywords internal
#'
fb_login <- function(private, username = NA_character_, password = NA_character_){
  user_input = private$session$findElement(xpath =  ".//input[@id = 'm_login_email']")
  user_input$clear()
  user_input$sendKeys(username)
  password_input = private$session$findElement(xpath = ".//input[@id = 'm_login_password']")
  password_input$clear()
  password_input$sendKeys(password)

  submit_btn = private$session$findElement(css = "#u_0_5")
  submit_btn$click()
  skip <- private$session$findElement(partialLinkText =  "Ahora no")
  skip$click()
}

#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_text
#' @keywords internal
#'
fb_getposts <- function(private, self, pagename = NA_character_, n = NA_integer_, reactions = F){
  url <- paste0("https://m.facebook.com/", pagename)
  if(private$session$getUrl() != url) {
    private$session$go(url)
  }
  private$scroll_n(xpath = ".//article", n =  n)
  page <- xml2::read_html(private$session$getSource()[[1]])
  post_text <- rvest::html_nodes(page, xpath = ".//article") %>%
    rvest::html_node(xpath = ".//div[@class = 'story_body_container']") %>%
    rvest::html_node(xpath = ".//p[1]") %>%
    rvest::html_text() %>%
    stringr::str_to_lower()

  n_comments <- rvest::html_nodes(page, xpath = ".//article") %>%
    rvest::html_node(xpath = ".//footer//div[@class = '_1fnt']/span[@data-sigil = 'comments-token']") %>%
    rvest::html_text() %>%
    private$as_integer() %>%
    ifelse(is.na(.), 0L, .)

  n_shares <- rvest::html_nodes(page, xpath = ".//article") %>%
    rvest::html_node(xpath = ".//footer//div[@class = '_1fnt']//span[not(@data-sigil)]") %>%
    rvest::html_text() %>%
    stringr::str_extract("\\d+") %>%
    private$as_integer() %>%
    ifelse(is.na(.), 0L, .)

  info <- rvest::html_nodes(page, xpath = ".//article") %>%
    rvest::html_attr("data-store") %>%
    stringr::str_remove_all("\\\\") %>%
    stringr::str_remove_all('\"')

  date_time <- info %>%
    stringr::str_extract("(?<=publish_time:)\\d+") %>%
    as.numeric() %>%
    lubridate::as_datetime()

  post_id <- ifelse(is.na(info %>% stringr::str_extract("(?<=mf_story_key.)\\d+")), "-",
                    info %>% stringr::str_extract("(?<=mf_story_key.)\\d+")
  )

  page_id <- info %>% stringr::str_extract("(?<=page_id.)\\d+")

  if(reactions){
    out = tibble::tibble(page_id, post_id,text = post_text, n_comments,n_shares)
    reactions = self$get_reactions(out$post_id)
    out = cbind(out,reactions,date_time)
    return(out)
  }else{
    out = tibble::tibble(page_id, post_id,text = post_text, n_comments,n_shares,date_time)
    return(out)
  }

}


#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text
#' @importFrom tibble tibble
#' @keywords internal
#'
fb_get_reactions <- function(private, post_id = NA_character_){

  pb <- progress::progress_bar$new(
    format = paste0("Extract reactions :n_posts/", length(post_id)," posts"),
    clear = FALSE, width = 90, total = length(post_id)
  )
  n_posts <- 0L
  out = purrr::map_df(post_id, ~{
    n_posts <<- n_posts + 1
    pb$tick(tokens = list(n_posts = n_posts))
    url <- paste0("https://m.facebook.com/ufi/reaction/profile/browser/?ft_ent_identifier=", .)
    private$session$go(url)
    page <- xml2::read_html(private$session$getSource()[[1]])

    like <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":1}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    love <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":2}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    wow <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":3}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    haha <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":4}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    sad <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":7}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    angry <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":8}']") %>%
      rvest::html_text() %>%
      as.numeric() %>%
      ifelse(is.na(.), 0L, .)

    df <- tibble::tibble(like, love, wow, haha, sad, angry)
    return(df)
  })
  pb$terminate()
  return(out)
}

#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_nodes html_text html_attr
#' @importFrom tibble tibble
#' @importFrom stringr str_remove_all str_extract str_to_lower
#' @keywords internal
#'
#'
fb_get_comments <- function(private, page_id = NA_character_, post_id = NA_character_){
  out = purrr::map2(page_id,post_id, ~{
    url <- paste0("https://m.facebook.com/story.php?story_fbid=", .y, "&id=", .x)
    private$session$go(url)
    private$load_more(xpath = ".//a[@data-sigil = 'ajaxify']")

    page <- xml2::read_html(private$session$getSource()[[1]])

    comments <- page %>% rvest::html_nodes(xpath = ".//div[@class = '_2b06']")
    full_name <- comments %>%
      rvest::html_node(xpath = ".//div[@class = '_2b05']/a") %>%
      rvest::html_text()
    user_name <- comments %>%
      rvest::html_node(xpath = ".//div[@class = '_2b05']/a") %>%
      rvest::html_attr("href") %>%
      stringr::str_extract("(^\\/profile.php\\?id\\=\\d+|^\\/(\\w|\\.|\\d)+(?=\\?|\\/))")
    text <- comments %>%
      rvest::html_node(xpath = ".//div[@data-sigil = 'comment-body']") %>%
      rvest::html_text() %>%
      stringr::str_remove_all("\\p{So}|\\p{Cn}")

    text[text == user_name] <- "image"
    text <- stringr::str_to_lower(text)

    tibble::tibble(page_id = .x, post_id = .y, full_name, user_name, text)
  })
  return(out)
}


#' Facebook bot
#'
#' Class with function to extract data from facebook posts using webdriver and phantomjs
#'
#'@section Usage:
#'
#'\preformatted{
#'
#' bot_facebook = fb_bot$new()
#' bot_facebook$login(username = <facebook username>, password = <facebook password>)
#' posts = bot_facebook$get_posts(pagename = "ameliarueda", n = 50, reactions = T)
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
fb_bot = R6::R6Class(classname = "fbbot",
                 public = list(
                   initialize = function(){
                      start_fbbot(private)
                   },
                   print = function(...) {
                     cat("<Facebook Bot>")
                   },
                   login = function(username = NA_character_, password = NA_character_){
                     fb_login(private, username, password)
                   },
                   get_posts = function(pagename = NA_character_, n = NA_integer_, reactions = F){
                     fb_getposts(private, self, pagename, n, reactions)
                   },
                   get_reactions = function(post_id = NA_character_){
                     fb_get_reactions(private, post_id)
                   },
                   get_comments = function(page_id = NA_character_, post_id = NA_character_){
                     fb_get_comments(private, page_id, post_id)
                   },
                   find_emails = function(text = NA_character_, email_services = c("gmail|yahoo|outlook|hotmail|live")) {
                     out <- stringr::str_extract(text, "[[:alnum:]\\.\\-\\_]+@[[:alnum:]]+(\\.\\w{1,3})+")
                     out <- out[stringr::str_detect(out, email_services)]
                     out <- out[!is.na(out)]
                     return(out)
                   }
                 ),
                 private = list(
                   session = NULL,
                   server = NULL,
                   as_integer = function(x){
                     x = stringr::str_replace(x,"(\\d+)\\,(\\d+)\\smil","\\1\\200")
                     x = readr::parse_number(x)
                     return(x)
                   },
                   scroll_n = function(xpath = NA_character_, n = NA_integer_) {
                     pb <- progress::progress_bar$new(
                       format = paste0("Loading posts :n_posts/", n),
                       clear = FALSE, width = 90, total = Inf
                     )
                     n_posts <- 0L
                     pb$tick(tokens = list(n_posts = n_posts))
                     while (n_posts < n) {
                       private$session$executeScript("window.scrollTo(0, document.body.scrollHeight);")
                       n_posts <- length(private$session$findElements(xpath = xpath))
                       pb$tick(tokens = list(n_posts = n_posts))
                     }
                     pb$terminate()
                   },
                   load_more = function(xpath = NA_character_){
                     aux <- 0L
                     while (T) {
                       btn <- tryCatch({
                         suppressMessages(private$session$findElement(xpath = xpath))
                       },
                       error = function(msg) {
                         return(NULL)
                       }
                       )
                       if (is.null(btn)) {
                         break()
                       }

                       tryCatch({
                         suppressMessages(btn$click())
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
                 ))
