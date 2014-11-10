Contents of this file
============
* Tutorial Overview
* Running the Examples

Tutorial Overview
============
- Introduce attendees not familiar with Principal Component Analysis (PCA) to the commonly used dimension reduction approach.
- Focus on real data analysis with R and Python. 

Tutorial Prerequisites
------------
Attendees are expected to have a working knowledge of statistics or linear algebra and R or Python.

Tutorial Outline
------------
- Motivation for PCA
- Overview of PCA (e.g. checking of assumptions, deciding how many components to use, etc.)
- Two aplications of PCA
- Extensions of PCA 

Running the Examples
============

Software Prerequisites
------------
Installation of R/Python and the following R/Python packages:
- R: lattice, blockcluster (optional), RTextTools (optional), RJSONIO (optional), httr (optional)
- Python: matplotlib, numpy, os, pandas, scipy, sklearn 

If scraping Meetup data from scratch:
- Get an API key from Meetup.com: https://secure.meetup.com/meetup_api/key/
- Save it as a string in the file 'meetup.apikey' (located in the 'Code' folder)
 
Running the examples
------------
- Clone the repository and navigate to 'Code' folder it in the Terminal.
- Example 1: Run the R/Python code as follows:
```{r}
# In R:
source("Example1.R")
```
 
```python
# In Python:
execfile("Example1.py")
```

- Example 2: Run the R/Python code as follows:
```{r}
# In R:
source("Example2.R")
```
 
```python
# In Python:
execfile("Example2.py")
```
