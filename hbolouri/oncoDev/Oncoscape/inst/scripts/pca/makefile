default:
	m4 index.pre > index.html
	R CMD install  --no-test-load --no-lock --preclean ../../..
	R -f run.R
