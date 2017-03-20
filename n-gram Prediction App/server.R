##This is the server file for my Word Prediction Shiny App.  It accepts a user input and generates a word prediction
##based on Katz's back-off method.

#suppress warnings
suppressWarnings(library(shiny))
suppressWarnings(library(tm))
suppressWarnings(library(stringr))


# load n-gram data files
load("fourGram.RData");
load("threeGram.RData");
load("twoGram.RData");
load("uniGram.RData");
mesg <- as.character(NULL);

##Clean up function for the user's input.
cleanInput <- function(userInput)
{
  
  # Remove the non-alphabatical characters
  userInput <- iconv(userInput, "latin1", "ASCII", sub=" ");
  userInput <- gsub("[^[:alpha:][:space:][:punct:]]", "", userInput);
  
  # Convert to a Corpus
  userInputCrps <- VCorpus(VectorSource(userInput))
  
  # Additional cleanup
  userInputCrps <- tm_map(userInputCrps, content_transformer(tolower))
  userInputCrps <- tm_map(userInputCrps, removePunctuation)
  userInputCrps <- tm_map(userInputCrps, removeNumbers)
  userInputCrps <- tm_map(userInputCrps, stripWhitespace)
  userInput <- as.character(userInputCrps[[1]])
  userInput <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", userInput)
  
  if (nchar(userInput) > 0) {
    return(userInput); 
  } else {
    return("");
  }
}

#Back-off algorithm
predFunction <- function(userInput)
{
  assign("mesg", "in predFunction", envir = .GlobalEnv)
  
  # Call to cleanup function
  userInput <- cleanInput(userInput);
  
  # Splits the user input into single words
  userInput <- unlist(strsplit(userInput, split=" "));
  userInputLen <- length(userInput);
  
  findNextWord <- FALSE;
  predNextWord <- as.character(NULL);

  # Checking quadgram first
  if (userInputLen >= 3 & !findNextWord)
  {

    userInput1 <- paste(userInput[(userInputLen-2):userInputLen], collapse=" ");
    
    searchStr <- paste("^",userInput1, sep = "");
    quadTemp <- quad[grep (searchStr, quad$terms), ];
    
    # Check to see if any matching record returned
    if ( length(quadTemp[, 1]) > 1 )
    {
      predNextWord <- quadTemp[1,1];
      findNextWord <- TRUE;
      mesg <<- "quadgrams"
    }
    quadTemp <- NULL;
  }
  
  # Checking trigram next
  if (userInputLen >= 2 & !findNextWord)
  {

    userInput1 <- paste(userInput[(userInputLen-1):userInputLen], collapse=" ");
    
    searchStr <- paste("^",userInput1, sep = "");
    triTemp <- tri[grep (searchStr, tri$terms), ];
    
    # Check to see if any matching record returned
    if ( length(triTemp[, 1]) > 1 )
    {
      predNextWord <- triTemp[1,1];
      findNextWord <- TRUE;
      mesg <<- "trigrams"
    }
    triTemp <- NULL;
  }
  
  # Checking bigrams
  if (userInputLen >= 1 & !findNextWord)
  {

    userInput1 <- userInput[userInputLen];
    
    searchStr <- paste("^",userInput1, sep = "");
    biTemp <- bi[grep (searchStr, bi$terms), ];
    
    # Check to see if any matching record returned
    if ( length(biTemp[, 1]) > 1 )
    {
      predNextWord <- biTemp[1,1];
      findNextWord <- TRUE;
      mesg <<- "bigrams";
    }
    biTemp <- NULL;
  }
  
  # Return single word if no other n-gram was previously found
  if (!findNextWord & userInputLen > 0)
  {
    predNextWord <- uni$terms[1];
    mesg <- "No word match found.  Returning most frequent word instead"
  }
  
  nextTerm <- word(predNextWord, -1);
  
  if (userInputLen > 0){
    dfTemp1 <- data.frame(nextTerm, mesg);
    return(dfTemp1);
  } else {
    nextTerm <- "";
    mesg <-"";
    dfTemp1 <- data.frame(nextTerm, mesg);
    return(dfTemp1);
  }
}

msg <- ""
shinyServer(function(input, output) {
  
  output$prediction <- renderPrint({
    cleanString <- cleanInput(input$inputString);
    predWord <- predFunction(cleanString);
    input$action;
    cat("", as.character(predWord[1,1]))
    cat("\n");
    cat("\n");
    cat("n-gram size used for prediction:",as.character(predWord[1,2]));
  })
 
}
)