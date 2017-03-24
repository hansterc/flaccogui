library(flacco)
library(shiny)
library(smoof)


ui <- navbarPage("flaccoGUI",
  tabPanel("Single Function Analysis",
   sidebarLayout(
     featureObject_sidebar("feature_function"),
     mainPanel(
       tabsetPanel( # Tabset panel for the different possibilites to put input in the app
        tabPanel("Feature Calculation",
          FeatureSetCalculationComponent("featureSet_Calculation")
        ),
        tabPanel("Visualization",
          FeatureSetVisualizationComponent("featureSet_Visualization")
        )
       )
     )
    )
  ),

    #CSV-Import tab for BBob Functions
    tabPanel("BBOB-Import",
      BBOBImportPage("BBOB_import_page")
    ),

    #CSV-Import für andere smoof funktionen
    tabPanel("smoof-Import",
             SmoofImportPage("smoof_import_page")
    )
)

server <- function(input, output) {

  featureObject <- callModule(functionInput, "feature_function",
             stringsAsFactors = FALSE)
  callModule(FeatureSetCalculation, "featureSet_Calculation",
             stringsAsFactors = FALSE, reactive(featureObject()))
  callModule(FeatureSetVisualization, "featureSet_Visualization",
              stringsAsFactors = FALSE, reactive(featureObject()))
  callModule(BBOBImport, "BBOB_import_page",
             stringsAsFactors = FALSE)
  callModule(SmoofImport, "smoof_import_page",
             stringsAsFactors = FALSE)


}

shinyApp(ui,server)
