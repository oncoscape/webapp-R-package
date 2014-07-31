default:
	m4 -E index.pre > index.html
	R CMD install --no-test-load --no-lock ../../..
	R --vanilla -f run.R
