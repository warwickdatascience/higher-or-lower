library(shinyjs)
library(shinyWidgets)

server <- function(input, output, session) {

  # Setup initial game state
  celebs <- initial_choice()
  state <- reactiveValues(score = 0,
                          lives = 3,
                          celeb_1 = celebs[[1]],
                          celeb_2 = celebs[[2]])

  output$body_ui <- renderUI({
    req(input$page_width, input$page_height)
    if (input$page_width <= 750) {  # mobile layout
      box_height = (input$page_height - 100) / 2 - 38
    } else {  # desktop layout
      box_height = (input$page_height - 50) - 53
    }
      fluidRow(
        box(uiOutput('celeb_1_ui'), width = 6,
            height = box_height, background = 'red',
            id = 'celeb_1_box', class = 'celeb_box'),
        box(uiOutput('celeb_2_ui'), width = 6,
            height = box_height, background = 'blue',
            id = 'celeb_2_box', class = 'celeb_box'),
      )
  })

  output$state_ui <- renderUI({
    req(input$page_width)
    absolutePanel(
      bottom = 0,
      left = input$page_width / 2 - 100,
      width = 200,
      wellPanel(
        paste("Score:",
              state$score,
              "|",
              "Lives:",
              state$lives)
      )
    )
  })

  output$celeb_1_ui <- renderUI({create_celeb_ui(state$celeb_1)})
  output$celeb_2_ui <- renderUI({create_celeb_ui(state$celeb_2)})

  onclick('celeb_1_box', {
    update_state(
      clicked_celeb_id = 1,
      other_celeb_id = 2,
      state, session
    )
  })

  onclick('celeb_2_box', {
    update_state(
      clicked_celeb_id = 2,
      other_celeb_id = 1,
      state, session
    )
  })

  observeEvent(state$lives, {
    req(state$lives <= 0)
    confirmSweetAlert(
      title = "You're out of lives!",
      inputId = 'play_again',
      text = paste("Your final score was", state$score),
      session = session,
      type = 'warning',
      btn_labels = "Play again",
      btn_colors = '#3085d6'
    )
  })

  observeEvent(input$play_again, {
    celebs <- initial_choice()
    state$score <- 0
    state$lives <- 3
    state$celeb_1 <- celebs[[1]]
    state$celeb_2 <- celebs[[2]]
  })

  observeEvent(input$open_modal, {
    showModal(
      modalDialog(title = "Help",
                  p(paste(
                    "This web app implements a version of the game Higher or",
                    "lower using the follower counts of various celebrities.",
                    "You will be given the names of two celebrities, but only",
                    "the follower count for one of these. You then need to",
                    "guess which celebrity has the highest follower count and",
                    "select this by clicking on them. You get a point for",
                    "every correct response and lose on of your three lives",
                    "for each incorrect response. Make sure to check out the",
                    "write-up and source code for this project by following",
                    "the links in the navigation bar. Best of luck!"
                  )))
    )
  })
}
