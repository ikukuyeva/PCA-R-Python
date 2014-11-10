################################################################################
### THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
###
### --- Author:  Irina Kukuyeva
### --- Contact: https://sites.google.com/site/ikukuyeva/contact-me
### --- Date:    2014-10-25
### --- Summary: Application of PCA to analysis of Pasadena Meetup.com groups.
################################################################################

### ----------------------------------------------------------------------------
### --- Step 0: Load required packages.
### ----------------------------------------------------------------------------
library(blockcluster) 	

### ----------------------------------------------------------------------------
### Step 1: Read-in the distance matrix
### ----------------------------------------------------------------------------
dist_mat <- read.csv("../Data/meetup_dist_mat.csv",
 					 row.names=1
 					 )

### ----------------------------------------------------------------------------
### Step 2: Perform PCA on the correlation matrix
### ----------------------------------------------------------------------------
out.cor     <- princomp(dist_mat, cor=TRUE)

lambda_perc <- out.cor$sdev^2/sum(out.cor$sdev^2)
V           <- out.cor$loadings
PC          <- out.cor$scores
Y           <- cor(dist_mat) %*% V

### ----------------------------------------------------------------------------
### --- Step 3: Choose the number of components by looking at the scree plot
### ---------------------------------------------------------------------------- 
lambda_perc_cumsum <- cumsum(lambda_perc)

plot(lambda_perc[2:20], 
     type="b",
     xlab="Component Number (2-20)",
     ylab="% total variance explained",
     axes=FALSE)
axis(1, 
     at=1:20,
     lab=2:21,
     las=2)
box()
text(x=2:20, 
     y=lambda_perc[2:20], 
     labels=round(
              lambda_perc_cumsum[2:20], 
              digits=2
              ), 
     adj=-0.1, 
     pos=3, 
     cex=0.7
     )

### ----------------------------------------------------------------------------
### Step 4: Interpret results via analysis of weights of components
### ----------------------------------------------------------------------------
### --- Look at relationships between weights 
V_first4   <- V[, 1:4]
### --- Look at relationships between components
Y_first4   <- Y[, 1:4]

### ----------------------------------------------------------------------------
### Step 5: Alternative analysis of the distance matrix via block clustering
### ----------------------------------------------------------------------------

# 'nbcocluster = 4 clusters for rows and 4 for columns
# 'model'      = equal-sized clusters with unequal variance
out <- cocluster(cor(dist_mat),
                 datatype="continuous",
                 nbcocluster=c(4,4), 
                 model="pi_rho_sigma2kl"
                 )

plot(out)
# summary(out)
# attributes(out)$rowclass
# attributes(out)$colclass




