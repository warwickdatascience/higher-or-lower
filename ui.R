library(shiny)
library(shinydashboard)
library(shinyjs)

ui <- dashboardPage(
    dashboardHeader(
        title = "WDSS Presents: Higher or Lower",
        titleWidth = 350,
        tags$li(
            actionLink(
                "open_modal",
                label = "",
                title = "Help",
                icon = icon("question")
            ),
            class = "dropdown"
        ),
        tags$li(
            a(
                href = paste0('https://research.warwickdatascience.com/',
                              'higher-or-lower'),
                target = '_blank',
                icon("file-alt"),
                title = "Write-up",
            ),
            class = "dropdown"
        ),
        tags$li(
            a(
                href = paste0('https://github.com/warwickdatascience/',
                              'higher-or-lower'),
                target = '_blank',
                icon("github"),
                title = "Source",
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
            # Setup Javascript to create responsive layout
            tags$script('
                $(document).on("shiny:connected", function(e) {
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
