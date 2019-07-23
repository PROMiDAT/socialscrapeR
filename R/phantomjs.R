#' Install PhantomJS
#'
#' @param version The version number of PhantomJS
#' @param baseURL The base URL for the location of PhantomJS binaries for download.
#'
#' @importFrom webdriver install_phantomjs
#' @export
install_phantomjs <- function(version = "2.1.1", baseURL = "https://github.com/wch/webshot/releases/download/v0.3.1/"){
  webdriver::install_phantomjs(version, baseURL)
}
