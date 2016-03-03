library(shiny)
library(jsonlite)
library(stringr)
library(plotly)

shinyUI(fluidPage(theme = "bootstrap.css",
                  
footer = "(c) Erik-Jan van Kesteren",

# Title
fluidRow(
  column(8, offset = 2,
         h1("Data from LoRa Sensor", align = "center")
        )
),

fluidRow(
  
  # Checkbox
  column(2,
        sidebarPanel(
          checkboxInput("update", "Automatically Update Data", value = T),
          conditionalPanel("input.update == 1", 
                           h6("Data is updated every 10 seconds", 
                              align = "center")
                           ),
          width = 12
        )
  ),
  
  # Plot
  column(10,
         plotlyOutput("temp")
  )
)

))