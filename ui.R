library(shiny)


shinyUI(fluidPage(
    titlePanel("Text-to-Speech Application"),
    
    sidebarLayout(
        sidebarPanel(
            h3("Settings"),
            selectInput("language", "Language", choices = 'none'),
            selectInput("voice", "Voice", choices = 'none')
        ),
        mainPanel(
            textInput("caption", "Enter text"),
            actionButton("gobutton", "submit"),
            uiOutput("play")
        )
    )
))
