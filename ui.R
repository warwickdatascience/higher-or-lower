library(shiny)
library(shinydashboard)
library(shinyjs)

ui <- dashboardPage(
    dashboardHeader(
        title = "WDSS Presents: Higher or Lower",
        titleWidth = 350,
        tags$li(
            actionLink("openModal", label = "", icon = icon("question")),
            class = "dropdown"
        ),
        tags$li(
            a(
                href = NULL,
                icon("file-alt"),
                title = "Write-up",
                style = "cursor: pointer;"
            ),
            class = "dropdown"
        ),
        tags$li(
            a(
                href = NULL,
                icon("github"),
                title = "Source",
                style = "cursor: pointer;"
            ),
            class = "dropdown"
        )
    ),
    dashboardSidebar(disable = TRUE),
    dashboardBody(
        tags$head(
            tags$link(rel = 'stylesheet',
                      type = 'text/css',
                      href = 'style.css')
        ),
        tags$head(
            tags$script(
                '$(document).on("shiny:connected", function(e) {
             Shiny.onInputChange("page_width", window.innerWidth);
             Shiny.onInputChange("page_height", window.innerHeight);
         });
         $(window).resize(function(e) {
             Shiny.onInputChange("page_width", window.innerWidth);
             Shiny.onInputChange("page_height", window.innerHeight);
         });'
            )
        ),
        useShinyjs(),
        uiOutput('body_ui'),
        uiOutput('state_ui')
    )
)
