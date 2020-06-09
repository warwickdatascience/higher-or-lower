library(dplyr)
library(readr)

celeb_df <- read_csv('resources/sample_data.csv',
                     col_types = 'cdc')

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

initial_choice <- function() {
  celeb_1_visible <- sample(c(TRUE, FALSE), 1)
  celeb_1 = random_celeb(visible = celeb_1_visible)
  celeb_2 = random_celeb(exclude = celeb_1$name,
                         visible = !celeb_1_visible)
  return(list(celeb_1 = celeb_1, celeb_2 = celeb_2))
}
