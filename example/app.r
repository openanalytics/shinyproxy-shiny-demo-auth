library(shiny)
library(bslib)
library(rlang)

ui <- page_fixed(
  tags$br(),
  titlePanel("Shiny in ShinyProxy auth demo"),
  tags$br(),
  p("This page demonstrates how to access the username and groups of the current user when using ShinyProxy. Using the environment variables will only work when not using container pre-initialization or sharing. On the other hand, using the HTTP headers is always possible."),
  tags$br(),
  layout_columns(
    col_widths = c(6, 6, 6, 6, 12, 12),
    card(
      card_header("Username using environment variable"),
      code('Sys.getenv("SHINYPROXY_USERNAME)'),
      tags$b("Output:"),
      verbatimTextOutput("env_username")
    ),
    card(
      card_header("Groups using environment variable"),
      code('Sys.getenv("SHINYPROXY_USERGROUPS)'),
      tags$b("Output:"),
      verbatimTextOutput("env_groups")
    ),
    card(
      card_header("Username using HTTP header"),
      code('session$request$HTTP_X_SP_USERID'),
      tags$b("Output:"),
      verbatimTextOutput("header_username")
    ),
    card(
      card_header("Groups using HTTP header"),
      code('session$request$HTTP_X_SP_USERGROUPS'),
      tags$b("Output:"),
      verbatimTextOutput("header_groups")
    ),
    card(
      card_header("All environment variables"),
      tags$b("Output:"),
      verbatimTextOutput("all_env")
    ),
    card(
      card_header("All HTTP headers"),
      tags$b("Output:"),
      verbatimTextOutput("all_headers")
    )
  )
)

server <- function(input, output, session) {

  output$env_username <- renderText({ Sys.getenv("SHINYPROXY_USERNAME") })
  output$env_groups <- renderText({ Sys.getenv("SHINYPROXY_USERGROUPS") })
  output$all_env <- renderPrint({ Sys.getenv() })
  output$header_username <- renderText({ session$request$HTTP_X_SP_USERID })
  output$header_groups <- renderText({ session$request$HTTP_X_SP_USERGROUPS })
  output$all_headers <- renderPrint({ mget(ls(session$request, pattern = "HTTP_.*"), envir = session$request) })

}

shinyApp(ui, server)
