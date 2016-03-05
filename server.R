shinyServer(function(input, output, session) {


  #Refresh the graph every 7.5 minutes
  autoInvalidate <- reactiveTimer(450000, session)


  # I use Plotly to draw the interactive table
  output$temp <- renderPlotly({

    autoInvalidate()

    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030592/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 3, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600



    # Draw plot
    p <- plot_ly(x = tm, y = th[,2], name = "Temperature",
                  line = list(
                    shape = "spline",
                    color = "#C72037"
                    ))
    l <- layout(p,
                yaxis = list(
                  range = c(min(th[,2])-3,max(th[,2])+3),
                  title = "Temperature (Celcius)"
                  ),
                xaxis = list(
                  type = "Date",
                  title = "Time"
                )
                )

  })
  # I use Plotly to draw the interactive table
  output$humid <- renderPlotly({

    autoInvalidate()

    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030592/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 3, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600

    # Draw plot
    p <- plot_ly(x = tm, y = th[,1], name = "Humidity",
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
    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030592/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 3, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600

    if (th[1,3] > 4200){
      return(paste("Battery Full: ", as.character(th[1,3]), " Volts"))
    } else if (th[1,3] > 4000){
      return(paste("Battery Good: ", as.character(th[1,3]), " Volts"))
    } else if (th[1,3] > 3700){
      return(paste("Battery O.K.: ", as.character(th[1,3]), " Volts"))
    } else if (th[1,3] > 3400){
      return(paste("Battery Low: ", as.character(th[1,3]), " Volts"))
    } else {
      return(paste("Battery Very Low: ", as.character(th[1,3]), " Volts"))
    }
  })

})
