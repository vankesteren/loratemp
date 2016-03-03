shinyServer(function(input, output, session) {

  # Refresh the data every 5 seconds
  autoInvalidate <- reactiveTimer(5000, session)


  dataInput <- reactive({
    # Data refresh
    autoInvalidate()

    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030512/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 2, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600

    })
  # I use Plotly to draw the interactive table
  output$temp <- renderPlotly({

    autoInvalidate()

    # Get the data from the things network api
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030512/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 2, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600



    # Draw plot
    p <- plot_ly(x = tm, y = th[,2], name = "Temperature", color = "orange")
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
    temp <- fromJSON("http://thethingsnetwork.org/api/v0/nodes/02030512/")

    # Parse dataset
    ar <- strsplit(temp$data_plain, split = ", ")
    th <- matrix(as.numeric(unlist(ar)), ncol = 2, byrow = T)
    tm <- strptime(temp$time, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC") + 3600

    # Draw plot
    p <- plot_ly(x = tm, y = th[,1], name = "Temperature")
    l <- layout(p,
                yaxis = list(
                  range = c(25,55),
                  title = "Humidity (%)"
                  ),
                xaxis = list(
                  type = "Date",
                  title = "Time"
                )
                )

  })


})
