################################################################################
### THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
###
### --- Author:  Irina Kukuyeva
### --- Contact: https://sites.google.com/site/ikukuyeva/contact-me
### --- Date:    2014-10-25
### --- Summary: Application of PCA to analysis of European food consumption.
################################################################################

### ----------------------------------------------------------------------------
### --- Step 0: Load required packages
### ----------------------------------------------------------------------------
library(lattice)

### ----------------------------------------------------------------------------
### --- Step 1: Read-in the data set (with tab-separated entries).
### ----------------------------------------------------------------------------
url = 'http://www.stat.ucla.edu/~rgould/120bs06/protein.txt'
data.orig   <- read.table(url,
                         header=TRUE,
                         sep="\t")

# For PCA analysis, keep all the variables 
# except the first column with country names:
data        <- data.orig[, -1]		

### ----------------------------------------------------------------------------
### --- Step 2: Check for equality of variances.
### ----------------------------------------------------------------------------

### --- Approach 1: Boxplot
op <- par(las=2, 
          cex.axis=0.8, 
          mfrow=c(1,2), 
          mai=c(1,0.5,1,0.1)
          )
boxplot(data, 
        main="'Protein' data set.",
        col=topo.colors(ncol(data))
        )
boxplot(data.frame(cor(data)), 
        main="cor('Protein') data set.",
        col=topo.colors(ncol(data))
        )
par(op)

### --- Approach 2: Bartless Test (if p<0.05, we reject the null hypothesis 
###                 that the variances are equal)
bartlett.test(data.frame(cor(data)))

### ----------------------------------------------------------------------------
### --- Step 3: Carry out PCA on the correlation matrix:
### ----------------------------------------------------------------------------
out.cor     <- princomp(data, cor=TRUE)

lambda_perc <- out.cor$sdev^2/sum(out.cor$sdev^2)
V           <- out.cor$loadings
PC          <- out.cor$scores
Y           <- cor(data) %*% V

### ----------------------------------------------------------------------------
### --- Step 4: Choose the number of components via scree plot:
### ----------------------------------------------------------------------------
par( mai=c(1,1,0.1,0.1) )
plot(lambda_perc, 
     type="b",
     xlab="Component Number",
     ylab="Percent total variance explained",
     pch=16
     )
text(x=1:ncol(cor(data)), 
     y=lambda_perc, 
     labels=round(cumsum(lambda_perc), 2), 
     adj=-0.3
     )

### ----------------------------------------------------------------------------
### --- Step 5: Interpret the results via biplot:
### ----------------------------------------------------------------------------
biplot(out.cor,
       pc.biplot=TRUE,
       xlabs=data.orig$Country, 
       xlim=c(-3, 3)
       )
abline(h=0, 
       lty=2, 
       col="grey50"
       ) 
abline(v=0, 
       lty=2, 
       col="grey50"
       )

### ----------------------------------------------------------------------------
### Step 6: Residual analysis
### ----------------------------------------------------------------------------
X_hat <- cor(data) - (cor(data) %*% V[, 1:2]) %*% t(V[, 1:2])

n_obs <- nrow(X_hat) * ncol(X_hat)

levelplot(X_hat, 
 col.regions=heat.colors( n_obs ), 
 scales=list( x=list(rot = 90) )
 )
 
 