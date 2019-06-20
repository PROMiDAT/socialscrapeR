#' @importFrom R6 R6Class
#' @export
tw_bot = R6::R6Class(classname = "twbot",
                     public = list(
                       initialize = function(){
                         private$server <- webdriver::run_phantomjs()
                         private$session <- webdriver::Session$new(port = private$server$port)
                         private$session$setTimeout(implicit = 10000)
                         private$session$go("https://twitter.com/login")
                       },
                       print = function(...) {
                         cat("<Twitter Bot>")
                       },
                       login = function(username = NA_character_, password = NA_character_){
                         user_input = private$session$findElement(xpath =  ".//div[@class = 'clearfix field']/input[@name = 'session[username_or_email]']")
                         user_input$clear()
                         user_input$sendKeys(username)
                         password_input = private$session$findElement(xpath = ".//div[@class = 'clearfix field']/input[@type = 'password']")
                         password_input$clear()
                         password_input$sendKeys(password)

                         submit_btn = private$session$findElement(xpath = ".//button[@type = 'submit']")
                         submit_btn$click()
                       },
                       takeScreenshot = function(){
                         private$session$takeScreenshot()
                       },
                       get_posts = function(pagename = NA_character_, n = NA_integer_){
                         url <- paste0("https://twitter.com/", pagename)
                         if(private$session$getUrl() != url) {
                           private$session$go(url)
                         }
                         private$scroll_n(xpath = ".//li[@data-item-type = 'tweet']", n)
                         page <- xml2::read_html(private$session$getSource()[[1]])

                         Sys.sleep(1)
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
                            private$session$executeScript("window.scrollTo(0, document.body.scrollHeight);")
                            n_posts <- length(private$session$findElements(xpath = xpath))
                            pb$tick(tokens = list(n_posts = n_posts))
                          }
                          pb$terminate()
                        }
                     ))
