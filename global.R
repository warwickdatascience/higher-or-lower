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
