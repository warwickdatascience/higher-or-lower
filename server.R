library(shinyjs)
library(shinyWidgets)

server <- function(input, output, session) {

  celebs <- initial_choice()
  state <- reactiveValues(score = 0,
                          lives = 3,
                          celeb_1 = celebs[[1]],
                          celeb_2 = celebs[[2]])

  output$body_ui <- renderUI({
    req(input$page_width, input$page_height)
    if (input$page_width <= 750) {
      box_height = (input$page_height - 100) / 2 - 38
    } else {
      box_height = (input$page_height - 50) - 53
    }
      fluidRow(
        tags$div(id = 'celeb_1_box',
                 box(uiOutput('celeb_1_ui'), width = 6,
                     height = box_height, background = 'red',
                     id = 'celeb_1_box_inner'),
                 style = "cursor: pointer;"),
        tags$div(id = 'celeb_2_box',
                 box(uiOutput('celeb_2_ui'), width = 6,
                     height = box_height, background = 'blue'),
                 style = "cursor: pointer;")
      )
  })

  output$state_ui <- renderUI({
    req(input$page_width)
    absolutePanel(
      bottom = 10,
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

  output$celeb_1_ui <- renderUI({
    tags$div(
      class = 'celeb',
      tags$div(class = 'picture',
               tags$img(class = 'img-fluid', src = state$celeb_1$image_path)
      ),
      tags$div(
        class = 'details',
        tags$h4(class = 'celeb_name', state$celeb_1$name),
        tags$h4(class = 'followers', ifelse(state$celeb_1$visible,
                                            paste(state$celeb_1$followers,
                                                  "followers"),
                                            ""))
      )
    )
  })

  output$celeb_2_ui <- renderUI({
    tags$div(
      class = 'celeb',
      tags$div(class = 'picture',
               tags$img(class = 'img-fluid', src = state$celeb_2$image_path)
      ),
      tags$div(
        class = 'details',
        tags$h4(class = 'celeb_name', state$celeb_2$name),
        tags$h4(class = 'followers', ifelse(state$celeb_2$visible,
                                            paste(state$celeb_2$followers,
                                                  "followers"),
                                            ""))
      )
    )
  })

  onclick('celeb_1_box', {
    if (state$celeb_1$visible) {
      hidden_celeb <- state$celeb_2$name
      hidden_followers <- state$celeb_2$followers
    } else {
      hidden_celeb <- state$celeb_1$name
      hidden_followers <- state$celeb_1$followers
    }
    if (state$celeb_1$followers >= state$celeb_2$followers) {
      sendSweetAlert(
        title = 'Spot on!',
        text = paste(hidden_celeb, "has", hidden_followers, "followers"),
        session = session,
        type = 'success',
        btn_labels = "Continue"
      )
      state$score <- state$score + 1
    } else {
      sendSweetAlert(
        title = 'Not quite!',
        text = paste(hidden_celeb, "has", hidden_followers, "followers"),
        session = session,
        type = 'error',
        btn_labels = "Continue"
      )
      state$lives <- state$lives - 1
    }
    if (state$celeb_1$visible) {
      state$celeb_2$visible <- TRUE
      state$celeb_1 <- random_celeb(exclude = state$celeb_2$name,
                                    visible = FALSE)
    } else {
      state$celeb_1$visible <- TRUE
      state$celeb_2 <- random_celeb(exclude = state$celeb_1$name,
                                    visible = FALSE)
    }
  })

  onclick('celeb_2_box', {
    if (state$celeb_2$visible) {
      hidden_celeb <- state$celeb_1$name
      hidden_followers <- state$celeb_1$followers
    } else {
      hidden_celeb <- state$celeb_2$name
      hidden_followers <- state$celeb_2$followers
    }
    if (state$celeb_2$followers >= state$celeb_1$followers) {
      sendSweetAlert(
        title = 'Spot on!',
        text = paste(hidden_celeb, "has", hidden_followers, "followers"),
        session = session,
        type = 'success',
        btn_labels = "Continue"
      )
      state$score <- state$score + 1
    } else {
      sendSweetAlert(
        title = 'Not quite!',
        text = paste(hidden_celeb, "has", hidden_followers, "followers"),
        session = session,
        type = 'error',
        btn_labels = "Continue"
      )
      state$lives <- state$lives - 1
    }
    if (state$celeb_1$visible) {
      state$celeb_2$visible <- TRUE
      state$celeb_1 <- random_celeb(exclude = state$celeb_2$name,
                                    visible = FALSE)
    } else {
      state$celeb_1$visible <- TRUE
      state$celeb_2 <- random_celeb(exclude = state$celeb_1$name,
                                    visible = FALSE)
    }
  })

  observeEvent(state$lives, {
    req(state$lives <= 0)
    sendSweetAlert(
      title = "You're out of lives!",
      text = paste("Your final score was", state$score),
      session = session,
      type = 'warning',
      btn_labels = "Play again"
    )

    celebs <- initial_choice()
    state$score <- 0
    state$lives <- 3
    state$celeb_1 <- celebs[[1]]
    state$celeb_2 <- celebs[[2]]
  })

  observeEvent(input$openModal, {
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
