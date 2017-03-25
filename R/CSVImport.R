library(flacco)
library(shiny)
`%then%` <- shiny:::`%OR%`

functionImportPage <- function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput(ns("import_file"), label = "File to import"),
      selectInput(ns("FeatureSet_import"),label="Feature Set",choices=listAvailableFeatureSets()),
      downloadButton(ns('downloadData_import'), 'Download')
    ),
    # Show a table with the generated features
    mainPanel(
      tableOutput(ns("FeatureTable_import"))
    )
  )
}

functionImport <- function(input, output, session, stringsAsFactors) {

  #function for controlling the file input app
  createFeatures_import <- reactive({
    importdata=read.csv(input$import_file$datapath) #load values from uploaded file
    #y <- apply(X, 1, eval(parse(text=paste("function(x) ",input$function_input))))
    feat.object <- flacco::createFeatureObject(X = data.frame(importdata[,1]), y = importdata[,2])
    features <- flacco::calculateFeatureSet(feat.object, set = input$FeatureSet_import)
    features <- data.frame(t(data.frame(features)),stringsAsFactors=FALSE) #flip data.frame around
  })

  #Table to display the features of the CSV-value import
  output$FeatureTable_import <- renderTable({
    features<- createFeatures_import()
  },rownames = TRUE,colnames=FALSE)

  output$downloadData_import <- downloadHandler(
    filename = function() { paste(input$FeatureSet_import, '.csv', sep='') },
    content = function(file) {
      write.csv(createFeatures_import(), file)
    }
  )

}
