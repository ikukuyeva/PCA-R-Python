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
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import scipy
from   sklearn.decomposition import PCA

### ----------------------------------------------------------------------------
### Step 1: Read-in the distance matrix
### ----------------------------------------------------------------------------
os.chdir("../Data")
dist_mat = pd.read_csv('meetup_dist_mat.csv',
						            sep=',',
						            index_col=0
                        )	

### ----------------------------------------------------------------------------
### Step 2: Perform PCA on the correlation matrix
### ----------------------------------------------------------------------------
data_std = dist_mat/dist_mat.std()	
out_cor  = PCA()	       # keep all components
out_cor.fit(data_std)	   # fit PCA

lambda_perc = out_cor.explained_variance_ratio_
V           = pd.DataFrame(out_cor.components_.T)
PC          = pd.DataFrame(out_cor.fit_transform(data_std))
Y 			    = pd.DataFrame(np.dot(dist_mat.corr(), V))

### ----------------------------------------------------------------------------
### --- Step 3: Choose the number of components by looking at the scree plot
### ----------------------------------------------------------------------------
lambda_perc_cumsum = np.cumsum(lambda_perc)

fig = plt.figure()
ax  = fig.add_subplot(111)

plt.plot(range(1, 21), 
         lambda_perc[1:21], 
        'ko-'
        )
plt.xticks(np.array(range(1, 21)))
ax.set_xticklabels(range(1, 21),
	                 rotation=90)
ax.set_yticklabels([])
ax.set_xlabel("Component Number (2 through 20)")
ax.set_ylabel("Percent total variance explained")

for i in range(1, 21):
	ax.text(x=i-0.2, 
          y=lambda_perc[i], 
          s=str(round(lambda_perc_cumsum[i], 2)),
          size='small'
          )

fig.show()

### ----------------------------------------------------------------------------
### Step 4: Interpret results via analysis of weights of components
### ----------------------------------------------------------------------------
### --- Look at relationships between weights (multiplied by scalar to match
###     R output)
V_first4 = pd.DataFrame([-V[0], V[1], -V[2], -V[3]]).T

### --- Look at relationships between components
Y_first4 = pd.DataFrame([-Y[0], Y[1], -Y[2], -Y[3]]).T


