## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height = 4, 
  fig.width = 7, 
  fig.align = "center"
)

## ----setup--------------------------------------------------------------------
#load the contact package
library(contact)

## ----Section 1, echo=TRUE, warning = FALSE, eval = TRUE-----------------------

data("calves") #load the calves data set
calves<-droplevels(calves[1:1000,]) #reduce the size to reduce processing time for this vignette.


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

head(calves)#The calves data set does not have a singular dateTime column. Rather, it has "date" and "time" columns. We must append a dateTime column to the data frame.

system.time(calves.dateTime<- contact::datetime.append(x = calves, date = calves$date, time= calves$time, dateTime = NULL, dateFormat = "mdy", dateFake = FALSE, startYear = NULL, tz.in = "UTC", tz.out = NULL, month = FALSE, day = FALSE, year = FALSE, hour = FALSE, minute = FALSE, second = FALSE, daySecond = FALSE, totalSecond = FALSE))


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

water<- data.frame(x = c(61.43315, 61.89377, 62.37518, 61.82622), y = c(62.44815, 62.73341, 61.93864, 61.67411)) #This is a data frame containing the x and y coordinates of the four trough vertices.


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

water_poly<-data.frame(matrix(ncol = 8, nrow = 1)) #(ncol = number of vertices)*2
colnum = 0
for(h in 1:nrow(water)){
  water_poly[1,colnum + h] <- water$x[h] #pull the x location for each vertex
  water_poly[1, (colnum + 1 + h)] <- water$y[h] #pull the y location for each vertex
  colnum <- colnum + 1
}


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

system.time(water_distance<-contact::dist2Area_df(x = calves.dateTime, y = water_poly, x.id = "calftag", y.id = "water", dateTime = "dateTime", point.x = calves.dateTime$x, point.y = calves.dateTime$y, poly.xy = NULL, parallel = FALSE, dataType = "Point", lonlat = FALSE, numVertices = NULL)) #note that the poly.xy and numVertices arguments refer to vertices of polygons in x, not y. Because dataType is "Point," not "Polygon," these arguments are irrelevant here.

head(water_distance)


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

SpThValues<-contact::findDistThresh(n = 100000, acc.Dist1 = 0.5, acc.Dist2 = NULL, pWithin1 = 90, pWithin2 = NULL, spTh = 0.5) #spTh represents the initially-defined spatial threshold for contact. Note that we've chosen to use 100,000 in-contact point-location pairs here.

SpThValues #it looks like an adjusted SpTh value of approximately 1.74 m will likely capture 99 to 100% of contacts, defined as instances when point-locations were within 0.333 m of the water trough, given the RTLS accuracy. #Note that because these confidence intervals are obtained from distributions generated from random samples, every time this function is run, results will be slightly different. 

CI_99<-unname(SpThValues[["spTh.adjustments"]][3]) #we will use this SpTh value moving forward.


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

system.time(water_contacts <- contact::contactDur.area(water_distance, dist.threshold=CI_99,sec.threshold=1, blocking = FALSE, equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE)) #Note that because we are not interested in making a time-aggregated network with > 1 temporal levels, we set blocking = FALSE to reduce processing time.

head(water_contacts)


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

system.time(water_edges<- contact::ntwrkEdges(x = water_contacts, importBlocks = FALSE, removeDuplicates = TRUE)) #get specific weighted edges

head(water_edges)


## ---- echo=TRUE, warning = FALSE, eval = TRUE---------------------------------

water.network <- igraph::simplify(igraph::graph_from_data_frame(d=water_edges, directed=F, vertices =  c(seq(101,110), "water")),remove.multiple = T, remove.loops = T) #Note that we have to specify the nodes here because not all calves were observed in contact with the water trough.
igraph::V(water.network)$color<- "orange1" #make calf nodes orange
igraph::V(water.network)$color[length(igraph::V(water.network))]<- "steelblue1" #make water node blue
igraph::V(water.network)$label<-NA #no need to label nodes
igraph::V(water.network)$size <-13
igraph::V(water.network)$shape<-c(rep("circle", (length(igraph::V(water.network)) - 1)), "square") #make the calf nodes circular and the water node square
igraph::E(water.network)$width <- water_edges$duration/10 #edge width is proportional to contact frequency
igraph::E(water.network)$color <- "black" #make edges black
watercoords1<- igraph::layout_as_star(water.network, center = igraph::V(water.network)[length(igraph::V(water.network))]) #set the center of the star layout as the water polygon
igraph::plot.igraph(water.network, layout = watercoords1)


## ----Section 2, echo=TRUE, warning = FALSE, eval = FALSE----------------------
#  data("calves2018") #load the data set

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  head(calves2018) #see that all necessary columns are there.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  calves2018$date<-lubridate::date(calves2018$dateTime) #add the date column to the data set
#  
#  calves06012018 <- droplevels(subset(calves2018, date == unique(calves2018$date)[1])) #pull the observations from 06/01/2018
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  system.time(calves_filter1 <- contact::mps(calves06012018, id = calves06012018$calftag, point.x = calves06012018$x, point.y = calves06012018$y, dateTime = calves06012018$dateTime, mpsThreshold = 10, lonlat = FALSE, parallel = FALSE, filterOutput = TRUE)) #we assume that if calves' point-locations suggest they moved faster than 10m/s, points are erroneous and should be removed. #This did not remove any observations.
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  confinementCoords <- data.frame(object = c("feed", "feed", "feed", "feed","fence", "fence", "fence", "fence", "fence"), x = c(46.0118, 46.6482, 58.3415, 57.6507, 60.5775, 29.3054, 16.7602, 17.0590, 46.0309), y = c(197.0570, 197.4131, 175.9618, 175.6284, 170.4628, 153.6002, 176.5861, 181.6315, 197.1261)) #these are the x & y coordinates for the feedlot-pen fenceline and adjacent feedbunk vertices. Note that they are arranged in a clockwise order, as the confine function below requires input vertices to be ordered clockwise or counter-clockwise.
#  
#  plot(confinementCoords$x,confinementCoords$y,lines(c(confinementCoords$x, confinementCoords$x[1]),c(confinementCoords$y, confinementCoords$y[1])), pch=16, main = "confinement polygon") #this is what the pen outline looks like.
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  system.time(calves_filter2<-contact::confine(calves_filter1, point.x = calves_filter1$x, point.y = calves_filter1$y, confinementCoord.x = confinementCoords$x, confinementCoord.y = confinementCoords$y, filterOutput = TRUE)) #this removed an additional 1784 observations
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  system.time(calves_filter3<- contact::dup(calves_filter2, id = calves_filter2$calftag, point.x = calves_filter2$x, point.y = calves_filter2$y, dateTime = calves_filter2$dateTime, avg = FALSE, parallel = FALSE, filterOutput = TRUE)) #it looks like there were no duplicates to remove in the first place. We're ready to proceed with analyses.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  #create our data set that shows calves average position every 10 seconds
#  system.time(calves.10secSmoothed <- contact::tempAggregate(x = calves_filter3, id = calves_filter3$calftag, point.x = calves_filter3$x, point.y = calves_filter3$y, dateTime = calves_filter3$dateTime, secondAgg = 10, extrapolate.left = FALSE, resolutionLevel = "reduced", extrapolate.right = FALSE, na.rm = TRUE, smooth.type = 2))
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  ##Create 0.333 m X 0.333 m calf head polygons.
#  #Note that this is done using the original reference points, which denote the locations of RFID tags on individuals' left ears.
#  system.time(calf_heads <- contact::referencePoint2Polygon(x = calves.10secSmoothed, id = calves.10secSmoothed$id, dateTime = calves.10secSmoothed$dateTime, point.x = calves.10secSmoothed$x, point.y = calves.10secSmoothed$y, direction = NULL, StartLocation = "DL", UpDownRepositionLen = 0.333, LeftRightRepositionLen = 0.333, CenterPoint = FALSE, MidPoints = FALSE, immobThreshold = 0, parallel = FALSE, modelOrientation = 90)) #Note that we do not specify an immobility threshold here. This is because the head polygons will later be unioned with body polygons generated from different point-locations, and prematurely thresholding them will potentially cause misalignment between the two polygons.
#  
#  head(calf_heads)
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  system.time(leftShoulder.point<-contact::repositionReferencePoint(x = calves.10secSmoothed, id = calves.10secSmoothed$id, dateTime = calves.10secSmoothed$dateTime, point.x = calves.10secSmoothed$x, point.y = calves.10secSmoothed$y, direction = NULL, repositionAngle = 180, repositionDist = 0.0835, immobThreshold = 0, parallel = FALSE, modelOrientation = 90))  #Again, see that we do not specify a immobility threshold here.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  head(leftShoulder.point)
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  system.time(calf_bods <- contact::referencePoint2Polygon(x = leftShoulder.point, id = leftShoulder.point$id, dateTime = leftShoulder.point$dateTime, point.x = leftShoulder.point$x.adjusted, point.y = leftShoulder.point$y.adjusted, direction = leftShoulder.point$movementDirection, StartLocation = "UL", UpDownRepositionLen = 1.167, LeftRightRepositionLen = 0.5, CenterPoint = FALSE, MidPoints = TRUE, immobThreshold = 0, parallel = FALSE, modelOrientation = 90)) #note that direction == leftShoulder.point$movementDirection.
#  
#  head(calf_bods) #notice the additional columns compared to calf_heads
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  calf_FullBody <- data.frame(calf_id = calf_bods$id, vertex1.x = calf_bods$cornerPoint1.x, vertex1.y = calf_bods$cornerPoint1.y, vertex2.x = calf_heads$cornerPoint1.x, vertex2.y = calf_heads$cornerPoint1.y, vertex3.x = calf_heads$cornerPoint2.x, vertex3.y = calf_heads$cornerPoint2.y, vertex4.x = calf_heads$cornerPoint3.x, vertex4.y = calf_heads$cornerPoint3.y, vertex5.x = calf_heads$cornerPoint4.x, vertex5.y = calf_heads$cornerPoint4.y, vertex6.x = calf_bods$cornerPoint2.x, vertex6.y = calf_bods$cornerPoint2.y,  vertex7.x = calf_bods$midPoint2.x, vertex7.y = calf_bods$midPoint2.y, vertex8.x = calf_bods$cornerPoint3.x, vertex8.y = calf_bods$cornerPoint3.y, vertex9.x = calf_bods$cornerPoint4.x, vertex9.y = calf_bods$cornerPoint4.y, vertex10.x = calf_bods$midPoint4.x, vertex10.y = calf_bods$midPoint4.y, dateTime = calf_bods$dateTime)
#  
#  head(calf_FullBody)
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  fullBodyExample <- data.frame(section = c("body", rep("head", 4), rep("body", 5)), x = unname(unlist(calf_FullBody[10,c(seq(2,21, by =2))])), y = unname(unlist(calf_FullBody[10,c(seq(3,21, by =2))])))
#  
#  {plot(fullBodyExample$x,fullBodyExample$y, col = as.factor(fullBodyExample$section), lines(c(fullBodyExample$x, fullBodyExample$x[1]),c(fullBodyExample$y, fullBodyExample$y[1])), pch=16, main = "Calves' body shape")
#   legend(39.2, 193.8, col = c(1,2), legend = c("body", "head"), cex = 0.7, pch = 16)}
#  

## ---- echo=FALSE, warning=FALSE, eval = FALSE---------------------------------
#  
#  calves.10secSmoothed.subset<-droplevels(calves.10secSmoothed[1:30,]) #subset for speed
#  leftShoulder.point.subset<-droplevels(leftShoulder.point[1:30,]) #subset for speed
#  
#  #new polygon sets
#  calf_heads2 <- contact::referencePoint2Polygon(x = calves.10secSmoothed.subset, id = calves.10secSmoothed.subset$id, dateTime = calves.10secSmoothed.subset$dateTime, point.x = calves.10secSmoothed.subset$x, point.y = calves.10secSmoothed.subset$y, direction = NULL, StartLocation = "DL", UpDownRepositionLen = 0.333, LeftRightRepositionLen = 0.333, CenterPoint = FALSE, MidPoints = FALSE, immobThreshold = 0.1, parallel = FALSE, modelOrientation = 90)
#  
#  calf_bods2 <- contact::referencePoint2Polygon(x = leftShoulder.point.subset, id = leftShoulder.point.subset$id, dateTime = leftShoulder.point.subset$dateTime, point.x = leftShoulder.point.subset$x.adjusted, point.y = leftShoulder.point.subset$y.adjusted, direction = leftShoulder.point.subset$movementDirection, StartLocation = "UL", UpDownRepositionLen = 1.167, LeftRightRepositionLen = 0.5, CenterPoint = FALSE, MidPoints = TRUE, immobThreshold = 0.1, parallel = FALSE, modelOrientation = 90) #note that direction == leftShoulder.point$movementDirection.
#  
#  calf_FullBody2 <- data.frame(calf_id = calf_bods2$id, vertex1.x = calf_bods2$cornerPoint1.x, vertex1.y = calf_bods2$cornerPoint1.y, vertex2.x = calf_heads2$cornerPoint1.x, vertex2.y = calf_heads2$cornerPoint1.y, vertex3.x = calf_heads2$cornerPoint2.x, vertex3.y = calf_heads2$cornerPoint2.y, vertex4.x = calf_heads2$cornerPoint3.x, vertex4.y = calf_heads2$cornerPoint3.y, vertex5.x = calf_heads2$cornerPoint4.x, vertex5.y = calf_heads2$cornerPoint4.y, vertex6.x = calf_bods2$cornerPoint2.x, vertex6.y = calf_bods2$cornerPoint2.y,  vertex7.x = calf_bods2$midPoint2.x, vertex7.y = calf_bods2$midPoint2.y, vertex8.x = calf_bods2$cornerPoint3.x, vertex8.y = calf_bods2$cornerPoint3.y, vertex9.x = calf_bods2$cornerPoint4.x, vertex9.y = calf_bods2$cornerPoint4.y, vertex10.x = calf_bods2$midPoint4.x, vertex10.y = calf_bods2$midPoint4.y, dateTime = calf_bods2$dateTime)
#  
#  fullBodyExample2 <- data.frame(section = c("body", rep("head", 4), rep("body", 5)), x = unname(unlist(calf_FullBody2[10,c(seq(2,21, by =2))])), y = unname(unlist(calf_FullBody2[10,c(seq(3,21, by =2))])))
#  
#  {plot(fullBodyExample2$x,fullBodyExample2$y, col = as.factor(fullBodyExample2$section), lines(c(fullBodyExample2$x, fullBodyExample2$x[1]),c(fullBodyExample2$y, fullBodyExample2$y[1])), pch=16, main = "Calves' body shape", sub = "improper immobility-threshold specification")
#   legend(39.2, 193.8, col = c(1,2), legend = c("body", "head"), cex = 0.7, pch = 16)}
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  immobility.vec<- (which(leftShoulder.point$dist.original < 0.1) + 1) #create a vector describing which polygons in calf_heads2 moved < 0.1m. Note that we add 1 to returned values because leftShoulder.point$dist.original details the distance to the successive point, but we want distance to the proceeding point.
#  
#  calf_FullBody.immob<-calf_FullBody
#  calf_bods.matrix<-as.matrix(calf_FullBody[,2:21]) #convert vertex columns to matrix for speed
#  
#  for(l in 1:length(immobility.vec)){
#    calf_bods.matrix[immobility.vec[l],] <- calf_bods.matrix[(immobility.vec[l]-1),] #replace l-th observations in calf_FullBody with the preceding coordinates.
#  }
#  
#  calf_FullBody.immob[,2:21]<- calf_bods.matrix #replace with the updated locations.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  naObs<-which(is.na(calf_FullBody.immob$vertex10.x) == T) #by identifying where NAs were introduced for any body vertex (other than vertex 1, which was left-shoulder point used to generate other vertices), we can determine what rows to remove. Note: we use a body vertex because two NAs were introduced (i.e., one from left-shoulder repositioning and another from polygon creation), as opposed to only one.
#  
#  FullBody_noNAs<-droplevels(calf_FullBody.immob[-naObs,]) #remove NA coordinates
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  system.time(fullbody_distances<-contact::dist2All_df(x = FullBody_noNAs, id = FullBody_noNAs$calf_id, dateTime = FullBody_noNAs$dateTime, point.x = NULL, point.y = NULL, poly.xy = FullBody_noNAs[,2:21], elev = NULL, parallel = FALSE, dataType = "Polygon", lonlat = FALSE, numVertices = 10)) #these are the distances from the nearest polygon edges (i.e., not distance from centroids).
#  
#  head(fullbody_distances) #note that if individuals were not observed in the data at a specific time, the function reports NAs for their respective distances.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  polySpThValues<-contact::findDistThresh(n = 100000, acc.Dist1 = 0.5, acc.Dist2 = NULL, pWithin1 = 90, pWithin2 = NULL, spTh = 0) #spTh represents the initially-defined spatial threshold for contact. #spTh represents the initially-defined spatial threshold for contact. Note that we've chosen to use 100,000 in-contact point-location pairs here.
#  
#  polySpThValues #it looks like an adjusted SpTh value of approximately 1.38 m will likely capture 99% of contacts, defined as instances when point-locations were within 0 m of one another, given the RTLS accuracy. #Note that because these confidence intervals are obtained from distributions generated from random samples, every time this function is run, results will be slightly different.
#  
#  polyCI_99<-unname(polySpThValues[["spTh.adjustments"]][3]) #we will use this SpTh value moving forward.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  system.time(calf_fullBody_contacts <- contact::contactDur.all(fullbody_distances,dist.threshold=polyCI_99,sec.threshold=10, blocking = FALSE, equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE)) #Note that because we are not interested in making a time-aggregated network with > 1 temporal levels, we set blocking = FALSE to reduce processing time.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  #Generate a static network edge set (aggregated to the day resolution)
#  system.time(fullBody_edges<- contact::ntwrkEdges(x = calf_fullBody_contacts, importBlocks = FALSE, removeDuplicates = TRUE))
#  
#  #visualize the network
#  fullBody.network <- igraph::simplify(igraph::graph_from_data_frame(d=fullBody_edges, directed=F),remove.multiple = T, remove.loops = T) #create network
#  
#  igraph::V(fullBody.network)$color<- "orange1"
#  igraph::V(fullBody.network)$size <-13
#  igraph::E(fullBody.network)$width <- fullBody_edges$duration/50 #edge width is proportional to contact frequency
#  igraph::E(fullBody.network)$color <- "black"
#  igraph::plot.igraph(fullBody.network, vertex.label.cex=0.4, layout = igraph::layout.circle)
#  

## ---- Section 3, echo=TRUE, warning = FALSE, eval = FALSE---------------------
#  
#  head(calves06012018) #point-location data set to be temporally smoothed
#  head(FullBody_noNAs) #polygon data set
#  head(fullbody_distances) #distances between each full-body polygon at each timestep
#  polyCI_99 #adjusted polygon-contact SpTh value that likely captures 99% of of inter-calf contacts, defined as instances when calf polygons intersect, given the RTLS accuracy.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  system.time(calf_fullBody_contacts.hr <- contact::contactDur.all(fullbody_distances,dist.threshold=polyCI_99,sec.threshold=10, blocking = TRUE, blockUnit = "hours", blockLength = 1, equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE)) #Note that the difference between this edge set and the one created in Section 2 is that blocking is set to TRUE here.
#  
#  headVertexColumns<-4:11 #these are the columns within FullBody_noNAs representative of head polygons
#  
#  system.time(head_distances<-contact::dist2All_df(x = FullBody_noNAs, id = FullBody_noNAs$calf_id, dateTime = FullBody_noNAs$dateTime, point.x = NULL, point.y = NULL, poly.xy = FullBody_noNAs[,headVertexColumns], elev = NULL, parallel = FALSE, dataType = "Polygon", lonlat = FALSE, numVertices = 4)) #Note that the difference between this distance set and the one created in Section 2 is that poly.xy and numVertices arguments refer to head polygons only
#  
#  system.time(calf_head_contacts.hr <- contact::contactDur.all(head_distances,dist.threshold=polyCI_99,sec.threshold=10, blocking = TRUE, blockUnit = "hours", blockLength = 1, equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE))
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  nRandomizations <- 2 #we will create 2 randomized-hour replicates.
#  
#  system.time(calf_fullBody.random.list <- contact::randomizePaths(x = FullBody_noNAs, id = FullBody_noNAs$calf_id, dateTime = FullBody_noNAs$dateTime, point.x = NULL, point.y = NULL, poly.xy = FullBody_noNAs[,2:21], parallel = FALSE, dataType = "Polygon", numVertices = 10, blocking = TRUE, blockUnit = "hours", blockLength = 1, shuffle.type = 1, indivPaths = TRUE, numRandomizations = nRandomizations)) #see that we can directly randomize the polygon set. There's no need to take it back to the point data (unless you really want to). See also that we randomize the polygon set with NAs already removed so that we don't have to do it again.
#  
#  head(data.frame(calf_fullBody.random.list[[1]])) #here's what the output looks like when you set shuffle.type == 1. See that there are separate coordinate columns designated "rand."
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  fullBodyVertexColnames<- colnames(data.frame(calf_fullBody.random.list[[1]]))[27:46] #these are the column names of columns in the data frames contained within calf_fullBody.random.list that contain randomized full-body-polygon-vertex information.
#  
#  system.time(fullBody_distances.random<-contact::dist2All_df(x = calf_fullBody.random.list, id = "id", dateTime = "dateTime", point.x = NULL, point.y = NULL, poly.xy = fullBodyVertexColnames, elev = NULL, parallel = FALSE, dataType = "Polygon", lonlat = FALSE, numVertices = 10)) #Note that the difference between this distance set and the one created in Section 2 is that x is a list and other arguments are given column-name information rather than vectors of length(nrow(x)).
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  system.time(calf_fullBody_contacts.hr.random <- contact::contactDur.all(x = fullBody_distances.random, dist.threshold = polyCI_99, sec.threshold=10, blocking = TRUE, blockLength = 1, blockUnit = "hours", equidistant.time = FALSE, parallel = FALSE, reportParameters = TRUE))
#  

## ---- echo=TRUE, warning=FALSE, eval = FALSE----------------------------------
#  
#  #create x.potential
#  system.time(x.potential <- contact::potentialDurations(fullbody_distances, blocking = TRUE, blockLength = 1, blockUnit = "hours", distFunction = "dist2All_df")) # see blocking information here
#  
#  head(x.potential) #see the layout of x.potential
#  
#  #create y.potential
#  system.time(y.potential <- contact::potentialDurations(fullBody_distances.random, blocking = TRUE, blockLength = 1, blockUnit = "hours", distFunction = "dist2All_df"))
#  
#  #summarize empirical contacts
#  system.time(x.summary <- contact::summarizeContacts(x = calf_fullBody_contacts.hr, importBlocks = TRUE, parallel = FALSE)) #note that
#  head(x.summary) #see the layout of x.summary
#  
#  #summarize randomized contacts
#  system.time(y.summary <- contact::summarizeContacts(x = calf_fullBody_contacts.hr.random[[2]], importBlocks = TRUE, avg = TRUE, parallel = FALSE))
#  

## ---- echo=TRUE, warning=FALSE, eval = FALSE----------------------------------
#  
#  system.time(fullBody_NULLTest1<-contact::contactCompare_chisq(x.summary, y.summary, x.potential, y.potential, importBlocks = TRUE, shuffle.type = 1, popLevelOutput = TRUE, parallel = FALSE)) #Note that we MUST indicate the shuffle.type used to randomize point-locations.
#  

## ---- echo=TRUE, warning = FALSE, eval = FALSE--------------------------------
#  
#  head(fullBody_NULLTest1[[2]])
#  

## ---- echo = TRUE, warning = FALSE, eval = FALSE------------------------------
#  
#  system.time(y.summary2 <- contact::summarizeContacts(calf_fullBody_contacts.hr, importBlocks = FALSE)) #create the new y.summary
#  
#  system.time(mantelOutput<-contact::contactCompare_mantel(x.summary, y.summary = y.summary2, numPermutations = 1000, alternative.hyp = "two.sided", importBlocks = FALSE))
#  
#  mantelOutput #based on the reported p-value, given an alpha-level of 0.05, we can reject the NULL hypothesis that these two networks are unrelated. (This is as we would expect, because the head X head-contact network is nested within the fullBody-contact network. If they were not similar, we would have a problem.)
#  

