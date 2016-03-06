shinyServer(function(input, output, session) {


  dataInput <- reactive({
    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030592/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    df <- as.data.frame(matrix(as.numeric(unlist(ar)), ncol = 3, byrow = T))
    df$tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600

    return(df)
    })


  # I use Plotly to draw the interactive table
  output$temp <- renderPlotly({

    # Draw plot
    p <- plot_ly(x = dataInput()$tm, y = dataInput()[,2], name = "Temperature",
                  line = list(
                    shape = "spline",
                    color = "#C72037"
                    ))
    l <- layout(p,
                yaxis = list(
                  range = c(min(dataInput()[,2])-3,max(dataInput()[,2])+3),
                  title = "Temperature (Celcius)"
                  ),
                xaxis = list(
                  type = "Date",
                  title = "Time"
                )
                )

  })


  output$humid <- renderPlotly({
    # Draw plot
    p <- plot_ly(x = dataInput()$tm, y = dataInput()[,1], name = "Humidity",
                  line = list(
                    shape = "spline",
                    color = "#31CFE9"
                    ))
    l <- layout(p,
                yaxis = list(
                  range = c(22,55),
                  title = "Humidity (%)"
                  ),
                xaxis = list(
                  type = "Date",
                  title = "Time"
                )
                )

  })

  output$battery <- renderText({

    volt <- dataInput()[1,3]

    if (volt > 4200){
      return(paste("Battery Full: ", as.character(volt), " Volts"))
    } else if (volt > 3700){
      return(paste("Battery Good: ", as.character(volt), " Volts"))
    } else if (volt > 3600){
      return(paste("Battery O.K.: ", as.character(volt), " Volts"))
    } else if (volt > 3500){
      return(paste("Battery Low: ", as.character(volt), " Volts"))
    } else {
      return(paste("Battery Very Low: ", as.character(volt),
                   " Volts"))
    }
  })

  output$voltage <- renderPlotly({
    # Draw plot
    p <- plot_ly(x = dataInput()[,4], y = dataInput()[,3], name = "Voltage",
                  line = list(
                    shape = "spline",
                    color = "#EFF248"
                    ))
    l <- layout(p,
                yaxis = list(
                  title = "",
                  showticklabels = F,
                  showgrid = F,
                  displayModeBar = F
                  ),
                xaxis = list(
                  type = "Date",
                  title = "",
                  showticklabels = F,
                  showgrid = F
                )
                )

  })

})
