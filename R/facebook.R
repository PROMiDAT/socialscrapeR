
#' Login in facebook
#'
#' @param x scrapeR_session
#' @param username facebook email
#' @param password facebook password
#' @importFrom crayon silver
#' @importFrom rlang abort
#' @export
login_facebook <- function(x = NULL, username = NA_character_, password = NA_character_) {
  if (is.na(username)) {
    abort_is_na("username")
  }
  if (is.na(username)) {
    abort_is_na("usarname")
  }
  if (is.na(password)) {
    abort_is_na("password")
  }

  if (is.null(x)) {
    abort_server_not_found()
  }

  if (!is.character(username)) {
    abort_bad_argument(arg = "username", must = character(), not = username)
  }
  tryCatch({
    if (x$session$getCurrentUrl() != "https://m.facebook.com") {
      navigate(x = x, url = "https://m.facebook.com")
    }
    x$session$setImplicitWaitTimeout(milliseconds = 10000)
    email.input <- x$session$findElement(using = "xpath", value = ".//input[@id = 'm_login_email']")
    password.input <- x$session$findElement(using = "xpath", value = ".//input[@id = 'm_login_password']")

    email.input$sendKeysToElement(list(username))
    password.input$sendKeysToElement(list(password))

    submit <- x$session$findElement(using = "id", value = "u_0_5")
    submit$clickElement()

    skip <- suppressMessages(x$session$findElement(using = "partial link text", value = "Ahora no"))
    skip$clickElement()
    cat(crayon::silver(paste0("Se inici\u00F3n sesi\u00F3n en https://m.facebook.com con el usuario ", username, "\n")))
  }, error = function(msg) {
    rlang::abort(paste0("\u2716 No se pudo iniciar sesi\u00F3n en https://m.facebook.com con el usuario ", username, "; verifique el usuario y la contrase\u00F1a\n"))
  })
  return(invisible(x))
}

#' get_reactions_by_user_
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_nodes html_attr html_text
#' @importFrom stringr str_extract str_detect
#' @importFrom dplyr case_when %>%
#' @importFrom tibble tibble
#' @importFrom rlang abort
#' @keywords internal
get_reactions_by_user_ <- function(x = NULL, post_id = NA_character_) {
  if (is.null(x)) {
    abort_server_not_found()
  }
  if (is.na(post_id)) {
    abort_is_na("post_id")
  }
  if (!is.character(post_id)) {
    abort_bad_argument(arg = "post_id", must = character(), not = post_id)
  }

  out <- tryCatch({
    url <- paste0("https://m.facebook.com/ufi/reaction/profile/browser/?ft_ent_identifier=", post_id)
    navigate(x = x, url = url, silence = T)
    load_more(x, xpath = ".//a[@data-sigil = 'touchable ajaxify']")

    page <- xml2::read_html(x$session$getPageSource()[[1]])

    reactions <- page %>% rvest::html_nodes(xpath = ".//div[@class = '_1uja _59qr'] | .//div[@class = '_1uja']")
    full_name <- reactions %>% rvest::html_node(xpath = ".//div[@class = '_4mo']") %>% rvest::html_text()
    user_name <- reactions %>%
      rvest::html_node(xpath = ".//div[@class = '_4mn c']/a") %>%
      rvest::html_attr("href") %>%
      stringr::str_extract("(^\\/profile.php\\?id\\=\\d+|^\\/(\\w|\\.|\\d)+(?=\\?|\\/))")
    type_reaction <- reactions %>% rvest::html_node(xpath = "./i") %>% rvest::html_attr("class")

    type_reaction <- dplyr::case_when(
      stringr::str_detect(type_reaction, "sx_216bdc") ~ "like",
      stringr::str_detect(type_reaction, "sx_1329b8") ~ "love",
      stringr::str_detect(type_reaction, "sx_07c8dd") ~ "wow",
      stringr::str_detect(type_reaction, "sx_6f3ed0") ~ "haha",
      stringr::str_detect(type_reaction, "sx_e2bf5f") ~ "sad",
      stringr::str_detect(type_reaction, "sx_a05db9") ~ "angry",
      T ~ NA_character_
    )
    tibble::tibble(post_id, full_name, user_name, type_reaction)
  }, error = function(msg) {
    rlang::abort(paste0("\u2716 No se pudo extraer las recciones por usuario para el post ", post_id))
  })

  return(out)
}


#' Get reactions by user
#'
#' @param x scrapeR_session
#' @param post_id facebook post id
#'
#' @importFrom purrr map_df
#' @importFrom progress progress_bar
#' @export
get_reactions_by_user <- function(x = NULL, post_id = NA_character_) {
  pb <- progress::progress_bar$new(
    format = "Extrayendo reacciones por usuario [:bar :percent] :current/:total publicaciones ",
    clear = FALSE, width = 90, total = length(post_id)
  )
  out <- purrr::map_df(post_id, ~ {
    pb$tick()
    out <- suppressWarnings(get_reactions_by_user_(x, .x))
    return(out)
  })
  return(out)
}

#' get_reactions_
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_nodes html_text
#' @importFrom tidyr nest
#' @importFrom dplyr rename left_join
#' @importFrom tibble tibble
#' @importFrom rlang abort
#' @keywords internal
get_reactions_ <- function(x = NULL, page_id = NA_character_, post_id = NA_character_, silence = T) {
  if (is.null(x)) {
    abort_server_not_found()
  }
  if (is.na(page_id)) {
    abort_is_na("page_id")
  }
  if (!is.character(page_id)) {
    abort_bad_argument(arg = "page_id", must = character(), not = page_id)
  }
  if (is.na(post_id)) {
    abort_is_na("post_id")
  }
  if (!is.character(post_id)) {
    abort_bad_argument(arg = "post_id", must = character(), not = post_id)
  }

  url <- paste0("https://m.facebook.com/ufi/reaction/profile/browser/?ft_ent_identifier=", post_id)

  out <- tryCatch({
    x %>% navigate(url, silence)
    page <- xml2::read_html(x$session$getPageSource()[[1]])
    like <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":1}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)
    love <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":2}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)
    wow <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":3}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)
    haha <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":4}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)
    sad <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":7}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)
    angry <- page %>%
      rvest::html_node(xpath = ".//span[@data-store = '{\"reactionType\":8}']") %>%
      rvest::html_text() %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)

    reactions <- get_reactions_by_user_(x = x, post_id = post_id)
    reactions <- tidyr::nest(reactions, -post_id)
    reactions <- dplyr::rename(reactions, "reactions_by_user" = "data")


    df <- tibble::tibble(page_id, post_id, like, love, wow, haha, sad, angry)
    df <- dplyr::left_join(df, reactions, by = "post_id")
    return(df)
  }, error = function(msg) {
    rlang::abort(paste0("\u2716 No se pudo obtener las reacciones del post ", post_id))
  })
  return(out)
}


#' Get reactions
#'
#' @param x scrapeR_session
#' @param page_id page id
#' @param post_id post id
#' @param silence otro
#' @importFrom progress progress_bar
#' @importFrom purrr map2_df
#' @export
get_reactions <- function(x = NULL, page_id = NA_character_, post_id = NA_character_, silence = T) {
  pb <- progress::progress_bar$new(
    format = "Extrayendo reacciones ... :current/:total publicaciones ",
    clear = FALSE, width = 90, total = length(post_id)
  )

  out <- purrr::map2_df(page_id, post_id, ~ {
    out <- get_reactions_(x = x, page_id = .x, post_id = .y, silence = silence)
    pb$tick()
    return(out)
  })

  return(out)
}

#' get_comments_
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom stringr str_remove_all str_to_lower str_extract
#' @importFrom tibble tibble
#' @importFrom rlang abort
#' @keywords internal
get_comments_ <- function(x = NULL, page_id = NA_character_, post_id = NA_character_) {
  if (is.null(x)) {
    abort_server_not_found()
  }
  if (is.na(page_id)) {
    abort_is_na("page_id")
  }
  if (!is.character(page_id)) {
    abort_bad_argument(arg = "page_id", must = character(), not = page_id)
  }
  if (is.na(post_id)) {
    abort_is_na("post_id")
  }
  if (!is.character(post_id)) {
    abort_bad_argument(arg = "post_id", must = character(), not = post_id)
  }

  out <- tryCatch({
    url <- paste0("https://m.facebook.com/story.php?story_fbid=", post_id, "&id=", page_id)
    navigate(x = x, url = url, silence = T)
    load_more(x, xpath = ".//a[@data-sigil = 'ajaxify']")
    page <- xml2::read_html(x$session$getPageSource()[[1]])
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

    tibble::tibble(page_id, post_id, text, full_name, user_name)
  }, error = function(msg) {
    rlang::abort(paste0("\u2716 No se pudo obtener los comentarios del post ", post_id))
  })

  return(out)
}


#' Get Facebook comments
#'
#' @param x scrapeR_session objetc
#' @param page_id facebook page id
#' @param post_id facebook post id
#' @importFrom progress progress_bar
#' @importFrom purrr map2_df
#' @export
get_comments <- function(x = NULL, page_id = NA_character_, post_id = NA_character_) {
  pb <- progress::progress_bar$new(
    format = "Extrayendo comentarios ... :current/:total publicaciones ",
    clear = FALSE, width = 90, total = length(post_id)
  )
  pb$tick(0)
  out <- purrr::map2_df(page_id, post_id, ~ {
    out <- suppressWarnings(get_comments_(x, .x, .y))
    pb$tick(1)
    return(out)
  })
  return(out)
}

#' get_shares_
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom stringr str_remove_all str_to_lower str_extract
#' @importFrom tibble tibble
#' @importFrom rlang abort
#' @keywords internal
get_shares_ <- function(x = NULL, page_id = NA_character_, post_id = NA_character_) {

  if (is.null(x)) {
    abort_server_not_found()
  }
  if (is.na(page_id)) {
    abort_is_na("page_id")
  }
  if (!is.character(page_id)) {
    abort_bad_argument(arg = "page_id", must = character(), not = post_id)
  }
  if (is.na(post_id)) {
    abort_is_na("post_id")
  }
  if (!is.character(post_id)) {
    abort_bad_argument(arg = "post_id", must = character(), not = post_id)
  }

  out <- tryCatch({
    url <- paste0("https://m.facebook.com/browse/shares?id=",post_id)
    navigate(x = x, url = url, silence = T)
    page <- xml2::read_html(x$session$getPageSource()[[1]])
    shares <- page %>% rvest::html_nodes(xpath = ".//div[@class = '_1uja _xon']")
    full_name <- shares %>% rvest::html_node(xpath = ".//div[@class = '_4mo']") %>% rvest::html_text()
    user_name <- shares %>%
      rvest::html_node(xpath = ".//div[@class = '_4mn c']/a") %>%
      rvest::html_attr("href") %>%
      stringr::str_extract("(^\\/profile.php\\?id\\=\\d+|^\\/(\\w|\\.|\\d)+(?=\\?|\\/))")
    tibble::tibble(page_id, post_id,full_name,user_name)
  })
  return(out)
}

#' Get shares
#'
#' @param x session
#' @param page_id page id
#' @param post_id post id
#' @importFrom progress progress_bar
#' @importFrom purrr map2_df
#' @export
get_shares <- function(x = NULL, page_id = NA_character_, post_id = NA_character_) {
  pb <- progress::progress_bar$new(
    format = "Extrayendo compartidos ... :current/:total publicaciones ",
    clear = FALSE, width = 90, total = length(post_id)
  )
  pb$tick(0)
  out <- purrr::map2_df(page_id, post_id, ~ {
    out <- suppressWarnings(get_shares_(x, .x, .y))
    pb$tick(1)
    return(out)
  })
  return(out)
}

#' Get Facebook post
#'
#' @param x session
#' @param pagename page name
#' @param n n of posts
#' @param reactions if TRUE add reactions
#' @param commets if TRUE add comments
#' @param shares if TRUE add shares
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom stringr str_extract str_to_lower str_remove_all
#' @importFrom lubridate as_datetime
#' @importFrom tibble tibble
#' @importFrom dplyr left_join select everything rename
#' @importFrom tidyr nest
#' @export
get_fb_posts <- function(x = NULL, pagename = NA_character_, n = 10L, reactions = FALSE, commets = FALSE, shares = FALSE) {
  if (is.null(x)) {
    abort_server_not_found()
  }
  if (!is.character(pagename)) {
    abort_bad_argument(arg = "pagename", must = character(), not = pagename)
  }
  if (is.na(pagename)) {
    abort_is_na("pagename")
  }
  if (is.na(n)) {
    abort_is_na("n")
  }
  if (!is.numeric(n)) {
    abort_bad_argument(arg = "n", must = integer(), not = n)
  }
  if (!is.logical(reactions)) {
    abort_bad_argument(arg = "reactions", must = logical(), not = reactions)
  }
  if (!is.logical(commets)) {
    abort_bad_argument(arg = "commets", must = logical(), not = commets)
  }

  out <- tryCatch({
    url <- paste0("https://m.facebook.com/", pagename)
    x %>% navigate(url)
    scroll_n(x, xpath = ".//div[@class = '_55wo _56bf _58k5']", n)
    page <- xml2::read_html(x$session$getPageSource()[[1]])

    post_text <- rvest::html_nodes(page, xpath = ".//div[@class = '_55wo _56bf _58k5']") %>%
      rvest::html_node(xpath = ".//div[@class = 'story_body_container']") %>%
      rvest::html_node(xpath = ".//div[1]//span/p") %>%
      rvest::html_text() %>%
      stringr::str_to_lower() %>%
      stringr::str_remove_all("\\p{So}|\\p{Cn}")

    n_comments <- rvest::html_nodes(page, xpath = ".//div[@class = '_55wo _56bf _58k5']") %>%
      rvest::html_node(xpath = ".//footer//div[@class = '_1fnt']/span[@data-sigil = 'comments-token']") %>%
      rvest::html_text() %>%
      stringr::str_extract("\\d+") %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)

    n_shares <- rvest::html_nodes(page, xpath = ".//div[@class = '_55wo _56bf _58k5']") %>%
      rvest::html_node(xpath = ".//footer//div[@class = '_1fnt']//span[not(@data-sigil)]") %>%
      rvest::html_text() %>%
      stringr::str_extract("\\d+") %>%
      as.integer() %>%
      ifelse(is.na(.), 0L, .)


    info <- rvest::html_nodes(page, xpath = ".//div[@class = '_3drp']//article") %>%
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



    df <- tibble::tibble(page_id, post_id, post_text, n_comments, n_shares, date_time)

    if (reactions) {
      reactions <- get_reactions(x = x, page_id = page_id, post_id = post_id, silence = T)
      df <- dplyr::left_join(df, reactions, by = c("page_id", "post_id"))
      df <- df %>% dplyr::select(-date_time, dplyr::everything())
    }

    if (commets) {
      comments <- get_comments(x = x, page_id = page_id, post_id = post_id)
      comments <- tidyr::nest(comments, -c("page_id", "post_id"))
      comments <- dplyr::rename(comments, "comments" = "data")
      df <- dplyr::left_join(df, comments, by = c("page_id", "post_id"))
      df <- df %>% dplyr::select(-date_time, dplyr::everything())
    }

    if(shares) {
      shares <- get_shares(x = x, page_id = page_id, post_id = post_id)
      shares <- tidyr::nest(shares, -c("page_id", "post_id"))
      shares <- dplyr::rename(shares, "shares" = "data")
      df <- dplyr::left_join(df, shares, by = c("page_id", "post_id"))
      df <- df %>% dplyr::select(-date_time, dplyr::everything())
    }
    return(df)
  })
  return(out)
}


#' Get public user info
#'
#' @param x session
#' @param username username
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text
#' @importFrom tibble tibble
#' @importFrom stringr str_extract
#' @importFrom gender gender
#' @export
get_user_info <- function(x = NULL, username = NA_character_) {
  tryCatch({
    url <- paste0("https://m.facebook.com", username, "/about")
    x$session$navigate(url)
    page <- xml2::read_html(x$session$getPageSource()[[1]])
    full_name <- page %>%
      rvest::html_node(xpath = ".//a[@data-sigil = 'MBackNavBarClick']") %>%
      rvest::html_text()
    location <- page %>%
      rvest::html_node(xpath = ".//div[@title = 'Direcci\u00F3n']//div[@class = '_5cdv r']") %>%
      rvest::html_text(trim = T)
    birthdate <- page %>%
      rvest::html_node(xpath = ".//div[@title = 'Fecha de nacimiento']//div[@class = '_5cdv r']") %>%
      rvest::html_text(trim = T)
    education <- page %>%
      rvest::html_node(xpath = ".//div[@id = 'education']//div[@class = '_5cds _2lcw']//span") %>%
      rvest::html_text()

    relationship <- page %>%
      rvest::html_node(xpath = ".//div[@id = 'relationship']/div//div") %>%
      rvest::html_text()

    gender <- gender::gender(stringr::str_extract(full_name,"^\\S+"))$gender

    tibble::tibble(full_name, username, location, birthdate, education, gender, relationship)
  },
  error = function() return(NULL)
  )
}
