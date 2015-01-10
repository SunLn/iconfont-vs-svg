all: gulp

gulp:
	npm install
	gulp

watch:
	npm install
	gulp
	gulp watch

prod:
	npm install
	gulp
	gulp prod