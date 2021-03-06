% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makePlanar.R
\name{makePlanar}
\alias{makePlanar}
\title{Project Geographic Coordinates onto a Plane}
\usage{
makePlanar(
  x = NULL,
  x.lon = NULL,
  x.lat = NULL,
  origin.lon = NULL,
  origin.lat = NULL,
  datum = "WGS84"
)
}
\arguments{
\item{x}{Data frame or matrix containing geographic data. Defaults to NULL.}

\item{x.lon}{Vector of length(nrow(x)) or singular character data, detailng 
the relevant colname in x, that denotes what longitude information will 
be used. If argument == NULL, makePlanar assumes a column with the 
colname "lon" exists in x. Defaults to NULL.}

\item{x.lat}{Vector of length(nrow(x)) or singular character data, detailing
the relevant colname in x, that denotes what latitude information will 
be used. If argument == NULL, makePlanar assumes a column with the 
colname "lat" exists in x. Defaults to NULL.}

\item{origin.lon}{Numerical. Describes the longitude will be used as the 
origin-point longitude for the azimuthal-equidistant projection. If NULL,
defaults to the longitude of the data set's centroid. Defaults to NULL.}

\item{origin.lat}{Numerical. Describes the latitude will be used as the 
origin-point latitude for the azimuthal-equidistant projection. If NULL,
defaults to the latitude of the data set's centroid. Defaults to NULL.}

\item{datum}{Character string describing the datum used to generate x.lon 
and x.lat. Defaults to "WGS84."}
}
\value{
Output is \code{x} appended with the following columns:

   \item{planar.x}{Planar x-coordinate values derived from longitude 
   observations.}
   \item{planar.y}{Planar y-coordinate values derived from latitude 
   observations.}
   \item{origin.lon}{Longitude of the origin point, either user specified 
   or the longitude of the data's centroid.}
   \item{origin.lat}{Latitude of the origin point, either user specified 
   or the latitude of the data's centroid.}
   \item{origin.distance}{Linear distance (m) between every point and the 
   origin point.}
}
\description{
This function converts lon/lat data (decimal degrees) from a geographic 
   coordinate system to planar coordinates using a custom azimuthal 
   equidistant projection, and appends these new coordinates to an input 
   data frame (x). By default, the function assumes longitude and latitude 
   coordinates were produced using the WGS84 datum, but users may change 
   this datum if they wish.
}
\details{
Users may specify longitude and latitude coordinates to become the origin of
   the projection (i.e., the (0,0) coordinate). If they do not specify these
   values, however, the function calculates the centroid of the data and 
   will use this as the origin point. 

Note: this function does not allow any NA coordinate values in 
   longitude/latitude vectors. If NAs exist you will get the following 
   error: "Error in .local(obj, ...) : NA values in coordinates." If NAs 
   exist in your data, we suggest 1.) removing them, or 2.) smoothing data 
   using contact::tempAggregate prior to running this function.
}
\examples{

data(baboons)

head(baboons) #see that locations are in geographic coordinates

lon.na <- which(is.na(baboons$location.long) == TRUE) #pull row ids of lon NAs
lat.na <- which(is.na(baboons$location.lat) == TRUE) #pull row ids of lat NAs

baboons.naRM <- droplevels(baboons[-unique(c(lon.na, lat.na)),]) #remove NAs

baboons.naRM_planar <- makePlanar(x = baboons.naRM, 
   x.lon = baboons.naRM$location.long, x.lat = baboons.naRM$location.lat, 
   origin.lon = NULL, origin.lat = NULL, datum = "WGS84") #note no specified origin coords
   
head(baboons.naRM_planar) #see that planar coordinates are reported
}
\keyword{GRC}
\keyword{data-processing}
\keyword{location}
\keyword{planar}
\keyword{point}
