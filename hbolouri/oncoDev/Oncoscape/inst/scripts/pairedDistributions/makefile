default:
	m4 index.pre > index.html
	R CMD install  --no-test-load ../../..
	R --vanilla -f run.R
