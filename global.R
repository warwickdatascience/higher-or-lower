library(dplyr)
library(readr)

celeb_df <- read_csv('resources/sample_data.csv',
                     col_types = 'cdc')

#' Sample a random celebrity from the scraped data and return their details
#'
#' @param visible Whether the celebrity's follower count should be visible in
#' in the user interface
#' @param exclude A character vector of celebrity names that should not be
#' included in the random sample
#' @return A list containing the sampled celebrity's name, follower count,
#' path to their profile picture, and whether they should be visible in the UI
random_celeb <- function(visible, exclude = character()) {
  sample_df = celeb_df %>%
    filter(!name %in% exclude) %>%
    sample_n(1)

  list(
    name = sample_df$name,
    followers = sample_df$followers,
    image_path = sample_df$image_path,
    visible = visible
  )
}

#' Sample two unique celebrities from the and return their details
#'
#' @return A list containing the details of two unique celebrities, chosen at
#' random from the scraped data
initial_choice <- function() {
  celeb_1_visible <- sample(c(TRUE, FALSE), 1)
  celeb_1 = random_celeb(visible = celeb_1_visible)
  celeb_2 = random_celeb(exclude = celeb_1$name, visible = !celeb_1_visible)
  return(list(celeb_1 = celeb_1, celeb_2 = celeb_2))
}

#' Create the UI for a celebrity given a list of their details
#'
#' @param celeb A list of details for a celebrity
#' @return A collection of tags for the celebrity UI
create_celeb_ui <- function(celeb) {
  tags$div(
    class = 'celeb',
    tags$div(class = 'picture',
             tags$img(class = 'img-fluid', src = celeb$image_path)
    ),
    tags$div(
      class = 'details',
      tags$h4(class = 'celeb_name', celeb$name),
      tags$h4(class = 'followers', ifelse(celeb$visible,
                                          paste(celeb$followers,
                                                "followers"),
                                          ""))
    )
  )
}

update_state <- function(clicked_celeb_id, other_celeb_id, state, session) {
  clicked_celeb <- state[[paste0('celeb_', clicked_celeb_id)]]
  other_celeb <- state[[paste0('celeb_', other_celeb_id)]]
  if (clicked_celeb$visible) {
    hidden_celeb <- other_celeb$name
    hidden_followers <- other_celeb$followers
  } else {
    hidden_celeb <- clicked_celeb$name
    hidden_followers <- clicked_celeb$followers
  }
  if (clicked_celeb$followers >= other_celeb$followers) {
    sendSweetAlert(
      title = 'Spot on!',
      text = paste(hidden_celeb, "has", hidden_followers, "followers"),
      session = session,
      type = 'success',
      btn_labels = "Continue"
    )
    state$score <- state$score + 1
  } else {
    if (state$lives > 1) {
      sendSweetAlert(
        title = 'Not quite!',
        text = paste(hidden_celeb, "has", hidden_followers, "followers"),
        session = session,
        type = 'error',
        btn_labels = "Continue"
      )
    }
    state$lives <- state$lives - 1
  }
  if (clicked_celeb$visible) {
    state[[paste0('celeb_', other_celeb_id)]]$visible <- TRUE
    state[[paste0('celeb_', clicked_celeb_id)]] <-
      random_celeb(exclude = other_celeb$name, visible = FALSE)
  } else {
    state[[paste0('celeb_', clicked_celeb_id)]]$visible <- TRUE
    state[[paste0('celeb_', other_celeb_id)]] <-
      random_celeb(exclude = clicked_celeb$name, visible = FALSE)
  }
}
