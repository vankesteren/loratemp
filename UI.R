library(shiny)
library(jsonlite)
library(stringr)
library(plotly)

shinyUI(fluidPage(theme = "bootstrap.css",

footer = "(c) Erik-Jan van Kesteren",

# Title
fluidRow(
  column(8, offset = 2,
         h1("Data from LoRa Sensor", align = "center"),
         h6(textOutput("battery"),
            align = "center"),
         fluidRow(
           column(6, offset = 3,
             checkboxInput("battery", NULL, value = F),
             conditionalPanel("input.battery == 1",
                              plotlyOutput("voltage",
                                           width = "80%",
                                           height = 170)
                              )
             )
           ),
         hr(),
         br()
        )
),

fluidRow(
  # Plot
  column(6,
         plotlyOutput("temp")
  ),
  column(6,
        plotlyOutput("humid")
  )

),

fluidRow(
  column(8, offset = 2,
          br(),
          hr(),
          br(),
          h6("(c) Erik-Jan van Kesteren", align = "center")
    )

  ),

tags$script(src = 'center.js')
))
