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
         br(),
         hr(),
         br()
        )
),

fluidRow(

  # # Checkbox
  # column(2,
  #       sidebarPanel(
  #         checkboxInput("battery", "Check Battery", value = F),
  #         conditionalPanel("input.battery == 1",
  #                          h6(textOutput("battery"),
  #                             align = "center")
  #                         ),
  #         width = 12
  #       )
  # ),

  # Plot
  column(6,
         plotlyOutput("temp")
  ),
  column(6,
        plotlyOutput("humid")
  )

)

))
