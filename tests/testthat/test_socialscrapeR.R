context("Start Senelium Server")

invisible(capture.output(session <- start_server()))
test_that("Start server",{
  expect_is(session, "scrapeR_session")
})

context("Facebook Login")
test_that("incorrect credentials",{
  expect_error(invisible(capture.output(login_facebook(x = session, username = "correo", password = "clave"))))
})

invisible(capture.output(session <- login_facebook(x = session,
                                                   username = getOption("email"),
                                                   password = getOption("pass"))))

test_that("Correct credentials",{
  expect_is(session, "scrapeR_session")
})

context("Extract Facebook Posts")

invisible(capture.output(fb_data <- get_fb_posts(x = session, pagename = "crhoy.comnoticias", n = 10)))

test_that("Download 10 posts",{
  expect_true(nrow(fb_data)>=10)
})

invisible(capture.output(fb_data <- get_fb_posts(x = session,
                                                 pagename = "crhoy.comnoticias",
                                                 n = 10,
                                                 reactions = T)))
test_that("Download 10 posts with reactions",{
  expect_is(fb_data, "tbl_df")
  expect_true(nrow(fb_data)>=10 & ncol(fb_data) == 13)
})

invisible(capture.output(fb_data <- get_fb_posts(x = session,
                                                 pagename = "crhoy.comnoticias",
                                                 n = 10,
                                                 reactions = T,
                                                 commets = T)))
test_that("Download 10 posts with reactions and comments",{
  expect_is(fb_data, "tbl_df")
  expect_true(nrow(fb_data)>=10 & ncol(fb_data) == 14)
})

invisible(capture.output(fb_data <- get_fb_posts(x = session,
                                                 pagename = "crhoy.comnoticias",
                                                 n = 10,
                                                 reactions = T,
                                                 commets = T,
                                                 shares = T)))
test_that("Download 10 posts with reactions, comments and shares",{
  expect_is(fb_data, "tbl_df")
  expect_true(nrow(fb_data)>=10 & ncol(fb_data) == 15)
})

context("Stop Selenium Server")
invisible(capture.output(session <- stop_server(session)))
test_that("Stop server",{
  expect_equal(session, NULL)
})
