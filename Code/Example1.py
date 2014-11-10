# -*- coding: utf-8 -*-
################################################################################
### THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
###
### --- Author:  Irina Kukuyeva
### --- Contact: https://sites.google.com/site/ikukuyeva/contact-me
### --- Date:    2014-10-25
### --- Summary: Application of PCA to analysis of European food consumption.
################################################################################

### ----------------------------------------------------------------------------
### --- Step 0: Load required packages.
### ----------------------------------------------------------------------------
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
from   sklearn.decomposition import PCA

### ----------------------------------------------------------------------------
### --- Step 1: Read-in the data set (with tab-separated entries).
### ----------------------------------------------------------------------------
url          = 'http://www.stat.ucla.edu/~rgould/120bs06/protein.txt'
data_orig    = pd.read_csv(url,
                           sep='\t')

columns_keep = data_orig.columns.values.tolist()[1:]
data         = data_orig[columns_keep]

### ----------------------------------------------------------------------------
### --- Step 2: Check for equality of variances.
### ----------------------------------------------------------------------------

### --- Approach 1: Boxplot
def boxplot(dataset, ax, colors):
  box = ax.boxplot(dataset, 
                 patch_artist=True) 
  # Add colors
  for bx, color in zip(box['boxes'], colors):
      bx.set_facecolor(color)
  for median in box['medians']:
      median.set_linewidth(2)
  # Customize the x-axis:    
  ax.set_xticklabels(data.columns.values.tolist(),
                     rotation=90,
                     size=8)

colors = ["#4c00ff", "#004cff", "#00e5ff",
          "#00ff4d", "#4dff00", "#e6ff00", 
          "#ffff00", "#ffde59", "#ffe0b3"]

# Create a figure instance:
fig = plt.figure(1, figsize=(12,6))
ax1 = fig.add_subplot(121)
boxplot(data.values, 
        ax1, 
        colors)
ax2 = fig.add_subplot(122)
boxplot(data.corr().values, 
        ax2, 
        colors)
fig.show()

### --- Approach 2: Bartless Test (if p<0.05, we reject the null hypothesis 
###                 that the variances are equal)
tmp = np.array(data.corr())
scipy.stats.bartlett(tmp[0], 
                     tmp[1], 
                     tmp[2], 
                     tmp[3], 
                     tmp[4], 
                     tmp[5], 
                     tmp[6], 
                     tmp[7], 
                     tmp[8]
                     )
# returns T-statistic and p-value as a tuple

### ----------------------------------------------------------------------------
### --- Step 3: Carry out PCA on the correlation matrix.
### ----------------------------------------------------------------------------
data_std    = data/data.std()
out_cor     = PCA().fit(data_std) 

lambda_perc = out_cor.explained_variance_ratio_
V           = pd.DataFrame(out_cor.components_.T)
PC          = pd.DataFrame(out_cor.fit_transform(data_std))
Y           = pd.DataFrame(np.dot(data.corr(), V))

### ----------------------------------------------------------------------------
### --- Step 4: Choose the number of components by looking at the scree plot
### ----------------------------------------------------------------------------
plt.plot(range(out_cor.n_components_), 
         lambda_perc, 
        'ko-')
plt.xlabel("Component Number")
plt.ylabel("Percent total variance explained")
for i in range(out_cor.n_components_):
  plt.text(x=i, 
           y=lambda_perc[i], 
           s=str(round(lambda_perc[i], 2))
          )

plt.show()

### ----------------------------------------------------------------------------
### --- Step 5: Interpret the results via biplot:
### ----------------------------------------------------------------------------

### --- Step 5a: Add locations of components:
plt.plot(PC[[0]], 
        -PC[[1]],
        'ko')
plt.xlabel("PC1")
plt.ylabel("-PC2")
plt.axvline(x=0, 
            color='0.75')
plt.axhline(y=0, 
            color='0.75')

### --- Step 5b: Add components' labels:
for i in range(len(PC)):
  plt.text(x=PC[0][i], 
           y=-PC[1][i],
           s=data_orig['Country'][i]
          )

### --- Step 5c: Add loading directions:
for i in range(out_cor.n_components_):
  plt.arrow(x=0,
            y=0, 
            dx=1.5*V[0][i], 
            dy=-1.5*V[1][i],
            color='r',
            head_width=0.1
            )

### --- Step 5d: Add loading labels:
col_names = data.columns.values.tolist()
for i in range(out_cor.n_components_):
  plt.text(x=2*V[0][i], 
           y=-2*V[1][i],
           s=col_names[i],
           color='r'
           )

plt.show()

### ----------------------------------------------------------------------------
### --- Step 6: Residual analysis:
### ----------------------------------------------------------------------------
X_hat = data.corr() - np.dot(np.dot(data.corr(), pd.DataFrame([V[0], -V[1]]).T), pd.DataFrame([V[0], -V[1]]))

fig = plt.figure(1, figsize=(12,6))
ax  = fig.add_subplot(111)
heatmap = plt.imshow(X_hat, interpolation='none')
heatmap.set_cmap('hot')
ax.set_xticks(range(out_cor.n_components_))
ax.set_yticks(range(out_cor.n_components_))
ax.set_xticklabels(data.columns.values.tolist(),
                   rotation=90,
                   size=10)
ax.set_yticklabels(data.columns.values.tolist(),
                   size=10)
plt.colorbar()
plt.show()
