library(flacco)
library(shiny)
library(smoof)
`%then%` <- shiny:::`%OR%`


#' Shiny component for Smoof-Function Input
#'
#' \code{SmoofFunctionPage} is a shiny component which can be added to your shiny app
#' so that you can put in a smoof function and calculate flacco features after that
#'
#'
#'@param id ID for the shiny component
#'@export
SmoofFunctionPage <- function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput(ns("smoof_function_select"),label="Function name",choices=filterFunctionsByTags("single-objective")),
      splitLayout(
        numericInput(ns("dimension_size"),label="Dimensions",value=1),
        selectInput(ns("sampletype"),label="Sample type",choices=c("random","lhs"))),

      splitLayout( #put lower and upper bound in one line
        numericInput(ns("samplelow"),label="Lower bound", value=0),
        numericInput(ns("sampleup"), label="Upper bound", value=1)),
      sliderInput(ns("ssize"),
                  "Sample size",
                  min = 100,
                  max = 10000,
                  value = 30),
      selectInput(ns("smoof_function_featureSet"),label="Feature Set",choices=listAvailableFeatureSets()),
      downloadButton(ns('smoof_function_downloadData'), 'Download')
    ),
    # Show a table with the generated features
    mainPanel(
      tableOutput(ns("smoof_function_FeatureTable"))
    )
  )
}


#' Shiny server function for BBOB import page module
#'
#' \code{SmoofFunctionInput} is a Shiny server function which will control all aspects
#' of the SmoofFunctionPage UI Module. Will be called with \code{callModule()}
#'
#' @param input Shiny input variable for the specific UI module
#' @param output Shiny output variable for the specific UI module
#' @param session Shiny session variable for the specific UI module
#' @param stringAsFactors
#'
#' @export
#'
SmoofFunctionInput <- function(input, output, session, stringsAsFactors) {
  # smoofFunctionPage  is using the smoof package for implementing them
  if (!requireNamespace("smoof", quietly = TRUE)) {
    stop("smoof needed for this function to work. Please install it.",
         call. = FALSE)
  }

  #function for controlling the input data
  smoof_input_createFeatures <- reactive({
    ctrl=list(init_sample.type = input$sampletype,
              init_sample.lower = input$samplelow,
              init_sample.upper = input$sampleup) #get ctrl values for creation of initial Sample
    X <- flacco::createInitialSample(n.obs = input$ssize, dim = input$dimension_size, control = ctrl)
    f <- smoof::makeFunctionsByName(input$smoof_function_select, dimensions = input$dimension_size)
    y <- apply(X, 1, f[[1]])
    feat.object <- flacco::createFeatureObject(X = X, y = y, fun = f[[1]])
    features <- flacco::calculateFeatureSet(feat.object, set = input$smoof_function_featureSet) #calculate the features
    features <- data.frame(t(data.frame(features)),stringsAsFactors=FALSE) #flip data.frame around
  })

  output$smoof_function_FeatureTable <- renderTable({
    features<- smoof_input_createFeatures()
  },rownames = TRUE,colnames=TRUE)


  output$smoof_function_downloadData <- downloadHandler(
    filename = function() { paste(input$smoof_input_featureSet, '.csv', sep='') },
    content = function(file) {
      write.csv(smoof_input_createFeatures(), file)
    }
  )
}
