##ui file for my word prediction Shiny App

##suppress warnings
suppressWarnings(library(shiny))

shinyUI(fluidPage(
  
  #Title
  titlePanel("N-Gram Word Predictor"),
  
  fluidRow(HTML("<strong>	&nbsp;	&nbsp;	&nbsp;	&nbsp;	&nbsp;Author: Paul Wachtler</strong>") ),
  fluidRow(HTML("<strong> &nbsp;	&nbsp;	&nbsp;	&nbsp;	&nbsp;Date: March 19, 2017</strong>") ),
  
  fluidRow(
    br(),
    p(HTML("&nbsp;	&nbsp;	&nbsp;	&nbsp;	&nbsp;Welcome to my word prediction app!  The underlying data for this app comes from a dataset of words from Twitter, news articles, and blog posts.  It applies Katz's back-off model to predict the next word."))),
  br(),
  br(),
  
  # Sidebar layout
  sidebarLayout(
    
    sidebarPanel(
      textInput("inputString", "Enter a word or partial sentence then press the enter key or click on the 'Submit' button",value = ""),
      submitButton("Submit")
    ),
    
    mainPanel(
      h4("Next Word Prediction"),
      verbatimTextOutput("prediction")
    )
  )
    ))