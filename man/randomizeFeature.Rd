% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/randomizeFeature.R
\name{randomizeFeature}
\alias{randomizeFeature}
\title{Randomize or Pseudorandomize Categorical Variables}
\usage{
randomizeFeature(
  x,
  feature = NULL,
  shuffle = FALSE,
  maintainDistr = TRUE,
  numRandomizations = 1
)
}
\arguments{
\item{x}{Data frame containing real-time-location data.}

\item{feature}{Vector of 1 or more column names describing variables
in x to be randomized.}

\item{shuffle}{Logical. If TRUE, unique values will be replaced with 
another, random unique value from the same distribution with 100% 
certainty. For example if the values in a "dose" column 
c(0mg,100mg,300mg) were shuffled, one possible outcome would be: 
x$dose.shuff[which(x$dose == "0mg")] <- 300mg, 
x$dose.shuff[which(x$dose == "100mg")] <- 0mg, 
and x$dose.shuff[which(x$dose == "300mg")] <- 100mg.
Defaults to FALSE.}

\item{maintainDistr}{Logical. If TRUE, the number of each unique value in 
the column will be maintained in the function output. Otherwise, the 
function will draw on the initial distribution to assign randomized 
values, but the specific number of each unique value may not be 
maintained. Defaults to TRUE.}

\item{numRandomizations}{Integer. The number of replicate data frames 
produced in output. Defaults to 1.}
}
\value{
Output is \code{x} appended with columns described below. 
   
   \item{...shuff}{Randomized value of specified variables.}
   \item{randomRep}{Randomization replicate.}
}
\description{
This function randomizes the values in a given column (or set of columns 
   (i.e., c(colname(x)[1], colname(x)[2]))), identified by the "feature" 
   argument in a dataset (x).
}
\details{
Note: the shuffle argument supercedes the maintainDistr argument. Therefore,
   if shuffle == TRUE, the maintainDistr argument is irrelevant.
}
\examples{

data(calves)

system.time(randomizedValues<-contact::randomizeFeature(x = calves, 
   feature = c("calftag", "date"), shuffle = TRUE, maintainDistr = TRUE, 
   numRandomizations = 3)) 
   
randomizedFrame<-data.frame(randomizedValues[[1]], stringsAsFactors = TRUE)

head(randomizedFrame) #see that randomized-value columns have been appended.
}
\references{
Farine, D.R., 2017. A guide to null models for animal social 
   network analysis. Methods in Ecology and Evolution 8:1309-1320.
   https://doi.org/10.1111/2041-210X.12772.
}
\keyword{data-processing}
\keyword{randomize}
