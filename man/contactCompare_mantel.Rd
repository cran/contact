% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/contactCompare_mantel.R
\name{contactCompare_mantel}
\alias{contactCompare_mantel}
\title{Statistically Compare Two Contact Matrices}
\usage{
contactCompare_mantel(
  x.summary,
  y.summary,
  numPermutations = 1000,
  alternative.hyp = "two.sided",
  importBlocks = FALSE
)
}
\arguments{
\item{x.summary}{List or single-data frame output from the summarizeContacts
function refering to the empirical data. Note that if x.summary is a list
of data frames, only the first data frame will be used in the function.}

\item{y.summary}{List or single-data frame output from the summarizeContacts
function refering to the randomized data (i.e., NULL model 
contact-network edge weights). Note that if y.summary is a list
of data frames, only the first data frame will be used in the function.}

\item{numPermutations}{Integer. Number of times to permute the data.
Defaults to 1000.}

\item{alternative.hyp}{Character string. Describes the nature of the 
alternative hypothesis being tested when test == "mantel." Takes the 
values "two.sided," "less," or "greater." Defaults to "two.sided."}

\item{importBlocks}{Logical. If true, each block in x.summary will be 
analyzed separately. Defaults to FALSE. Note that the "block" column must
exist in .summary objects AND values must be identical (i.e., if block 
100 exists in x.summary, it must also exist in y.summary), otherwise an 
error will be returned.}
}
\value{
Output format is a single data frame with the following columns.

   \item{method}{Statistical test used to determine significance.}
   \item{z.val}{z statistic.}
   \item{p.value}{p.values associated with each comparison.}
   \item{x.mean}{mean contacts in x.summary overall or by block (if 
   applicable). Note that these means are calculated BEFORE any NAs are 
   converted to zeroes (see note above)}
   \item{y.mean}{mean contacts in y.summary overall or by block (if
   applicable). Note that these means are calculated BEFORE any NAs are 
   converted to zeroes (see note above)} 
   \item{alternative.hyp}{The nature of the alternative hypothesis being 
   tested.}
   \item{nperm}{Number of permutations used to generate p value.}
   \item{warning}{Denotes if any specific warning occurred during analysis.}
}
\description{
Tests for similarity of the x.summary input to y.summary. Please note that 
   this is a function of convience that is essentially a wrapper for the 
   ape::mantel.test function, that allows users to easily compare contact
   networks created using our pipeline of contact:: functions.
   Please understand that ape::mantel.test does not allow for missing
   values in matrices, so all NAs will be treated as zeroes.
}
\examples{
\donttest{
data(calves) #load data

calves.dateTime<-datetime.append(calves, date = calves$date,
                                 time = calves$time) #add dateTime column

calves.agg<-tempAggregate(calves.dateTime, id = calves.dateTime$calftag,
                       dateTime = calves.dateTime$dateTime, point.x = calves.dateTime$x,
                       point.y = calves.dateTime$y, secondAgg = 300, extrapolate.left = FALSE,
                       extrapolate.right = FALSE, resolutionLevel = "reduced", parallel = FALSE,
                       na.rm = TRUE, smooth.type = 1) #aggregate to 5-min timepoints

calves.dist<-dist2All_df(x = calves.agg, parallel = FALSE,
                       dataType = "Point", lonlat = FALSE) #calculate  inter-calf distances

calves.contact.block<-contactDur.all(x = calves.dist, dist.threshold=1,
                       sec.threshold=10, blocking = TRUE, blockUnit = "hours", blockLength = 1,
                       equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE)

emp.summary <- summarizeContacts(calves.contact.block, 
                                 importBlocks = TRUE) #empirical contact summ.



calves.agg.rand<-randomizePaths(x = calves.agg, id = "id",
                       dateTime = "dateTime", point.x = "x", point.y = "y", poly.xy = NULL,
                       parallel = FALSE, dataType = "Point", numVertices = 1, blocking = TRUE,
                       blockUnit = "mins", blockLength = 20, shuffle.type = 0, shuffleUnit = NA,
                       indivPaths = TRUE, numRandomizations = 2) #randomize calves.agg

calves.dist.rand<-dist2All_df(x = calves.agg.rand, point.x = "x.rand",
                       point.y = "y.rand", parallel = FALSE, dataType = "Point", lonlat = FALSE)

calves.contact.rand<-contactDur.all(x = calves.dist.rand,
                       dist.threshold=1, sec.threshold=10, blocking = TRUE, blockUnit = "hours",
                       blockLength = 1, equidistant.time = FALSE, parallel = FALSE,
                       reportParameters = TRUE) #NULL model contacts (list of 2)

rand.summary <- summarizeContacts(calves.contact.rand, avg = TRUE,
                                  importBlocks = TRUE) #NULL contact summary


contactCompare_mantel(x.summary = emp.summary, y.summary = rand.summary,
                    importBlocks = FALSE, numPermutations = 100,
                    alternative.hyp = "two.sided") #no blocking

contactCompare_mantel(x.summary = emp.summary, y.summary = rand.summary,
                    importBlocks = TRUE, numPermutations = 100,
                    alternative.hyp = "two.sided") #blocking
   }
}
\references{
Mantel, N. 1967. The detection of disease clustering and a 
   generalized regression approach. Cancer Research, 27:209–220.
}
\keyword{network-analysis}
