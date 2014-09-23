Oncoscape is developed at the Fred Hutchinson Cancer Research Center under the auspices 
of the Solid Tumor Translational Research initiative.

Oncoscape is as an SPA -- a single page web application -- using JavaScript in the browser 
and R (primarily) on the backend server.  It is an R package, though the immediate web-facing http
server, currently written in R, will likely change over time to a more traditional 
architecture.  

The goal of Oncoscape is to provide browser-based, user-friendly data exploration tools
for rich clinical and molecular cancer data, supported by statistically powerful
analysis.  R is very well-suited to handling data, and performing analysis. JavaScript
in the browser provides a rich and nimble user experience.

Oncoscape's design encourages custom deployments focused on any clinical/molecular data set.
Oncoscape, here at GitHub, ships with patient and molecular data from the TCGA's study
of Glioblastoma multiforme.

