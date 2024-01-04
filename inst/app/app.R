
library(shiny)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)

#load(here::here("inst","backend","calculate_daily_data.rdata"))
load("calculate_daily_data.rdata")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Forint inflációja a KSH 'Fogyasztói árindex , 1990. évi bázison' adatsora alapján"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            actionButton("log_y", "Log skála"),
            actionButton("lin_y", "Lin. skála"),
            hr(),
            numericInput(
              "START_AMOUNT",
              "Összeg értéke:",
              value = 10000
            ),
            checkboxInput("REVERSE", "A későbbi időpontban(?)",
                          value = FALSE),
            sliderInput("START_TIME",
                        "Korábbi időpont:",
                        min = as.Date("1992-01-01","%Y-%m-%d"),
                        max = as.Date("2023-01-01","%Y-%m-%d"),
                        value=as.Date("2019-05-04"),
                        timeFormat="%Y-%m-%d"),
            sliderInput("END_TIME",
                        "Későbbi időpont:",
                        min = as.Date("1992-01-01","%Y-%m-%d"),
                        max = as.Date("2023-10-30","%Y-%m-%d"),
                        value=as.Date("2023-10-01"),
                        timeFormat="%Y-%m-%d"),

            # Download button
            downloadButton("downloadData", "Adatsor letöltése (Napi bontás)"),

            # Add your discreet message at the bottom
            tags$hr(),  # Horizontal line for separation

            # Footer with discreet message and custom link
            tags$footer(

              tags$p("Ha megköszönnéd vagy kéne egy statisztikus:"),
              tags$a(href = "mailto:inquiries.mkmarton@gmail.com", "inquiries.mkmarton@gmail.com"),
              tags$p("Wallet: 0x253b92ccb486b0755b348d4b83b1c59e4819d034"),
              style = "font-size: 80%; color: grey; text-align: left;",  # Styling

              # Github link
              tags$p(
                tags$a(href = "https://github.com/MartynK/InflationAppHUF/", "Github repo"),
                style = "font-size: 80%; color: grey; text-align: center; padding-top: 10px;"
              ),

              # Author's link
              tags$p(
                tags$a(href = "https://www.linkedin.com/in/marton-kiss-md-29308a112/", "by Márton Kiss"),
                style = "font-size: 80%; color: grey; text-align: center; padding-top: 10px;"
              )
            )
        ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("orig_val"),
          textOutput("end_val"),
          plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  scale_y <- reactiveValues(scale="log")

  observeEvent(input$lin_y, {scale_y$scale<-"lin"})
  observeEvent(input$log_y, {scale_y$scale<-"log"})

  cpi_begin     <- reactive({
    dat$cpi[dat$time == input$START_TIME]
    })

  cpi_end     <- reactive({
    dat$cpi[dat$time == input$END_TIME]
  })


  dat_react <- reactive({
    if (input$REVERSE == TRUE) {
      dat %>%
        mutate(current_forints = input$START_AMOUNT / cpi_end() * cpi )
    } else {
      dat %>%
        mutate(current_forints = input$START_AMOUNT / cpi_begin() * cpi )
    }

  })

  value_early <- reactive({
    if (input$REVERSE == TRUE) {
      input$START_AMOUNT * cpi_begin() / cpi_end()
    } else {
      input$START_AMOUNT
    }
  })

  value_late <- reactive({
    if (input$REVERSE == TRUE) {
      input$START_AMOUNT
    } else {
      input$START_AMOUNT * cpi_end() /  cpi_begin()
    }
  })

  output$distPlot <- renderPlot({

    p <-
      dat_react() %>%
        ggplot( aes( x = time, y = current_forints)) +
        theme_bw() +
        theme( legend.position = "none") +
        geom_line()  +
        scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
        geom_hline( yintercept = value_early(), col = "salmon4") +
        geom_vline( xintercept = input$START_TIME, col = "salmon4") +
        geom_hline( yintercept = value_late(), col = "blue") +
        geom_vline( xintercept = input$END_TIME, col = "blue") +
        labs( x = "Dátum")

    if ( scale_y$scale == "lin") {
      p <- p +
             scale_y_continuous() +
             labs(y = "Nominális forint (lineáris skála)")
    } else if ( scale_y$scale == "log") {
      p <- p +
        scale_y_log10() +
        labs(y = "Nominális forint (log10-es skála)")
    }

    p

  })

  output$orig_val <- renderText({ value_early() %>% round() %>%
      paste0("Az összeg a korábbi időpontban: ",.," Ft") })
  output$end_val  <- renderText({
    value_late() %>% round() %>%
      paste0("Az összeg a későbbi időpontban: ",.," Ft")
  })

  # Server response for download
  output$downloadData <- downloadHandler(
    filename = function() {
      "calculate_daily_data.xlsx"
    },
    content = function(file) {
      file.copy("calculate_daily_data.xlsx", file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
