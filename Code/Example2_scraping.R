################################################################################
### THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
###
### --- Author:      Irina Kukuyeva
### --- Contact:     https://sites.google.com/site/ikukuyeva/contact-me
### --- Date:        2014-10-25
### --- Summary:     Scraping data for analysis of Pasadena Meetup.com groups.
### --- Link to API: http://www.meetup.com/meetup_api/docs/groups/
################################################################################

### ----------------------------------------------------------------------------
### --- Step 0a: Load required packages
### ----------------------------------------------------------------------------
library(RTextTools)
library(RJSONIO)
library(httr)

### ----------------------------------------------------------------------------
### --- Step 0b: Heper Functions
### ----------------------------------------------------------------------------
###
### --- Function: Extract the keywords of a given meetup.
###
###     Arguments: 
###			topic = List of meetup keywords and their attributes.
###
### 	Returns: 
###			res   = List of meetup keywords.
###
### --- Example of a list that is passed in: 
# [[1]]
#    id    urlkey      name 
#  "85" "science" "Science" 

# [[2]]
#   id        urlkey          name 
# "89" "environment" "Environment" 
### --- Example of a list that is returned: 
#      name          name 
# "Science" "Environment" 
###
preproc_topic <- function(topic){
	res <- sapply(topic, function(x) x[3])
	return(res)
}

###
### --- Function: Preprocess the keywords for better stemming.
###
### 	Arguments: 
###			desc = List of keywords for a given meetup.
###
### 	Returns: 
###			res  = Vector of keywords for the same meetup.
###
preproc_desc <- function(desc){
	# Remove all punctuation:
	desc <- gsub("'", "", as.character(desc))
	# desc <- gsub("[[:punct:]]", " ", as.character(desc))
	# Change font:
	desc <- tolower(desc)
	# Split by spaces:
	# desc <- strsplit(desc, " ")
	# Word count:
	# res <- sort(table(unlist(desc)), decreasing=TRUE)
	res <- paste(desc, collapse=" ")
	res <- gsub("[[:punct:]]", " ", as.character(res))
	res <- gsub("  ", " ", as.character(res))
	return(res)
}

###
### Function: Compute distance between two meetups x and y (based on relative
###			  error between word counts):
###
### Arguments:
###		x = vector of word counts from a given meetup
###		y = vector of word counts from a given meetup (same or different)
###
### Returns: 
###		dist = distance between two meetups based on relative error.
###
###
abs_dist <- function(x, y){
	dist <- sum(abs(x - y))/length(x)
	return(dist)
}

### ----------------------------------------------------------------------------
### --- Step 1: Read-in the Meetup.com API key:
### ----------------------------------------------------------------------------
api_key <- scan("meetup.apikey", character(), quiet = TRUE)

### ----------------------------------------------------------------------------
### --- Step 2: Get data from 200 meetups in Pasadena and nearby cities:
### ----------------------------------------------------------------------------
req_url <- paste0(
	"https://api.meetup.com/groups.json/?country=us&state=ca&city=pasadena&key=",
	api_key
	)
### Note: Los Angeles should be entered as 
# city=los%20angeles

### Use default settings: 200 groups per hour and 
###	radius=25 miles of the city specified
tmp <- fromJSON(rawToChar(
			  GET(req_url
			     )$content
			)
		)$results

### ----------------------------------------------------------------------------
### --- Step 3: Preprocess the data
### ----------------------------------------------------------------------------

### --- Step 3a: Get the names of the 200 meetups:
meetups <- sapply(tmp, function(x) x$group_urlname)

### --- Step 3b: Extract the keywords of each meetup:
topics  <- sapply(tmp, function(x) preproc_topic(x$topic))

### --- Step 3c: Format the keywords of each meetup to be on
###				 one line to ease manipulation:
topics_1line <- sapply(topics, function(x) preproc_desc(x))

### --- Step 3d: Stem the keywords:
topics_df <- data.frame(id=1:length(topics_1line), 
			words=topics_1line
			)

topics_stem <- create_matrix(topics_df,
			     stemWords=TRUE,
			     removeStopwords=FALSE,
			     minWordLength=2
			     )
colnames(topics_stem) # see the stemmed words
topics_stem 		  <- as.matrix(topics_stem)
rownames(topics_stem) <- meetups

### --- Step 3e: Compute the distance between two Meetup groups:
dist_mat <- apply(topics_stem, 
		  1, 
		  function(x){
			apply(topics_stem, 
			1, 
			function(y) abs_dist(x, y)
				)
		  }
		)

### ----------------------------------------------------------------------------
### --- Step 4: Save off data to be analyzed in Example 2 via PCA:
### ----------------------------------------------------------------------------
write.csv(topics_stem, "../Data/meetup_wc.csv")		# for reference
rownames(dist_mat) <- meetups 						
write.csv(dist_mat, "../Data/meetup_dist_mat.csv")	# for analysis

